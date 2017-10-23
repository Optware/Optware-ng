###########################################################
#
# libtiff
#
###########################################################

# You must replace "libtiff" and "LIBTIFF" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTIFF_VERSION, LIBTIFF_SITE and LIBTIFF_SOURCE define
# the upstream location of the source code for the package.
# LIBTIFF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTIFF_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
# http://www.remotesensing.org/libtiff/
#
LIBTIFF_SITE=http://download.osgeo.org/libtiff
LIBTIFF_VERSION=3.9.7
LIBTIFF_SOURCE=tiff-$(LIBTIFF_VERSION).tar.gz
LIBTIFF_DIR=tiff-$(LIBTIFF_VERSION)
LIBTIFF_UNZIP=zcat
LIBTIFF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTIFF_DESCRIPTION=Tag Image File Format Libraries
LIBTIFF_SECTION=lib
LIBTIFF_PRIORITY=optional
LIBTIFF_DEPENDS=zlib, libstdc++, libjpeg
LIBTIFF_SUGGESTS=
LIBTIFF_CONFLICTS=

#
# LIBTIFF_IPK_VERSION should be incremented when the ipk changes.
#
LIBTIFF_IPK_VERSION=2

#
# LIBTIFF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBTIFF_PATCHES=$(LIBTIFF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq (syno-x07, $(OPTWARE_TARGET))
LIBTIFF_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)
else
LIBTIFF_CPPFLAGS=$(STAGING_CPPFLAGS)
endif
LIBTIFF_LDFLAGS=

#
# LIBTIFF_BUILD_DIR is the directory in which the build is done.
# LIBTIFF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTIFF_IPK_DIR is the directory in which the ipk is built.
# LIBTIFF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTIFF_BUILD_DIR=$(BUILD_DIR)/libtiff
LIBTIFF_SOURCE_DIR=$(SOURCE_DIR)/libtiff
LIBTIFF_IPK_DIR=$(BUILD_DIR)/libtiff-$(LIBTIFF_VERSION)-ipk
LIBTIFF_IPK=$(BUILD_DIR)/libtiff_$(LIBTIFF_VERSION)-$(LIBTIFF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTIFF_SOURCE):
	$(WGET) -P $(@D) $(LIBTIFF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(LIBTIFF_SITE)/old/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#libtiff-source: $(DL_DIR)/$(LIBTIFF_SOURCE) $(LIBTIFF_PATCHES)

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
$(LIBTIFF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTIFF_SOURCE) $(LIBTIFF_PATCHES) make/libtiff.mk
	$(MAKE) zlib-stage libjpeg-stage
	rm -rf $(BUILD_DIR)/$(LIBTIFF_DIR) $(@D)
	$(LIBTIFF_UNZIP) $(DL_DIR)/$(LIBTIFF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBTIFF_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(LIBTIFF_DIR) -p1
	mv $(BUILD_DIR)/$(LIBTIFF_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(LIBTIFF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTIFF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
ifeq (syno-x07, $(OPTWARE_TARGET))
	sed -i -e 's| -O2||' $(@D)/libtiff/Makefile $(@D)/tools/Makefile
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtiff-unpack: $(LIBTIFF_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBTIFF_BUILD_DIR)/.built: $(LIBTIFF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libtiff: $(LIBTIFF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTIFF_BUILD_DIR)/.staged: $(LIBTIFF_BUILD_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiff.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffio.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffconf.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffvers.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/.libs/libtiff.so.$(LIBTIFF_VERSION) $(STAGING_LIB_DIR)
	rm -f $(STAGING_LIB_DIR)/libtiff*.la
	cd $(STAGING_LIB_DIR) && ln -fs libtiff.so.$(LIBTIFF_VERSION) libtiff.so.3
	cd $(STAGING_LIB_DIR) && ln -fs libtiff.so.$(LIBTIFF_VERSION) libtiff.so
	touch -f $@

libtiff-stage: $(LIBTIFF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtiff
#
$(LIBTIFF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libtiff" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTIFF_PRIORITY)" >>$@
	@echo "Section: $(LIBTIFF_SECTION)" >>$@
	@echo "Version: $(LIBTIFF_VERSION)-$(LIBTIFF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTIFF_MAINTAINER)" >>$@
	@echo "Source: $(LIBTIFF_SITE)/$(LIBTIFF_SOURCE)" >>$@
	@echo "Description: $(LIBTIFF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTIFF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTIFF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTIFF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/etc/libtiff/...
# Documentation files should be installed in $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/doc/libtiff/...
# Daemon startup scripts should be installed in $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libtiff
#
# You may need to patch your application to make it use these locations.
#
$(LIBTIFF_IPK): $(LIBTIFF_BUILD_DIR)/.built
	rm -rf $(LIBTIFF_IPK_DIR) $(BUILD_DIR)/libtiff_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) -C $(LIBTIFF_BUILD_DIR) DESTDIR=$(LIBTIFF_IPK_DIR) install-exec transform=''
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/bin/*

	$(INSTALL) -d $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiff.h $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffio.h $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffconf.h $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/include
	$(INSTALL) -m 644 $(LIBTIFF_BUILD_DIR)/libtiff/tiffvers.h $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/include

	rm -f $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/lib/lib*.a
	rm -f $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/lib/lib*.la
	$(STRIP_COMMAND) $(LIBTIFF_IPK_DIR)$(TARGET_PREFIX)/lib/lib*.so
	$(MAKE) $(LIBTIFF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTIFF_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBTIFF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtiff-ipk: $(LIBTIFF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtiff-clean:
	-$(MAKE) -C $(LIBTIFF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtiff-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTIFF_DIR) $(LIBTIFF_BUILD_DIR) $(LIBTIFF_IPK_DIR) $(LIBTIFF_IPK)

#
# Some sanity check for the package.
#
libtiff-check: $(LIBTIFF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
