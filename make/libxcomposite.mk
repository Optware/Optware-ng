###########################################################
#
# libxcomposite
#
###########################################################
#
# LIBXCOMPOSITE_VERSION, LIBXCOMPOSITE_SITE and LIBXCOMPOSITE_SOURCE define
# the upstream location of the source code for the package.
# LIBXCOMPOSITE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXCOMPOSITE_UNZIP is the command used to unzip the source.
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
LIBXCOMPOSITE_URL=http://xorg.freedesktop.org/archive/individual/lib/libXcomposite-$(LIBXCOMPOSITE_VERSION).tar.gz
LIBXCOMPOSITE_VERSION=0.4.4
LIBXCOMPOSITE_SOURCE=libXcomposite-$(LIBXCOMPOSITE_VERSION).tar.gz
LIBXCOMPOSITE_DIR=libXcomposite-$(LIBXCOMPOSITE_VERSION)
LIBXCOMPOSITE_UNZIP=zcat
LIBXCOMPOSITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBXCOMPOSITE_DESCRIPTION=X11 Composite extension library.
LIBXCOMPOSITE_SECTION=lib
LIBXCOMPOSITE_PRIORITY=optional
LIBXCOMPOSITE_DEPENDS=x11, xfixes
LIBXCOMPOSITE_SUGGESTS=
LIBXCOMPOSITE_CONFLICTS=

#
# LIBXCOMPOSITE_IPK_VERSION should be incremented when the ipk changes.
#
LIBXCOMPOSITE_IPK_VERSION=2

#
# LIBXCOMPOSITE_CONFFILES should be a list of user-editable files
#LIBXCOMPOSITE_CONFFILES=$(TARGET_PREFIX)/etc/libxcomposite.conf $(TARGET_PREFIX)/etc/init.d/SXXlibxcomposite

#
# LIBXCOMPOSITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBXCOMPOSITE_PATCHES=$(LIBXCOMPOSITE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXCOMPOSITE_CPPFLAGS=
LIBXCOMPOSITE_LDFLAGS=

#
# LIBXCOMPOSITE_BUILD_DIR is the directory in which the build is done.
# LIBXCOMPOSITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXCOMPOSITE_IPK_DIR is the directory in which the ipk is built.
# LIBXCOMPOSITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXCOMPOSITE_BUILD_DIR=$(BUILD_DIR)/libxcomposite
LIBXCOMPOSITE_SOURCE_DIR=$(SOURCE_DIR)/libxcomposite
LIBXCOMPOSITE_IPK_DIR=$(BUILD_DIR)/libxcomposite-$(LIBXCOMPOSITE_VERSION)-ipk
LIBXCOMPOSITE_IPK=$(BUILD_DIR)/libxcomposite_$(LIBXCOMPOSITE_VERSION)-$(LIBXCOMPOSITE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libxcomposite-source libxcomposite-unpack libxcomposite libxcomposite-stage libxcomposite-ipk libxcomposite-clean libxcomposite-dirclean libxcomposite-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBXCOMPOSITE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBXCOMPOSITE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBXCOMPOSITE_SOURCE).sha512
#
$(DL_DIR)/$(LIBXCOMPOSITE_SOURCE):
	$(WGET) -O $@ $(LIBXCOMPOSITE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxcomposite-source: $(DL_DIR)/$(LIBXCOMPOSITE_SOURCE) $(LIBXCOMPOSITE_PATCHES)

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
$(LIBXCOMPOSITE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXCOMPOSITE_SOURCE) $(LIBXCOMPOSITE_PATCHES) make/libxcomposite.mk
	$(MAKE) compositeproto-stage xorg-macros-stage x11-stage xfixes-stage
	rm -rf $(BUILD_DIR)/$(LIBXCOMPOSITE_DIR) $(@D)
	$(LIBXCOMPOSITE_UNZIP) $(DL_DIR)/$(LIBXCOMPOSITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBXCOMPOSITE_PATCHES)" ; \
		then cat $(LIBXCOMPOSITE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBXCOMPOSITE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBXCOMPOSITE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBXCOMPOSITE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXCOMPOSITE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXCOMPOSITE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libxcomposite-unpack: $(LIBXCOMPOSITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXCOMPOSITE_BUILD_DIR)/.built: $(LIBXCOMPOSITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libxcomposite: $(LIBXCOMPOSITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXCOMPOSITE_BUILD_DIR)/.staged: $(LIBXCOMPOSITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xcomposite.pc
	rm -f $(STAGING_LIB_DIR)/libXcomposite.la
	touch $@

libxcomposite-stage: $(LIBXCOMPOSITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libxcomposite
#
$(LIBXCOMPOSITE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libxcomposite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXCOMPOSITE_PRIORITY)" >>$@
	@echo "Section: $(LIBXCOMPOSITE_SECTION)" >>$@
	@echo "Version: $(LIBXCOMPOSITE_VERSION)-$(LIBXCOMPOSITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXCOMPOSITE_MAINTAINER)" >>$@
	@echo "Source: $(LIBXCOMPOSITE_URL)" >>$@
	@echo "Description: $(LIBXCOMPOSITE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXCOMPOSITE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXCOMPOSITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXCOMPOSITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/libxcomposite/...
# Documentation files should be installed in $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/doc/libxcomposite/...
# Daemon startup scripts should be installed in $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libxcomposite
#
# You may need to patch your application to make it use these locations.
#
$(LIBXCOMPOSITE_IPK): $(LIBXCOMPOSITE_BUILD_DIR)/.built
	rm -rf $(LIBXCOMPOSITE_IPK_DIR) $(BUILD_DIR)/libxcomposite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBXCOMPOSITE_BUILD_DIR) DESTDIR=$(LIBXCOMPOSITE_IPK_DIR) install-strip
	rm -f $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBXCOMPOSITE_SOURCE_DIR)/libxcomposite.conf $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/libxcomposite.conf
#	$(INSTALL) -d $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBXCOMPOSITE_SOURCE_DIR)/rc.libxcomposite $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibxcomposite
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXCOMPOSITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibxcomposite
	$(MAKE) $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBXCOMPOSITE_SOURCE_DIR)/postinst $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBXCOMPOSITE_SOURCE_DIR)/prerm $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBXCOMPOSITE_IPK_DIR)/CONTROL/postinst $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBXCOMPOSITE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXCOMPOSITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXCOMPOSITE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXCOMPOSITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libxcomposite-ipk: $(LIBXCOMPOSITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libxcomposite-clean:
	rm -f $(LIBXCOMPOSITE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBXCOMPOSITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxcomposite-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXCOMPOSITE_DIR) $(LIBXCOMPOSITE_BUILD_DIR) $(LIBXCOMPOSITE_IPK_DIR) $(LIBXCOMPOSITE_IPK)
#
#
# Some sanity check for the package.
#
libxcomposite-check: $(LIBXCOMPOSITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
