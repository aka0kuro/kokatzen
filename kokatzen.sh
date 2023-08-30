#! /bin/bash

######################################################
# Variable Color
######################################################
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

# Reset
Color_Off='\033[0m'       # Text Reset

######################################################
# Inicio del script
######################################################

function Inicio(){
	
	echo -e " \033[1;91m
██╗  ██╗ ██████╗ ██╗  ██╗ █████╗ ████████╗███████╗███████╗███╗   ██╗
██║ ██╔╝██╔═══██╗██║ ██╔╝██╔══██╗╚══██╔══╝╚══███╔╝██╔════╝████╗  ██║
█████╔╝ ██║   ██║█████╔╝ ███████║   ██║     ███╔╝ █████╗  ██╔██╗ ██║
██╔═██╗ ██║   ██║██╔═██╗ ██╔══██║   ██║    ███╔╝  ██╔══╝  ██║╚██╗██║
██║  ██╗╚██████╔╝██║  ██╗██║  ██║   ██║   ███████╗███████╗██║ ╚████║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝                                                                                                                                                        																							
\033[0m"

}
function Respuesta(){
	
	echo -e "\033[1;97m
Este es un script de instalación de Arch Linux.
Para iniciarlo, presione Enter, de lo contrario, presione cualquier otra tecla.
Sin embargo, no hay garantía de éxito.
Tampoco hay garantía de la seguridad de sus datos existentes.\033[0m
	"
	
	read -p "`echo -e '\033[1;92m¿Iniciar?\033[0m'`" inicio

	if [[ -n $inicio ]] ; then
		exit 1
	fi	

}
function Verificar_UEFI(){
	
	echo -e "\033[0;91m
######################################################
# Verificando el modo del boot
# https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode
######################################################\033[0m
	"
	
	if [[ -e /sys/firmware/efi/efivars ]] ; then
		echo -e "\033[1;97mUEFI modo activado.\033[0m"
	else
		echo "\033[0;91m¡El sistema no arrancó en modo UEFI!\033[0m"
		exit 1
	fi
	echo -e "\n"
	read -p "`echo -e '\033[1;92m¿Quiere configurar un arranque seguro con su propia clave? [S/n] \033[0m'`" secure_boot


	case $secure_boot in 
		[sS] ) 
			setup_mode=$(bootctl status | grep -E "Secure Boot.*setup" | wc -l)
			if [[ $setup_mode -ne 1 ]] ; then
				echo "El firmware no está en el modo de configuración. Verifique la BIOS."
				read -p "¿Continuar sin arranque seguro? [s/N] " keep_going
				case $keep_going in 
					[sS] ) 
						Internet;;
					[nN] )
						exit 1;;
					* ) echo -e "\033[1;97m\nOpcion invalida\033[0m";
					sleep 03; clear; Inicio; Verificar_UEFI;;
				esac
			fi;Internet;;
		[nN] )
			secure_boot="n"; Internet;;
		* ) echo -e "\033[1;97m\nOpcion invalida\033[0m";
			sleep 03; clear; Inicio; Verificar_UEFI;;
	esac
	
}

function Internet(){

	echo -e "\033[0;91m
######################################################
# Comprobando conexión a internet
# https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet
######################################################\033[0m
	"
	ping -c 1 archlinux.org >/dev/null 2>&1
	if [[ $? -ne 0 ]] ; then
		echo -e "\033[1;97mPor favor, compruebe la conexión a Internet.\033[0m"
		echo -e "\n"
		read -p "`echo -e '\033[1;92m¿Quiere configurar la conexión wifi? [S/n] \033[0m'`" wifi
		case $wifi in 
			[sS] ) 
				dispositivo=$(iwctl device list | grep --invert-match "Devices" | grep --invert-match "Name" | grep --invert-match "-" | awk '{print $2}' | head -n1 | cat --number)			
				echo -e "\033[1;97m $dispositivo\033[0m"
				read -p "`echo -e '\033[1;92mSelecciona la interfaz: \033[0m'`" wifi_id
				wifi_part=$(echo "$dispositivo" | awk "\$1 == $wifi_id { print \$2}")
				iwctl station $wifi_part scan 
				sleep 04
				SSID=$(iwctl station $wifi_part get-networks | grep --invert-match "Available" | grep --invert-match "Network" | grep --invert-match "-" | cat --number)
				echo -e "\033[1;97m$SSID\033[0m"
				read -p "`echo -e '\033[1;92mSelecciona tu SSID: \033[0m'`" wifi_ssid
				wifi_part_ssid=$(echo "$SSID" | awk "\$1 == $wifi_ssid { print \$2}")
				iwctl station $wifi_part connect $wifi_part_ssid
				sleep 04
				ping -c 1 archlinux.org >/dev/null 2>&1
				if [[ $? -ne 0 ]] ; then
					Internet
				else
					echo -e "\033[1;97mConectado a Internet.\033[0m"
				fi;;
			[nN] ) echo -e "\033[1;97m\nSaliendo del script\nSin internet no se puede instalar\033[0m";
				exit 1;;
			* ) echo -e "\033[1;97m\nOpcion invalida\033[0m";
				sleep 03; clear; Inicio; Internet;;
		esac
	else
		echo -e "\033[1;97mConectado a Internet.\033[0m"
	fi
}

function Clock(){

	echo -e " \033[0;91m
######################################################
# Actualizar reloj del sistema
# https://wiki.archlinux.org/title/Installation_guide#Update_the_system_clock
######################################################\033[0m
	"
timedatectl set-ntp true
echo -e "\033[1;97mActualizado Reloj del Sistema.\033[0m"

}

function UEFI_entradas(){
	
	echo -e " \033[0;91m
######################################################
# EFI configuracion boot
# https://man.archlinux.org/man/efibootmgr.8
######################################################\033[0m
"
efibootmgr
efi_boot_id=" "
while [[ -n $efi_boot_id ]]; do
    echo -e "\033[1;97m\n¿Desea eliminar alguna entrada del arranque?\033[0m"
    read -p "`echo -e '\033[1;92mIngrese el número de arranque (vacío para omitir): \033[0m'`"  efi_boot_id
    if [[ -n $efi_boot_id ]] ; then
        efibootmgr -b $efi_boot_id -B
    fi
done

}

function Particion(){

	echo -e " \033[0;91m
######################################################
# Particion de discos
# https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks
######################################################\033[0m
"
devices=$(lsblk --nodeps --paths --list --noheadings --sort=size --output=name,size,model | grep --invert-match "loop" | cat --number)

echo -e "\033[1;92m\nElege el dispositivo a formatear:\033[0m"
echo -e "\033[1;97m$devices\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número del disco: \033[0m'`"  device_id
device=$(echo "$devices" | awk "\$1 == $device_id { print \$2}")

read -p "`echo -e '\033[1;92m\nIngrese la dimensión de la swap: \033[0m'`"  swap

sgdisk --clear --new=1:0:+512MiB --typecode=1:ef00 --change-name=1:EFI --new=2:0:+"$swap"GiB --typecode=2:8200 --change-name=2:cryptswap --new=3:0:0 --typecode=3:8300 --change-name=3:cryptsystem $device >/dev/null 2>&1

partitions=$(lsblk --paths --list --noheadings --output=name,size,model | grep --invert-match "loop" | cat --number)

echo -e "\033[1;92m\n\nSeleccione el número de partición EFI: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número: \033[0m'`" efi_id
efi_part=$(echo "$partitions" | awk "\$1 == $efi_id { print \$2}")

echo -e "\033[1;92m\n\nSeleccione el número de partición root: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número: \033[0m'`" root_id
root_part=$(echo "$partitions" | awk "\$1 == $root_id { print \$2}")

cryptsetup erase $root_part 2> /dev/null

cryptsetup luksDump $root_part 2> /dev/null

wipefs --all $root_part 2> /dev/null

echo -e "\033[1;92m\n\nSeleccione el número de partición swap: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "Ingrese el número:" swap_id
swap_part=$(echo "$partitions" | awk "\$1 == $swap_id { print \$2}")

cryptsetup erase $swap_part 2> /dev/null
cryptsetup luksDump $swap_part 2> /dev/null
wipefs --all $swap_part 2> /dev/null

}

function Formateando_UEFI(){

	echo -e " \033[0;91m
######################################################
# Formateando Particiones
# https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions
######################################################\033[0m
"
echo -e "\033[1;97mFormateando Particion EFI...\033[0m"
echo -e "\033[1;97mCorriendo commando: mkfs.fat -n boot -F 32 $efi_part\033[0m"

mkfs.fat -n boot -F 32 "$efi_part" >/dev/null 2>&1

}

function Formateando_root(){
	echo " \033[0;91m
######################################################
# Encryptando Particion Root
# https://wiki.archlinux.org/title/Dm-crypt/Device_encryption
######################################################\033[0m
"

echo -e "\033[1;97mEncryptando particon root ...\033[0m"
ccryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --key-size 512 --iter-time 2000 --pbkdf argon2id --hash sha3-512 "$root_part"
echo -e "\033[1;97mDesencriptando la particion root ...\033[0m"
cryptsetup open "$root_part" cryptroot

echo -e "\033[1;97mFormateando particion root en BTRFS...\033[0m"
mkfs.btrfs -L ROOT -n 32k /dev/mapper/cryptroot

echo -e "\033[1;97mMontando particion root en /mnt...\033[0m"
mount /dev/mapper/cryptroot /mnt

echo -e "\033[1;97mCreando subvolumenes BTRFS...\033[0m"
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@abs
btrfs sub create /mnt/@tmp
btrfs sub create /mnt/@srv
btrfs sub create /mnt/@snapshots

echo -e "\033[1;97mMontando subvolumenes...\033[0m"
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@,clear_cache /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,var/abs,var/tmp,srv,.snapshots}
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@pkg /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@abs /dev/mapper/cryptroot /mnt/var/abs
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@tmp /dev/mapper/cryptroot /mnt/var/tmp
mount -o noatime,nodiratime,compress-force=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@srv /dev/mapper/cryptroot /mnt/srv
mount -o noatime,nodiratime,compres-forces=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

}

function Formateando_swap(){
	echo  " \033[0;91m
######################################################
# Encryptando Particion Swap
# https://wiki.archlinux.org/title/swap
######################################################\033[0m
"

echo -e "\033[1;97mEncryptando particon swap ...\033[0m"
cryptsetup open --type plain --key-file /dev/urandom $swap_part swap

echo -e "\033[1;97mMontando swap...\033[0m"
mkswap -L swap /dev/mapper/swap
swapon -L swap

}

function Instalacion(){
	echo  " \033[0;91m
######################################################
# Instalando sistema base
# https://wiki.archlinux.org/title/installation_guide#Installation
######################################################\033[0m
"
echo -e "\033[1;97mPaquetes a instalar: base \nbase-devel \nlinux-zen  \nlinux-zen-headers \nlinux-firmware \nintel-ucode \nefitools \nmkinitcpio \nnetworkmanager \nnano \nefibootmgr \nbtrfs-progs \nsudo \npolkit...\033[0m"
read -p "`echo -e '\033[1;92m¿Quiere Instalar paquetes adicionales a la instalacion? [S/n] \033[0m'`" add
case $add in 
	[sS] ) 
		read "Añade paquetes adiccionales(con un espacio entre ellos):" add_mas;
		pacstrap /mnt base base-devel linux-zen  linux-zen-headers linux-firmware intel-ucode efitools mkinitcpio networkmanager nano efibootmgr btrfs-progs sudo polkit wpa_supplicant $add_mas;;
	[nN] ) echo -e "\033[1;97m\nInstalando paquetes base\033[0m";
		pacstrap /mnt base base-devel linux-zen  linux-zen-headers linux-firmware intel-ucode efitools mkinitcpio networkmanager nano efibootmgr btrfs-progs sudo polkit wpa_supplicant;;
			
	* ) echo -e "\033[1;97m\nOpcion invalida\033[0m";
		sleep 03; clear; Inicio; Instalacion;;
esac

}

function fstab(){
echo " \033[0;91m
######################################################
# Generando fstab
# https://wiki.archlinux.org/title/Installation_guide#Fstab
######################################################\033[0m
"
echo -e "Generando fstab ..."
genfstab -U /mnt >> /mnt/etc/fstab

}

function horaria(){
echo " \033[0;91m
######################################################
# Colocando zona horaria
# https://wiki.archlinux.org/title/Installation_guide#Time_zone
######################################################\033[0m
"
echo -e "Configurando zona horaria..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
arch-chroot /mnt hwclock --systohc

}

function idioma(){
echo " \033[0;91m
######################################################
# Idioma
# https://wiki.archlinux.org/title/Installation_guide#Localization
######################################################\033[0m
"

echo -e "Configurando Idiomas ..."
arch-chroot /mnt sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=es_ES.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=es" > /mnt/etc/vconsole.conf

}

function network(){
echo " \033[0;91m
######################################################
# Activando NetworkManager
# https://wiki.archlinux.org/title/NetworkManager
######################################################\033[0m
"

arch-chroot /mnt systemctl enable systemd-resolved.service
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable wpa_supplicant.service

}


function config(){
	
root_block=$root_part
root_uuid=$(lsblk -dno UUID $root_block)
efi_uuid=$(lsblk -dno UUID $efi_part)

echo "cryptroot  UUID=$root_uuid  -  password-echo=no,x-systemd.device-timeout=0,timeout=0,no-read-workqueue,no-write-workqueue,discard"  >>  /mnt/etc/crypttab.initramfs

swap_uuid=$(lsblk -dno UUID $swap_part)
echo "cryptswap  UUID=$swap_uuid  /dev/urandom swap,offset=2048,cipher=aes-xts-plain64,size=256" >> /mnt/etc/crypttab
sed -i "/swap/ s:^UUID=[a-zA-Z0-9-]*\s:/dev/mapper/cryptswap  :" /mnt/etc/fstab

echo "Editing mkinitcpio ..."
sed -i '/^HOOKS=/ s/ udev//' /mnt/etc/mkinitcpio.conf
sed -i '/^HOOKS=/ s/ keymap//' /mnt/etc/mkinitcpio.conf
sed -i '/^HOOKS=/ s/ consolefont//' /mnt/etc/mkinitcpio.conf
sed -i '/^HOOKS=/ s/base/base systemd keyboard/' /mnt/etc/mkinitcpio.conf
sed -i '/^HOOKS=/ s/block/sd-vconsole block sd-encrypt/' /mnt/etc/mkinitcpio.conf

kernel_cmd="$kernel_cmd rootfstype=btrfs rootflags=subvol=/@ rw modprobe.blacklist=pcspkr"

echo "$kernel_cmd" > /mnt/etc/kernel/cmdline_fallback

arch-chroot /mnt mkdir -p /efi/EFI/Linux

    # Add line ALL_microcode=(/boot/*-ucode.img)
    sed -i '/^ALL_kver=.*/a ALL_microcode=(/boot/*-ucode.img)' /mnt/etc/mkinitcpio.d/linux-zen.preset
    # Add Arch splash screen and add default_uki= and fallback_uki=
    sed -i "s|^#default_options=.*|default_options=\"--splash /usr/share/systemd/bootctl/splash-arch.bmp\"\\ndefault_uki=\"/efi/EFI/Linux/ArchLinux-$KERNEL.efi\"|" /mnt/etc/mkinitcpio.d/linux-zen.preset
    sed -i "s|^fallback_options=.*|fallback_options=\"-S autodetect --cmdline /etc/kernel/cmdline_fallback\"\\nfallback_uki=\"/efi/EFI/Linux/ArchLinux-$KERNEL-fallback.efi\"|" /mnt/etc/mkinitcpio.d/linux-zen.preset
    # comment out default_image= and fallback_image=
    sed -i "s|^default_image=.*|#&|" /mnt/etc/mkinitcpio.d/linux-zen.preset
    sed -i "s|^fallback_image=.*|#&|" /mnt/etc/mkinitcpio.d/linux-zen.preset
    
rm /mnt/efi/initramfs-*.img 2>/dev/null
rm /mnt/boot/initramfs-*.img 2>/dev/null

echo "$kernel_cmd" > /mnt/etc/kernel/cmdline
echo "Regenerating the initramfs ..."
arch-chroot /mnt mkinitcpio -P

if [[ $secure_boot == y ]] ; then
    echo "
######################################################
# Secure boot setup
# https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot
######################################################
"
    arch-chroot /mnt pacman --noconfirm -S sbctl
    echo "Creating keys ..."
    arch-chroot /mnt sbctl create-keys
    arch-chroot /mnt chattr -i /sys/firmware/efi/efivars/{PK,KEK,db}*

    echo "Enroll keys ..."
    read -p "Do you want to add Microsoft's UEFI drivers certificates to the database? [Y/n] " ms_cert
    ms_cert="${ms_cert:-y}"
    ms_cert="${ms_cert,,}"
    if [[ $ms_cert == n ]] ; then
        arch-chroot /mnt sbctl enroll-keys 2>&1
    else
        arch-chroot /mnt sbctl enroll-keys --microsoft 2>&1
    fi
    # Ignore any error and force enroll keys
    # I need --yes-this-might-brick-my-machine for libvirt virtual machines
    if [[ $? -ne 0 ]] ; then
        read -p "Ignore error and enroll key anyway? [y/N] " force_enroll
        force_enroll="${force_enroll:-n}"
        force_enroll="${force_enroll,,}"
        if [[ $force_enroll == y ]] ; then
            if [[ $ms_cert == n ]] ; then
                arch-chroot /mnt sbctl enroll-keys --yes-this-might-brick-my-machine
            else
                arch-chroot /mnt sbctl enroll-keys --microsoft --yes-this-might-brick-my-machine
            fi
        else
            echo "Did not enroll any keys"
            echo "Now chroot into new system and enroll keys manully with"
            echo "sbctl enroll-keys"
            echo "exit the chroot to continue installation"
            arch-chroot /mnt
        fi
    fi

    echo "Signing unified kernel image ..."
        arch-chroot /mnt sbctl sign --save "/efi/EFI/Linux/ArchLinux-linux-zen.efi"
        arch-chroot /mnt sbctl sign --save "/efi/EFI/Linux/ArchLinux-linux-zen-fallback.efi"

fi

echo "
######################################################
# Set up UFEI boot the unified kernel image directly
# https://wiki.archlinux.org/title/Unified_kernel_image#Directly_from_UEFI
######################################################
"
efi_dev=$(lsblk --noheadings --output PKNAME $efi_part)
efi_part_num=$(echo $efi_part | grep -Eo '[0-9]+$')
arch-chroot /mnt pacman --noconfirm -S --needed efibootmgr

echo "Creating UEFI boot entries for each unified kernel image ..."

    arch-chroot /mnt efibootmgr --create --disk /dev/${efi_dev} --part ${efi_part_num} --label "ArchLinux-linux-zen" --loader "EFI\\Linux\\ArchLinux-linux-zen.efi" --quiet
    arch-chroot /mnt efibootmgr --create --disk /dev/${efi_dev} --part ${efi_part_num} --label "ArchLinux-linux-zen-fallback" --loader "EFI\\Linux\\ArchLinux-linux-zen-fallback.efi" --quiet

arch-chroot /mnt efibootmgr
echo -e "\n\nDo you want to change boot order?: "
read -p "Enter boot order (empty to skip): " boot_order
if [[ -n $boot_order ]] ; then
    echo -e "\n"
    arch-chroot /mnt efibootmgr --bootorder ${boot_order}
    echo -e "\n"
fi

}

Inicio
Respuesta
Verificar_UEFI
sleep 02
Clock
sleep 02
UEFI_entradas
sleep 02
Particion
sleep 02 
Formateando_UEFI
sleep 02
Formateando_root
sleep 02
Formatenado_swap
sleep 02
Instalacion
sleep 02
fstab
sleep 02
horaria
sleep 02
idioma
sleep 02
network
sleep 02
config
