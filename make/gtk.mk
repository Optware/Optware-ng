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
GTK_SITE=http://ftp.gnome.org/pub/gnome/sources/gtk+/3.16
GTK_VERSION=3.16.1
GTK_SOURCE=gtk+-$(GTK_VERSION).tar.xz
GTK_DIR=gtk+-$(GTK_VERSION)
GTK_UNZIP=xzcat
GTK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTK_DESCRIPTION=GTK+ widget library
GTK_PRINT_DESCRIPTION=GTK+ printing files
GTK_DOC_DESCRIPTION=GTK+ docs
GTK_SECTION=lib
GTK_PRIORITY=optional
GTK_DEPENDS=pango, atk, atk-bridge, gdk-pixbuf, libtiff, libjpeg (>= 6b-2), libpng, libepoxy, ttf-bitstream-vera, \
	gconv-modules, xext, xfixes, xcursor, xft, xi, libxkbcommon, gettext, pango, cairo, e2fsprogs, \
	hicolor-icon-theme, shared-mime-info, gsettings-desktop-schemas
ifeq (wayland, $(filter wayland, $(PACKAGES)))
GTK_DEPENDS+=, wayland
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GTK_DEPENDS+=, libiconv
endif
GTK_PRINT_DEPENDS=gtk, cups


#
# GTK_IPK_VERSION should be incremented when the ipk changes.
#
GTK_IPK_VERSION=4

#
# GTK_LOCALES defines which locales get installed
#
GTK_LOCALES=

#
# GTK_CONFFILES should be a list of user-editable files
#GTK_CONFFILES=$(TARGET_PREFIX)/etc/gtk.conf $(TARGET_PREFIX)/etc/init.d/SXXgtk

#
# GTK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GTK_PATCHES=\
$(GTK_SOURCE_DIR)/configure.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/atk-1.0 -I$(STAGING_INCLUDE_DIR)/freetype2
GTK_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GTK_LDFLAGS += -liconv
endif

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

GTK_PRINT_IPK_DIR=$(BUILD_DIR)/gtk-print-$(GTK_VERSION)-ipk
GTK_PRINT_IPK=$(BUILD_DIR)/gtk-print_$(GTK_VERSION)-$(GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

GTK_DOC_IPK_DIR=$(BUILD_DIR)/gtk-doc-$(GTK_VERSION)-ipk
GTK_DOC_IPK=$(BUILD_DIR)/gtk-doc_$(GTK_VERSION)-$(GTK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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

$(GTK_PRINT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtk-print" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK_PRIORITY)" >>$@
	@echo "Section: $(GTK_SECTION)" >>$@
	@echo "Version: $(GTK_VERSION)-$(GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK_MAINTAINER)" >>$@
	@echo "Source: $(GTK_SITE)/$(GTK_SOURCE)" >>$@
	@echo "Description: $(GTK_PRINT_DESCRIPTION)" >>$@
	@echo "Depends: $(GTK_PRINT_DEPENDS)" >>$@

$(GTK_DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtk-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK_PRIORITY)" >>$@
	@echo "Section: $(GTK_SECTION)" >>$@
	@echo "Version: $(GTK_VERSION)-$(GTK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK_MAINTAINER)" >>$@
	@echo "Source: $(GTK_SITE)/$(GTK_SOURCE)" >>$@
	@echo "Description: $(GTK_DOC_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTK_SOURCE):
	$(WGET) -P $(@D) $(GTK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(GTK_BUILD_DIR)/.configured: $(DL_DIR)/$(GTK_SOURCE) $(GTK_PATCHES) make/gtk.mk
	$(MAKE) glib-host-stage gettext-host-stage libtiff-stage libpng-stage libjpeg-stage \
	pango-stage cairo-stage atk-stage atk-bridge-stage gdk-pixbuf-stage cups-stage \
	xcursor-stage xfixes-stage xext-stage xft-stage xi-stage \
	libxkbcommon-stage gettext-stage pango-stage cairo-stage \
	e2fsprogs-stage gettext-host-stage libepoxy-stage
ifeq (wayland, $(filter wayland, $(PACKAGES)))
	$(MAKE) wayland-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GTK_DIR) $(@D)
	$(GTK_UNZIP) $(DL_DIR)/$(GTK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTK_PATCHES)" ; \
		then cat $(GTK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GTK_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(GTK_DIR) $(@D)
	sed -i -e '/SRC_SUBDIRS *=/s| demos||' $(@D)/Makefile.in
	sed -i -e '/SUBDIRS *=/s| native||' $(@D)/gtk/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTK_LDFLAGS)" \
		CPPFLAGS_FOR_BUILD="$(HOST_STAGING_CPPFLAGS)" \
		LDFLAGS_FOR_BUILD="$(HOST_STAGING_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_PERL=/usr/bin/perl \
		GLIB_COMPILE_SCHEMAS=$(HOST_STAGING_PREFIX)/bin/glib-compile-schemas \
		WAYLAND_SCANNER=$(HOST_STAGING_PREFIX)/bin/wayland-scanner \
		MSGFMT=$(HOST_STAGING_PREFIX)/bin/msgfmt \
		ac_cv_path_XGETTEXT=$(HOST_STAGING_PREFIX)/bin/xgettext \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
                --without-libjasper \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--disable-static \
		--disable-glibtest \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gtk-unpack: $(GTK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GTK_BUILD_DIR)/.built: $(GTK_BUILD_DIR)/.configured
	rm -f $@
	$(INSTALL) -m 644 $(GTK_SOURCE_DIR)/test-inline-pixbufs.h $(@D)/demos
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gtk: $(GTK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTK_BUILD_DIR)/.staged: $(GTK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GTK_BUILD_DIR) install prefix=$(STAGING_PREFIX)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		-e 's|-I$(TARGET_PREFIX)/include|-I$(STAGING_INCLUDE_DIR)|g' \
		$(STAGING_LIB_DIR)/pkgconfig/g[dt]k*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/gail-*.pc
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libgailutil-3.la libgdk-3.la libgtk-3.la)
	find $(STAGING_LIB_DIR)/gtk-3.0 -type f -name *.la -exec rm -f {} \;
	touch $@

gtk-stage: $(GTK_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GTK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GTK_IPK_DIR)$(TARGET_PREFIX)/etc/gtk/...
# Documentation files should be installed in $(GTK_IPK_DIR)$(TARGET_PREFIX)/doc/gtk/...
# Daemon startup scripts should be installed in $(GTK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gtk
#
# You may need to patch your application to make it use these locations.
#
$(GTK_IPK) $(GTK_DOC_IPK) $(GTK_PRINT_IPK): $(GTK_BUILD_DIR)/.built
	rm -rf $(GTK_IPK_DIR) $(GTK_DOC_IPK_DIR) $(GTK_PRINT_IPK_DIR) \
		$(BUILD_DIR)/gtk_*_$(TARGET_ARCH).ipk \
		$(BUILD_DIR)/gtk-doc_*_$(TARGET_ARCH).ipk \
		$(BUILD_DIR)/gtk-print_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTK_BUILD_DIR) DESTDIR=$(GTK_IPK_DIR) install-strip
	### make gtk-doc-ipk
	$(INSTALL) -d $(GTK_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	mv -f $(GTK_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc $(GTK_DOC_IPK_DIR)$(TARGET_PREFIX)/share/
	$(MAKE) $(GTK_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK_DOC_IPK_DIR)
	### make gtk-print-ipk
	find $(GTK_IPK_DIR) -type f -name *.la -exec rm -f {} \;
	$(INSTALL) -d $(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/include/gtk-3.0 \
		$(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-3.0/3.0.0 \
		$(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	mv -f $(GTK_IPK_DIR)$(TARGET_PREFIX)/include/gtk-3.0/unix-print \
		$(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/include/gtk-3.0/
	mv -f $(GTK_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-3.0/3.0.0/printbackends \
		$(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-3.0/3.0.0/
	mv -f $(GTK_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/gtk+-unix-print-3.0.pc \
		$(GTK_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/
	$(MAKE) $(GTK_PRINT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK_PRINT_IPK_DIR)
	### make gtk-ipk
	$(MAKE) $(GTK_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(GTK_SOURCE_DIR)/postinst $(GTK_IPK_DIR)/CONTROL/postinst
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
	rm -rf $(BUILD_DIR)/$(GTK_DIR) $(GTK_BUILD_DIR) \
		$(GTK_IPK_DIR) $(GTK_DOC_IPK_DIR) $(GTK_PRINT_IPK_DIR) \
		$(GTK_IPK) $(GTK_DOC_IPK) $(GTK_PRINT_IPK)

#
# Some sanity check for the package.
#
gtk-check: $(GTK_IPK) $(GTK_DOC_IPK) $(GTK_PRINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
