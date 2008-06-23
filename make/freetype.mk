###########################################################
#
# freetype
#
###########################################################

# You must replace "freetype" and "FREETYPE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FREETYPE_VERSION, FREETYPE_SITE and FREETYPE_SOURCE define
# the upstream location of the source code for the package.
# FREETYPE_DIR is the directory which is created when the source
# archive is unpacked.
# FREETYPE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FREETYPE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/freetype
FREETYPE_VERSION=2.3.6
FREETYPE_SOURCE=freetype-$(FREETYPE_VERSION).tar.bz2
FREETYPE_DIR=freetype-$(FREETYPE_VERSION)
FREETYPE_UNZIP=bzcat
FREETYPE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
FREETYPE_DESCRIPTION=Free truetype library
FREETYPE_SECTION=lib
FREETYPE_PRIORITY=optional
FREETYPE_DEPENDS=zlib

#
# FREETYPE_IPK_VERSION should be incremented when the ipk changes.
#
FREETYPE_IPK_VERSION=1

#
# FREETYPE_CONFFILES should be a list of user-editable files
FREETYPE_CONFFILES=/opt/etc/freetype.conf /opt/etc/init.d/SXXfreetype

#
# FREETYPE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FREETYPE_PATCHES=#$(FREETYPE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FREETYPE_CPPFLAGS=
FREETYPE_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# FREETYPE_BUILD_DIR is the directory in which the build is done.
# FREETYPE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FREETYPE_IPK_DIR is the directory in which the ipk is built.
# FREETYPE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FREETYPE_BUILD_DIR=$(BUILD_DIR)/freetype
FREETYPE_SOURCE_DIR=$(SOURCE_DIR)/freetype
FREETYPE_IPK_DIR=$(BUILD_DIR)/freetype-$(FREETYPE_VERSION)-ipk
FREETYPE_IPK=$(BUILD_DIR)/freetype_$(FREETYPE_VERSION)-$(FREETYPE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(FREETYPE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: freetype" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FREETYPE_PRIORITY)" >>$@
	@echo "Section: $(FREETYPE_SECTION)" >>$@
	@echo "Version: $(FREETYPE_VERSION)-$(FREETYPE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FREETYPE_MAINTAINER)" >>$@
	@echo "Source: $(FREETYPE_SITE)/$(FREETYPE_SOURCE)" >>$@
	@echo "Description: $(FREETYPE_DESCRIPTION)" >>$@
	@echo "Depends: $(FREETYPE_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FREETYPE_SOURCE):
	$(WGET) -P $(@D) $(FREETYPE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
freetype-source: $(DL_DIR)/$(FREETYPE_SOURCE) $(FREETYPE_PATCHES)

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
$(FREETYPE_BUILD_DIR)/.configured: $(DL_DIR)/$(FREETYPE_SOURCE) $(FREETYPE_PATCHES)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(FREETYPE_DIR) $(@D)
	$(FREETYPE_UNZIP) $(DL_DIR)/$(FREETYPE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(FREETYPE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FREETYPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FREETYPE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/builds/unix/libtool
	touch $@

freetype-unpack: $(FREETYPE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FREETYPE_BUILD_DIR)/.built: $(FREETYPE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
freetype: $(FREETYPE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FREETYPE_BUILD_DIR)/.staged: $(FREETYPE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's%includedir=$${*prefix}*/include%includedir=$(STAGING_INCLUDE_DIR)%' $(STAGING_PREFIX)/bin/freetype-config
	install -d $(STAGING_DIR)/bin
	cp $(STAGING_DIR)/opt/bin/freetype-config $(STAGING_DIR)/bin/freetype-config
	rm -f $(STAGING_LIB_DIR)/libfreetype.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/freetype2.pc
	touch $@

freetype-stage: $(FREETYPE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FREETYPE_IPK_DIR)/opt/sbin or $(FREETYPE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FREETYPE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FREETYPE_IPK_DIR)/opt/etc/freetype/...
# Documentation files should be installed in $(FREETYPE_IPK_DIR)/opt/doc/freetype/...
# Daemon startup scripts should be installed in $(FREETYPE_IPK_DIR)/opt/etc/init.d/S??freetype
#
# You may need to patch your application to make it use these locations.
#
$(FREETYPE_IPK): $(FREETYPE_BUILD_DIR)/.built
	rm -rf $(FREETYPE_IPK_DIR) $(BUILD_DIR)/freetype_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FREETYPE_BUILD_DIR) DESTDIR=$(FREETYPE_IPK_DIR) install
	$(STRIP_COMMAND) $(FREETYPE_IPK_DIR)/opt/lib/*.so
	rm -f $(FREETYPE_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(FREETYPE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREETYPE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
freetype-ipk: $(FREETYPE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
freetype-clean:
	-$(MAKE) -C $(FREETYPE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
freetype-dirclean:
	rm -rf $(BUILD_DIR)/$(FREETYPE_DIR) $(FREETYPE_BUILD_DIR) $(FREETYPE_IPK_DIR) $(FREETYPE_IPK)

#
# Some sanity check for the package.
#
freetype-check: $(FREETYPE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FREETYPE_IPK)
