#!/bin/bash
echo "------------------disable usb ports--------------------------"

# sudo modprobe -r uas
# sudo modprobe -r usb-storage
cd /etc/modprobe.d

sudo chmod -R 777 /etc/modprobe.d/blacklist.conf
sudo echo -e "blacklist uas\nblacklist usb_storage">>blacklist.conf


sudo touch /etc/modprobe.d/disable_usb.conf
sudo chmod -R 777 /etc/modprobe.d/disable_usb.conf
sudo echo "install usb-storage /bin/false" > disable_usb.conf #&& sudo modprobe -r uas && sudo modprobe -r usb-storage

sleep 1
sudo modprobe -r uas && sudo modprobe -r usb-storage