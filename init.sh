pacman -S --noconfirm xf86-video-amdgpu lightdm lightdm-gtk-greeter xorg-server gvim i3 lxterminal networkmanager nm-applet
systemctl enable lightdm.service
systemctl enable NetworkManager.service
cp lightdm.conf /etc/lightdm/lightdm.conf
ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
hwclock --systohc