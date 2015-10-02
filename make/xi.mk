###########################################################
#
# xi
#
###########################################################

#
# XI_VERSION, XI_SITE and XI_SOURCE define
# the upstream location of the source code for the package.
# XI_DIR is the directory which is created when the source
# archive is unpacked.
#
XI_SITE=http://xorg.freedesktop.org/releases/individual/lib
XI_SOURCE=libXi-$(XI_VERSION).tar.gz
XI_VERSION=1.7
XI_FULL_VERSION=$(XI_VERSION)
XI_DIR=libXi-$(XI_VERSION)
XI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XI_DESCRIPTION=library for the X Input Extension
XI_SECTION=lib
XI_PRIORITY=optional
XI_DEPENDS=x11, xext

#
# XI_IPK_VERSION should be incremented when the ipk changes.
#
XI_IPK_VERSION=1

#
# XI_CONFFILES should be a list of user-editable files
XI_CONFFILES=

#
# XI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XI_PATCHES=$(XI_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XI_CPPFLAGS=
XI_LDFLAGS=

#
# XI_BUILD_DIR is the directory in which the build is done.
# XI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XI_IPK_DIR is the directory in which the ipk is built.
# XI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XI_BUILD_DIR=$(BUILD_DIR)/xi
XI_SOURCE_DIR=$(SOURCE_DIR)/xi
XI_IPK_DIR=$(BUILD_DIR)/xi-$(XI_FULL_VERSION)-ipk
XI_IPK=$(BUILD_DIR)/xi_$(XI_FULL_VERSION)-$(XI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XI_PRIORITY)" >>$@
	@echo "Section: $(XI_SECTION)" >>$@
	@echo "Version: $(XI_FULL_VERSION)-$(XI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XI_MAINTAINER)" >>$@
	@echo "Source: $(XI_SITE)/$(XI_SOURCE)" >>$@
	@echo "Description: $(XI_DESCRIPTION)" >>$@
	@echo "Depends: $(XI_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XI_SOURCE):
	$(WGET) -P $(@D) $(XI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xi-source: $(DL_DIR)/$(XI_SOURCE) $(XI_PATCHES)

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
$(XI_BUILD_DIR)/.configured: $(DL_DIR)/$(XI_SOURCE) $(XI_PATCHES) make/xi.mk
	$(MAKE) xorg-macros-stage xproto-stage x11-stage xextproto-stage \
		xext-stage inputproto-stage
	rm -rf $(BUILD_DIR)/$(XI_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XI_SOURCE)
	if test -n "$(XI_PATCHES)" ; \
		then cat $(XI_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XI_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

xi-unpack: $(XI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XI_BUILD_DIR)/.built: $(XI_BUILD_DIR)/.configured
	rm -f $@
	### a very odd xi/inputproto bug:
	### xi fails on intial build with lots of errors,
	### but builds fine after re-building and
	### re-staging inputproto
	$(MAKE) -C $(@D) || \
	( \
		$(MAKE) inputproto-dirclean inputproto-stage && \
		$(MAKE) -C $(@D) \
	)
	touch $@

#
# This is the build convenience target.
#
xi: $(XI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XI_BUILD_DIR)/.staged: $(XI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xi.pc
	rm -f $(STAGING_LIB_DIR)/libXi.la
	touch $@

xi-stage: $(XI_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XI_IPK_DIR)/opt/sbin or $(XI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XI_IPK_DIR)/opt/etc/xi/...
# Documentation files should be installed in $(XI_IPK_DIR)/opt/doc/xi/...
# Daemon startup scripts should be installed in $(XI_IPK_DIR)/opt/etc/init.d/S??xi
#
# You may need to patch your application to make it use these locations.
#
$(XI_IPK): $(XI_BUILD_DIR)/.built
	rm -rf $(XI_IPK_DIR) $(BUILD_DIR)/xi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XI_BUILD_DIR) DESTDIR=$(XI_IPK_DIR) install-strip
	$(MAKE) $(XI_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XI_SOURCE_DIR)/postinst $(XI_IPK_DIR)/CONTROL/postinst
	rm -f $(XI_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xi-ipk: $(XI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xi-clean:
	-$(MAKE) -C $(XI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xi-dirclean:
	rm -rf $(BUILD_DIR)/$(XI_DIR) $(XI_BUILD_DIR) $(XI_IPK_DIR) $(XI_IPK)
