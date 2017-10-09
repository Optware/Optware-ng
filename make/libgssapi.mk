###########################################################
#
# libgssapi
#
###########################################################

LIBGSSAPI_SITE=http://www.citi.umich.edu/projects/nfsv4/linux/libgssapi
LIBGSSAPI_VERSION=0.11
LIBGSSAPI_SOURCE=libgssapi-$(LIBGSSAPI_VERSION).tar.gz
LIBGSSAPI_DIR=libgssapi-$(LIBGSSAPI_VERSION)
LIBGSSAPI_UNZIP=zcat
LIBGSSAPI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGSSAPI_DESCRIPTION=libgssapi provides a gssapi interface, but does not implement any gssapi mechanisms itself; instead it calls other gssapi functions (e.g., those provided by MIT Kerberos), depending on the requested mechanism, to do the work.
LIBGSSAPI_SECTION=lib
LIBGSSAPI_PRIORITY=optional
LIBGSSAPI_DEPENDS=

#
# LIBGSSAPI_IPK_VERSION should be incremented when the ipk changes.
#
LIBGSSAPI_IPK_VERSION=2

#
# LIBGSSAPI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBGSSAPI_PATCHES=$(LIBGSSAPI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGSSAPI_CPPFLAGS=
LIBGSSAPI_LDFLAGS=

#
# LIBGSSAPI_BUILD_DIR is the directory in which the build is done.
# LIBGSSAPI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGSSAPI_IPK_DIR is the directory in which the ipk is built.
# LIBGSSAPI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGSSAPI_BUILD_DIR=$(BUILD_DIR)/libgssapi
LIBGSSAPI_SOURCE_DIR=$(SOURCE_DIR)/libgssapi
LIBGSSAPI_IPK_DIR=$(BUILD_DIR)/libgssapi-$(LIBGSSAPI_VERSION)-ipk
LIBGSSAPI_IPK=$(BUILD_DIR)/libgssapi_$(LIBGSSAPI_VERSION)-$(LIBGSSAPI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgssapi-source libgssapi-unpack libgssapi libgssapi-stage libgssapi-ipk libgssapi-clean libgssapi-dirclean libgssapi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGSSAPI_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGSSAPI_SITE)/$(LIBGSSAPI_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBGSSAPI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgssapi-source: $(DL_DIR)/$(LIBGSSAPI_SOURCE) $(LIBGSSAPI_PATCHES)

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
$(LIBGSSAPI_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGSSAPI_SOURCE) $(LIBGSSAPI_PATCHES) make/libgssapi.mk
	rm -rf $(BUILD_DIR)/$(LIBGSSAPI_DIR) $(LIBGSSAPI_BUILD_DIR)
	$(LIBGSSAPI_UNZIP) $(DL_DIR)/$(LIBGSSAPI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBGSSAPI_PATCHES)"; then \
		cat $(LIBGSSAPI_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(LIBGSSAPI_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(LIBGSSAPI_DIR) $(LIBGSSAPI_BUILD_DIR)
	(cd $(LIBGSSAPI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGSSAPI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGSSAPI_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	touch $@

libgssapi-unpack: $(LIBGSSAPI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGSSAPI_BUILD_DIR)/.built: $(LIBGSSAPI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBGSSAPI_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libgssapi: $(LIBGSSAPI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGSSAPI_BUILD_DIR)/.staged: $(LIBGSSAPI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libgssapi-stage: $(LIBGSSAPI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libgssapi
#
$(LIBGSSAPI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libgssapi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGSSAPI_PRIORITY)" >>$@
	@echo "Section: $(LIBGSSAPI_SECTION)" >>$@
	@echo "Version: $(LIBGSSAPI_VERSION)-$(LIBGSSAPI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGSSAPI_MAINTAINER)" >>$@
	@echo "Source: $(LIBGSSAPI_SITE)/$(LIBGSSAPI_SOURCE)" >>$@
	@echo "Description: $(LIBGSSAPI_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGSSAPI_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/etc/libgssapi/...
# Documentation files should be installed in $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/doc/libgssapi/...
# Daemon startup scripts should be installed in $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libgssapi
#
# You may need to patch your application to make it use these locations.
#
$(LIBGSSAPI_IPK): $(LIBGSSAPI_BUILD_DIR)/.built
	rm -rf $(LIBGSSAPI_IPK_DIR) $(BUILD_DIR)/libgssapi_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBGSSAPI_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) -C $(LIBGSSAPI_BUILD_DIR) DESTDIR=$(LIBGSSAPI_IPK_DIR) install-strip
	$(MAKE) $(LIBGSSAPI_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGSSAPI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgssapi-ipk: $(LIBGSSAPI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgssapi-clean:
	rm -f $(LIBGSSAPI_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBGSSAPI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgssapi-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGSSAPI_DIR) $(LIBGSSAPI_BUILD_DIR) $(LIBGSSAPI_IPK_DIR) $(LIBGSSAPI_IPK)

#
# Some sanity check for the package.
#
libgssapi-check: $(LIBGSSAPI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBGSSAPI_IPK)
