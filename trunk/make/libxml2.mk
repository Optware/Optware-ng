###########################################################
#
# libxml2
#
###########################################################

#
# LIBXML2_VERSION, LIBXML2_SITE and LIBXML2_SOURCE define
# the upstream location of the source code for the package.
# LIBXML2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXML2_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#

LIBXML2_SITE=ftp://xmlsoft.org/libxml2
LIBXML2_VERSION=2.6.30
LIBXML2_SOURCE=libxml2-$(LIBXML2_VERSION).tar.gz
LIBXML2_DIR=libxml2-$(LIBXML2_VERSION)
LIBXML2_UNZIP=zcat
LIBXML2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBXML2_DESCRIPTION=Libxml2 is the XML C parser and toolkit developed for the Gnome project.
LIBXML2_SECTION=libs
LIBXML2_PRIORITY=optional
LIBXML2_DEPENDS=zlib

#
# LIBXML2_IPK_VERSION should be incremented when the ipk changes.
#
LIBXML2_IPK_VERSION=1

#
# LIBXML2_CONFFILES should be a list of user-editable files
#LIBXML2_CONFFILES=/opt/etc/libxml2.conf /opt/etc/init.d/SXXlibxml2

#
# LIBXML2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBXML2_PATCHES=$(LIBXML2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXML2_CPPFLAGS=
LIBXML2_LDFLAGS=

#
# LIBXML2_BUILD_DIR is the directory in which the build is done.
# LIBXML2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXML2_IPK_DIR is the directory in which the ipk is built.
# LIBXML2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXML2_BUILD_DIR=$(BUILD_DIR)/libxml2
LIBXML2_SOURCE_DIR=$(SOURCE_DIR)/libxml2
LIBXML2_IPK_DIR=$(BUILD_DIR)/libxml2-$(LIBXML2_VERSION)-ipk
LIBXML2_IPK=$(BUILD_DIR)/libxml2_$(LIBXML2_VERSION)-$(LIBXML2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libxml2-source libxml2-unpack libxml2 libxml2-stage libxml2-ipk libxml2-clean libxml2-dirclean libxml2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBXML2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBXML2_SITE)/$(LIBXML2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxml2-source: $(DL_DIR)/$(LIBXML2_SOURCE) $(LIBXML2_PATCHES)

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
$(LIBXML2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXML2_SOURCE) $(LIBXML2_PATCHES) make/libxml.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBXML2_DIR) $(LIBXML2_BUILD_DIR)
	$(LIBXML2_UNZIP) $(DL_DIR)/$(LIBXML2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(LIBXML2_PATCHES) | patch -d $(BUILD_DIR)/$(LIBXML2_DIR) -p1
	mv $(BUILD_DIR)/$(LIBXML2_DIR) $(LIBXML2_BUILD_DIR)
	(cd $(LIBXML2_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXML2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXML2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-shared \
		--without-python \
	)
	touch $@

libxml2-unpack: $(LIBXML2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXML2_BUILD_DIR)/.built: $(LIBXML2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBXML2_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libxml2: $(LIBXML2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXML2_BUILD_DIR)/.staged: $(LIBXML2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBXML2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's%includedir=$${*prefix}*/include%includedir=$(STAGING_INCLUDE_DIR)%' \
		$(STAGING_PREFIX)/bin/xml2-config
	rm $(STAGING_LIB_DIR)/libxml2.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libxml*.pc
	touch $@

libxml2-stage: $(LIBXML2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libxml2
#
$(LIBXML2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libxml2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXML2_PRIORITY)" >>$@
	@echo "Section: $(LIBXML2_SECTION)" >>$@
	@echo "Version: $(LIBXML2_VERSION)-$(LIBXML2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXML2_MAINTAINER)" >>$@
	@echo "Source: $(LIBXML2_SITE)/$(LIBXML2_SOURCE)" >>$@
	@echo "Description: $(LIBXML2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXML2_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXML2_IPK_DIR)/opt/sbin or $(LIBXML2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXML2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBXML2_IPK_DIR)/opt/etc/libxml2/...
# Documentation files should be installed in $(LIBXML2_IPK_DIR)/opt/doc/libxml2/...
# Daemon startup scripts should be installed in $(LIBXML2_IPK_DIR)/opt/etc/init.d/S??libxml2
#
# You may need to patch your application to make it use these locations.
#
$(LIBXML2_IPK): $(LIBXML2_BUILD_DIR)/.built
	rm -rf $(LIBXML2_IPK_DIR) $(BUILD_DIR)/libxml2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBXML2_BUILD_DIR) DESTDIR=$(LIBXML2_IPK_DIR) install-strip
	rm -f $(LIBXML2_IPK_DIR)/opt/lib/libxml2.la
	rm -rf $(LIBXML2_IPK_DIR)/opt/share/doc
	$(MAKE) $(LIBXML2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXML2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libxml2-ipk: $(LIBXML2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libxml2-clean:
	-$(MAKE) -C $(LIBXML2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxml2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXML2_DIR) $(LIBXML2_BUILD_DIR) $(LIBXML2_IPK_DIR) $(LIBXML2_IPK)

#
# Some sanity check for the package.
#
libxml2-check: $(LIBXML2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBXML2_IPK)
