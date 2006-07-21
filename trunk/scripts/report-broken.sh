#!/bin/sh
# This script will  try to build all common cross packages one by one and 
# at the end will output broken packages in Makefile format
# Example batch usage: nohup sh scripts/report-broken.sh &

PACKAGES=`make query-COMMON_CROSS_PACKAGES`

i=0
NL="\\\\\\n"

for package in ${PACKAGES} ; do
	echo "####### >>>  Building ${package}"
	make ${package}-ipk
	status=$?
	if [ ${status} != 0 ]; then
		echo "%%%%%%% ${package} Error ${status}"
		BROKEN="${BROKEN} ${package}"
		i=$((${i}+1))
		if [ ${i} = 7 ]; then
			BROKEN="${BROKEN} ${NL}\t"
			i=0
		fi
	fi
done

echo -e "BROKEN_PACKAGES = ${NL}\t${BROKEN}"
