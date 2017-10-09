###########################################################
#
# xfconf
#
###########################################################

# You must replace "xfconf" and "XFCONF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XFCONF_VERSION, XFCONF_SITE and XFCONF_SOURCE define
# the upstream location of the source code for the package.
# XFCONF_DIR is the directory which is created when the source
# archive is unpacked.
# XFCONF_UNZIP is the command used to unzip the source.
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
XFCONF_SITE=http://archive.xfce.org/src/xfce/xfconf/4.12
XFCONF_VERSION=4.12.0
XFCONF_SOURCE=xfconf-$(XFCONF_VERSION).tar.bz2
XFCONF_DIR=xfconf-$(XFCONF_VERSION)
XFCONF_UNZIP=bzcat
XFCONF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XFCONF_DESCRIPTION=Configuration storage system for Xfce. 
XFCONF_SECTION=utility
XFCONF_PRIORITY=optional
XFCONF_DEPENDS=dbus-glib, libxfce4util
XFCONF_SUGGESTS=
XFCONF_CONFLICTS=

#
# XFCONF_IPK_VERSION should be incremented when the ipk changes.
#
XFCONF_IPK_VERSION=2

#
# XFCONF_CONFFILES should be a list of user-editable files
#XFCONF_CONFFILES=$(TARGET_PREFIX)/etc/xfconf.conf $(TARGET_PREFIX)/etc/init.d/SXXxfconf

#
# XFCONF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XFCONF_PATCHES=$(XFCONF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XFCONF_CPPFLAGS=
XFCONF_LDFLAGS=

#
# XFCONF_BUILD_DIR is the directory in which the build is done.
# XFCONF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XFCONF_IPK_DIR is the directory in which the ipk is built.
# XFCONF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XFCONF_BUILD_DIR=$(BUILD_DIR)/xfconf
XFCONF_SOURCE_DIR=$(SOURCE_DIR)/xfconf
XFCONF_IPK_DIR=$(BUILD_DIR)/xfconf-$(XFCONF_VERSION)-ipk
XFCONF_IPK=$(BUILD_DIR)/xfconf_$(XFCONF_VERSION)-$(XFCONF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xfconf-source xfconf-unpack xfconf xfconf-stage xfconf-ipk xfconf-clean xfconf-dirclean xfconf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XFCONF_SOURCE):
	$(WGET) -P $(@D) $(XFCONF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xfconf-source: $(DL_DIR)/$(XFCONF_SOURCE) $(XFCONF_PATCHES)

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
$(XFCONF_BUILD_DIR)/.configured: $(DL_DIR)/$(XFCONF_SOURCE) $(XFCONF_PATCHES) make/xfconf.mk
	$(MAKE) dbus-glib-stage libxfce4util-stage
	rm -rf $(BUILD_DIR)/$(XFCONF_DIR) $(@D)
	$(XFCONF_UNZIP) $(DL_DIR)/$(XFCONF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XFCONF_PATCHES)" ; \
		then cat $(XFCONF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XFCONF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XFCONF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XFCONF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XFCONF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XFCONF_LDFLAGS)" \
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
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xfconf-unpack: $(XFCONF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XFCONF_BUILD_DIR)/.built: $(XFCONF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xfconf: $(XFCONF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XFCONF_BUILD_DIR)/.staged: $(XFCONF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libxfconf-0.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libxfconf-0.pc
	touch $@

xfconf-stage: $(XFCONF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xfconf
#
$(XFCONF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xfconf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XFCONF_PRIORITY)" >>$@
	@echo "Section: $(XFCONF_SECTION)" >>$@
	@echo "Version: $(XFCONF_VERSION)-$(XFCONF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XFCONF_MAINTAINER)" >>$@
	@echo "Source: $(XFCONF_SITE)/$(XFCONF_SOURCE)" >>$@
	@echo "Description: $(XFCONF_DESCRIPTION)" >>$@
	@echo "Depends: $(XFCONF_DEPENDS)" >>$@
	@echo "Suggests: $(XFCONF_SUGGESTS)" >>$@
	@echo "Conflicts: $(XFCONF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/xfconf/...
# Documentation files should be installed in $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/doc/xfconf/...
# Daemon startup scripts should be installed in $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xfconf
#
# You may need to patch your application to make it use these locations.
#
$(XFCONF_IPK): $(XFCONF_BUILD_DIR)/.built
	rm -rf $(XFCONF_IPK_DIR) $(BUILD_DIR)/xfconf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XFCONF_BUILD_DIR) DESTDIR=$(XFCONF_IPK_DIR) install-strip
	rm -f $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(XFCONF_SOURCE_DIR)/xfconf.conf $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/xfconf.conf
#	$(INSTALL) -d $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(XFCONF_SOURCE_DIR)/rc.xfconf $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxfconf
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XFCONF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxfconf
	$(MAKE) $(XFCONF_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(XFCONF_SOURCE_DIR)/postinst $(XFCONF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XFCONF_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(XFCONF_SOURCE_DIR)/prerm $(XFCONF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XFCONF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XFCONF_IPK_DIR)/CONTROL/postinst $(XFCONF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XFCONF_CONFFILES) | sed -e 's/ /\n/g' > $(XFCONF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XFCONF_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XFCONF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xfconf-ipk: $(XFCONF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xfconf-clean:
	rm -f $(XFCONF_BUILD_DIR)/.built
	-$(MAKE) -C $(XFCONF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xfconf-dirclean:
	rm -rf $(BUILD_DIR)/$(XFCONF_DIR) $(XFCONF_BUILD_DIR) $(XFCONF_IPK_DIR) $(XFCONF_IPK)
#
#
# Some sanity check for the package.
#
xfconf-check: $(XFCONF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
