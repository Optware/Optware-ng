#!/bin/sh
feed=http://ipkg.nslu2-linux.org/optware-ng/%TARGET%
cd /tmp 
ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-static/ {print $2}') 
wget $feed/$ipk_name 
tar -xvzf $ipk_name ./data.tar.gz 
tar -C / -xzvf data.tar.gz 
echo "src/gz alllexx $feed" > %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf 
echo "dest %OPTWARE_TARGET_PREFIX%/ /" >> %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf

echo "Bootstraping done"
