###########################################################
#
# fontconfig
#
###########################################################

#
# FONTCONFIG_VERSION, FONTCONFIG_SITE and FONTCONFIG_SOURCE define
# the upstream location of the source code for the package.
# FONTCONFIG_DIR is the directory which is created when the source
# archive is unpacked.
#
FONTCONFIG_SITE=http://fontconfig.org/release
FONTCONFIG_VERSION=2.12.4
FONTCONFIG_SOURCE=fontconfig-$(FONTCONFIG_VERSION).tar.gz
FONTCONFIG_DIR=fontconfig-$(FONTCONFIG_VERSION)
FONTCONFIG_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
FONTCONFIG_DESCRIPTION=Font configuration library
FONTCONFIG_SECTION=lib
FONTCONFIG_PRIORITY=optional
FONTCONFIG_DEPENDS=expat, freetype, gconv-modules
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FONTCONFIG_DEPENDS+=, libiconv
endif

#
# FONTCONFIG_IPK_VERSION should be incremented when the ipk changes.
#
FONTCONFIG_IPK_VERSION=1

#
# FONTCONFIG_CONFFILES should be a list of user-editable files
FONTCONFIG_CONFFILES=

#
# FONTCONFIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FONTCONFIG_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FONTCONFIG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
FONTCONFIG_LDFLAGS=

#
# FONTCONFIG_BUILD_DIR is the directory in which the build is done.
# FONTCONFIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FONTCONFIG_IPK_DIR is the directory in which the ipk is built.
# FONTCONFIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FONTCONFIG_BUILD_DIR=$(BUILD_DIR)/fontconfig
FONTCONFIG_SOURCE_DIR=$(SOURCE_DIR)/fontconfig
FONTCONFIG_IPK_DIR=$(BUILD_DIR)/fontconfig-$(FONTCONFIG_VERSION)-ipk
FONTCONFIG_IPK=$(BUILD_DIR)/fontconfig_$(FONTCONFIG_VERSION)-$(FONTCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fontconfig-source fontconfig-unpack fontconfig fontconfig-stage fontconfig-ipk fontconfig-clean fontconfig-dirclean fontconfig-check


#
# Automatically create a ipkg control file
#
$(FONTCONFIG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: fontconfig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FONTCONFIG_PRIORITY)" >>$@
	@echo "Section: $(FONTCONFIG_SECTION)" >>$@
	@echo "Version: $(FONTCONFIG_VERSION)-$(FONTCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FONTCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(FONTCONFIG_SITE)/$(FONTCONFIG_SOURCE)" >>$@
	@echo "Description: $(FONTCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(FONTCONFIG_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/fontconfig-$(FONTCONFIG_VERSION).tar.gz:
	$(WGET) -P $(DL_DIR) $(FONTCONFIG_SITE)/$(FONTCONFIG_SOURCE)

fontconfig-source: $(DL_DIR)/fontconfig-$(FONTCONFIG_VERSION).tar.gz $(FONTCONFIG_PATCHES)

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
$(FONTCONFIG_BUILD_DIR)/.configured: $(DL_DIR)/fontconfig-$(FONTCONFIG_VERSION).tar.gz \
		$(FONTCONFIG_PATCHES) make/fontconfig.mk
	$(MAKE) freetype-stage expat-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(FONTCONFIG_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/fontconfig-$(FONTCONFIG_VERSION).tar.gz
	if test -n "$(FONTCONFIG_PATCHES)" ; \
		then cat $(FONTCONFIG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FONTCONFIG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FONTCONFIG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FONTCONFIG_DIR) $(@D) ; \
	fi
	sed -i -e '/^\(LDFLAGS\|CFLAGS\|CPPFLAGS\) =/s|=.*$$|=|' \
		$(@D)/fc-case/Makefile.in \
		$(@D)/fc-glyphname/Makefile.in \
		$(@D)/fc-lang/Makefile.in \
		;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FONTCONFIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FONTCONFIG_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_prog_HASDOCBOOK=no \
		./configure \
		--with-arch=$(TARGET_ARCH) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-default-fonts=$(TARGET_PREFIX)/share/fonts \
		--without-add-fonts \
		--with-freetype-config=$(STAGING_PREFIX)/bin/freetype-config \
		--disable-docs \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e 's|$(STAGING_INCLUDE_DIR)|\$${includedir}|g' -e 's|$(STAGING_LIB_DIR)|\$${libdir}|g' \
		$(@D)/fontconfig.pc
	touch $@

fontconfig-unpack: $(FONTCONFIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FONTCONFIG_BUILD_DIR)/.built: $(FONTCONFIG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fontconfig: $(FONTCONFIG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FONTCONFIG_BUILD_DIR)/.staged: $(FONTCONFIG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FONTCONFIG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libfontconfig.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fontconfig.pc
	touch $@

fontconfig-stage: $(FONTCONFIG_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/etc/fontconfig/...
# Documentation files should be installed in $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/doc/fontconfig/...
# Daemon startup scripts should be installed in $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??fontconfig
#
# You may need to patch your application to make it use these locations.
#
$(FONTCONFIG_IPK): $(FONTCONFIG_BUILD_DIR)/.built
	rm -rf $(FONTCONFIG_IPK_DIR) $(BUILD_DIR)/fontconfig_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FONTCONFIG_BUILD_DIR) DESTDIR=$(FONTCONFIG_IPK_DIR) install-strip
	rm -f $(FONTCONFIG_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(MAKE) $(FONTCONFIG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FONTCONFIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fontconfig-ipk: $(FONTCONFIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fontconfig-clean:
	-$(MAKE) -C $(FONTCONFIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fontconfig-dirclean:
	rm -rf $(BUILD_DIR)/$(FONTCONFIG_DIR) $(FONTCONFIG_BUILD_DIR) $(FONTCONFIG_IPK_DIR) $(FONTCONFIG_IPK)
#
# Some sanity check for the package.
#
fontconfig-check: $(FONTCONFIG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FONTCONFIG_IPK)
