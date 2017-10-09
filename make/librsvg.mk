###########################################################
#
# librsvg
#
###########################################################

# You must replace "librsvg" and "LIBRSVG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBRSVG_VERSION, LIBRSVG_SITE and LIBRSVG_SOURCE define
# the upstream location of the source code for the package.
# LIBRSVG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBRSVG_UNZIP is the command used to unzip the source.
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
LIBRSVG_SITE=http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40
LIBRSVG_VERSION=2.40.8
LIBRSVG_SOURCE=librsvg-$(LIBRSVG_VERSION).tar.xz
LIBRSVG_DIR=librsvg-$(LIBRSVG_VERSION)
LIBRSVG_UNZIP=xzcat
LIBRSVG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBRSVG_DESCRIPTION=Scalable Vector Graphic (SVG) images manipulation library and tools.
LIBRSVG_SECTION=lib
LIBRSVG_PRIORITY=optional
LIBRSVG_DEPENDS=gtk, libcroco, gobject-introspection
LIBRSVG_SUGGESTS=
LIBRSVG_CONFLICTS=

#
# LIBRSVG_IPK_VERSION should be incremented when the ipk changes.
#
LIBRSVG_IPK_VERSION=2

#
# LIBRSVG_CONFFILES should be a list of user-editable files
#LIBRSVG_CONFFILES=$(TARGET_PREFIX)/etc/librsvg.conf $(TARGET_PREFIX)/etc/init.d/SXXlibrsvg

#
# LIBRSVG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBRSVG_PATCHES=$(LIBRSVG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBRSVG_CPPFLAGS=
LIBRSVG_LDFLAGS=

#
# LIBRSVG_BUILD_DIR is the directory in which the build is done.
# LIBRSVG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBRSVG_IPK_DIR is the directory in which the ipk is built.
# LIBRSVG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBRSVG_BUILD_DIR=$(BUILD_DIR)/librsvg
LIBRSVG_SOURCE_DIR=$(SOURCE_DIR)/librsvg
LIBRSVG_IPK_DIR=$(BUILD_DIR)/librsvg-$(LIBRSVG_VERSION)-ipk
LIBRSVG_IPK=$(BUILD_DIR)/librsvg_$(LIBRSVG_VERSION)-$(LIBRSVG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: librsvg-source librsvg-unpack librsvg librsvg-stage librsvg-ipk librsvg-clean librsvg-dirclean librsvg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBRSVG_SOURCE):
	$(WGET) -P $(@D) $(LIBRSVG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
librsvg-source: $(DL_DIR)/$(LIBRSVG_SOURCE) $(LIBRSVG_PATCHES)

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
$(LIBRSVG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBRSVG_SOURCE) $(LIBRSVG_PATCHES) \
		$(LIBRSVG_SOURCE_DIR)/$(LIBRSVG_VERSION)/Rsvg-2.0.gir make/librsvg.mk
	$(MAKE) gtk-stage libcroco-stage
	rm -rf $(BUILD_DIR)/$(LIBRSVG_DIR) $(@D)
	$(LIBRSVG_UNZIP) $(DL_DIR)/$(LIBRSVG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBRSVG_PATCHES)" ; \
		then cat $(LIBRSVG_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBRSVG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBRSVG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBRSVG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBRSVG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBRSVG_LDFLAGS)" \
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
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

librsvg-unpack: $(LIBRSVG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBRSVG_BUILD_DIR)/.built: $(LIBRSVG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
librsvg: $(LIBRSVG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBRSVG_BUILD_DIR)/.staged: $(LIBRSVG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/librsvg-2.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/librsvg-2.0.pc
	touch $@

librsvg-stage: $(LIBRSVG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/librsvg
#
$(LIBRSVG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: librsvg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBRSVG_PRIORITY)" >>$@
	@echo "Section: $(LIBRSVG_SECTION)" >>$@
	@echo "Version: $(LIBRSVG_VERSION)-$(LIBRSVG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBRSVG_MAINTAINER)" >>$@
	@echo "Source: $(LIBRSVG_SITE)/$(LIBRSVG_SOURCE)" >>$@
	@echo "Description: $(LIBRSVG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBRSVG_DEPENDS)" >>$@
	@echo "Suggests: $(LIBRSVG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBRSVG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/librsvg/...
# Documentation files should be installed in $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/doc/librsvg/...
# Daemon startup scripts should be installed in $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??librsvg
#
# You may need to patch your application to make it use these locations.
#
$(LIBRSVG_IPK): $(LIBRSVG_BUILD_DIR)/.built
	rm -rf $(LIBRSVG_IPK_DIR) $(BUILD_DIR)/librsvg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBRSVG_BUILD_DIR) DESTDIR=$(LIBRSVG_IPK_DIR) install-strip
	find $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX) -type f -name *.la -exec rm -f {} \;
	$(INSTALL) -d $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/share/gir-1.0
	$(INSTALL) -m 644 $(LIBRSVG_SOURCE_DIR)/$(LIBRSVG_VERSION)/Rsvg-2.0.gir \
		$(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/share/gir-1.0/Rsvg-2.0.gir
#	$(INSTALL) -d $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBRSVG_SOURCE_DIR)/librsvg.conf $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/librsvg.conf
#	$(INSTALL) -d $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBRSVG_SOURCE_DIR)/rc.librsvg $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibrsvg
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRSVG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibrsvg
	$(MAKE) $(LIBRSVG_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(LIBRSVG_SOURCE_DIR)/postinst $(LIBRSVG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRSVG_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(LIBRSVG_SOURCE_DIR)/prerm $(LIBRSVG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRSVG_IPK_DIR)/CONTROL/prerm
	$(INSTALL) -m 755 $(LIBRSVG_SOURCE_DIR)/postrm $(LIBRSVG_IPK_DIR)/CONTROL/postrm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBRSVG_IPK_DIR)/CONTROL/postinst $(LIBRSVG_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBRSVG_CONFFILES) | sed -e 's/ /\n/g' > $(LIBRSVG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBRSVG_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBRSVG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
librsvg-ipk: $(LIBRSVG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
librsvg-clean:
	rm -f $(LIBRSVG_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBRSVG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
librsvg-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBRSVG_DIR) $(LIBRSVG_BUILD_DIR) $(LIBRSVG_IPK_DIR) $(LIBRSVG_IPK)
#
#
# Some sanity check for the package.
#
librsvg-check: $(LIBRSVG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
