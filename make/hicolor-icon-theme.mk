###########################################################
#
# hicolor-icon-theme
#
###########################################################

# You must replace "hicolor-icon-theme" and "HICOLOR-ICON-THEME" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HICOLOR-ICON-THEME_VERSION, HICOLOR-ICON-THEME_SITE and HICOLOR-ICON-THEME_SOURCE define
# the upstream location of the source code for the package.
# HICOLOR-ICON-THEME_DIR is the directory which is created when the source
# archive is unpacked.
# HICOLOR-ICON-THEME_UNZIP is the command used to unzip the source.
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
HICOLOR-ICON-THEME_SITE=http://icon-theme.freedesktop.org/releases
HICOLOR-ICON-THEME_VERSION=0.14
HICOLOR-ICON-THEME_SOURCE=hicolor-icon-theme-$(HICOLOR-ICON-THEME_VERSION).tar.xz
HICOLOR-ICON-THEME_DIR=hicolor-icon-theme-$(HICOLOR-ICON-THEME_VERSION)
HICOLOR-ICON-THEME_UNZIP=xzcat
HICOLOR-ICON-THEME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HICOLOR-ICON-THEME_DESCRIPTION=The hicolor-icon-theme package contains a default fallback theme for implementations of the icon theme specification.
HICOLOR-ICON-THEME_SECTION=misc
HICOLOR-ICON-THEME_PRIORITY=optional
HICOLOR-ICON-THEME_DEPENDS=
HICOLOR-ICON-THEME_SUGGESTS=
HICOLOR-ICON-THEME_CONFLICTS=

#
# HICOLOR-ICON-THEME_IPK_VERSION should be incremented when the ipk changes.
#
HICOLOR-ICON-THEME_IPK_VERSION=2

#
# HICOLOR-ICON-THEME_CONFFILES should be a list of user-editable files
#HICOLOR-ICON-THEME_CONFFILES=/opt/etc/hicolor-icon-theme.conf /opt/etc/init.d/SXXhicolor-icon-theme

#
# HICOLOR-ICON-THEME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HICOLOR-ICON-THEME_PATCHES=$(HICOLOR-ICON-THEME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HICOLOR-ICON-THEME_CPPFLAGS=
HICOLOR-ICON-THEME_LDFLAGS=

#
# HICOLOR-ICON-THEME_BUILD_DIR is the directory in which the build is done.
# HICOLOR-ICON-THEME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HICOLOR-ICON-THEME_IPK_DIR is the directory in which the ipk is built.
# HICOLOR-ICON-THEME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HICOLOR-ICON-THEME_BUILD_DIR=$(BUILD_DIR)/hicolor-icon-theme
HICOLOR-ICON-THEME_SOURCE_DIR=$(SOURCE_DIR)/hicolor-icon-theme
HICOLOR-ICON-THEME_IPK_DIR=$(BUILD_DIR)/hicolor-icon-theme-$(HICOLOR-ICON-THEME_VERSION)-ipk
HICOLOR-ICON-THEME_IPK=$(BUILD_DIR)/hicolor-icon-theme_$(HICOLOR-ICON-THEME_VERSION)-$(HICOLOR-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hicolor-icon-theme-source hicolor-icon-theme-unpack hicolor-icon-theme hicolor-icon-theme-stage hicolor-icon-theme-ipk hicolor-icon-theme-clean hicolor-icon-theme-dirclean hicolor-icon-theme-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HICOLOR-ICON-THEME_SOURCE):
	$(WGET) -P $(@D) $(HICOLOR-ICON-THEME_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hicolor-icon-theme-source: $(DL_DIR)/$(HICOLOR-ICON-THEME_SOURCE) $(HICOLOR-ICON-THEME_PATCHES)

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
$(HICOLOR-ICON-THEME_BUILD_DIR)/.configured: $(DL_DIR)/$(HICOLOR-ICON-THEME_SOURCE) $(HICOLOR-ICON-THEME_PATCHES) make/hicolor-icon-theme.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(HICOLOR-ICON-THEME_DIR) $(@D)
	$(HICOLOR-ICON-THEME_UNZIP) $(DL_DIR)/$(HICOLOR-ICON-THEME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HICOLOR-ICON-THEME_PATCHES)" ; \
		then cat $(HICOLOR-ICON-THEME_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(HICOLOR-ICON-THEME_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HICOLOR-ICON-THEME_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HICOLOR-ICON-THEME_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HICOLOR-ICON-THEME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HICOLOR-ICON-THEME_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

hicolor-icon-theme-unpack: $(HICOLOR-ICON-THEME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HICOLOR-ICON-THEME_BUILD_DIR)/.built: $(HICOLOR-ICON-THEME_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
hicolor-icon-theme: $(HICOLOR-ICON-THEME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HICOLOR-ICON-THEME_BUILD_DIR)/.staged: $(HICOLOR-ICON-THEME_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

hicolor-icon-theme-stage: $(HICOLOR-ICON-THEME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hicolor-icon-theme
#
$(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: hicolor-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HICOLOR-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(HICOLOR-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(HICOLOR-ICON-THEME_VERSION)-$(HICOLOR-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HICOLOR-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(HICOLOR-ICON-THEME_SITE)/$(HICOLOR-ICON-THEME_SOURCE)" >>$@
	@echo "Description: $(HICOLOR-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(HICOLOR-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(HICOLOR-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(HICOLOR-ICON-THEME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HICOLOR-ICON-THEME_IPK_DIR)/opt/sbin or $(HICOLOR-ICON-THEME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HICOLOR-ICON-THEME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/hicolor-icon-theme/...
# Documentation files should be installed in $(HICOLOR-ICON-THEME_IPK_DIR)/opt/doc/hicolor-icon-theme/...
# Daemon startup scripts should be installed in $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/init.d/S??hicolor-icon-theme
#
# You may need to patch your application to make it use these locations.
#
$(HICOLOR-ICON-THEME_IPK): $(HICOLOR-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(HICOLOR-ICON-THEME_IPK_DIR) $(BUILD_DIR)/hicolor-icon-theme_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HICOLOR-ICON-THEME_BUILD_DIR) DESTDIR=$(HICOLOR-ICON-THEME_IPK_DIR) install
#	$(INSTALL) -d $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(HICOLOR-ICON-THEME_SOURCE_DIR)/hicolor-icon-theme.conf $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/hicolor-icon-theme.conf
#	$(INSTALL) -d $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(HICOLOR-ICON-THEME_SOURCE_DIR)/rc.hicolor-icon-theme $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/init.d/SXXhicolor-icon-theme
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HICOLOR-ICON-THEME_IPK_DIR)/opt/etc/init.d/SXXhicolor-icon-theme
	$(MAKE) $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(HICOLOR-ICON-THEME_SOURCE_DIR)/postinst $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(HICOLOR-ICON-THEME_SOURCE_DIR)/prerm $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/postinst $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HICOLOR-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(HICOLOR-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HICOLOR-ICON-THEME_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(HICOLOR-ICON-THEME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hicolor-icon-theme-ipk: $(HICOLOR-ICON-THEME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hicolor-icon-theme-clean:
	rm -f $(HICOLOR-ICON-THEME_BUILD_DIR)/.built
	-$(MAKE) -C $(HICOLOR-ICON-THEME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hicolor-icon-theme-dirclean:
	rm -rf $(BUILD_DIR)/$(HICOLOR-ICON-THEME_DIR) $(HICOLOR-ICON-THEME_BUILD_DIR) $(HICOLOR-ICON-THEME_IPK_DIR) $(HICOLOR-ICON-THEME_IPK)
#
#
# Some sanity check for the package.
#
hicolor-icon-theme-check: $(HICOLOR-ICON-THEME_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
