#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

# Color to scipt
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[94m" 
ENDCOLOR="\e[0m"

# Logo to script
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

infomation () {
clear
logo
password () {
	echo
	# Setting password.
	if [[ -n $username ]]; then
		read -s -p "$(echo -e $GREEN"Enter your password: " $ENDCOLOR)" password
		echo -e "\n"
		
		read -s -p "$(echo -e $GREEN"Confir your password: " $ENDCOLOR)" password_confirm
		echo -e "\n"
	fi
	if [[ "$password" == "$password_confirm" ]]; then
	    echo -e "${GREEN}Passwords match.$ENDCOLOR"
	else
	    echo -e "${RED}Passwords do not match.$ENDCOLOR" && sleep 3 && clear && logo && password
	fi
}
echo -e "${GREEN}Selecting the installation method. $ENDCOLOR"
# Setting username.
read -r -p "$(echo -e $GREEN"Please enter name for a user account ${RED}(leave empty to skip)${GREEN}: "$ENDCOLOR)" username
password

echo
# Choose locales.
read -r -p "$(echo -e $GREEN"Please insert the locale you use in this format ${RED}(xx_XX)${GREEN}: "$ENDCOLOR)" locale

echo
# Choose keyboard layout.
read -r -p "$(echo -e $GREEN"Please insert the keyboard layout you use: ${RED}(es)${GREEN}: "$ENDCOLOR)" kblayout

echo
# Choose timezone.
read -r -p "$(echo -e $GREEN"Please insert the timezone you use: ${RED}(Europe/Madrid)${GREEN}: "$ENDCOLOR)" timezone

echo
# Choose languaje.
read -r -p "$(echo -e $GREEN"Please insert the language you use: ${RED}(en_US.UTF-8)${GREEN}: "$ENDCOLOR)" language

echo
read -p "$(echo -e $GREEN"Press Enter to continue, otherwise press any other key. "$ENDCOLOR)" start_install

}

# Selecting the kernel flavor to install.
kernel_selector () {
	clear
	logo

	echo -e "${BLUE}Selecting the kernel to install. $ENDCOLOR"
	echo
    echo -e "${GREEN}List of kernels: $ENDCOLOR"
    echo -e "${RED}1)$GREEN Stable — Vanilla Linux kernel and modules, with a few patches applied. $ENDCOLOR"
    echo -e "${RED}2)$GREEN Hardened — A security-focused Linux kernel. $ENDCOLOR"
    echo -e "${RED}3)$GREEN Longterm — Long-term support (LTS) Linux kernel and modules. $ENDCOLOR"
    echo -e "${RED}4)$GREEN Zen Kernel — Optimized for desktop usage. $ENDCOLOR"
    read -r -p "Insert the number of the corresponding kernel: " choice

    case $choice in
        1 ) kernel=linux
            ;;
        2 ) kernel=linux-hardened
            ;;
        3 ) kernel=linux-lts
            ;;
        4 ) kernel=linux-zen
            ;;
        * ) echo -e "${REED}You did not enter a valid selection. $ENDCOLOR" && clear && logo
            kernel_selector
    esac
	echo -e "${GREEN}The selected kernel is:$BLUE $kernel $ENDCOLOR"
    sleep 2
	# Confirming the disk selection.
	while true; do
		echo
		read -r -p "$(echo -e $GREEN"Correct kernel selection?. Do you agree $RED[y/N]$GREEN?" $ENDCOLOR)" response
		response=${response,,}
		if [[ "$response" =~ ^(yes|y)$ ]]; then
			infomation
			break 
		elif [[ ! "$response" =~ ^(yes|y)$ ]]; then
			echo
			echo -e "${RED}Invalid response. Please type 'yes' or 'y' to continue.${ENDCOLOR}" & sleep 2 & kernel_selector
		fi
	done
}

disk () {
	clear
	logo
	echo

	# Selecting the target for the installation.
	disks=$(lsblk -dpno NAME | grep -P "/dev/sd|nvme|vd|mm")

	counter=1
	declare -a disk_array
	for disk in $disks; do
		echo -e "${BLUE}[$counter] $disk${ENDCOLOR}"
		disk_array+=("$disk")
		((counter++))
	done

	while true; do
		echo -e "${GREEN}Please select a disk (1-${counter}):${ENDCOLOR}"
		read -r selection

		# Validar selección
		if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -lt "$counter" ]; then
			DISK=${disk_array[$selection-1]}
			echo
			echo -e "${GREEN}Installing Arch Linux on$BLUE $DISK.${ENDCOLOR}"
			break
		else     
			echo
			echo -e "${RED}Invalid selection. Please try again.${ENDCOLOR}" && sleep 2 && disk
		fi
	done

# Confirming the disk selection.
while true; do
	echo
	read -r -p "$(echo -e $GREEN"This will delete the current partition table on $DISK. Do you agree $RED[y/N]$GREEN?" $ENDCOLOR)" response
	response=${response,,}
	if [[ "$response" =~ ^(yes|y)$ ]]; then
		kernel_selector
		break 
	elif [[ ! "$response" =~ ^(yes|y)$ ]]; then
		echo -e "${RED}Invalid response. Please type 'yes' or 'y' to continue.${ENDCOLOR}" & disk
	fi
done
}
disk


if [[ -n $start_install ]] ; then
    exit 1
fi

BASE_PKGS="base sudo linux-firmware iptables-nft python nano git python linux-$kernel_selector-headers networkmanager dosfstools e2fsprogs btrfs-progs man-db"

if [[ -e /sys/firmware/efi/efivars ]] ; then
    echo -e "${GREEN}UEFI mode OK.${ENDCOLOR}"
else
    echo -e "${RED}System not booted in UEFI mode!${ENDCOLOR}"
    exit 1
fi
echo -e "\n"
read -p "$(echo -e $GREEN"Do you want to set up secure boot with your own key? $RED[Y/n] " $ENDCOLOR)" secure_boot
secure_boot="${secure_boot:-y}"
secure_boot="${secure_boot,,}"

# check the firmware is in the setup mode
if [[ $secure_boot == y ]] ; then
    # bootctl status output should have
    # Secure Boot: disabled (setup)
    setup_mode=$(bootctl status | grep -E "Secure Boot.*setup" | wc -l)
    if [[ $setup_mode -ne 1 ]] ; then
        echo -e "${GREEN}The firmware is not in the setup mode. Please check BIOS.$ENDCOLOR"
        read -p "$(echo -e $GREEN"Continue without secure boot? ${RED}[y/N] " $ENDCOLOR)" keep_going
        keep_going="${keep_going:-n}"
        keep_going="${keep_going,,}"
        if [[ keep_going == y ]] ; then
            secure_boot="n"
        else
            exit 1
        fi
    fi
fi

ping -c 1 archlinux.org > /dev/null
if [[ $? -ne 0 ]] ; then
    # Function to prompt the user to retry or exit
    retry_or_exit() {
        echo -e "${GREEN}Do you want to try again? ${RED}(y/n)${ENDCOLOR}"
        read -r choice
        case "$choice" in
            y|Y) return 0 ;;
            n|N) echo "${RED}Exiting...${ENDCOLOR}"; exit 1 ;;
            *) echo -e "${GREEN}Invalid choice. Exiting...${ENDCOLOR}"; exit 1 ;;
        esac
    }
    
    # Get available Wi-Fi interfaces
    interfaces=($(iwctl device list | awk '/wlan/ {print $2}'))
    
    # Check if any Wi-Fi interfaces were found
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo -e "${RED}No Wi-Fi interfaces detected. Is your Wi-Fi card enabled?${ENDCOLOR}"
        exit 1
    fi
    
    # Display interfaces and allow the user to select one
    while true; do
        echo -e "${GREEN}Detected Wi-Fi interfaces:${ENDCOLOR}"
        for i in "${!interfaces[@]}"; do
            echo -e "${RED}[$i] ${interfaces[$i]}${ENDCOLOR}"
        done
    
        read -p "$(echo -e $GREEN"Select the number of the Wi-Fi interface: " $ENDCOLOR)" index
    
        if [[ "$index" =~ ^[0-9]+$ ]] && [ "$index" -lt "${#interfaces[@]}" ]; then
            interface="${interfaces[$index]}"
            echo -e "${GREEN}Using interface: $interface${ENDCOLOR}"
            break
        else
            echo -e "${RED}Invalid selection.${ENDCOLOR}"
            retry_or_exit
        fi
    done
    
    # Scan for available networks
    echo -e "${GREEN}Scanning for Wi-Fi networks...${ENDCOLOR}"
    iwctl station "$interface" scan
    sleep 2
    
    # Get list of available networks
    networks=($(iwctl station "$interface" get-networks | awk -F '  +' 'NR>5 {print $2}'))
    
    # Check if any networks were found
    if [ ${#networks[@]} -eq 0 ]; then
        echo -e "${RED}No Wi-Fi networks found. Try again.${ENDCOLOR}"
        retry_or_exit
    fi
    
    # Display available networks and allow the user to select one
    while true; do
        echo -e "${GREEN}Detected Wi-Fi networks:${ENDCOLOR}"
        for i in "${!networks[@]}"; do
            echo -e "${GREEN}[$i] ${networks[$i]}${ENDCOLOR}"
        done
    
        read -p "$(echo -e $GREEN"Select the number of the Wi-Fi network to connect to: " $ENDCOLOR)" net_index
    
        if [[ "$net_index" =~ ^[0-9]+$ ]] && [ "$net_index" -lt "${#networks[@]}" ]; then
            network="${networks[$net_index]}"
            echo -e "${GREEN}Connecting to: ${RED}$network${ENDCOLOR}"
            break
        else
            echo "${RED}Invalid selection.${ENDCOLOR}"
            retry_or_exit
        fi
    done
    
    # Request Wi-Fi password
    read -s -p "$(echo -e $GREEN"Enter the password for $network: " $ENDCOLOR)" password
    echo
    
    # Connect to the Wi-Fi network
    iwctl station "$interface" connect "$network" --passphrase "$password"
    
    echo -e "${GREEN}Attempting to connect to $network...${ENDCOLOR}"
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

timedatectl set-ntp true

efibootmgr --unicode
efi_boot_id=" "
while [[ -n $efi_boot_id ]]; do
    echo -e "\nDo you want to delete any boot entries?: "
    read -p "$(echo -e $GREEN"Enter boot number (empty to skip): " $ENDCOLOR)" efi_boot_id
    if [[ -n $efi_boot_id ]] ; then
        efibootmgr --bootnum $efi_boot_id --delete-bootnum --unicode
    fi
done

umount -R /mnt
devices=$(lsblk --nodeps --paths --list --noheadings --sort=size --output=name,size,model | grep --invert-match "loop" | cat --number)

device_id=" "
while [[ -n $device_id ]]; do
    echo -e "Choose device to format:"
    echo "$devices"
    read -p "$(echo -e $GREEN"Enter a number (empty to skip): " $ENDCOLOR)" device_id
    if [[ -n $device_id ]] ; then
        device=$(echo "$devices" | awk "\$1 == $device_id { print \$2}")
        fdisk "$device"
    fi
done

partitions=$(lsblk --paths --list --noheadings --output=name,size,model | grep --invert-match "loop" | cat --number)

# EFI partition
echo -e "\n\nTell me the EFI partition number:"
echo "$partitions"
read -p "$(echo -e $GREEN"Enter a number: " $ENDCOLOR)" efi_id
efi_part=$(echo "$partitions" | awk "\$1 == $efi_id { print \$2}")

# root partition
echo -e "\n\nTell me the root partition number:"
echo "$partitions"
read -p "$(echo -e $GREEN"Enter a number: " $ENDCOLOR)" root_id
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
read -p "$(echo -e $GREEN"Enter a number or press ENTER to skip: " $ENDCOLOR)" swap_id
if [[ -n $swap_id ]] ; then
    swap_part=$(echo "$partitions" | awk "\$1 == $swap_id { print \$2}") || swap_part=""

    # Wipe existing LUKS header
    cryptsetup erase $swap_part 2> /dev/null
    cryptsetup luksDump $swap_part 2> /dev/null
    wipefs --all $swap_part 2> /dev/null
fi
