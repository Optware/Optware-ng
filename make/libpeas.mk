###########################################################
#
# libpeas
#
###########################################################

# You must replace "libpeas" and "LIBPEAS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPEAS_VERSION, LIBPEAS_SITE and LIBPEAS_SOURCE define
# the upstream location of the source code for the package.
# LIBPEAS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPEAS_UNZIP is the command used to unzip the source.
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
LIBPEAS_SITE=http://ftp.gnome.org/pub/gnome/sources/libpeas/1.14
LIBPEAS_VERSION=1.14.0
LIBPEAS_SOURCE=libpeas-$(LIBPEAS_VERSION).tar.xz
LIBPEAS_DIR=libpeas-$(LIBPEAS_VERSION)
LIBPEAS_UNZIP=xzcat
LIBPEAS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPEAS_DESCRIPTION=GObject based plugins engine, targeted at giving every application the chance to assume its own extensibility.
LIBPEAS_SECTION=lib
LIBPEAS_PRIORITY=optional
LIBPEAS_DEPENDS=gtk, gobject-introspection
LIBPEAS_SUGGESTS=
LIBPEAS_CONFLICTS=

#
# LIBPEAS_IPK_VERSION should be incremented when the ipk changes.
#
LIBPEAS_IPK_VERSION=2

#
# LIBPEAS_CONFFILES should be a list of user-editable files
#LIBPEAS_CONFFILES=$(TARGET_PREFIX)/etc/libpeas.conf $(TARGET_PREFIX)/etc/init.d/SXXlibpeas

#
# LIBPEAS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBPEAS_PATCHES=$(LIBPEAS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPEAS_CPPFLAGS=
LIBPEAS_LDFLAGS=

#
# LIBPEAS_BUILD_DIR is the directory in which the build is done.
# LIBPEAS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPEAS_IPK_DIR is the directory in which the ipk is built.
# LIBPEAS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPEAS_BUILD_DIR=$(BUILD_DIR)/libpeas
LIBPEAS_SOURCE_DIR=$(SOURCE_DIR)/libpeas
LIBPEAS_IPK_DIR=$(BUILD_DIR)/libpeas-$(LIBPEAS_VERSION)-ipk
LIBPEAS_IPK=$(BUILD_DIR)/libpeas_$(LIBPEAS_VERSION)-$(LIBPEAS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpeas-source libpeas-unpack libpeas libpeas-stage libpeas-ipk libpeas-clean libpeas-dirclean libpeas-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPEAS_SOURCE):
	$(WGET) -P $(@D) $(LIBPEAS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpeas-source: $(DL_DIR)/$(LIBPEAS_SOURCE) $(LIBPEAS_PATCHES)

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
$(LIBPEAS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPEAS_SOURCE) $(LIBPEAS_PATCHES) make/libpeas.mk
	$(MAKE) gtk-stage gobject-introspection-stage
	rm -rf $(BUILD_DIR)/$(LIBPEAS_DIR) $(@D)
	$(LIBPEAS_UNZIP) $(DL_DIR)/$(LIBPEAS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBPEAS_PATCHES)" ; \
		then cat $(LIBPEAS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBPEAS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBPEAS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBPEAS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPEAS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPEAS_LDFLAGS)" \
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
	sed -i -e '/SUBDIRS = .*tests/s/tests//' $(@D)/Makefile
	sed -i -e '/Peas.*-1.0.gir/s/^/#/' $(@D)/*/Makefile
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libpeas-unpack: $(LIBPEAS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBPEAS_BUILD_DIR)/.built: $(LIBPEAS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libpeas: $(LIBPEAS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPEAS_BUILD_DIR)/.staged: $(LIBPEAS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpeas-*.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libpeas-*.pc
	touch $@

libpeas-stage: $(LIBPEAS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpeas
#
$(LIBPEAS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libpeas" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPEAS_PRIORITY)" >>$@
	@echo "Section: $(LIBPEAS_SECTION)" >>$@
	@echo "Version: $(LIBPEAS_VERSION)-$(LIBPEAS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPEAS_MAINTAINER)" >>$@
	@echo "Source: $(LIBPEAS_SITE)/$(LIBPEAS_SOURCE)" >>$@
	@echo "Description: $(LIBPEAS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPEAS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPEAS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPEAS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/libpeas/...
# Documentation files should be installed in $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/doc/libpeas/...
# Daemon startup scripts should be installed in $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libpeas
#
# You may need to patch your application to make it use these locations.
#
$(LIBPEAS_IPK): $(LIBPEAS_BUILD_DIR)/.built
	rm -rf $(LIBPEAS_IPK_DIR) $(BUILD_DIR)/libpeas_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBPEAS_BUILD_DIR) DESTDIR=$(LIBPEAS_IPK_DIR) install-strip
	rm -f $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBPEAS_SOURCE_DIR)/libpeas.conf $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/libpeas.conf
#	$(INSTALL) -d $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBPEAS_SOURCE_DIR)/rc.libpeas $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibpeas
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPEAS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibpeas
	$(MAKE) $(LIBPEAS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBPEAS_SOURCE_DIR)/postinst $(LIBPEAS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPEAS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBPEAS_SOURCE_DIR)/prerm $(LIBPEAS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPEAS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBPEAS_IPK_DIR)/CONTROL/postinst $(LIBPEAS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBPEAS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBPEAS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPEAS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBPEAS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpeas-ipk: $(LIBPEAS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpeas-clean:
	rm -f $(LIBPEAS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBPEAS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpeas-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPEAS_DIR) $(LIBPEAS_BUILD_DIR) $(LIBPEAS_IPK_DIR) $(LIBPEAS_IPK)
#
#
# Some sanity check for the package.
#
libpeas-check: $(LIBPEAS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
