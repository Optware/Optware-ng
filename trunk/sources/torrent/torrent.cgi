#!/bin/sh
# httpd.conf for busybox_httpd -p 8008 -c /opt/etc/httpd.conf -h /opt/share/www
# A:*
# /cgi-bin:admin:admin
# For thttpd.conf add cgipat=/cgi-bin/* and user=admin
# replace standard "admin" on wl500gx with "root" for other systems

. /opt/etc/torrent.conf

PATH=/bin:/sbin:/usr/bin:/opt/sbin:/opt/bin
export PATH


#################################################
## Debug

debug ()
{
    if [[ $DEBUG && $DEBUG -gt 0 ]]; then
	echo $*
    fi
}

#################################################
## The functions
_write_info()
{
    echo "STARTTIME=\"${STARTTIME}\"
ENDTIME=\"${ENDTIME}\"
TRIES=${TRIES:-0}
PROGRESS=\"${PROGRESS}\"
PID=${PID}
SCRAPE=\"${SCRAPE}\"
TORRENTNAME=\"${TORRENTNAME}\"" > "${TORRENT%/*}/.info"
}
    
_update_progress()
{
    for TORRENT in ${WORK}/*/*.torrent ${TARGET}/*/*.torrent.seeding ; do
	INFO="${TORRENT%/*}/.info"  
	if [ -f "${INFO}" ]; then
	    . "${INFO}"
	    LOG="${TORRENT%/*}/current.log"
	    PROGRESS=`tail -30 "${LOG}"|tr '\r' '\n'|grep "Download"|tail -1`  
	    _write_info
	fi
    done
}

# Can only start torrents in WORK or TARGET
_start_torrent()
{
    TORRENT="$1"
    if [ -f "${TORRENT%.seeding}.seeding" ]; then
	SEED="-s"
    else
	SEED=""
    fi

    DIRNAME="${TORRENT%/*}"
    cd "${DIRNAME}"    
#    echo "Starting torrent in ${DIRNAME}"
    [ -f ./.info ] && TMP="${TORRENT}" && . ./.info && TORRENT="${TMP}"
    nice nohup btget ${SEED} -t ${LOG_TIME} "${TORRENT}" 2>> current_error.log >> current.log &
    sleep 2 # Throttle for torrent to settle
    PID=$!
    [ -z "${STARTTIME}" ] && STARTTIME=`date +"${DATE_FORMAT}"`
    PROGRESS=""
    _write_info 

}

_stop_torrent ()
{
    TORRENT="$1"
    DIRNAME="${TORRENT%/*}"
    cd "${DIRNAME}"
    if [ -f ./.info ] ; then
	. ./.info
	kill -TERM ${PID} 
	[ -z "${ENDTIME}" ] && ENDTIME=`date +"${DATE_FORMAT}"`
	PID=""
	PROGRESS=`echo "${PROGRESS}" | cut -f 1 -d " "`
	_write_info
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
    _start_torrent "${TORRENT}"
}

# Suspend active torrent
_suspend ()
{
    _stop_torrent "${TORRENT}"
    mv "${TORRENT}" "${TORRENT}.suspended"
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
    LOG=`ls -1 $TARGET/*/*.log 2>/dev/null | head -n 1`
    if [ -z "${LOG}" ] ; then
	echo "No LOG to purge."
    else
      echo "<pre>"
      for f in $TARGET/*/*.log ; do
	  DUMMY="${f%/*.log}"
	  TORRENT="${DUMMY}/${DUMMY##*/}.torrent.seeding"
	  if [ -f "${TORRENT}" ]; then
		echo "<b>$f not purged</b>"
	  else
          	echo "Purging $f"
		rm "$f"
	  fi 
      done
      echo "</pre>"
    fi
    
    REMOVED=`ls -1 $WORK/*/*.torrent.removed 2>/dev/null | head -n 1`
    if [ -n "${REMOVED}" ]; then
        echo "<pre>"
	for f in $WORK/*/*.torrent.removed ; do
		DIR=`dirname "$f"`
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
	echo "<b>Watchdog will resume torrents!</b>"
    else
	touch "$WORK/.paused"
    	for TORRENT in ${WORK}/*/*.torrent ${TARGET}/*/*.torrent.seeding ; do
	    INFO="${TORRENT%/*}/.info"
	    if [ -f "${INFO}" ]; then
		. "${INFO}"
		kill -TERM ${PID}
		PROGRESS="paused ${PROGRESS}"
		PID=
		_write_info
	    fi
	done
	echo "<b>All torrents killed!</b>"
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
	_write_info
    fi  
  done
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
	    echo "<tr><td><input name=ID value=$idx type=radio></td><td>$DUMMY</td>"
	    if [ -f "$P/.info" ] ; then
		. "$P/.info"
		echo "<td>${PROGRESS}"
		[ -n "${PID}" ]  && echo " PID:${PID} "
		echo " Start: ${STARTTIME}"
		[ -n "${ENDTIME}" ] && echo " End: ${ENDTIME}"
		[ "${TRIES}" -gt 0 ] && echo " Tries: ${TRIES}"
		[ -n "${SCRAPE}" ] && echo " ${SCRAPE}"
		echo "</td></tr>"
DL=`echo "${PROGRESS}" | sed 's/.*Download \([0-9]\{1,\}\)kbs.*/\1/;t;s/.*/0/'`
UL=`echo "${PROGRESS}" | sed 's/.*Upload \([0-9]\{1,\}\)kbs.*/\1/;t;s/.*/0/'`
		download=$((${download}+${DL}))
		upload=$((${upload}+${UL}))
		STARTTIME=""
		ENDTIME=""
		TRIES=0
		SCRAPE=""
		PROGRESS=""
	    fi
	    idx=`expr $idx + 1`
	done
	echo "</tbody></table>"
    echo
    fi
}

_list ()
{
    idx=0
    download=0
    upload=0
    if [ -f "$WORK/.paused" ] ; then
	echo "<h3>Torrent processing paused!</h3>"
    fi
    __list "$WORK/*/*.torrent" "Active"
    __list "$TARGET/*/*.torrent.seeding" "Seeding"
    echo "<table><tr><td>Total</td><td>Download ${download}kbs</td>"
    echo "<td>Upload ${upload}kbs</td></tr></table>"
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

# Show tail of the selected torrent log
_log ()
{
    if [ -z "$ID" ] ; then
	echo "<b>Please select torrent first!</b>"
	return
    fi
    _find
    DIR="${TORRENT%/*}"
    NAME="${TORRENT##*/}"
    echo "<h3>${NAME}</h3><pre>"
    tail -10 "${DIR}/current.log"
    echo "</pre>"
    SECONDS=`tail -10 "${DIR}/current.log" | tr '\r' '\n' | grep Time | tail -1 | cut -d " " -f 2`
    if [ -n "${SECONDS}" -a -x /opt/bin/date ]; then
      DATE=`/opt/bin/date -d "1970-01-01 UTC ${SECONDS} seconds" +"${DATE_FORMAT}"`
      echo "<p>Last timestamp seen at ${DATE}</p>"
    fi
}

_info ()
{
    if [ -z "$ID" ] ; then
	echo "<b>Please select torrent first!</b>"
	return
    fi
    _find
    echo "<h3>Status</h3>"
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
<dt>Log<dd>shows <u>c</u>urrent.log of active torrent
<dt>Pau<u>s</u>e<dd>all active torrent processing should stop/resume imediately
<dt><u>P</u>ush<dd> Push selected torrent to other queue
<dt><u>L</u>ist<dd>lists queued, active, suspended and completed torrents
<dt><u>R</u>emove<dt>mark torrent for purging
<dt>Pur<u>g</u>e<dd>removes all logs from completed torrents and clean removed torrents
<dt><u>W</u>atchdog<dd>forces torrent_watchdog processing
<dt><u>I</u>nfo<dd>shows selected torrent info ((file content and size)
<dt>Scr<u>a</u>pe<dd>Update scrape info (seeders, leechers, downloaded)
     from tracker for downloaded torrents
<dt><u>B</u>est<dd>Search scrape for best done torrent and suggest seeding based on (leecees/seeds) ratio 
<dt><u>H</u>elp<dd> Access keys <u>underlined</u>!
</dl>
__EOF__
_root_check
}

#############################################
# MAIN PROCESS
cat << __EOF__                                 
Content-type: text/html

<html>
<head>
  <title>Torrent admin</title>
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
<form action=torrent.cgi method=get>
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
<input type=submit accesskey=h name=ACTION value=Help>
<! img align=top alt="" src=pingvin.gif>
<br>


__EOF__

QUERY_STRING=`echo "$QUERY_STRING" | sed 's/&/;/g'`
eval ${QUERY_STRING}
#export ACTION
#/opt/bin/printenv

case "${ACTION}" in
	Update) _update_progress ; _list ;;
	Log) _log ;;
	Push)	_push ; _list ;;
	Pause) _pause ; _list ;;
        Remove) _remove; _list ;;
        Purge) _purge ;;
        Watchdog) torrent_watchdog ;;
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
