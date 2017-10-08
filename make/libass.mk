###########################################################
#
# libass
#
###########################################################
#
# LIBASS_VERSION, LIBASS_SITE and LIBASS_SOURCE define
# the upstream location of the source code for the package.
# LIBASS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBASS_UNZIP is the command used to unzip the source.
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
LIBASS_URL=https://github.com/libass/libass/releases/download/$(LIBASS_VERSION)/libass-$(LIBASS_VERSION).tar.gz
LIBASS_VERSION=0.13.7
LIBASS_SOURCE=libass-$(LIBASS_VERSION).tar.gz
LIBASS_DIR=libass-$(LIBASS_VERSION)
LIBASS_UNZIP=zcat
LIBASS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBASS_DESCRIPTION=libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format.
LIBASS_SECTION=libs
LIBASS_PRIORITY=optional
LIBASS_DEPENDS=fribidi, freetype, fontconfig, libpng
LIBASS_SUGGESTS=
LIBASS_CONFLICTS=

#
# LIBASS_IPK_VERSION should be incremented when the ipk changes.
#
LIBASS_IPK_VERSION=1

#
# LIBASS_CONFFILES should be a list of user-editable files
#LIBASS_CONFFILES=$(TARGET_PREFIX)/etc/libass.conf $(TARGET_PREFIX)/etc/init.d/SXXlibass

#
# LIBASS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBASS_PATCHES=$(LIBASS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBASS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
LIBASS_LDFLAGS=

#
# LIBASS_BUILD_DIR is the directory in which the build is done.
# LIBASS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBASS_IPK_DIR is the directory in which the ipk is built.
# LIBASS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBASS_BUILD_DIR=$(BUILD_DIR)/libass
LIBASS_SOURCE_DIR=$(SOURCE_DIR)/libass
LIBASS_IPK_DIR=$(BUILD_DIR)/libass-$(LIBASS_VERSION)-ipk
LIBASS_IPK=$(BUILD_DIR)/libass_$(LIBASS_VERSION)-$(LIBASS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libass-source libass-unpack libass libass-stage libass-ipk libass-clean libass-dirclean libass-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBASS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBASS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBASS_SOURCE).sha512
#
$(DL_DIR)/$(LIBASS_SOURCE):
	$(WGET) -O $@ $(LIBASS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libass-source: $(DL_DIR)/$(LIBASS_SOURCE) $(LIBASS_PATCHES)

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
$(LIBASS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBASS_SOURCE) $(LIBASS_PATCHES) make/libass.mk
	$(MAKE) fribidi-stage freetype-stage fontconfig-stage libpng-stage
	rm -rf $(BUILD_DIR)/$(LIBASS_DIR) $(@D)
	$(LIBASS_UNZIP) $(DL_DIR)/$(LIBASS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBASS_PATCHES)" ; \
		then cat $(LIBASS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBASS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBASS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBASS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBASS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBASS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-harfbuzz \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libass-unpack: $(LIBASS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBASS_BUILD_DIR)/.built: $(LIBASS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libass: $(LIBASS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBASS_BUILD_DIR)/.staged: $(LIBASS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libass.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libass.pc
	touch $@

libass-stage: $(LIBASS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libass
#
$(LIBASS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libass" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBASS_PRIORITY)" >>$@
	@echo "Section: $(LIBASS_SECTION)" >>$@
	@echo "Version: $(LIBASS_VERSION)-$(LIBASS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBASS_MAINTAINER)" >>$@
	@echo "Source: $(LIBASS_URL)" >>$@
	@echo "Description: $(LIBASS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBASS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBASS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBASS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/libass/...
# Documentation files should be installed in $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/doc/libass/...
# Daemon startup scripts should be installed in $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libass
#
# You may need to patch your application to make it use these locations.
#
$(LIBASS_IPK): $(LIBASS_BUILD_DIR)/.built
	rm -rf $(LIBASS_IPK_DIR) $(BUILD_DIR)/libass_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBASS_BUILD_DIR) DESTDIR=$(LIBASS_IPK_DIR) install-strip
	rm -f $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBASS_SOURCE_DIR)/libass.conf $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/libass.conf
#	$(INSTALL) -d $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBASS_SOURCE_DIR)/rc.libass $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibass
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibass
	$(MAKE) $(LIBASS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBASS_SOURCE_DIR)/postinst $(LIBASS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBASS_SOURCE_DIR)/prerm $(LIBASS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBASS_IPK_DIR)/CONTROL/postinst $(LIBASS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBASS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBASS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBASS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBASS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libass-ipk: $(LIBASS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libass-clean:
	rm -f $(LIBASS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBASS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libass-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBASS_DIR) $(LIBASS_BUILD_DIR) $(LIBASS_IPK_DIR) $(LIBASS_IPK)
#
#
# Some sanity check for the package.
#
libass-check: $(LIBASS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
