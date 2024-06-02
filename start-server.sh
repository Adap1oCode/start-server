#!/bin/bash

# Function to change the hostname
change_hostname() {
    read -p "Enter the new hostname: " new_hostname
    if [ -z "$new_hostname" ]; then
        echo "Hostname cannot be empty. Exiting."
        exit 1
    fi

    # Change the hostname
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Hostname changed to $new_hostname"

    # Update /etc/hosts
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$new_hostname/" /etc/hosts
    echo "/etc/hosts updated with the new hostname"
}

# Function to run specified commands
run_commands() {
    sudo apt update
    sudo apt install -y git nano curl wget

    # Remove and recreate the .ssh directory
    rm -r ~/.ssh
    mkdir ~/.ssh

    # Generate a new SSH key
    hostname=$(hostname)
    ssh-keygen -t rsa -b 4096 -C "$hostname" -f ~/.ssh/$hostname
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/$hostname

    # Display the public key
    cat ~/.ssh/$hostname.pub

    # Pause for 40 seconds
    echo "Pausing for 40 seconds..."
    sleep 40
}

# Function to run the GitHub setup commands
run_github_setup() {
    ssh -T git@github.com
    git clone git@github.com:Adap1oCode/server-setup.git /opt/server-setup
    sudo chmod -R 755 /opt/server-setup
    bash '/opt/server-setup/0 - menu.sh'
}

# Main function to prompt user
main() {
    read -p "Do you want to change the existing hostname? (Y/N): " answer
    case $answer in
        [Yy]* ) change_hostname;;
        [Nn]* ) echo "No changes made.";;
        * ) echo "Invalid input. Please enter Y or N.";;
    esac

    read -p "Do you want to run the specified commands? (Y/N): " answer
    case $answer in
        [Yy]* ) run_commands;;
        [Nn]* ) echo "Commands not executed.";;
        * ) echo "Invalid input. Please enter Y or N.";;
    esac

    read -p "Do you want to run the GitHub setup commands? (Y/N): " answer
    case $answer in
        [Yy]* ) run_github_setup;;
        [Nn]* ) echo "GitHub setup commands not executed.";;
        * ) echo "Invalid input. Please enter Y or N.";;
    esac
}

# Execute the main function
main
