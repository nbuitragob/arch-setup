#!/bin/bash
MACHINE=$1

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
cp locale.gen /etc/locale.gen
locale-gen

cp hostname /etc/hostname
cp hosts /etc/hosts
cp vconsole.conf /etc/vconsole.conf

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
if [[ "$PASSWORD"=="$PASSWORD_" ]]; then
       echo -e "\npasswords match"
else 
       echo "passwords don't match"
       exit 1
fi       


useradd $USERNAME
echo -e "$PASSWORD\n$PASSWORD" | passwd "$USERNAME" 
echo -e "$PASSWORD\n$PASSWORD" | passwd root
echo -e "$USERNAME\tALL=(ALL:ALL) ALL" >> /etc/sudoers 
mkdir -p /home/$USERNAME
