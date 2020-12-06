#!/bin/bash
pacman -S --needed --noconfirm i3 lightdm lightdm-gtk-greeter xorg-server xorg-xinit lxterminal network-manager-applet gvim
systemctl enable lightdm.service
cp lightdm.conf /etc/lightdm/lightdm.conf
mkdir -p /etc/X11/xorg.conf.d/
cp 20-keyboard.conf /etc/X11/xorg.conf.d/

if [[ "$MACHINE"=="AMD" ]]
then 
    echo "Installing AMD driver"	
    pacman -S --noconfirm xf86-video-amdgpu
else 
    echo "Installing VBOX driver"	
    pacman -S --noconfirm xf86-video-qxl
fi

USERNAME=$1
chown $USERNAME:$USERNAME /home/$USERNAME
cd /home/$USERNAME
