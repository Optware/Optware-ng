###########################################################
#
# libcapi20
#
###########################################################

# You must replace "libcapi20" and "LIBCAPI20" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBCAPI20_VERSION, LIBCAPI20_SITE and LIBCAPI20_SOURCE define
# the upstream location of the source code for the package.
# LIBCAPI20_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCAPI20_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBCAPI20_SITE=ftp://ftp.melware.net/capi-utils
LIBCAPI20_VERSION=3-cm
LIBCAPI20_SOURCE=libcapi20-$(LIBCAPI20_VERSION).tar.gz
LIBCAPI20_DIR=libcapi20-$(LIBCAPI20_VERSION)
LIBCAPI20_UNZIP=zcat
LIBCAPI20_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCAPI20_DESCRIPTION=This Library supports remote capi over an TCP/IP network.
LIBCAPI20_SECTION=lib
LIBCAPI20_PRIORITY=optional
LIBCAPI20_DEPENDS=
LIBCAPI20_CONFLICTS=

#
# LIBCAPI20_IPK_VERSION should be incremented when the ipk changes.
#
LIBCAPI20_IPK_VERSION=1

#
# LIBCAPI20_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBCAPI20_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCAPI20_CPPFLAGS=
LIBCAPI20_LDFLAGS=

#
# LIBCAPI20_BUILD_DIR is the directory in which the build is done.
# LIBCAPI20_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCAPI20_IPK_DIR is the directory in which the ipk is built.
# LIBCAPI20_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCAPI20_BUILD_DIR=$(BUILD_DIR)/libcapi20
LIBCAPI20_SOURCE_DIR=$(SOURCE_DIR)/libcapi20
LIBCAPI20_IPK_DIR=$(BUILD_DIR)/libcapi20-$(LIBCAPI20_VERSION)-ipk
LIBCAPI20_IPK=$(BUILD_DIR)/libcapi20_$(LIBCAPI20_VERSION)-$(LIBCAPI20_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libcapi20-source libcapi20-unpack libcapi20 libcapi20-stage libcapi20-ipk libcapi20-clean libcapi20-dirclean libcapi20-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCAPI20_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBCAPI20_SITE)/$(LIBCAPI20_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcapi20-source: $(DL_DIR)/$(LIBCAPI20_SOURCE) $(LIBCAPI20_PATCHES)

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
$(LIBCAPI20_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCAPI20_SOURCE) $(LIBCAPI20_PATCHES)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBCAPI20_DIR) $(LIBCAPI20_BUILD_DIR)
	$(LIBCAPI20_UNZIP) $(DL_DIR)/$(LIBCAPI20_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBCAPI20_PATCHES)"; \
		then cat $(LIBCAPI20_PATCHES) | patch -d $(BUILD_DIR)/$(LIBCAPI20_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(LIBCAPI20_DIR) $(LIBCAPI20_BUILD_DIR)
#	cd $(LIBCAPI20_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif ;
	(cd $(LIBCAPI20_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCAPI20_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCAPI20_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBCAPI20_BUILD_DIR)/libtool
	touch $@

libcapi20-unpack: $(LIBCAPI20_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBCAPI20_BUILD_DIR)/.built: $(LIBCAPI20_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBCAPI20_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libcapi20: $(LIBCAPI20_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCAPI20_BUILD_DIR)/.staged: $(LIBCAPI20_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBCAPI20_BUILD_DIR) prefix=$(STAGING_PREFIX) install
	rm -f $(STAGING_DIR)/opt/lib/libcapi20.la
	rm -f $(STAGING_DIR)/opt/lib/libcapi2012.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libcapi20*.pc
	sed -ie 's|-I$${includedir}|-I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/libcapi2012-config
	touch $@

libcapi20-stage: $(LIBCAPI20_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libcapi20
#
$(LIBCAPI20_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libcapi20" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCAPI20_PRIORITY)" >>$@
	@echo "Section: $(LIBCAPI20_SECTION)" >>$@
	@echo "Version: $(LIBCAPI20_VERSION)-$(LIBCAPI20_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCAPI20_MAINTAINER)" >>$@
	@echo "Source: $(LIBCAPI20_SITE)/$(LIBCAPI20_SOURCE)" >>$@
	@echo "Description: $(LIBCAPI20_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCAPI20_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBCAPI20_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCAPI20_IPK_DIR)/opt/sbin or $(LIBCAPI20_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCAPI20_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBCAPI20_IPK_DIR)/opt/etc/libcapi20/...
# Documentation files should be installed in $(LIBCAPI20_IPK_DIR)/opt/doc/libcapi20/...
# Daemon startup scripts should be installed in $(LIBCAPI20_IPK_DIR)/opt/etc/init.d/S??libcapi20
#
# You may need to patch your application to make it use these locations.
#
$(LIBCAPI20_IPK): $(LIBCAPI20_BUILD_DIR)/.built
	rm -rf $(LIBCAPI20_IPK_DIR) $(LIBCAPI20_IPK)
	install -d $(LIBCAPI20_IPK_DIR)/opt
	$(MAKE) -C $(LIBCAPI20_BUILD_DIR) prefix=$(LIBCAPI20_IPK_DIR)/opt install-strip
	rm -f $(LIBCAPI20_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(LIBCAPI20_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCAPI20_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcapi20-ipk: $(LIBCAPI20_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcapi20-clean:
	-$(MAKE) -C $(LIBCAPI20_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcapi20-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCAPI20_DIR) $(LIBCAPI20_BUILD_DIR) $(LIBCAPI20_IPK_DIR) $(LIBCAPI20_IPK)

#
# Some sanity check for the package.
#
libcapi20-check: $(LIBCAPI20_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBCAPI20_IPK)
