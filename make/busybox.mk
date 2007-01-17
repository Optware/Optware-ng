###########################################################
#
# busybox
#
###########################################################

# You must replace "busybox" and "BUSYBOX" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BUSYBOX_VERSION, BUSYBOX_SITE and BUSYBOX_SOURCE define
# the upstream location of the source code for the package.
# BUSYBOX_DIR is the directory which is created when the source
# archive is unpacked.
# BUSYBOX_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
BUSYBOX_SITE=http://www.busybox.net/downloads
# If you change this version, you must check the adduser package as well.
BUSYBOX_VERSION=1.3.1
BUSYBOX_SOURCE=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_DIR=busybox-$(BUSYBOX_VERSION)
BUSYBOX_UNZIP=bzcat
BUSYBOX_CONFIG=$(BUSYBOX_SOURCE_DIR)/defconfig
BUSYBOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BUSYBOX_DESCRIPTION=A userland replacement for embedded systems.
BUSYBOX_SECTION=core
BUSYBOX_PRIORITY=optional
BUSYBOX_DEPENDS=
BUSYBOX_CONFLICTS=

#
# BUSYBOX_IPK_VERSION should be incremented when the ipk changes.
#
BUSYBOX_IPK_VERSION=3

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BUSYBOX_CPPFLAGS=
#BUSYBOX_LDFLAGS=-Wl,lm

#
# USHARE_BUILD_DIR is the directory in which the build is done.
# USHARE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# USHARE_IPK_DIR is the directory in which the ipk is built.
# USHARE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BUSYBOX_BUILD_DIR=$(BUILD_DIR)/busybox
BUSYBOX_SOURCE_DIR=$(SOURCE_DIR)/busybox
BUSYBOX_IPK_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)-ipk
BUSYBOX_IPK=$(BUILD_DIR)/busybox_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: busybox-source busybox-unpack busybox busybox-stage busybox-ipk busybox-clean busybox-dirclean busybox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(WGET) -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(BUSYBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES) make/busybox.mk
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(BUSYBOX_DIR)" != "$(BUSYBOX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR) ; \
	fi
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_DIR)/.config
ifeq ($(LIBC_STYLE),uclibc)
	sed -i -e "s/^.*CONFIG_FEATURE_SORT_BIG.*/# CONFIG_FEATURE_SORT_BIG is not set/" \
		-e "s/^.*CONFIG_MKSWAP.*/CONFIG_MKSWAP=y/" \
		-e "s/^.*CONFIG_LOSETUP.*/CONFIG_LOSETUP=y/" \
		$(BUSYBOX_BUILD_DIR)/.config
else
	sed -i -e "s/^.*CONFIG_FEATURE_SORT_BIG.*/CONFIG_FEATURE_SORT_BIG=y/" \
		$(BUSYBOX_BUILD_DIR)/.config
endif
	$(MAKE) HOSTCC=$(HOSTCC) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" \
		-C $(BUSYBOX_BUILD_DIR) oldconfig
	touch $(BUSYBOX_BUILD_DIR)/.configured

busybox-unpack: $(BUSYBOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BUSYBOX_BUILD_DIR)/.built: $(BUSYBOX_BUILD_DIR)/.configured
	rm -f $(BUSYBOX_BUILD_DIR)/.built
	CPPFLAGS="$(STAGING_CPPFLAGS) $(BUSYBOX_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(BUSYBOX_LDFLAGS)" \
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUILD_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		-C $(BUSYBOX_BUILD_DIR)
	touch $(BUSYBOX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
busybox: $(BUSYBOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BUSYBOX_BUILD_DIR)/.staged: $(BUSYBOX_BUILD_DIR)/.built
	rm -f $(BUSYBOX_BUILD_DIR)/.staged
	$(MAKE) -C $(BUSYBOX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BUSYBOX_BUILD_DIR)/.staged

busybox-stage: $(BUSYBOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources
#
$(BUSYBOX_IPK_DIR)/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: busybox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)), busybox-links (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-base/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)-base/CONTROL
	@rm -f $@
	@echo "Package: busybox-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: $(BUSYBOX_DEPENDS)" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-links/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)-links/CONTROL
	@rm -f $@
	@echo "Package: busybox-links" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUSYBOX_IPK_DIR)/opt/sbin or $(BUSYBOX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUSYBOX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BUSYBOX_IPK_DIR)/opt/etc/busybox/...
# Documentation files should be installed in $(BUSYBOX_IPK_DIR)/opt/doc/busybox/...
# Daemon startup scripts should be installed in $(BUSYBOX_IPK_DIR)/opt/etc/init.d/S??busybox
#
# You may need to patch your application to make it use these locations.
#
$(BUSYBOX_IPK): $(BUSYBOX_BUILD_DIR)/.built
	rm -rf $(BUSYBOX_IPK_DIR) $(BUILD_DIR)/busybox_*_$(TARGET_ARCH).ipk
	install -d $(BUSYBOX_IPK_DIR)/opt
	CPPFLAGS="$(STAGING_CPPFLAGS) $(BUSYBOX_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(BUSYBOX_LDFLAGS)" \
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUSYBOX_IPK_DIR)/opt" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_BUILD_DIR) install
	rm -rf $(BUSYBOX_IPK_DIR)-base
	install -d $(BUSYBOX_IPK_DIR)-base/opt/bin
	mv $(BUSYBOX_IPK_DIR)/opt/bin/busybox $(BUSYBOX_IPK_DIR)-base/opt/bin
	$(MAKE) $(BUSYBOX_IPK_DIR)-base/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-base
	rm -rf $(BUSYBOX_IPK_DIR)-links
	install -d $(BUSYBOX_IPK_DIR)-links/opt/bin
	install -d $(BUSYBOX_IPK_DIR)-links/opt/sbin
	mv $(BUSYBOX_IPK_DIR)/opt/bin/* $(BUSYBOX_IPK_DIR)-links/opt/bin
	mv $(BUSYBOX_IPK_DIR)/opt/sbin/* $(BUSYBOX_IPK_DIR)-links/opt/sbin
	# Remove the symlinks for potential "stock functionality" applets.
	rm $(BUSYBOX_IPK_DIR)-links/opt/sbin/fdisk
	rm $(BUSYBOX_IPK_DIR)-links/opt/sbin/insmod
	# Remove broken df - stock is better
	rm $(BUSYBOX_IPK_DIR)-links/opt/bin/df
	$(MAKE) $(BUSYBOX_IPK_DIR)-links/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-links
	rm -rf $(BUSYBOX_IPK_DIR)/opt
	$(MAKE) $(BUSYBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
busybox-ipk: $(BUSYBOX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
busybox-clean:
	-$(MAKE) -C $(BUSYBOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
busybox-dirclean:
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR) $(BUSYBOX_IPK_DIR) $(BUSYBOX_IPK)

#
# Some sanity check for the package.
#
busybox-check: $(BUSYBOX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BUSYBOX_IPK)
