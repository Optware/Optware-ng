###########################################################
#
# xchat
#
###########################################################

#
# XCHAT_VERSION, XCHAT_SITE and XCHAT_SOURCE define
# the upstream location of the source code for the package.
# XCHAT_DIR is the directory which is created when the source
# archive is unpacked.
# XCHAT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
XCHAT_SITE=http://www.xchat.org/files/source/2.8
XCHAT_VERSION=2.8.4
XCHAT_SOURCE=xchat-$(XCHAT_VERSION).tar.bz2
XCHAT_DIR=xchat-$(XCHAT_VERSION)
XCHAT_UNZIP=bzcat
XCHAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XCHAT_DESCRIPTION=Gtk+ based IRC client
XCHAT_SECTION=lib
XCHAT_PRIORITY=optional
XCHAT_DEPENDS=gtk

#
# XCHAT_IPK_VERSION should be incremented when the ipk changes.
#
XCHAT_IPK_VERSION=1

#
# XCHAT_LOCALES defines which locales get installed
#
XCHAT_LOCALES=

#
# XCHAT_CONFFILES should be a list of user-editable files
#XCHAT_CONFFILES=/opt/etc/xchat.conf /opt/etc/init.d/SXXxchat

#
# XCHAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XCHAT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XCHAT_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include -I$(STAGING_INCLUDE_DIR)/freetype2 -I$(STAGING_INCLUDE_DIR)/gtk-2.0 -I$(STAGING_LIB_DIR)/gtk-2.0/include -I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/atk-1.0
XCHAT_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# XCHAT_BUILD_DIR is the directory in which the build is done.
# XCHAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XCHAT_IPK_DIR is the directory in which the ipk is built.
# XCHAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XCHAT_BUILD_DIR=$(BUILD_DIR)/xchat
XCHAT_SOURCE_DIR=$(SOURCE_DIR)/xchat
XCHAT_IPK_DIR=$(BUILD_DIR)/xchat-$(XCHAT_VERSION)-ipk
XCHAT_IPK=$(BUILD_DIR)/xchat_$(XCHAT_VERSION)-$(XCHAT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XCHAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xchat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XCHAT_PRIORITY)" >>$@
	@echo "Section: $(XCHAT_SECTION)" >>$@
	@echo "Version: $(XCHAT_VERSION)-$(XCHAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XCHAT_MAINTAINER)" >>$@
	@echo "Source: $(XCHAT_SITE)/$(XCHAT_SOURCE)" >>$@
	@echo "Description: $(XCHAT_DESCRIPTION)" >>$@
	@echo "Depends: $(XCHAT_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XCHAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(XCHAT_SITE)/$(XCHAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xchat-source: $(DL_DIR)/$(XCHAT_SOURCE) $(XCHAT_PATCHES)

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
$(XCHAT_BUILD_DIR)/.configured: $(DL_DIR)/$(XCHAT_SOURCE) \
		$(XCHAT_PATCHES)
	$(MAKE) gtk-stage
	rm -rf $(BUILD_DIR)/$(XCHAT_DIR) $(XCHAT_BUILD_DIR)
	$(XCHAT_UNZIP) $(DL_DIR)/$(XCHAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(XCHAT_DIR) $(XCHAT_BUILD_DIR)
	#cat $(XCHAT_PATCHES) |patch -p0 -d$(XCHAT_BUILD_DIR)
	(cd $(XCHAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(STAGING_DIR)/opt/bin:$$PATH" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XCHAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XCHAT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		gdkpixbufcsourcepath=/bin/false \
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
		--disable-gtktest \
		--disable-perl \
		--disable-python \
		--disable-tcl \
	)
	$(PATCH_LIBTOOL) $(XCHAT_BUILD_DIR)/libtool
	touch $@

xchat-unpack: $(XCHAT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(XCHAT_BUILD_DIR)/.built: $(XCHAT_BUILD_DIR)/.configured
	rm -f $@
	cp $(XCHAT_SOURCE_DIR)/inline_pngs.h $(XCHAT_BUILD_DIR)/src/pixmaps
	$(MAKE) -C $(XCHAT_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
xchat: $(XCHAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XCHAT_BUILD_DIR)/.staged: $(XCHAT_BUILD_DIR)/.built
	$(MAKE) -C $(XCHAT_BUILD_DIR) install-strip DESTDIR=$(STAGING_DIR)
	rm -rf $(STAGING_DIR)/opt/lib/libxchat.la

xchat-stage: $(XCHAT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XCHAT_IPK_DIR)/opt/sbin or $(XCHAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XCHAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XCHAT_IPK_DIR)/opt/etc/xchat/...
# Documentation files should be installed in $(XCHAT_IPK_DIR)/opt/doc/xchat/...
# Daemon startup scripts should be installed in $(XCHAT_IPK_DIR)/opt/etc/init.d/S??xchat
#
# You may need to patch your application to make it use these locations.
#
$(XCHAT_IPK): $(XCHAT_BUILD_DIR)/.built
	rm -rf $(XCHAT_IPK_DIR) $(BUILD_DIR)/xchat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XCHAT_BUILD_DIR) DESTDIR=$(XCHAT_IPK_DIR) install-strip
	$(MAKE) $(XCHAT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XCHAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xchat-ipk: $(XCHAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xchat-clean:
	-$(MAKE) -C $(XCHAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xchat-dirclean:
	rm -rf $(BUILD_DIR)/$(XCHAT_DIR) $(XCHAT_BUILD_DIR) $(XCHAT_IPK_DIR) $(XCHAT_IPK)

#
# Some sanity check for the package.
#
xchat-check: $(XCHAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(XCHAT_IPK)
