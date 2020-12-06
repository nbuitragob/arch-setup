#!/bin/bash
cp config/linux/locale.gen /etc/locale.gen
cp config/linux/hostname /etc/hostname
cp config/linux/hosts /etc/hosts
cp config/linux/vconsole.conf /etc/vconsole.conf


scripts/install_grub.sh "$1"

mkdir -p /etc/X11/xorg.conf.d/
cp config/lightdm/20-keyboard.conf /etc/X11/xorg.conf.d/
cp -r dotfiles/.config /home/melferas/
chowm -R /home/melferas
