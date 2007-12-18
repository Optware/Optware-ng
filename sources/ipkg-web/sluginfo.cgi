#!/bin/sh
#
# $Header$
#
if [ "${BASH_CHECK}" != 1 -a -f /opt/bin/bash ]
then
	BASH_CHECK=1; export BASH_CHECK
	/opt/bin/bash $0
	exit $$
fi

showcommand() {
	NAME=$1
	shift
	PROG=$1
	shift
	if [ -f ${PROG} ]
	then
		echo "<h3>${NAME}</h3>"
		echo "<pre>"
		${PROG} "$@"
		echo "</pre>"
	fi
}

showfile() {
	FILE=$1;
	BASE=${FILE##*/}
	shift
	if [ -f "${FILE}" ]
	then
		showcommand "${BASE}" "/bin/cat" "${FILE}"
	fi
}

runprog() {
	PROG=$1;
	BASE=${PROG##*/}
	shift
	showcommand "${BASE}" "${PROG}" "$@"
}

cd /tmp
cat << EOF
Content-type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="generator" content="sh" />
  <meta name="version" content="\$Id$" />
  <title>sluginfo</title>
</head>
<body>
<h1>Slug info</h1>
<ol>
<li><a href="#sys">System</a></li>
<li><a href="#soft">Installed software</a></li>
<li><a href="#disk">Disks</a></li>
<li><a href="#network">Network</a></li>
<li><a href="#samba">samba</a></li>
</ol>
EOF
echo '<a id="sys" /><h2>System</h2>'
showfile /etc/motd 
runprog /opt/bin/uname -a
showfile /proc/cpuinfo
showfile /proc/meminfo
showfile /proc/bus/usb/devices
runprog /sbin/lsmod
runprog /bin/ps
runprog /bin/dmesg
echo '<a id="soft" /><h2>Installed software</h2>'
runprog /usr/bin/ipkg list_installed
echo '<a id="disk" /><h2>Disks</h2>'
showfile /proc/mounts
runprog /bin/df
showcommand "sda" /sbin/fdisk -l /dev/sda
showcommand "sdb" /sbin/fdisk -l /dev/sdb
showcommand "sdc" /sbin/fdisk -l /dev/sdc
showcommand "sdd" /sbin/fdisk -l /dev/sdd
echo '<a id="network" /><h2>Network</h2>'
runprog /sbin/ifconfig
runprog /sbin/route
showfile /etc/resolv.conf
runprog /opt/bin/host ipkg.nslu2-linux.org
runprog /bin/ping -c 2 ipkg.nslu2-linux.org
runprog /usr/bin/wget http://ipkg.nslu2-linux.org
echo '<a id="samba" /><h2>Samba</h2>'
showfile /etc/samba/smb.conf
showfile /etc/samba/user_smb.conf
showfile /var/log/samba/log.smbd
showfile /var/log/samba/log.nmbd
echo '</body>'
echo '</html>'
