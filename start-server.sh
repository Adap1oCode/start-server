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

    # Prompt user to type 'c' to continue
    read -p "Type 'c' to continue after copying the public key: " confirm
    while [ "$confirm" != "c" ]; do
        read -p "Invalid input. Please type 'c' to continue: " confirm
    done
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
    current_hostname=$(hostname)
    echo "The current hostname is: $current_hostname"
    change_hostname
    run_commands
    run_github_setup
     
}

# Execute the main function
main
