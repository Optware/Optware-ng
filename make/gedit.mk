###########################################################
#
# gedit
#
###########################################################

# You must replace "gedit" and "GEDIT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GEDIT_VERSION, GEDIT_SITE and GEDIT_SOURCE define
# the upstream location of the source code for the package.
# GEDIT_DIR is the directory which is created when the source
# archive is unpacked.
# GEDIT_UNZIP is the command used to unzip the source.
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
GEDIT_SITE=http://ftp.gnome.org/pub/gnome/sources/gedit/3.16
GEDIT_VERSION=3.16.0
GEDIT_SOURCE=gedit-$(GEDIT_VERSION).tar.xz
GEDIT_DIR=gedit-$(GEDIT_VERSION)
GEDIT_UNZIP=xzcat
GEDIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GEDIT_DESCRIPTION=Lightweight UTF-8 text editor for the GNOME Desktop.
GEDIT_SECTION=editor
GEDIT_PRIORITY=optional
GEDIT_DEPENDS=gsettings-desktop-schemas, gtksourceview, libpeas
GEDIT_SUGGESTS=
GEDIT_CONFLICTS=

#
# GEDIT_IPK_VERSION should be incremented when the ipk changes.
#
GEDIT_IPK_VERSION=2

#
# GEDIT_CONFFILES should be a list of user-editable files
#GEDIT_CONFFILES=$(TARGET_PREFIX)/etc/gedit.conf $(TARGET_PREFIX)/etc/init.d/SXXgedit

#
# GEDIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GEDIT_PATCHES=\
$(GEDIT_SOURCE_DIR)/glib-compile-schemas_nonstrict.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GEDIT_CPPFLAGS=
GEDIT_LDFLAGS=-Wl,-rpath,$(TARGET_PREFIX)/lib/gedit

#
# GEDIT_BUILD_DIR is the directory in which the build is done.
# GEDIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GEDIT_IPK_DIR is the directory in which the ipk is built.
# GEDIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GEDIT_BUILD_DIR=$(BUILD_DIR)/gedit
GEDIT_SOURCE_DIR=$(SOURCE_DIR)/gedit
GEDIT_IPK_DIR=$(BUILD_DIR)/gedit-$(GEDIT_VERSION)-ipk
GEDIT_IPK=$(BUILD_DIR)/gedit_$(GEDIT_VERSION)-$(GEDIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gedit-source gedit-unpack gedit gedit-stage gedit-ipk gedit-clean gedit-dirclean gedit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GEDIT_SOURCE):
	$(WGET) -P $(@D) $(GEDIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gedit-source: $(DL_DIR)/$(GEDIT_SOURCE) $(GEDIT_PATCHES)

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
$(GEDIT_BUILD_DIR)/.configured: $(DL_DIR)/$(GEDIT_SOURCE) $(GEDIT_PATCHES) make/gedit.mk
	$(MAKE) gsettings-desktop-schemas-stage gtksourceview-stage libpeas-stage
	rm -rf $(BUILD_DIR)/$(GEDIT_DIR) $(@D)
	$(GEDIT_UNZIP) $(DL_DIR)/$(GEDIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GEDIT_PATCHES)" ; \
		then cat $(GEDIT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GEDIT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GEDIT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GEDIT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GEDIT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GEDIT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-spell \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gedit-unpack: $(GEDIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GEDIT_BUILD_DIR)/.built: $(GEDIT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gedit: $(GEDIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GEDIT_BUILD_DIR)/.staged: $(GEDIT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gedit-stage: $(GEDIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gedit
#
$(GEDIT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gedit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GEDIT_PRIORITY)" >>$@
	@echo "Section: $(GEDIT_SECTION)" >>$@
	@echo "Version: $(GEDIT_VERSION)-$(GEDIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GEDIT_MAINTAINER)" >>$@
	@echo "Source: $(GEDIT_SITE)/$(GEDIT_SOURCE)" >>$@
	@echo "Description: $(GEDIT_DESCRIPTION)" >>$@
	@echo "Depends: $(GEDIT_DEPENDS)" >>$@
	@echo "Suggests: $(GEDIT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GEDIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/gedit/...
# Documentation files should be installed in $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/doc/gedit/...
# Daemon startup scripts should be installed in $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gedit
#
# You may need to patch your application to make it use these locations.
#
$(GEDIT_IPK): $(GEDIT_BUILD_DIR)/.built
	rm -rf $(GEDIT_IPK_DIR) $(BUILD_DIR)/gedit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GEDIT_BUILD_DIR) DESTDIR=$(GEDIT_IPK_DIR) install-strip
#	$(INSTALL) -d $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GEDIT_SOURCE_DIR)/gedit.conf $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/gedit.conf
#	$(INSTALL) -d $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GEDIT_SOURCE_DIR)/rc.gedit $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgedit
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GEDIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgedit
	$(MAKE) $(GEDIT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GEDIT_SOURCE_DIR)/postinst $(GEDIT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GEDIT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GEDIT_SOURCE_DIR)/prerm $(GEDIT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GEDIT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GEDIT_IPK_DIR)/CONTROL/postinst $(GEDIT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GEDIT_CONFFILES) | sed -e 's/ /\n/g' > $(GEDIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GEDIT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GEDIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gedit-ipk: $(GEDIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gedit-clean:
	rm -f $(GEDIT_BUILD_DIR)/.built
	-$(MAKE) -C $(GEDIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gedit-dirclean:
	rm -rf $(BUILD_DIR)/$(GEDIT_DIR) $(GEDIT_BUILD_DIR) $(GEDIT_IPK_DIR) $(GEDIT_IPK)
#
#
# Some sanity check for the package.
#
gedit-check: $(GEDIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
