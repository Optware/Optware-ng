#!/bin/sh
BSDIR="/volume1/tmp/ipkg-bootstrap"

echo -n "Creating temporary ipkg repository..."
rm -rf $BSDIR
mkdir -p $BSDIR || exit 1
ln -s $BSDIR /tmp/ipkg
cat >>$BSDIR/ipkg.conf <<EOF
dest root /
lists_dir ext /$BSDIR/ipkg
EOF
echo " success"

export IPKG_CONF_DIR=$BSDIR 
export IPKG_DIR_PREFIX=$BSDIR 

echo -n "Installing DS101(g)-bootstrap package..."
mkdir -p /usr/lib/ipkg/info/
sh ./ipkg.sh install bootstrap.ipk || exit 1
echo " success"

echo "Installing IPKG package... (Ignore missing md5sum warning)"
sh ./ipkg.sh install ipkg-opt.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg
rm -rf /usr/lib/ipkg

echo -n "Installing wget..."
/opt/bin/ipkg install wget.ipk || exit 1
echo " success"

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	ARCH=`uname -m`
	if [ "$ARCH" = "ppc" ]; then
		echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/ds101g/cross/stable" >/opt/etc/ipkg/cross-feed.conf
	else
		echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/ds101/cross/stable" >/opt/etc/ipkg/cross-feed.conf
	fi
fi

echo "Setup complete..."
echo "If your network setup is correct, you should be able to do \"ipkg update\" to get the"
echo "full list of installable packages"
