#!/bin/bash
# encoding: utf-8

##################################################
#		    Variables 			 #
##################################################
# Computer Name
HOSTN=void-pc

# Keyboard Layout
KEYBOARD_LAYOUT=la-latin1

# Your language, used for localization purposes
LANGUAGE=en_US

# Geography Localization. Verify the directory /usr/share/zoneinfo/<Zone>/<SubZone>
LOCALE=America/Bogota

# Admin username for the brand new installed system
read -p 'Admin username: ' USERNAME

# Admin's and root's password for the brand new installed system
read -sp 'Password: ' PASSWORD
echo
read -sp 'Verify password: ' PASSWORD_2
if [ "$PASSWORD" = "$PASSWORD_2" ]; then
       echo -e "\npasswords match"
else 
       echo "passwords don't match"
       exit 1
fi

# Root password for the brand new installed system
ROOT_PASSWD=$PASSWORD

########## Hard Disk Partitioning Variable
# ANTENTION, this script erases ALL YOU HD DATA (specified bt $HD)
read -p 'Filesystem e.g /dev/sda: ' HD
# Boot Partition Size: /boot
BOOT_SIZE=+1G
# Root Partition Size: /
ROOT_SIZE=+100G
# Swap partition size: /swap
SWAP_SIZE=+4G
# The /home partition will occupy the remain free space

# Partitions file system
HOME_FS=ext4
ROOT_FS=ext4

# Extra packages (not obligatory)
EXTRA_PKGS='vim'


##################################################
#		    Script 			 #
##################################################
# Loads the keyboard layout
loadkeys $KEYBOARD_LAYOUT

#### Partitioning
echo "HD Initialization"
# Set the partition table to GPT type 
printf "g\nn\n\n\n+${BOOT_SIZE}\nn\n\n\n${SWAP_SIZE}\nt\n\n19\nn\n\n\n${ROOT_SIZE}\nn\n\n\n\nw\n" | fdisk $HD
