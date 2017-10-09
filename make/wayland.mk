###########################################################
#
# wayland
#
###########################################################

# You must replace "wayland" and "WAYLAND" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WAYLAND_VERSION, WAYLAND_SITE and WAYLAND_SOURCE define
# the upstream location of the source code for the package.
# WAYLAND_DIR is the directory which is created when the source
# archive is unpacked.
# WAYLAND_UNZIP is the command used to unzip the source.
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
WAYLAND_SITE=http://wayland.freedesktop.org/releases
WAYLAND_VERSION=1.7.0
WAYLAND_SOURCE=wayland-$(WAYLAND_VERSION).tar.xz
WAYLAND_DIR=wayland-$(WAYLAND_VERSION)
WAYLAND_UNZIP=xzcat
WAYLAND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WAYLAND_DESCRIPTION=Wayland is intended as a simpler replacement for X, easier to develop and maintain
WAYLAND_SECTION=lib
WAYLAND_PRIORITY=optional
WAYLAND_DEPENDS=expat, libffi
WAYLAND_SUGGESTS=
WAYLAND_CONFLICTS=

#
# WAYLAND_IPK_VERSION should be incremented when the ipk changes.
#
WAYLAND_IPK_VERSION=2

#
# WAYLAND_CONFFILES should be a list of user-editable files
#WAYLAND_CONFFILES=$(TARGET_PREFIX)/etc/wayland.conf $(TARGET_PREFIX)/etc/init.d/SXXwayland

#
# WAYLAND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WAYLAND_PATCHES=$(WAYLAND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WAYLAND_CPPFLAGS=
WAYLAND_LDFLAGS=

#
# WAYLAND_BUILD_DIR is the directory in which the build is done.
# WAYLAND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WAYLAND_IPK_DIR is the directory in which the ipk is built.
# WAYLAND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WAYLAND_BUILD_DIR=$(BUILD_DIR)/wayland
WAYLAND_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/wayland
WAYLAND_SOURCE_DIR=$(SOURCE_DIR)/wayland
WAYLAND_IPK_DIR=$(BUILD_DIR)/wayland-$(WAYLAND_VERSION)-ipk
WAYLAND_IPK=$(BUILD_DIR)/wayland_$(WAYLAND_VERSION)-$(WAYLAND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wayland-source wayland-unpack wayland wayland-stage wayland-ipk wayland-clean wayland-dirclean wayland-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WAYLAND_SOURCE):
	$(WGET) -P $(@D) $(WAYLAND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wayland-source: $(DL_DIR)/$(WAYLAND_SOURCE) $(WAYLAND_PATCHES)

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
$(WAYLAND_BUILD_DIR)/.configured: $(DL_DIR)/$(WAYLAND_SOURCE) $(WAYLAND_PATCHES) make/wayland.mk $(WAYLAND_HOST_BUILD_DIR)/.staged
	$(MAKE) expat-stage libffi-stage
	rm -rf $(BUILD_DIR)/$(WAYLAND_DIR) $(@D)
	$(WAYLAND_UNZIP) $(DL_DIR)/$(WAYLAND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WAYLAND_PATCHES)" ; \
		then cat $(WAYLAND_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(WAYLAND_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WAYLAND_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(WAYLAND_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WAYLAND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WAYLAND_LDFLAGS)" \
		EXPAT_CFLAGS="$(STAGING_CPPFLAGS)" \
		EXPAT_LIBS="$(STAGING_LDFLAGS) -lexpat" \
		FFI_CFLAGS="$(STAGING_CPPFLAGS)" \
		FFI_LIBS="$(STAGING_LDFLAGS) -lffi" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-documentation \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

wayland-unpack: $(WAYLAND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WAYLAND_BUILD_DIR)/.built: $(WAYLAND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) wayland_scanner=$(HOST_STAGING_PREFIX)/bin/wayland-scanner
	touch $@

#
# This is the build convenience target.
#
wayland: $(WAYLAND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WAYLAND_BUILD_DIR)/.staged: $(WAYLAND_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(STAGING_PREFIX) \
		wayland_scanner=$(HOST_STAGING_PREFIX)/bin/wayland-scanner
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/wayland-*.pc
	rm -f $(STAGING_LIB_DIR)/libwayland-*.la
	touch $@

wayland-stage: $(WAYLAND_BUILD_DIR)/.staged

$(WAYLAND_HOST_BUILD_DIR)/.staged: $(DL_DIR)/$(WAYLAND_SOURCE)
	$(MAKE) expat-host-stage libffi-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(WAYLAND_DIR) $(@D)
	$(WAYLAND_UNZIP) $(DL_DIR)/$(WAYLAND_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(WAYLAND_PATCHES)" ; \
		then cat $(WAYLAND_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(WAYLAND_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(WAYLAND_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(WAYLAND_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		CPPFLAGS="$(HOST_STAGING_CPPFLAGS) -fPIC" \
		LDFLAGS="$(HOST_STAGING_LDFLAGS)" \
		EXPAT_CFLAGS="$(HOST_STAGING_CPPFLAGS)" \
		EXPAT_LIBS="$(HOST_STAGING_LDFLAGS) -lexpat" \
		FFI_CFLAGS="$(HOST_STAGING_CPPFLAGS)" \
		FFI_LIBS="$(HOST_STAGING_LDFLAGS) -lffi" \
		./configure \
		--disable-documentation \
		--prefix=$(HOST_STAGING_PREFIX) \
		--disable-nls \
		--disable-shared \
	)
	$(MAKE) -C $(@D) install
	touch $@

wayland-host-stage: $(WAYLAND_HOST_BUILD_DIR)/.staged

wayland-stage: $(WAYLAND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wayland
#
$(WAYLAND_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: wayland" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WAYLAND_PRIORITY)" >>$@
	@echo "Section: $(WAYLAND_SECTION)" >>$@
	@echo "Version: $(WAYLAND_VERSION)-$(WAYLAND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WAYLAND_MAINTAINER)" >>$@
	@echo "Source: $(WAYLAND_SITE)/$(WAYLAND_SOURCE)" >>$@
	@echo "Description: $(WAYLAND_DESCRIPTION)" >>$@
	@echo "Depends: $(WAYLAND_DEPENDS)" >>$@
	@echo "Suggests: $(WAYLAND_SUGGESTS)" >>$@
	@echo "Conflicts: $(WAYLAND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/sbin or $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/wayland/...
# Documentation files should be installed in $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/doc/wayland/...
# Daemon startup scripts should be installed in $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??wayland
#
# You may need to patch your application to make it use these locations.
#
$(WAYLAND_IPK): $(WAYLAND_BUILD_DIR)/.built
	rm -rf $(WAYLAND_IPK_DIR) $(BUILD_DIR)/wayland_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WAYLAND_BUILD_DIR) DESTDIR=$(WAYLAND_IPK_DIR) install-strip \
		 wayland_scanner=$(HOST_STAGING_PREFIX)/bin/wayland-scanner
#	$(INSTALL) -d $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(WAYLAND_SOURCE_DIR)/wayland.conf $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/wayland.conf
#	$(INSTALL) -d $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(WAYLAND_SOURCE_DIR)/rc.wayland $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXwayland
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAYLAND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXwayland
	$(MAKE) $(WAYLAND_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(WAYLAND_SOURCE_DIR)/postinst $(WAYLAND_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAYLAND_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(WAYLAND_SOURCE_DIR)/prerm $(WAYLAND_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WAYLAND_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(WAYLAND_IPK_DIR)/CONTROL/postinst $(WAYLAND_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(WAYLAND_CONFFILES) | sed -e 's/ /\n/g' > $(WAYLAND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WAYLAND_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(WAYLAND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wayland-ipk: $(WAYLAND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wayland-clean:
	rm -f $(WAYLAND_BUILD_DIR)/.built
	-$(MAKE) -C $(WAYLAND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wayland-dirclean:
	rm -rf $(BUILD_DIR)/$(WAYLAND_DIR) $(WAYLAND_BUILD_DIR) $(WAYLAND_IPK_DIR) $(WAYLAND_IPK)
#
#
# Some sanity check for the package.
#
wayland-check: $(WAYLAND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
