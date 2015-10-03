###########################################################
#
# lxde-icon-theme
#
###########################################################

# You must replace "lxde-icon-theme" and "LXDE-ICON-THEME" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LXDE-ICON-THEME_VERSION, LXDE-ICON-THEME_SITE and LXDE-ICON-THEME_SOURCE define
# the upstream location of the source code for the package.
# LXDE-ICON-THEME_DIR is the directory which is created when the source
# archive is unpacked.
# LXDE-ICON-THEME_UNZIP is the command used to unzip the source.
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
LXDE-ICON-THEME_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/lxde
LXDE-ICON-THEME_VERSION=0.5.1
LXDE-ICON-THEME_SOURCE=lxde-icon-theme-$(LXDE-ICON-THEME_VERSION).tar.xz
LXDE-ICON-THEME_DIR=lxde-icon-theme-$(LXDE-ICON-THEME_VERSION)
LXDE-ICON-THEME_UNZIP=xzcat
LXDE-ICON-THEME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LXDE-ICON-THEME_DESCRIPTION=LXDE icon theme.
LXDE-ICON-THEME_SECTION=misc
LXDE-ICON-THEME_PRIORITY=optional
LXDE-ICON-THEME_DEPENDS=
LXDE-ICON-THEME_SUGGESTS=
LXDE-ICON-THEME_CONFLICTS=

#
# LXDE-ICON-THEME_IPK_VERSION should be incremented when the ipk changes.
#
LXDE-ICON-THEME_IPK_VERSION=1

#
# LXDE-ICON-THEME_CONFFILES should be a list of user-editable files
#LXDE-ICON-THEME_CONFFILES=/opt/etc/lxde-icon-theme.conf /opt/etc/init.d/SXXlxde-icon-theme

#
# LXDE-ICON-THEME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LXDE-ICON-THEME_PATCHES=$(LXDE-ICON-THEME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LXDE-ICON-THEME_CPPFLAGS=
LXDE-ICON-THEME_LDFLAGS=

#
# LXDE-ICON-THEME_BUILD_DIR is the directory in which the build is done.
# LXDE-ICON-THEME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LXDE-ICON-THEME_IPK_DIR is the directory in which the ipk is built.
# LXDE-ICON-THEME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LXDE-ICON-THEME_BUILD_DIR=$(BUILD_DIR)/lxde-icon-theme
LXDE-ICON-THEME_SOURCE_DIR=$(SOURCE_DIR)/lxde-icon-theme
LXDE-ICON-THEME_IPK_DIR=$(BUILD_DIR)/lxde-icon-theme-$(LXDE-ICON-THEME_VERSION)-ipk
LXDE-ICON-THEME_IPK=$(BUILD_DIR)/lxde-icon-theme_$(LXDE-ICON-THEME_VERSION)-$(LXDE-ICON-THEME_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lxde-icon-theme-source lxde-icon-theme-unpack lxde-icon-theme lxde-icon-theme-stage lxde-icon-theme-ipk lxde-icon-theme-clean lxde-icon-theme-dirclean lxde-icon-theme-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LXDE-ICON-THEME_SOURCE):
	$(WGET) -P $(@D) $(LXDE-ICON-THEME_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lxde-icon-theme-source: $(DL_DIR)/$(LXDE-ICON-THEME_SOURCE) $(LXDE-ICON-THEME_PATCHES)

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
$(LXDE-ICON-THEME_BUILD_DIR)/.configured: $(DL_DIR)/$(LXDE-ICON-THEME_SOURCE) $(LXDE-ICON-THEME_PATCHES) make/lxde-icon-theme.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LXDE-ICON-THEME_DIR) $(@D)
	$(LXDE-ICON-THEME_UNZIP) $(DL_DIR)/$(LXDE-ICON-THEME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LXDE-ICON-THEME_PATCHES)" ; \
		then cat $(LXDE-ICON-THEME_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LXDE-ICON-THEME_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LXDE-ICON-THEME_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LXDE-ICON-THEME_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LXDE-ICON-THEME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LXDE-ICON-THEME_LDFLAGS)" \
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

lxde-icon-theme-unpack: $(LXDE-ICON-THEME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LXDE-ICON-THEME_BUILD_DIR)/.built: $(LXDE-ICON-THEME_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
lxde-icon-theme: $(LXDE-ICON-THEME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LXDE-ICON-THEME_BUILD_DIR)/.staged: $(LXDE-ICON-THEME_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

lxde-icon-theme-stage: $(LXDE-ICON-THEME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lxde-icon-theme
#
$(LXDE-ICON-THEME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: lxde-icon-theme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LXDE-ICON-THEME_PRIORITY)" >>$@
	@echo "Section: $(LXDE-ICON-THEME_SECTION)" >>$@
	@echo "Version: $(LXDE-ICON-THEME_VERSION)-$(LXDE-ICON-THEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LXDE-ICON-THEME_MAINTAINER)" >>$@
	@echo "Source: $(LXDE-ICON-THEME_SITE)/$(LXDE-ICON-THEME_SOURCE)" >>$@
	@echo "Description: $(LXDE-ICON-THEME_DESCRIPTION)" >>$@
	@echo "Depends: $(LXDE-ICON-THEME_DEPENDS)" >>$@
	@echo "Suggests: $(LXDE-ICON-THEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(LXDE-ICON-THEME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LXDE-ICON-THEME_IPK_DIR)/opt/sbin or $(LXDE-ICON-THEME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LXDE-ICON-THEME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/lxde-icon-theme/...
# Documentation files should be installed in $(LXDE-ICON-THEME_IPK_DIR)/opt/doc/lxde-icon-theme/...
# Daemon startup scripts should be installed in $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/init.d/S??lxde-icon-theme
#
# You may need to patch your application to make it use these locations.
#
$(LXDE-ICON-THEME_IPK): $(LXDE-ICON-THEME_BUILD_DIR)/.built
	rm -rf $(LXDE-ICON-THEME_IPK_DIR) $(BUILD_DIR)/lxde-icon-theme_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LXDE-ICON-THEME_BUILD_DIR) DESTDIR=$(LXDE-ICON-THEME_IPK_DIR) install
#	$(INSTALL) -d $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(LXDE-ICON-THEME_SOURCE_DIR)/lxde-icon-theme.conf $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/lxde-icon-theme.conf
#	$(INSTALL) -d $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(LXDE-ICON-THEME_SOURCE_DIR)/rc.lxde-icon-theme $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/init.d/SXXlxde-icon-theme
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXDE-ICON-THEME_IPK_DIR)/opt/etc/init.d/SXXlxde-icon-theme
	$(MAKE) $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(LXDE-ICON-THEME_SOURCE_DIR)/postinst $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(LXDE-ICON-THEME_SOURCE_DIR)/prerm $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LXDE-ICON-THEME_IPK_DIR)/CONTROL/postinst $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LXDE-ICON-THEME_CONFFILES) | sed -e 's/ /\n/g' > $(LXDE-ICON-THEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LXDE-ICON-THEME_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LXDE-ICON-THEME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lxde-icon-theme-ipk: $(LXDE-ICON-THEME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lxde-icon-theme-clean:
	rm -f $(LXDE-ICON-THEME_BUILD_DIR)/.built
	-$(MAKE) -C $(LXDE-ICON-THEME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lxde-icon-theme-dirclean:
	rm -rf $(BUILD_DIR)/$(LXDE-ICON-THEME_DIR) $(LXDE-ICON-THEME_BUILD_DIR) $(LXDE-ICON-THEME_IPK_DIR) $(LXDE-ICON-THEME_IPK)
#
#
# Some sanity check for the package.
#
lxde-icon-theme-check: $(LXDE-ICON-THEME_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
