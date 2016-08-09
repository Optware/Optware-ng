###########################################################
#
# sm
#
###########################################################

#
# SM_VERSION, SM_SITE and SM_SOURCE define
# the upstream location of the source code for the package.
# SM_DIR is the directory which is created when the source
# archive is unpacked.
#
SM_SITE=http://xorg.freedesktop.org/releases/individual/lib
SM_SOURCE=libSM-$(SM_VERSION).tar.gz
SM_VERSION=1.2.2
SM_FULL_VERSION=release-$(SM_VERSION)
SM_DIR=libSM-$(SM_VERSION)
SM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SM_DESCRIPTION=X session management library
SM_SECTION=lib
SM_PRIORITY=optional
SM_DEPENDS=ice, e2fslibs

#
# SM_IPK_VERSION should be incremented when the ipk changes.
#
SM_IPK_VERSION=2

#
# SM_CONFFILES should be a list of user-editable files
SM_CONFFILES=

#
# SM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SM_PATCHES=$(SM_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SM_CPPFLAGS=
SM_LDFLAGS=

#
# SM_BUILD_DIR is the directory in which the build is done.
# SM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SM_IPK_DIR is the directory in which the ipk is built.
# SM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SM_BUILD_DIR=$(BUILD_DIR)/sm
SM_SOURCE_DIR=$(SOURCE_DIR)/sm
SM_IPK_DIR=$(BUILD_DIR)/sm-$(SM_FULL_VERSION)-ipk
SM_IPK=$(BUILD_DIR)/sm_$(SM_FULL_VERSION)-$(SM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(SM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(SM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SM_PRIORITY)" >>$@
	@echo "Section: $(SM_SECTION)" >>$@
	@echo "Version: $(SM_FULL_VERSION)-$(SM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SM_MAINTAINER)" >>$@
	@echo "Source: $(SM_SITE)/$(SM_SOURCE)" >>$@
	@echo "Description: $(SM_DESCRIPTION)" >>$@
	@echo "Depends: $(SM_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SM_SOURCE):
	$(WGET) -P $(@D) $(SM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

sm-source: $(DL_DIR)/$(SM_SOURCE) $(SM_PATCHES)

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
$(SM_BUILD_DIR)/.configured: $(DL_DIR)/$(SM_SOURCE) \
		$(SM_PATCHES) make/sm.mk
	$(MAKE) ice-stage e2fslibs-stage
	rm -rf $(BUILD_DIR)/$(SM_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(SM_SOURCE)
	if test -n "$(SM_PATCHES)" ; \
		then cat $(SM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SM_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SM_DIR)" != "$(SM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SM_DIR) $(SM_BUILD_DIR) ; \
	fi
	(cd $(SM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SM_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(SM_BUILD_DIR)/libtool
	touch $@

sm-unpack: $(SM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SM_BUILD_DIR)/.built: $(SM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SM_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
sm: $(SM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SM_BUILD_DIR)/.staged: $(SM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/sm.pc
	rm -f $(STAGING_LIB_DIR)/libSM.la
	touch $@

sm-stage: $(SM_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
$(SM_IPK): $(SM_BUILD_DIR)/.built
	rm -rf $(SM_IPK_DIR) $(BUILD_DIR)/sm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SM_BUILD_DIR) DESTDIR=$(SM_IPK_DIR) install-strip
	$(MAKE) $(SM_IPK_DIR)/CONTROL/control
	rm -f $(SM_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sm-ipk: $(SM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sm-clean:
	rm -f $(SM_BUILD_DIR)/.built
	-$(MAKE) -C $(SM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sm-dirclean:
	rm -rf $(BUILD_DIR)/$(SM_DIR) $(SM_BUILD_DIR) $(SM_IPK_DIR) $(SM_IPK)

#
#
# Some sanity check for the package.
#
sm-check: $(SM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
