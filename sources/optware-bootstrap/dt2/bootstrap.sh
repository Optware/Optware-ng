#!/bin/sh

# Replaced during packaging based on value in target-specific.mk
REAL_OPT_DIR=/home/.optware

if [ -e "$REAL_OPT_DIR" ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf $REAL_OPT_DIR"
    echo "This will remove all existing optware packages."
    echo
    echo "You must *reboot* and then restart the bootstrap script."
    exit 1
fi

echo "Removing broken vendor ipkg..."
rm -f /bin/ipkg /usr/bin/update-alternatives /etc/ipkg.conf*
rm -rf /usr/lib/ipkg

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
tar -xOzf optware-bootstrap.ipk ./control.tar.gz | tar -xOzf - ./preinst | sh
tar -xOzf optware-bootstrap.ipk ./data.tar.gz | tar -C / -xzf -
tar -xOzf optware-bootstrap.ipk ./control.tar.gz | tar -xOzf - ./postinst | sh

echo "Installing ipkg..."
tar -xOzf ipkg-opt.ipk ./data.tar.gz | tar -C / -xzf -

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg

echo "Installing wget..."
/opt/bin/ipkg install wget.ipk

echo "Installing coreutils..."
/opt/bin/ipkg install coreutils.ipk

echo "Installing diffutils..."
/opt/bin/ipkg install diffutils.ipk

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	echo "src/gz ${OPTWARE_TARGET} http://ipkg.nslu2-linux.org/feeds/optware/${OPTWARE_TARGET}/cross/stable" >/opt/etc/ipkg/cross-feed.conf
	echo "src/gz cs05q3armel http://ipkg.nslu2-linux.org/feeds/optware/cs05q3armel/cross/stable">>/opt/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
