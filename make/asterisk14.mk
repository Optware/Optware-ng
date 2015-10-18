###########################################################
#
# asterisk14
#
###########################################################
#
# ASTERISK14_VERSION, ASTERISK14_SITE and ASTERISK14_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK14_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK14_UNZIP is the command used to unzip the source.
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
ASTERISK14_SOURCE_TYPE=tarball
#ASTERISK14_SOURCE_TYPE=svn

ASTERISK14_SITE=http://downloads.digium.com/pub/asterisk/releases
ASTERISK14_BASE_VERSION=1.4.22.1

ifeq ($(ASTERISK14_SOURCE_TYPE), svn)
ASTERISK14_SVN=http://svn.digium.com/svn/asterisk/branches/1.4
ASTERISK14_SVN_REV=108288
ASTERISK14_VERSION=$(ASTERISK14_BASE_VERSION)svn-r$(ASTERISK14_SVN_REV)
else
ASTERISK14_VERSION=$(ASTERISK14_BASE_VERSION)
endif

ASTERISK14_SOURCE=asterisk-$(ASTERISK14_VERSION).tar.gz
ASTERISK14_DIR=asterisk-$(ASTERISK14_VERSION)
ASTERISK14_UNZIP=zcat
ASTERISK14_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
ASTERISK14_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK14_SECTION=util
ASTERISK14_PRIORITY=optional
ASTERISK14_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++,popt
ASTERISK14_SUGGESTS=\
asterisk14-chan-capi,\
asterisk14-core-sounds-en-alaw,\
asterisk14-core-sounds-en-g729,\
asterisk14-core-sounds-en-gsm,\
asterisk14-core-sounds-en-ulaw,\
asterisk14-extra-sounds-en-alaw,\
asterisk14-extra-sounds-en-g729,\
asterisk14-extra-sounds-en-gsm,\
asterisk14-extra-sounds-en-ulaw,\
asterisk14-moh-freeplay-alaw,\
asterisk14-moh-freeplay-g729,\
asterisk14-moh-freeplay-gsm,\
asterisk14-moh-freeplay-ulaw,\
asterisk14-gui\
,libogg\
,radiusclient-ng\
,sqlite2\
,unixodbc

ifneq (, $(filter jabberd, $(PACKAGES)))
ASTERISK14_SUGGESTS +=,jabberd
endif
ifneq (, $(filter iksemel, $(PACKAGES)))
ASTERISK14_SUGGESTS +=,iksemel
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
ASTERISK16_SUGGESTS +=,gtk2
endif
ifneq (, $(filter net-snmp, $(PACKAGES)))
ASTERISK14_SUGGESTS +=,net-snmp
endif

ASTERISK14_CONFLICTS=asterisk,asterisk16,asterisk-sounds,asterisk-chan-capi


#
# ASTERISK14_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14_IPK_VERSION=1

#
# ASTERISK14_CONFFILES should be a list of user-editable files
#ASTERISK14_CONFFILES=$(TARGET_PREFIX)/etc/asterisk14.conf $(TARGET_PREFIX)/etc/init.d/SXXasterisk14
ASTERISK14_CONFFILES=\
$(TARGET_PREFIX)/etc/asterisk/adsi.conf \
$(TARGET_PREFIX)/etc/asterisk/adtranvofr.conf \
$(TARGET_PREFIX)/etc/asterisk/agents.conf \
$(TARGET_PREFIX)/etc/asterisk/alarmreceiver.conf \
$(TARGET_PREFIX)/etc/asterisk/alsa.conf \
$(TARGET_PREFIX)/etc/asterisk/amd.conf \
$(TARGET_PREFIX)/etc/asterisk/asterisk.adsi \
$(TARGET_PREFIX)/etc/asterisk/asterisk.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_custom.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_manager.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_odbc.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_pgsql.conf \
$(TARGET_PREFIX)/etc/asterisk/cdr_tds.conf \
$(TARGET_PREFIX)/etc/asterisk/codecs.conf \
$(TARGET_PREFIX)/etc/asterisk/dnsmgr.conf \
$(TARGET_PREFIX)/etc/asterisk/dundi.conf \
$(TARGET_PREFIX)/etc/asterisk/enum.conf \
$(TARGET_PREFIX)/etc/asterisk/extconfig.conf \
$(TARGET_PREFIX)/etc/asterisk/extensions.ael \
$(TARGET_PREFIX)/etc/asterisk/extensions.conf \
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
$(TARGET_PREFIX)/etc/asterisk/logger.conf \
$(TARGET_PREFIX)/etc/asterisk/manager.conf \
$(TARGET_PREFIX)/etc/asterisk/meetme.conf \
$(TARGET_PREFIX)/etc/asterisk/mgcp.conf \
$(TARGET_PREFIX)/etc/asterisk/misdn.conf \
$(TARGET_PREFIX)/etc/asterisk/modules.conf \
$(TARGET_PREFIX)/etc/asterisk/musiconhold.conf \
$(TARGET_PREFIX)/etc/asterisk/muted.conf \
$(TARGET_PREFIX)/etc/asterisk/osp.conf \
$(TARGET_PREFIX)/etc/asterisk/oss.conf \
$(TARGET_PREFIX)/etc/asterisk/phone.conf \
$(TARGET_PREFIX)/etc/asterisk/privacy.conf \
$(TARGET_PREFIX)/etc/asterisk/queues.conf \
$(TARGET_PREFIX)/etc/asterisk/res_odbc.conf \
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
$(TARGET_PREFIX)/etc/asterisk/users.conf \
$(TARGET_PREFIX)/etc/asterisk/voicemail.conf \
$(TARGET_PREFIX)/etc/asterisk/vpb.conf


#
# ASTERISK14_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK14_PATCHES=$(ASTERISK14_SOURCE_DIR)/main-db1-ast-Makefile.patch $(ASTERISK14_SOURCE_DIR)/gsm.patch
ASTERISK14_PATCHES=$(ASTERISK14_SOURCE_DIR)/nv.patch\
	$(ASTERISK14_SOURCE_DIR)/app_notify_2.0rc1.patch\
	$(ASTERISK14_SOURCE_DIR)/sounds.xml.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK14_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR)
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
ASTERISK14_CPPFLAGS+= -DPATH_MAX=4096
endif
ASTERISK14_LDFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter angstrombe angstromle cs05q3armel cs08q1armel syno-e500, $(OPTWARE_TARGET)))
ASTERISK14_LDFLAGS+=-lpthread -ldl -lresolv
endif

ASTERISK14_CONFIGURE_OPTS=
ifneq (, $(filter gnutls, $(PACKAGES)))
ASTERISK14_CONFIGURE_OPTS += --with-gnutls=$(STAGING_PREFIX)
else
ASTERISK14_CONFIGURE_OPTS += --without-gnutls
endif
ifneq (, $(filter iksemel, $(PACKAGES)))
ASTERISK14_CONFIGURE_OPTS += --with-iksemel=$(STAGING_PREFIX)
else
ASTERISK14_CONFIGURE_OPTS += --without-iksemel
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
ASTERISK16_CONFIGURE_OPTS += --with-gtk2=$(STAGING_PREFIX)
else
ASTERISK16_CONFIGURE_OPTS += --without-gtk2
endif
ifneq (, $(filter net-snmp, $(PACKAGES)))
ASTERISK14_CONFIGURE_OPTS += --with-netsnmp=$(STAGING_PREFIX)
else
ASTERISK14_CONFIGURE_OPTS += --without-netsnmp
endif

#
# ASTERISK14_BUILD_DIR is the directory in which the build is done.
# ASTERISK14_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK14_IPK_DIR is the directory in which the ipk is built.
# ASTERISK14_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK14_BUILD_DIR=$(BUILD_DIR)/asterisk14
ASTERISK14_SOURCE_DIR=$(SOURCE_DIR)/asterisk14
ASTERISK14_IPK_DIR=$(BUILD_DIR)/asterisk14-$(ASTERISK14_VERSION)-ipk
ASTERISK14_IPK=$(BUILD_DIR)/asterisk14_$(ASTERISK14_VERSION)-$(ASTERISK14_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk14-source asterisk14-unpack asterisk14 asterisk14-stage asterisk14-ipk asterisk14-clean asterisk14-dirclean asterisk14-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK14_SOURCE):
ifeq ($(ASTERISK14_SOURCE_TYPE), svn)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK14_DIR) && \
		svn co -r $(ASTERISK14_SVN_REV) $(ASTERISK14_SVN) \
			$(ASTERISK14_DIR) && \
		tar -czf $@ $(ASTERISK14_DIR) && \
		rm -rf $(ASTERISK14_DIR) \
	)
else
	$(WGET) -P $(DL_DIR) $(ASTERISK14_SITE)/$(ASTERISK14_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk14-source: $(DL_DIR)/$(ASTERISK14_SOURCE) $(ASTERISK14_PATCHES)

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
$(ASTERISK14_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK14_SOURCE) $(ASTERISK14_PATCHES) make/asterisk14.mk
	$(MAKE) ncurses-stage openssl-stage libcurl-stage zlib-stage termcap-stage libstdc++-stage
ifneq (, $(filter jabberd, $(PACKAGES)))
	$(MAKE) jabberd-stage
endif
ifneq (, $(filter iksemel, $(PACKAGES)))
	$(MAKE) iksemel-stage
endif
ifeq (gtk2, $(filter gtk2, $(PACKAGES)))
	$(MAKE) gtk2-stage
endif
ifneq (, $(filter net-snmp, $(PACKAGES)))
	$(MAKE) net-snmp-stage
endif
	$(MAKE) radiusclient-ng-stage unixodbc-stage popt-stage
	$(MAKE) sqlite2-stage libogg-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR)
	$(ASTERISK14_UNZIP) $(DL_DIR)/$(ASTERISK14_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK14_PATCHES)" ; \
		then cat $(ASTERISK14_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ASTERISK14_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14_DIR)" != "$(ASTERISK14_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e '/-pipe/s/^/#/' $(@D)/Makefile
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
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
		--without-pwlib \
		--with-ssl=$(STAGING_PREFIX) \
		--with-z=$(STAGING_PREFIX) \
		--with-termcap=$(STAGING_PREFIX) \
		--with-curl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-popt=$(STAGING_PREFIX) \
		--without-tds \
		--with-sqlite=$(STAGING_PREFIX) \
		--without-postgres \
		--with-radius=$(STAGING_PREFIX) \
		--with-odbc=$(STAGING_PREFIX) \
		--without-imap \
		$(ASTERISK14_CONFIGURE_OPTS) \
		--localstatedir=$(TARGET_PREFIX)/var \
		--sysconfdir=$(TARGET_PREFIX)/etc \
	)
	touch $@

asterisk14-unpack: $(ASTERISK14_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14_BUILD_DIR)/.built: $(ASTERISK14_BUILD_DIR)/.configured
	rm -f $@
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK14_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
asterisk14: $(ASTERISK14_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK14_BUILD_DIR)/.staged: $(ASTERISK14_BUILD_DIR)/.built
	rm -f $(ASTERISK14_BUILD_DIR)/.staged
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK14_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install
	touch $(ASTERISK14_BUILD_DIR)/.staged

asterisk14-stage: $(ASTERISK14_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14
#
$(ASTERISK14_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: asterisk14" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK14_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK14_SECTION)" >>$@
	@echo "Version: $(ASTERISK14_VERSION)-$(ASTERISK14_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK14_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK14_SITE)/$(ASTERISK14_SOURCE)" >>$@
	@echo "Description: $(ASTERISK14_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK14_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK14_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK14_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk14/...
# Documentation files should be installed in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/doc/asterisk14/...
# Daemon startup scripts should be installed in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??asterisk14
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14_IPK): $(ASTERISK14_BUILD_DIR)/.built
	rm -rf $(ASTERISK14_IPK_DIR) $(BUILD_DIR)/asterisk14_*_$(TARGET_ARCH).ipk
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) ASTSBINDIR=$(TARGET_PREFIX)/sbin install
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#$(TARGET_PREFIX)/var/spool/asterisk#g' $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#$(TARGET_PREFIX)/var/lib/asterisk#g' $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/var/calls#$(TARGET_PREFIX)/var/calls#g' $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#$(TARGET_PREFIX)/sbin/streamplayer#g' $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*
	sed -i -e 's#$(TARGET_PREFIX)$(TARGET_PREFIX)/#$(TARGET_PREFIX)/#g' $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/*

	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => format_ogg_vorbis.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk/modules.conf

	cp -r $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/samples
	mv $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/samples $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/etc/asterisk

	$(MAKE) $(ASTERISK14_IPK_DIR)/CONTROL/control
	echo $(ASTERISK14_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK14_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/aelparse \
			$(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/asterisk \
			$(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/muted \
			$(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/smsq \
			$(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/stereorize \
			$(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/sbin/streamplayer ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)$(TARGET_PREFIX)/var/lib/asterisk/agi-bin/*test ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done

	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK14_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk14-ipk: $(ASTERISK14_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk14-clean:
	rm -f $(ASTERISK14_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK14_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk14-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR) $(ASTERISK14_IPK_DIR) $(ASTERISK14_IPK)
#
#
# Some sanity check for the package.
#
asterisk14-check: $(ASTERISK14_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK14_IPK)
