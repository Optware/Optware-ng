###########################################################
#
# printproto
#
###########################################################

#
# PRINTPROTO_VERSION, PRINTPROTO_SITE and PRINTPROTO_SOURCE define
# the upstream location of the source code for the package.
# PRINTPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# PRINTPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PRINTPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
PRINTPROTO_SOURCE=printproto-$(PRINTPROTO_VERSION).tar.gz
PRINTPROTO_VERSION=1.0.5
PRINTPROTO_DIR=printproto-$(PRINTPROTO_VERSION)
PRINTPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PRINTPROTO_DESCRIPTION=X Print Protocol Headers
PRINTPROTO_SECTION=lib
PRINTPROTO_PRIORITY=optional

#
# PRINTPROTO_IPK_VERSION should be incremented when the ipk changes.
#
PRINTPROTO_IPK_VERSION=1

#
# PRINTPROTO_CONFFILES should be a list of user-editable files
PRINTPROTO_CONFFILES=

#
# PRINTPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PRINTPROTO_PATCHES=$(PRINTPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PRINTPROTO_CPPFLAGS=
PRINTPROTO_LDFLAGS=

#
# PRINTPROTO_BUILD_DIR is the directory in which the build is done.
# PRINTPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PRINTPROTO_IPK_DIR is the directory in which the ipk is built.
# PRINTPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PRINTPROTO_BUILD_DIR=$(BUILD_DIR)/printproto
PRINTPROTO_SOURCE_DIR=$(SOURCE_DIR)/printproto
PRINTPROTO_IPK_DIR=$(BUILD_DIR)/printproto-$(PRINTPROTO_VERSION)-ipk
PRINTPROTO_IPK=$(BUILD_DIR)/printproto_$(PRINTPROTO_VERSION)-$(PRINTPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PRINTPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PRINTPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: printproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PRINTPROTO_PRIORITY)" >>$@
	@echo "Section: $(PRINTPROTO_SECTION)" >>$@
	@echo "Version: $(PRINTPROTO_VERSION)-$(PRINTPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PRINTPROTO_MAINTAINER)" >>$@
	@echo "Source: $(PRINTPROTO_SITE)/$(PRINTPROTO_SOURCE)" >>$@
	@echo "Description: $(PRINTPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PRINTPROTO_SOURCE):
	$(WGET) -P $(@D) $(PRINTPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

printproto-source: $(DL_DIR)/$(PRINTPROTO_SOURCE) $(PRINTPROTO_PATCHES)

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
$(PRINTPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(PRINTPROTO_SOURCE) $(PRINTPROTO_PATCHES) make/printproto.mk
	rm -rf $(BUILD_DIR)/$(PRINTPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(PRINTPROTO_SOURCE)
	if test -n "$(PRINTPROTO_PATCHES)" ; \
		then cat $(PRINTPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PRINTPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PRINTPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PRINTPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PRINTPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PRINTPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

printproto-unpack: $(PRINTPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PRINTPROTO_BUILD_DIR)/.built: $(PRINTPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
printproto: $(PRINTPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PRINTPROTO_BUILD_DIR)/.staged: $(PRINTPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/printproto.pc
	touch $@

printproto-stage: $(PRINTPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PRINTPROTO_IPK_DIR)/opt/sbin or $(PRINTPROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PRINTPROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PRINTPROTO_IPK_DIR)/opt/etc/printproto/...
# Documentation files should be installed in $(PRINTPROTO_IPK_DIR)/opt/doc/printproto/...
# Daemon startup scripts should be installed in $(PRINTPROTO_IPK_DIR)/opt/etc/init.d/S??printproto
#
# You may need to patch your application to make it use these locations.
#
$(PRINTPROTO_IPK): $(PRINTPROTO_BUILD_DIR)/.built
	rm -rf $(PRINTPROTO_IPK_DIR) $(BUILD_DIR)/printproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PRINTPROTO_BUILD_DIR) DESTDIR=$(PRINTPROTO_IPK_DIR) install
	$(MAKE) $(PRINTPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PRINTPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
printproto-ipk: $(PRINTPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
printproto-clean:
	-$(MAKE) -C $(PRINTPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
printproto-dirclean:
	rm -rf $(BUILD_DIR)/$(PRINTPROTO_DIR) $(PRINTPROTO_BUILD_DIR) $(PRINTPROTO_IPK_DIR) $(PRINTPROTO_IPK)
