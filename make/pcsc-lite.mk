###########################################################
#
# pcsc-lite
#
###########################################################
#
# PCSC_LITE_VERSION, PCSC_LITE_SITE and PCSC_LITE_SOURCE define
# the upstream location of the source code for the package.
# PCSC_LITE_DIR is the directory which is created when the source
# archive is unpacked.
# PCSC_LITE_UNZIP is the command used to unzip the source.
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
PCSC_LITE_URL=https://launchpad.net/ubuntu/+archive/primary/+files/pcsc-lite_$(PCSC_LITE_VERSION).orig.tar.bz2
PCSC_LITE_VERSION=1.8.6
PCSC_LITE_SOURCE=pcsc-lite-$(PCSC_LITE_VERSION).tar.bz2
PCSC_LITE_DIR=pcsc-lite-$(PCSC_LITE_VERSION)
PCSC_LITE_UNZIP=bzcat
PCSC_LITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCSC_LITE_DESCRIPTION=Middleware to access a smart card using PC/SC.
PCSC_LITE_SECTION=misc
PCSC_LITE_PRIORITY=optional
PCSC_LITE_DEPENDS=libusb1
PCSC_LITE_SUGGESTS=
PCSC_LITE_CONFLICTS=

#
# PCSC_LITE_IPK_VERSION should be incremented when the ipk changes.
#
PCSC_LITE_IPK_VERSION=2

#
# PCSC_LITE_CONFFILES should be a list of user-editable files
#PCSC_LITE_CONFFILES=$(TARGET_PREFIX)/etc/pcsc-lite.conf $(TARGET_PREFIX)/etc/init.d/SXXpcsc-lite

#
# PCSC_LITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PCSC_LITE_PATCHES=$(PCSC_LITE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCSC_LITE_CPPFLAGS=
PCSC_LITE_LDFLAGS=

#
# PCSC_LITE_BUILD_DIR is the directory in which the build is done.
# PCSC_LITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCSC_LITE_IPK_DIR is the directory in which the ipk is built.
# PCSC_LITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCSC_LITE_BUILD_DIR=$(BUILD_DIR)/pcsc-lite
PCSC_LITE_SOURCE_DIR=$(SOURCE_DIR)/pcsc-lite
PCSC_LITE_IPK_DIR=$(BUILD_DIR)/pcsc-lite-$(PCSC_LITE_VERSION)-ipk
PCSC_LITE_IPK=$(BUILD_DIR)/pcsc-lite_$(PCSC_LITE_VERSION)-$(PCSC_LITE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pcsc-lite-source pcsc-lite-unpack pcsc-lite pcsc-lite-stage pcsc-lite-ipk pcsc-lite-clean pcsc-lite-dirclean pcsc-lite-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PCSC_LITE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PCSC_LITE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PCSC_LITE_SOURCE).sha512
#
$(DL_DIR)/$(PCSC_LITE_SOURCE):
	$(WGET) -O $@ $(PCSC_LITE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pcsc-lite-source: $(DL_DIR)/$(PCSC_LITE_SOURCE) $(PCSC_LITE_PATCHES)

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
$(PCSC_LITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PCSC_LITE_SOURCE) $(PCSC_LITE_PATCHES) make/pcsc-lite.mk
	$(MAKE) libusb1-stage
	rm -rf $(BUILD_DIR)/$(PCSC_LITE_DIR) $(@D)
	$(PCSC_LITE_UNZIP) $(DL_DIR)/$(PCSC_LITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PCSC_LITE_PATCHES)" ; \
		then cat $(PCSC_LITE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PCSC_LITE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PCSC_LITE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PCSC_LITE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCSC_LITE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCSC_LITE_LDFLAGS)" \
		LIBUSB_CFLAGS="-I$(STAGING_INCLUDE_DIR)/libusb-1.0" \
		LIBUSB_LIBS="-lusb-1.0 -pthread" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-libudev \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pcsc-lite-unpack: $(PCSC_LITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCSC_LITE_BUILD_DIR)/.built: $(PCSC_LITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pcsc-lite: $(PCSC_LITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCSC_LITE_BUILD_DIR)/.staged: $(PCSC_LITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpcsclite.la $(STAGING_LIB_DIR)/libpcscspy.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libpcsclite.pc
	touch $@

pcsc-lite-stage: $(PCSC_LITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pcsc-lite
#
$(PCSC_LITE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: pcsc-lite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCSC_LITE_PRIORITY)" >>$@
	@echo "Section: $(PCSC_LITE_SECTION)" >>$@
	@echo "Version: $(PCSC_LITE_VERSION)-$(PCSC_LITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCSC_LITE_MAINTAINER)" >>$@
	@echo "Source: $(PCSC_LITE_URL)" >>$@
	@echo "Description: $(PCSC_LITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PCSC_LITE_DEPENDS)" >>$@
	@echo "Suggests: $(PCSC_LITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PCSC_LITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/pcsc-lite/...
# Documentation files should be installed in $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/doc/pcsc-lite/...
# Daemon startup scripts should be installed in $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??pcsc-lite
#
# You may need to patch your application to make it use these locations.
#
$(PCSC_LITE_IPK): $(PCSC_LITE_BUILD_DIR)/.built
	rm -rf $(PCSC_LITE_IPK_DIR) $(BUILD_DIR)/pcsc-lite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCSC_LITE_BUILD_DIR) DESTDIR=$(PCSC_LITE_IPK_DIR) install-strip
	rm -f $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(PCSC_LITE_SOURCE_DIR)/pcsc-lite.conf $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/pcsc-lite.conf
#	$(INSTALL) -d $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(PCSC_LITE_SOURCE_DIR)/rc.pcsc-lite $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXpcsc-lite
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCSC_LITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXpcsc-lite
	$(MAKE) $(PCSC_LITE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(PCSC_LITE_SOURCE_DIR)/postinst $(PCSC_LITE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCSC_LITE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PCSC_LITE_SOURCE_DIR)/prerm $(PCSC_LITE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PCSC_LITE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PCSC_LITE_IPK_DIR)/CONTROL/postinst $(PCSC_LITE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PCSC_LITE_CONFFILES) | sed -e 's/ /\n/g' > $(PCSC_LITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCSC_LITE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PCSC_LITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pcsc-lite-ipk: $(PCSC_LITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pcsc-lite-clean:
	rm -f $(PCSC_LITE_BUILD_DIR)/.built
	-$(MAKE) -C $(PCSC_LITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pcsc-lite-dirclean:
	rm -rf $(BUILD_DIR)/$(PCSC_LITE_DIR) $(PCSC_LITE_BUILD_DIR) $(PCSC_LITE_IPK_DIR) $(PCSC_LITE_IPK)
#
#
# Some sanity check for the package.
#
pcsc-lite-check: $(PCSC_LITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
