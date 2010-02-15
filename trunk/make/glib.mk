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
GLIB_SITE=http://ftp.gnome.org/pub/gnome/sources/glib/2.20
GLIB_VERSION=2.20.4
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

GLIB_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/glib

.PHONY: glib-source glib-unpack glib glib-stage glib-ipk glib-clean glib-dirclean \
glib-check glib-host glib-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GLIB_SOURCE):
	$(WGET) -P $(@D) $(GLIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
glib-source: $(DL_DIR)/$(GLIB_SOURCE) $(GLIB_PATCHES)


$(GLIB_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GLIB_SOURCE) make/glib.mk
	rm -rf $(HOST_BUILD_DIR)/$(GLIB_DIR) $(@D)
	$(GLIB_UNZIP) $(DL_DIR)/$(GLIB_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(GLIB_DIR) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=/opt	\
	)
	$(MAKE) -C $(@D)
	touch $@

glib-host: $(GLIB_HOST_BUILD_DIR)/.built


$(GLIB_HOST_BUILD_DIR)/.staged: $(GLIB_HOST_BUILD_DIR)/.built host/.configured make/glib.mk
	rm -f $@
	$(MAKE) -C $(@D) install prefix=$(HOST_STAGING_PREFIX)
	touch $@

glib-host-stage: $(GLIB_HOST_BUILD_DIR)/.staged


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
$(GLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(GLIB_SOURCE) $(GLIB_PATCHES) make/glib.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) glib-host-stage
endif
	rm -rf $(BUILD_DIR)/$(GLIB_DIR) $(@D)
	$(GLIB_UNZIP) $(DL_DIR)/$(GLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	if test -n "$(GLIB_PATCHES)" ; \
#		then cat $(GLIB_PATCHES) | \
#		patch -d $(BUILD_DIR)/$(GLIB_DIR) -p1 ; \
#	fi
	mv $(BUILD_DIR)/$(GLIB_DIR) $(@D)
	cp $(SOURCE_DIR)/glib/glib.cache $(@D)/arm.cache
#	sed -i -e '/^ALL_LINGUAS=/s/"[^"]\+"$$/$(GLIB_LOCALES)/;' $(@D)/configure
	sed -i -e 's/^ *$$as_echo_n /echo -n /' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GLIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GLIB_LDFLAGS)" \
        ac_cv_func_posix_getgrgid_r=yes \
        $(if $(filter $(HOSTCC), $(TARGET_CC)),,PATH=$$PATH:$(HOST_STAGING_PREFIX)/bin) \
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
	sed -i -e '/#define _POSIX_SOURCE/a#include <bits/posix1_lim.h>' $(@D)/glib/giounix.c
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

glib-unpack: $(GLIB_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GLIB_BUILD_DIR)/.built: $(GLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
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
	$(MAKE) -C $(@D) install-strip prefix=$(STAGING_DIR)/opt
	install $(@D)/glibconfig.h $(STAGING_INCLUDE_DIR)/glib-2.0/
	rm -rf $(STAGING_DIR)/opt/lib/libgio-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libglib-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgmodule-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgobject-2.0.la
	rm -rf $(STAGING_DIR)/opt/lib/libgthread-2.0.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
               -e 's|glib_mkenums=.*|glib_mkenums=$${prefix}/bin/glib-mkenums|' \
		$(STAGING_LIB_DIR)/pkgconfig/gio*-2.0.pc \
		$(STAGING_LIB_DIR)/pkgconfig/glib-2.0.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gmodule*-2.0.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gobject-2.0.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gthread-2.0.pc
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
	rm -f $(GLIB_BUILD_DIR)/.built
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
