#!/bin/sh

BSDIR="/opt/ipkg-bootstrap"

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

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/optware.conf ]
then
	echo "Creating /opt/etc/ipkg/optware.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/i686g25/cross/unstable" >/opt/etc/ipkg/optware.conf
	echo "# src/gz native http://ipkg.nslu2-linux.org/feeds/optware/i686g25/native/unstable" >>/opt/etc/ipkg/optware.conf
	echo "src/gz kernel http://ipkg.nslu2-linux.org/feeds/optware/pre-emulator/cross/unstable" >>/opt/etc/ipkg/optware.conf
fi

echo "Setup complete."
