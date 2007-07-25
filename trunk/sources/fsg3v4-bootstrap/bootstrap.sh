#!/bin/sh

if [ -e /home/.optware ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf /home/.optware"
    echo "  rm -rf /usr/lib/ipkg"
    echo
    echo "Then you must *reboot* and then restart the bootstrap script."
    exit 1
fi

echo "Installing FSG-3 V4 bootstrap package..."
ipkg install bootstrap.ipk

echo "Overwriting /etc/ipkg.conf..."
echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/fsg3v4/cross/stable" \
		>/etc/ipkg.conf

echo "Setup complete."
