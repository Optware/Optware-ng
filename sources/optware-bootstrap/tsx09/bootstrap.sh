#!/bin/sh

# Replaced during packaging based on value in target-specific.mk
REAL_OPT_DIR=/share/MD0_DATA/.@optware

if [ -e "$REAL_OPT_DIR" ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf $REAL_OPT_DIR"
    echo "This will remove all existing optware packages."
    echo
    echo "You must *reboot* and then restart the bootstrap script."
    exit 1
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
# Do it manually, so we don't get a complaint about md5sum missing
tar -xOzf ipkg-opt.ipk ./data.tar.gz | tar -C / -xzf -

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg

if [ ! -e /usr/bin/md5sum ] ; then
    echo "Installing /usr/bin/md5sum symlink for ipkg..."
    ln -s %OPTWARE_TARGET_PREFIX%/bin/coreutils-md5sum /usr/bin/md5sum
fi

echo "Manually installing wget..."
tar -xOzf wget.ipk ./data.tar.gz | tar -C / -xzf -

echo "Installing coreutils..."
%OPTWARE_TARGET_PREFIX%/bin/ipkg install coreutils.ipk

echo "Installing diffutils..."
%OPTWARE_TARGET_PREFIX%/bin/ipkg install diffutils.ipk

echo "Re-installing wget properly..."
%OPTWARE_TARGET_PREFIX%/bin/ipkg install -force-overwrite wget.ipk

[ ! -d %OPTWARE_TARGET_PREFIX%/etc/ipkg ] && mkdir -p %OPTWARE_TARGET_PREFIX%/etc/ipkg
if [ ! -e %OPTWARE_TARGET_PREFIX%/etc/ipkg/cross-feed.conf ]
then
	echo "Creating %OPTWARE_TARGET_PREFIX%/etc/ipkg/cross-feed.conf..."
	echo "src/gz ${OPTWARE_TARGET} http://ipkg.nslu2-linux.org/feeds/optware/${OPTWARE_TARGET}/cross/stable" >%OPTWARE_TARGET_PREFIX%/etc/ipkg/cross-feed.conf
	echo "src/gz cs05q3armel http://ipkg.nslu2-linux.org/feeds/optware/cs05q3armel/cross/stable">>%OPTWARE_TARGET_PREFIX%/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
