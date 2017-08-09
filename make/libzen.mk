###########################################################
#
# libzen
#
###########################################################
#
# LIBZEN_VERSION, LIBZEN_SITE and LIBZEN_SOURCE define
# the upstream location of the source code for the package.
# LIBZEN_DIR is the directory which is created when the source
# archive is unpacked.
# LIBZEN_UNZIP is the command used to unzip the source.
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
LIBZEN_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/zenlib/libzen_$(LIBZEN_VERSION).tar.bz2
LIBZEN_VERSION=0.4.31
LIBZEN_SOURCE=libzen_$(LIBZEN_VERSION).tar.bz2
LIBZEN_DIR=ZenLib
LIBZEN_UNZIP=bzcat
LIBZEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBZEN_DESCRIPTION=Small C++ derivate class to have a simpler life.
LIBZEN_SECTION=lib
LIBZEN_PRIORITY=optional
LIBZEN_DEPENDS=libstdc++
LIBZEN_SUGGESTS=
LIBZEN_CONFLICTS=

#
# LIBZEN_IPK_VERSION should be incremented when the ipk changes.
#
LIBZEN_IPK_VERSION=1

#
# LIBZEN_CONFFILES should be a list of user-editable files
#LIBZEN_CONFFILES=$(TARGET_PREFIX)/etc/libzen.conf $(TARGET_PREFIX)/etc/init.d/SXXlibzen

#
# LIBZEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBZEN_PATCHES=$(LIBZEN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBZEN_CPPFLAGS=
LIBZEN_LDFLAGS=

#
# LIBZEN_BUILD_DIR is the directory in which the build is done.
# LIBZEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBZEN_IPK_DIR is the directory in which the ipk is built.
# LIBZEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBZEN_BUILD_DIR=$(BUILD_DIR)/libzen
LIBZEN_SOURCE_DIR=$(SOURCE_DIR)/libzen
LIBZEN_IPK_DIR=$(BUILD_DIR)/libzen-$(LIBZEN_VERSION)-ipk
LIBZEN_IPK=$(BUILD_DIR)/libzen_$(LIBZEN_VERSION)-$(LIBZEN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libzen-source libzen-unpack libzen libzen-stage libzen-ipk libzen-clean libzen-dirclean libzen-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBZEN_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBZEN_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBZEN_SOURCE).sha512
#
$(DL_DIR)/$(LIBZEN_SOURCE):
	$(WGET) -O $@ $(LIBZEN_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libzen-source: $(DL_DIR)/$(LIBZEN_SOURCE) $(LIBZEN_PATCHES)

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
$(LIBZEN_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBZEN_SOURCE) $(LIBZEN_PATCHES) make/libzen.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBZEN_DIR) $(@D)
	$(LIBZEN_UNZIP) $(DL_DIR)/$(LIBZEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBZEN_PATCHES)" ; \
		then cat $(LIBZEN_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBZEN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBZEN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBZEN_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)/Project/GNU/Library
	(cd $(@D)/Project/GNU/Library; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBZEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBZEN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/Project/GNU/Library/libtool
	touch $@

libzen-unpack: $(LIBZEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBZEN_BUILD_DIR)/.built: $(LIBZEN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/Library
	touch $@

#
# This is the build convenience target.
#
libzen: $(LIBZEN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBZEN_BUILD_DIR)/.staged: $(LIBZEN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/Library DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libzen.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libzen.pc
	touch $@

libzen-stage: $(LIBZEN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libzen
#
$(LIBZEN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libzen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBZEN_PRIORITY)" >>$@
	@echo "Section: $(LIBZEN_SECTION)" >>$@
	@echo "Version: $(LIBZEN_VERSION)-$(LIBZEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBZEN_MAINTAINER)" >>$@
	@echo "Source: $(LIBZEN_URL)" >>$@
	@echo "Description: $(LIBZEN_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBZEN_DEPENDS)" >>$@
	@echo "Suggests: $(LIBZEN_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBZEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/libzen/...
# Documentation files should be installed in $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/doc/libzen/...
# Daemon startup scripts should be installed in $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libzen
#
# You may need to patch your application to make it use these locations.
#
$(LIBZEN_IPK): $(LIBZEN_BUILD_DIR)/.built
	rm -rf $(LIBZEN_IPK_DIR) $(BUILD_DIR)/libzen_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBZEN_BUILD_DIR)/Project/GNU/Library DESTDIR=$(LIBZEN_IPK_DIR) install-strip
	rm -f $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/lib/libzen.la
#	$(INSTALL) -d $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBZEN_SOURCE_DIR)/libzen.conf $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/libzen.conf
#	$(INSTALL) -d $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBZEN_SOURCE_DIR)/rc.libzen $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibzen
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBZEN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibzen
	$(MAKE) $(LIBZEN_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBZEN_SOURCE_DIR)/postinst $(LIBZEN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBZEN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBZEN_SOURCE_DIR)/prerm $(LIBZEN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBZEN_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBZEN_IPK_DIR)/CONTROL/postinst $(LIBZEN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBZEN_CONFFILES) | sed -e 's/ /\n/g' > $(LIBZEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBZEN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBZEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libzen-ipk: $(LIBZEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libzen-clean:
	rm -f $(LIBZEN_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBZEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libzen-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBZEN_DIR) $(LIBZEN_BUILD_DIR) $(LIBZEN_IPK_DIR) $(LIBZEN_IPK)
#
#
# Some sanity check for the package.
#
libzen-check: $(LIBZEN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
