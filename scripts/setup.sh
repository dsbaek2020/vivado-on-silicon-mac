#!/bin/zsh

# Initial setup on host (macOS) side

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"

# Make sure that the script is run in macOS and not the Docker container
validate_macos

# Make sure permissions are right
if [[ "$current_user" == "root" ]]; then
    f_echo "Do not execute this script as root."
    exit 1
fi

# Make sure there are no previous installations in this folder
if [ -d "$script_dir/../Xilinx" ]; then
    f_echo "A previous installation was found. To reinstall, remove the Xilinx folder."
    exit 1
fi

validate_internet

f_echo "Advancing with the setup requires the following:"
f_echo "- Agreeing to Xilinx'/AMD's EULAs (which can be obtained by extracting the installation archive)"
f_echo "- Enabling WebTalk data collection for version 2021.1 and agreeing to corresponding terms"
f_echo "- Installation of Rosetta 2 and agreeing to Apple's corresponding software license agreement"
f_echo "Proceed [Y/n]?"
read user_consent
case $user_consent in
[yY]|[yY][eE]*)
    f_echo "Continuing setup..."
    ;;
[nN]|[nN][oO]*)
    f_echo "Aborting setup."
    exit 1
    ;;
*)
    f_echo "Invalid option."
    exit 1
    ;;
esac

# Check if the Mac is Intel or Apple Silicon
if [[ "$(uname -m)" == "x86_64" ]]; then
    f_echo "Mac is Intel-based. Rosetta installation is not required."
else
    if arch -arch x86_64 uname -m > /dev/null 2>&1; then
        f_echo "Rosetta is already installed."
    else
        f_echo "Rosetta is not installed."
        f_echo "Proceeding with Rosetta installation..."
        if ! softwareupdate --install-rosetta --agree-to-license; then
            f_echo "Error installing Rosetta."
            exit 1
        fi
    fi
fi

# Get Vivado installation directory
f_echo "You need to put the extracted Vivado installation folder (containing xsetup) into this folder if you have not done so already."
installation_dir=""
while true; do
    installation_dir=""
    f_echo "Then, drag and drop the Vivado installation directory into this terminal window and press Enter: "
    read installation_dir
    parent_dir=$(dirname "$script_dir")

    if ! [[ $installation_dir == $parent_dir/* ]]; then
        f_echo "You need to move the installation directory into the folder!"
        continue
    fi

    if [ ! -x "$installation_dir/xsetup" ]; then
        f_echo "xsetup file not found or not executable in the specified directory!"
        continue
    fi

    f_echo "Valid Vivado installation directory detected."
    break
done

# write directory path to "install_dir"
install_dir_path="${installation_dir#$parent_dir}"
install_dir_path="/home/user$install_dir_path"
echo -n "$install_dir_path" > "$script_dir/install_dir"

# Make the user own the whole folder
if ! chown -R $current_user "$script_dir/.."; then
    f_echo "Higher privileges are required to make the folder owned by the user."
    if ! sudo chown -R $current_user "$script_dir/.."; then
        f_echo "Error setting $current_user as owner of this folder."
        exit 1
    fi
fi

# Make the scripts executable
if xattr -p com.apple.quarantine "$script_dir/xvcd/bin/xvcd" &>/dev/null; then
    if ! xattr -d com.apple.quarantine "$script_dir/xvcd/bin/xvcd"; then
        f_echo "You need to remove the quarantine attribute from $script_dir/xvcd/bin/xvcd manually."
        wait_for_user_input
    fi
fi

if ! chmod +x "$script_dir"/*.sh "$script_dir/xvcd/bin/xvcd" "$installation_dir/xsetup"; then
    f_echo "Error making the scripts executable."
    exit 1
fi

# make sure that Docker is installed
start_docker

# Attempt to enable Rosetta and set swap to at least 2GiB in Docker
eval "$script_dir/configure_docker.sh"

# Generate the Docker image
if ! eval "$script_dir/gen_image.sh"; then
    exit 1
fi

# Set VNC resolution
f_echo "Set the resolution of the container. Keep in mind that high resolutions might make text and images appear small."
f_echo "You can change the resolution manually in the vnc_resolution file later."
f_echo "Press enter to leave the default (1920x1080) or type in your preference:"
read resolution

if [[ $resolution =~ "^[0-9]+x[0-9]+$" ]]; then
    f_echo "Setting $resolution as resolution"
    echo "$resolution" > "$script_dir/vnc_resolution"
else
    f_echo "Setting the default of $vnc_default_resolution"
    echo "$vnc_default_resolution" > "$script_dir/vnc_resolution"
fi
echo ""

# copy de_start.desktop autostart file
mkdir -p "$script_dir/../.config/autostart"
cp "$script_dir/de_start.desktop" "$script_dir/../.config/autostart/de_start.desktop"
mkdir "$script_dir/../Desktop"

# Start container
f_echo "Now, the container is started (only terminal, no GUI) and the actual installation process begins."
docker run --init -it --rm --name vivado_container \
    --mount type=bind,source="$script_dir/..",target="/home/user" \
    -p 127.0.0.1:5901:5901 --platform linux/amd64 x64-linux \
    sudo -H -u user bash /home/user/scripts/install_vivado.sh

