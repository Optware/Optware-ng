###########################################################
#
# vte
#
###########################################################

#
# VTE_VERSION, VTE_SITE and VTE_SOURCE define
# the upstream location of the source code for the package.
# VTE_DIR is the directory which is created when the source
# archive is unpacked.
# VTE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
VTE_SITE=http://ftp.gnome.org/pub/gnome/sources/vte/0.11/
VTE_VERSION=0.11.21
VTE_SOURCE=vte-$(VTE_VERSION).tar.bz2
VTE_DIR=vte-$(VTE_VERSION)
VTE_UNZIP=bzcat
VTE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
VTE_DESCRIPTION=Gtk+ terminal widget
VTE_SECTION=lib
VTE_PRIORITY=optional
VTE_DEPENDS=gtk, ncurses, termcap, sm, dev-pts

#
# VTE_IPK_VERSION should be incremented when the ipk changes.
#
VTE_IPK_VERSION=1

#
# VTE_LOCALES defines which locales get installed
#
VTE_LOCALES=

#
# VTE_CONFFILES should be a list of user-editable files
#VTE_CONFFILES=/opt/etc/vte.conf /opt/etc/init.d/SXXvte

#
# VTE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VTE_PATCHES=$(VTE_SOURCE_DIR)/default-font.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VTE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/freetype2 -I$(STAGING_INCLUDE_DIR)/gtk-2.0 -I$(STAGING_LIB_DIR)/gtk-2.0/include -I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/atk-1.0
VTE_LDFLAGS=

#
# VTE_BUILD_DIR is the directory in which the build is done.
# VTE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VTE_IPK_DIR is the directory in which the ipk is built.
# VTE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VTE_BUILD_DIR=$(BUILD_DIR)/vte
VTE_SOURCE_DIR=$(SOURCE_DIR)/vte
VTE_IPK_DIR=$(BUILD_DIR)/vte-$(VTE_VERSION)-ipk
VTE_IPK=$(BUILD_DIR)/vte_$(VTE_VERSION)-$(VTE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vte-source vte-unpack vte vte-stage vte-ipk vte-clean vte-dirclean vte-check

#
# Automatically create a ipkg control file
#
$(VTE_IPK_DIR)/CONTROL/control:
	@install -d $(VTE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: vte" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VTE_PRIORITY)" >>$@
	@echo "Section: $(VTE_SECTION)" >>$@
	@echo "Version: $(VTE_VERSION)-$(VTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VTE_MAINTAINER)" >>$@
	@echo "Source: $(VTE_SITE)/$(VTE_SOURCE)" >>$@
	@echo "Description: $(VTE_DESCRIPTION)" >>$@
	@echo "Depends: $(VTE_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VTE_SOURCE):
	$(WGET) -P $(DL_DIR) $(VTE_SITE)/$(VTE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vte-source: $(DL_DIR)/$(VTE_SOURCE) $(VTE_PATCHES)

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
$(VTE_BUILD_DIR)/.configured: $(DL_DIR)/$(VTE_SOURCE) \
		$(VTE_PATCHES)
	$(MAKE) gtk-stage sm-stage ncurses-stage termcap-stage
	rm -rf $(BUILD_DIR)/$(VTE_DIR) $(VTE_BUILD_DIR)
	$(VTE_UNZIP) $(DL_DIR)/$(VTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(VTE_DIR) $(VTE_BUILD_DIR)
	if test -n "$(VTE_PATCHES)"; \
		then cat $(VTE_PATCHES) |patch -p0 -d$(VTE_BUILD_DIR); \
	fi
	(cd $(VTE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/opt/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VTE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VTE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--prefix=/opt \
		--disable-gtk-doc \
		--disable-static \
		--disable-glibtest \
	)
	$(PATCH_LIBTOOL) $(VTE_BUILD_DIR)/libtool
	touch $(VTE_BUILD_DIR)/.configured

vte-unpack: $(VTE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(VTE_BUILD_DIR)/.built: $(VTE_BUILD_DIR)/.configured
	rm -f $(VTE_BUILD_DIR)/.built
	$(MAKE) -C $(VTE_BUILD_DIR)
	touch $(VTE_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
vte: $(VTE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VTE_BUILD_DIR)/.staged: $(VTE_BUILD_DIR)/.built
	$(MAKE) -C $(VTE_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	rm -rf $(STAGING_DIR)/opt/lib/libvte.la

vte-stage: $(VTE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(VTE_IPK_DIR)/opt/sbin or $(VTE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VTE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VTE_IPK_DIR)/opt/etc/vte/...
# Documentation files should be installed in $(VTE_IPK_DIR)/opt/doc/vte/...
# Daemon startup scripts should be installed in $(VTE_IPK_DIR)/opt/etc/init.d/S??vte
#
# You may need to patch your application to make it use these locations.
#
$(VTE_IPK): $(VTE_BUILD_DIR)/.built
	rm -rf $(VTE_IPK_DIR) $(BUILD_DIR)/vte_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VTE_BUILD_DIR) DESTDIR=$(VTE_IPK_DIR) install-strip
	rm -f $(VTE_IPK_DIR)/opt/lib/*.la
	rm -rf $(VTE_IPK_DIR)/opt/share/gtk-doc
	install -d $(VTE_IPK_DIR)/opt/etc/init.d
	$(MAKE) $(VTE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VTE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vte-ipk: $(VTE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vte-clean:
	-$(MAKE) -C $(VTE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vte-dirclean:
	rm -rf $(BUILD_DIR)/$(VTE_DIR) $(VTE_BUILD_DIR) $(VTE_IPK_DIR) $(VTE_IPK)

#
# Some sanity check for the package.
#
vte-check: $(VTE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VTE_IPK)
