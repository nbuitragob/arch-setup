MACHINE=$1

ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc
cp locale.gen /etc/locale.gen
locale-gen

cp hostname /etc/hostname
cp hosts /etc/hosts
cp vconsole.conf /etc/vconsole.conf

if [[ "$MACHINE"=="AMD" ]]
then 
    pacman -S --noconfirm xf86-video-amdgpu
else 
    pacman -S --noconfirm xf86-video-vesa
fi

pacman -S --noconfirm grub sudo networkmanager lightdm lightdm-gtk-greeter xorg-server efibootmgr dosfstools os-prober mtools lxterminal network-manager-applet gvim
systemctl enable lightdm.service
mkdir -p /etc/X11/xorg.conf.d/
cp 20-keyboard.conf /etc/X11/xorg.conf.d/

systemctl enable NetworkManager
cp lightdm.conf /etc/lightdm/lightdm.conf

mkdir /boot/EFI
mount /dev/sda1 /boot/EFI

grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm --nedeed i3
