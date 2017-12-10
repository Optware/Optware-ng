###########################################################
#
# gtksourceview
#
###########################################################

# You must replace "gtksourceview" and "GTKSOURCEVIEW" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GTKSOURCEVIEW_VERSION, GTKSOURCEVIEW_SITE and GTKSOURCEVIEW_SOURCE define
# the upstream location of the source code for the package.
# GTKSOURCEVIEW_DIR is the directory which is created when the source
# archive is unpacked.
# GTKSOURCEVIEW_UNZIP is the command used to unzip the source.
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
GTKSOURCEVIEW_SITE=http://ftp.gnome.org/pub/gnome/sources/gtksourceview/3.16
GTKSOURCEVIEW_VERSION=3.16.0
GTKSOURCEVIEW_SOURCE=gtksourceview-$(GTKSOURCEVIEW_VERSION).tar.xz
GTKSOURCEVIEW_DIR=gtksourceview-$(GTKSOURCEVIEW_VERSION)
GTKSOURCEVIEW_UNZIP=xzcat
GTKSOURCEVIEW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTKSOURCEVIEW_DESCRIPTION=Libraries for the GTK+ syntax highlighting widget.
GTKSOURCEVIEW_SECTION=lib
GTKSOURCEVIEW_PRIORITY=optional
GTKSOURCEVIEW_DEPENDS=gtk
GTKSOURCEVIEW_SUGGESTS=
GTKSOURCEVIEW_CONFLICTS=

#
# GTKSOURCEVIEW_IPK_VERSION should be incremented when the ipk changes.
#
GTKSOURCEVIEW_IPK_VERSION=1

#
# GTKSOURCEVIEW_CONFFILES should be a list of user-editable files
#GTKSOURCEVIEW_CONFFILES=$(TARGET_PREFIX)/etc/gtksourceview.conf $(TARGET_PREFIX)/etc/init.d/SXXgtksourceview

#
# GTKSOURCEVIEW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GTKSOURCEVIEW_PATCHES=$(GTKSOURCEVIEW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTKSOURCEVIEW_CPPFLAGS=-Wno-error=format-nonliteral
GTKSOURCEVIEW_LDFLAGS=

#
# GTKSOURCEVIEW_BUILD_DIR is the directory in which the build is done.
# GTKSOURCEVIEW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTKSOURCEVIEW_IPK_DIR is the directory in which the ipk is built.
# GTKSOURCEVIEW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTKSOURCEVIEW_BUILD_DIR=$(BUILD_DIR)/gtksourceview
GTKSOURCEVIEW_SOURCE_DIR=$(SOURCE_DIR)/gtksourceview
GTKSOURCEVIEW_IPK_DIR=$(BUILD_DIR)/gtksourceview-$(GTKSOURCEVIEW_VERSION)-ipk
GTKSOURCEVIEW_IPK=$(BUILD_DIR)/gtksourceview_$(GTKSOURCEVIEW_VERSION)-$(GTKSOURCEVIEW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gtksourceview-source gtksourceview-unpack gtksourceview gtksourceview-stage gtksourceview-ipk gtksourceview-clean gtksourceview-dirclean gtksourceview-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTKSOURCEVIEW_SOURCE):
	$(WGET) -P $(@D) $(GTKSOURCEVIEW_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtksourceview-source: $(DL_DIR)/$(GTKSOURCEVIEW_SOURCE) $(GTKSOURCEVIEW_PATCHES)

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
$(GTKSOURCEVIEW_BUILD_DIR)/.configured: $(DL_DIR)/$(GTKSOURCEVIEW_SOURCE) $(GTKSOURCEVIEW_PATCHES) make/gtksourceview.mk
	$(MAKE) gtk-stage
	rm -rf $(BUILD_DIR)/$(GTKSOURCEVIEW_DIR) $(@D)
	$(GTKSOURCEVIEW_UNZIP) $(DL_DIR)/$(GTKSOURCEVIEW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTKSOURCEVIEW_PATCHES)" ; \
		then cat $(GTKSOURCEVIEW_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GTKSOURCEVIEW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GTKSOURCEVIEW_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GTKSOURCEVIEW_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTKSOURCEVIEW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTKSOURCEVIEW_LDFLAGS)" \
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

gtksourceview-unpack: $(GTKSOURCEVIEW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GTKSOURCEVIEW_BUILD_DIR)/.built: $(GTKSOURCEVIEW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gtksourceview: $(GTKSOURCEVIEW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTKSOURCEVIEW_BUILD_DIR)/.staged: $(GTKSOURCEVIEW_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgtksourceview-3.0.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gtksourceview-3.0.pc
	touch $@

gtksourceview-stage: $(GTKSOURCEVIEW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gtksourceview
#
$(GTKSOURCEVIEW_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtksourceview" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTKSOURCEVIEW_PRIORITY)" >>$@
	@echo "Section: $(GTKSOURCEVIEW_SECTION)" >>$@
	@echo "Version: $(GTKSOURCEVIEW_VERSION)-$(GTKSOURCEVIEW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTKSOURCEVIEW_MAINTAINER)" >>$@
	@echo "Source: $(GTKSOURCEVIEW_SITE)/$(GTKSOURCEVIEW_SOURCE)" >>$@
	@echo "Description: $(GTKSOURCEVIEW_DESCRIPTION)" >>$@
	@echo "Depends: $(GTKSOURCEVIEW_DEPENDS)" >>$@
	@echo "Suggests: $(GTKSOURCEVIEW_SUGGESTS)" >>$@
	@echo "Conflicts: $(GTKSOURCEVIEW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/gtksourceview/...
# Documentation files should be installed in $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/doc/gtksourceview/...
# Daemon startup scripts should be installed in $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gtksourceview
#
# You may need to patch your application to make it use these locations.
#
$(GTKSOURCEVIEW_IPK): $(GTKSOURCEVIEW_BUILD_DIR)/.built
	rm -rf $(GTKSOURCEVIEW_IPK_DIR) $(BUILD_DIR)/gtksourceview_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTKSOURCEVIEW_BUILD_DIR) DESTDIR=$(GTKSOURCEVIEW_IPK_DIR) install-strip
	rm -f $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GTKSOURCEVIEW_SOURCE_DIR)/gtksourceview.conf $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/gtksourceview.conf
#	$(INSTALL) -d $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW_SOURCE_DIR)/rc.gtksourceview $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgtksourceview
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgtksourceview
	$(MAKE) $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW_SOURCE_DIR)/postinst $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW_SOURCE_DIR)/prerm $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GTKSOURCEVIEW_IPK_DIR)/CONTROL/postinst $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GTKSOURCEVIEW_CONFFILES) | sed -e 's/ /\n/g' > $(GTKSOURCEVIEW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTKSOURCEVIEW_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GTKSOURCEVIEW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtksourceview-ipk: $(GTKSOURCEVIEW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtksourceview-clean:
	rm -f $(GTKSOURCEVIEW_BUILD_DIR)/.built
	-$(MAKE) -C $(GTKSOURCEVIEW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtksourceview-dirclean:
	rm -rf $(BUILD_DIR)/$(GTKSOURCEVIEW_DIR) $(GTKSOURCEVIEW_BUILD_DIR) $(GTKSOURCEVIEW_IPK_DIR) $(GTKSOURCEVIEW_IPK)
#
#
# Some sanity check for the package.
#
gtksourceview-check: $(GTKSOURCEVIEW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
