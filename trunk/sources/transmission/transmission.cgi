#!/bin/sh
# httpd.conf for busybox_httpd -p 8008 -c /opt/etc/httpd.conf -h /opt/share/www
# A:*
# /cgi-bin:admin:admin
# For thttpd.conf add cgipat=/cgi-bin/* and user=admin
# replace standard "admin" on wl500gx with "root" for other systems
# /bin/sh can be BusyBox v1.1.3 applet

. /opt/etc/transmission.conf

PATH=/bin:/sbin:/usr/bin:/opt/sbin:/opt/bin:/usr/sbin
export PATH


#################################################
## The functions

# rewrites active torrents listing into file and notifies daemon to reload it
_update_active()
{
    if [ -n "`ls ${WORK}/*/*.torrent 2>/dev/null | head -n 1`" ] ; then
	ls -1  ${WORK}/*/*.torrent > ${ACTIVE}	
    else
    	rm -f ${ACTIVE}
    fi
    if [ -n "`ls ${TARGET}/*/*.seeding 2>/dev/null | head -n 1`" ] ; then
        ls -1  ${TARGET}/*/*.seeding >> ${ACTIVE}
    fi
    [ -f ${PIDFILE} ] && kill -HUP `cat ${PIDFILE}`
}

#writes .info file describing some torrent stats
_write_info()
{
    echo "STARTTIME=\"${STARTTIME}\"
ENDTIME=\"${ENDTIME}\"
STATUS=\"${STATUS}\"
SCRAPE=\"${SCRAPE}\"
UPLOADED=\"${UPLOADED}\"
URL=\"${URL}\"
NOTE=\"${NOTE}\"
TORRENTNAME=\"${TORRENTNAME}\"" > "${TORRENT%/*}/.info"
}

#creates clean info contents
_clean_info()
{
    STARTTIME=""
    ENDTIME=""
    STATUS=""
    SCRAPE=""
    TORRENTNAME=""
    UPLOADED=""
    URL=""
    NOTE=""
}

    
_update_progress()
{
    kill -USR1 `cat ${PIDFILE}`
    sleep 1
    for TORRENT in ${WORK}/*/*.torrent ${TARGET}/*/*.torrent.seeding ; do
       if [ -d "${TORRENT%/*}" ]; then
         INFO="${TORRENT%/*}/.info"  
         if [ -f "${INFO}" ]; then
	    . "${INFO}"
	   LOG="${TORRENT%/*}/.status"
	   if [ -f "${LOG}" ]; then
	       .  "${LOG}"
	   else
	       STATUS=".status not found for ${TORRENT}"
	   fi
         else
	   _clean_info
         fi
         _write_info
       fi
    done
    UPLOADED=
}

# Can only start torrents in WORK or TARGET
_start_torrent()
{
    TORRENT="$1"
    INFO="${TORRENT%/*}/.info"
    if [ -f "${INFO}" ] ; then
	TMP="${TORRENT}"
	 . "${INFO}" 
	 TORRENT="${TMP}"
    else
	_clean_info
    fi
    [ -z "${STARTTIME}" ] && STARTTIME=`date +"${DATE_FORMAT}"`
    STATUS="started"
    UPLOADED=
    _write_info
    _update_active
}

_stop_torrent ()
{
    TORRENT="$1"
    INFO="${TORRENT%/*}/.info"
    if [ -f  "${INFO}"  ] ; then
	. "${INFO}"
	[ -z "${ENDTIME}" ] && ENDTIME=`date +"${DATE_FORMAT}"`
	STATUS=`echo "${STATUS}"|sed -e 's/Progress: \([0-9\.]\{2,6\} %\).*/\1/p;d'`
	_write_info
	_update_active
    fi
}


# Move selected torrent to work dir and start it
_enqueue()
{
    TORRENTNAME="${TORRENT%.torrent}"
    TORRENTNAME="${TORRENTNAME##*/}"
    mkdir -p "$WORK/$TORRENTNAME"                                               
    chmod 777 "$WORK/$TORRENTNAME" 
    mv "${TORRENT}" "$WORK/$TORRENTNAME"
    TORRENT="$WORK/$TORRENTNAME/${TORRENTNAME}.torrent"       
    _write_info
    _start_torrent "${TORRENT}"
}

# Suspend active torrent
_suspend ()
{
    mv "${TORRENT}" "${TORRENT}.suspended"
    _stop_torrent "${TORRENT}"
}

# Resume suspended torrent
_resume ()
{
    
    mv "${TORRENT}" "${TORRENT%.suspended}"
    _start_torrent "${TORRENT%.suspended}"
}

# Seed/unSeed DONE torrents
_seed ()
{
   # Double check
   if [ ! -f "${TARGET}${TORRENT#${TARGET}}" ] ; then
	echo "<b>Can only seed already done torrents</b>"
	return
   fi
   
   if [ -f "${TORRENT%.seeding}" ]; then
	mv "${TORRENT}" "${TORRENT}.seeding"
	_start_torrent "${TORRENT}.seeding"
   else
	mv "${TORRENT}" "${TORRENT%.seeding}"
	_stop_torrent "${TORRENT%.seeding}"
   fi 
}

# Purge log files in target and cleanup removed
_purge ()
{
    LOG=`ls -1 $TARGET/*/.info 2>/dev/null | head -n 1`
    if [ -z "${LOG}" ] ; then
	echo "No .info to purge."
    else
      echo "<pre>"
      for f in $TARGET/*/.info ; do
	  DUMMY="${f%/.info}"
	  TORRENT="${DUMMY}/${DUMMY##*/}.torrent.seeding"
	  if [ -f "${TORRENT}" ]; then
		echo "<b>status $f not purged</b>"
	  else
          	echo "Puging ${DUMMY}"
		[ -f "${DUMMY}/.status" ] && rm "${DUMMY}/.status"
		. "${f}"
		STATUS=""
		_write_info
	  fi 
      done
      echo "</pre>"
    fi
    
    REMOVED=`ls -1 $WORK/*/*.torrent.removed 2>/dev/null | head -n 1`
    if [ -n "${REMOVED}" ]; then
        echo "<pre>"
	for f in $WORK/*/*.torrent.removed ; do
		DIR="${f%/*}"
		echo "Purging $DIR"
		rm -fr "${DIR}"			
	done
        echo "</pre>"
    fi
}

# Instruct watchdog to stop/start all active torrents
_pause ()
{
    if [ -f "$WORK/.paused" ] ; then
	rm "$WORK/.paused"
	echo "Starting transmission..."
	[ -e ${PIDFILE} ] && rm ${PIDFILE}
	export HOME
	_update_active
	if  false ; then
	transmissiond -p ${LISTENING_PORT} \
	    -w ${WATCHDOG} \
	    -u ${UPLOAD_SPEED} \
	    -d ${DOWNLOAD_SPEED} \
	    -i ${PIDFILE}   ${ACTIVE}
	sleep 5
	if [ -f ${PIDFILE} ]; then
	    PID=`cat ${PIDFILE}`
	    echo "<p>Transmission daemon started with PID=${PID}</p>"
	else
	    echo "<p><b>Transmission daemon failed to start</b></p>" 
	fi
	else
	    echo "<p>transmission_watchdog will start Trasmission daemon</p>"
	fi
    else
	touch "$WORK/.paused"
	kill -TERM `cat ${PIDFILE}`
	echo "<b>Stopping transmissison!</b>"
	echo "<p>Transmission will eventuallty stop. "
	echo " Depending of its current state. Be patient.<p>"
    fi
}

# Update scrape info for active and downloaded torrents
_scrape ()
{
  for TORRENT in ${WORK}/*/*.torrent ${TARGET}/*/*.torrent* ; do
    INFO="${TORRENT%/*}/.info"
    if [ -f "${INFO}" ]; then
	. "${INFO}"
	SCRAPE=`btlist -sq "${TORRENT}" | grep seeders`
	DUMMY=$?
	_write_info
	if [ $DUMMY != 0 ]; then
	   echo "<p>${TORRENT} scrape failed</p>"
	fi
	UPLOADED=
	echo "."
    fi  
  done
  echo " done."
}

# Search for best done torrent and suggest seeding based on ratio
_best_seed ()                     
{                                
   BEST=0              
    if [ -n "`ls ${TARGET}/*/*.torrent 2>/dev/null | head -n 1`" ] ; then
	for TORRENT in ${TARGET}/*/*.torrent ; do
	    INFO="${TORRENT%/*}/.info"
	    if [ -f "${INFO}" ]; then
		. "${INFO}"
		QUOTIENT=`echo "${SCRAPE}" | sed '/seeders: [1-9]\{1,\}/s/seeders:.\([0-9]\{1,\}\) leechers: \([0-9]\{1,\}\).*/(\2000\/\1/;t;d'` 
		RATIO=$((QUOTIENT))
		if [ ${RATIO} -gt ${BEST} ]; then
		    BESTTORRENT="${TORRENT}"
		    BESTSCRAPE="${SCRAPE}"
		    BEST=${RATIO}
		fi                                   
            fi       
	done 
	echo "<h3>Best seed suggestion</h3>"
	echo "<p>${BESTTORRENT##*/}</p>"
	echo "<p>${BESTSCRAPE}</p>"
   else                                                                
	echo "<b>No torrents to suggest for seeding</b>"
   fi                                       
}

# Fetch torrent from URL location given with FETCH
_fetch()
{
    TORRENT=$(echo "${FETCH}" | sed 's|%20| |g;s|%3A|:|g;s|%2F|/|g;s|%3F|?|g;s|%3D|=|g;s|%26|\&|g;s|%5B|\[|g;s|%5D|\]|g;s|%28|(|g;s|%29|)|g;s|%7B|{|g;s|%7D|}|g;s|%25|%|g')
#    echo "<p>Fetching ${TORRENT}</p>"
    wget --quiet -P ${SOURCE} "${TORRENT}"  ||  echo "<p>wget ${TORRENT} failed</p>"
}

# Sub for directory search
__find ()
{
    [ -n "${TORRENT}" ] && return
    
    FILEPAT="$1"
    if [ -n "`ls ${FILEPAT} 2>/dev/null | head -n 1`" ] ; then
	for i in $FILEPAT ; do
	    if [ $ID = $idx ]; then
		TORRENT="$i"
#		echo "Found $idx ${TORRENT}"
		return
	    fi
	    idx=$(($idx+1)) 
	done
    fi
}


# Search for torrent ID through directories.  Must be in sync with _list()
# When found TORRENT is set. Should always find!
_find ()
{
    idx=0 
    TORRENT=""
    __find "$WORK/*/*.torrent"
    __find "$TARGET/*/*.torrent.seeding"
    __find "$WORK/*/*.torrent.suspended"
    __find "$WORK/*/*.torrent.removed"
    __find "$SOURCE/*.torrent"
    __find "$TARGET/*/*.torrent" 
   [ -z "${TORRENT}" ] && echo "Assertion failed [ -z TORRENT ] in _find()" 
}

__list ()
{
    FILEPAT="$1"
    DESC="$2"
    
    if [ -n "`ls ${FILEPAT} 2>/dev/null | head -n 1`" ]
    then
	echo "<table>"
	echo "<thead><tr><td></td><td>${DESC}</td><td>status</td></tr>"
	echo "</thead><tbody>"
	for i in $FILEPAT
	do
	    DUMMY="${i%.torrent*}"
	    P="${i%/*}"
	    DUMMY=${DUMMY##*/}
	    echo "<tr><td><input name=ID value=$idx type=radio></td>"
	    if [ -f "${P}/.info" ];then
	       . "${P}/.info" 
	    else
	       _clean_info
	    fi
	    TORRENT="$i"
	    if [ -n "${SETURL}" -a "${idx}" = "${ID}" ]; then
	       URL=`echo "${SETURL}" | sed -e 's|%3A|:|g;s|%2F|/|g;s|%3F|?|g;s|%3D|=|g;s|%23|#|g;s|%26|\&|g'`
	       _write_info
	    fi
	    if [ -n "${URL}" ]; then
	       echo "<td><a href=\"${URL}\" target=_blank>${DUMMY}</a></td>"
	    else
	       echo "<td>${DUMMY}</td>"
	    fi
	    if [ -f "$P/.info" ] ; then
		echo "<td>${STATUS}"
		echo " Start: ${STARTTIME}"
		[ -n "${ENDTIME}" ] && echo " End: ${ENDTIME}"
		[ -n "${SCRAPE}" ] && echo " ${SCRAPE}"
		if [ -n "${SETNOTE}" -a "${idx}" = "${ID}" ]; then
		   NOTE=`echo "${SETNOTE}" | sed -e 's|+| |g;s|%3F|?|g'`
		   _write_info
		fi
		[ -n "${UPLOADED}" ] && echo " uploaded: ${UPLOADED} MB" 
		[ -n "${NOTE}" ] && echo " ${NOTE}"
		echo "</td></tr>"
	    fi
	    STARTTIME=
	    ENDTIME=
	    SCRAPE=
	    STATUS=
	    URL=
	    UPLOADED=
	    NOTE=
	    idx=`expr $idx + 1`
	done
	echo "</tbody></table>"
    echo
    fi
}

_list ()
{
    idx=0
    if [ -f "$WORK/.paused" ] ; then
	echo "<h3>Torrent processing paused!</h3>"
    fi
    __list "$WORK/*/*.torrent" "Active"
    __list "$TARGET/*/*.torrent.seeding" "Seeding"
    SPEED=`tail ${SYSLOG}  | sed  -n '/transmissiond/s/.*\dl \([0-9.]\{1,\}\) ul \([0-9.]\{1,\}\).*/DOWNLOAD="\1";UPLOAD="\2"/p' | tail -1`
    eval "${SPEED}"
    if [ -n "${DOWNLOAD}"  ] ; then
	echo "<table><tr><td>Total</td><td>Download ${DOWNLOAD}kB/s</td>"
	echo "<td>Upload ${UPLOAD} kB/s</td></tr></table>"
    fi
    [ "${ACTION}" = "Update" ] && return
    __list "$WORK/*/*.torrent.suspended" "Suspended" 
    __list "$WORK/*/*.torrent.removed" "Removed" 
    __list "$SOURCE/*.torrent" "Queued"
    __list "$TARGET/*/*.torrent" "Done" 
    
}

_root_check () {
	if  [ ${USER} != admin -a  ${USER} != root ]; then
	    echo "You must be root! Because of killing stuff"
	    return 1
	fi
	return 0
}

# Mark torrent as removed. Purge will do cleanup
_remove ()
{
    if [ -z "$ID" ] ; then
	echo "<b>Please select torrent first!</b>"
	return
    fi
   
    _find
   
   if [ -f "${TORRENT%.torrent.suspended}.torrent.suspended" ]; then
	mv "${TORRENT}" "${TORRENT%.suspended}.removed"
   else
	echo "<b>Can only remove suspended torrents!</b>"
   fi
}

# Determine what to do? _resume|_suspend|_seed
_push()
{
    if [ -z "$ID" ] ; then
	echo "<b>Please select torrent first!</b>"
	return
    fi
    _find
    
    if [ -f "${TORRENT%.suspended}.suspended" ]; then
       _resume
       return
    fi
   
    if [ -f "${WORK}${TORRENT#${WORK}}" ]; then
       if [ -f "${TORRENT%.torrent}.torrent" ]; then
	    _suspend
   	    return
       fi
       # Removed ? Not pushed
    fi
    
    if [ -f "${TARGET}${TORRENT#${TARGET}}" ]; then
       _seed
       return
    fi 
    
    if [ -f "${SOURCE}${TORRENT#${SOURCE}}" ]; then
       _enqueue
       return
    fi
    
    echo "<p><em>Nothing to push!</em></p>" 
}

# Show transfer log from log file
_log ()
{

if [ ! -x ${GNUPLOT} ]; then
  echo "<p>gnuplot: ${GNUPLOT} not found. Properly configure paths"
  echo "in transmission.conf for transfer graphing!</p>"
  return
fi

cat > ${GNUPLOT_COMMAND} << __EOF__
set terminal png small size 800,320
set output '${GNUPLOT_OUTPUT}'
set xdata time
set timefmt "%s"
set format x "%H:%M\n%m/%d"
set ytics nomirror
set y2tics nomirror
set y2range [0:]
set ylabel "Transmission transfer rate (kB/s)"
set y2label "System load (5 min average)"
set y2tics 1
plot '${GNUPLOT_DATA}' using 1:2 title 'download' axis x1y1 with impulses, \
     '${GNUPLOT_DATA}' using 1:3 title 'upload' with impulses, \
     '${GNUPLOT_DATA}' using 1:4 axis x1y2 title 'load' with lines
quit 
__EOF__

sed  -n '/transmissiond/s/.*: \([0-9]\{1,10\}\) [0-9]\{1,\} dl \([0-9.]\{1,\}\) ul \([0-9.]\{1,\}\) ld \([0-9.]\{1,\}\)/\1 \2 -\3 \4/p' < ${SYSLOG} > ${GNUPLOT_DATA}

${GNUPLOT} ${GNUPLOT_COMMAND}

echo "<br><img src=\"${HTTP_IMG_LOCATION}\">"

}

_info ()
{
    if [ -z "$ID" ] ; then
	echo "<b>Please select torrent first!</b>"
	return
    fi
    _find
    echo "<h3>Torrent file metainfo</h3>"
    echo "<pre>"
    btlist -s "${TORRENT}"
    echo "</pre>"
}

_help ()
{
    cat << __EOF__
This is quick explanation of the buttons:
<dl>
<dt><u>U</u>pdate<dd>updates active torrents status
<dt>Log<dd>shows <u>c</u>urrent transfer log graph
<dt>Pau<u>s</u>e<dd>all active torrent processing should stop/resume imediately
<dt><u>P</u>ush<dd> Push selected torrent to other queue
<dt><u>L</u>ist<dd>lists queued, active, suspended and completed torrents
<dt><u>R</u>emove<dd>mark torrent for purging
<dt>Pur<u>g</u>e<dd>removes all logs from completed torrents and clean removed torrents
<dt><u>W</u>atchdog<dd>forces transmission_watchdog processing
<dt><u>I</u>nfo<dd>shows selected torrent info ((file content and size)
<dt>Scr<u>a</u>pe<dd>Update scrape info (seeders, leechers, downloaded)
     from tracker for downloaded torrents
<dt><u>B</u>est<dd>Search scrape for best done torrent and suggest seeding based on (leecees/seeds) ratio
<dt>U<u>R</u>L<dd>Enter URL location for torrent
<dt><u>N</u>ote<dd>Append your notes to torrent status
<dt><u>F</u>etch<dd>Fetch torrent file from URL (link location)
<dt><u>H</u>elp<dd> Access keys <u>underlined</u>! Use Alt-Key for access.
</dl>
__EOF__
if [ -r /opt/share/doc/transmission/README.daemon ]; then 
	echo "<pre>" 
	cat /opt/share/doc/transmission/README.daemon
	echo "</pre>" 
fi                                         
_root_check
}

#############################################
# MAIN PROCESS
cat << __EOF__                                 
Content-type: text/html

<html>
<head>
  <title>Transmission</title>
  <style type="text/css">
  <!--
      BODY { background-color: #F8F4E7; color: #552800 }
      A:link { color: #0000A0 }
      A:visited { color: #A000A0 }
      THEAD {
        background: #D0D0D0;
        color: #000000;
        text-align: center;
      }
      TBODY {
        background: #D0D0E7;
      }
   //-->
  </style>
</head>
<body>
<form action=transmission.cgi method=get>
<input type=submit accesskey=u name=ACTION value=Update>
<input type=submit accesskey=c name=ACTION value=Log>
<input type=submit accesskey=s name=ACTION value=Pause>
<input type=submit accesskey=p name=ACTION value=Push>
<input type=submit accesskey=l name=ACTION value=List>
<input type=submit accesskey=r name=ACTION value=Remove>
<input type=submit accesskey=g name=ACTION value=Purge>
<input type=submit accesskey=w name=ACTION value=Watchdog>
<input type=submit accesskey=i name=ACTION value=Info>
<input type=submit accesskey=a name=ACTION value=Scrape>
<input type=submit accesskey=b name=ACTION value=Best>
<input type=submit accesskey=r name=SETURL value=URL 
 onClick='value=prompt("Enter URL location to torrent page", "http://")'>
<input type=submit accesskey=n name=SETNOTE value=Note
 onClick='value=prompt("Enter your notes for this torrent")'>
<input type=submit accesskey=f name=FETCH value=Fetch
onClick='value=prompt("Enter torrent link location for fetching")'>
<input type=submit accesskey=h name=ACTION value=Help>
<! img align=top alt="" src=pingvin.gif>
<br>


__EOF__

QUERY_STRING=`echo "$QUERY_STRING" | sed 's/&/;/g'`
eval ${QUERY_STRING}
#export ACTION
#/opt/bin/printenv
#set

[ -n "${FETCH}" ] && _fetch

case "${ACTION}" in
    Update) _update_progress ; _list ;;
    Log) _log ;;
    Push)	_push ; _list ;;
    Pause) _pause ; _list ;;
    Remove) _remove; _list ;;
    Purge) _purge ;;
    Watchdog) transmission_watchdog ;;
    Info) _info ;;
    Help) _help ;;
    Scrape) _scrape ; _list;;
    Best) _best_seed ; _list;;
    *) _list ;;
esac


echo "<p>" ; uptime ; echo "</p>" 

cat << __EOF__  
</form>



<h3>Links</h3>
<ul>
  <li><a href=../torrent/source>source</a></li>
  <li><a href=../torrent/work>work</a></li>
  <li><a href=../torrent/target>target</a></li>
</ul>
<hr>
<address>
&copy; 2005, 2006 oleo
</address>
</body>
</html>
__EOF__
