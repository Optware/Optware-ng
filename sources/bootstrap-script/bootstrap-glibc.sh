#!/bin/sh
feed=http://ipkg.nslu2-linux.org/optware-ng/%TARGET%
ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-static/ {print $2}')
wget -O /tmp/$ipk_name $feed/$ipk_name
tar -C /tmp -xvzf /tmp/$ipk_name ./data.tar.gz
tar -C / -xzvf /tmp/data.tar.gz
rm -f /tmp/$ipk_name /tmp/data.tar.gz
echo "src/gz optware-ng $feed" > %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf
echo "dest %OPTWARE_TARGET_PREFIX%/ /" >> %OPTWARE_TARGET_PREFIX%/etc/ipkg.conf

PATH=$PATH:%OPTWARE_TARGET_PREFIX%/bin:%OPTWARE_TARGET_PREFIX%/sbin

echo "Bootstraping done"

echo "Installing glibc-locale package to generate needed %OPTWARE_TARGET_PREFIX%/lib/locale/locale-archive"
echo "================================================================================="

%OPTWARE_TARGET_PREFIX%/bin/ipkg update
%OPTWARE_TARGET_PREFIX%/bin/ipkg install glibc-locale

echo "================================================================================="
echo "Removing glibc-locale package to save space: this doesn't remove generated %OPTWARE_TARGET_PREFIX%/lib/locale/locale-archive"

%OPTWARE_TARGET_PREFIX%/bin/ipkg remove glibc-locale
