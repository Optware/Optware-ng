###########################################################
#
# gtksourceview2
#
###########################################################

# You must replace "gtksourceview2" and "GTKSOURCEVIEW2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GTKSOURCEVIEW2_VERSION, GTKSOURCEVIEW2_SITE and GTKSOURCEVIEW2_SOURCE define
# the upstream location of the source code for the package.
# GTKSOURCEVIEW2_DIR is the directory which is created when the source
# archive is unpacked.
# GTKSOURCEVIEW2_UNZIP is the command used to unzip the source.
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
GTKSOURCEVIEW2_SITE=http://ftp.gnome.org/pub/gnome/sources/gtksourceview/2.10
GTKSOURCEVIEW2_VERSION=2.10.5
GTKSOURCEVIEW2_SOURCE=gtksourceview-$(GTKSOURCEVIEW2_VERSION).tar.gz
GTKSOURCEVIEW2_DIR=gtksourceview-$(GTKSOURCEVIEW2_VERSION)
GTKSOURCEVIEW2_UNZIP=zcat
GTKSOURCEVIEW2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTKSOURCEVIEW2_DESCRIPTION=Libraries for the GTK+ syntax highlighting widget.
GTKSOURCEVIEW2_SECTION=lib
GTKSOURCEVIEW2_PRIORITY=optional
GTKSOURCEVIEW2_DEPENDS=gtk2
GTKSOURCEVIEW2_SUGGESTS=
GTKSOURCEVIEW2_CONFLICTS=

#
# GTKSOURCEVIEW2_IPK_VERSION should be incremented when the ipk changes.
#
GTKSOURCEVIEW2_IPK_VERSION=1

#
# GTKSOURCEVIEW2_CONFFILES should be a list of user-editable files
#GTKSOURCEVIEW2_CONFFILES=/opt/etc/gtksourceview2.conf /opt/etc/init.d/SXXgtksourceview2

#
# GTKSOURCEVIEW2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GTKSOURCEVIEW2_PATCHES=$(GTKSOURCEVIEW2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTKSOURCEVIEW2_CPPFLAGS=
GTKSOURCEVIEW2_LDFLAGS=

#
# GTKSOURCEVIEW2_BUILD_DIR is the directory in which the build is done.
# GTKSOURCEVIEW2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTKSOURCEVIEW2_IPK_DIR is the directory in which the ipk is built.
# GTKSOURCEVIEW2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTKSOURCEVIEW2_BUILD_DIR=$(BUILD_DIR)/gtksourceview2
GTKSOURCEVIEW2_SOURCE_DIR=$(SOURCE_DIR)/gtksourceview2
GTKSOURCEVIEW2_IPK_DIR=$(BUILD_DIR)/gtksourceview2-$(GTKSOURCEVIEW2_VERSION)-ipk
GTKSOURCEVIEW2_IPK=$(BUILD_DIR)/gtksourceview2_$(GTKSOURCEVIEW2_VERSION)-$(GTKSOURCEVIEW2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gtksourceview2-source gtksourceview2-unpack gtksourceview2 gtksourceview2-stage gtksourceview2-ipk gtksourceview2-clean gtksourceview2-dirclean gtksourceview2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTKSOURCEVIEW2_SOURCE):
	$(WGET) -P $(@D) $(GTKSOURCEVIEW2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtksourceview2-source: $(DL_DIR)/$(GTKSOURCEVIEW2_SOURCE) $(GTKSOURCEVIEW2_PATCHES)

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
$(GTKSOURCEVIEW2_BUILD_DIR)/.configured: $(DL_DIR)/$(GTKSOURCEVIEW2_SOURCE) $(GTKSOURCEVIEW2_PATCHES) make/gtksourceview2.mk
	$(MAKE) gtk2-stage
	rm -rf $(BUILD_DIR)/$(GTKSOURCEVIEW2_DIR) $(@D)
	$(GTKSOURCEVIEW2_UNZIP) $(DL_DIR)/$(GTKSOURCEVIEW2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTKSOURCEVIEW2_PATCHES)" ; \
		then cat $(GTKSOURCEVIEW2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GTKSOURCEVIEW2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GTKSOURCEVIEW2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GTKSOURCEVIEW2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTKSOURCEVIEW2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTKSOURCEVIEW2_LDFLAGS)" \
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

gtksourceview2-unpack: $(GTKSOURCEVIEW2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GTKSOURCEVIEW2_BUILD_DIR)/.built: $(GTKSOURCEVIEW2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gtksourceview2: $(GTKSOURCEVIEW2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTKSOURCEVIEW2_BUILD_DIR)/.staged: $(GTKSOURCEVIEW2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgtksourceview-2.0.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gtksourceview-2.0.pc
	touch $@

gtksourceview2-stage: $(GTKSOURCEVIEW2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gtksourceview2
#
$(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtksourceview2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTKSOURCEVIEW2_PRIORITY)" >>$@
	@echo "Section: $(GTKSOURCEVIEW2_SECTION)" >>$@
	@echo "Version: $(GTKSOURCEVIEW2_VERSION)-$(GTKSOURCEVIEW2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTKSOURCEVIEW2_MAINTAINER)" >>$@
	@echo "Source: $(GTKSOURCEVIEW2_SITE)/$(GTKSOURCEVIEW2_SOURCE)" >>$@
	@echo "Description: $(GTKSOURCEVIEW2_DESCRIPTION)" >>$@
	@echo "Depends: $(GTKSOURCEVIEW2_DEPENDS)" >>$@
	@echo "Suggests: $(GTKSOURCEVIEW2_SUGGESTS)" >>$@
	@echo "Conflicts: $(GTKSOURCEVIEW2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTKSOURCEVIEW2_IPK_DIR)/opt/sbin or $(GTKSOURCEVIEW2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTKSOURCEVIEW2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/gtksourceview2/...
# Documentation files should be installed in $(GTKSOURCEVIEW2_IPK_DIR)/opt/doc/gtksourceview2/...
# Daemon startup scripts should be installed in $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/init.d/S??gtksourceview2
#
# You may need to patch your application to make it use these locations.
#
$(GTKSOURCEVIEW2_IPK): $(GTKSOURCEVIEW2_BUILD_DIR)/.built
	rm -rf $(GTKSOURCEVIEW2_IPK_DIR) $(BUILD_DIR)/gtksourceview2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTKSOURCEVIEW2_BUILD_DIR) DESTDIR=$(GTKSOURCEVIEW2_IPK_DIR) install-strip
	rm -f $(GTKSOURCEVIEW2_IPK_DIR)/opt/lib/*.la
#	$(INSTALL) -d $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(GTKSOURCEVIEW2_SOURCE_DIR)/gtksourceview2.conf $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/gtksourceview2.conf
#	$(INSTALL) -d $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW2_SOURCE_DIR)/rc.gtksourceview2 $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/init.d/SXXgtksourceview2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW2_IPK_DIR)/opt/etc/init.d/SXXgtksourceview2
	$(MAKE) $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW2_SOURCE_DIR)/postinst $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GTKSOURCEVIEW2_SOURCE_DIR)/prerm $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/postinst $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GTKSOURCEVIEW2_CONFFILES) | sed -e 's/ /\n/g' > $(GTKSOURCEVIEW2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTKSOURCEVIEW2_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GTKSOURCEVIEW2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtksourceview2-ipk: $(GTKSOURCEVIEW2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtksourceview2-clean:
	rm -f $(GTKSOURCEVIEW2_BUILD_DIR)/.built
	-$(MAKE) -C $(GTKSOURCEVIEW2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtksourceview2-dirclean:
	rm -rf $(BUILD_DIR)/$(GTKSOURCEVIEW2_DIR) $(GTKSOURCEVIEW2_BUILD_DIR) $(GTKSOURCEVIEW2_IPK_DIR) $(GTKSOURCEVIEW2_IPK)
#
#
# Some sanity check for the package.
#
gtksourceview2-check: $(GTKSOURCEVIEW2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
