#!/bin/sh
BSDIR="/tmp/ipkg-bootstrap"

echo "Creating temporary ipkg repository..."
rm -rf $BSDIR
mkdir -p $BSDIR
cat >>$BSDIR/ipkg.conf <<EOF
dest root /
lists_dir ext /$BSDIR/ipkg
EOF

export IPKG_CONF_DIR=$BSDIR 
export IPKG_DIR_PREFIX=$BSDIR 

echo "Installing DS101(g)-bootstrap package..."
sh ./ipkg.sh install ds101-bootstrap_0.1-1_*.ipk || exit 1

echo "Installing IPKG package..."
sh ./ipkg.sh install ipkg_0.99-148-1_*.ipk || exit 1

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR

echo "Instaling OpenSSL.."
/opt/bin/ipkg install openssl_0.9.7d-4_*.ipk || exit 1

echo "Instaling wget-SSL..."
/opt/bin/ipkg install wget-ssl_1.10-1_*.ipk || exit 1

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

echo "OK, now call . /etc/profile"
