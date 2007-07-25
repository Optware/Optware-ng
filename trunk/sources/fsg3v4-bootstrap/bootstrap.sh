#!/bin/sh

echo "Installing FSG-3 V4 bootstrap package..."
ipkg install bootstrap.ipk

echo "Overwriting /etc/ipkg.conf..."
echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/fsg3v4/cross/stable" \
		>/etc/ipkg.conf

echo "Setup complete."
