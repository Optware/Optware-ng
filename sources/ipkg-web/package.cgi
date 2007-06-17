#!/bin/sh
#
# $Id$
#

if [ "${BASH_CHECK}" != 1 -a -f /opt/bin/bash ]
then
	BASH_CHECK=1; export BASH_CHECK
	/opt/bin/bash $0
	exit $$
fi

PROG=${0##*/}
TMPFILE=/tmp/${PROG}.$$

#
# HTML Header
#
cat << EOF
Content-type: text/html

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 
<head>
<meta name="generator" content="CGI:shell" />
<meta name="version" content="\$Id$" />
<title>ipkg web</title>
<style type="text/css">
h1, h2 {
  font-family: Arial, Helvetica, sans-serif;
  color: #004;
}

table {
  border-top: 1px solid #eee;
  border-right: 1px solid #eee;
  width: 100%;
}

th, td {
  padding: 2px 4px;
  border-left: 1px solid #eee;
  border-bottom: 1px solid #eee;
}

table a {
  background: #ddd;
  color: #004;
  text-decoration: none;
  margin: 1px;
  padding: 2px 4px;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 75%;
}

table a.ins {
  background: #dfd;
  border-left: 1px solid #cec;
  border-bottom: 1px solid #cec;
}

table a.upd {
  background: #ddf;
  border-left: 1px solid #cce;
  border-bottom: 1px solid #cce;
}

table a.del {
  background: #fdd;
  border-left: 1px solid #ecc;
  border-bottom: 1px solid #ecc;
}
</style>
</head>

<body>
<h1>The ipkg web frontend</h1>
<form methode="GET">
<table>
<tr>
	<td>Sync packages</td>
	<td>
		<input type="radio" name="updatedb" value="n" checked>no</input>
		<input type="radio" name="updatedb" value="y">yes</input>
	</td>
</tr>
<tr>
	<td>Type:</td>
	<td>
		<select name="typefilter">
			<option selected value="none">NONE</option>
			<option value="update">Updates</option>
			<option value="installed">Installed</option>
			<option value="not">Not installed</option>
		</select>
	</td>
</tr>
<tr>
	<td>Filter</td>
	<td><input type="text" name="namefilter"></td>
</tr>
</table>
<input type="submit" name="submit">&nbsp;<input type="reset">
</form>
EOF

NAMEFILTER=.

# QUERY_STRING=task=install&package=atk
IFS='&'
set -- ${QUERY_STRING}
for i in $@
do
	case ${i%%=*} in
		task)
			TASK="${i#*=}"
			;;
		package)
			PACKAGE="${i#*=}"
			;;
		updatedb)
			UPDATEDB="${i#*=}"
			;;
		typefilter)
			TYPEFILTER="${i#*=}"
			;;
		namefilter)
			if [ "${i#*=}" ]
			then
				NAMEFILTER="${i#*=}"
			fi
			;;
		submit)
			SUBMIT="${i#*=}"
			;;
		*)
			echo "<b>ERROR</b>: Unkown option '${i}'"
			echo '</body>'
			echo '</html>'
			exit 1
			;;
	esac
done

if [ ! -f /opt/bin/bash ]
then
	echo "<h2>Please install bash</h2>"
	echo "<p>I recomend to install bash because this cgi script will"
	echo "run more than two times faster with bash</p>"
fi

if [ "${UPDATEDB}" = y ]
then
	echo "<h2>Upgrading package list</h2>"
	echo '<pre>'
	ipkg update </dev/null
	echo '</pre>'
fi

if [ "${TASK}" = install ]
then
	echo "<h2>Install ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg -force-defaults install "${PACKAGE}" </dev/null
	echo '</pre>'
fi

if [ "${TASK}" = update ]
then
	echo "<h2>Update ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg -force-defaults upgrade "${PACKAGE}" </dev/null
	echo '</pre>'
fi

if [ "${TASK}" = delete ]
then
	echo "<h2>Delete ${PACKAGE}</h2>"
	echo '<pre>'
	ipkg -force-defaults remove "${PACKAGE}" </dev/null
	echo '</pre>'
fi

if [ "${SUBMIT}" != ""  ]
then
	echo '<h2>Package list</h2>'
	ipkg list_installed >${TMPFILE}
	trap "[ -f ${TMPFILE} ] && rm ${TMPFILE}" 0

	echo '<table border="1" cellpadding="0" cellspacing="0">'
	echo '<tr><th>task</th><th>Package</th><th>I-Ver</th><th>P-Ver</th><th>Comment</th><th>Delete</th></tr>'
	ipkg list | grep -- "${NAMEFILTER}" | while read line
	do
		INSTALLED=""
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
			INSTALLED=Y
			DEL="<a href='$PROG?task=delete&amp;package=${NAME}' class='del'>delete</a>"
			instline=${instline#* - }
			IVER=${instline%% - *}
			if [ "${IVER}" = "${VERSION}" ]
			then
				TASK='&nbsp;'
			else
				TASK="<a href='$PROG?task=update&amp;package=${NAME}' class='upd'>update</a>"
			fi
		else
			DEL='&nbsp;'
			IVER='&nbsp;'
			TASK="<a href='$PROG?task=install&amp;package=${NAME}' class='ins'>install</a>"
		fi
		SHOW=0
		case "${TYPEFILTER}" in
			none)
				SHOW=1
				;;
			update)
				[ "${INSTALLED}" ] && [ "${IVER}" != "${VERSION}" ] && SHOW=1
				;;
			installed)
				[ "${INSTALLED}" ] && SHOW=1
				;;
			not)
				[ -z "${INSTALLED}" ] && SHOW=1
				;;
			*)
				echo "<b>ERROR</b>: Unkown typefilter '${TYPEFILTER}'"
				echo '</body>'
				echo '</html>'
				exit 1
				;;
		esac
		[ "${SHOW}" = 1 ] && echo "<tr><td>${TASK}</td><td>${NAME}</td><td>${IVER}</td><td>${VERSION}</td><td>${COMMENT}</td><td>${DEL}</td></tr>"
	done
	echo '</table>'
fi

echo '</body>'
echo '</html>'
