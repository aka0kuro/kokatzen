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
# Variables
######################################################
BTRFS_MOUNT_OPTS="ssd,noatime,compress=zstd:1,space_cache=v2,autodefrag"

KERNEL_PKGS="linux"
BASE_PKGS="base sudo linux-firmware"
FS_PKGS="dosfstools btrfs-progs"

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

	# compruebe que el firmware está en el modo de configuración
	case $secure_boot in 
		[sS] ) 
			# La salida de estado de bootctl debería tener
			# Arranque seguro: deshabilitado (configuración)
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

# Dimensión de swap
read -p "`echo -e '\033[1;92m\nIngrese la dimensión de la swap: \033[0m'`"  swap

# Creamos las particiones
sgdisk --clear --new=1:0:+512MiB --typecode=1:ef00 --change-name=1:EFI --new=2:0:+"$swap"GiB --typecode=2:8200 --change-name=2:cryptswap --new=3:0:0 --typecode=3:8300 --change-name=3:cryptsystem $device >/dev/null 2>&1

partitions=$(lsblk --paths --list --noheadings --output=name,size,model | grep --invert-match "loop" | cat --number)

# EFI particion
echo -e "\033[1;92m\n\nSeleccione el número de partición EFI: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número: \033[0m'`" efi_id
efi_part=$(echo "$partitions" | awk "\$1 == $efi_id { print \$2}")

# root particion
echo -e "\033[1;92m\n\nSeleccione el número de partición root: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número: \033[0m'`" root_id
root_part=$(echo "$partitions" | awk "\$1 == $root_id { print \$2}")

# Borrar el encabezado LUKS existente
# https://wiki.archlinux.org/title/Dm-crypt/Drive_preparation#Wipe_LUKS_header
# Borrar todas las claves
cryptsetup erase $root_part 2> /dev/null
# Asegúrese de que no queden ranuras activas
cryptsetup luksDump $root_part 2> /dev/null
# Eliminar el encabezado LUKS para evitar que cryptsetup lo detecte
wipefs --all $root_part 2> /dev/null

# swap partition
# swap is important, see [In defence of swap](https://chrisdown.name/2018/01/02/in-defence-of-swap.html)
echo -e "\033[1;92m\n\nSeleccione el número de partición swap: \033[0m"
echo -e "\033[1;97m$partitions\033[0m"
read -p "`echo -e '\033[1;92mIngrese el número: \033[0m'`" swap_id
swap_part=$(echo "$partitions" | awk "\$1 == $swap_id { print \$2}") || swap_part=""

# Wipe existing LUKS header
cryptsetup erase $swap_part 2> /dev/null
cryptsetup luksDump $swap_part 2> /dev/null
wipefs --all $swap_part 2> /dev/null

}

function formateando(){

	echo -e " \033[0;91m
######################################################
# Format the partitions
# https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions
######################################################
"
# EFI partition
echo "Formatting EFI partition ..."
echo "Running command: mkfs.fat -n boot -F 32 $efi_part"
# create fat32 partition with name(label) boot
mkfs.fat -n boot -F 32 "$efi_part"

# swap partition
echo "Formatting swap partition ..."
echo "Running command: mkswap -L swap $swap_part"
# create swap partition with label swap
mkswap -L swap "$swap_part"
	
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
