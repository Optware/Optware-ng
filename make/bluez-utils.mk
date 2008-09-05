###########################################################
#
# bluez-utils
#
###########################################################

#
# BLUEZ-UTILS_VERSION, BLUEZ-UTILS_SITE and BLUEZ-UTILS_SOURCE define
# the upstream location of the source code for the package.
# BLUEZ-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BLUEZ-UTILS_UNZIP is the command used to unzip the source.
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
BLUEZ-UTILS_SITE=http://bluez.sf.net/download
BLUEZ-UTILS_VERSION=3.36
BLUEZ-UTILS_SOURCE=bluez-utils-$(BLUEZ-UTILS_VERSION).tar.gz
BLUEZ-UTILS_DIR=bluez-utils-$(BLUEZ-UTILS_VERSION)
BLUEZ-UTILS_UNZIP=zcat
BLUEZ-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BLUEZ-UTILS_DESCRIPTION=Bluetooth utilities.
BLUEZ-UTILS_SECTION=misc
BLUEZ-UTILS_PRIORITY=optional
BLUEZ-UTILS_DEPENDS=bluez-libs, dbus, expat
BLUEZ-UTILS_SUGGESTS=
BLUEZ-UTILS_CONFLICTS=

#
# BLUEZ-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
BLUEZ-UTILS_IPK_VERSION=3

#
# BLUEZ-UTILS_CONFFILES should be a list of user-editable files
BLUEZ-UTILS_CONFFILES=\
/opt/etc/bluetooth/hcid.conf \
/opt/etc/bluetooth/echo.service \
/opt/etc/bluetooth/input.service \
/opt/etc/bluetooth/serial.service \
/opt/etc/bluetooth/network.service \
/opt/etc/bluetooth/rfcomm.conf \
/opt/etc/dbus-1/system.d/bluetooth.conf \
/opt/etc/init.d/bluetooth \
/opt/etc/default/bluetooth \
/opt/etc/udev/bluetooth.rules \


#
# BLUEZ-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BLUEZ-UTILS_PATCHES=$(BLUEZ-UTILS_SOURCE_DIR)/bridge_ioctls.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(TARGET_ARCH), mipsel)
BLUEZ-UTILS_CPPFLAGS=-DENOKEY=161
else
ifneq ($(OPTWARE_TARGET), slugosbe)
BLUEZ-UTILS_CPPFLAGS=-DENOKEY=126
endif
endif
BLUEZ-UTILS_LDFLAGS=

ifeq ($(OPTWARE_TARGET), $(filter syno-x07 vt4, $(OPTWARE_TARGET)))
BLUEZ-UTILS_CONFIG_ARGS= --disable-alsa --disable-pie
endif

#
# BLUEZ-UTILS_BUILD_DIR is the directory in which the build is done.
# BLUEZ-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BLUEZ-UTILS_IPK_DIR is the directory in which the ipk is built.
# BLUEZ-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BLUEZ-UTILS_BUILD_DIR=$(BUILD_DIR)/bluez-utils
BLUEZ-UTILS_SOURCE_DIR=$(SOURCE_DIR)/bluez-utils
BLUEZ-UTILS_IPK_DIR=$(BUILD_DIR)/bluez-utils-$(BLUEZ-UTILS_VERSION)-ipk
BLUEZ-UTILS_IPK=$(BUILD_DIR)/bluez-utils_$(BLUEZ-UTILS_VERSION)-$(BLUEZ-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bluez-utils-source bluez-utils-unpack bluez-utils bluez-utils-stage bluez-utils-ipk bluez-utils-clean bluez-utils-dirclean bluez-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BLUEZ-UTILS_SOURCE):
	$(WGET) -P $(@D) $(BLUEZ-UTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bluez-utils-source: $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) $(BLUEZ-UTILS_PATCHES)

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
$(BLUEZ-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) $(BLUEZ-UTILS_PATCHES) make/bluez-utils.mk
	$(MAKE) bluez-libs-stage
	$(MAKE) dbus-stage
	$(MAKE) expat-stage
	$(MAKE) libusb-stage
	$(MAKE) openobex-stage
	rm -rf $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(@D)
	$(BLUEZ-UTILS_UNZIP) $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BLUEZ-UTILS_PATCHES)"; then \
		cat $(BLUEZ-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BLUEZ-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BLUEZ-UTILS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-all \
		$(BLUEZ-UTILS_CONFIG_ARGS) \
		--disable-glib \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bluez-utils-unpack: $(BLUEZ-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BLUEZ-UTILS_BUILD_DIR)/.built: $(BLUEZ-UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bluez-utils: $(BLUEZ-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BLUEZ-UTILS_BUILD_DIR)/.staged: $(BLUEZ-UTILS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bluez-utils-stage: $(BLUEZ-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bluez-utils
#
$(BLUEZ-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bluez-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BLUEZ-UTILS_PRIORITY)" >>$@
	@echo "Section: $(BLUEZ-UTILS_SECTION)" >>$@
	@echo "Version: $(BLUEZ-UTILS_VERSION)-$(BLUEZ-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BLUEZ-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(BLUEZ-UTILS_SITE)/$(BLUEZ-UTILS_SOURCE)" >>$@
	@echo "Description: $(BLUEZ-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BLUEZ-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BLUEZ-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BLUEZ-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BLUEZ-UTILS_IPK_DIR)/opt/sbin or $(BLUEZ-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BLUEZ-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/etc/bluez-utils/...
# Documentation files should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/doc/bluez-utils/...
# Daemon startup scripts should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/etc/init.d/S??bluez-utils
#
# You may need to patch your application to make it use these locations.
#
$(BLUEZ-UTILS_IPK): $(BLUEZ-UTILS_BUILD_DIR)/.built
	rm -rf $(BLUEZ-UTILS_IPK_DIR) $(BUILD_DIR)/bluez-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR) DESTDIR=$(BLUEZ-UTILS_IPK_DIR) install-strip
#	sed -i -e 's|"/etc|"/opt/etc|' $(BLUEZ-UTILS_IPK_DIR)/opt/etc/*/bluetooth
	$(MAKE) $(BLUEZ-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BLUEZ-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bluez-utils-ipk: $(BLUEZ-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bluez-utils-clean:
	-$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bluez-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(BLUEZ-UTILS_BUILD_DIR) $(BLUEZ-UTILS_IPK_DIR) $(BLUEZ-UTILS_IPK)

#
# Some sanity check for the package.
#
bluez-utils-check: $(BLUEZ-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BLUEZ-UTILS_IPK)
