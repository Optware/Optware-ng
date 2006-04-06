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

PROG=${0##*/}
TMPFILE=/tmp/${PROG}.$$


# QUERY_STRING=task=install&package=atk
if [ "${QUERY_STRING}" != "" ]
then
	TASK_PART=${QUERY_STRING%%&*}
	TASK_PART1=${QUERY_STRING%&*}
	PACKAGE_PART=${QUERY_STRING##*&}
	PACKAGE_PART1=${QUERY_STRING#*&}
	if [ "${TASK_PART}" != "${TASK_PART1}" ]
	then
		exit 1
	fi
	if [ "${PACKAGE_PART}" != "${PACKAGE_PART1}" ]
	then
		exit 2
	fi
	if [ "${TASK_PART%=*}" = task ]
	then
		TASK="${TASK_PART#*=}"
		PACKAGE="${PACKAGE_PART#*=}"
	else
		exit 4
	fi
else
	TASK="";
fi

cat << EOF
Content-type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html xmlns="http://www.w3.org/1999/xhtml">
 
<html>
<head>
  <meta name="generator" content="BusyBox v0.60.4" />
  <meta name="version" content="\$Id$" />
  <title>ipkg web</title>
</head>
<body>
<h1>The ipkg web frontend</h1>
EOF
if [ "${TASK}" = install ]
then
	echo "<h2>Install ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg install "${PACKAGE}" </dev/null
	echo '</pre>'
fi
if [ "${TASK}" = update ]
then
	echo "<h2>Update ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg upgrade "${PACKAGE}" </dev/null
	echo '</pre>'
fi
if [ "${TASK}" = delete ]
then
	echo "<h2>Delete ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg remove "${PACKAGE}" </dev/null
	echo '</pre>'
fi
if [ "${TASK}" = updatedb ]
then
	echo "<h2>Upgrading package list</h2>"
	echo '<pre>'
	ipkg update </dev/null
	echo '</pre>'
else
	cat <<EOF2
		<h2>Upgrade package list?</h2>
		<p><a href="$PROG?task=updatedb">Sync</a> package list with the repositories.</p>
EOF2
fi

if [ ! -f /opt/bin/bash ]
then
	echo "<h2>Please install bash</h2>"
	echo "<p>I recomend to install bash because this cgi script will"
	echo "run more than two times faster with bash</p>"
fi

echo '<h2>Package list</h2>'
ipkg list_installed >${TMPFILE}
trap "[ -f ${TMPFILE} ] && rm ${TMPFILE}" 0

echo '<table border=1>'
echo '<tr><th>task</th><th>Package</th><th>I-Ver</th><th>P-Ver</th><th>Comment</th><th>Delete</th></tr>'
# ipkg list | while read line
cat /tmp/list | while read line
do
	NAME=${line%% - *}
	line=${line#* - }
	VERSION=${line%% - *}
	VERSION=${VERSION% -}
	COMMENT=${line#* - }
	if [ "$COMMENT" = "$line" ]
	then
		COMMENT='&nbsp;'
	fi
	instline=$(grep "^${NAME} - " ${TMPFILE})
	if [ "${instline}" != "" ]
	then
		DEL="<a href=\"$PROG?task=delete&package=${NAME}\">delete</a>"
		instline=${instline#* - }
		IVER=${instline%% - *}
		if [ "${IVER}" = "${VERSION}" ]
		then
			TASK='&nbsp;'
		else
			TASK="<a href=\"$PROG?task=update&package=${NAME}\">update</a>"
		fi
	else
		DEL='&nbsp;'
		IVER='&nbsp;'
		TASK="<a href=\"$PROG?task=install&package=${NAME}\">install</a>"
	fi
	echo "<tr><td>${TASK}<td>${NAME}</td><td>${IVER}</td><td>${VERSION}</td><td>${COMMENT}</td><td>${DEL}</td></tr>"
done
echo '</table>'
echo '</body>'
echo '</html>'
