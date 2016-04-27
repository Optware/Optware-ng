#!/bin/sh
feed=http://ipkg.nslu2-linux.org/optware-ng/%TARGET%
ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-static/ {print $2}')
wget -O /tmp/$ipk_name $feed/$ipk_name
tar -C /tmp -xvzf /tmp/$ipk_name ./data.tar.gz
tar -C / -xzvf /tmp/data.tar.gz
rm -f /tmp/$ipk_name /tmp/data.tar.gz
echo "src/gz optware-ng $feed" > %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf
echo "dest %OPTWARE_TARGET_PREFIX%/ /" >> %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf

echo "Bootstraping done"
