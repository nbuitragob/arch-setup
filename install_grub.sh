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

adduser "$USERNAME"
echo "$PASSWORD" | passwd "$USERNAME" --stdin
echo "$PASSWORD" | passwd root --stdin
echo "$USERNAME	ALL=(ALL:ALL) ALL" >> /etc/sudoers 
mkdir /home/$USERNAME
chowm $USERNAME:$USERNAME /home/$USERNAME

su $USERNAME
echo $PASSWORD | sudo -S pacman -S --needed --noconfirm i3 lightdm lightdm-gtk-greeter xorg-server xorg-xinit lxterminal network-manager-applet gvim
echo $PASSWORD | sudo -S systemctl enable lightdm.service
echo $PASSWORD | sudo -S cp lightdm.conf /etc/lightdm/lightdm.conf
echo $PASSWORD | sudo -S mkdir -p /etc/X11/xorg.conf.d/
echo $PASSWORD | sudo -S cp 20-keyboard.conf /etc/X11/xorg.conf.d/

if [[ "$MACHINE"=="AMD" ]]
then 
    echo "Installing AMD driver"	
    echo $PASSWORD | sudo -S pacman -S --noconfirm xf86-video-amdgpu
else 
    echo "Installing VBOX driver"	
    echo $PASSWORD | sudo -S pacman -S --noconfirm xf86-video-qxl
fi

cd /home/melferas
git clone https://github.com/nbuitragob/arch-setup.git
cd /home
