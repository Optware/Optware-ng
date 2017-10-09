###########################################################
#
# lxappearance
#
###########################################################

# You must replace "lxappearance" and "LXAPPEARANCE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LXAPPEARANCE_VERSION, LXAPPEARANCE_SITE and LXAPPEARANCE_SOURCE define
# the upstream location of the source code for the package.
# LXAPPEARANCE_DIR is the directory which is created when the source
# archive is unpacked.
# LXAPPEARANCE_UNZIP is the command used to unzip the source.
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
LXAPPEARANCE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/lxde
LXAPPEARANCE_VERSION=0.6.1
LXAPPEARANCE_SOURCE=lxappearance-$(LXAPPEARANCE_VERSION).tar.xz
LXAPPEARANCE_DIR=lxappearance-$(LXAPPEARANCE_VERSION)
LXAPPEARANCE_UNZIP=xzcat
LXAPPEARANCE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LXAPPEARANCE_DESCRIPTION=LXAppearance is a new feature-rich GTK+ theme switcher able to change GTK+ themes, icon themes, and fonts used by applications.
LXAPPEARANCE_SECTION=utility
LXAPPEARANCE_PRIORITY=optional
LXAPPEARANCE_DEPENDS=gtk2
LXAPPEARANCE_SUGGESTS=
LXAPPEARANCE_CONFLICTS=

#
# LXAPPEARANCE_IPK_VERSION should be incremented when the ipk changes.
#
LXAPPEARANCE_IPK_VERSION=2

#
# LXAPPEARANCE_CONFFILES should be a list of user-editable files
#LXAPPEARANCE_CONFFILES=$(TARGET_PREFIX)/etc/lxappearance.conf $(TARGET_PREFIX)/etc/init.d/SXXlxappearance

#
# LXAPPEARANCE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LXAPPEARANCE_PATCHES=$(LXAPPEARANCE_SOURCE_DIR)/paths.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LXAPPEARANCE_CPPFLAGS=
LXAPPEARANCE_LDFLAGS=

#
# LXAPPEARANCE_BUILD_DIR is the directory in which the build is done.
# LXAPPEARANCE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LXAPPEARANCE_IPK_DIR is the directory in which the ipk is built.
# LXAPPEARANCE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LXAPPEARANCE_BUILD_DIR=$(BUILD_DIR)/lxappearance
LXAPPEARANCE_SOURCE_DIR=$(SOURCE_DIR)/lxappearance
LXAPPEARANCE_IPK_DIR=$(BUILD_DIR)/lxappearance-$(LXAPPEARANCE_VERSION)-ipk
LXAPPEARANCE_IPK=$(BUILD_DIR)/lxappearance_$(LXAPPEARANCE_VERSION)-$(LXAPPEARANCE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lxappearance-source lxappearance-unpack lxappearance lxappearance-stage lxappearance-ipk lxappearance-clean lxappearance-dirclean lxappearance-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LXAPPEARANCE_SOURCE):
	$(WGET) -P $(@D) $(LXAPPEARANCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lxappearance-source: $(DL_DIR)/$(LXAPPEARANCE_SOURCE) $(LXAPPEARANCE_PATCHES)

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
$(LXAPPEARANCE_BUILD_DIR)/.configured: $(DL_DIR)/$(LXAPPEARANCE_SOURCE) $(LXAPPEARANCE_PATCHES) make/lxappearance.mk
	$(MAKE) gtk2-stage
	rm -rf $(BUILD_DIR)/$(LXAPPEARANCE_DIR) $(@D)
	$(LXAPPEARANCE_UNZIP) $(DL_DIR)/$(LXAPPEARANCE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LXAPPEARANCE_PATCHES)" ; \
		then cat $(LXAPPEARANCE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LXAPPEARANCE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LXAPPEARANCE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LXAPPEARANCE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LXAPPEARANCE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LXAPPEARANCE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
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

lxappearance-unpack: $(LXAPPEARANCE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LXAPPEARANCE_BUILD_DIR)/.built: $(LXAPPEARANCE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
lxappearance: $(LXAPPEARANCE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LXAPPEARANCE_BUILD_DIR)/.staged: $(LXAPPEARANCE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

lxappearance-stage: $(LXAPPEARANCE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lxappearance
#
$(LXAPPEARANCE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: lxappearance" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LXAPPEARANCE_PRIORITY)" >>$@
	@echo "Section: $(LXAPPEARANCE_SECTION)" >>$@
	@echo "Version: $(LXAPPEARANCE_VERSION)-$(LXAPPEARANCE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LXAPPEARANCE_MAINTAINER)" >>$@
	@echo "Source: $(LXAPPEARANCE_SITE)/$(LXAPPEARANCE_SOURCE)" >>$@
	@echo "Description: $(LXAPPEARANCE_DESCRIPTION)" >>$@
	@echo "Depends: $(LXAPPEARANCE_DEPENDS)" >>$@
	@echo "Suggests: $(LXAPPEARANCE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LXAPPEARANCE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/lxappearance/...
# Documentation files should be installed in $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/doc/lxappearance/...
# Daemon startup scripts should be installed in $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??lxappearance
#
# You may need to patch your application to make it use these locations.
#
$(LXAPPEARANCE_IPK): $(LXAPPEARANCE_BUILD_DIR)/.built
	rm -rf $(LXAPPEARANCE_IPK_DIR) $(BUILD_DIR)/lxappearance_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LXAPPEARANCE_BUILD_DIR) DESTDIR=$(LXAPPEARANCE_IPK_DIR) install-strip
#	$(INSTALL) -d $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LXAPPEARANCE_SOURCE_DIR)/lxappearance.conf $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/lxappearance.conf
#	$(INSTALL) -d $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LXAPPEARANCE_SOURCE_DIR)/rc.lxappearance $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlxappearance
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXAPPEARANCE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlxappearance
	$(MAKE) $(LXAPPEARANCE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LXAPPEARANCE_SOURCE_DIR)/postinst $(LXAPPEARANCE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXAPPEARANCE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LXAPPEARANCE_SOURCE_DIR)/prerm $(LXAPPEARANCE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LXAPPEARANCE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LXAPPEARANCE_IPK_DIR)/CONTROL/postinst $(LXAPPEARANCE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LXAPPEARANCE_CONFFILES) | sed -e 's/ /\n/g' > $(LXAPPEARANCE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LXAPPEARANCE_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LXAPPEARANCE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lxappearance-ipk: $(LXAPPEARANCE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lxappearance-clean:
	rm -f $(LXAPPEARANCE_BUILD_DIR)/.built
	-$(MAKE) -C $(LXAPPEARANCE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lxappearance-dirclean:
	rm -rf $(BUILD_DIR)/$(LXAPPEARANCE_DIR) $(LXAPPEARANCE_BUILD_DIR) $(LXAPPEARANCE_IPK_DIR) $(LXAPPEARANCE_IPK)
#
#
# Some sanity check for the package.
#
lxappearance-check: $(LXAPPEARANCE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
