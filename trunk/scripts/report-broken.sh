#!/bin/sh
# This script will  try to build all common cross packages one by one and 
# at the end will output broken packages in Makefile format
# Example batch usage: nohup sh scripts/report-broken.sh &
# or with artument: nohup sh scripts/report-broken.sh PACKAGES &
#
# After paste into platforms/packages-foo.mk one can reytry build
# with manual cleanup and retry after some fixes were performed for
# incremental rebuild of broken packages
# for f in $(make query-BROKEN_PACKAGES_REPORT);do make $f-dirclean;done
#

PKGS_VAR=$1
if test -z "$PKGS_VAR"; then
	PKGS_VAR=COMMON_CROSS_PACKAGES
fi

PACKAGES=`make query-${PKGS_VAR}`

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

echo -e "BROKEN_PACKAGES_REPORT = ${NL}\t${BROKEN}"
