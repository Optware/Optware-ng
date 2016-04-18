###########################################################
#
# compositeproto
#
###########################################################
#
# COMPOSITEPROTO_VERSION, COMPOSITEPROTO_SITE and COMPOSITEPROTO_SOURCE define
# the upstream location of the source code for the package.
# COMPOSITEPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# COMPOSITEPROTO_UNZIP is the command used to unzip the source.
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
COMPOSITEPROTO_URL=http://xorg.freedesktop.org/archive/individual/proto/compositeproto-$(COMPOSITEPROTO_VERSION).tar.gz
COMPOSITEPROTO_VERSION=0.4.2
COMPOSITEPROTO_SOURCE=compositeproto-$(COMPOSITEPROTO_VERSION).tar.gz
COMPOSITEPROTO_DIR=compositeproto-$(COMPOSITEPROTO_VERSION)
COMPOSITEPROTO_UNZIP=zcat
COMPOSITEPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COMPOSITEPROTO_DESCRIPTION=X11 Composite extension wire protocol.
COMPOSITEPROTO_SECTION=misc
COMPOSITEPROTO_PRIORITY=optional
COMPOSITEPROTO_DEPENDS=
COMPOSITEPROTO_SUGGESTS=
COMPOSITEPROTO_CONFLICTS=

#
# COMPOSITEPROTO_IPK_VERSION should be incremented when the ipk changes.
#
COMPOSITEPROTO_IPK_VERSION=1

#
# COMPOSITEPROTO_CONFFILES should be a list of user-editable files
#COMPOSITEPROTO_CONFFILES=$(TARGET_PREFIX)/etc/compositeproto.conf $(TARGET_PREFIX)/etc/init.d/SXXcompositeproto

#
# COMPOSITEPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#COMPOSITEPROTO_PATCHES=$(COMPOSITEPROTO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
COMPOSITEPROTO_CPPFLAGS=
COMPOSITEPROTO_LDFLAGS=

#
# COMPOSITEPROTO_BUILD_DIR is the directory in which the build is done.
# COMPOSITEPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COMPOSITEPROTO_IPK_DIR is the directory in which the ipk is built.
# COMPOSITEPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COMPOSITEPROTO_BUILD_DIR=$(BUILD_DIR)/compositeproto
COMPOSITEPROTO_SOURCE_DIR=$(SOURCE_DIR)/compositeproto
COMPOSITEPROTO_IPK_DIR=$(BUILD_DIR)/compositeproto-$(COMPOSITEPROTO_VERSION)-ipk
COMPOSITEPROTO_IPK=$(BUILD_DIR)/compositeproto_$(COMPOSITEPROTO_VERSION)-$(COMPOSITEPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: compositeproto-source compositeproto-unpack compositeproto compositeproto-stage compositeproto-ipk compositeproto-clean compositeproto-dirclean compositeproto-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(COMPOSITEPROTO_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(COMPOSITEPROTO_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(COMPOSITEPROTO_SOURCE).sha512
#
$(DL_DIR)/$(COMPOSITEPROTO_SOURCE):
	$(WGET) -O $@ $(COMPOSITEPROTO_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
compositeproto-source: $(DL_DIR)/$(COMPOSITEPROTO_SOURCE) $(COMPOSITEPROTO_PATCHES)

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
$(COMPOSITEPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(COMPOSITEPROTO_SOURCE) $(COMPOSITEPROTO_PATCHES) make/compositeproto.mk
	$(MAKE) xfixesproto-stage xorg-macros-stage
	rm -rf $(BUILD_DIR)/$(COMPOSITEPROTO_DIR) $(@D)
	$(COMPOSITEPROTO_UNZIP) $(DL_DIR)/$(COMPOSITEPROTO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(COMPOSITEPROTO_PATCHES)" ; \
		then cat $(COMPOSITEPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(COMPOSITEPROTO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(COMPOSITEPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(COMPOSITEPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(COMPOSITEPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(COMPOSITEPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	touch $@

compositeproto-unpack: $(COMPOSITEPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(COMPOSITEPROTO_BUILD_DIR)/.built: $(COMPOSITEPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
compositeproto: $(COMPOSITEPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(COMPOSITEPROTO_BUILD_DIR)/.staged: $(COMPOSITEPROTO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/compositeproto.pc
	touch $@

compositeproto-stage: $(COMPOSITEPROTO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/compositeproto
#
$(COMPOSITEPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: compositeproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COMPOSITEPROTO_PRIORITY)" >>$@
	@echo "Section: $(COMPOSITEPROTO_SECTION)" >>$@
	@echo "Version: $(COMPOSITEPROTO_VERSION)-$(COMPOSITEPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COMPOSITEPROTO_MAINTAINER)" >>$@
	@echo "Source: $(COMPOSITEPROTO_URL)" >>$@
	@echo "Description: $(COMPOSITEPROTO_DESCRIPTION)" >>$@
	@echo "Depends: $(COMPOSITEPROTO_DEPENDS)" >>$@
	@echo "Suggests: $(COMPOSITEPROTO_SUGGESTS)" >>$@
	@echo "Conflicts: $(COMPOSITEPROTO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/compositeproto/...
# Documentation files should be installed in $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/compositeproto/...
# Daemon startup scripts should be installed in $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??compositeproto
#
# You may need to patch your application to make it use these locations.
#
$(COMPOSITEPROTO_IPK): $(COMPOSITEPROTO_BUILD_DIR)/.built
	rm -rf $(COMPOSITEPROTO_IPK_DIR) $(BUILD_DIR)/compositeproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(COMPOSITEPROTO_BUILD_DIR) DESTDIR=$(COMPOSITEPROTO_IPK_DIR) install-strip
#	$(INSTALL) -d $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(COMPOSITEPROTO_SOURCE_DIR)/compositeproto.conf $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/compositeproto.conf
#	$(INSTALL) -d $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(COMPOSITEPROTO_SOURCE_DIR)/rc.compositeproto $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcompositeproto
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(COMPOSITEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcompositeproto
	$(MAKE) $(COMPOSITEPROTO_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(COMPOSITEPROTO_SOURCE_DIR)/postinst $(COMPOSITEPROTO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(COMPOSITEPROTO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(COMPOSITEPROTO_SOURCE_DIR)/prerm $(COMPOSITEPROTO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(COMPOSITEPROTO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(COMPOSITEPROTO_IPK_DIR)/CONTROL/postinst $(COMPOSITEPROTO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(COMPOSITEPROTO_CONFFILES) | sed -e 's/ /\n/g' > $(COMPOSITEPROTO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COMPOSITEPROTO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(COMPOSITEPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
compositeproto-ipk: $(COMPOSITEPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
compositeproto-clean:
	rm -f $(COMPOSITEPROTO_BUILD_DIR)/.built
	-$(MAKE) -C $(COMPOSITEPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
compositeproto-dirclean:
	rm -rf $(BUILD_DIR)/$(COMPOSITEPROTO_DIR) $(COMPOSITEPROTO_BUILD_DIR) $(COMPOSITEPROTO_IPK_DIR) $(COMPOSITEPROTO_IPK)
#
#
# Some sanity check for the package.
#
compositeproto-check: $(COMPOSITEPROTO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
