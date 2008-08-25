###########################################################
#
# neon
#
###########################################################

# You must replace "neon" and "NEON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NEON_VERSION, NEON_SITE and NEON_SOURCE define
# the upstream location of the source code for the package.
# NEON_DIR is the directory which is created when the source
# archive is unpacked.
# NEON_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
NEON_SITE=http://www.webdav.org/neon
NEON_VERSION=0.28.3
NEON_SOURCE=neon-$(NEON_VERSION).tar.gz
NEON_DIR=neon-$(NEON_VERSION)
NEON_UNZIP=zcat
NEON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NEON_DESCRIPTION=an HTTP and WebDAV client library, with a C interface
NEON_SECTION=net
NEON_PRIORITY=optional
NEON_DEPENDS=openssl, zlib, libxml2
NEON_SUGGESTS=
NEON_CONFLICTS=

#
# NEON_IPK_VERSION should be incremented when the ipk changes.
#
NEON_IPK_VERSION=1

#
# NEON_CONFFILES should be a list of user-editable files
NEON_CONFFILES=

#
# NEON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NEON_PATCHES=$(NEON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NEON_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2
NEON_LDFLAGS=

#
# NEON_BUILD_DIR is the directory in which the build is done.
# NEON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NEON_IPK_DIR is the directory in which the ipk is built.
# NEON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NEON_BUILD_DIR=$(BUILD_DIR)/neon
NEON_SOURCE_DIR=$(SOURCE_DIR)/neon
NEON_IPK_DIR=$(BUILD_DIR)/neon-$(NEON_VERSION)-ipk
NEON_IPK=$(BUILD_DIR)/neon_$(NEON_VERSION)-$(NEON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NEON_SOURCE):
	$(WGET) -P $(@D) $(NEON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
neon-source: $(DL_DIR)/$(NEON_SOURCE) $(NEON_PATCHES)

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
$(NEON_BUILD_DIR)/.configured: $(DL_DIR)/$(NEON_SOURCE) $(NEON_PATCHES) make/neon.mk
	$(MAKE) openssl-stage
	$(MAKE) zlib-stage
	$(MAKE) expat-stage
	$(MAKE) libxml2-stage
	rm -rf $(BUILD_DIR)/$(NEON_DIR) $(@D)
	$(NEON_UNZIP) $(DL_DIR)/$(NEON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(NEON_PATCHES) | patch -d $(BUILD_DIR)/$(NEON_DIR) -p1
	mv $(BUILD_DIR)/$(NEON_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NEON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NEON_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		XML2_CONFIG=$(STAGING_DIR)/opt/bin/xml2-config \
		ac_cv_path_KRB5_CONFIG=none \
		ne_cv_gai_addrconfig=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-shared \
		--with-ssl \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

neon-unpack: $(NEON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NEON_BUILD_DIR)/.built: $(NEON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
neon: $(NEON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NEON_BUILD_DIR)/.staged: $(NEON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NEON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -e "s:echo \$${libdir}/libneon.la:echo $(STAGING_DIR)/\$${libdir}/libneon.la:" <$(NEON_BUILD_DIR)/neon-config >$(STAGING_DIR)/opt/bin/neon-config
	sed -i -e '/echo/s|-I$${includedir}/neon|-I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/neon-config
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/neon.pc
	touch $@

neon-stage: $(NEON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/neon
#
$(NEON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: neon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NEON_PRIORITY)" >>$@
	@echo "Section: $(NEON_SECTION)" >>$@
	@echo "Version: $(NEON_VERSION)-$(NEON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NEON_MAINTAINER)" >>$@
	@echo "Source: $(NEON_SITE)/$(NEON_SOURCE)" >>$@
	@echo "Description: $(NEON_DESCRIPTION)" >>$@
	@echo "Depends: $(NEON_DEPENDS)" >>$@
	@echo "Suggests: $(NEON_SUGGESTS)" >>$@
	@echo "Conflicts: $(NEON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NEON_IPK_DIR)/opt/sbin or $(NEON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NEON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NEON_IPK_DIR)/opt/etc/neon/...
# Documentation files should be installed in $(NEON_IPK_DIR)/opt/doc/neon/...
# Daemon startup scripts should be installed in $(NEON_IPK_DIR)/opt/etc/init.d/S??neon
#
# You may need to patch your application to make it use these locations.
#
$(NEON_IPK): $(NEON_BUILD_DIR)/.built
	rm -rf $(NEON_IPK_DIR) $(BUILD_DIR)/neon_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NEON_BUILD_DIR) DESTDIR=$(NEON_IPK_DIR) install
	rm -f $(NEON_IPK_DIR)/opt/lib/libneon.la
	$(TARGET_STRIP) $(NEON_IPK_DIR)/opt/lib/libneon.so
	$(MAKE) $(NEON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NEON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
neon-ipk: $(NEON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
neon-clean:
	-$(MAKE) -C $(NEON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
neon-dirclean:
	rm -rf $(BUILD_DIR)/$(NEON_DIR) $(NEON_BUILD_DIR) $(NEON_IPK_DIR) $(NEON_IPK)

#
# Some sanity check for the package.
#
neon-check: $(NEON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NEON_IPK)
