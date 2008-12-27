###########################################################
#
# net-snmp
#
###########################################################
#
# $Header$
#
NET_SNMP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/net-snmp
NET_SNMP_VERSION=5.4.2.1
NET_SNMP_SOURCE=net-snmp-$(NET_SNMP_VERSION).tar.gz
NET_SNMP_DIR=net-snmp-$(NET_SNMP_VERSION)
NET_SNMP_UNZIP=zcat
NET_SNMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NET_SNMP_DESCRIPTION=net-SNMP is a suite of applications used to implement SNMP v1, SNMP v2c and SNMP v3 using both IPv4 and IPv6
NET_SNMP_SECTION=net
NET_SNMP_PRIORITY=optional
NET_SNMP_DEPENDS=openssl
NET_SNMP_SUGGESTS=
NET_SNMP_CONFLICTS=

#
# NET_SNMP_IPK_VERSION should be incremented when the ipk changes.
#
NET_SNMP_IPK_VERSION=1

#
# NET_SNMP_CONFFILES should be a list of user-editable files
NET_SNMP_CONFFILES=/opt/etc/snmpd.conf /opt/etc/init.d/S70net-snmp

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
$(NET_SNMP_BUILD_DIR)/.configured: $(DL_DIR)/$(NET_SNMP_SOURCE) $(NET_SNMP_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(NET_SNMP_DIR) $(@D)
	$(NET_SNMP_UNZIP) $(DL_DIR)/$(NET_SNMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NET_SNMP_PATCHES)"; then \
		cat $(NET_SNMP_PATCHES) | patch -d $(BUILD_DIR)/$(NET_SNMP_DIR) -p0; \
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
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		$(NET_SNMP_CROSS_CONFIG) \
		--disable-embedded-perl \
		--without-perl-modules \
		--with-default-snmp-version=3 \
		--with-sys-contact=root@localhost \
		--with-sys-location="(Unknown)" \
		--with-logfile=/opt/var/log/snmpd.log \
		--with-persistent-directory=/opt/var/net-snmp \
	)
ifeq ($(OPTWARE_TARGET), $(filter syno-x07, $(OPTWARE_TARGET)))
	sed -i -e 's/#if HAVE_NETINET_IF_ETHER_H/#if 0/' \
		$(@D)/agent/mibgroup/mibII/at.c \
		$(@D)/agent/mibgroup/mibII/interfaces.c
endif
	touch $@

net-snmp-unpack: $(NET_SNMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NET_SNMP_BUILD_DIR)/.built: $(NET_SNMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
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
	@install -d $(@D)
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(NET_SNMP_IPK_DIR)/opt/sbin or $(NET_SNMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NET_SNMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NET_SNMP_IPK_DIR)/opt/etc/net-snmp/...
# Documentation files should be installed in $(NET_SNMP_IPK_DIR)/opt/doc/net-snmp/...
# Daemon startup scripts should be installed in $(NET_SNMP_IPK_DIR)/opt/etc/init.d/S??net-snmp
#
# You may need to patch your application to make it use these locations.
#
$(NET_SNMP_IPK): $(NET_SNMP_BUILD_DIR)/.built
	rm -rf $(NET_SNMP_IPK_DIR) $(BUILD_DIR)/net-snmp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NET_SNMP_BUILD_DIR) INSTALL_PREFIX=$(NET_SNMP_IPK_DIR) install
	for F in $(NET_SNMP_IPK_DIR)/opt/bin/* ; do (file $$F |fgrep -vq ELF) || $(STRIP_COMMAND) $$F ; done
	$(STRIP_COMMAND) $(NET_SNMP_IPK_DIR)/opt/sbin/*
	$(STRIP_COMMAND) $(NET_SNMP_IPK_DIR)/opt/lib/*.so
	install -d $(NET_SNMP_IPK_DIR)/opt/etc/
	install -m 644 $(NET_SNMP_SOURCE_DIR)/snmpd.conf $(NET_SNMP_IPK_DIR)/opt/etc/snmpd.conf
	install -d $(NET_SNMP_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NET_SNMP_SOURCE_DIR)/rc.net-snmp $(NET_SNMP_IPK_DIR)/opt/etc/init.d/S70net-snmp
	$(MAKE) $(NET_SNMP_IPK_DIR)/CONTROL/control
	install -m 755 $(NET_SNMP_SOURCE_DIR)/postinst $(NET_SNMP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NET_SNMP_SOURCE_DIR)/prerm $(NET_SNMP_IPK_DIR)/CONTROL/prerm
	echo $(NET_SNMP_CONFFILES) | sed -e 's/ /\n/g' > $(NET_SNMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NET_SNMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
net-snmp-ipk: $(NET_SNMP_IPK)

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
	rm -rf $(BUILD_DIR)/$(NET_SNMP_DIR) $(NET_SNMP_BUILD_DIR) $(NET_SNMP_IPK_DIR) $(NET_SNMP_IPK)

#
# Some sanity check for the package.
#
net-snmp-check: $(NET_SNMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NET_SNMP_IPK)
