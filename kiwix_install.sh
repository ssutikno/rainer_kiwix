#!/bin/bash

# Kiwix Installer Script for Linux on RAINER SERVER

# Define the Kiwix download URL
KIWIX_URL="https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz"

# Define the installation directory
INSTALL_DIR="/usr/local/kiwix"
# Define the Kiwix data directory
DATA_DIR="/var/kiwix/data"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y wget tar
    elif command_exists yum; then
        sudo yum install -y wget tar
    else
        echo "Unsupported package manager. Please install wget and tar manually."
        exit 1
    fi
}

# Function to download and install Kiwix
install_kiwix() {
    echo "Downloading Kiwix..."
    wget -O /tmp/kiwix.tar.gz "$KIWIX_URL"

    echo "Extracting Kiwix..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -xzf /tmp/kiwix.tar.gz -C "$INSTALL_DIR" --strip-components=1

    echo "Cleaning up..."
    rm /tmp/kiwix.tar.gz

    echo "Creating symbolic link..."
    sudo ln -sf "$INSTALL_DIR/kiwix-serve" /usr/local/bin/kiwix-serve
    sudo ln -sf "$INSTALL_DIR/kiwix-manage" /usr/local/bin/kiwix-manage

    echo "Kiwix installation completed."
}

# Function to create the Kiwix data directory and set permissions
setup_data_directory() {
    echo "Setting up Kiwix data directory..."
    sudo mkdir -p "$DATA_DIR"
    sudo chown -R nobody:nogroup "$DATA_DIR"
    sudo chmod -R 755 "$DATA_DIR"
}

# Function to create the library.xml file and add .zim files
create_library() {
    echo "Creating Kiwix library..."
    cd "$DATA_DIR"
    sudo -u nobody kiwix-manage library.xml create

    for zim_file in *.zim; do
        if [ -f "$zim_file" ]; then
            sudo -u nobody kiwix-manage library.xml add "$zim_file"
        fi
    done

    echo "Library created and .zim files added."
}

# Function to create a systemd service
create_systemd_service() {
    echo "Creating systemd service for Kiwix..."

    sudo bash -c 'cat << EOF > /etc/systemd/system/kiwix.service
[Unit]
Description=Kiwix Server
After=network.target

[Service]
ExecStart=/usr/local/bin/kiwix-serve --port=9000 --library=/var/kiwix/data/library.xml
WorkingDirectory=/usr/local/kiwix
User=nobody
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

    echo "Enabling and starting the Kiwix service..."
    sudo systemctl daemon-reload
    sudo systemctl enable kiwix.service
    sudo systemctl start kiwix.service
}

# Main script execution
install_dependencies
install_kiwix
setup_data_directory
create_library
create_systemd_service

echo "Kiwix installation and setup completed. Kiwix server will run on port 9000 automatically on boot."
echo "Place your .zim files in /var/kiwix/data."