###########################################################
#
# oniguruma
#
###########################################################
#
# ONIGURUMA_VERSION, ONIGURUMA_SITE and ONIGURUMA_SOURCE define
# the upstream location of the source code for the package.
# ONIGURUMA_DIR is the directory which is created when the source
# archive is unpacked.
# ONIGURUMA_UNZIP is the command used to unzip the source.
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
ONIGURUMA_URL=https://github.com/kkos/oniguruma/releases/download/v$(ONIGURUMA_VERSION)
ONIGURUMA_VERSION=6.9.1
ONIGURUMA_SOURCE=onig-$(ONIGURUMA_VERSION).tar.gz
ONIGURUMA_DIR=onig-$(ONIGURUMA_VERSION)
ONIGURUMA_UNZIP=zcat
ONIGURUMA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ONIGURUMA_DESCRIPTION=Regex Library Supporting Different Character Encodings
ONIGURUMA_SECTION=lib
ONIGURUMA_PRIORITY=optional
ONIGURUMA_DEPENDS=
ONIGURUMA_SUGGESTS=
ONIGURUMA_CONFLICTS=

#
# ONIGURUMA_IPK_VERSION should be incremented when the ipk changes.
#
ONIGURUMA_IPK_VERSION=1

#
# ONIGURUMA_CONFFILES should be a list of user-editable files
#ONIGURUMA_CONFFILES=$(TARGET_PREFIX)/etc/oniguruma.conf $(TARGET_PREFIX)/etc/init.d/SXXoniguruma

#
# ONIGURUMA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ONIGURUMA_PATCHES=$(ONIGURUMA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ONIGURUMA_CPPFLAGS=
ONIGURUMA_LDFLAGS=

#
# ONIGURUMA_BUILD_DIR is the directory in which the build is done.
# ONIGURUMA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ONIGURUMA_IPK_DIR is the directory in which the ipk is built.
# ONIGURUMA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ONIGURUMA_BUILD_DIR=$(BUILD_DIR)/oniguruma
ONIGURUMA_SOURCE_DIR=$(SOURCE_DIR)/oniguruma
ONIGURUMA_IPK_DIR=$(BUILD_DIR)/oniguruma-$(ONIGURUMA_VERSION)-ipk
ONIGURUMA_IPK=$(BUILD_DIR)/oniguruma_$(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)_$(TARGET_ARCH).ipk
ONIGURUMA_DEV_IPK_DIR=$(BUILD_DIR)/oniguruma-dev-$(ONIGURUMA_VERSION)-ipk
ONIGURUMA_DEV_IPK=$(BUILD_DIR)/oniguruma-dev_$(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: oniguruma-source oniguruma-unpack oniguruma oniguruma-stage oniguruma-ipk oniguruma-clean oniguruma-dirclean oniguruma-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(ONIGURUMA_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(ONIGURUMA_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(ONIGURUMA_SOURCE).sha512
#
$(DL_DIR)/$(ONIGURUMA_SOURCE):
	$(WGET) -P $(@D) $(ONIGURUMA_URL)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
oniguruma-source: $(DL_DIR)/$(ONIGURUMA_SOURCE) $(ONIGURUMA_PATCHES)

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
$(ONIGURUMA_BUILD_DIR)/.configured: $(DL_DIR)/$(ONIGURUMA_SOURCE) $(ONIGURUMA_PATCHES) make/oniguruma.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ONIGURUMA_DIR) $(@D)
	$(ONIGURUMA_UNZIP) $(DL_DIR)/$(ONIGURUMA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ONIGURUMA_PATCHES)" ; \
		then cat $(ONIGURUMA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ONIGURUMA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ONIGURUMA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ONIGURUMA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ONIGURUMA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ONIGURUMA_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

oniguruma-unpack: $(ONIGURUMA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ONIGURUMA_BUILD_DIR)/.built: $(ONIGURUMA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
oniguruma: $(ONIGURUMA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ONIGURUMA_BUILD_DIR)/.staged: $(ONIGURUMA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

oniguruma-stage: $(ONIGURUMA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/oniguruma
#
$(ONIGURUMA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: oniguruma" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ONIGURUMA_PRIORITY)" >>$@
	@echo "Section: $(ONIGURUMA_SECTION)" >>$@
	@echo "Version: $(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ONIGURUMA_MAINTAINER)" >>$@
	@echo "Source: $(ONIGURUMA_URL)" >>$@
	@echo "Description: $(ONIGURUMA_DESCRIPTION)" >>$@
	@echo "Depends: $(ONIGURUMA_DEPENDS)" >>$@
	@echo "Suggests: $(ONIGURUMA_SUGGESTS)" >>$@
	@echo "Conflicts: $(ONIGURUMA_CONFLICTS)" >>$@

$(ONIGURUMA_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: oniguruma-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ONIGURUMA_PRIORITY)" >>$@
	@echo "Section: $(ONIGURUMA_SECTION)" >>$@
	@echo "Version: $(ONIGURUMA_VERSION)-$(ONIGURUMA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ONIGURUMA_MAINTAINER)" >>$@
	@echo "Source: $(ONIGURUMA_URL)" >>$@
	@echo "Description: Development files for oniguruma" >>$@
	@echo "Depends: oniguruma" >>$@
	@echo "Suggests: $(ONIGURUMA_SUGGESTS)" >>$@
	@echo "Conflicts: $(ONIGURUMA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/etc/oniguruma/...
# Documentation files should be installed in $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/doc/oniguruma/...
# Daemon startup scripts should be installed in $(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??oniguruma
#
# You may need to patch your application to make it use these locations.
#
$(ONIGURUMA_IPK) $(ONIGURUMA_DEV_IPK): $(ONIGURUMA_BUILD_DIR)/.built
	rm -rf	$(ONIGURUMA_IPK_DIR) $(BUILD_DIR)/oniguruma_*_$(TARGET_ARCH).ipk \
		$(ONIGURUMA_DEV_IPK_DIR) $(BUILD_DIR)/oniguruma-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ONIGURUMA_BUILD_DIR) DESTDIR=$(ONIGURUMA_IPK_DIR) install-strip
	$(MAKE) -C $(ONIGURUMA_BUILD_DIR) DESTDIR=$(ONIGURUMA_DEV_IPK_DIR) install-strip
	rm -fr	$(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/bin \
		$(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/include \
		$(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig \
		$(ONIGURUMA_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	rm -fr	$(ONIGURUMA_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/libonig.so* \
		$(ONIGURUMA_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(MAKE) $(ONIGURUMA_IPK_DIR)/CONTROL/control
	$(MAKE) $(ONIGURUMA_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ONIGURUMA_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ONIGURUMA_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ONIGURUMA_IPK_DIR) $(ONIGURUMA_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
oniguruma-ipk: $(ONIGURUMA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
oniguruma-clean:
	rm -f $(ONIGURUMA_BUILD_DIR)/.built
	-$(MAKE) -C $(ONIGURUMA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
oniguruma-dirclean:
	rm -rf	$(BUILD_DIR)/$(ONIGURUMA_DIR) $(ONIGURUMA_BUILD_DIR) \
		$(ONIGURUMA_IPK_DIR) $(ONIGURUMA_IPK) \
		$(ONIGURUMA_DEV_IPK_DIR) $(ONIGURUMA_DEV_IPK)
#
#
# Some sanity check for the package.
#
oniguruma-check: $(ONIGURUMA_IPK) $(ONIGURUMA_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
