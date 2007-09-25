#!/bin/sh

if [ -e /share/.optware ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf /share/.optware"
    echo "  rm -rf /usr/lib/ipkg"
    echo "This will remove all existing optware packages."
    echo
    echo "You must *reboot* and then restart the bootstrap script."
    exit 1
fi

BSDIR="/share/.optware/ipkg-bootstrap"

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
sh ./ipkg.sh install ipkg.ipk

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR
rm /tmp/ipkg

echo "Installing OpenSSL..."
/opt/bin/ipkg install openssl.ipk || exit 1

echo "Installing wget..."
/opt/bin/ipkg install wget-ssl.ipk || exit 1

[ ! -d /opt/etc/ipkg ] && mkdir -p /opt/etc/ipkg
if [ ! -e /opt/etc/ipkg/cross-feed.conf ]
then
	echo "Creating /opt/etc/ipkg/cross-feed.conf..."
	echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/mssii/cross/stable" >/opt/etc/ipkg/cross-feed.conf
fi

echo "Setup complete."
