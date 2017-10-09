###########################################################
#
# net-snmp
#
###########################################################
#
# $Header$
#
NET_SNMP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/net-snmp
NET_SNMP_VERSION=5.7.3
NET_SNMP_SOURCE=net-snmp-$(NET_SNMP_VERSION).tar.gz
NET_SNMP_DIR=net-snmp-$(NET_SNMP_VERSION)
NET_SNMP_UNZIP=zcat
NET_SNMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NET_SNMP_DESCRIPTION=net-SNMP is a suite of applications used to implement SNMP v1, SNMP v2c and SNMP v3 using both IPv4 and IPv6
LIBNETSNMP_DESCRIPTION=SNMP main library
LIBNETSNMPAGENT_DESCRIPTION=SNMP agent library
LIBNETSNMPHELPERS_DESCRIPTION=SNMP helpers library
LIBNETSNMPMIBS_DESCRIPTION=SNMP MIBs library
LIBNETSNMPTRAPD_DESCRIPTION=SNMP trapd library
SNMP_MIBS_DESCRIPTION=SNMP MIBs modules
NET_SNMP_SECTION=net
NET_SNMP_PRIORITY=optional
NET_SNMP_DEPENDS=libnetsnmp, libnetsnmpagent, libnetsnmphelpers, libnetsnmpmibs, libnetsnmptrapd, openssl, libnl, snmp-mibs
LIBNETSNMP_DEPENDS=openssl
LIBNETSNMPAGENT_DEPENDS=libnetsnmp, libnl
LIBNETSNMPHELPERS_DEPENDS=
LIBNETSNMPMIBS_DEPENDS=libnetsnmpagent
LIBNETSNMPTRAPD_DEPENDS=libnetsnmpmibs
SNMP_MIBS_DEPENDS=
NET_SNMP_SUGGESTS=
NET_SNMP_CONFLICTS=

#
# NET_SNMP_IPK_VERSION should be incremented when the ipk changes.
#
NET_SNMP_IPK_VERSION=7

#
# NET_SNMP_CONFFILES should be a list of user-editable files
NET_SNMP_CONFFILES=$(TARGET_PREFIX)/etc/snmpd.conf $(TARGET_PREFIX)/etc/init.d/S70net-snmp

#
# NET_SNMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NET_SNMP_PATCHES=$(NET_SNMP_SOURCE_DIR)/SNMP_FREE-gcc4.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NET_SNMP_CPPFLAGS=
NET_SNMP_LDFLAGS=
ifeq ($(HOSTCC), $(TARGET_CC))
NET_SNMP_CROSS_CONFIG=
else
NET_SNMP_CROSS_CONFIG=$$WITH_ENDIANNESS
endif

#
# NET_SNMP_BUILD_DIR is the directory in which the build is done.
# NET_SNMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NET_SNMP_IPK_DIR is the directory in which the ipk is built.
# NET_SNMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NET_SNMP_BUILD_DIR=$(BUILD_DIR)/net-snmp
NET_SNMP_SOURCE_DIR=$(SOURCE_DIR)/net-snmp

NET_SNMP_IPK_DIR=$(BUILD_DIR)/net-snmp-$(NET_SNMP_VERSION)-ipk
NET_SNMP_IPK=$(BUILD_DIR)/net-snmp_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBNETSNMP_IPK_DIR=$(BUILD_DIR)/libnetsnmp-$(NET_SNMP_VERSION)-ipk
LIBNETSNMP_IPK=$(BUILD_DIR)/libnetsnmp_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBNETSNMPAGENT_IPK_DIR=$(BUILD_DIR)/libnetsnmpagent-$(NET_SNMP_VERSION)-ipk
LIBNETSNMPAGENT_IPK=$(BUILD_DIR)/libnetsnmpagent_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBNETSNMPHELPERS_IPK_DIR=$(BUILD_DIR)/libnetsnmphelpers-$(NET_SNMP_VERSION)-ipk
LIBNETSNMPHELPERS_IPK=$(BUILD_DIR)/libnetsnmphelpers_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBNETSNMPMIBS_IPK_DIR=$(BUILD_DIR)/libnetsnmpmibs-$(NET_SNMP_VERSION)-ipk
LIBNETSNMPMIBS_IPK=$(BUILD_DIR)/libnetsnmpmibs_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBNETSNMPTRAPD_IPK_DIR=$(BUILD_DIR)/libnetsnmptrapd-$(NET_SNMP_VERSION)-ipk
LIBNETSNMPTRAPD_IPK=$(BUILD_DIR)/libnetsnmptrapd_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

SNMP_MIBS_IPK_DIR=$(BUILD_DIR)/snmp-mibs-$(NET_SNMP_VERSION)-ipk
SNMP_MIBS_IPK=$(BUILD_DIR)/snmp-mibs_$(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

NET_SNMP_IPKS=$(NET_SNMP_IPK) $(SNMP_MIBS_IPK) $(LIBNETSNMP_IPK) $(LIBNETSNMPAGENT_IPK) \
		$(LIBNETSNMPHELPERS_IPK) $(LIBNETSNMPMIBS_IPK) $(LIBNETSNMPTRAPD_IPK)

NET_SNMP_IPK_DIRS=$(NET_SNMP_IPK_DIR) $(SNMP_MIBS_IPK_DIR) $(LIBNETSNMP_IPK_DIR) $(LIBNETSNMPAGENT_IPK_DIR) \
	$(LIBNETSNMPHELPERS_IPK_DIR) $(LIBNETSNMPMIBS_IPK_DIR) $(LIBNETSNMPTRAPD_IPK_DIR)

NET_SNMP_IPKS_WILDCARD=$(BUILD_DIR)/net-snmp_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/snmp-mibs_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/libnetsnmp_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/libnetsnmpagent_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/libnetsnmphelpers_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/libnetsnmpmibs_*_$(TARGET_ARCH).ipk \
			$(BUILD_DIR)/libnetsnmptrapd_*_$(TARGET_ARCH).ipk

.PHONY: net-snmp-source net-snmp-unpack net-snmp net-snmp-stage net-snmp-ipk net-snmp-clean net-snmp-dirclean net-snmp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NET_SNMP_SOURCE):
	$(WGET) -P $(@D) $(NET_SNMP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
net-snmp-source: $(DL_DIR)/$(NET_SNMP_SOURCE) $(NET_SNMP_PATCHES)

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
$(NET_SNMP_BUILD_DIR)/.configured: $(DL_DIR)/$(NET_SNMP_SOURCE) $(NET_SNMP_PATCHES) make/net-snmp.mk
	$(MAKE) openssl-stage libnl-stage
	rm -rf $(BUILD_DIR)/$(NET_SNMP_DIR) $(@D)
	$(NET_SNMP_UNZIP) $(DL_DIR)/$(NET_SNMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NET_SNMP_PATCHES)"; then \
		cat $(NET_SNMP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(NET_SNMP_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(NET_SNMP_DIR) $(@D)
	(cd $(@D); \
		if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
		then WITH_ENDIANNESS="--with-endianness=big"; \
		else WITH_ENDIANNESS="--with-endianness=little"; fi; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NET_SNMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NET_SNMP_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		PKG_CONFIG_LIBDIR=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		$(NET_SNMP_CROSS_CONFIG) \
		--disable-embedded-perl \
		--without-perl-modules \
		--with-default-snmp-version=3 \
		--with-sys-contact=root@localhost \
		--with-sys-location="(Unknown)" \
		--with-logfile=$(TARGET_PREFIX)/var/log/snmpd.log \
		--with-persistent-directory=$(TARGET_PREFIX)/var/net-snmp \
	)
	touch $@

net-snmp-unpack: $(NET_SNMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NET_SNMP_BUILD_DIR)/.built: $(NET_SNMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	# missing some built libs workaround
	rm -f $(@D)/agent/*.la
	$(MAKE) -C $(@D)/agent
	$(MAKE) -C $(@D)/apps
	touch $@

#
# This is the build convenience target.
#
net-snmp: $(NET_SNMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NET_SNMP_BUILD_DIR)/.staged: $(NET_SNMP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

net-snmp-stage: $(NET_SNMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/net-snmp
#
$(NET_SNMP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: net-snmp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: $(NET_SNMP_SECTION)" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(NET_SNMP_DESCRIPTION)" >>$@
	@echo "Depends: $(NET_SNMP_DEPENDS)" >>$@
	@echo "Suggests: $(NET_SNMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NET_SNMP_CONFLICTS)" >>$@

$(SNMP_MIBS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: snmp-mibs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: $(NET_SNMP_SECTION)" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(SNMP_MIBS_DESCRIPTION)" >>$@
	@echo "Depends: $(SNMP_MIBS_DEPENDS)" >>$@
	@echo "Suggests: $(SNMP_MIBS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SNMP_MIBS_CONFLICTS)" >>$@

$(LIBNETSNMP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetsnmp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(LIBNETSNMP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETSNMP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETSNMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETSNMP_CONFLICTS)" >>$@

$(LIBNETSNMPAGENT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetsnmpagent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(LIBNETSNMPAGENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETSNMPAGENT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETSNMPAGENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETSNMPAGENT_CONFLICTS)" >>$@

$(LIBNETSNMPHELPERS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetsnmphelpers" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(LIBNETSNMPHELPERS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETSNMPHELPERS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETSNMPHELPERS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETSNMPHELPERS_CONFLICTS)" >>$@

$(LIBNETSNMPMIBS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetsnmpmibs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(LIBNETSNMPMIBS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETSNMPMIBS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETSNMPMIBS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETSNMPMIBS_CONFLICTS)" >>$@

$(LIBNETSNMPTRAPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetsnmptrapd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET_SNMP_PRIORITY)" >>$@
	@echo "Section: lib" >>$@
	@echo "Version: $(NET_SNMP_VERSION)-$(NET_SNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET_SNMP_MAINTAINER)" >>$@
	@echo "Source: $(NET_SNMP_SITE)/$(NET_SNMP_SOURCE)" >>$@
	@echo "Description: $(LIBNETSNMPTRAPD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETSNMPTRAPD_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETSNMPTRAPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETSNMPTRAPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/net-snmp/...
# Documentation files should be installed in $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/doc/net-snmp/...
# Daemon startup scripts should be installed in $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??net-snmp
#
# You may need to patch your application to make it use these locations.
#
$(NET_SNMP_IPKS): $(NET_SNMP_BUILD_DIR)/.built
	rm -rf $(NET_SNMP_IPK_DIRS) $(NET_SNMP_IPKS_WILDCARD)
	$(MAKE) -C $(NET_SNMP_BUILD_DIR) INSTALL_PREFIX=$(NET_SNMP_IPK_DIR) install
	for F in $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/bin/* ; do (file $$F |fgrep -vq ELF) || $(STRIP_COMMAND) $$F ; done
	$(STRIP_COMMAND) $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(STRIP_COMMAND) $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	sed -i -e 's|$(TARGET_CC)|$(TARGET_PREFIX)/bin/gcc|g' -e 's|$(STAGING_PREFIX)|$(TARGET_PREFIX)|g' \
		$(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/bin/{net-snmp-config,net-snmp-create-v3-user}
	$(INSTALL) -d $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 644 $(NET_SNMP_SOURCE_DIR)/snmpd.conf $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/snmpd.conf
	$(INSTALL) -d $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(NET_SNMP_SOURCE_DIR)/rc.net-snmp $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S70net-snmp
	# package libnetsnmp
	$(INSTALL) -d $(LIBNETSNMP_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/libnetsnmp.so* $(LIBNETSNMP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBNETSNMP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETSNMP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNETSNMP_IPK_DIR)
	# package libnetsnmpagent
	$(INSTALL) -d $(LIBNETSNMPAGENT_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/libnetsnmpagent.so* $(LIBNETSNMPAGENT_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBNETSNMPAGENT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETSNMPAGENT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNETSNMPAGENT_IPK_DIR)
	# package libnetsnmphelpers
	$(INSTALL) -d $(LIBNETSNMPHELPERS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/libnetsnmphelpers.so* $(LIBNETSNMPHELPERS_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBNETSNMPHELPERS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETSNMPHELPERS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNETSNMPHELPERS_IPK_DIR)
	# package libnetsnmpmibs
	$(INSTALL) -d $(LIBNETSNMPMIBS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/libnetsnmpmibs.so* $(LIBNETSNMPMIBS_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBNETSNMPMIBS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETSNMPMIBS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNETSNMPMIBS_IPK_DIR)
	# package libnetsnmptrapd
	$(INSTALL) -d $(LIBNETSNMPTRAPD_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/libnetsnmptrapd.so* $(LIBNETSNMPTRAPD_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBNETSNMPTRAPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETSNMPTRAPD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNETSNMPTRAPD_IPK_DIR)
	# package snmp-mibs
	$(INSTALL) -d $(SNMP_MIBS_IPK_DIR)$(TARGET_PREFIX)/share/snmp
	mv -f $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/share/snmp/mibs $(SNMP_MIBS_IPK_DIR)$(TARGET_PREFIX)/share/snmp
	$(MAKE) $(SNMP_MIBS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SNMP_MIBS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SNMP_MIBS_IPK_DIR)
	# finally, package net-snmp
	rm -rf $(NET_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(NET_SNMP_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(NET_SNMP_SOURCE_DIR)/postinst $(NET_SNMP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(NET_SNMP_SOURCE_DIR)/prerm $(NET_SNMP_IPK_DIR)/CONTROL/prerm
	echo $(NET_SNMP_CONFFILES) | sed -e 's/ /\n/g' > $(NET_SNMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NET_SNMP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NET_SNMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
net-snmp-ipk: $(NET_SNMP_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
net-snmp-clean:
	-$(MAKE) -C $(NET_SNMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
net-snmp-dirclean:
	rm -rf $(BUILD_DIR)/$(NET_SNMP_DIR) $(NET_SNMP_BUILD_DIR) $(NET_SNMP_IPK_DIRS) $(NET_SNMP_IPKS)

#
# Some sanity check for the package.
#
net-snmp-check: $(NET_SNMP_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
