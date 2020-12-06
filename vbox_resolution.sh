#!bin/bash
chmod a+rx scripts/lightdm_xrandr.sh
cp scripts/lightdm_xrandr.sh /usr/share/
mkdir -p /etc/lightdm/lightdm.conf.d/
cp config/lightdm/lightdm_resolution_fix.conf /etc/lightdm/lightdm.conf.d/xrandr_resize.conf
