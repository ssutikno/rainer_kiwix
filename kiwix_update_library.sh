#!/bin/bash

# Recreate Kiwix Library Script

# Define the Kiwix data directory
DATA_DIR="/var/kiwix/data"
LIBRARY_FILE="$DATA_DIR/library.xml"

# Function to create the library.xml file and add .zim files
create_library() {
    echo "Creating Kiwix library..."

    # Remove existing library.xml if it exists
    if [ -f "$LIBRARY_FILE" ]; then
        echo "Removing existing library.xml..."
        sudo rm "$LIBRARY_FILE"
    fi

    # Create a new library.xml
    sudo -u nobody kiwix-manage "$LIBRARY_FILE" create

    # Add all .zim files in the data directory to the library.xml
    for zim_file in "$DATA_DIR"/*.zim; do
        if [ -f "$zim_file" ]; then
            echo "Adding $zim_file to the library..."
            sudo -u nobody kiwix-manage "$LIBRARY_FILE" add "$zim_file"
        fi
    done

    echo "Library recreated and .zim files added."
}

# Main script execution
create_library

echo "Kiwix library recreation completed. All .zim files in /var/kiwix/data have been added to the library.xml."