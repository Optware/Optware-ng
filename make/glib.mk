###########################################################
#
# glib
#
###########################################################

#
# GLIB_VERSION, GLIB_SITE and GLIB_SOURCE define
# the upstream location of the source code for the package.
# GLIB_DIR is the directory which is created when the source
# archive is unpacked.
# GLIB_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
GLIB_SITE=ftp://ftp.gtk.org/pub/gtk/v2.9/
GLIB_VERSION=2.9.6
GLIB_SOURCE=glib-$(GLIB_VERSION).tar.bz2
GLIB_DIR=glib-$(GLIB_VERSION)
GLIB_UNZIP=bzcat
GLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GLIB_DESCRIPTION=The GLib library of C routines.
GLIB_SECTION=lib
GLIB_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GLIB_DEPENDS=libiconv
else
GLIB_DEPENDS=
endif
ifeq ($(GETTEXT_NLS), enable)
# assume standalone libiconv
GLIB_DEPENDS+=, gettext
endif
GLIB_SUGGESTS=
GLIB_CONFLICTS=

#
# GLIB_IPK_VERSION should be incremented when the ipk changes.
#
GLIB_IPK_VERSION=1

#
# GLIB_LOCALES defines which locales get installed
#
GLIB_LOCALES=

#
# GLIB_CONFFILES should be a list of user-editable files
#GLIB_CONFFILES=/opt/etc/glib.conf /opt/etc/init.d/SXXglib

#
# GLIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GLIB_PATCHES=$(GLIB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GLIB_CPPFLAGS=
GLIB_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GLIB_CONFIG_OPT=--with-libiconv=gnu
endif

#
# GLIB_BUILD_DIR is the directory in which the build is done.
# GLIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GLIB_IPK_DIR is the directory in which the ipk is built.
# GLIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GLIB_BUILD_DIR=$(BUILD_DIR)/glib
GLIB_SOURCE_DIR=$(SOURCE_DIR)/glib
GLIB_IPK_DIR=$(BUILD_DIR)/glib-$(GLIB_VERSION)-ipk
GLIB_IPK=$(BUILD_DIR)/glib_$(GLIB_VERSION)-$(GLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(GLIB_SITE)/$(GLIB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
glib-source: $(DL_DIR)/$(GLIB_SOURCE) $(GLIB_PATCHES)

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
$(GLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(GLIB_SOURCE) $(GLIB_PATCHES)
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(GLIB_DIR) $(GLIB_BUILD_DIR)
	$(GLIB_UNZIP) $(DL_DIR)/$(GLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(GLIB_PATCHES) | patch -d $(BUILD_DIR)/$(GLIB_DIR) -p1
	mv $(BUILD_DIR)/$(GLIB_DIR) $(GLIB_BUILD_DIR)
	cp $(SOURCE_DIR)/glib/glib.cache $(GLIB_BUILD_DIR)/arm.cache
	sed -i -e '/^ALL_LINGUAS=/s/"[^"]\+"$$/$(GLIB_LOCALES)/;' $(GLIB_BUILD_DIR)/configure
	(cd $(GLIB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GLIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GLIB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--cache-file=arm.cache \
		--prefix=/opt \
		$(GLIB_CONFIG_OPT) \
		--disable-nls \
		--disable-static \
	)
	sed -ie '/#define _POSIX_SOURCE/a#include <bits/posix1_lim.h>' $(GLIB_BUILD_DIR)/glib/giounix.c
	$(PATCH_LIBTOOL) $(GLIB_BUILD_DIR)/libtool
	touch $@

glib-unpack: $(GLIB_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GLIB_BUILD_DIR)/.built: $(GLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GLIB_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
glib: $(GLIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GLIB_BUILD_DIR)/.staged: $(GLIB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GLIB_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	install $(GLIB_BUILD_DIR)/glibconfig.h $(STAGING_INCLUDE_DIR)/glib-2.0/
	rm -rf $(STAGING_DIR)/opt/lib/libglib-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgmodule-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgobject-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgthread-2.0.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/glib-*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gmodule-*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gobject-*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gthread-*.pc
	touch $@

glib-stage: $(GLIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/glib
#
$(GLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: glib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLIB_PRIORITY)" >>$@
	@echo "Section: $(GLIB_SECTION)" >>$@
	@echo "Version: $(GLIB_VERSION)-$(GLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GLIB_MAINTAINER)" >>$@
	@echo "Source: $(GLIB_SITE)/$(GLIB_SOURCE)" >>$@
	@echo "Description: $(GLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(GLIB_DEPENDS)" >>$@
	@echo "Suggests: $(GLIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(GLIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GLIB_IPK_DIR)/opt/sbin or $(GLIB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GLIB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GLIB_IPK_DIR)/opt/etc/glib/...
# Documentation files should be installed in $(GLIB_IPK_DIR)/opt/doc/glib/...
# Daemon startup scripts should be installed in $(GLIB_IPK_DIR)/opt/etc/init.d/S??glib
#
# You may need to patch your application to make it use these locations.
#
$(GLIB_IPK): $(GLIB_BUILD_DIR)/.built
	rm -rf $(GLIB_IPK_DIR) $(BUILD_DIR)/glib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GLIB_BUILD_DIR) install-strip prefix=$(GLIB_IPK_DIR)/opt
	rm -rf $(GLIB_IPK_DIR)/opt/share/gtk-doc
	rm -rf $(GLIB_IPK_DIR)/opt/man
	$(MAKE) $(GLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
glib-ipk: $(GLIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
glib-clean:
	-$(MAKE) -C $(GLIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
glib-dirclean:
	rm -rf $(BUILD_DIR)/$(GLIB_DIR) $(GLIB_BUILD_DIR) $(GLIB_IPK_DIR) $(GLIB_IPK)

#
# Some sanity check for the package.
#
glib-check: $(GLIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GLIB_IPK)
