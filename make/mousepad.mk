###########################################################
#
# mousepad
#
###########################################################

# You must replace "mousepad" and "MOUSEPAD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MOUSEPAD_VERSION, MOUSEPAD_SITE and MOUSEPAD_SOURCE define
# the upstream location of the source code for the package.
# MOUSEPAD_DIR is the directory which is created when the source
# archive is unpacked.
# MOUSEPAD_UNZIP is the command used to unzip the source.
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
MOUSEPAD_SITE=http://archive.xfce.org/src/apps/mousepad/0.4
MOUSEPAD_VERSION=0.4.0
MOUSEPAD_SOURCE=mousepad-$(MOUSEPAD_VERSION).tar.bz2
MOUSEPAD_DIR=mousepad-$(MOUSEPAD_VERSION)
MOUSEPAD_UNZIP=bzcat
MOUSEPAD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOUSEPAD_DESCRIPTION=Simple GTK+ 2 text editor for the Xfce desktop environment.
MOUSEPAD_SECTION=editor
MOUSEPAD_PRIORITY=optional
MOUSEPAD_DEPENDS=gtksourceview2
MOUSEPAD_SUGGESTS=
MOUSEPAD_CONFLICTS=

#
# MOUSEPAD_IPK_VERSION should be incremented when the ipk changes.
#
MOUSEPAD_IPK_VERSION=2

#
# MOUSEPAD_CONFFILES should be a list of user-editable files
#MOUSEPAD_CONFFILES=$(TARGET_PREFIX)/etc/mousepad.conf $(TARGET_PREFIX)/etc/init.d/SXXmousepad

#
# MOUSEPAD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOUSEPAD_PATCHES=$(MOUSEPAD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOUSEPAD_CPPFLAGS=
MOUSEPAD_LDFLAGS=

#
# MOUSEPAD_BUILD_DIR is the directory in which the build is done.
# MOUSEPAD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOUSEPAD_IPK_DIR is the directory in which the ipk is built.
# MOUSEPAD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOUSEPAD_BUILD_DIR=$(BUILD_DIR)/mousepad
MOUSEPAD_SOURCE_DIR=$(SOURCE_DIR)/mousepad
MOUSEPAD_IPK_DIR=$(BUILD_DIR)/mousepad-$(MOUSEPAD_VERSION)-ipk
MOUSEPAD_IPK=$(BUILD_DIR)/mousepad_$(MOUSEPAD_VERSION)-$(MOUSEPAD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mousepad-source mousepad-unpack mousepad mousepad-stage mousepad-ipk mousepad-clean mousepad-dirclean mousepad-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOUSEPAD_SOURCE):
	$(WGET) -P $(@D) $(MOUSEPAD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mousepad-source: $(DL_DIR)/$(MOUSEPAD_SOURCE) $(MOUSEPAD_PATCHES)

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
$(MOUSEPAD_BUILD_DIR)/.configured: $(DL_DIR)/$(MOUSEPAD_SOURCE) $(MOUSEPAD_PATCHES) make/mousepad.mk
	$(MAKE) gtksourceview2-stage
	rm -rf $(BUILD_DIR)/$(MOUSEPAD_DIR) $(@D)
	$(MOUSEPAD_UNZIP) $(DL_DIR)/$(MOUSEPAD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOUSEPAD_PATCHES)" ; \
		then cat $(MOUSEPAD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MOUSEPAD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOUSEPAD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOUSEPAD_DIR) $(@D) ; \
	fi
	sed -i -e 's|g_get_user_config_dir ()|"$(TARGET_PREFIX)/etc"|' $(@D)/mousepad/*.[ch]
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOUSEPAD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOUSEPAD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-gtk3 \
		--program-transform-name='s&^&&' \
		--enable-keyfile-settings \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mousepad-unpack: $(MOUSEPAD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOUSEPAD_BUILD_DIR)/.built: $(MOUSEPAD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mousepad: $(MOUSEPAD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOUSEPAD_BUILD_DIR)/.staged: $(MOUSEPAD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mousepad-stage: $(MOUSEPAD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mousepad
#
$(MOUSEPAD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mousepad" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOUSEPAD_PRIORITY)" >>$@
	@echo "Section: $(MOUSEPAD_SECTION)" >>$@
	@echo "Version: $(MOUSEPAD_VERSION)-$(MOUSEPAD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOUSEPAD_MAINTAINER)" >>$@
	@echo "Source: $(MOUSEPAD_SITE)/$(MOUSEPAD_SOURCE)" >>$@
	@echo "Description: $(MOUSEPAD_DESCRIPTION)" >>$@
	@echo "Depends: $(MOUSEPAD_DEPENDS)" >>$@
	@echo "Suggests: $(MOUSEPAD_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOUSEPAD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/mousepad/...
# Documentation files should be installed in $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/doc/mousepad/...
# Daemon startup scripts should be installed in $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mousepad
#
# You may need to patch your application to make it use these locations.
#
$(MOUSEPAD_IPK): $(MOUSEPAD_BUILD_DIR)/.built
	rm -rf $(MOUSEPAD_IPK_DIR) $(BUILD_DIR)/mousepad_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOUSEPAD_BUILD_DIR) DESTDIR=$(MOUSEPAD_IPK_DIR) install-strip
#	$(INSTALL) -d $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MOUSEPAD_SOURCE_DIR)/mousepad.conf $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/mousepad.conf
#	$(INSTALL) -d $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MOUSEPAD_SOURCE_DIR)/rc.mousepad $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmousepad
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOUSEPAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmousepad
	$(MAKE) $(MOUSEPAD_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(MOUSEPAD_SOURCE_DIR)/postinst $(MOUSEPAD_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(MOUSEPAD_SOURCE_DIR)/postrm $(MOUSEPAD_IPK_DIR)/CONTROL/postrm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOUSEPAD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MOUSEPAD_SOURCE_DIR)/prerm $(MOUSEPAD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOUSEPAD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MOUSEPAD_IPK_DIR)/CONTROL/postinst $(MOUSEPAD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MOUSEPAD_CONFFILES) | sed -e 's/ /\n/g' > $(MOUSEPAD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOUSEPAD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MOUSEPAD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mousepad-ipk: $(MOUSEPAD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mousepad-clean:
	rm -f $(MOUSEPAD_BUILD_DIR)/.built
	-$(MAKE) -C $(MOUSEPAD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mousepad-dirclean:
	rm -rf $(BUILD_DIR)/$(MOUSEPAD_DIR) $(MOUSEPAD_BUILD_DIR) $(MOUSEPAD_IPK_DIR) $(MOUSEPAD_IPK)
#
#
# Some sanity check for the package.
#
mousepad-check: $(MOUSEPAD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
