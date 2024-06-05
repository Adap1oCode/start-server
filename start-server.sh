#!/bin/bash
update_system() {
    sudo apt update
    sudo apt install -y git nano curl wget
}

# Function to change the hostname
change_hostname() {
    read -p "Enter the new hostname: " new_hostname
    if [ -z "$new_hostname" ]; then
        echo "Hostname cannot be empty. Exiting."
        exit 1
    fi

    # Change the hostname
    full_hostname="$new_hostname.adaplo.co.uk"
    sudo hostnamectl set-hostname "$full_hostname"
    echo "Hostname changed to $full_hostname"

    # Update /etc/hosts
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$full_hostname/" /etc/hosts
    echo "/etc/hosts updated with the new hostname"
}

# Function to run specified commands
run_commands() {
    # Remove and recreate the .ssh directory
    rm -r ~/.ssh
    mkdir ~/.ssh

    # Generate a new SSH key with .adaplo.co.uk appended to the hostname
    hostname=$(hostname)
    full_hostname="$hostname"
    ssh-keygen -t rsa -b 4096 -C "$full_hostname" -f ~/.ssh/$full_hostname
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/$full_hostname

    # Display the public key
    cat ~/.ssh/$full_hostname.pub

    # Prompt user to type 'c' to continue
    read -p "Type 'c' to continue after copying the public key: " confirm
    while [ "$confirm" != "c" ]; do
        read -p "Invalid input. Please type 'c' to continue: " confirm
    done
}

update_dns_servers() {
    # Backup the current resolv.conf
    sudo cp /etc/resolv.conf /etc/resolv.conf.bak

    # Clear current DNS server entries
    sudo sed -i '/^nameserver/d' /etc/resolv.conf

    # Add Cloudflare and Google DNS servers
    echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
    echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

    echo "DNS servers updated successfully."
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
    update_system
    update_dns_servers
    current_hostname=$(hostname)
    echo "The current hostname is: $current_hostname"
    change_hostname
    update_dns_servers
    run_commands
    run_github_setup
     
}

# Execute the main function
main
