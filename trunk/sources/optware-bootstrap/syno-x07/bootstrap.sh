#!/bin/sh

# Replaced during packaging based on value in target-specific.mk
REAL_OPT_DIR=/volume1/.optware

if [ -e "$REAL_OPT_DIR" ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf $REAL_OPT_DIR"
    echo "  rm -rf /usr/lib/ipkg"
    echo "This will remove all existing optware packages."
    echo
    echo "You must *reboot* and then restart the bootstrap script."
    exit 1
fi

BS_DIR="$REAL_OPT_DIR/ipkg-bootstrap"

echo "Creating temporary ipkg repository..."
rm -rf $BS_DIR
mkdir -p $BS_DIR
ln -s $BS_DIR /tmp/ipkg
cat >>$BS_DIR/ipkg.conf <<EOF
dest root /
lists_dir ext $BS_DIR/ipkg
EOF

if ! which md5sum >/dev/null && which openssl >/dev/null; then \
    sed -i -e "/md5sum.*sed/{s|\`md5sum|\`openssl md5|;s|sed 's/ .*//'|sed 's/.* //'|}" ./ipkg.sh
fi

export IPKG_CONF_DIR=$BS_DIR 
export IPKG_DIR_PREFIX=$BS_DIR 

echo "Installing optware-bootstrap package..."
sh ./ipkg.sh install optware-bootstrap.ipk

echo "Installing ipkg..."
sh ./ipkg.sh install ipkg-opt.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BS_DIR
rm /tmp/ipkg

echo "Installing wget..."
/opt/bin/ipkg install wget.ipk || exit 1

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/syno-x07/cross/unstable" >/opt/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
