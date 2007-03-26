###########################################################
#
# atk
#
###########################################################

#
# ATK_VERSION, ATK_SITE and ATK_SOURCE define
# the upstream location of the source code for the package.
# ATK_DIR is the directory which is created when the source
# archive is unpacked.
# ATK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
ATK_SITE=ftp://ftp.gtk.org/pub/gtk/v2.6/
ATK_VERSION=1.9.0
ATK_SOURCE=atk-$(ATK_VERSION).tar.bz2
ATK_DIR=atk-$(ATK_VERSION)
ATK_UNZIP=bzcat
ATK_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
ATK_DESCRIPTION=GNOME accessibility toolkit
ATK_SECTION=lib
ATK_PRIORITY=optional
ATK_DEPENDS=glib

#
# ATK_IPK_VERSION should be incremented when the ipk changes.
#
ATK_IPK_VERSION=2

#
# ATK_LOCALES defines which locales get installed
#
ATK_LOCALES=

#
# ATK_CONFFILES should be a list of user-editable files
#ATK_CONFFILES=/opt/etc/atk.conf /opt/etc/init.d/SXXatk

#
# ATK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ATK_PATCHES=$(ATK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ATK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_LIB_DIR)/glib-2.0/include
ATK_LDFLAGS=

#
# ATK_BUILD_DIR is the directory in which the build is done.
# ATK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ATK_IPK_DIR is the directory in which the ipk is built.
# ATK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ATK_BUILD_DIR=$(BUILD_DIR)/atk
ATK_SOURCE_DIR=$(SOURCE_DIR)/atk
ATK_IPK_DIR=$(BUILD_DIR)/atk-$(ATK_VERSION)-ipk
ATK_IPK=$(BUILD_DIR)/atk_$(ATK_VERSION)-$(ATK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(ATK_IPK_DIR)/CONTROL/control:
	@install -d $(ATK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: atk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATK_PRIORITY)" >>$@
	@echo "Section: $(ATK_SECTION)" >>$@
	@echo "Version: $(ATK_VERSION)-$(ATK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATK_MAINTAINER)" >>$@
	@echo "Source: $(ATK_SITE)/$(ATK_SOURCE)" >>$@
	@echo "Description: $(ATK_DESCRIPTION)" >>$@
	@echo "Depends: $(ATK_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ATK_SOURCE):
	$(WGET) -P $(DL_DIR) $(ATK_SITE)/$(ATK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
atk-source: $(DL_DIR)/$(ATK_SOURCE) $(ATK_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(ATK_BUILD_DIR)/.configured: $(DL_DIR)/$(ATK_SOURCE) \
		$(ATK_PATCHES)
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(ATK_DIR) $(ATK_BUILD_DIR)
	$(ATK_UNZIP) $(DL_DIR)/$(ATK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ATK_DIR) $(ATK_BUILD_DIR)
	(cd $(ATK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ATK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ATK_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--disable-glibtest \
	)
	$(PATCH_LIBTOOL) $(ATK_BUILD_DIR)/libtool
	touch $(ATK_BUILD_DIR)/.configured

atk-unpack: $(ATK_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(ATK_BUILD_DIR)/.built: $(ATK_BUILD_DIR)/.configured
	rm -f $(ATK_BUILD_DIR)/.built
	$(MAKE) -C $(ATK_BUILD_DIR)
	touch $(ATK_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
atk: $(ATK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ATK_BUILD_DIR)/.staged: $(ATK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ATK_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/atk.pc
	rm -rf $(STAGING_DIR)/opt/lib/libatk-1.0.la
	touch $@

atk-stage: $(ATK_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ATK_IPK_DIR)/opt/sbin or $(ATK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ATK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ATK_IPK_DIR)/opt/etc/atk/...
# Documentation files should be installed in $(ATK_IPK_DIR)/opt/doc/atk/...
# Daemon startup scripts should be installed in $(ATK_IPK_DIR)/opt/etc/init.d/S??atk
#
# You may need to patch your application to make it use these locations.
#
$(ATK_IPK): $(ATK_BUILD_DIR)/.built
	rm -rf $(ATK_IPK_DIR) $(BUILD_DIR)/atk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ATK_BUILD_DIR) DESTDIR=$(ATK_IPK_DIR) install-strip
	rm -f $(ATK_IPK_DIR)/opt/lib/*.la
	rm -rf $(ATK_IPK_DIR)/opt/share/gtk-doc
	$(MAKE) $(ATK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
atk-ipk: $(ATK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
atk-clean:
	-$(MAKE) -C $(ATK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
atk-dirclean:
	rm -rf $(BUILD_DIR)/$(ATK_DIR) $(ATK_BUILD_DIR) $(ATK_IPK_DIR) $(ATK_IPK)
