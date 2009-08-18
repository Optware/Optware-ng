#!/bin/sh

# Replaced during packaging based on value in target-specific.mk
REAL_OPT_DIR=/mnt/disk1/.optware

if [ -e "$REAL_OPT_DIR" ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf $REAL_OPT_DIR"
    echo "  rm -rf /usr/lib/ipkg"
    echo "This will remove all existing optware packages."
    echo
    echo "You must *reboot* and then restart the bootstrap script."
    exit 1
fi

if [ ! -e `dirname $REAL_OPT_DIR` ]; then
    echo "Error: `dirname $REAL_OPT_DIR` does not exist"
    exit 2
fi

if ! grep Feroceon-KW /proc/cpuinfo >/dev/null 2>&1; then
    echo "Error: CPU not Marvell Kirkwood, probably wrong bootstrap.xsh"
    exit 3
fi

BSDIR="$REAL_OPT_DIR/ipkg-bootstrap"

echo "Creating temporary ipkg repository..."
rm -rf $BSDIR
mkdir -p $BSDIR
ln -s $BSDIR /tmp/ipkg
cat >>$BSDIR/ipkg.conf <<EOF
dest root /
lists_dir ext $BSDIR/ipkg
EOF

export IPKG_CONF_DIR=$BSDIR 
export IPKG_DIR_PREFIX=$BSDIR 

echo "Installing optware-bootstrap package..."
sh ./ipkg.sh install optware-bootstrap.ipk

echo "Installing ipkg..."
sh ./ipkg.sh install ipkg-opt.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg

echo "Installing wget..."
/opt/bin/ipkg install wget.ipk || exit 1

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/${OPTWARE_TARGET}/cross/stable" >/opt/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
