-- SQL commands to create a TorrentFlux database using sqlite
-- --------------------------------------------------------

BEGIN TRANSACTION;

CREATE TABLE tf_links (
  lid           INTEGER  PRIMARY KEY,
  url           VARCHAR  NOT NULL default '',
  sitename      VARCHAR  NOT NULL default 'Old Link',
  sort_order    INTEGER  default '0'
);

INSERT INTO tf_links VALUES (1, 'http://www.torrentflux.com', 'TorrentFlux.com', 0);

-- --------------------------------------------------------

CREATE TABLE tf_log (
  cid           INTEGER  PRIMARY KEY,
  user_id       VARCHAR  NOT NULL default '',
  file          VARCHAR  NOT NULL default '',
  action        VARCHAR  NOT NULL default '',
  ip            VARCHAR  NOT NULL default '',
  ip_resolved   VARCHAR  NOT NULL default '',
  user_agent    VARCHAR  NOT NULL default '',
  time          VARCHAR  NOT NULL default '0'
);

-- --------------------------------------------------------

CREATE TABLE tf_messages (
  mid           INTEGER  PRIMARY KEY,
  to_user       VARCHAR  NOT NULL default '',
  from_user     VARCHAR  NOT NULL default '',
  message       TEXT,
  IsNew         INTEGER  default NULL,
  ip            VARCHAR  NOT NULL default '',
  time          VARCHAR  NOT NULL default '0',
  force_read    INTEGER  default '0'
);

-- --------------------------------------------------------

CREATE TABLE tf_rss (
  rid           INTEGER  PRIMARY KEY,
  url           VARCHAR  NOT NULL default ''
);

-- --------------------------------------------------------

CREATE TABLE tf_settings (
  tf_key        VARCHAR  PRIMARY KEY default '',
  tf_value      TEXT     NOT NULL
);

INSERT INTO tf_settings VALUES ('path', '/opt/var/torrentflux/downloads');
INSERT INTO tf_settings VALUES ('btphpbin', '/opt/share/www/torrentflux/TF_BitTornado/btphptornado.py');
INSERT INTO tf_settings VALUES ('btshowmetainfo', '/opt/share/www/torrentflux/TF_BitTornado/btshowmetainfo.py');
INSERT INTO tf_settings VALUES ('advanced_start', '1');
INSERT INTO tf_settings VALUES ('max_upload_rate', '10');
INSERT INTO tf_settings VALUES ('max_download_rate', '0');
INSERT INTO tf_settings VALUES ('max_uploads', '4');
INSERT INTO tf_settings VALUES ('minport', '49160');
INSERT INTO tf_settings VALUES ('maxport', '49300');
INSERT INTO tf_settings VALUES ('rerequest_interval', '1800');
INSERT INTO tf_settings VALUES ('cmd_options', '');
INSERT INTO tf_settings VALUES ('enable_search', '1');
INSERT INTO tf_settings VALUES ('enable_file_download', '1');
INSERT INTO tf_settings VALUES ('enable_view_nfo', '1');
INSERT INTO tf_settings VALUES ('package_ENGINE', 'zip');
INSERT INTO tf_settings VALUES ('show_server_load', '1');
INSERT INTO tf_settings VALUES ('loadavg_path', '/proc/loadavg');
INSERT INTO tf_settings VALUES ('days_to_keep', '30');
INSERT INTO tf_settings VALUES ('minutes_to_keep', '3');
INSERT INTO tf_settings VALUES ('rss_cache_min', '20');
INSERT INTO tf_settings VALUES ('page_refresh', '60');
INSERT INTO tf_settings VALUES ('default_theme', 'matrix');
INSERT INTO tf_settings VALUES ('default_language', 'lang-english.php');
INSERT INTO tf_settings VALUES ('debug_sql', '1');
INSERT INTO tf_settings VALUES ('torrent_dies_when_done', 'False');
INSERT INTO tf_settings VALUES ('sharekill', '150');
INSERT INTO tf_settings VALUES ('tfQManager', '/opt/share/www/torrentflux/TF_BitTornado/tfQManager.py');
INSERT INTO tf_settings VALUES ('AllowQueing', '0');
INSERT INTO tf_settings VALUES ('maxServerThreads', '5');
INSERT INTO tf_settings VALUES ('maxUserThreads', '2');
INSERT INTO tf_settings VALUES ('sleepInterval', '10');
INSERT INTO tf_settings VALUES ('debugTorrents', '0');
INSERT INTO tf_settings VALUES ('pythonCmd', '/opt/bin/python');
INSERT INTO tf_settings VALUES ('searchEngine', 'isoHunt');
INSERT INTO tf_settings VALUES ('TorrentSpyGenreFilter', 'a:3:{i:0;s:2:"11";i:1;s:1:"6";i:2;s:1:"7";}');
INSERT INTO tf_settings VALUES ('TorrentBoxGenreFilter', 'a:3:{i:0;s:1:"0";i:1;s:1:"9";i:2;s:2:"10";}');
INSERT INTO tf_settings VALUES ('TorrentPortalGenreFilter', 'a:3:{i:0;s:1:"0";i:1;s:1:"6";i:2;s:2:"10";}');
INSERT INTO tf_settings VALUES ('enable_maketorrent','0');
INSERT INTO tf_settings VALUES ('btmakemetafile','/opt/share/www/torrentflux/TF_BitTornado/btmakemetafile.py');
INSERT INTO tf_settings VALUES ('enable_torrent_download','1');
INSERT INTO tf_settings VALUES ('enable_file_priority','1');
INSERT INTO tf_settings VALUES ('security_code','0');
INSERT INTO tf_settings VALUES ('crypto_allowed', '1');
INSERT INTO tf_settings VALUES ('crypto_only', '1');
INSERT INTO tf_settings VALUES ('crypto_stealth', '0');

-- --------------------------------------------------------

CREATE TABLE tf_users (
  uid           INTEGER  PRIMARY KEY,
  user_id       VARCHAR  NOT NULL default '',
  password      VARCHAR  NOT NULL default '',
  hits          INTEGER  NOT NULL default '0',
  last_visit    VARCHAR  NOT NULL default '0',
  time_created  VARCHAR  NOT NULL default '0',
  user_level    INTEGER  NOT NULL default '0',
  hide_offline  INTEGER  NOT NULL default '0',
  theme         VARCHAR  NOT NULL default 'mint',
  language_file VARCHAR  default 'lang-english.php'
);

-- --------------------------------------------------------

CREATE TABLE tf_cookies (
  cid           INTEGER  NOT NULL PRIMARY KEY,
  uid           INTEGER  NOT NULL,
  host          VARCHAR  default NULL,
  data          VARCHAR  default NULL
);

INSERT INTO tf_cookies VALUES(1,1,'thepiratebay.org','language=en_EN');

-- --------------------------------------------------------

COMMIT;

