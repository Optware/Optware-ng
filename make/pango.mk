###########################################################
#
# pango
#
###########################################################

#
# PANGO_VERSION, PANGO_SITE and PANGO_SOURCE define
# the upstream location of the source code for the package.
# PANGO_DIR is the directory which is created when the source
# archive is unpacked.
# PANGO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PANGO_SITE=http://ftp.gnome.org/pub/gnome/sources/pango/1.36
PANGO_VERSION=1.36.8
PANGO_SOURCE=pango-$(PANGO_VERSION).tar.xz
PANGO_DIR=pango-$(PANGO_VERSION)
PANGO_UNZIP=xzcat
PANGO_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PANGO_DESCRIPTION=GNOME font abstraction library
PANGO_SECTION=lib
PANGO_PRIORITY=optional
PANGO_DEPENDS=glib, xft, freetype, fontconfig, ice, cairo, harfbuzz

#
# PANGO_IPK_VERSION should be incremented when the ipk changes.
#
PANGO_IPK_VERSION=3

#
# PANGO_LOCALES defines which locales get installed
#
PANGO_LOCALES=

#
# PANGO_CONFFILES should be a list of user-editable files
#PANGO_CONFFILES=$(TARGET_PREFIX)/etc/pango.conf $(TARGET_PREFIX)/etc/init.d/SXXpango

#
# PANGO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PANGO_PATCHES=$(PANGO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PANGO_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/freetype2 -I$(STAGING_INCLUDE_DIR)/harfbuzz
PANGO_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# PANGO_BUILD_DIR is the directory in which the build is done.
# PANGO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PANGO_IPK_DIR is the directory in which the ipk is built.
# PANGO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PANGO_BUILD_DIR=$(BUILD_DIR)/pango
PANGO_SOURCE_DIR=$(SOURCE_DIR)/pango
PANGO_IPK_DIR=$(BUILD_DIR)/pango-$(PANGO_VERSION)-ipk
PANGO_IPK=$(BUILD_DIR)/pango_$(PANGO_VERSION)-$(PANGO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PANGO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: pango" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PANGO_PRIORITY)" >>$@
	@echo "Section: $(PANGO_SECTION)" >>$@
	@echo "Version: $(PANGO_VERSION)-$(PANGO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PANGO_MAINTAINER)" >>$@
	@echo "Source: $(PANGO_SITE)/$(PANGO_SOURCE)" >>$@
	@echo "Description: $(PANGO_DESCRIPTION)" >>$@
	@echo "Depends: $(PANGO_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PANGO_SOURCE):
	$(WGET) -P $(DL_DIR) $(PANGO_SITE)/$(PANGO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pango-source: $(DL_DIR)/$(PANGO_SOURCE) $(PANGO_PATCHES)

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
$(PANGO_BUILD_DIR)/.configured: $(DL_DIR)/$(PANGO_SOURCE) $(PANGO_PATCHES) make/pango.mk
	$(MAKE) glib-stage
	$(MAKE) xft-stage
	$(MAKE) ice-stage
	$(MAKE) cairo-stage
	$(MAKE) harfbuzz-stage
	rm -rf $(BUILD_DIR)/$(PANGO_DIR) $(PANGO_BUILD_DIR)
	$(PANGO_UNZIP) $(DL_DIR)/$(PANGO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PANGO_DIR) $(@D)
	sed -i -e '/cd .* glib-mkenums/s|glib-mkenums |$(STAGING_PREFIX)/bin/& |' $(@D)/pango/Makefile.in
	sed -i -e 's/have_freetype=false/have_freetype=true/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PANGO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PANGO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		FONTCONFIG_CFLAGS="-I$(STAGING_INCLUDE_DIR)" \
		FONTCONFIG_LIBS="-L$(STAGING_LIB_DIR) -lfontconfig" \
		FREETYPE_CFLAGS="-I$(STAGING_INCLUDE_DIR) -I$(STAGING_INCLUDE_DIR)/freetype2" \
		FREETYPE_LIBS="-L$(STAGING_LIB_DIR) -lfreetype -lz" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--disable-glibtest \
		--disable-introspection \
		--with-cairo \
	)
	$(PATCH_LIBTOOL) $(PANGO_BUILD_DIR)/libtool
	touch $@

pango-unpack: $(PANGO_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PANGO_BUILD_DIR)/.built: $(PANGO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PANGO_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
pango: $(PANGO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PANGO_BUILD_DIR)/.staged: $(PANGO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PANGO_BUILD_DIR) install-strip prefix=$(STAGING_PREFIX)
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/pango*.pc
	rm -f $(STAGING_LIB_DIR)/libpango-1.0.la
	rm -f $(STAGING_LIB_DIR)/libpangox-1.0.la
	rm -f $(STAGING_LIB_DIR)/libpangoxft-1.0.la
	rm -f $(STAGING_LIB_DIR)/libpangoft2-1.0.la
	rm -f $(STAGING_LIB_DIR)/libpangocairo-1.0.la
	touch $@

pango-stage: $(PANGO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PANGO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PANGO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PANGO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PANGO_IPK_DIR)$(TARGET_PREFIX)/etc/pango/...
# Documentation files should be installed in $(PANGO_IPK_DIR)$(TARGET_PREFIX)/doc/pango/...
# Daemon startup scripts should be installed in $(PANGO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??pango
#
# You may need to patch your application to make it use these locations.
#
$(PANGO_IPK): $(PANGO_BUILD_DIR)/.built
	rm -rf $(PANGO_IPK_DIR) $(BUILD_DIR)/pango_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PANGO_BUILD_DIR) DESTDIR=$(PANGO_IPK_DIR) install-strip
	find $(PANGO_IPK_DIR) -type f -name '*.la' -exec rm -f {} \;
	rm -rf $(PANGO_IPK_DIR)$(TARGET_PREFIX)/share/gtk-doc
	$(MAKE) $(PANGO_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(PANGO_SOURCE_DIR)/postinst $(PANGO_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PANGO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pango-ipk: $(PANGO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pango-clean:
	-$(MAKE) -C $(PANGO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pango-dirclean:
	rm -rf $(BUILD_DIR)/$(PANGO_DIR) $(PANGO_BUILD_DIR) $(PANGO_IPK_DIR) $(PANGO_IPK)
