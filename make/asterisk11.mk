###########################################################
#
# asterisk11
#
###########################################################
#
# ASTERISK11_VERSION, ASTERISK11_SITE and ASTERISK11_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK11_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK11_UNZIP is the command used to unzip the source.
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
ASTERISK11_SOURCE_TYPE=tarball
#ASTERISK11_SOURCE_TYPE=svn

ASTERISK11_SITE=http://downloads.digium.com/pub/asterisk/releases
ASTERISK11_BASE_VERSION=11.3.0

ifeq ($(ASTERISK11_SOURCE_TYPE), svn)
ASTERISK11_SVN=http://svn.digium.com/svn/asterisk/branches/1.8.0
ASTERISK11_SVN_REV=166221
ASTERISK11_VERSION=$(ASTERISK11_BASE_VERSION)svn-r$(ASTERISK11_SVN_REV)
else
ASTERISK11_VERSION=$(ASTERISK11_BASE_VERSION)
endif

ASTERISK11_SOURCE=asterisk-$(ASTERISK11_VERSION).tar.gz
ASTERISK11_DIR=asterisk-$(ASTERISK11_VERSION)
ASTERISK11_UNZIP=zcat
ASTERISK11_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
ASTERISK11_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK11_SECTION=util
ASTERISK11_PRIORITY=optional
ASTERISK11_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++,popt,libxml2,sqlite,e2fslibs
ASTERISK11_SUGGESTS=\
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
,libogg\
,net-snmp\
,radiusclient-ng\
,unixodbc

ifeq (jabberd, $(filter jabberd, $(PACKAGES)))
ASTERISK11_SUGGESTS +=,jabberd
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK11_DEPENDS +=,iksemel
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
ASTERISK11_SUGGESTS +=,gtk
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK11_SUGGESTS +=,x11
endif

ASTERISK11_CONFLICTS=asterisk18,asterisk10


#
# ASTERISK11_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK11_IPK_VERSION=1

#
# ASTERISK11_CONFFILES should be a list of user-editable files
#ASTERISK11_CONFFILES=/opt/etc/asterisk.conf /opt/etc/init.d/SXXasterisk
ASTERISK11_CONFFILES=\
/opt/etc/asterisk/xmpp.conf \
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
/opt/etc/asterisk/res_corosync.conf \
/opt/etc/asterisk/res_config_sqlite3.conf \
/opt/etc/asterisk/res_config_mysql.conf \
/opt/etc/asterisk/queues.conf \
/opt/etc/asterisk/queuerules.conf \
/opt/etc/asterisk/phoneprov.conf \
/opt/etc/asterisk/phone.conf \
/opt/etc/asterisk/oss.conf \
/opt/etc/asterisk/osp.conf \
/opt/etc/asterisk/ooh323.conf \
/opt/etc/asterisk/muted.conf \
/opt/etc/asterisk/musiconhold.conf \
/opt/etc/asterisk/motif.conf \
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
/opt/etc/asterisk/config_test.conf \
/opt/etc/asterisk/confbridge.conf \
/opt/etc/asterisk/codecs.conf \
/opt/etc/asterisk/cli_permissions.conf \
/opt/etc/asterisk/cli_aliases.conf \
/opt/etc/asterisk/cli.conf \
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
/opt/etc/asterisk/app_skel.conf \
/opt/etc/asterisk/app_mysql.conf \
/opt/etc/asterisk/amd.conf \
/opt/etc/asterisk/alsa.conf \
/opt/etc/asterisk/alarmreceiver.conf \
/opt/etc/asterisk/agents.conf \
/opt/etc/asterisk/adsi.conf \
/opt/etc/asterisk/acl.conf \


#
# ASTERISK11_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK11_PATCHES = $(ASTERISK11_SOURCE_DIR)/roundf.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK11_CPPFLAGS=-fPIC -fsigned-char -I$(STAGING_INCLUDE_DIR)
ifeq (slugosbe, $(OPTWARE_TARGET))
ASTERISK11_CPPFLAGS+= -DPATH_MAX=4096
endif
ASTERISK11_LDFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter angstrombe angstromle cs05q3armel cs08q1armel syno-e500, $(OPTWARE_TARGET)))
ASTERISK11_LDFLAGS+=-lpthread -ldl -lresolv
endif
ifeq (uclibc, $(LIBC_STYLE))
ASTERISK11_LDFLAGS+=-lpthread -lm
endif

ASTERISK11_CONFIGURE_OPTS=
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK11_CONFIGURE_OPTS += --with-iksemel=$(STAGING_PREFIX)
else
ASTERISK11_CONFIGURE_OPTS += --without-iksemel
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
ASTERISK11_CONFIGURE_OPTS += --with-gtk2=$(STAGING_PREFIX)
else
ASTERISK11_CONFIGURE_OPTS += --without-gtk2
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK11_CONFIGURE_OPTS += --with-x11=$(STAGING_PREFIX)
else
ASTERISK11_CONFIGURE_OPTS += --without-x11
endif

#
# ASTERISK11_BUILD_DIR is the directory in which the build is done.
# ASTERISK11_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK11_IPK_DIR is the directory in which the ipk is built.
# ASTERISK11_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK11_BUILD_DIR=$(BUILD_DIR)/asterisk11
ASTERISK11_SOURCE_DIR=$(SOURCE_DIR)/asterisk11
ASTERISK11_IPK_DIR=$(BUILD_DIR)/asterisk11-$(ASTERISK11_VERSION)-ipk
ASTERISK11_IPK=$(BUILD_DIR)/asterisk11_$(ASTERISK11_VERSION)-$(ASTERISK11_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk11-source asterisk11-unpack asterisk11 asterisk11-stage asterisk11-ipk asterisk11-clean asterisk11-dirclean asterisk11-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK11_SOURCE):
ifeq ($(ASTERISK11_SOURCE_TYPE), svn)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK11_DIR) && \
		svn co -r $(ASTERISK11_SVN_REV) $(ASTERISK11_SVN) \
			$(ASTERISK11_DIR) && \
		tar -czf $@ $(ASTERISK11_DIR) && \
		rm -rf $(ASTERISK11_DIR) \
	)
else
	$(WGET) -P $(DL_DIR) $(ASTERISK11_SITE)/$(ASTERISK11_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk11-source: $(DL_DIR)/$(ASTERISK11_SOURCE) $(ASTERISK11_PATCHES)

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
$(ASTERISK11_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK11_SOURCE) $(ASTERISK11_PATCHES) make/asterisk11.mk
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
	$(MAKE) mysql-stage bluez2-libs-stage openssl-stage e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK11_DIR) $(ASTERISK11_BUILD_DIR)
	$(ASTERISK11_UNZIP) $(DL_DIR)/$(ASTERISK11_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK11_PATCHES)" ; \
		then cat $(ASTERISK11_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK11_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK11_DIR)" != "$(ASTERISK11_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK11_DIR) $(ASTERISK11_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e '/+= *-pipe/s/^/#/' $(@D)/Makefile
endif
	(cd $(@D); \
		sed -i -e "s/AC_CHECK_HEADERS..xlocale\.h../###########/" configure.ac; \
		sed -i -e "s|<defaultenabled>yes</defaultenabled>||" sounds/sounds.xml; \
		sed -i -e "s#    ac_cross_compile=\$$.*#    ac_cross_compile=\`echo \$$\{CC\} | sed 's/gcc\$$//'\`#" res/pjproject/aconfigure; \
		./bootstrap.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		LIBEDIT_DIR="internal" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK11_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
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
		--without-sqlite \
		--with-sqlite3=$(STAGING_PREFIX) \
		--with-radius=$(STAGING_PREFIX) \
		--with-unixodbc=$(STAGING_PREFIX) \
		--with-netsnmp=$(STAGING_PREFIX) \
		--with-ltdl=$(STAGING_PREFIX) \
		--with-mysqlclient=$(STAGING_PREFIX) \
		--with-bluetooth=$(STAGING_PREFIX) \
		--without-ilbc \
		--without-postgres \
		--without-pwlib \
		--without-lua \
		--without-imap \
		--without-dahdi \
		--without-sdl \
		--disable-xmldoc \
		$(ASTERISK11_CONFIGURE_OPTS) \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc; \
	cd $(@D)/res/pjproject; \
		echo "export CFLAGS += $(STAGING_CPPFLAGS) $(ASTERISK11_CPPFLAGS)" > user.mak; \
		echo "export LDLAGS += $(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" >> user.mak; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK11_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-floating-point \
		--disable-sound \
		--disable-oss \
		--disable-speex-aec \
		--disable-l16-codec \
		--disable-gsm-codec \
		--disable-g722-codec \
		--disable-g7221-codec \
		--disable-speex-codec \
		--disable-ilbc-codec \
		--disable-g711-codec \
		--disable-opencore-amrnb \
		--disable-video \
		--disable-ffmpeg \
		--disable-v4l2 \
		--disable-ssl; \
	)
	touch $@

asterisk11-unpack: $(ASTERISK11_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK11_BUILD_DIR)/.built: $(ASTERISK11_BUILD_DIR)/.configured
	rm -f $@
	ASTCFLAGS="$(ASTERISK11_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
	$(MAKE) NOISY_BUILD=yes -C $(@D) menuselect.makeopts
	( cd $(ASTERISK11_BUILD_DIR);\
	./menuselect/menuselect --enable-category MENUSELECT_ADDONS menuselect.makeopts;\
	./menuselect/menuselect --disable format_mp3 menuselect.makeopts )
	ASTCFLAGS="$(ASTERISK11_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
	$(MAKE) NOISY_BUILD=yes -C $(@D)
	touch $@

#
# This is the build convenience target.
#
asterisk11: $(ASTERISK11_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK11_BUILD_DIR)/.staged: $(ASTERISK11_BUILD_DIR)/.built
	rm -f $(ASTERISK11_BUILD_DIR)/.staged
	ASTCFLAGS="$(ASTERISK11_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
	$(MAKE) NOISY_BUILD=yes -C $(ASTERISK11_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=/opt/sbin install
	touch $(ASTERISK11_BUILD_DIR)/.staged

asterisk11-stage: $(ASTERISK11_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk
#
$(ASTERISK11_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk11" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK11_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK11_SECTION)" >>$@
	@echo "Version: $(ASTERISK11_VERSION)-$(ASTERISK11_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK11_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK11_SITE)/$(ASTERISK11_SOURCE)" >>$@
	@echo "Description: $(ASTERISK11_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK11_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK11_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK11_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK11_IPK_DIR)/opt/sbin or $(ASTERISK11_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK11_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/...
# Documentation files should be installed in $(ASTERISK11_IPK_DIR)/opt/doc/asterisk/...
# Daemon startup scripts should be installed in $(ASTERISK11_IPK_DIR)/opt/etc/init.d/S??asterisk
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK11_IPK): $(ASTERISK11_BUILD_DIR)/.built
	rm -rf $(ASTERISK11_IPK_DIR) $(BUILD_DIR)/asterisk11_*_$(TARGET_ARCH).ipk
	ASTCFLAGS="$(ASTERISK11_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
	$(MAKE) NOISY_BUILD=yes -C $(ASTERISK11_BUILD_DIR) DESTDIR=$(ASTERISK11_IPK_DIR) ASTSBINDIR=/opt/sbin install
	ASTCFLAGS="$(ASTERISK11_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK11_LDFLAGS)" \
	$(MAKE) NOISY_BUILD=yes -C $(ASTERISK11_BUILD_DIR) DESTDIR=$(ASTERISK11_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#/opt/var/spool/asterisk#g' $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#/opt/var/lib/asterisk#g' $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/calls#/opt/var/calls#g' $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#/opt/sbin/streamplayer#g' $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/opt/opt/#/opt/#g' $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/*

	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => func_speex.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_console.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_iax2.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_jingle.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_mgcp.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_mobile.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_skinny.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_unistim.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => pbx_dundi.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => pbx_ael.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => format_ogg_vorbis.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_amd.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_dictate.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_festival.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_mixmonitor.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_morsecode.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_mysql.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_queue.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => app_speech_utils.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_ael_share.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_agi.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_curl.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_ldap.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_mysql.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_sqlite.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_fax.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_speech.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_adaptive_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_mysql.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite3_custom.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_odbc.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_radius.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cel_sqlite3_custom.so" >> $(ASTERISK11_IPK_DIR)/opt/etc/asterisk/modules.conf

	$(MAKE) NOISY_BUILD=yes $(ASTERISK11_IPK_DIR)/CONTROL/control
	echo $(ASTERISK11_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK11_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK11_IPK_DIR)/opt/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	$(STRIP_COMMAND) $(ASTERISK11_IPK_DIR)/opt/lib/libasteriskssl.so
	for filetostrip in $(ASTERISK11_IPK_DIR)/opt/sbin/astcanary \
			$(ASTERISK11_IPK_DIR)/opt/sbin/astdb2bdb \
			$(ASTERISK11_IPK_DIR)/opt/sbin/astdb2sqlite3 \
			$(ASTERISK11_IPK_DIR)/opt/sbin/asterisk ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK11_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ASTERISK11_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk11-ipk: $(ASTERISK11_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk11-clean:
	rm -f $(ASTERISK11_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK11_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk11-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK11_DIR) $(ASTERISK11_BUILD_DIR) $(ASTERISK11_IPK_DIR) $(ASTERISK11_IPK)
#
#
# Some sanity check for the package.
#
asterisk11-check: $(ASTERISK11_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK11_IPK)
