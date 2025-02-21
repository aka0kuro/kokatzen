#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

logo (){ 
echo -e "$RED
██╗  ██╗ ██████╗ ██╗  ██╗ █████╗ ████████╗███████╗███████╗███╗   ██╗
██║ ██╔╝██╔═══██╗██║ ██╔╝██╔══██╗╚══██╔══╝╚══███╔╝██╔════╝████╗  ██║
█████╔╝ ██║   ██║█████╔╝ ███████║   ██║     ███╔╝ █████╗  ██╔██╗ ██║
██╔═██╗ ██║   ██║██╔═██╗ ██╔══██║   ██║    ███╔╝  ██╔══╝  ██║╚██╗██║
██║  ██╗╚██████╔╝██║  ██╗██║  ██║   ██║   ███████╗███████╗██║ ╚████║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝
$ENDCOLOR"
}

logo
echo

# Selecting the target for the installation.
PS3="$GREEN Select the disk where Arch Linux is going to be installed: $ENDCOLOR"
select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd|mm");
do
    DISK=$ENTRY
    echo -e "$GREEN Installing Arch Linux on $DISK.$ENDCOLOR"
    break
done

# Confirming the disk selection.
read -r -p "$(echo -e $GREEN"This will delete the current partition table on $DISK. Do you agree [y/N]?" $ENDCOLOR)" response
response=${response,,}
if [[ ! ("$response" =~ ^(yes|y)$) ]]; then
    echo -e "$RED Quitting. $ENDCOLOR"
    exit
fi

# Selecting the kernel flavor to install.
kernel_selector () {
    echo "List of kernels:"
    echo "1) Stable — Vanilla Linux kernel and modules, with a few patches applied."
    echo "2) Hardened — A security-focused Linux kernel."
    echo "3) Longterm — Long-term support (LTS) Linux kernel and modules."
    echo "4) Zen Kernel — Optimized for desktop usage."
    read -r -p "Insert the number of the corresponding kernel: " choice
    echo "$choice will be installed"
    case $choice in
        1 ) kernel=linux
            ;;
        2 ) kernel=linux-hardened
            ;;
        3 ) kernel=linux-lts
            ;;
        4 ) kernel=linux-zen
            ;;
        * ) echo "You did not enter a valid selection."
            kernel_selector
    esac
}
clear
logo

echo "Selecting the kernel to install."
kernel_selector

clear
logo
echo "Selecting the installation method."
# Setting username.
read -r -p "Please enter name for a user account (leave empty to skip): " username

echo
# Setting password.
if [[ -n $username ]]; then
    read -r -p -s "Please enter a password for the user account: " password
fi

echo
# Choose locales.
read -r -p "Please insert the locale you use in this format (xx_XX): " locale

echo
# Choose keyboard layout.
read -r -p "Please insert the keyboard layout you use: " kblayout

echo
# Choose timezone.
read -r -p "Please insert the timezone you use: (Europe/Madrid)" timezone

echo
# Choose languaje.
read -r -p "Please insert the language you use: (en_US.UTF-8)" language

BASE_PKGS="base sudo linux-firmware iptables-nft python nano git python linux-$kernel_selector-headers networkmanager dosfstools e2fsprogs btrfs-progs man-db"

echo
read -p "Press Enter to continue, otherwise press any other key. " start_install

if [[ -n $start_install ]] ; then
    exit 1
fi


echo "
######################################################
# Verify the boot mode
# https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
######################################################
"
if [[ -e /sys/firmware/efi/efivars ]] ; then
    echo "UEFI mode OK."
else
    echo "System not booted in UEFI mode!"
    exit 1
fi
echo -e "\n"
read -p "Do you want to set up secure boot with your own key? [Y/n] " secure_boot
secure_boot="${secure_boot:-y}"
secure_boot="${secure_boot,,}"

# check the firmware is in the setup mode
if [[ $secure_boot == y ]] ; then
    # bootctl status output should have
    # Secure Boot: disabled (setup)
    setup_mode=$(bootctl status | grep -E "Secure Boot.*setup" | wc -l)
    if [[ $setup_mode -ne 1 ]] ; then
        echo "The firmware is not in the setup mode. Please check BIOS."
        read -p "Continue without secure boot? [y/N] " keep_going
        keep_going="${keep_going:-n}"
        keep_going="${keep_going,,}"
        if [[ keep_going == y ]] ; then
            secure_boot="n"
        else
            exit 1
        fi
    fi
fi

echo "
######################################################
# Check internet connection
# https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet
######################################################
"
ping -c 1 archlinux.org > /dev/null
if [[ $? -ne 0 ]] ; then
    # Function to prompt the user to retry or exit
    retry_or_exit() {
        echo "Do you want to try again? (y/n)"
        read -r choice
        case "$choice" in
            y|Y) return 0 ;;
            n|N) echo "Exiting..."; exit 1 ;;
            *) echo "Invalid choice. Exiting..."; exit 1 ;;
        esac
    }
    
    # Get available Wi-Fi interfaces
    interfaces=($(iwctl device list | awk '/wlan/ {print $2}'))
    
    # Check if any Wi-Fi interfaces were found
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "No Wi-Fi interfaces detected. Is your Wi-Fi card enabled?"
        exit 1
    fi
    
    # Display interfaces and allow the user to select one
    while true; do
        echo "Detected Wi-Fi interfaces:"
        for i in "${!interfaces[@]}"; do
            echo "[$i] ${interfaces[$i]}"
        done
    
        read -p "Select the number of the Wi-Fi interface: " index
    
        if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -lt "${#interfaces[@]}" ]; then
            interface="${interfaces[$index]}"
            echo "Using interface: $interface"
            break
        else
            echo "Invalid selection."
            retry_or_exit
        fi
    done
    
    # Scan for available networks
    echo "Scanning for Wi-Fi networks..."
    iwctl station "$interface" scan
    sleep 2
    
    # Get list of available networks
    networks=($(iwctl station "$interface" get-networks | awk -F '  +' 'NR>5 {print $2}'))
    
    # Check if any networks were found
    if [ ${#networks[@]} -eq 0 ]; then
        echo "No Wi-Fi networks found. Try again."
        retry_or_exit
    fi
    
    # Display available networks and allow the user to select one
    while true; do
        echo "Detected Wi-Fi networks:"
        for i in "${!networks[@]}"; do
            echo "[$i] ${networks[$i]}"
        done
    
        read -p "Select the number of the Wi-Fi network to connect to: " net_index
    
        if [[ "$net_index" =~ ^[0-9]+$ ]] && [ "$net_index" -lt "${#networks[@]}" ]; then
            network="${networks[$net_index]}"
            echo "Connecting to: $network"
            break
        else
            echo "Invalid selection."
            retry_or_exit
        fi
    done
    
    # Request Wi-Fi password
    read -s -p "Enter the password for $network: " password
    echo
    
    # Connect to the Wi-Fi network
    iwctl station "$interface" connect "$network" --passphrase "$password"
    
    echo "Attempting to connect to $network..."
    sleep 3
    
    # Check if the connection was successful
    if iwctl station "$interface" show | grep -q "connected"; then
        echo "Successfully connected to $network."
    else
        echo "Failed to connect to $network."
        retry_or_exit
    fi
else
    echo "Internet OK."
fi

# Checking the microcode to install.
CPU=$(grep vendor_id /proc/cpuinfo)
if [[ $CPU == *"AuthenticAMD"* ]]; then
    microcode=amd-ucode
else
    microcode=intel-ucode
fi


echo "
######################################################
# Update the system clock
# https://wiki.archlinux.org/title/Installation_guide#Update_the_system_clock
######################################################
"
timedatectl set-ntp true

echo "
######################################################
# EFI boot settings
# https://man.archlinux.org/man/efibootmgr.8
######################################################
"
efibootmgr --unicode
efi_boot_id=" "
while [[ -n $efi_boot_id ]]; do
    echo -e "\nDo you want to delete any boot entries?: "
    read -p "Enter boot number (empty to skip): " efi_boot_id
    if [[ -n $efi_boot_id ]] ; then
        efibootmgr --bootnum $efi_boot_id --delete-bootnum --unicode
    fi
done

echo "
######################################################
# Partition disks
# https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
######################################################
"
umount -R /mnt
devices=$(lsblk --nodeps --paths --list --noheadings --sort=size --output=name,size,model | grep --invert-match "loop" | cat --number)

device_id=" "
while [[ -n $device_id ]]; do
    echo -e "Choose device to format:"
    echo "$devices"
    read -p "Enter a number (empty to skip): " device_id
    if [[ -n $device_id ]] ; then
        device=$(echo "$devices" | awk "\$1 == $device_id { print \$2}")
        fdisk "$device"
    fi
done

partitions=$(lsblk --paths --list --noheadings --output=name,size,model | grep --invert-match "loop" | cat --number)

# EFI partition
echo -e "\n\nTell me the EFI partition number:"
echo "$partitions"
read -p "Enter a number: " efi_id
efi_part=$(echo "$partitions" | awk "\$1 == $efi_id { print \$2}")

# root partition
echo -e "\n\nTell me the root partition number:"
echo "$partitions"
read -p "Enter a number: " root_id
root_part=$(echo "$partitions" | awk "\$1 == $root_id { print \$2}")

# Wipe existing LUKS header
# https://wiki.archlinux.org/title/Dm-crypt/Drive_preparation#Wipe_LUKS_header
# Erase all keys
cryptsetup erase $root_part 2> /dev/null
# Make sure there is no active slots left
cryptsetup luksDump $root_part 2> /dev/null
# Remove LUKS header to prevent cryptsetup from detecting it
wipefs --all $root_part 2> /dev/null

# swap partition
# swap is important, see [In defence of swap](https://chrisdown.name/2018/01/02/in-defence-of-swap.html)
echo -e "\n\nTell me the swap partition number:"
echo "$partitions"
read -p "Enter a number or press ENTER to skip: " swap_id
if [[ -n $swap_id ]] ; then
    swap_part=$(echo "$partitions" | awk "\$1 == $swap_id { print \$2}") || swap_part=""

    # Wipe existing LUKS header
    cryptsetup erase $swap_part 2> /dev/null
    cryptsetup luksDump $swap_part 2> /dev/null
    wipefs --all $swap_part 2> /dev/null
fi

