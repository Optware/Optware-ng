###########################################################
#
# gtk2
#
###########################################################

#
# GTK2_VERSION, GTK2_SITE and GTK2_SOURCE define
# the upstream location of the source code for the package.
# GTK2_DIR is the directory which is created when the source
# archive is unpacked.
# GTK2_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
GTK2_SITE=http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24
GTK2_VERSION=2.24.27
GTK2_SOURCE=gtk+-$(GTK2_VERSION).tar.xz
GTK2_DIR=gtk+-$(GTK2_VERSION)
GTK2_UNZIP=xzcat
GTK2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTK2_DESCRIPTION=GTK+-2.0 widget library
GTK2_PRINT_DESCRIPTION=GTK+-2.0 printing files
GTK2_DOC_DESCRIPTION=GTK+-2.0 docs
GTK2_SECTION=lib
GTK2_PRIORITY=optional
GTK2_DEPENDS=pango, atk, gdk-pixbuf, x11, xext, libtiff, libjpeg (>= 6b-2), libpng, xfixes, xcursor, xft, ttf-bitstream-vera, gconv-modules, \
	hicolor-icon-theme, shared-mime-info, gsettings-desktop-schemas
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GTK2_DEPENDS+=, libiconv
endif
GTK2_PRINT_DEPENDS=gtk2, cups

#
# GTK2_IPK_VERSION should be incremented when the ipk changes.
#
GTK2_IPK_VERSION=6

#
# GTK2_LOCALES defines which locales get installed
#
GTK2_LOCALES=

#
# GTK2_CONFFILES should be a list of user-editable files
#GTK2_CONFFILES=$(TARGET_PREFIX)/etc/gtk2.conf $(TARGET_PREFIX)/etc/init.d/SXXgtk2

#
# GTK2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GTK2_PATCHES=$(GTK2_SOURCE_DIR)/no-update-icon-cache.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTK2_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/atk-1.0 -I$(STAGING_INCLUDE_DIR)/freetype2
GTK2_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GTK2_LDFLAGS += -liconv
endif

#
# GTK2_BUILD_DIR is the directory in which the build is done.
# GTK2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTK2_IPK_DIR is the directory in which the ipk is built.
# GTK2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTK2_BUILD_DIR=$(BUILD_DIR)/gtk2
GTK2_SOURCE_DIR=$(SOURCE_DIR)/gtk2

GTK2_IPK_DIR=$(BUILD_DIR)/gtk2-$(GTK2_VERSION)-ipk
GTK2_IPK=$(BUILD_DIR)/gtk2_$(GTK2_VERSION)-$(GTK2_IPK_VERSION)_$(TARGET_ARCH).ipk

GTK2_PRINT_IPK_DIR=$(BUILD_DIR)/gtk2-print-$(GTK2_VERSION)-ipk
GTK2_PRINT_IPK=$(BUILD_DIR)/gtk2-print_$(GTK2_VERSION)-$(GTK2_IPK_VERSION)_$(TARGET_ARCH).ipk

GTK2_DOC_IPK_DIR=$(BUILD_DIR)/gtk2-doc-$(GTK2_VERSION)-ipk
GTK2_DOC_IPK=$(BUILD_DIR)/gtk2-doc_$(GTK2_VERSION)-$(GTK2_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(GTK2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtk2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK2_PRIORITY)" >>$@
	@echo "Section: $(GTK2_SECTION)" >>$@
	@echo "Version: $(GTK2_VERSION)-$(GTK2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK2_MAINTAINER)" >>$@
	@echo "Source: $(GTK2_SITE)/$(GTK2_SOURCE)" >>$@
	@echo "Description: $(GTK2_DESCRIPTION)" >>$@
	@echo "Depends: $(GTK2_DEPENDS)" >>$@

$(GTK2_PRINT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtk2-print" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK2_PRIORITY)" >>$@
	@echo "Section: $(GTK2_SECTION)" >>$@
	@echo "Version: $(GTK2_VERSION)-$(GTK2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK2_MAINTAINER)" >>$@
	@echo "Source: $(GTK2_SITE)/$(GTK2_SOURCE)" >>$@
	@echo "Description: $(GTK2_PRINT_DESCRIPTION)" >>$@
	@echo "Depends: $(GTK2_PRINT_DEPENDS)" >>$@

$(GTK2_DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gtk2-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTK2_PRIORITY)" >>$@
	@echo "Section: $(GTK2_SECTION)" >>$@
	@echo "Version: $(GTK2_VERSION)-$(GTK2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTK2_MAINTAINER)" >>$@
	@echo "Source: $(GTK2_SITE)/$(GTK2_SOURCE)" >>$@
	@echo "Description: $(GTK2_DOC_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTK2_SOURCE):
	$(WGET) -P $(@D) $(GTK2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtk2-source: $(DL_DIR)/$(GTK2_SOURCE) $(GTK2_PATCHES)

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
$(GTK2_BUILD_DIR)/.configured: $(DL_DIR)/$(GTK2_SOURCE) $(GTK2_PATCHES) make/gtk2.mk
	$(MAKE) libtiff-stage libpng-stage libjpeg-stage \
	x11-stage xcursor-stage xfixes-stage xext-stage xft-stage \
	pango-stage cairo-stage atk-stage gdk-pixbuf-stage cups-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GTK2_DIR) $(@D)
	$(GTK2_UNZIP) $(DL_DIR)/$(GTK2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTK2_PATCHES)" ; \
		then cat $(GTK2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GTK2_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(GTK2_DIR) $(@D)
	sed -i -e '/SRC_SUBDIRS *=/s| demos||' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTK2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTK2_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_path_PERL=/usr/bin/perl \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--bindir=\$${prefix}/bin/gtk-2.0 \
                --without-libjasper \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--disable-static \
		--disable-glibtest \
		--enable-cups \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gtk2-unpack: $(GTK2_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GTK2_BUILD_DIR)/.built: $(GTK2_BUILD_DIR)/.configured
	rm -f $@
	$(INSTALL) -m 644 $(GTK2_SOURCE_DIR)/test-inline-pixbufs.h $(@D)/demos
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gtk2: $(GTK2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTK2_BUILD_DIR)/.staged: $(GTK2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GTK2_BUILD_DIR) install-strip prefix=$(STAGING_PREFIX)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gail.pc $(STAGING_LIB_DIR)/pkgconfig/g[dt]k*2.0.pc
	rm -f $(STAGING_PREFIX)/bin/gtk-2.0/gdk-pixbuf-csource
	rm -f $(STAGING_LIB_DIR)/libgailutil.la
	rm -f $(STAGING_LIB_DIR)/libgdk-x11-2.0.la
	rm -f $(STAGING_LIB_DIR)/libgdk_pixbuf-2.0.la
	rm -f $(STAGING_LIB_DIR)/libgdk_pixbuf_xlib-2.0.la
	rm -f $(STAGING_LIB_DIR)/libgtk-x11-2.0.la
	touch $@

gtk2-stage: $(GTK2_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTK2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GTK2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTK2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GTK2_IPK_DIR)$(TARGET_PREFIX)/etc/gtk2/...
# Documentation files should be installed in $(GTK2_IPK_DIR)$(TARGET_PREFIX)/doc/gtk2/...
# Daemon startup scripts should be installed in $(GTK2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gtk2
#
# You may need to patch your application to make it use these locations.
#
$(GTK2_IPK) $(GTK2_DOC_IPK) $(GTK2_PRINT_IPK): $(GTK2_BUILD_DIR)/.built
	rm -rf $(GTK2_IPK_DIR) $(GTK2_DOC_IPK_DIR) $(GTK2_PRINT_IPK_DIR) \
		$(BUILD_DIR)/gtk2_*_$(TARGET_ARCH).ipk \
		$(BUILD_DIR)/gtk2-doc_*_$(TARGET_ARCH).ipk \
		$(BUILD_DIR)/gtk2-print_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTK2_BUILD_DIR) DESTDIR=$(GTK2_IPK_DIR) install-strip
	$(INSTALL) -d $(GTK2_IPK_DIR)$(TARGET_PREFIX)/etc/gtk-2.0
	### make gtk2-doc-ipk
	$(INSTALL) -d $(GTK2_DOC_IPK_DIR)$(TARGET_PREFIX)/share
	mv -f $(GTK2_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc $(GTK2_DOC_IPK_DIR)$(TARGET_PREFIX)/share/
	$(MAKE) $(GTK2_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK2_DOC_IPK_DIR)
	### make gtk2-print-ipk
	find $(GTK2_IPK_DIR) -type f -name *.la -exec rm -f {} \;
	$(INSTALL) -d $(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/include \
		$(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-2.0/2.10.0 \
		$(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	mv -f $(GTK2_IPK_DIR)$(TARGET_PREFIX)/include/gtk-unix-print-2.0 \
		$(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/include/
	mv -f $(GTK2_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-2.0/2.10.0/printbackends \
		$(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/gtk-2.0/2.10.0/
	mv -f $(GTK2_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/gtk+-unix-print-2.0.pc \
		$(GTK2_PRINT_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/
	$(MAKE) $(GTK2_PRINT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK2_PRINT_IPK_DIR)
	### make gtk2-ipk
	$(MAKE) $(GTK2_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(GTK2_SOURCE_DIR)/postinst $(GTK2_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTK2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtk2-ipk: $(GTK2_IPK) $(GTK2_DOC_IPK) $(GTK2_PRINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtk2-clean:
	-$(MAKE) -C $(GTK2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtk2-dirclean:
	rm -rf $(BUILD_DIR)/$(GTK2_DIR) $(GTK2_BUILD_DIR) \
		$(GTK2_IPK_DIR) $(GTK2_DOC_IPK_DIR) $(GTK2_PRINT_IPK_DIR) \
		$(GTK2_IPK) $(GTK2_DOC_IPK) $(GTK2_PRINT_IPK)

#
# Some sanity check for the package.
#
gtk2-check: $(GTK2_IPK) $(GTK2_DOC_IPK) $(GTK2_PRINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
