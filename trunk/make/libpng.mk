###########################################################
#
# libpng
#
###########################################################

# You must replace "libpng" and "LIBPNG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPNG_VERSION, LIBPNG_SITE and LIBPNG_SOURCE define
# the upstream location of the source code for the package.
# LIBPNG_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPNG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBPNG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libpng
LIBPNG_VERSION=1.2.30
LIBPNG_SOURCE=libpng-$(LIBPNG_VERSION).tar.gz
LIBPNG_DIR=libpng-$(LIBPNG_VERSION)
LIBPNG_UNZIP=zcat
LIBPNG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPNG_DESCRIPTION=Portable Network Graphics Libraries
LIBPNG_SECTION=lib
LIBPNG_PRIORITY=optional
LIBPNG_DEPENDS=zlib
LIBPNG_CONFLICTS=

#
# LIBPNG_IPK_VERSION should be incremented when the ipk changes.
#
LIBPNG_IPK_VERSION=1

#
# LIBPNG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBPNG_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPNG_CPPFLAGS=
LIBPNG_LDFLAGS=

#
# LIBPNG_BUILD_DIR is the directory in which the build is done.
# LIBPNG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPNG_IPK_DIR is the directory in which the ipk is built.
# LIBPNG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPNG_BUILD_DIR=$(BUILD_DIR)/libpng
LIBPNG_SOURCE_DIR=$(SOURCE_DIR)/libpng
LIBPNG_IPK_DIR=$(BUILD_DIR)/libpng-$(LIBPNG_VERSION)-ipk
LIBPNG_IPK=$(BUILD_DIR)/libpng_$(LIBPNG_VERSION)-$(LIBPNG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpng-source libpng-unpack libpng libpng-stage libpng-ipk libpng-clean libpng-dirclean libpng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPNG_SOURCE):
	$(WGET) -P $(@D) $(LIBPNG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpng-source: $(DL_DIR)/$(LIBPNG_SOURCE) $(LIBPNG_PATCHES)

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
$(LIBPNG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPNG_SOURCE) $(LIBPNG_PATCHES) make/libpng.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBPNG_DIR) $(@D)
	$(LIBPNG_UNZIP) $(DL_DIR)/$(LIBPNG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBPNG_PATCHES)"; \
		then cat $(LIBPNG_PATCHES) | patch -d $(BUILD_DIR)/$(LIBPNG_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(LIBPNG_DIR) $(@D)
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPNG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPNG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libpng-unpack: $(LIBPNG_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBPNG_BUILD_DIR)/.built: $(LIBPNG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libpng: $(LIBPNG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPNG_BUILD_DIR)/.staged: $(LIBPNG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) prefix=$(STAGING_PREFIX) install
	rm -f $(STAGING_DIR)/opt/lib/libpng.la
	rm -f $(STAGING_DIR)/opt/lib/libpng12.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libpng*.pc
	sed -ie 's|-I$${includedir}|-I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/libpng12-config
	touch $@

libpng-stage: $(LIBPNG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpng
#
$(LIBPNG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libpng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPNG_PRIORITY)" >>$@
	@echo "Section: $(LIBPNG_SECTION)" >>$@
	@echo "Version: $(LIBPNG_VERSION)-$(LIBPNG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPNG_MAINTAINER)" >>$@
	@echo "Source: $(LIBPNG_SITE)/$(LIBPNG_SOURCE)" >>$@
	@echo "Description: $(LIBPNG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPNG_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBPNG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPNG_IPK_DIR)/opt/sbin or $(LIBPNG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPNG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBPNG_IPK_DIR)/opt/etc/libpng/...
# Documentation files should be installed in $(LIBPNG_IPK_DIR)/opt/doc/libpng/...
# Daemon startup scripts should be installed in $(LIBPNG_IPK_DIR)/opt/etc/init.d/S??libpng
#
# You may need to patch your application to make it use these locations.
#
$(LIBPNG_IPK): $(LIBPNG_BUILD_DIR)/.built
	rm -rf $(LIBPNG_IPK_DIR) $(LIBPNG_IPK)
	install -d $(LIBPNG_IPK_DIR)/opt
	$(MAKE) -C $(LIBPNG_BUILD_DIR) prefix=$(LIBPNG_IPK_DIR)/opt install-strip
	rm -f $(LIBPNG_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(LIBPNG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPNG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpng-ipk: $(LIBPNG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpng-clean:
	-$(MAKE) -C $(LIBPNG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpng-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPNG_DIR) $(LIBPNG_BUILD_DIR) $(LIBPNG_IPK_DIR) $(LIBPNG_IPK)

#
# Some sanity check for the package.
#
libpng-check: $(LIBPNG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBPNG_IPK)
