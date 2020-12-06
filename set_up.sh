#!/bin/bash
cp config/linux/locale.gen /etc/locale.gen
cp config/linux/hostname /etc/hostname
cp config/linux/hosts /etc/hosts
cp config/linux/vconsole.conf /etc/vconsole.conf


sh scripts/install_grub.sh

cp config/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
mkdir -p /etc/X11/xorg.conf.d/
cp config/lightdm/20-keyboard.conf /etc/X11/xorg.conf.d/
