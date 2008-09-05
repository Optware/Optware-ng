###########################################################
#
# bluez-hcidump
#
###########################################################

#
# BLUEZ-HCIDUMP_VERSION, BLUEZ-HCIDUMP_SITE and BLUEZ-HCIDUMP_SOURCE define
# the upstream location of the source code for the package.
# BLUEZ-HCIDUMP_DIR is the directory which is created when the source
# archive is unpacked.
# BLUEZ-HCIDUMP_UNZIP is the command used to unzip the source.
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
BLUEZ-HCIDUMP_SITE=http://bluez.sf.net/download
BLUEZ-HCIDUMP_VERSION=1.42
BLUEZ-HCIDUMP_SOURCE=bluez-hcidump-$(BLUEZ-HCIDUMP_VERSION).tar.gz
BLUEZ-HCIDUMP_DIR=bluez-hcidump-$(BLUEZ-HCIDUMP_VERSION)
BLUEZ-HCIDUMP_UNZIP=zcat
BLUEZ-HCIDUMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BLUEZ-HCIDUMP_DESCRIPTION=Bluetooth packet analyzer.
BLUEZ-HCIDUMP_SECTION=misc
BLUEZ-HCIDUMP_PRIORITY=optional
BLUEZ-HCIDUMP_DEPENDS=bluez-libs
BLUEZ-HCIDUMP_SUGGESTS=
BLUEZ-HCIDUMP_CONFLICTS=

#
# BLUEZ-HCIDUMP_IPK_VERSION should be incremented when the ipk changes.
#
BLUEZ-HCIDUMP_IPK_VERSION=1

#
# BLUEZ-HCIDUMP_CONFFILES should be a list of user-editable files
#BLUEZ-HCIDUMP_CONFFILES=/opt/etc/bluez-hcidump.conf /opt/etc/init.d/SXXbluez-hcidump

#
# BLUEZ-HCIDUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BLUEZ-HCIDUMP_PATCHES=$(BLUEZ-HCIDUMP_SOURCE_DIR)/AI_ADDRCONFIG.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BLUEZ-HCIDUMP_CPPFLAGS=
BLUEZ-HCIDUMP_LDFLAGS=

ifeq ($(OPTWARE_TARGET), $(filter syno-x07, $(OPTWARE_TARGET)))
BLUEZ-HCIDUMP_CONFIG_ARGS = --disable-pie
endif

#
# BLUEZ-HCIDUMP_BUILD_DIR is the directory in which the build is done.
# BLUEZ-HCIDUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BLUEZ-HCIDUMP_IPK_DIR is the directory in which the ipk is built.
# BLUEZ-HCIDUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BLUEZ-HCIDUMP_BUILD_DIR=$(BUILD_DIR)/bluez-hcidump
BLUEZ-HCIDUMP_SOURCE_DIR=$(SOURCE_DIR)/bluez-hcidump
BLUEZ-HCIDUMP_IPK_DIR=$(BUILD_DIR)/bluez-hcidump-$(BLUEZ-HCIDUMP_VERSION)-ipk
BLUEZ-HCIDUMP_IPK=$(BUILD_DIR)/bluez-hcidump_$(BLUEZ-HCIDUMP_VERSION)-$(BLUEZ-HCIDUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bluez-hcidump-source bluez-hcidump-unpack bluez-hcidump bluez-hcidump-stage bluez-hcidump-ipk bluez-hcidump-clean bluez-hcidump-dirclean bluez-hcidump-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BLUEZ-HCIDUMP_SOURCE):
	$(WGET) -P $(@D) $(BLUEZ-HCIDUMP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bluez-hcidump-source: $(DL_DIR)/$(BLUEZ-HCIDUMP_SOURCE) $(BLUEZ-HCIDUMP_PATCHES)

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
$(BLUEZ-HCIDUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(BLUEZ-HCIDUMP_SOURCE) $(BLUEZ-HCIDUMP_PATCHES)
	$(MAKE) bluez-libs-stage
	rm -rf $(BUILD_DIR)/$(BLUEZ-HCIDUMP_DIR) $(@D)
	$(BLUEZ-HCIDUMP_UNZIP) $(DL_DIR)/$(BLUEZ-HCIDUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BLUEZ-HCIDUMP_PATCHES)"; then \
		cat $(BLUEZ-HCIDUMP_PATCHES) | patch -d $(BUILD_DIR)/$(BLUEZ-HCIDUMP_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(BLUEZ-HCIDUMP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BLUEZ-HCIDUMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BLUEZ-HCIDUMP_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(BLUEZ-HCIDUMP_CONFIG_ARGS) \
		--disable-nls \
	)
	touch $@

bluez-hcidump-unpack: $(BLUEZ-HCIDUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BLUEZ-HCIDUMP_BUILD_DIR)/.built: $(BLUEZ-HCIDUMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bluez-hcidump: $(BLUEZ-HCIDUMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BLUEZ-HCIDUMP_BUILD_DIR)/.staged: $(BLUEZ-HCIDUMP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-strip
#	touch $@
#
#bluez-hcidump-stage: $(BLUEZ-HCIDUMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bluez-hcidump
#
$(BLUEZ-HCIDUMP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bluez-hcidump" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BLUEZ-HCIDUMP_PRIORITY)" >>$@
	@echo "Section: $(BLUEZ-HCIDUMP_SECTION)" >>$@
	@echo "Version: $(BLUEZ-HCIDUMP_VERSION)-$(BLUEZ-HCIDUMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BLUEZ-HCIDUMP_MAINTAINER)" >>$@
	@echo "Source: $(BLUEZ-HCIDUMP_SITE)/$(BLUEZ-HCIDUMP_SOURCE)" >>$@
	@echo "Description: $(BLUEZ-HCIDUMP_DESCRIPTION)" >>$@
	@echo "Depends: $(BLUEZ-HCIDUMP_DEPENDS)" >>$@
	@echo "Suggests: $(BLUEZ-HCIDUMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(BLUEZ-HCIDUMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BLUEZ-HCIDUMP_IPK_DIR)/opt/sbin or $(BLUEZ-HCIDUMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BLUEZ-HCIDUMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BLUEZ-HCIDUMP_IPK_DIR)/opt/etc/bluez-hcidump/...
# Documentation files should be installed in $(BLUEZ-HCIDUMP_IPK_DIR)/opt/doc/bluez-hcidump/...
# Daemon startup scripts should be installed in $(BLUEZ-HCIDUMP_IPK_DIR)/opt/etc/init.d/S??bluez-hcidump
#
# You may need to patch your application to make it use these locations.
#
$(BLUEZ-HCIDUMP_IPK): $(BLUEZ-HCIDUMP_BUILD_DIR)/.built
	rm -rf $(BLUEZ-HCIDUMP_IPK_DIR) $(BUILD_DIR)/bluez-hcidump_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BLUEZ-HCIDUMP_BUILD_DIR) DESTDIR=$(BLUEZ-HCIDUMP_IPK_DIR) install-strip
	$(MAKE) $(BLUEZ-HCIDUMP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BLUEZ-HCIDUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bluez-hcidump-ipk: $(BLUEZ-HCIDUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bluez-hcidump-clean:
	-$(MAKE) -C $(BLUEZ-HCIDUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bluez-hcidump-dirclean:
	rm -rf $(BUILD_DIR)/$(BLUEZ-HCIDUMP_DIR) $(BLUEZ-HCIDUMP_BUILD_DIR) $(BLUEZ-HCIDUMP_IPK_DIR) $(BLUEZ-HCIDUMP_IPK)

#
# Some sanity check for the package.
#
bluez-hcidump-check: $(BLUEZ-HCIDUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BLUEZ-HCIDUMP_IPK)
