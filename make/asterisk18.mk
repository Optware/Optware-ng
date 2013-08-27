###########################################################
#
# asterisk18
#
###########################################################
#
# ASTERISK18_VERSION, ASTERISK18_SITE and ASTERISK18_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK18_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK18_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
ASTERISK18_SOURCE_TYPE=tarball
#ASTERISK18_SOURCE_TYPE=svn

ASTERISK18_SITE=http://downloads.asterisk.org/pub/telephony/asterisk/releases
ASTERISK18_BASE_VERSION=1.8.23.0

ifeq ($(ASTERISK18_SOURCE_TYPE), svn)
ASTERISK18_SVN=http://svn.digium.com/svn/asterisk/branches/1.8.0
ASTERISK18_SVN_REV=166221
ASTERISK18_VERSION=$(ASTERISK18_BASE_VERSION)svn-r$(ASTERISK18_SVN_REV)
else
ASTERISK18_VERSION=$(ASTERISK18_BASE_VERSION)
endif

ASTERISK18_SOURCE=asterisk-$(ASTERISK18_VERSION).tar.gz
ASTERISK18_DIR=asterisk-$(ASTERISK18_VERSION)
ASTERISK18_UNZIP=zcat
ASTERISK18_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
ASTERISK18_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK18_SECTION=util
ASTERISK18_PRIORITY=optional
ASTERISK18_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++,popt,libxml2
ASTERISK18_SUGGESTS=\
asterisk14-core-sounds-en-alaw\
,asterisk14-core-sounds-en-g729\
,asterisk14-core-sounds-en-gsm\
,asterisk14-core-sounds-en-ulaw\
,asterisk14-extra-sounds-en-alaw\
,asterisk14-extra-sounds-en-g729\
,asterisk14-extra-sounds-en-gsm\
,asterisk14-extra-sounds-en-ulaw\
,asterisk14-moh-opsound-alaw\
,asterisk14-moh-opsound-g729\
,asterisk14-moh-opsound-gsm\
,asterisk14-moh-opsound-ulaw\
,libical\
,libogg\
,net-snmp\
,neon\
,radiusclient-ng\
,sqlite\
,unixodbc

ifeq (jabberd, $(filter jabberd, $(PACKAGES)))
ASTERISK18_SUGGESTS +=,jabberd
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK18_DEPENDS +=,iksemel
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
ASTERISK18_SUGGESTS +=,gtk
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK18_SUGGESTS +=,x11
endif

ASTERISK18_CONFLICTS=asterisk10,asterisk11


#
# ASTERISK18_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK18_IPK_VERSION=1

#
# ASTERISK18_CONFFILES should be a list of user-editable files
#ASTERISK18_CONFFILES=/opt/etc/asterisk18.conf /opt/etc/init.d/SXXasterisk18
ASTERISK18_CONFFILES=\
/opt/etc/asterisk/vpb.conf \
/opt/etc/asterisk/voicemail.conf \
/opt/etc/asterisk/users.conf \
/opt/etc/asterisk/unistim.conf \
/opt/etc/asterisk/udptl.conf \
/opt/etc/asterisk/telcordia-1.adsi \
/opt/etc/asterisk/smdi.conf \
/opt/etc/asterisk/sla.conf \
/opt/etc/asterisk/skinny.conf \
/opt/etc/asterisk/sip_notify.conf \
/opt/etc/asterisk/sip.conf \
/opt/etc/asterisk/say.conf \
/opt/etc/asterisk/rtp.conf \
/opt/etc/asterisk/res_stun_monitor.conf \
/opt/etc/asterisk/res_snmp.conf \
/opt/etc/asterisk/res_pktccops.conf \
/opt/etc/asterisk/res_pgsql.conf \
/opt/etc/asterisk/res_odbc.conf \
/opt/etc/asterisk/res_ldap.conf \
/opt/etc/asterisk/res_fax.conf \
/opt/etc/asterisk/res_curl.conf \
/opt/etc/asterisk/res_config_sqlite.conf \
/opt/etc/asterisk/res_config_mysql.conf \
/opt/etc/asterisk/queues.conf \
/opt/etc/asterisk/queuerules.conf \
/opt/etc/asterisk/phoneprov.conf \
/opt/etc/asterisk/phone.conf \
/opt/etc/asterisk/oss.conf \
/opt/etc/asterisk/osp.conf \
/opt/etc/asterisk/muted.conf \
/opt/etc/asterisk/musiconhold.conf \
/opt/etc/asterisk/modules.conf \
/opt/etc/asterisk/misdn.conf \
/opt/etc/asterisk/minivm.conf \
/opt/etc/asterisk/mgcp.conf \
/opt/etc/asterisk/meetme.conf \
/opt/etc/asterisk/manager.conf \
/opt/etc/asterisk/logger.conf \
/opt/etc/asterisk/jingle.conf \
/opt/etc/asterisk/jabber.conf \
/opt/etc/asterisk/indications.conf \
/opt/etc/asterisk/iaxprov.conf \
/opt/etc/asterisk/iax.conf \
/opt/etc/asterisk/http.conf \
/opt/etc/asterisk/h323.conf \
/opt/etc/asterisk/gtalk.conf \
/opt/etc/asterisk/func_odbc.conf \
/opt/etc/asterisk/followme.conf \
/opt/etc/asterisk/festival.conf \
/opt/etc/asterisk/features.conf \
/opt/etc/asterisk/extensions_minivm.conf \
/opt/etc/asterisk/extensions.lua \
/opt/etc/asterisk/extensions.conf \
/opt/etc/asterisk/extensions.ael \
/opt/etc/asterisk/extconfig.conf \
/opt/etc/asterisk/enum.conf \
/opt/etc/asterisk/dundi.conf \
/opt/etc/asterisk/dsp.conf \
/opt/etc/asterisk/dnsmgr.conf \
/opt/etc/asterisk/dbsep.conf \
/opt/etc/asterisk/console.conf \
/opt/etc/asterisk/codecs.conf \
/opt/etc/asterisk/cli_permissions.conf \
/opt/etc/asterisk/cli_aliases.conf \
/opt/etc/asterisk/cli.conf \
/opt/etc/asterisk/chan_ooh323.conf \
/opt/etc/asterisk/chan_mobile.conf \
/opt/etc/asterisk/chan_dahdi.conf \
/opt/etc/asterisk/cel_tds.conf \
/opt/etc/asterisk/cel_sqlite3_custom.conf \
/opt/etc/asterisk/cel_pgsql.conf \
/opt/etc/asterisk/cel_odbc.conf \
/opt/etc/asterisk/cel_custom.conf \
/opt/etc/asterisk/cel.conf \
/opt/etc/asterisk/cdr_tds.conf \
/opt/etc/asterisk/cdr_syslog.conf \
/opt/etc/asterisk/cdr_sqlite3_custom.conf \
/opt/etc/asterisk/cdr_pgsql.conf \
/opt/etc/asterisk/cdr_odbc.conf \
/opt/etc/asterisk/cdr_mysql.conf \
/opt/etc/asterisk/cdr_manager.conf \
/opt/etc/asterisk/cdr_custom.conf \
/opt/etc/asterisk/cdr_adaptive_odbc.conf \
/opt/etc/asterisk/cdr.conf \
/opt/etc/asterisk/ccss.conf \
/opt/etc/asterisk/calendar.conf \
/opt/etc/asterisk/asterisk.conf \
/opt/etc/asterisk/asterisk.adsi \
/opt/etc/asterisk/app_mysql.conf \
/opt/etc/asterisk/amd.conf \
/opt/etc/asterisk/alsa.conf \
/opt/etc/asterisk/alarmreceiver.conf \
/opt/etc/asterisk/ais.conf \
/opt/etc/asterisk/agents.conf \
/opt/etc/asterisk/adsi.conf \


#
# ASTERISK18_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK18_PATCHES = $(ASTERISK18_SOURCE_DIR)/roundf.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK18_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR) \
	-I$(STAGING_INCLUDE_DIR)/libxml2
ifeq (slugosbe, $(OPTWARE_TARGET))
ASTERISK18_CPPFLAGS+= -DPATH_MAX=4096
endif
ASTERISK18_LDFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter angstrombe angstromle cs05q3armel cs08q1armel syno-e500, $(OPTWARE_TARGET)))
ASTERISK18_LDFLAGS+=-lpthread -ldl -lresolv
endif
ifeq (uclibc, $(LIBC_STYLE))
ASTERISK18_LDFLAGS+=-lpthread -lm
endif

ASTERISK18_CONFIGURE_OPTS=
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK18_CONFIGURE_OPTS += --with-iksemel=$(STAGING_PREFIX)
else
ASTERISK18_CONFIGURE_OPTS += --without-iksemel
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
ASTERISK18_CONFIGURE_OPTS += --with-gtk2=$(STAGING_PREFIX)
else
ASTERISK18_CONFIGURE_OPTS += --without-gtk2
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK18_CONFIGURE_OPTS += --with-x11=$(STAGING_PREFIX)
else
ASTERISK18_CONFIGURE_OPTS += --without-x11
endif

#
# ASTERISK18_BUILD_DIR is the directory in which the build is done.
# ASTERISK18_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK18_IPK_DIR is the directory in which the ipk is built.
# ASTERISK18_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK18_BUILD_DIR=$(BUILD_DIR)/asterisk18
ASTERISK18_SOURCE_DIR=$(SOURCE_DIR)/asterisk18
ASTERISK18_IPK_DIR=$(BUILD_DIR)/asterisk18-$(ASTERISK18_VERSION)-ipk
ASTERISK18_IPK=$(BUILD_DIR)/asterisk18_$(ASTERISK18_VERSION)-$(ASTERISK18_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk18-source asterisk18-unpack asterisk18 asterisk18-stage asterisk18-ipk asterisk18-clean asterisk18-dirclean asterisk18-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK18_SOURCE):
ifeq ($(ASTERISK18_SOURCE_TYPE), svn)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK18_DIR) && \
		svn co -r $(ASTERISK18_SVN_REV) $(ASTERISK18_SVN) \
			$(ASTERISK18_DIR) && \
		tar -czf $@ $(ASTERISK18_DIR) && \
		rm -rf $(ASTERISK18_DIR) \
	)
else
	$(WGET) -P $(DL_DIR) $(ASTERISK18_SITE)/$(ASTERISK18_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk18-source: $(DL_DIR)/$(ASTERISK18_SOURCE) $(ASTERISK18_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(ASTERISK18_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK18_SOURCE) $(ASTERISK18_PATCHES) make/asterisk18.mk
	$(MAKE) ncurses-stage openssl-stage libcurl-stage zlib-stage termcap-stage libstdc++-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (jabberd, $(filter jabberd, $(PACKAGES)))
	$(MAKE) jabberd-stage
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
	$(MAKE) iksemel-stage
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(MAKE) gtk-stage
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
	$(MAKE) x11-stage
endif
	$(MAKE) radiusclient-ng-stage unixodbc-stage popt-stage net-snmp-stage
	$(MAKE) sqlite-stage libogg-stage libxml2-stage
	$(MAKE) mysql-stage bluez2-libs-stage neon-stage libical-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK18_DIR) $(ASTERISK18_BUILD_DIR)
	$(ASTERISK18_UNZIP) $(DL_DIR)/$(ASTERISK18_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK18_PATCHES)" ; \
		then cat $(ASTERISK18_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK18_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK18_DIR)" != "$(ASTERISK18_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK18_DIR) $(ASTERISK18_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e '/+= *-pipe/s/^/#/' $(@D)/Makefile
endif
	(cd $(@D); \
		sed -i -e "s/AC_CHECK_HEADERS..xlocale\.h../###########/" configure.ac; \
		sed -i -e "s|<defaultenabled>yes</defaultenabled>||" sounds/sounds.xml; \
		./bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK18_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$(PATH)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-ssl=$(STAGING_PREFIX) \
		--with-z=$(STAGING_PREFIX) \
		--with-termcap=$(STAGING_PREFIX) \
		--with-libcurl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-popt=$(STAGING_PREFIX) \
		--without-tds \
		--without-openais \
		--without-sqlite \
		--with-sqlite3=$(STAGING_PREFIX) \
		--with-radius=$(STAGING_PREFIX) \
		--with-unixodbc=$(STAGING_PREFIX) \
		--with-netsnmp=$(STAGING_PREFIX) \
		--with-ltdl=$(STAGING_PREFIX) \
		--with-mysqlclient=$(STAGING_PREFIX) \
		--with-bluetooth=$(STAGING_PREFIX) \
		--with-neon=$(STAGING_PREFIX) \
		--with-ical=$(STAGING_PREFIX) \
		--with-ncurses=$(STAGING_PREFIX) \
		--with-libxml2=$(STAGING_PREFIX) \
		--without-postgres \
		--without-pwlib \
		--without-lua \
		--without-imap \
		--without-dahdi \
		--without-sdl \
		$(ASTERISK18_CONFIGURE_OPTS) \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)
	touch $@

asterisk18-unpack: $(ASTERISK18_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK18_BUILD_DIR)/.built: $(ASTERISK18_BUILD_DIR)/.configured
	rm -f $@
	ASTCFLAGS="$(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(@D) menuselect.makeopts
	( cd $(ASTERISK18_BUILD_DIR);\
	./menuselect/menuselect --enable-category MENUSELECT_ADDONS menuselect.makeopts;\
	./menuselect/menuselect --disable format_mp3 menuselect.makeopts )
	ASTCFLAGS="$(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
asterisk18: $(ASTERISK18_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK18_BUILD_DIR)/.staged: $(ASTERISK18_BUILD_DIR)/.built
	rm -f $(ASTERISK18_BUILD_DIR)/.staged
	ASTCFLAGS="$(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=/opt/sbin install
	touch $(ASTERISK18_BUILD_DIR)/.staged

asterisk18-stage: $(ASTERISK18_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk18
#
$(ASTERISK18_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk18" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK18_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK18_SECTION)" >>$@
	@echo "Version: $(ASTERISK18_VERSION)-$(ASTERISK18_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK18_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK18_SITE)/$(ASTERISK18_SOURCE)" >>$@
	@echo "Description: $(ASTERISK18_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK18_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK18_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK18_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK18_IPK_DIR)/opt/sbin or $(ASTERISK18_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK18_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK18_IPK_DIR)/opt/etc/asterisk18/...
# Documentation files should be installed in $(ASTERISK18_IPK_DIR)/opt/doc/asterisk18/...
# Daemon startup scripts should be installed in $(ASTERISK18_IPK_DIR)/opt/etc/init.d/S??asterisk18
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK18_IPK): $(ASTERISK18_BUILD_DIR)/.built
	rm -rf $(ASTERISK18_IPK_DIR) $(BUILD_DIR)/asterisk18_*_$(TARGET_ARCH).ipk
	ASTCFLAGS="$(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(ASTERISK18_IPK_DIR) ASTSBINDIR=/opt/sbin install
	ASTCFLAGS="$(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(ASTERISK18_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#/opt/var/spool/asterisk#g' $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#/opt/var/lib/asterisk#g' $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/calls#/opt/var/calls#g' $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#/opt/sbin/streamplayer#g' $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/opt/opt/#/opt/#g' $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#/opt/var/lib/asterisk#' \
		-e 's#/var/spool/asterisk#/opt/var/spool/asterisk#' \
		-e 's#/var/log/asterisk#/opt/var/log/asterisk#' \
		-e 's#/etc/asterisk#/opt/etc/asterisk#' \
		$(ASTERISK18_IPK_DIR)/opt/var/lib/asterisk/static-http/core-en_US.xml

	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => func_speex.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_console.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_iax2.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_jingle.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_mgcp.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_mobile.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_skinny.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_ooh323.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_unistim.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => pbx_dundi.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => pbx_ael.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => format_ogg_vorbis.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_festival.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_amd.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_queue.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_mixmonitor.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_mysql.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_ael_share.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_agi.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_curl.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_ldap.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_mysql.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_sqlite.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_fax.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_adaptive_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_mysql.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite3_custom.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_odbc.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_radius.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_sqlite3_custom.so" >> $(ASTERISK18_IPK_DIR)/opt/etc/asterisk/modules.conf

	$(MAKE) $(ASTERISK18_IPK_DIR)/CONTROL/control
	echo $(ASTERISK18_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK18_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK18_IPK_DIR)/opt/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK18_IPK_DIR)/opt/sbin/astcanary \
			$(ASTERISK18_IPK_DIR)/opt/sbin/asterisk ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK18_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ASTERISK18_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk18-ipk: $(ASTERISK18_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk18-clean:
	rm -f $(ASTERISK18_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK18_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk18-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK18_DIR) $(ASTERISK18_BUILD_DIR) $(ASTERISK18_IPK_DIR) $(ASTERISK18_IPK)
#
#
# Some sanity check for the package.
#
asterisk18-check: $(ASTERISK18_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK18_IPK)
