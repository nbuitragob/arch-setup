#!/bin/bash
# encoding: utf-8

##################################################
#		    Variables 			 #
##################################################
# Computer Name
HOSTN=void-pc

# Admin username for the brand new installed system
read -p 'Admin username: ' USERNAME

# Admin's and root's password for the brand new installed system
read -p 'test your keys' KEY_TEST
read -sp 'Password: ' PASSWORD
echo
read -sp 'Verify password: ' PASSWORD_2
if [ "$PASSWORD" = "$PASSWORD_2" ]; then
       echo -e "\npasswords match"
else 
       echo "passwords don't match"
       exit 1
fi


# Keyboard Layout
KEYBOARD_LAYOUT=la-latin1

timedatectl set-ntp true

# Loads the keyboard layout
loadkeys $KEYBOARD_LAYOUT

# Admin username for the brand new installed system
read -p 'Admin username: ' USERNAME

# Your language, used for localization purposes
LANGUAGE=en_US

# Geography Localization. Verify the directory /usr/share/zoneinfo/<Zone>/<SubZone>
LOCALE=America/Bogota

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

##################################################
#		    Script 			 #
##################################################
#### Partitioning
echo "HD Initialization"
# Set the partition table to GPT type 
printf "g\nn\n\n\n${BOOT_SIZE}\nt\n1\nn\n\n\n${SWAP_SIZE}\nt\n\n19\nn\n\n\n${ROOT_SIZE}\nn\n\n\n\nw\n" | fdisk $HD


# Formats the root, home and boot partition to the specified file system
echo "Formating boot partition"
mkfs.fat -F32 ${HD}1 1>/dev/null
echo "Formating root partition"
mkfs.$ROOT_FS ${HD}3 -L Root 1>/dev/null
echo "Formating home partition"
mkfs.$HOME_FS ${HD}4 -L Home 1>/dev/null
# Initializes the swap
echo "Formating swap partition"
mkswap ${HD}2
swapon ${HD}2

echo "Mounting partitions"
# mounts the root partition
mount ${HD}3 /mnt
# mounts the home partition
mkdir /mnt/home
mount ${HD}4 /mnt/home

#### Installation
echo "Running pactrap base base-devel git linux linux-firmware"
pacstrap /mnt base base-devel git linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

###########################################
#### Enters in the new system (chroot) ####
###########################################
arch-chroot /mnt << EOF
mkdir -p /home/$USERNAME
cd /home/$USERNAME
git clone https://github.com/nbuitragob/arch-setup
cd arch-setup
chown -R $USERNAME:$USERNAME /home/$USERNAME

echo "setting up locale"
cat /home/$USERNAME/arch-setup/config/linux/locale.gen
cp /home/$USERNAME/arch-setup/config/linux/locale.gen /etc/locale.gen

echo "setting up host"
cat /home/$USERNAME/arch-setup/config/linux/hostname
echo 
cat /home/$USERNAME/arch-setup/config/linux/hosts
cp /home/$USERNAME/arch-setup/config/linux/hostname /etc/hostname
cp /home/$USERNAME/arch-setup/config/linux/hosts /etc/hosts
cp /home/$USERNAME/arch-setup/config/linux/vconsole.conf /etc/vconsole.conf

echo "Setting up locale ln -sf /usr/share/zoneinfo/$LOCALE /etc/localtime"
ln -sf /usr/share/zoneinfo/$LOCALE /etc/localtime

echo "hwclock --systohc"
hwclock --systohc
echo "locale-gen"
locale-gen

#grub installation
echo "installing grub sudo networkmanager efibootmgr dosfstools os-prober mtools"
pacman -S --noconfirm grub sudo networkmanager efibootmgr dosfstools os-prober mtools
echo "enabling network manager"
systemctl enable NetworkManager
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI

grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

#Additional programs
echo "Installing additional programs"
pacman -S --needed --noconfirm i3 lightdm lightdm-gtk-greeter xorg picom firefox xorg-server xorg-xinit lxterminal \
	network-manager-applet gvim lightdm-webkit2-greeter feh thunar go
	
MACHINE="$1"
if [ "$MACHINE" = "AMD" ]; then 
    echo "Installing AMD driver"	
    pacman -S --noconfirm xf86-video-amdgpu
else 
    echo "Installing VBOX driver"
    sh /home/$USERNAME/arch-setup/vbox_resolution.sh
    pacman -S --noconfirm virtualbox-guest-utils
fi

# Root password for the brand new installed system

#Admin user creation
sh -c "echo '$USERNAME:$PASSWORD' | chpasswd"
sh -c "echo 'root:$PASSWORD' | chpasswd"
sh -c "echo -e '$USERNAME\tALL=(ALL:ALL) ALL' >> /etc/sudoers" 

#Yay installation
git clone https://aur.archlinux.org/yay.git
chown -R $USERNAME:$USERNAME /home/$USERNAME
cd yay
sudo -u $USERNAME makepkg -si

systemctl enable lightdm
mkdir -p /etc/X11/xorg.conf.d/
cp /home/$USERNAME/arch-setup/config/lightdm/20-keyboard.conf /etc/X11/xorg.conf.d/
cp -r /home/$USERNAME/arch-setup/dotfiles/.config /home/$USERNAME/
cp -r /home/$USERNAME/arch-setup/dotfiles/.bashrc /home/$USERNAME/
chown -R $USERNAME:$USERNAME /home/$USERNAME
EOF

echo "Umounting partitions"
umount /mnt/{boot,home,}
