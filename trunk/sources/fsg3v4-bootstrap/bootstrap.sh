#!/bin/sh
BSDIR="/home/.optware/ipkg-bootstrap"

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

echo "Installing FSG-3 V4 bootstrap package..."
mkdir -p /usr/lib/ipkg/info/
ipkg install bootstrap.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg
rm -rf /usr/lib/ipkg

echo "Installing OpenSSL..."
ipkg install openssl.ipk || exit 1

echo "Installing wget..."
ipkg install wget-ssl.ipk || exit 1

[ ! -d /etc/ipkg ] && mkdir -p /etc/ipkg
if [ ! -e /etc/ipkg/cross-feed.conf ]
then
	echo "Removing /etc/ipkg.conf..."
	rm -f /etc/ipkg.conf
	echo "Creating /etc/ipkg/cross-feed.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/fsg3v4/cross/stable" \
		>/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
