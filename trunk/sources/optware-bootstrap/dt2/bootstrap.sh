#!/bin/sh

if [ -e /home/.optware ] ; then
    echo "Backup your configuration settings, then type:"
    echo "  rm -rf /home/.optware"
    echo "  rm -rf /usr/lib/ipkg"
    echo "This will remove all existing optware packages."
    echo
    echo "Then you must *reboot* and then restart the bootstrap script."
    exit 1
fi

echo "Installing DataTank bootstrap package..."
ipkg install optware-bootstrap.ipk

echo "Installing diffutils..."
ipkg install diffutils.ipk

echo "Overwriting /etc/ipkg.conf..."
echo "src/gz cross http://ipkg.nslu2-linux.org/feeds/optware/dt2/cross/stable" \
		>/etc/ipkg.conf
echo "src/gz armel http://ipkg.nslu2-linux.org/feeds/optware/cs05q3armel/cross/stable" \
		>>/etc/ipkg.conf

echo "Setup complete."
