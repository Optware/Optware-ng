#!/bin/sh

if test 0 != `id -u`; then
    echo 'Please run as root'
    exit 1
fi
 
if test `uname -m` = armv5teb ; then
    optware_target=slugos5be
else
    optware_target=slugos5le
fi

feed=http://ipkg.nslu2-linux.org/feeds/optware/${optware_target}/cross/unstable
latest_xsh=`wget -q -O- ${feed} | grep '\.xsh' | sed -e 's/.*xsh">//' -e 's/<.*//'`

if test -n "${latest_xsh}"; then
    cd /tmp
    rm -f ${latest_xsh}
    wget ${feed}/${latest_xsh}
    sh ${latest_xsh}
fi
