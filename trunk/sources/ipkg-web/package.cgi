#!/bin/sh
#
# $Header$
#
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

echo Content-type: text/html
echo
echo '<html>'
if [ "${TASK}" = install ]
then
	echo '<pre>'
	ipkg install "${PACKAGE}" </dev/null
	echo '</pre>'
fi
if [ "${TASK}" = update ]
then
	echo '<pre>'
	ipkg update "${PACKAGE}" </dev/null
	echo '</pre>'
fi

ipkg list_installed >${TMPFILE}
trap "[ -f ${TMPFILE} ] && rm ${TMPFILE}" 0

echo '<table border=1>'
echo '<tr><th>task</th><th>Package</th><th>I-Ver</th><th>P-Ver</th><th>Comment</th></tr>'
ipkg list | while read line
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
		instline=${instline#* - }
		IVER=${instline%% - *}
		if [ "${IVER}" = "${VERSION}" ]
		then
			TASK='&nbsp;'
		else
			TASK="<a href='$PROG?task=update&package=${NAME}'>update</a>"
		fi
	else
		IVER='&nbsp;'
		TASK="<a href='$PROG?task=install&package=${NAME}'>install</a>"
	fi
	echo "<tr><td>${TASK}<td>${NAME}</td><td>${IVER}</td><td>${VERSION}</td><td>${COMMENT}</td></tr>"
done
echo '</table>'
echo '</html>'
