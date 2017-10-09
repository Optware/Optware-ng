###########################################################
#
# gdk-pixbuf
#
###########################################################

#
# GDK-PIXBUF_VERSION, GDK-PIXBUF_SITE and GDK-PIXBUF_SOURCE define
# the upstream location of the source code for the package.
# GDK-PIXBUF_DIR is the directory which is created when the source
# archive is unpacked.
# GDK-PIXBUF_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
GDK-PIXBUF_SITE=http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/2.31
GDK-PIXBUF_VERSION=2.31.3
GDK-PIXBUF_SOURCE=gdk-pixbuf-$(GDK-PIXBUF_VERSION).tar.xz
GDK-PIXBUF_DIR=gdk-pixbuf-$(GDK-PIXBUF_VERSION)
GDK-PIXBUF_UNZIP=xzcat
GDK-PIXBUF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GDK-PIXBUF_DESCRIPTION=GNOME accessibility toolkit
GDK-PIXBUF_SECTION=lib
GDK-PIXBUF_PRIORITY=optional
GDK-PIXBUF_DEPENDS=glib, gettext, libjpeg, libpng, libtiff, x11, gobject-introspection

#
# GDK-PIXBUF_IPK_VERSION should be incremented when the ipk changes.
#
GDK-PIXBUF_IPK_VERSION=5

#
# GDK-PIXBUF_LOCALES defines which locales get installed
#
GDK-PIXBUF_LOCALES=

#
# GDK-PIXBUF_CONFFILES should be a list of user-editable files
#GDK-PIXBUF_CONFFILES=$(TARGET_PREFIX)/etc/gdk-pixbuf.conf $(TARGET_PREFIX)/etc/init.d/SXXgdk-pixbuf

#
# GDK-PIXBUF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GDK-PIXBUF_PATCHES=$(GDK-PIXBUF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GDK-PIXBUF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
GDK-PIXBUF_LDFLAGS=

#
# GDK-PIXBUF_BUILD_DIR is the directory in which the build is done.
# GDK-PIXBUF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GDK-PIXBUF_IPK_DIR is the directory in which the ipk is built.
# GDK-PIXBUF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GDK-PIXBUF_BUILD_DIR=$(BUILD_DIR)/gdk-pixbuf
GDK-PIXBUF_SOURCE_DIR=$(SOURCE_DIR)/gdk-pixbuf
GDK-PIXBUF_IPK_DIR=$(BUILD_DIR)/gdk-pixbuf-$(GDK-PIXBUF_VERSION)-ipk
GDK-PIXBUF_IPK=$(BUILD_DIR)/gdk-pixbuf_$(GDK-PIXBUF_VERSION)-$(GDK-PIXBUF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(GDK-PIXBUF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gdk-pixbuf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GDK-PIXBUF_PRIORITY)" >>$@
	@echo "Section: $(GDK-PIXBUF_SECTION)" >>$@
	@echo "Version: $(GDK-PIXBUF_VERSION)-$(GDK-PIXBUF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GDK-PIXBUF_MAINTAINER)" >>$@
	@echo "Source: $(GDK-PIXBUF_SITE)/$(GDK-PIXBUF_SOURCE)" >>$@
	@echo "Description: $(GDK-PIXBUF_DESCRIPTION)" >>$@
	@echo "Depends: $(GDK-PIXBUF_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GDK-PIXBUF_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDK-PIXBUF_SITE)/$(GDK-PIXBUF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gdk-pixbuf-source: $(DL_DIR)/$(GDK-PIXBUF_SOURCE) $(GDK-PIXBUF_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(GDK-PIXBUF_BUILD_DIR)/.configured: $(DL_DIR)/$(GDK-PIXBUF_SOURCE) $(GDK-PIXBUF_PATCHES) \
		$(GDK-PIXBUF_SOURCE_DIR)/$(GDK-PIXBUF_VERSION)/GdkPixbuf-2.0.gir make/gdk-pixbuf.mk
	$(MAKE) glib-stage libjpeg-stage libpng-stage libtiff-stage gettext-stage \
		x11-stage
	rm -rf $(BUILD_DIR)/$(GDK-PIXBUF_DIR) $(@D)
	$(GDK-PIXBUF_UNZIP) $(DL_DIR)/$(GDK-PIXBUF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GDK-PIXBUF_PATCHES)" ; \
		then cat $(GDK-PIXBUF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GDK-PIXBUF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GDK-PIXBUF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GDK-PIXBUF_DIR) $(@D) ; \
	fi
	(cd $(GDK-PIXBUF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GDK-PIXBUF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GDK-PIXBUF_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-x11 \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gdk-pixbuf-unpack: $(GDK-PIXBUF_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GDK-PIXBUF_BUILD_DIR)/.built: $(GDK-PIXBUF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gdk-pixbuf: $(GDK-PIXBUF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GDK-PIXBUF_BUILD_DIR)/.staged: $(GDK-PIXBUF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install-strip prefix=$(STAGING_PREFIX)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gdk-pixbuf-2.0.pc \
							$(STAGING_LIB_DIR)/pkgconfig/gdk-pixbuf-xlib-2.0.pc
	sed -i -e 's|^gdk_pixbuf_binarydir=\$${exec_prefix}|gdk_pixbuf_binarydir=$(TARGET_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gdk-pixbuf-2.0.pc
	rm -f $(STAGING_LIB_DIR)/libgdk_pixbuf-2.0.la $(STAGING_LIB_DIR)/libgdk_pixbuf_xlib-2.0.la \
		$(STAGING_LIB_DIR)/gdk-pixbuf-2.0/2.10.0/loaders/*.la
	touch $@

gdk-pixbuf-stage: $(GDK-PIXBUF_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/etc/gdk-pixbuf/...
# Documentation files should be installed in $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/doc/gdk-pixbuf/...
# Daemon startup scripts should be installed in $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gdk-pixbuf
#
# You may need to patch your application to make it use these locations.
#
$(GDK-PIXBUF_IPK): $(GDK-PIXBUF_BUILD_DIR)/.built
	rm -rf $(GDK-PIXBUF_IPK_DIR) $(BUILD_DIR)/gdk-pixbuf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GDK-PIXBUF_BUILD_DIR) DESTDIR=$(GDK-PIXBUF_IPK_DIR) install-strip
	$(INSTALL) -d $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/share/gir-1.0
	$(INSTALL) -m 644 $(GDK-PIXBUF_SOURCE_DIR)/$(GDK-PIXBUF_VERSION)/GdkPixbuf-2.0.gir \
		$(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/share/gir-1.0/GdkPixbuf-2.0.gir
	find $(GDK-PIXBUF_IPK_DIR) -type f -name *.la -exec rm -f {} \;
	rm -rf $(GDK-PIXBUF_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc
	$(MAKE) $(GDK-PIXBUF_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(GDK-PIXBUF_SOURCE_DIR)/postinst $(GDK-PIXBUF_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(GDK-PIXBUF_SOURCE_DIR)/prerm $(GDK-PIXBUF_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDK-PIXBUF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gdk-pixbuf-ipk: $(GDK-PIXBUF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gdk-pixbuf-clean:
	-$(MAKE) -C $(GDK-PIXBUF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gdk-pixbuf-dirclean:
	rm -rf $(BUILD_DIR)/$(GDK-PIXBUF_DIR) $(GDK-PIXBUF_BUILD_DIR) $(GDK-PIXBUF_IPK_DIR) $(GDK-PIXBUF_IPK)
