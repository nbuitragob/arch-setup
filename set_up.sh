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
BOOT_SIZE=1024
# Root Partition Size: /
ROOT_SIZE=102400
# Swap partition size: /swap
SWAP_SIZE=4096
# The /home partition will occupy the remain free space

# Partitions file system
BOOT_FS=fat32
HOME_FS=ext4
ROOT_FS=ext4

# Extra packages (not obligatory)
EXTRA_PKGS='vim'


######## Auxiliary variables. THIS SHOULD NOT BE ALTERED
BOOT_START=1
BOOT_END=$(($BOOT_START+$BOOT_SIZE))

SWAP_START=$BOOT_END
SWAP_END=$(($SWAP_START+$SWAP_SIZE))

ROOT_START=$SWAP_END
ROOT_END=$(($ROOT_START+$ROOT_SIZE))

HOME_START=$ROOT_END

##################################################
#		    Script 			 #
##################################################
# Loads the keyboard layout
loadkeys $KEYBOARD_LAYOUT

#### Partitioning
echo "HD Initialization"
# Set the partition table to GPT type 
parted -s $HD mklabel gpt &> /dev/null

# Remove any older partitions
parted -s $HD rm 1 &> /dev/null
parted -s $HD rm 2 &> /dev/null
parted -s $HD rm 3 &> /dev/null
parted -s $HD rm 4 &> /dev/null

# Create boot partition
echo "Create boot partition"
parted -s $HD mkpart primary $BOOT_FS $BOOT_START $BOOT_END 1>/dev/null
parted -s $HD set 1 boot on 1>/dev/null

# Create swap partition
echo "Create swap partition"
parted -s $HD mkpart primary linux-swap $SWAP_START $SWAP_END 1>/dev/null

# Create root partition
echo "Create root partition"
parted -s $HD mkpart primary $ROOT_FS $ROOT_START $ROOT_END 1>/dev/null

# Create home partition
echo "Create home partition"
parted -s -- $HD mkpart primary $HOME_FS $HOME_START -0 1>/dev/null

# Formats the root, home and boot partition to the specified file system
echo "Formating boot partition"
mkfs.$BOOT_FS ${HD}1 -L Boot 1>/dev/null
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

#################################################################################################################################################
#### Enters in the new system (chroot) ####
arch-chroot /mnt << EOF
cd /home
git clone https://github.com/nbuitragob/arch-setup
cd arch-setup

echo "setting up locale"
cat /home/arch-setup/config/linux/locale.gen
cp /home/arch-setup/config/linux/locale.gen /etc/locale.gen

echo "setting up host"
cat /home/arch-setup/config/linux/hostname
echo 
cat /home/arch-setup/config/linux/hosts
cp /home/arch-setup/config/linux/hostname /etc/hostname
cp /home/arch-setup/config/linux/hosts /etc/hosts
cp /home/arch-setup/config/linux/vconsole.conf /etc/vconsole.conf

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

#Admin user creation
useradd $USERNAME
echo -e "$USERNAME\tALL=(ALL:ALL) ALL" >> /etc/sudoers 
mkdir -p /home/$USERNAME

#Additional programs
echo "Installing additional programs"
pacman -S --needed --noconfirm i3 lightdm lightdm-gtk-greeter xorg picom firefox xorg-server xorg-xinit lxterminal \
	network-manager-applet gvim lightdm-webkit2-greeter feh
	
MACHINE="$1"
if [ "$MACHINE" = "AMD" ]; then 
    echo "Installing AMD driver"	
    pacman -S --noconfirm xf86-video-amdgpu
else 
    echo "Installing VBOX driver"
    sh /home/arch-setup/vbox_resolution.sh
    pacman -S --noconfirm virtualbox-guest-utils
fi

#Yay installation
loadkeys $KEYBOARD_LAYOUT
git clone https://aur.archlinux.org/yay.git
cd yay
chown -R $USERNAME:$USERNAME /home/arch-setup
sudo -u $USERNAME makepkg -si

systemctl enable lightdm
mkdir -p /etc/X11/xorg.conf.d/
cp /home/arch-setup/config/lightdm/20-keyboard.conf /etc/X11/xorg.conf.d/
cp -r /home/arch-setup/dotfiles/.config /home/$USERNAME/
cp -r /home/arch-setup/dotfiles/.bashrc /home/$USERNAME/
chown -R $USERNAME:$USERNAME /home/$USERNAME
EOF

echo "Umounting partitions"
umount /mnt/{boot,home,}
