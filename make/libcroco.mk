###########################################################
#
# libcroco
#
###########################################################

# You must replace "libcroco" and "LIBCROCO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBCROCO_VERSION, LIBCROCO_SITE and LIBCROCO_SOURCE define
# the upstream location of the source code for the package.
# LIBCROCO_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCROCO_UNZIP is the command used to unzip the source.
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
LIBCROCO_SITE=http://ftp.gnome.org/pub/gnome/sources/libcroco/0.6
LIBCROCO_VERSION=0.6.8
LIBCROCO_SOURCE=libcroco-$(LIBCROCO_VERSION).tar.xz
LIBCROCO_DIR=libcroco-$(LIBCROCO_VERSION)
LIBCROCO_UNZIP=xzcat
LIBCROCO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCROCO_DESCRIPTION=CSS2 parsing and manipulation library. 
LIBCROCO_SECTION=lib
LIBCROCO_PRIORITY=optional
LIBCROCO_DEPENDS=glib, libxml2
LIBCROCO_SUGGESTS=
LIBCROCO_CONFLICTS=

#
# LIBCROCO_IPK_VERSION should be incremented when the ipk changes.
#
LIBCROCO_IPK_VERSION=1

#
# LIBCROCO_CONFFILES should be a list of user-editable files
#LIBCROCO_CONFFILES=/opt/etc/libcroco.conf /opt/etc/init.d/SXXlibcroco

#
# LIBCROCO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBCROCO_PATCHES=$(LIBCROCO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCROCO_CPPFLAGS=
LIBCROCO_LDFLAGS=

#
# LIBCROCO_BUILD_DIR is the directory in which the build is done.
# LIBCROCO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCROCO_IPK_DIR is the directory in which the ipk is built.
# LIBCROCO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCROCO_BUILD_DIR=$(BUILD_DIR)/libcroco
LIBCROCO_SOURCE_DIR=$(SOURCE_DIR)/libcroco
LIBCROCO_IPK_DIR=$(BUILD_DIR)/libcroco-$(LIBCROCO_VERSION)-ipk
LIBCROCO_IPK=$(BUILD_DIR)/libcroco_$(LIBCROCO_VERSION)-$(LIBCROCO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libcroco-source libcroco-unpack libcroco libcroco-stage libcroco-ipk libcroco-clean libcroco-dirclean libcroco-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCROCO_SOURCE):
	$(WGET) -P $(@D) $(LIBCROCO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcroco-source: $(DL_DIR)/$(LIBCROCO_SOURCE) $(LIBCROCO_PATCHES)

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
$(LIBCROCO_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCROCO_SOURCE) $(LIBCROCO_PATCHES) make/libcroco.mk
	$(MAKE) glib-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(LIBCROCO_DIR) $(@D)
	$(LIBCROCO_UNZIP) $(DL_DIR)/$(LIBCROCO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBCROCO_PATCHES)" ; \
		then cat $(LIBCROCO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBCROCO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBCROCO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBCROCO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCROCO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCROCO_LDFLAGS)" \
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

libcroco-unpack: $(LIBCROCO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBCROCO_BUILD_DIR)/.built: $(LIBCROCO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libcroco: $(LIBCROCO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCROCO_BUILD_DIR)/.staged: $(LIBCROCO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libcroco-0.6.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libcroco-0.6.pc
	touch $@

libcroco-stage: $(LIBCROCO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libcroco
#
$(LIBCROCO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libcroco" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCROCO_PRIORITY)" >>$@
	@echo "Section: $(LIBCROCO_SECTION)" >>$@
	@echo "Version: $(LIBCROCO_VERSION)-$(LIBCROCO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCROCO_MAINTAINER)" >>$@
	@echo "Source: $(LIBCROCO_SITE)/$(LIBCROCO_SOURCE)" >>$@
	@echo "Description: $(LIBCROCO_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCROCO_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCROCO_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCROCO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCROCO_IPK_DIR)/opt/sbin or $(LIBCROCO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCROCO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBCROCO_IPK_DIR)/opt/etc/libcroco/...
# Documentation files should be installed in $(LIBCROCO_IPK_DIR)/opt/doc/libcroco/...
# Daemon startup scripts should be installed in $(LIBCROCO_IPK_DIR)/opt/etc/init.d/S??libcroco
#
# You may need to patch your application to make it use these locations.
#
$(LIBCROCO_IPK): $(LIBCROCO_BUILD_DIR)/.built
	rm -rf $(LIBCROCO_IPK_DIR) $(BUILD_DIR)/libcroco_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBCROCO_BUILD_DIR) DESTDIR=$(LIBCROCO_IPK_DIR) install-strip
	rm -f $(LIBCROCO_IPK_DIR)/opt/lib/libcroco-0.6.la
#	$(INSTALL) -d $(LIBCROCO_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(LIBCROCO_SOURCE_DIR)/libcroco.conf $(LIBCROCO_IPK_DIR)/opt/etc/libcroco.conf
#	$(INSTALL) -d $(LIBCROCO_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(LIBCROCO_SOURCE_DIR)/rc.libcroco $(LIBCROCO_IPK_DIR)/opt/etc/init.d/SXXlibcroco
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCROCO_IPK_DIR)/opt/etc/init.d/SXXlibcroco
	$(MAKE) $(LIBCROCO_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBCROCO_SOURCE_DIR)/postinst $(LIBCROCO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCROCO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBCROCO_SOURCE_DIR)/prerm $(LIBCROCO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCROCO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBCROCO_IPK_DIR)/CONTROL/postinst $(LIBCROCO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBCROCO_CONFFILES) | sed -e 's/ /\n/g' > $(LIBCROCO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCROCO_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBCROCO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcroco-ipk: $(LIBCROCO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcroco-clean:
	rm -f $(LIBCROCO_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBCROCO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcroco-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCROCO_DIR) $(LIBCROCO_BUILD_DIR) $(LIBCROCO_IPK_DIR) $(LIBCROCO_IPK)
#
#
# Some sanity check for the package.
#
libcroco-check: $(LIBCROCO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
