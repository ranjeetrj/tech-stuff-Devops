echo "------------------Enable usb ports--------------------------"
sed -i '/blacklist usb_storage/d' /etc/modprobe.d/blacklist.conf
sed -i '/blacklist uas/d' /etc/modprobe.d/blacklist.conf
sed -i '/usb-storage/d' /etc/modprobe.d/disable_usb.conf
echo "Port enabled status --> $?"
