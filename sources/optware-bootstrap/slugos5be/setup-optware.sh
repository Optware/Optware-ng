#!/bin/sh

if test 0 != `id -u`; then
    echo 'Please run as root'
    exit 1
fi
 
optware_target=slugos5be
feed=http://ipkg.nslu2-linux.org/feeds/optware/${optware_target}/cross/unstable
latest_xsh=`wget -q -O- ${feed} | grep '\.xsh' | sed -e 's/.*xsh">//' -e 's/<.*//'`

if test -n "${latest_xsh}"; then
    cd /tmp
    wget ${feed}/${latest_xsh}
    sh ${latest_xsh}
fi
