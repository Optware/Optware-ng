/******************************************************************************
 * $Id$
 *
 * Visit http://transmission.m0k.org/cgi-bin/trac.cgi/ticket/127
 * and http://transmission.m0k.org/forum/viewtopic.php?p=3757#3757
 *
 * Sample usage: export HOME=/tmp/harddisk/tmp
 * transmissiond -p 65534 -w 1800 -u 40 -i /opt/var/run/transmission.pid  \
 *                /tmp/harddisk/tmp/active-torrents.txt
 *
 * Always use full paths to facilitate reload_active.
 *
 * TODO: 
 *  notification delay (autoseed time). Seeding expired status.
 *  config file 
 *  messageLevel for syslog in background mode
 *
 * Copyright (c) 2005-2007 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <signal.h>
#include <libgen.h>
#include <time.h>
#include <sys/stat.h>
#include <syslog.h>
#include <transmission.h>
#ifdef SYS_BEOS
#include <kernel/OS.h>
#define usleep snooze
#endif
#ifdef __GNUC__
#  define UNUSED __attribute__((unused))
#else
#  define UNUSED
#endif
#ifdef SYS_LINUX
#include <sys/sysinfo.h>
#define HAVE_SYSINFO
#endif

#define USAGE \
"Usage: %s [options] active-torrents.txt [options]\n\n" \
"Options:\n" \
"  -h, --help           Print this help and exit\n" \
"  -v, --verbose <int>  Verbose level implies foreground (0 to 2, default = 0)\n" \
"  -p, --port <int>     Port we should listen on (default = %d)\n" \
"  -u, --upload <int>   Maximum upload rate (-1 = no limit, default = 20)\n" \
"  -d, --download <int> Maximum download rate (-1 = no limit, default = -1)\n" \
"  -f, --finish <shell script> Command you wish to run on completion\n" \
"  -n  --nat-traversal  Attempt NAT traversal using NAT-PMP or UPnP IGD\n" \
"  -w, --watchdog <int> Watchdog interval in seconds (default = 600)\n" \
"  -i, --pidfile <path> PID file path \n" \
"Signals:\n"                                                            \
"\tHUP\treload active-torrents.txt and start/stop torrents\n"\
"\tUSR1\twrite .status files into torrent directories\n"   \
"\tUSR2\tlist active torrents\n"

static int          showHelp      = 0;
static int          verboseLevel  = 0;
static int          bindPort      = TR_DEFAULT_PORT;
static int          uploadLimit   = 20;
static int          downloadLimit = -1;
static char         * torrentPath = NULL;
static int          watchdogInterval = 600;
static int          natTraversal  = 0;
static sig_atomic_t mustDie       = 0;
static sig_atomic_t got_hup       = 0;
static sig_atomic_t got_usr1      = 0;
static sig_atomic_t got_usr2      = 0;
static char         * pidfile = NULL;

static char         * finishCall   = NULL;
static tr_handle_t  * h;

static int  parseCommandLine ( int argc, char ** argv );

/* return number of items in array */
#define ALEN(a)                 (sizeof(a) / sizeof((a)[0]))

static void watchdog(tr_torrent_t *tor, void * data UNUSED)
{
  int result;

  if( tr_getFinished( tor ) )
    {
      result = system(finishCall);
    }  
}


/* Try for 5 seconds to notice the tracker that we are leaving */
static void stop(tr_torrent_t *tor, void * data UNUSED )
{
  int i;
  tr_stat_t    * s;
  tr_info_t * info =  tr_torrentInfo( tor );
  syslog( LOG_NOTICE, "Stopping torrent %s", info->torrent );
  tr_torrentStop( tor );
  for( i = 0; i < 10; i++ )
    {
      s = tr_torrentStat( tor );
      if( s->status & TR_STATUS_PAUSE )
        {
          /* The 'stopped' message was sent */
          break;
        }
      usleep( 500000 );
    }
  tr_torrentClose( h, tor );
}

struct active_torrents_s
{
  char *torrent;
  char found;
};

#define TR_FACTIVE 0x80    /* Torrent should be active */


/* Check torrent if disposal is needed and clean active flag */
static void dispose(tr_torrent_t *tor, void * data )
{
  tr_info_t * info =  tr_torrentInfo( tor );
  if (info->flags & TR_FACTIVE)
    info->flags &= ~TR_FACTIVE;
  else
    stop(tor, data);
}

/* Check torrent by name provided and mark it as active */
static void is_active(tr_torrent_t *tor, void *data)
{
  struct active_torrents_s *a = (struct active_torrents_s *)data;
  tr_info_t * info =  tr_torrentInfo( tor );
  if ( 0 == strcmp(info->torrent, a->torrent))
    {
      a->found = 1;
      info->flags |= TR_FACTIVE; 
    }
}


static void reload_active()
{
  tr_torrent_t * tor;
  int error;
  FILE *stream;

  struct active_torrents_s active_torrents;

  syslog(LOG_DEBUG, "Reload_Active called");

  /* open a file with a list of requested active torrents */
  if ( (stream = fopen(torrentPath, "r")) != NULL)
    {
      char fn[MAX_PATH_LENGTH];
      while (fgets(fn, MAX_PATH_LENGTH, stream) )
        {
          char *tr = fn;
          while(*tr) {
            if (*tr == '\n')
              { *tr = '\0';
                break;
              }
            tr++;
          }
          if ( tr == fn)
            continue;
          
          /* Is on the list of active_torrents ? */
          active_torrents.torrent = fn;
          active_torrents.found = 0;
          tr_torrentIterate(h, is_active, &active_torrents);
          if ( !active_torrents.found ) /* add new torrent */
            {
              if( !( tor = tr_torrentInit( h, fn, NULL, 0, &error ) ) )
                {
                  syslog(LOG_CRIT, "%.80s - %m", fn );
                }
              else
                {
                  tr_info_t * info =  tr_torrentInfo( tor );
                  char *folder = strdup(fn);
                  tr_torrentSetFolder( tor, dirname(folder));
                  free(folder);
                  tr_torrentStart( tor );
                  info->flags |= TR_FACTIVE; 
                  syslog( LOG_NOTICE, "Starting torrent %s", info->torrent );
                }
            }
        }
      fclose(stream);
      /* Stop unwanted torrents which do not have active flag */
      tr_torrentIterate(h, dispose, NULL);
    }
  else
    syslog(LOG_ERR, "Active torrent file %s - %m", torrentPath);
}

/* Prepares status string up to STATUS_WIDTH chars width */
static char * status(tr_torrent_t *tor)
{
#define STATUS_WIDTH 90
  static char string[STATUS_WIDTH];
  int  chars = 0;

  tr_stat_t    * s = tr_torrentStat( tor );

  if (s->error)
    snprintf( string, STATUS_WIDTH, "Error: %s", s->errorString );
  else if( s->status & TR_STATUS_CHECK )
    {
      chars = snprintf( string, STATUS_WIDTH,
                        "Checking files... %.2f %%", 100.0 * s->progress );
    }
  else if( s->status & TR_STATUS_DOWNLOAD )
    {
      if (s->eta < 0 ) /* Without eta */
        snprintf( string, STATUS_WIDTH,
                  "Progress: %.2f %%, %d peer%s, dl from %d (%.2f KB/s), "
                  "ul to %d (%.2f KB/s)", 100.0 * s->progress,
                  s->peersTotal, ( s->peersTotal == 1 ) ? "" : "s",
                  s->peersUploading, s->rateDownload,
                  s->peersDownloading, s->rateUpload );
      else
        snprintf( string, STATUS_WIDTH,
                  "Progress: %.2f %%, %d peer%s, dl from %d (%.2f KB/s), "
                  "ul to %d (%.2f KB/s) %d:%02d remaining",
                  100.0 * s->progress,
                  s->peersTotal, ( s->peersTotal == 1 ) ? "" : "s",
                  s->peersUploading, s->rateDownload,
                  s->peersDownloading, s->rateUpload,
                  s->eta / 3600, (s->eta / 60) % 60
                  );
    }
  else if( s->status & TR_STATUS_SEED )
    {
      chars = snprintf( string, STATUS_WIDTH,
                        "Seeding, uploading to %d of %d peer(s), %.2f KB/s",
                        s->peersDownloading, s->peersTotal,
                        s->rateUpload );
    }
  else if (s->status & TR_STATUS_STOPPING)
    snprintf( string, STATUS_WIDTH, "Stopping...");
  else if (s->status & TR_STATUS_PAUSE )
    snprintf( string, STATUS_WIDTH, "Paused (%.2f %%)", 100 * s->progress);
  else
    string[0] = '\0';

  return string;
}


static void write_info(tr_torrent_t *tor, void * data UNUSED )
{
  FILE *stream;
  char fn[MAX_PATH_LENGTH];
  tr_stat_t    * s = tr_torrentStat( tor );
  
  snprintf(fn, MAX_PATH_LENGTH, "%s/.status", tr_torrentGetFolder(tor));
  stream = fopen(fn, "w");
  if ( stream )
    {
      fputs("STATUS='", stream);
      fputs(status(tor), stream);
      fprintf(stream, "'\nDOWNLOADED='%.1f'\nUPLOADED='%.1f'\n",
              (s->downloaded/1024)/1024.0f,
              (s->uploaded/1024)/1024.0f);
      fclose(stream);
    }
  else
    syslog(LOG_ERR, "%s - %m", fn);
}

/* List torrent name */
static void list(tr_torrent_t *tor, void * data UNUSED)
{
  tr_info_t * info =  tr_torrentInfo( tor );
  syslog(LOG_INFO, "'%s':%s", info->name, status(tor));
}


static void signalHandler( int signal )
{
  switch( signal )
    {
    case SIGINT:
    case SIGTERM:
      mustDie = 1;
      break;
    case SIGUSR1:
      got_usr1 = 1;
      break;
    case SIGUSR2:
      got_usr2 = 1;
      break;
    case SIGHUP:
      got_hup = 1;
      break;
    default:
      break;
    }
}

static void setupsighandlers(void) {
  int sigs[] = {SIGHUP, SIGINT, SIGTERM, SIGUSR1, SIGUSR2};
  struct sigaction sa;
  unsigned int ii;

  bzero(&sa, sizeof(sa));
  sa.sa_handler = signalHandler;
  for(ii = 0; ii < ALEN(sigs); ii++)
    sigaction(sigs[ii], &sa, NULL);
}



static int write_pidfile(int pid)
{
  FILE *f = fopen(pidfile, "w");
  if ( f != NULL)
    {
      fprintf(f, "%d\n", pid);
      fclose(f);
      return 0;
    }
  else
    syslog( LOG_CRIT, "%.80s - %m", pidfile );
  return -1;
}


static void flush_queued_messages( void )
{
  tr_msg_list_t * list;
  tr_msg_list_t * prev;
  int repeated;
  list = tr_getQueuedMessages();

  prev = NULL;
  repeated = 0;
  
  while( NULL != list )
    {
      if (prev && (strcmp(prev->message, list->message) == 0))
        {
          repeated ++;
        }
      else
        {
          if (repeated)
            {
              syslog(LOG_NOTICE, "Previous message repeated %d times", repeated);
              repeated = 0;
            }
          else
            {
              switch ( list->level )
                {
                case TR_MSG_ERR:
                  syslog(LOG_ERR, "%s", list->message);
                  break;
                case TR_MSG_INF:
                  syslog(LOG_INFO, "%s", list->message);
                  break;
                case TR_MSG_DBG:
                  syslog(LOG_DEBUG, "%s", list->message);
                  break;
                default:
                  syslog(LOG_CRIT, "%s", list->message);
                }
            }
        }
      prev = list;
      list = list->next;
    }
  if (repeated)
    {
      syslog(LOG_NOTICE, "Previous message repeated %d times", repeated);
    }
  tr_freeMessageList( list );
}

int main( int argc, char ** argv )
{
  int i;
  pid_t pid;
  char *cp;
  tr_handle_status_t * hstat;
  
  /* Get options */
  if( parseCommandLine( argc, argv ) )
    {
      printf( USAGE, argv[0], TR_DEFAULT_PORT );
      return 1;
    }
  
  if( showHelp )
    {
      printf( USAGE, argv[0], TR_DEFAULT_PORT );
      return 0;
    }
  
  if( verboseLevel < 0 )
    {
      verboseLevel = 0;
    }
  else if( verboseLevel > 9 )
    {
      verboseLevel = 9;
    }
  if( verboseLevel )
    {
      static char env[11];
      sprintf( env, "TR_DEBUG=%d", verboseLevel );
      putenv( env );
    }
  
  if( bindPort < 1 || bindPort > 65535 )
    {
      printf( "Invalid port '%d'\n", bindPort );
      return 1;
    }
  
  if (verboseLevel == 0)
    {
      switch( fork())
        {
        case 0:
          break;
        case -1:
          syslog( LOG_CRIT, "fork - %m" );
          exit(1);
        default:
          exit(0);
        }
  
      /* child continues */
  

      /* We're not going to use stdin stdout or stderr from here on, so close
      ** them to save file descriptors.  */
     fclose( stdin );
     fclose( stdout );
     fclose( stderr );  
    }

  setsid();    /* become session leader */
  pid = getpid();
  
  cp = strrchr( argv[0], '/' );
  if ( cp != (char*) 0 )
    ++cp;
  else
    cp = argv[0];
  
  openlog(cp, LOG_NDELAY|LOG_PID, LOG_USER);
  
  syslog(LOG_INFO,
         "Transmission daemon %s (%d) started - http://transmission.m0k.org/",
         VERSION_STRING, VERSION_REVISION );
  
  /*  */
  if (pidfile != NULL)
    write_pidfile(pid);
  
  
  /* Initialize libtransmission */
  h = tr_init("cgi");

  /* Move  to writable directory to be able to save coredump there */
  if ( chdir(tr_getPrefsDirectory())  < 0)
    {
      syslog( LOG_CRIT, "chdir - %m" );
      exit( 1 );
    }

  if ( verboseLevel == 0)
    {
      tr_setMessageQueuing(TR_MSG_ERR);
      tr_setMessageLevel(TR_MSG_ERR);
    }
  tr_setBindPort( h, bindPort );
  tr_setGlobalUploadLimit( h, uploadLimit );
  tr_setGlobalDownloadLimit( h, downloadLimit );

  tr_natTraversalEnable( h, natTraversal);
  
  setupsighandlers();
  reload_active();
  
  while( !mustDie )
    {
      float upload, download;
      sleep( watchdogInterval );
      flush_queued_messages();
      if ( got_usr1 )
        {
          tr_torrentIterate( h, write_info, NULL );
          got_usr1 = 0;
        }
      if ( got_usr2 )
        {
          tr_torrentIterate( h, list, NULL );
          got_usr2 = 0;
        }
      if ( got_hup )
        {
          reload_active();
          got_hup = 0;
        }
      tr_torrentIterate( h, watchdog, NULL );
      tr_torrentRates(h, &download, &upload);

#ifdef HAVE_SYSINFO
      {
        static const int FSHIFT = 16;          /* nr of bits of precision */
#       define FIXED_1         (1<<FSHIFT)     /* 1.0 as fixed-point */
#       define LOAD_INT(x) ((x) >> FSHIFT)
#       define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)

        struct sysinfo info;
        sysinfo(&info);
        syslog(LOG_INFO, "%ld %d dl %.2f ul %.2f ld %ld.%02ld", time(NULL),
               tr_torrentCount( h ), download, upload,
               LOAD_INT(info.loads[1]), LOAD_FRAC(info.loads[1]));
      }
#else
      syslog(LOG_INFO, "%ld %d dl %.2f ul %.2f ld 0.0", time(NULL),
             tr_torrentCount( h ), download, upload);
#endif
    }
  
  tr_torrentIterate( h, stop, NULL );
  syslog( LOG_NOTICE, "All torrents stopped");

  /* Try for 5 seconds to delete any port mappings for nat traversal */
  tr_natTraversalEnable( h , 0);
  for( i = 0; i < 10; i++ )
    {
      hstat = tr_handleStatus( h );
      if( TR_NAT_TRAVERSAL_DISABLED == hstat->natTraversalStatus )
        {
          /* Port mappings were deleted */
          break;
        }
      usleep( 500000 );
    }
  tr_close( h );
  
  if (pidfile != NULL)
    unlink(pidfile);
  
  syslog( LOG_NOTICE, "exiting" );
  closelog();
  
  return 0;
}



static int parseCommandLine( int argc, char ** argv )
{
    for( ;; )
    {
        static struct option long_options[] =
          { { "help",     no_argument,       NULL, 'h' },
            { "verbose",  required_argument, NULL, 'v' },
            { "port",     required_argument, NULL, 'p' },
            { "upload",   required_argument, NULL, 'u' },
            { "download", required_argument, NULL, 'd' },
            { "finish",   required_argument, NULL, 'f' },
            { "watchdog", required_argument, NULL, 'w' },
            { "pidfile",  required_argument, NULL, 'i' }, 
            { "nat-traversal", no_argument,  NULL, 'n' },
            { 0, 0, 0, 0} };

        int c, optind = 0;
        c = getopt_long( argc, argv, "hv:p:u:d:f:w:i:n", long_options, &optind );
        if( c < 0 )
        {
            break;
        }
        switch( c )
          {
          case 'h':
            showHelp = 1;
            break;
          case 'v':
            verboseLevel = atoi( optarg );
            break;
          case 'p':
            bindPort = atoi( optarg );
            break;
          case 'u':
            uploadLimit = atoi( optarg );
            break;
          case 'd':
            downloadLimit = atoi( optarg );
            break;
          case 'f':
            finishCall = optarg;
            break;
          case 'w':
            watchdogInterval = atoi (optarg);
            break;
          case 'i':
            pidfile = optarg;
            break;
          case 'n':
            natTraversal = 1;
            break;
          default:
            return 1;
        }
    }

    if( optind > argc - 1  )
    {
        return !showHelp;
    }

    torrentPath = argv[optind];

    return 0;
}

