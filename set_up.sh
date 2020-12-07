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

loadkeys $KEYBOARD_LAYOUT

#### Partitioning
echo "HD Initialization"
# Set the partition table to GPT type 
printf "g\nn\n\n\n+1G\nn\n\n\n+4G\nt\n\n19\nn\n\n\n100G\nn\n\n\n\nw\n" | fdisk /dev/sda
