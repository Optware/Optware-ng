###########################################################
#
# presentproto
#
###########################################################

#
# PRESENTPROTO_VERSION, PRESENTPROTO_SITE and PRESENTPROTO_SOURCE define
# the upstream location of the source code for the package.
# PRESENTPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# PRESENTPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PRESENTPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
PRESENTPROTO_SOURCE=presentproto-$(PRESENTPROTO_VERSION).tar.gz
PRESENTPROTO_VERSION=1.0
PRESENTPROTO_DIR=presentproto-$(PRESENTPROTO_VERSION)
PRESENTPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PRESENTPROTO_DESCRIPTION=PRESENT Protocol headers
PRESENTPROTO_SECTION=lib
PRESENTPROTO_PRIORITY=optional

#
# PRESENTPROTO_IPK_VERSION should be incremented when the ipk changes.
#
PRESENTPROTO_IPK_VERSION=1

#
# PRESENTPROTO_CONFFILES should be a list of user-editable files
PRESENTPROTO_CONFFILES=

#
# PRESENTPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PRESENTPROTO_PATCHES=$(PRESENTPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PRESENTPROTO_CPPFLAGS=
PRESENTPROTO_LDFLAGS=

#
# PRESENTPROTO_BUILD_DIR is the directory in which the build is done.
# PRESENTPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PRESENTPROTO_IPK_DIR is the directory in which the ipk is built.
# PRESENTPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PRESENTPROTO_BUILD_DIR=$(BUILD_DIR)/presentproto
PRESENTPROTO_SOURCE_DIR=$(SOURCE_DIR)/presentproto
PRESENTPROTO_IPK_DIR=$(BUILD_DIR)/presentproto-$(PRESENTPROTO_VERSION)-ipk
PRESENTPROTO_IPK=$(BUILD_DIR)/presentproto_$(PRESENTPROTO_VERSION)-$(PRESENTPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PRESENTPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PRESENTPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: presentproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PRESENTPROTO_PRIORITY)" >>$@
	@echo "Section: $(PRESENTPROTO_SECTION)" >>$@
	@echo "Version: $(PRESENTPROTO_VERSION)-$(PRESENTPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PRESENTPROTO_MAINTAINER)" >>$@
	@echo "Source: $(PRESENTPROTO_SITE)/$(PRESENTPROTO_SOURCE)" >>$@
	@echo "Description: $(PRESENTPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PRESENTPROTO_SOURCE):
	$(WGET) -P $(@D) $(PRESENTPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

presentproto-source: $(DL_DIR)/$(PRESENTPROTO_SOURCE) $(PRESENTPROTO_PATCHES)

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
$(PRESENTPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(PRESENTPROTO_SOURCE) $(PRESENTPROTO_PATCHES) make/presentproto.mk
	rm -rf $(BUILD_DIR)/$(PRESENTPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(PRESENTPROTO_SOURCE)
	if test -n "$(PRESENTPROTO_PATCHES)" ; \
		then cat $(PRESENTPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PRESENTPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PRESENTPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PRESENTPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PRESENTPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PRESENTPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	touch $@

presentproto-unpack: $(PRESENTPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PRESENTPROTO_BUILD_DIR)/.built: $(PRESENTPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
presentproto: $(PRESENTPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PRESENTPROTO_BUILD_DIR)/.staged: $(PRESENTPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/presentproto.pc
	touch $@

presentproto-stage: $(PRESENTPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/presentproto/...
# Documentation files should be installed in $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/presentproto/...
# Daemon startup scripts should be installed in $(PRESENTPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??presentproto
#
# You may need to patch your application to make it use these locations.
#
$(PRESENTPROTO_IPK): $(PRESENTPROTO_BUILD_DIR)/.built
	rm -rf $(PRESENTPROTO_IPK_DIR) $(BUILD_DIR)/presentproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PRESENTPROTO_BUILD_DIR) DESTDIR=$(PRESENTPROTO_IPK_DIR) install
	$(MAKE) $(PRESENTPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PRESENTPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
presentproto-ipk: $(PRESENTPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
presentproto-clean:
	-$(MAKE) -C $(PRESENTPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
presentproto-dirclean:
	rm -rf $(BUILD_DIR)/$(PRESENTPROTO_DIR) $(PRESENTPROTO_BUILD_DIR) $(PRESENTPROTO_IPK_DIR) $(PRESENTPROTO_IPK)
