###########################################################
#
# meganz-sdk
#
###########################################################
#
# MEGANZ_SDK_VERSION, MEGANZ_SDK_SITE and MEGANZ_SDK_SOURCE define
# the upstream location of the source code for the package.
# MEGANZ_SDK_DIR is the directory which is created when the source
# archive is unpacked.
# MEGANZ_SDK_UNZIP is the command used to unzip the source.
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
MEGANZ_SDK_URL=https://github.com/meganz/sdk/archive/v$(MEGANZ_SDK_VERSION).tar.gz
MEGANZ_SDK_VERSION=3.1.9
MEGANZ_SDK_SOURCE=meganz-sdk-$(MEGANZ_SDK_VERSION).tar.gz
MEGANZ_SDK_DIR=sdk-$(MEGANZ_SDK_VERSION)
MEGANZ_SDK_UNZIP=zcat
MEGANZ_SDK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEGANZ_SDK_DESCRIPTION=MEGA SDK - Client Access Engine.
MEGANZ_SDK_SECTION=misc
MEGANZ_SDK_PRIORITY=optional
MEGANZ_SDK_DEPENDS=libstdc++, c-ares, libcurl, zlib, libsodium, sqlite, openssl
MEGANZ_SDK_SUGGESTS=
MEGANZ_SDK_CONFLICTS=

#
# MEGANZ_SDK_IPK_VERSION should be incremented when the ipk changes.
#
MEGANZ_SDK_IPK_VERSION=3

#
# MEGANZ_SDK_CONFFILES should be a list of user-editable files
#MEGANZ_SDK_CONFFILES=$(TARGET_PREFIX)/etc/meganz-sdk.conf $(TARGET_PREFIX)/etc/init.d/SXXmeganz-sdk

#
# MEGANZ_SDK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MEGANZ_SDK_PATCHES=$(MEGANZ_SDK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEGANZ_SDK_CPPFLAGS=
MEGANZ_SDK_LDFLAGS=

#
# MEGANZ_SDK_BUILD_DIR is the directory in which the build is done.
# MEGANZ_SDK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEGANZ_SDK_IPK_DIR is the directory in which the ipk is built.
# MEGANZ_SDK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEGANZ_SDK_BUILD_DIR=$(BUILD_DIR)/meganz-sdk
MEGANZ_SDK_SOURCE_DIR=$(SOURCE_DIR)/meganz-sdk
MEGANZ_SDK_IPK_DIR=$(BUILD_DIR)/meganz-sdk-$(MEGANZ_SDK_VERSION)-ipk
MEGANZ_SDK_IPK=$(BUILD_DIR)/meganz-sdk_$(MEGANZ_SDK_VERSION)-$(MEGANZ_SDK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: meganz-sdk-source meganz-sdk-unpack meganz-sdk meganz-sdk-stage meganz-sdk-ipk meganz-sdk-clean meganz-sdk-dirclean meganz-sdk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(MEGANZ_SDK_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(MEGANZ_SDK_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(MEGANZ_SDK_SOURCE).sha512
#
$(DL_DIR)/$(MEGANZ_SDK_SOURCE):
	$(WGET) -O $@ $(MEGANZ_SDK_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
meganz-sdk-source: $(DL_DIR)/$(MEGANZ_SDK_SOURCE) $(MEGANZ_SDK_PATCHES)

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
$(MEGANZ_SDK_BUILD_DIR)/.configured: $(DL_DIR)/$(MEGANZ_SDK_SOURCE) $(MEGANZ_SDK_PATCHES) make/meganz-sdk.mk
	$(MAKE) c-ares-stage libcurl-stage zlib-stage crypto++-stage libsodium-stage \
		sqlite-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(MEGANZ_SDK_DIR) $(@D)
	$(MEGANZ_SDK_UNZIP) $(DL_DIR)/$(MEGANZ_SDK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEGANZ_SDK_PATCHES)" ; \
		then cat $(MEGANZ_SDK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MEGANZ_SDK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEGANZ_SDK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MEGANZ_SDK_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		OBJCXX=$(TARGET_CXX) \
		AM_LIBTOOLFLAGS="--tag=CXX" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MEGANZ_SDK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MEGANZ_SDK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--without-freeimage \
		--with-sodium \
		--disable-silent-rules \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

meganz-sdk-unpack: $(MEGANZ_SDK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEGANZ_SDK_BUILD_DIR)/.built: $(MEGANZ_SDK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
meganz-sdk: $(MEGANZ_SDK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEGANZ_SDK_BUILD_DIR)/.staged: $(MEGANZ_SDK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) \
		install_sh='$${SHELL} $(@D)/install-sh' install
	touch $@

meganz-sdk-stage: $(MEGANZ_SDK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/meganz-sdk
#
$(MEGANZ_SDK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: meganz-sdk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEGANZ_SDK_PRIORITY)" >>$@
	@echo "Section: $(MEGANZ_SDK_SECTION)" >>$@
	@echo "Version: $(MEGANZ_SDK_VERSION)-$(MEGANZ_SDK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEGANZ_SDK_MAINTAINER)" >>$@
	@echo "Source: $(MEGANZ_SDK_URL)" >>$@
	@echo "Description: $(MEGANZ_SDK_DESCRIPTION)" >>$@
	@echo "Depends: $(MEGANZ_SDK_DEPENDS)" >>$@
	@echo "Suggests: $(MEGANZ_SDK_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEGANZ_SDK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/meganz-sdk/...
# Documentation files should be installed in $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/doc/meganz-sdk/...
# Daemon startup scripts should be installed in $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??meganz-sdk
#
# You may need to patch your application to make it use these locations.
#
$(MEGANZ_SDK_IPK): $(MEGANZ_SDK_BUILD_DIR)/.built
	rm -rf $(MEGANZ_SDK_IPK_DIR) $(BUILD_DIR)/meganz-sdk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEGANZ_SDK_BUILD_DIR) DESTDIR=$(MEGANZ_SDK_IPK_DIR) \
		install_sh='$${SHELL} $(MEGANZ_SDK_BUILD_DIR)/install-sh' install-strip
#	$(INSTALL) -d $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MEGANZ_SDK_SOURCE_DIR)/meganz-sdk.conf $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/meganz-sdk.conf
#	$(INSTALL) -d $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MEGANZ_SDK_SOURCE_DIR)/rc.meganz-sdk $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmeganz-sdk
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGANZ_SDK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmeganz-sdk
	$(MAKE) $(MEGANZ_SDK_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MEGANZ_SDK_SOURCE_DIR)/postinst $(MEGANZ_SDK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGANZ_SDK_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MEGANZ_SDK_SOURCE_DIR)/prerm $(MEGANZ_SDK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGANZ_SDK_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MEGANZ_SDK_IPK_DIR)/CONTROL/postinst $(MEGANZ_SDK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MEGANZ_SDK_CONFFILES) | sed -e 's/ /\n/g' > $(MEGANZ_SDK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEGANZ_SDK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MEGANZ_SDK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
meganz-sdk-ipk: $(MEGANZ_SDK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
meganz-sdk-clean:
	rm -f $(MEGANZ_SDK_BUILD_DIR)/.built
	-$(MAKE) -C $(MEGANZ_SDK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
meganz-sdk-dirclean:
	rm -rf $(BUILD_DIR)/$(MEGANZ_SDK_DIR) $(MEGANZ_SDK_BUILD_DIR) $(MEGANZ_SDK_IPK_DIR) $(MEGANZ_SDK_IPK)
#
#
# Some sanity check for the package.
#
meganz-sdk-check: $(MEGANZ_SDK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
