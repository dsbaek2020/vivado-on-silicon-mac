#!/bin/bash

# This runs the Vivado offline installer in batch mode.

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"
validate_linux

# Read installation directory path from file
install_dir_path=$(tr -d "\n\r\t " < "/home/user/scripts/install_dir")

# Check if xsetup exists and is executable
if [ ! -x "$install_dir_path/xsetup" ]; then
    f_echo "Error: xsetup not found or not executable in $install_dir_path"
    exit 1
fi

f_echo "Found xsetup in $install_dir_path"

# Set config file path for Vivado 2024.1
config_file="/home/user/scripts/install_configs/202410.txt"

# Verify config file exists
if [ ! -f "$config_file" ]; then
    f_echo "Error: Config file not found at $config_file"
    exit 1
fi

f_echo "Using configuration file: $config_file"

# Run xsetup in batch mode with EULA agreement
f_echo "Starting Vivado 2024.1 offline installation..."

if "$install_dir_path/xsetup" --agree XilinxEULA,3rdPartyEULA --batch Install --config "$config_file"; then
    f_echo "Vivado was successfully installed."
    f_echo "You can now run start_container.sh to launch Vivado."
else
    f_echo "An error occurred during installation. Please check the logs and run cleanup.sh before retrying."
    exit 1
fi

