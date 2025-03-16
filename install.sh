#!/bin/bash
#
# install.sh - Automated installation script for the picoctf tool.
# Created by Mahros Alqabay
#
# This script installs the picoctf tool on your system by copying
# the 'picoctf' script to /usr/local/bin, ensuring it is executable,
# and allowing you to run picoctf globally.
#
# Source code for picoctf (provided in this repository):
#
#   #!/bin/bash
#
#   # Show help/manual for the tool
#   show_help() {
#       echo "picoctf - A versatile tool for handling picoCTF flags"
#       ...
#   }
#   ...
#
# Usage:
#   1. Ensure the picoctf file is present in this directory.
#   2. Make this script executable: chmod +x install.sh
#   3. Run the script: ./install.sh
#

# Check if the picoctf file exists in the current directory.
if [ ! -f "picoctf" ]; then
    echo "Error: picoctf script not found in the current directory."
    exit 1
fi

# Ensure the picoctf file is executable.
chmod +x picoctf

# Copy picoctf to /usr/local/bin for global usage.
echo "Installing picoctf to /usr/local/bin..."
if sudo cp picoctf /usr/local/bin/; then
    echo "Installation successful! You can now run picoctf from any terminal."
else
    echo "Installation failed. Please check your permissions and try again."
    exit 1
fi
