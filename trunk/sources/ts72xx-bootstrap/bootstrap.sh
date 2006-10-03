#!/bin/sh
BSDIR="/home/tmp/ipkg-bootstrap"

echo "Creating temporary ipkg repository..."
rm -rf $BSDIR
mkdir -p $BSDIR
ln -s $BSDIR /tmp/ipkg
cat >>$BSDIR/ipkg.conf <<EOF
dest root /
lists_dir ext /$BSDIR/ipkg
EOF

export IPKG_CONF_DIR=$BSDIR 
export IPKG_DIR_PREFIX=$BSDIR 

echo "Installing TS72XX bootstrap package..."
mkdir -p /usr/lib/ipkg/info/
sh ./ipkg.sh install bootstrap.ipk

echo "Installing IPKG package... (Ignore missing md5sum warning)"
sh ./ipkg.sh install ipkg.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg
rm -rf /usr/lib/ipkg

echo "Installing OpenSSL.."
/opt/bin/ipkg install openssl.ipk || exit 1

echo "Installing wget-SSL..."
/opt/bin/ipkg install wget-ssl.ipk || exit 1

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/ts72xx/cross/stable" >/opt/etc/ipkg/cross-feed.conf
fi

echo "Setup complete..."
