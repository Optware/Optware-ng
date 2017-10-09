###########################################################
#
# libconfig
#
###########################################################
#
# LIBCONFIG_VERSION, LIBCONFIG_SITE and LIBCONFIG_SOURCE define
# the upstream location of the source code for the package.
# LIBCONFIG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCONFIG_UNZIP is the command used to unzip the source.
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
LIBCONFIG_URL=http://www.hyperrealm.com/libconfig/libconfig-$(LIBCONFIG_VERSION).tar.gz
LIBCONFIG_VERSION=1.5
LIBCONFIG_SOURCE=libconfig-$(LIBCONFIG_VERSION).tar.gz
LIBCONFIG_DIR=libconfig-$(LIBCONFIG_VERSION)
LIBCONFIG_UNZIP=zcat
LIBCONFIG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCONFIG_DESCRIPTION=Libconfig is a simple library for processing structured configuration files. C language bindings.
LIBCONFIG++_DESCRIPTION=Libconfig is a simple library for processing structured configuration files. C++ language bindings.
LIBCONFIG_SECTION=libs
LIBCONFIG_PRIORITY=optional
LIBCONFIG_DEPENDS=
LIBCONFIG++_DEPENDS=libstdc++
LIBCONFIG_SUGGESTS=
LIBCONFIG_CONFLICTS=

#
# LIBCONFIG_IPK_VERSION should be incremented when the ipk changes.
#
LIBCONFIG_IPK_VERSION=2

#
# LIBCONFIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBCONFIG_PATCHES=$(LIBCONFIG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCONFIG_CPPFLAGS=
LIBCONFIG_LDFLAGS=

#
# LIBCONFIG_BUILD_DIR is the directory in which the build is done.
# LIBCONFIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCONFIG_IPK_DIR is the directory in which the ipk is built.
# LIBCONFIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCONFIG_BUILD_DIR=$(BUILD_DIR)/libconfig
LIBCONFIG_SOURCE_DIR=$(SOURCE_DIR)/libconfig

LIBCONFIG_IPK_DIR=$(BUILD_DIR)/libconfig-$(LIBCONFIG_VERSION)-ipk
LIBCONFIG_IPK=$(BUILD_DIR)/libconfig_$(LIBCONFIG_VERSION)-$(LIBCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBCONFIG++_IPK_DIR=$(BUILD_DIR)/libconfig++-$(LIBCONFIG_VERSION)-ipk
LIBCONFIG++_IPK=$(BUILD_DIR)/libconfig++_$(LIBCONFIG_VERSION)-$(LIBCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libconfig-source libconfig-unpack libconfig libconfig-stage libconfig-ipk libconfig-clean libconfig-dirclean libconfig-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBCONFIG_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBCONFIG_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBCONFIG_SOURCE).sha512
#
$(DL_DIR)/$(LIBCONFIG_SOURCE):
	$(WGET) -O $@ $(LIBCONFIG_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libconfig-source: $(DL_DIR)/$(LIBCONFIG_SOURCE) $(LIBCONFIG_PATCHES)

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
$(LIBCONFIG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCONFIG_SOURCE) $(LIBCONFIG_PATCHES) make/libconfig.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBCONFIG_DIR) $(@D)
	$(LIBCONFIG_UNZIP) $(DL_DIR)/$(LIBCONFIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBCONFIG_PATCHES)" ; \
		then cat $(LIBCONFIG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBCONFIG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBCONFIG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBCONFIG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCONFIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCONFIG_LDFLAGS)" \
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

libconfig-unpack: $(LIBCONFIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBCONFIG_BUILD_DIR)/.built: $(LIBCONFIG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libconfig: $(LIBCONFIG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCONFIG_BUILD_DIR)/.staged: $(LIBCONFIG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libconfig{++,}.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libconfig{++,}.pc
	touch $@

libconfig-stage: $(LIBCONFIG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libconfig
#
$(LIBCONFIG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libconfig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCONFIG_PRIORITY)" >>$@
	@echo "Section: $(LIBCONFIG_SECTION)" >>$@
	@echo "Version: $(LIBCONFIG_VERSION)-$(LIBCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(LIBCONFIG_URL)" >>$@
	@echo "Description: $(LIBCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCONFIG_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCONFIG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCONFIG_CONFLICTS)" >>$@

$(LIBCONFIG++_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libconfig++" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCONFIG_PRIORITY)" >>$@
	@echo "Section: $(LIBCONFIG_SECTION)" >>$@
	@echo "Version: $(LIBCONFIG_VERSION)-$(LIBCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(LIBCONFIG_URL)" >>$@
	@echo "Description: $(LIBCONFIG++_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCONFIG++_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCONFIG++_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCONFIG++_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/etc/libconfig/...
# Documentation files should be installed in $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/doc/libconfig/...
# Daemon startup scripts should be installed in $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libconfig
#
# You may need to patch your application to make it use these locations.
#
$(LIBCONFIG_IPK) $(LIBCONFIG++_IPK): $(LIBCONFIG_BUILD_DIR)/.built
	rm -rf $(LIBCONFIG_IPK_DIR) $(BUILD_DIR)/libconfig_*_$(TARGET_ARCH).ipk \
		$(LIBCONFIG++_IPK_DIR) $(BUILD_DIR)/libconfig++_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBCONFIG_BUILD_DIR) DESTDIR=$(LIBCONFIG_IPK_DIR) install-strip
	rm -rf $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/{lib/*.la,share}
	mkdir -p $(LIBCONFIG++_IPK_DIR)$(TARGET_PREFIX)/{include,lib/pkgconfig}
	mv -f $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/include/libconfig.h++ $(LIBCONFIG++_IPK_DIR)$(TARGET_PREFIX)/include
	mv -f $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/lib/libconfig++.* $(LIBCONFIG++_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(LIBCONFIG_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/libconfig++.pc $(LIBCONFIG++_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	$(MAKE) $(LIBCONFIG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCONFIG_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBCONFIG_IPK_DIR)
	$(MAKE) $(LIBCONFIG++_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCONFIG++_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBCONFIG++_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libconfig-ipk: $(LIBCONFIG_IPK) $(LIBCONFIG++_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libconfig-clean:
	rm -f $(LIBCONFIG_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBCONFIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libconfig-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCONFIG_DIR) $(LIBCONFIG_BUILD_DIR) \
		$(LIBCONFIG_IPK_DIR) $(LIBCONFIG_IPK) \
		$(LIBCONFIG++_IPK_DIR) $(LIBCONFIG++_IPK)
#
#
# Some sanity check for the package.
#
libconfig-check: $(LIBCONFIG_IPK) $(LIBCONFIG++_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
