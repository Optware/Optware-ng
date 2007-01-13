###########################################################
#
# gtk
#
###########################################################

#
# GTK_VERSION, GTK_SITE and GTK_SOURCE define
# the upstream location of the source code for the package.
# GTK_DIR is the directory which is created when the source
# archive is unpacked.
# GTK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
GTK_SITE=ftp://ftp.gtk.org/pub/gtk/v2.6/
GTK_VERSION=2.6.7
GTK_SOURCE=gtk+-$(GTK_VERSION).tar.bz2
GTK_DIR=gtk+-$(GTK_VERSION)
GTK_UNZIP=bzcat
GTK_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
GTK_DESCRIPTION=Gtk+ widget library
GTK_SECTION=lib
GTK_PRIORITY=optional
GTK_DEPENDS=pango, atk, x11, xext, libtiff, libjpeg (>= 6b-2), libpng, xfixes, xcursor, xft, ttf-bitstream-vera, gconv-modules

#
# GTK_IPK_VERSION should be incremented when the ipk changes.
#
GTK_IPK_VERSION=2

#
# GTK_LOCALES defines which locales get installed
#
GTK_LOCALES=

#
# GTK_CONFFILES should be a list of user-editable files
#GTK_CONFFILES=/opt/etc/gtk.conf /opt/etc/init.d/SXXgtk

#
# GTK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GTK_PATCHES=$(GTK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/atk-1.0 -I$(STAGING_INCLUDE_DIR)/freetype2
GTK_LDFLAGS=

#
# GTK_BUILD_DIR is the directory in which the build is done.
# GTK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTK_IPK_DIR is the directory in which the ipk is built.
# GTK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTK_BUILD_DIR=$(BUILD_DIR)/gtk
GTK_SOURCE_DIR=$(SOURCE_DIR)/gtk
GTK_IPK_DIR=$(BUILD_DIR)/gtk-$(GTK_VERSION)-ipk
GTK_IPK=$(BUILD_DIR)/gtk_$(GTK_VERSION)-$(GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(GTK_IPK_DIR)/CONTROL/control:
	@install -d $(GTK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK_PRIORITY)" >>$@
	@echo "Section: $(GTK_SECTION)" >>$@
	@echo "Version: $(GTK_VERSION)-$(GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK_MAINTAINER)" >>$@
	@echo "Source: $(GTK_SITE)/$(GTK_SOURCE)" >>$@
	@echo "Description: $(GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(GTK_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTK_SOURCE):
	$(WGET) -P $(DL_DIR) $(GTK_SITE)/$(GTK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtk-source: $(DL_DIR)/$(GTK_SOURCE) $(GTK_PATCHES)

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
$(GTK_BUILD_DIR)/.configured: $(DL_DIR)/$(GTK_SOURCE) \
		$(GTK_PATCHES)
	$(MAKE) libtiff-stage
	$(MAKE) libpng-stage
	$(MAKE) libjpeg-stage
	$(MAKE) x11-stage
	$(MAKE) xcursor-stage
	$(MAKE) xfixes-stage
	$(MAKE) xext-stage
	$(MAKE) xft-stage
	$(MAKE) pango-stage
	$(MAKE) atk-stage
	rm -rf $(BUILD_DIR)/$(GTK_DIR) $(GTK_BUILD_DIR)
	$(GTK_UNZIP) $(DL_DIR)/$(GTK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(GTK_DIR) $(GTK_BUILD_DIR)
	(cd $(GTK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/opt/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTK_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_PERL=/usr/bin/perl \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--disable-static \
		--disable-glibtest \
	)
	$(PATCH_LIBTOOL) $(GTK_BUILD_DIR)/libtool
	touch $(GTK_BUILD_DIR)/.configured

gtk-unpack: $(GTK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GTK_BUILD_DIR)/.built: $(GTK_BUILD_DIR)/.configured
	rm -f $(GTK_BUILD_DIR)/.built
	cp $(GTK_SOURCE_DIR)/test-inline-pixbufs.h $(GTK_BUILD_DIR)/demos
	$(MAKE) -C $(GTK_BUILD_DIR)
	touch $(GTK_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gtk: $(GTK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTK_BUILD_DIR)/.staged: $(GTK_BUILD_DIR)/.built
	rm -f $(GTK_BUILD_DIR)/.staged
	$(MAKE) -C $(GTK_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/g[dt]k*.pc
	rm -f $(STAGING_DIR)/opt/bin/gdk-pixbuf-csource
	rm -f $(STAGING_DIR)/opt/lib/libgdk-x11-2.0.la
	rm -f $(STAGING_DIR)/opt/lib/libgdk_pixbuf-2.0.la
	rm -f $(STAGING_DIR)/opt/lib/libgdk_pixbuf_xlib-2.0.la
	rm -f $(STAGING_DIR)/opt/lib/libgtk-x11-2.0.la
	touch $(GTK_BUILD_DIR)/.staged

gtk-stage: $(GTK_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTK_IPK_DIR)/opt/sbin or $(GTK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GTK_IPK_DIR)/opt/etc/gtk/...
# Documentation files should be installed in $(GTK_IPK_DIR)/opt/doc/gtk/...
# Daemon startup scripts should be installed in $(GTK_IPK_DIR)/opt/etc/init.d/S??gtk
#
# You may need to patch your application to make it use these locations.
#
$(GTK_IPK): $(GTK_BUILD_DIR)/.built
	rm -rf $(GTK_IPK_DIR) $(BUILD_DIR)/gtk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTK_BUILD_DIR) DESTDIR=$(GTK_IPK_DIR) install-strip
	install -d $(GTK_IPK_DIR)/opt/etc/gtk-2.0
	rm -f $(GTK_IPK_DIR)/opt/lib/*.la
	rm -rf $(GTK_IPK_DIR)/opt/share/gtk-doc
	$(MAKE) $(GTK_IPK_DIR)/CONTROL/control
	install -m 644 $(GTK_SOURCE_DIR)/postinst $(GTK_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtk-ipk: $(GTK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtk-clean:
	-$(MAKE) -C $(GTK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtk-dirclean:
	rm -rf $(BUILD_DIR)/$(GTK_DIR) $(GTK_BUILD_DIR) $(GTK_IPK_DIR) $(GTK_IPK)
