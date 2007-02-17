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
#ASTERISK14_SOURCE_TYPE=tarball
ASTERISK14_SOURCE_TYPE=svn

ASTERISK14_SITE=http://ftp.digium.com/pub/asterisk/releases
ASTERISK14_BASE_VERSION=1.4.0

ifeq ($(ASTERISK14_SOURCE_TYPE), svn)
ASTERISK14_SVN=http://svn.digium.com/svn/asterisk/branches/1.4
ASTERISK14_SVN_REV=55196
ASTERISK14_VERSION=$(ASTERISK14_BASE_VERSION)svn-r$(ASTERISK14_SVN_REV)
else
ASTERISK14_VERSION=$(ASTERISK14_BASE_VERSION)
endif

ASTERISK14_SOURCE=asterisk-$(ASTERISK14_VERSION).tar.gz
ASTERISK14_DIR=asterisk-$(ASTERISK14_VERSION)
ASTERISK14_UNZIP=zcat
ASTERISK14_MAINTAINER=Ovidiu Sas <sip.nslu@gmail.com>
ASTERISK14_DESCRIPTION=Asterisk is an Open Source PBX and telephony toolkit.
ASTERISK14_SECTION=util
ASTERISK14_PRIORITY=optional
ASTERISK14_DEPENDS=openssl,ncurses,libcurl,zlib,termcap,libstdc++,popt
ASTERISK14_SUGGESTS=\
asterisk14-chan-capi,\
asterisk14-core-sounds-en-ulaw,\
asterisk14-extra-sounds-en-gsm,\
asterisk14-extra-sounds-en-ulaw,\
asterisk14-gui,\
freetds,\
iksemel,\
libogg,\
net-snmp,\
radiusclient-ng,\
sqlite2,\
unixodbc
ASTERISK14_CONFLICTS=asterisk,asterisk-sounds,asterisk-chan-capi


#
# ASTERISK14_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14_IPK_VERSION=1

#
# ASTERISK14_CONFFILES should be a list of user-editable files
#ASTERISK14_CONFFILES=/opt/etc/asterisk14.conf /opt/etc/init.d/SXXasterisk14
ASTERISK14_CONFFILES=\
/opt/etc/asterisk/adsi.conf \
/opt/etc/asterisk/adtranvofr.conf \
/opt/etc/asterisk/agents.conf \
/opt/etc/asterisk/alarmreceiver.conf \
/opt/etc/asterisk/alsa.conf \
/opt/etc/asterisk/amd.conf \
/opt/etc/asterisk/asterisk.adsi \
/opt/etc/asterisk/asterisk.conf \
/opt/etc/asterisk/cdr.conf \
/opt/etc/asterisk/cdr_custom.conf \
/opt/etc/asterisk/cdr_manager.conf \
/opt/etc/asterisk/cdr_odbc.conf \
/opt/etc/asterisk/cdr_pgsql.conf \
/opt/etc/asterisk/cdr_tds.conf \
/opt/etc/asterisk/codecs.conf \
/opt/etc/asterisk/dnsmgr.conf \
/opt/etc/asterisk/dundi.conf \
/opt/etc/asterisk/enum.conf \
/opt/etc/asterisk/extconfig.conf \
/opt/etc/asterisk/extensions.ael \
/opt/etc/asterisk/extensions.conf \
/opt/etc/asterisk/features.conf \
/opt/etc/asterisk/festival.conf \
/opt/etc/asterisk/followme.conf \
/opt/etc/asterisk/func_odbc.conf \
/opt/etc/asterisk/gtalk.conf \
/opt/etc/asterisk/h323.conf \
/opt/etc/asterisk/http.conf \
/opt/etc/asterisk/iax.conf \
/opt/etc/asterisk/iaxprov.conf \
/opt/etc/asterisk/indications.conf \
/opt/etc/asterisk/jabber.conf \
/opt/etc/asterisk/logger.conf \
/opt/etc/asterisk/manager.conf \
/opt/etc/asterisk/meetme.conf \
/opt/etc/asterisk/mgcp.conf \
/opt/etc/asterisk/misdn.conf \
/opt/etc/asterisk/modem.conf \
/opt/etc/asterisk/modules.conf \
/opt/etc/asterisk/musiconhold.conf \
/opt/etc/asterisk/muted.conf \
/opt/etc/asterisk/osp.conf \
/opt/etc/asterisk/oss.conf \
/opt/etc/asterisk/phone.conf \
/opt/etc/asterisk/privacy.conf \
/opt/etc/asterisk/queues.conf \
/opt/etc/asterisk/res_odbc.conf \
/opt/etc/asterisk/res_snmp.conf \
/opt/etc/asterisk/rpt.conf \
/opt/etc/asterisk/rtp.conf \
/opt/etc/asterisk/say.conf \
/opt/etc/asterisk/sip.conf \
/opt/etc/asterisk/sip_notify.conf \
/opt/etc/asterisk/skinny.conf \
/opt/etc/asterisk/sla.conf \
/opt/etc/asterisk/smdi.conf \
/opt/etc/asterisk/telcordia-1.adsi \
/opt/etc/asterisk/udptl.conf \
/opt/etc/asterisk/users.conf \
/opt/etc/asterisk/voicemail.conf \
/opt/etc/asterisk/vpb.conf \
/opt/etc/asterisk/zapata.conf


#
# ASTERISK14_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK14_PATCHES=$(ASTERISK14_SOURCE_DIR)/main-db1-ast-Makefile.patch $(ASTERISK14_SOURCE_DIR)/gsm.patch
ASTERISK14_PATCHES=$(ASTERISK14_SOURCE_DIR)/nv.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET), slugosbe)
ASTERISK14_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR) -DPATH_MAX=4096
else
ASTERISK14_CPPFLAGS=-fsigned-char -I$(STAGING_INCLUDE_DIR)
endif
ASTERISK14_LDFLAGS=

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
		tar -czf $@ --exclude=.svn $(ASTERISK14_DIR) && \
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
	$(MAKE) iksemel-stage gnutls-stage radiusclient-ng-stage unixodbc-stage popt-stage net-snmp-stage
	$(MAKE) sqlite2-stage freetds-stage libogg-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR)
	$(ASTERISK14_UNZIP) $(DL_DIR)/$(ASTERISK14_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK14_PATCHES)" ; \
		then cat $(ASTERISK14_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK14_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14_DIR)" != "$(ASTERISK14_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14_DIR) $(ASTERISK14_BUILD_DIR) ; \
	fi
	(cd $(ASTERISK14_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$(PATH)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-pwlib \
		--with-ssl=$(STAGING_PREFIX) \
		--with-z=$(STAGING_PREFIX) \
		--with-termcap=$(STAGING_PREFIX) \
		--with-curl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-popt=$(STAGING_PREFIX) \
		--with-tds=$(STAGING_PREFIX) \
		--with-sqlite=$(STAGING_PREFIX) \
		--without-postgres \
		--with-iksemel=$(STAGING_PREFIX) \
		--with-gnutls=$(STAGING_PREFIX) \
		--with-radius=$(STAGING_PREFIX) \
		--with-odbc=$(STAGING_PREFIX) \
		--with-netsnmp=$(STAGING_PREFIX) \
		--without-imap \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)
	#sed -i -e '/GSM_.*+=.*k6opt/s|^|#|' $(ASTERISK14_BUILD_DIR)/codecs/gsm/Makefile
	touch $(ASTERISK14_BUILD_DIR)/.configured

asterisk14-unpack: $(ASTERISK14_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14_BUILD_DIR)/.built: $(ASTERISK14_BUILD_DIR)/.configured
	rm -f $(ASTERISK14_BUILD_DIR)/.built
	NOISY_BUILD=yes \
	ASTCFLAGS="$(ASTERISK14_CPPFLAGS)" \
	ASTLDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR)
	touch $(ASTERISK14_BUILD_DIR)/.built

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
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(STAGING_DIR) ASTSBINDIR=/opt/sbin install
	touch $(ASTERISK14_BUILD_DIR)/.staged

asterisk14-stage: $(ASTERISK14_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14
#
$(ASTERISK14_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
# Binaries should be installed into $(ASTERISK14_IPK_DIR)/opt/sbin or $(ASTERISK14_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK14_IPK_DIR)/opt/etc/asterisk14/...
# Documentation files should be installed in $(ASTERISK14_IPK_DIR)/opt/doc/asterisk14/...
# Daemon startup scripts should be installed in $(ASTERISK14_IPK_DIR)/opt/etc/init.d/S??asterisk14
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14_IPK): $(ASTERISK14_BUILD_DIR)/.built
	rm -rf $(ASTERISK14_IPK_DIR) $(BUILD_DIR)/asterisk14_*_$(TARGET_ARCH).ipk
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) ASTSBINDIR=/opt/sbin install
	NOISY_BUILD=yes \
	$(MAKE) -C $(ASTERISK14_BUILD_DIR) DESTDIR=$(ASTERISK14_IPK_DIR) samples

	sed -i -e 's#/var/spool/asterisk#/opt/var/spool/asterisk#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/lib/asterisk#/opt/var/lib/asterisk#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/var/calls#/opt/var/calls#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/usr/bin/streamplayer#/opt/sbin/streamplayer#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/*
	sed -i -e 's#/opt/opt/#/opt/#g' $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/*

	echo "" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => func_odbc.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_alsa.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_gtalk.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => chan_oss.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_ilbc.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_lpc10.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => codec_speex.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_config_odbc.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_jabber.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_odbc.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_snmp.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => res_smdi.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_odbc.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_radius.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_sqlite.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf
	echo "noload => cdr_tds.so" >> $(ASTERISK14_IPK_DIR)/opt/etc/asterisk/modules.conf

	cp -r $(ASTERISK14_IPK_DIR)/opt/etc/asterisk $(ASTERISK14_IPK_DIR)/opt/etc/samples
	mv $(ASTERISK14_IPK_DIR)/opt/etc/samples $(ASTERISK14_IPK_DIR)/opt/etc/asterisk

	$(MAKE) $(ASTERISK14_IPK_DIR)/CONTROL/control
	echo $(ASTERISK14_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK14_IPK_DIR)/CONTROL/conffiles

	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/lib/asterisk/modules/*.so ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/sbin/aelparse \
			$(ASTERISK14_IPK_DIR)/opt/sbin/asterisk \
			$(ASTERISK14_IPK_DIR)/opt/sbin/muted \
			$(ASTERISK14_IPK_DIR)/opt/sbin/smsq \
			$(ASTERISK14_IPK_DIR)/opt/sbin/stereorize \
			$(ASTERISK14_IPK_DIR)/opt/sbin/streamplayer ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	for filetostrip in $(ASTERISK14_IPK_DIR)/opt/var/lib/asterisk/agi-bin/*test ; do \
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
