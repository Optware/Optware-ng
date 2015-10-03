###########################################################
#
# gsettings-desktop-schemas
#
###########################################################

# You must replace "gsettings-desktop-schemas" and "GSETTINGS-DESKTOP-SCHEMAS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GSETTINGS-DESKTOP-SCHEMAS_VERSION, GSETTINGS-DESKTOP-SCHEMAS_SITE and GSETTINGS-DESKTOP-SCHEMAS_SOURCE define
# the upstream location of the source code for the package.
# GSETTINGS-DESKTOP-SCHEMAS_DIR is the directory which is created when the source
# archive is unpacked.
# GSETTINGS-DESKTOP-SCHEMAS_UNZIP is the command used to unzip the source.
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
GSETTINGS-DESKTOP-SCHEMAS_SITE=http://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.16
GSETTINGS-DESKTOP-SCHEMAS_VERSION=3.16.0
GSETTINGS-DESKTOP-SCHEMAS_SOURCE=gsettings-desktop-schemas-$(GSETTINGS-DESKTOP-SCHEMAS_VERSION).tar.xz
GSETTINGS-DESKTOP-SCHEMAS_DIR=gsettings-desktop-schemas-$(GSETTINGS-DESKTOP-SCHEMAS_VERSION)
GSETTINGS-DESKTOP-SCHEMAS_UNZIP=xzcat
GSETTINGS-DESKTOP-SCHEMAS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GSETTINGS-DESKTOP-SCHEMAS_DESCRIPTION=GSettings schemas settings shared by various components of a GNOME Desktop.
GSETTINGS-DESKTOP-SCHEMAS_SECTION=misc
GSETTINGS-DESKTOP-SCHEMAS_PRIORITY=optional
GSETTINGS-DESKTOP-SCHEMAS_DEPENDS=glib
GSETTINGS-DESKTOP-SCHEMAS_SUGGESTS=
GSETTINGS-DESKTOP-SCHEMAS_CONFLICTS=

#
# GSETTINGS-DESKTOP-SCHEMAS_IPK_VERSION should be incremented when the ipk changes.
#
GSETTINGS-DESKTOP-SCHEMAS_IPK_VERSION=1

#
# GSETTINGS-DESKTOP-SCHEMAS_CONFFILES should be a list of user-editable files
#GSETTINGS-DESKTOP-SCHEMAS_CONFFILES=$(TARGET_PREFIX)/etc/gsettings-desktop-schemas.conf $(TARGET_PREFIX)/etc/init.d/SXXgsettings-desktop-schemas

#
# GSETTINGS-DESKTOP-SCHEMAS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GSETTINGS-DESKTOP-SCHEMAS_PATCHES=$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GSETTINGS-DESKTOP-SCHEMAS_CPPFLAGS=
GSETTINGS-DESKTOP-SCHEMAS_LDFLAGS=

#
# GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR is the directory in which the build is done.
# GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR is the directory in which the ipk is built.
# GSETTINGS-DESKTOP-SCHEMAS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR=$(BUILD_DIR)/gsettings-desktop-schemas
GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR=$(SOURCE_DIR)/gsettings-desktop-schemas
GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR=$(BUILD_DIR)/gsettings-desktop-schemas-$(GSETTINGS-DESKTOP-SCHEMAS_VERSION)-ipk
GSETTINGS-DESKTOP-SCHEMAS_IPK=$(BUILD_DIR)/gsettings-desktop-schemas_$(GSETTINGS-DESKTOP-SCHEMAS_VERSION)-$(GSETTINGS-DESKTOP-SCHEMAS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gsettings-desktop-schemas-source gsettings-desktop-schemas-unpack gsettings-desktop-schemas gsettings-desktop-schemas-stage gsettings-desktop-schemas-ipk gsettings-desktop-schemas-clean gsettings-desktop-schemas-dirclean gsettings-desktop-schemas-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE):
	$(WGET) -P $(@D) $(GSETTINGS-DESKTOP-SCHEMAS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gsettings-desktop-schemas-source: $(DL_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE) $(GSETTINGS-DESKTOP-SCHEMAS_PATCHES)

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
$(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.configured: $(DL_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE) $(GSETTINGS-DESKTOP-SCHEMAS_PATCHES) make/gsettings-desktop-schemas.mk
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_DIR) $(@D)
	$(GSETTINGS-DESKTOP-SCHEMAS_UNZIP) $(DL_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GSETTINGS-DESKTOP-SCHEMAS_PATCHES)" ; \
		then cat $(GSETTINGS-DESKTOP-SCHEMAS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GSETTINGS-DESKTOP-SCHEMAS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GSETTINGS-DESKTOP-SCHEMAS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-introspection \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gsettings-desktop-schemas-unpack: $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.built: $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gsettings-desktop-schemas: $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.staged: $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	mkdir -p $(STAGING_LIB_DIR)/pkgconfig
	mv -f $(STAGING_PREFIX)/share/pkgconfig/gsettings-desktop-schemas.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gsettings-desktop-schemas.pc
	touch $@

gsettings-desktop-schemas-stage: $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gsettings-desktop-schemas
#
$(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gsettings-desktop-schemas" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GSETTINGS-DESKTOP-SCHEMAS_PRIORITY)" >>$@
	@echo "Section: $(GSETTINGS-DESKTOP-SCHEMAS_SECTION)" >>$@
	@echo "Version: $(GSETTINGS-DESKTOP-SCHEMAS_VERSION)-$(GSETTINGS-DESKTOP-SCHEMAS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GSETTINGS-DESKTOP-SCHEMAS_MAINTAINER)" >>$@
	@echo "Source: $(GSETTINGS-DESKTOP-SCHEMAS_SITE)/$(GSETTINGS-DESKTOP-SCHEMAS_SOURCE)" >>$@
	@echo "Description: $(GSETTINGS-DESKTOP-SCHEMAS_DESCRIPTION)" >>$@
	@echo "Depends: $(GSETTINGS-DESKTOP-SCHEMAS_DEPENDS)" >>$@
	@echo "Suggests: $(GSETTINGS-DESKTOP-SCHEMAS_SUGGESTS)" >>$@
	@echo "Conflicts: $(GSETTINGS-DESKTOP-SCHEMAS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/gsettings-desktop-schemas/...
# Documentation files should be installed in $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/doc/gsettings-desktop-schemas/...
# Daemon startup scripts should be installed in $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gsettings-desktop-schemas
#
# You may need to patch your application to make it use these locations.
#
$(GSETTINGS-DESKTOP-SCHEMAS_IPK): $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.built
	rm -rf $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR) $(BUILD_DIR)/gsettings-desktop-schemas_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR) DESTDIR=$(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR) install-strip
	$(INSTALL) -d $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(addprefix $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/, share/pkgconfig lib/)
#	$(INSTALL) -d $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR)/gsettings-desktop-schemas.conf $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/gsettings-desktop-schemas.conf
#	$(INSTALL) -d $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR)/rc.gsettings-desktop-schemas $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgsettings-desktop-schemas
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgsettings-desktop-schemas
	$(MAKE) $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR)/postinst $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GSETTINGS-DESKTOP-SCHEMAS_SOURCE_DIR)/prerm $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/postinst $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GSETTINGS-DESKTOP-SCHEMAS_CONFFILES) | sed -e 's/ /\n/g' > $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gsettings-desktop-schemas-ipk: $(GSETTINGS-DESKTOP-SCHEMAS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gsettings-desktop-schemas-clean:
	rm -f $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR)/.built
	-$(MAKE) -C $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gsettings-desktop-schemas-dirclean:
	rm -rf $(BUILD_DIR)/$(GSETTINGS-DESKTOP-SCHEMAS_DIR) $(GSETTINGS-DESKTOP-SCHEMAS_BUILD_DIR) $(GSETTINGS-DESKTOP-SCHEMAS_IPK_DIR) $(GSETTINGS-DESKTOP-SCHEMAS_IPK)
#
#
# Some sanity check for the package.
#
gsettings-desktop-schemas-check: $(GSETTINGS-DESKTOP-SCHEMAS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
