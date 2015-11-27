###########################################################
#
# libsodium
#
###########################################################
#
# LIBSODIUM_VERSION, LIBSODIUM_SITE and LIBSODIUM_SOURCE define
# the upstream location of the source code for the package.
# LIBSODIUM_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSODIUM_UNZIP is the command used to unzip the source.
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
LIBSODIUM_URL=https://github.com/jedisct1/libsodium/releases/download/$(LIBSODIUM_VERSION)/libsodium-$(LIBSODIUM_VERSION).tar.gz
LIBSODIUM_VERSION=1.0.6
LIBSODIUM_SOURCE=libsodium-$(LIBSODIUM_VERSION).tar.gz
LIBSODIUM_DIR=libsodium-$(LIBSODIUM_VERSION)
LIBSODIUM_UNZIP=zcat
LIBSODIUM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSODIUM_DESCRIPTION=A modern and easy-to-use crypto library.
LIBSODIUM_SECTION=libs
LIBSODIUM_PRIORITY=optional
LIBSODIUM_DEPENDS=
LIBSODIUM_SUGGESTS=
LIBSODIUM_CONFLICTS=

#
# LIBSODIUM_IPK_VERSION should be incremented when the ipk changes.
#
LIBSODIUM_IPK_VERSION=1

#
# LIBSODIUM_CONFFILES should be a list of user-editable files
#LIBSODIUM_CONFFILES=$(TARGET_PREFIX)/etc/libsodium.conf $(TARGET_PREFIX)/etc/init.d/SXXlibsodium

#
# LIBSODIUM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSODIUM_PATCHES=$(LIBSODIUM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSODIUM_CPPFLAGS=
LIBSODIUM_LDFLAGS=

#
# LIBSODIUM_BUILD_DIR is the directory in which the build is done.
# LIBSODIUM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSODIUM_IPK_DIR is the directory in which the ipk is built.
# LIBSODIUM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSODIUM_BUILD_DIR=$(BUILD_DIR)/libsodium
LIBSODIUM_SOURCE_DIR=$(SOURCE_DIR)/libsodium
LIBSODIUM_IPK_DIR=$(BUILD_DIR)/libsodium-$(LIBSODIUM_VERSION)-ipk
LIBSODIUM_IPK=$(BUILD_DIR)/libsodium_$(LIBSODIUM_VERSION)-$(LIBSODIUM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libsodium-source libsodium-unpack libsodium libsodium-stage libsodium-ipk libsodium-clean libsodium-dirclean libsodium-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBSODIUM_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBSODIUM_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBSODIUM_SOURCE).sha512
#
$(DL_DIR)/$(LIBSODIUM_SOURCE):
	$(WGET) -O $@ $(LIBSODIUM_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsodium-source: $(DL_DIR)/$(LIBSODIUM_SOURCE) $(LIBSODIUM_PATCHES)

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
$(LIBSODIUM_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSODIUM_SOURCE) $(LIBSODIUM_PATCHES) make/libsodium.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBSODIUM_DIR) $(@D)
	$(LIBSODIUM_UNZIP) $(DL_DIR)/$(LIBSODIUM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSODIUM_PATCHES)" ; \
		then cat $(LIBSODIUM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBSODIUM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSODIUM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBSODIUM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSODIUM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSODIUM_LDFLAGS)" \
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

libsodium-unpack: $(LIBSODIUM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSODIUM_BUILD_DIR)/.built: $(LIBSODIUM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libsodium: $(LIBSODIUM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSODIUM_BUILD_DIR)/.staged: $(LIBSODIUM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(addprefix $(STAGING_LIB_DIR)/,libsse2.la libaesni.la libsse41.la libssse3.la libsodium.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libsodium.pc
	touch $@

libsodium-stage: $(LIBSODIUM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsodium
#
$(LIBSODIUM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libsodium" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSODIUM_PRIORITY)" >>$@
	@echo "Section: $(LIBSODIUM_SECTION)" >>$@
	@echo "Version: $(LIBSODIUM_VERSION)-$(LIBSODIUM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSODIUM_MAINTAINER)" >>$@
	@echo "Source: $(LIBSODIUM_URL)" >>$@
	@echo "Description: $(LIBSODIUM_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSODIUM_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSODIUM_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSODIUM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/libsodium/...
# Documentation files should be installed in $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/doc/libsodium/...
# Daemon startup scripts should be installed in $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libsodium
#
# You may need to patch your application to make it use these locations.
#
$(LIBSODIUM_IPK): $(LIBSODIUM_BUILD_DIR)/.built
	rm -rf $(LIBSODIUM_IPK_DIR) $(BUILD_DIR)/libsodium_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSODIUM_BUILD_DIR) DESTDIR=$(LIBSODIUM_IPK_DIR) install-strip
	rm -f $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBSODIUM_SOURCE_DIR)/libsodium.conf $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/libsodium.conf
#	$(INSTALL) -d $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBSODIUM_SOURCE_DIR)/rc.libsodium $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibsodium
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSODIUM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibsodium
	$(MAKE) $(LIBSODIUM_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBSODIUM_SOURCE_DIR)/postinst $(LIBSODIUM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSODIUM_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBSODIUM_SOURCE_DIR)/prerm $(LIBSODIUM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSODIUM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBSODIUM_IPK_DIR)/CONTROL/postinst $(LIBSODIUM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBSODIUM_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSODIUM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSODIUM_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBSODIUM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsodium-ipk: $(LIBSODIUM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsodium-clean:
	rm -f $(LIBSODIUM_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSODIUM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsodium-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSODIUM_DIR) $(LIBSODIUM_BUILD_DIR) $(LIBSODIUM_IPK_DIR) $(LIBSODIUM_IPK)
#
#
# Some sanity check for the package.
#
libsodium-check: $(LIBSODIUM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
