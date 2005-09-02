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
sh ./ipkg.sh install ds101*-bootstrap_0.1-1_*.ipk || exit 1

echo "Installing IPKG package..."
sh ./ipkg.sh install ipkg_0.99-148-1_*.ipk || exit 1

echo "Removing temporary ipkg repository..."
rm -rf $BSDIR

echo "OK, now call . /etc/profile"
