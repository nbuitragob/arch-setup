#!/bin/bash
ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
locale-gen

pacman -S --noconfirm grub sudo networkmanager efibootmgr dosfstools os-prober mtools
systemctl enable NetworkManager
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI

grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

read -p 'Username: ' USERNAME
read -sp 'Password: ' PASSWORD
echo
read -sp 'Verify password: ' PASSWORD_2
if [ "$PASSWORD" = "$PASSWORD_2" ]; then
       echo -e "\npasswords match"
else 
       echo "passwords don't match"
       exit 1
fi       

userdel $USERNAME
useradd $USERNAME
echo -e "$PASSWORD\n$PASSWORD" | passwd "$USERNAME" 
echo -e "$PASSWORD\n$PASSWORD" | passwd root
echo -e "$USERNAME\tALL=(ALL:ALL) ALL" >> /etc/sudoers 
mkdir -p /home/$USERNAME

pacman -S --needed --noconfirm i3 lightdm lightdm-gtk-greeter xorg picom firefox xorg-server xorg-xinit lxterminal \
	network-manager-applet gvim

MACHINE="$1"
if [ "$MACHINE" = "AMD" ]; then 
    echo "Installing AMD driver"	
    pacman -S --noconfirm xf86-video-amdgpu
else 
    echo "Installing VBOX driver"	
    pacman -S --noconfirm virtualbox-guest-utils
fi

chown $USERNAME:$USERNAME /home/$USERNAME
systemctl enable lightdm
