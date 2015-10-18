###########################################################
#
# asterisk16
#
###########################################################
#
# ASTERISK16_VERSION, ASTERISK16_SITE and ASTERISK16_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK16_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK16_UNZIP is the command used to unzip the source.
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
ASTERISK16_SOURCE_TYPE=tarball
#ASTERISK16_SOURCE_TYPE=svn

ASTERISK16_SITE=http://downloads.digium.com/pub/asterisk/releases
ASTERISK16_BASE_VERSION=1.6.2.22

ifeq ($(ASTERISK16_SOURCE_TYPE), svn)
ASTERISK16_SVN=http://svn.digium.com/svn/asterisk/branches/1.6.1
ASTERISK16_SVN_REV=166221
ASTERISK16_VERSION=$(ASTERISK16_BASE_VERSION)svn-r$(ASTERISK16_SVN_REV)
else
ASTERISK16_VERSION=$(ASTERISK16_BASE_VERSION)
endif

ASTERISK16_SOURCE=asterisk-$(ASTERISK16_VERSION).tar.gz
ASTERISK16_DIR=asterisk-$(ASTERISK16_VERSION)
ASTERISK16_UNZIP=zcat
ASTERISK16_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
ASTERISK16_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK16_SECTION=util
ASTERISK16_PRIORITY=optional
ASTERISK16_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++,popt,libxml2
ASTERISK16_SUGGESTS=\
asterisk14-core-sounds-en-alaw,\
asterisk14-core-sounds-en-g729,\
asterisk14-core-sounds-en-gsm,\
asterisk14-core-sounds-en-ulaw,\
asterisk14-extra-sounds-en-alaw,\
asterisk14-extra-sounds-en-g729,\
asterisk14-extra-sounds-en-gsm,\
asterisk14-extra-sounds-en-ulaw,\
asterisk14-moh-opsound-alaw,\
asterisk14-moh-opsound-g729,\
asterisk14-moh-opsound-gsm,\
asterisk14-moh-opsound-ulaw,\
asterisk14-gui\
,libogg\
,net-snmp\
,radiusclient-ng\
,sqlite2\
,unixodbc

ifeq (jabberd, $(filter jabberd, $(PACKAGES)))
ASTERISK16_SUGGESTS +=,jabberd
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK16_SUGGESTS +=,iksemel
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
ASTERISK16_SUGGESTS +=,gtk2
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK16_SUGGESTS +=,x11
endif

ASTERISK16_CONFLICTS=asterisk,asterisk14,astersk18,asterisk-sounds,asterisk-chan-capi,asterisk14-chan-capi


#
# ASTERISK16_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK16_IPK_VERSION=2

#
# ASTERISK16_CONFFILES should be a list of user-editable files
#ASTERISK16_CONFFILES=$(TARGET_PREFIX)/etc/asterisk16.conf $(TARGET_PREFIX)/etc/init.d/SXXasterisk16
ASTERISK16_CONFFILES=\
$(TARGET_PREFIX)/etc/asterisk/adsi.conf \
$(TARGET_PREFIX)/etc/asterisk/adtranvofr.conf \
$(TARGET_PREFIX)/etc/asterisk/agents.conf \
$(TARGET_PREFIX)/etc/asterisk/alarmreceiver.conf \
$(TARGET_PREFIX)/etc/asterisk/alsa.conf \
$(TARGET_PREFIX)/etc/asterisk/amd.conf \
$(TARGET_PREFIX)/etc/asterisk/asterisk.adsi \
$(TARGET_PREFIX)/etc/asterisk/asterisk.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_adaptive_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_manager.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_sqlite3_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_tds.conf \
$(TARGET_PREFIX)/etc/asterisk/chan_dahdi.conf \
$(TARGET_PREFIX)/etc/asterisk/cli.conf \
$(TARGET_PREFIX)/etc/asterisk/codecs.conf \
$(TARGET_PREFIX)/etc/asterisk/console.conf \
$(TARGET_PREFIX)/etc/asterisk/dnsmgr.conf \
$(TARGET_PREFIX)/etc/asterisk/dundi.conf \
$(TARGET_PREFIX)/etc/asterisk/enum.conf \
$(TARGET_PREFIX)/etc/asterisk/extconfig.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions.ael \
$(TARGET_PREFIX)/etc/asterisk/extensions.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions.lua \
$(TARGET_PREFIX)/etc/asterisk/extensions_minivm.conf \
$(TARGET_PREFIX)/etc/asterisk/features.conf \
$(TARGET_PREFIX)/etc/asterisk/festival.conf \
$(TARGET_PREFIX)/etc/asterisk/followme.conf \
$(TARGET_PREFIX)/etc/asterisk/func_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/gtalk.conf \
$(TARGET_PREFIX)/etc/asterisk/h323.conf \
$(TARGET_PREFIX)/etc/asterisk/http.conf \
$(TARGET_PREFIX)/etc/asterisk/iax.conf \
$(TARGET_PREFIX)/etc/asterisk/iaxprov.conf \
$(TARGET_PREFIX)/etc/asterisk/indications.conf \
$(TARGET_PREFIX)/etc/asterisk/jabber.conf \
$(TARGET_PREFIX)/etc/asterisk/jingle.conf \
$(TARGET_PREFIX)/etc/asterisk/logger.conf \
$(TARGET_PREFIX)/etc/asterisk/manager.conf \
$(TARGET_PREFIX)/etc/asterisk/meetme.conf \
$(TARGET_PREFIX)/etc/asterisk/mgcp.conf \
$(TARGET_PREFIX)/etc/asterisk/minivm.conf \
$(TARGET_PREFIX)/etc/asterisk/misdn.conf \
$(TARGET_PREFIX)/etc/asterisk/modules.conf \
$(TARGET_PREFIX)/etc/asterisk/musiconhold.conf \
$(TARGET_PREFIX)/etc/asterisk/muted.conf \
$(TARGET_PREFIX)/etc/asterisk/osp.conf \
$(TARGET_PREFIX)/etc/asterisk/oss.conf \
$(TARGET_PREFIX)/etc/asterisk/phone.conf \
$(TARGET_PREFIX)/etc/asterisk/phoneprov.conf \
$(TARGET_PREFIX)/etc/asterisk/queuerules.conf \
$(TARGET_PREFIX)/etc/asterisk/queues.conf \
$(TARGET_PREFIX)/etc/asterisk/res_ldap.conf \
$(TARGET_PREFIX)/etc/asterisk/res_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/res_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/res_snmp.conf \
$(TARGET_PREFIX)/etc/asterisk/rpt.conf \
$(TARGET_PREFIX)/etc/asterisk/rtp.conf \
$(TARGET_PREFIX)/etc/asterisk/say.conf \
$(TARGET_PREFIX)/etc/asterisk/sip.conf \
$(TARGET_PREFIX)/etc/asterisk/sip_notify.conf \
$(TARGET_PREFIX)/etc/asterisk/skinny.conf \
$(TARGET_PREFIX)/etc/asterisk/sla.conf \
$(TARGET_PREFIX)/etc/asterisk/smdi.conf \
$(TARGET_PREFIX)/etc/asterisk/telcordia-1.adsi \
$(TARGET_PREFIX)/etc/asterisk/udptl.conf \
$(TARGET_PREFIX)/etc/asterisk/unistim.conf \
$(TARGET_PREFIX)/etc/asterisk/usbradio.conf \
$(TARGET_PREFIX)/etc/asterisk/users.conf \
$(TARGET_PREFIX)/etc/asterisk/voicemail.conf \
$(TARGET_PREFIX)/etc/asterisk/vpb.conf

#
# ASTERISK16_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK16_PATCHES=$(ASTERISK16_SOURCE_DIR)/sounds.xml.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK16_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR)
ifeq (slugosbe, $(OPTWARE_TARGET))
ASTERISK16_CPPFLAGS+= -DPATH_MAX=4096
endif
ASTERISK16_LDFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter angstrombe angstromle cs05q3armel cs08q1armel syno-e500, $(OPTWARE_TARGET)))
ASTERISK16_LDFLAGS+=-lpthread -ldl -lresolv
endif
ifeq (uclibc, $(LIBC_STYLE))
ASTERISK16_LDFLAGS+=-lpthread -lm
ASTERISK16_PATCHES += $(ASTERISK16_SOURCE_DIR)/roundf.patch
endif

ASTERISK16_CONFIGURE_OPTS=
ifeq (gnutls, $(filter gnutls, $(PACKAGES)))
ASTERISK16_CONFIGURE_OPTS += --with-gnutls=$(STAGING_PREFIX)
else
ASTERISK16_CONFIGURE_OPTS += --without-gnutls
endif
ifeq (iksemel, $(filter iksemel, $(PACKAGES)))
ASTERISK16_CONFIGURE_OPTS += --with-iksemel=$(STAGING_PREFIX)
else
ASTERISK16_CONFIGURE_OPTS += --without-iksemel
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
ASTERISK16_CONFIGURE_OPTS += --with-gtk2=$(STAGING_PREFIX)
else
ASTERISK16_CONFIGURE_OPTS += --without-gtk2
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
ASTERISK16_CONFIGURE_OPTS += --with-x11=$(STAGING_PREFIX)
else
ASTERISK16_CONFIGURE_OPTS += --without-x11
endif

#
# ASTERISK16_BUILD_DIR is the directory in which the build is done.
# ASTERISK16_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK16_IPK_DIR is the directory in which the ipk is built.
# ASTERISK16_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK16_BUILD_DIR=$(BUILD_DIR)/asterisk16
ASTERISK16_SOURCE_DIR=$(SOURCE_DIR)/asterisk16
ASTERISK16_IPK_DIR=$(BUILD_DIR)/asterisk16-$(ASTERISK16_VERSION)-ipk
ASTERISK16_IPK=$(BUILD_DIR)/asterisk16_$(ASTERISK16_VERSION)-$(ASTERISK16_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk16-source asterisk16-unpack asterisk16 asterisk16-stage asterisk16-ipk asterisk16-clean asterisk16-dirclean asterisk16-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK16_SOURCE):
ifeq ($(ASTERISK16_SOURCE_TYPE), svn)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK16_DIR) && \
		svn co -r $(ASTERISK16_SVN_REV) $(ASTERISK16_SVN) \
			$(ASTERISK16_DIR) && \
		tar -czf $@ $(ASTERISK16_DIR) && \
		rm -rf $(ASTERISK16_DIR) \
	)
else
	$(WGET) -P $(DL_DIR) $(ASTERISK16_SITE)/$(ASTERISK16_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk16-source: $(DL_DIR)/$(ASTERISK16_SOURCE) $(ASTERISK16_PATCHES)

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
$(ASTERISK16_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK16_SOURCE) $(ASTERISK16_PATCHES) make/asterisk16.mk
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
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
	$(MAKE) gtk2-stage
endif
ifeq (x11, $(filter x11, $(PACKAGES)))
	$(MAKE) x11-stage
endif
	$(MAKE) radiusclient-ng-stage unixodbc-stage popt-stage net-snmp-stage
	$(MAKE) sqlite2-stage libogg-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK16_DIR) $(ASTERISK16_BUILD_DIR)
	$(ASTERISK16_UNZIP) $(DL_DIR)/$(ASTERISK16_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK16_PATCHES)" ; \
		then cat $(ASTERISK16_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ASTERISK16_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK16_DIR)" != "$(ASTERISK16_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK16_DIR) $(ASTERISK16_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e '/+= *-pipe/s/^/#/' $(@D)/Makefile
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK16_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
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
		--with-curl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-popt=$(STAGING_PREFIX) \
		--without-tds \
		--with-sqlite=$(STAGING_PREFIX) \
		--with-radius=$(STAGING_PREFIX) \
		--with-odbc=$(STAGING_PREFIX) \
		--with-netsnmp=$(STAGING_PREFIX) \
		--with-ltdl=$(STAGING_PREFIX) \
		--without-postgres \
		--without-sqlite3 \
		--without-pwlib \
		--without-usb \
		--without-lua \
		--without-imap \
		--without-dahdi \
		--without-sdl \
		$(ASTERISK16_CONFIGURE_OPTS) \
		--localstatedir=$(TARGET_PREFIX)/var \
		--sysconfdir=$(TARGET_PREFIX)/etc \
	)
	touch $@

asterisk16-unpack: $(ASTERISK16_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK16_BUILD_DIR)/.built: $(ASTERISK16_BUILD_DIR)/.configured
	rm -f $@
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
asterisk16: $(ASTERISK16_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK16_BUILD_DIR)/.staged: $(ASTERISK16_BUILD_DIR)/.built
	rm -f $(ASTERISK16_BUILD_DIR)/.staged
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install
	touch $(ASTERISK16_BUILD_DIR)/.staged

asterisk16-stage: $(ASTERISK16_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk16
#
$(ASTERISK16_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: asterisk16" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK16_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK16_SECTION)" >>$@
	@echo "Version: $(ASTERISK16_VERSION)-$(ASTERISK16_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK16_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK16_SITE)/$(ASTERISK16_SOURCE)" >>$@
	@echo "Description: $(ASTERISK16_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK16_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK16_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK16_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk16/...
# Documentation files should be installed in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/doc/asterisk16/...
# Daemon startup scripts should be installed in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??asterisk16
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK16_IPK): $(ASTERISK16_BUILD_DIR)/.built
	rm -rf $(ASTERISK16_IPK_DIR) $(BUILD_DIR)/asterisk16_*_$(TARGET_ARCH).ipk
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_BUILD_DIR) DESTDIR=$(ASTERISK16_IPK_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK16_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK16_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK16_BUILD_DIR) DESTDIR=$(ASTERISK16_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#$(TARGET_PREFIX)/var/spool/asterisk#g' $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#$(TARGET_PREFIX)/var/lib/asterisk#g' $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/calls#$(TARGET_PREFIX)/var/calls#g' $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#$(TARGET_PREFIX)/sbin/streamplayer#g' $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#$(TARGET_PREFIX)$(TARGET_PREFIX)/#$(TARGET_PREFIX)/#g' $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*

	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_console.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_jingle.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_mgcp.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_skinny.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => format_ogg_vorbis.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_festival.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_amd.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => app_queue.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_ldap.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_sqlite.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_adaptive_odbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite3_custom.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf

	#cp -r $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/samples
	#mv $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/samples $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk

	$(MAKE) $(ASTERISK16_IPK_DIR)/CONTROL/control
	echo $(ASTERISK16_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK16_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/aelparse \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/astcanary \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/asterisk \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/conf2ael \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/hashtest \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/hashtest2 \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/muted \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/refcounter \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/smsq \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/stereorize \
			$(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/sbin/streamplayer ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK16_IPK_DIR)$(TARGET_PREFIX)/var/lib/asterisk/agi-bin/*test ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK16_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk16-ipk: $(ASTERISK16_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk16-clean:
	rm -f $(ASTERISK16_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK16_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk16-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK16_DIR) $(ASTERISK16_BUILD_DIR) $(ASTERISK16_IPK_DIR) $(ASTERISK16_IPK)
#
#
# Some sanity check for the package.
#
asterisk16-check: $(ASTERISK16_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK16_IPK)
