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
ASTERISK18_BASE_VERSION=1.8.25.0

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
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
ASTERISK18_SUGGESTS +=,gtk2
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK18_SUGGESTS +=,x11
endif

ASTERISK18_CONFLICTS=asterisk10,asterisk11


#
# ASTERISK18_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK18_IPK_VERSION=5

#
# ASTERISK18_CONFFILES should be a list of user-editable files
#ASTERISK18_CONFFILES=$(TARGET_PREFIX)/etc/asterisk18.conf $(TARGET_PREFIX)/etc/init.d/SXXasterisk18
ASTERISK18_CONFFILES=\
$(TARGET_PREFIX)/etc/asterisk/vpb.conf \
$(TARGET_PREFIX)/etc/asterisk/voicemail.conf \
$(TARGET_PREFIX)/etc/asterisk/users.conf \
$(TARGET_PREFIX)/etc/asterisk/unistim.conf \
$(TARGET_PREFIX)/etc/asterisk/udptl.conf \
$(TARGET_PREFIX)/etc/asterisk/telcordia-1.adsi \
$(TARGET_PREFIX)/etc/asterisk/smdi.conf \
$(TARGET_PREFIX)/etc/asterisk/sla.conf \
$(TARGET_PREFIX)/etc/asterisk/skinny.conf \
$(TARGET_PREFIX)/etc/asterisk/sip_notify.conf \
$(TARGET_PREFIX)/etc/asterisk/sip.conf \
$(TARGET_PREFIX)/etc/asterisk/say.conf \
$(TARGET_PREFIX)/etc/asterisk/rtp.conf \
$(TARGET_PREFIX)/etc/asterisk/res_stun_monitor.conf \
$(TARGET_PREFIX)/etc/asterisk/res_snmp.conf \
$(TARGET_PREFIX)/etc/asterisk/res_pktccops.conf \
$(TARGET_PREFIX)/etc/asterisk/res_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/res_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/res_ldap.conf \
$(TARGET_PREFIX)/etc/asterisk/res_fax.conf \
$(TARGET_PREFIX)/etc/asterisk/res_curl.conf \
$(TARGET_PREFIX)/etc/asterisk/res_config_sqlite.conf \
$(TARGET_PREFIX)/etc/asterisk/res_config_mysql.conf \
$(TARGET_PREFIX)/etc/asterisk/queues.conf \
$(TARGET_PREFIX)/etc/asterisk/queuerules.conf \
$(TARGET_PREFIX)/etc/asterisk/phoneprov.conf \
$(TARGET_PREFIX)/etc/asterisk/phone.conf \
$(TARGET_PREFIX)/etc/asterisk/oss.conf \
$(TARGET_PREFIX)/etc/asterisk/osp.conf \
$(TARGET_PREFIX)/etc/asterisk/muted.conf \
$(TARGET_PREFIX)/etc/asterisk/musiconhold.conf \
$(TARGET_PREFIX)/etc/asterisk/modules.conf \
$(TARGET_PREFIX)/etc/asterisk/misdn.conf \
$(TARGET_PREFIX)/etc/asterisk/minivm.conf \
$(TARGET_PREFIX)/etc/asterisk/mgcp.conf \
$(TARGET_PREFIX)/etc/asterisk/meetme.conf \
$(TARGET_PREFIX)/etc/asterisk/manager.conf \
$(TARGET_PREFIX)/etc/asterisk/logger.conf \
$(TARGET_PREFIX)/etc/asterisk/jingle.conf \
$(TARGET_PREFIX)/etc/asterisk/jabber.conf \
$(TARGET_PREFIX)/etc/asterisk/indications.conf \
$(TARGET_PREFIX)/etc/asterisk/iaxprov.conf \
$(TARGET_PREFIX)/etc/asterisk/iax.conf \
$(TARGET_PREFIX)/etc/asterisk/http.conf \
$(TARGET_PREFIX)/etc/asterisk/h323.conf \
$(TARGET_PREFIX)/etc/asterisk/gtalk.conf \
$(TARGET_PREFIX)/etc/asterisk/func_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/followme.conf \
$(TARGET_PREFIX)/etc/asterisk/festival.conf \
$(TARGET_PREFIX)/etc/asterisk/features.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions_minivm.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions.lua \
$(TARGET_PREFIX)/etc/asterisk/extensions.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions.ael \
$(TARGET_PREFIX)/etc/asterisk/extconfig.conf \
$(TARGET_PREFIX)/etc/asterisk/enum.conf \
$(TARGET_PREFIX)/etc/asterisk/dundi.conf \
$(TARGET_PREFIX)/etc/asterisk/dsp.conf \
$(TARGET_PREFIX)/etc/asterisk/dnsmgr.conf \
$(TARGET_PREFIX)/etc/asterisk/dbsep.conf \
$(TARGET_PREFIX)/etc/asterisk/console.conf \
$(TARGET_PREFIX)/etc/asterisk/codecs.conf \
$(TARGET_PREFIX)/etc/asterisk/cli_permissions.conf \
$(TARGET_PREFIX)/etc/asterisk/cli_aliases.conf \
$(TARGET_PREFIX)/etc/asterisk/cli.conf \
$(TARGET_PREFIX)/etc/asterisk/chan_ooh323.conf \
$(TARGET_PREFIX)/etc/asterisk/chan_mobile.conf \
$(TARGET_PREFIX)/etc/asterisk/chan_dahdi.conf \
$(TARGET_PREFIX)/etc/asterisk/cel_tds.conf \
$(TARGET_PREFIX)/etc/asterisk/cel_sqlite3_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cel_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/cel_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cel_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cel.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_tds.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_syslog.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_sqlite3_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_mysql.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_manager.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_adaptive_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr.conf \
$(TARGET_PREFIX)/etc/asterisk/ccss.conf \
$(TARGET_PREFIX)/etc/asterisk/calendar.conf \
$(TARGET_PREFIX)/etc/asterisk/asterisk.conf \
$(TARGET_PREFIX)/etc/asterisk/asterisk.adsi \
$(TARGET_PREFIX)/etc/asterisk/app_mysql.conf \
$(TARGET_PREFIX)/etc/asterisk/amd.conf \
$(TARGET_PREFIX)/etc/asterisk/alsa.conf \
$(TARGET_PREFIX)/etc/asterisk/alarmreceiver.conf \
$(TARGET_PREFIX)/etc/asterisk/ais.conf \
$(TARGET_PREFIX)/etc/asterisk/agents.conf \
$(TARGET_PREFIX)/etc/asterisk/adsi.conf \


#
# ASTERISK18_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK18_PATCHES = \
$(ASTERISK18_SOURCE_DIR)/roundf.patch \
$(ASTERISK18_SOURCE_DIR)/inline_api.patch

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
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
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
	$(MAKE) ncurses-stage openssl-stage libcurl-stage zlib-stage termcap-stage libstdc++-stage \
		radiusclient-ng-stage unixodbc-stage popt-stage net-snmp-stage \
		sqlite-stage libogg-stage libxml2-stage \
		mysql-stage bluez2-libs-stage neon-stage libical-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (jabberd, $(filter jabberd, $(PACKAGES)))
	$(MAKE) jabberd-stage
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
	$(MAKE) iksemel-stage
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
	$(MAKE) gtk2-stage
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
	$(MAKE) x11-stage
endif
	rm -rf $(BUILD_DIR)/$(ASTERISK18_DIR) $(ASTERISK18_BUILD_DIR)
	$(ASTERISK18_UNZIP) $(DL_DIR)/$(ASTERISK18_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK18_PATCHES)" ; \
		then cat $(ASTERISK18_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ASTERISK18_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK18_DIR)" != "$(ASTERISK18_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK18_DIR) $(ASTERISK18_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e '/+= *-pipe/s/^/#/' $(@D)/Makefile
endif
ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabi buildroot-armeabi-ng buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy buildroot-mipsel buildroot-mipsel-ng, $(OPTWARE_TARGET)))
#	no res_nsearch() in uClibc
	sed -i -e '/AC_DEFINE(\[HAVE_RES_NINIT\]/d' $(@D)/configure.ac
endif
	sed -i -e "s/AC_CHECK_HEADERS..xlocale\.h../###########/" $(@D)/configure.ac
	sed -i -e "s|<defaultenabled>yes</defaultenabled>||" $(@D)/sounds/sounds.xml
	echo 'ACLOCAL_AMFLAGS = -I autoconf' >> $(@D)/Makefile.am
	$(AUTORECONF1.9) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK18_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$(PATH)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
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
		--localstatedir=$(TARGET_PREFIX)/var \
		--sysconfdir=$(TARGET_PREFIX)/etc \
	)
	touch $@

asterisk18-unpack: $(ASTERISK18_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK18_BUILD_DIR)/.built: $(ASTERISK18_BUILD_DIR)/.configured
	rm -f $@
	ASTCFLAGS="$(TARGET_CUSTOM_FLAGS) $(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(@D) menuselect.makeopts
	( cd $(ASTERISK18_BUILD_DIR);\
	./menuselect/menuselect --enable-category MENUSELECT_ADDONS menuselect.makeopts;\
	./menuselect/menuselect --disable format_mp3 menuselect.makeopts )
	ASTCFLAGS="$(TARGET_CUSTOM_FLAGS) $(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(@D) $(strip $(if $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)), OPTIMIZE=-O2))
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
	ASTCFLAGS="$(TARGET_CUSTOM_FLAGS) $(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install -j1
	touch $(ASTERISK18_BUILD_DIR)/.staged

asterisk18-stage: $(ASTERISK18_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk18
#
$(ASTERISK18_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
# Binaries should be installed into $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk18/...
# Documentation files should be installed in $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/doc/asterisk18/...
# Daemon startup scripts should be installed in $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??asterisk18
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK18_IPK): $(ASTERISK18_BUILD_DIR)/.built
	rm -rf $(ASTERISK18_IPK_DIR) $(BUILD_DIR)/asterisk18_*_$(TARGET_ARCH).ipk
	ASTCFLAGS="$(TARGET_CUSTOM_FLAGS) $(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(ASTERISK18_IPK_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install -j1
	ASTCFLAGS="$(TARGET_CUSTOM_FLAGS) $(ASTERISK18_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK18_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK18_BUILD_DIR) DESTDIR=$(ASTERISK18_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#$(TARGET_PREFIX)/var/spool/asterisk#g' $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#$(TARGET_PREFIX)/var/lib/asterisk#g' $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/calls#$(TARGET_PREFIX)/var/calls#g' $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#$(TARGET_PREFIX)/sbin/streamplayer#g' $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#$(TARGET_PREFIX)$(TARGET_PREFIX)/#$(TARGET_PREFIX)/#g' $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#$(TARGET_PREFIX)/var/lib/asterisk#' \
		-e 's#/var/spool/asterisk#$(TARGET_PREFIX)/var/spool/asterisk#' \
		-e 's#/var/log/asterisk#$(TARGET_PREFIX)/var/log/asterisk#' \
		-e 's#/etc/asterisk#$(TARGET_PREFIX)/etc/asterisk#' \
		$(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/var/lib/asterisk/static-http/core-en_US.xml

	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => func_speex.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_console.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_iax2.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_jingle.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_mgcp.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_mobile.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_skinny.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_ooh323.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_unistim.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => pbx_dundi.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => pbx_ael.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => format_ogg_vorbis.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_festival.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_amd.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_queue.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_mixmonitor.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_mysql.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_ael_share.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_agi.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_curl.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_ldap.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_mysql.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_sqlite.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_fax.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_adaptive_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_mysql.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite3_custom.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cel_odbc.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cel_radius.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cel_sqlite3_custom.so" >> $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf

	$(MAKE) $(ASTERISK18_IPK_DIR)/CONTROL/control
	echo $(ASTERISK18_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK18_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/sbin/astcanary \
			$(ASTERISK18_IPK_DIR)$(TARGET_PREFIX)/sbin/asterisk ; do \
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
