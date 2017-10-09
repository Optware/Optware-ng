###########################################################
#
# thunar
#
###########################################################

# You must replace "thunar" and "THUNAR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# THUNAR_VERSION, THUNAR_SITE and THUNAR_SOURCE define
# the upstream location of the source code for the package.
# THUNAR_DIR is the directory which is created when the source
# archive is unpacked.
# THUNAR_UNZIP is the command used to unzip the source.
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
THUNAR_SITE=http://archive.xfce.org/src/xfce/thunar/1.6
THUNAR_VERSION=1.6.10
THUNAR_SOURCE=Thunar-$(THUNAR_VERSION).tar.bz2
THUNAR_DIR=Thunar-$(THUNAR_VERSION)
THUNAR_UNZIP=bzcat
THUNAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
THUNAR_DESCRIPTION=Xfce file manager.
THUNAR_SECTION=utilities
THUNAR_PRIORITY=optional
THUNAR_DEPENDS=exo, pcre, libgudev, xdamage, e2fslibs, gnome-icon-theme
THUNAR_SUGGESTS=
THUNAR_CONFLICTS=

#
# THUNAR_IPK_VERSION should be incremented when the ipk changes.
#
THUNAR_IPK_VERSION=2

#
# THUNAR_CONFFILES should be a list of user-editable files
#THUNAR_CONFFILES=$(TARGET_PREFIX)/etc/thunar.conf $(TARGET_PREFIX)/etc/init.d/SXXthunar

#
# THUNAR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#THUNAR_PATCHES=$(THUNAR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
THUNAR_CPPFLAGS=
THUNAR_LDFLAGS=

#
# THUNAR_BUILD_DIR is the directory in which the build is done.
# THUNAR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# THUNAR_IPK_DIR is the directory in which the ipk is built.
# THUNAR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
THUNAR_BUILD_DIR=$(BUILD_DIR)/thunar
THUNAR_SOURCE_DIR=$(SOURCE_DIR)/thunar
THUNAR_IPK_DIR=$(BUILD_DIR)/thunar-$(THUNAR_VERSION)-ipk
THUNAR_IPK=$(BUILD_DIR)/thunar_$(THUNAR_VERSION)-$(THUNAR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: thunar-source thunar-unpack thunar thunar-stage thunar-ipk thunar-clean thunar-dirclean thunar-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(THUNAR_SOURCE):
	$(WGET) -P $(@D) $(THUNAR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
thunar-source: $(DL_DIR)/$(THUNAR_SOURCE) $(THUNAR_PATCHES)

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
$(THUNAR_BUILD_DIR)/.configured: $(DL_DIR)/$(THUNAR_SOURCE) $(THUNAR_PATCHES) make/thunar.mk
	$(MAKE) exo-stage pcre-stage udev-stage xdamage-stage e2fslibs-stage
	rm -rf $(BUILD_DIR)/$(THUNAR_DIR) $(@D)
	$(THUNAR_UNZIP) $(DL_DIR)/$(THUNAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(THUNAR_PATCHES)" ; \
		then cat $(THUNAR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(THUNAR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(THUNAR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(THUNAR_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(THUNAR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(THUNAR_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--docdir=$(TARGET_PREFIX)/share/doc/Thunar-$(THUNAR_VERSION) \
		--program-transform-name='s&^&&' \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

thunar-unpack: $(THUNAR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(THUNAR_BUILD_DIR)/.built: $(THUNAR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
thunar: $(THUNAR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(THUNAR_BUILD_DIR)/.staged: $(THUNAR_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#thunar-stage: $(THUNAR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/thunar
#
$(THUNAR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: thunar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(THUNAR_PRIORITY)" >>$@
	@echo "Section: $(THUNAR_SECTION)" >>$@
	@echo "Version: $(THUNAR_VERSION)-$(THUNAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(THUNAR_MAINTAINER)" >>$@
	@echo "Source: $(THUNAR_SITE)/$(THUNAR_SOURCE)" >>$@
	@echo "Description: $(THUNAR_DESCRIPTION)" >>$@
	@echo "Depends: $(THUNAR_DEPENDS)" >>$@
	@echo "Suggests: $(THUNAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(THUNAR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/thunar/...
# Documentation files should be installed in $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/doc/thunar/...
# Daemon startup scripts should be installed in $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??thunar
#
# You may need to patch your application to make it use these locations.
#
$(THUNAR_IPK): $(THUNAR_BUILD_DIR)/.built
	rm -rf $(THUNAR_IPK_DIR) $(BUILD_DIR)/thunar_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(THUNAR_BUILD_DIR) DESTDIR=$(THUNAR_IPK_DIR) install-strip
	rm -f $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(THUNAR_SOURCE_DIR)/thunar.conf $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/thunar.conf
#	$(INSTALL) -d $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(THUNAR_SOURCE_DIR)/rc.thunar $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXthunar
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(THUNAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXthunar
	$(MAKE) $(THUNAR_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(THUNAR_SOURCE_DIR)/postinst $(THUNAR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(THUNAR_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(THUNAR_SOURCE_DIR)/prerm $(THUNAR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(THUNAR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(THUNAR_IPK_DIR)/CONTROL/postinst $(THUNAR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(THUNAR_CONFFILES) | sed -e 's/ /\n/g' > $(THUNAR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(THUNAR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(THUNAR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
thunar-ipk: $(THUNAR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
thunar-clean:
	rm -f $(THUNAR_BUILD_DIR)/.built
	-$(MAKE) -C $(THUNAR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
thunar-dirclean:
	rm -rf $(BUILD_DIR)/$(THUNAR_DIR) $(THUNAR_BUILD_DIR) $(THUNAR_IPK_DIR) $(THUNAR_IPK)
#
#
# Some sanity check for the package.
#
thunar-check: $(THUNAR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
