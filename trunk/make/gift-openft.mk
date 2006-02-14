###########################################################
#
# gift-openft
#
###########################################################

# You must replace "gift-openft" and "GIFTOPENFT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.
#
# GIFTOPENFT_VERSION, GIFTOPENFT_SITE and GIFTOPENFT_SOURCE define
# the upstream location of the source code for the package.
# GIFTOPENFT_DIR is the directory which is created when the source
# archive is unpacked.
# GIFTOPENFT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFTOPENFT_SITE=http://dl.sourceforge.net/gift
GIFTOPENFT_VERSION=0.2.1.6
GIFTOPENFT_SOURCE=gift-openft-$(GIFTOPENFT_VERSION).tar.bz2
GIFTOPENFT_DIR=gift-openft-$(GIFTOPENFT_VERSION)
GIFTOPENFT_UNZIP=bzcat
GIFTOPENFT_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFTOPENFT_SECTION=net
GIFTOPENFT_PRIORITY=optional
GIFTOPENFT_DEPENDS=gift, zlib
GIFTOPENFT_DESCRIPTION=gIFt openft plugin

#
# GIFTOPENFT_IPK_VERSION should be incremented when the ipk changes.
#
GIFTOPENFT_IPK_VERSION=1

#
# GIFTOPENFT_CONFFILES should be a list of user-editable files
GIFTOPENFT_CONFFILES=/opt/etc/gift-openft.conf /opt/etc/init.d/SXXgift-openft

#
# GIFTOPENFT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFTOPENFT_PATCHES=$(GIFTOPENFT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFTOPENFT_CPPFLAGS=
GIFTOPENFT_LDFLAGS=

#
# GIFTOPENFT_BUILD_DIR is the directory in which the build is done.
# GIFTOPENFT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFTOPENFT_IPK_DIR is the directory in which the ipk is built.
# GIFTOPENFT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFTOPENFT_BUILD_DIR=$(BUILD_DIR)/gift-openft
GIFTOPENFT_SOURCE_DIR=$(SOURCE_DIR)/gift-openft
GIFTOPENFT_IPK_DIR=$(BUILD_DIR)/gift-openft-$(GIFTOPENFT_VERSION)-ipk
GIFTOPENFT_IPK=$(BUILD_DIR)/gift-openft_$(GIFTOPENFT_VERSION)-$(GIFTOPENFT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFTOPENFT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIFTOPENFT_SITE)/$(GIFTOPENFT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-openft-source: $(DL_DIR)/$(GIFTOPENFT_SOURCE) $(GIFTOPENFT_PATCHES)

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
$(GIFTOPENFT_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFTOPENFT_SOURCE) $(GIFTOPENFT_PATCHES)
	$(MAKE) gift-stage
	rm -rf $(BUILD_DIR)/$(GIFTOPENFT_DIR) $(GIFTOPENFT_BUILD_DIR)
	$(GIFTOPENFT_UNZIP) $(DL_DIR)/$(GIFTOPENFT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFTOPENFT_PATCHES) | patch -d $(BUILD_DIR)/$(GIFTOPENFT_DIR) -p1
	mv $(BUILD_DIR)/$(GIFTOPENFT_DIR) $(GIFTOPENFT_BUILD_DIR)
	(cd $(GIFTOPENFT_BUILD_DIR);  \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFTOPENFT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFTOPENFT_LDFLAGS)" \
		./configure \
		--with-zlib=$(STAGING_DIR)/opt \
		--disable-libdb \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFTOPENFT_BUILD_DIR)/.configured

gift-openft-unpack: $(GIFTOPENFT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GIFTOPENFT_BUILD_DIR)/.built: $(GIFTOPENFT_BUILD_DIR)/.configured
	rm -f $(GIFTOPENFT_BUILD_DIR)/.built
	$(MAKE) -C $(GIFTOPENFT_BUILD_DIR)
	touch $(GIFTOPENFT_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gift-openft: $(GIFTOPENFT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgift-openft.so.$(GIFTOPENFT_VERSION): $(GIFTOPENFT_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/gift-openft.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/libgift-openft.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/libgift-openft.so.$(GIFTOPENFT_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-openft.so.$(GIFTOPENFT_VERSION) libgift-openft.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-openft.so.$(GIFTOPENFT_VERSION) libgift-openft.so

gift-openft-stage: $(STAGING_DIR)/opt/lib/libgift-openft.so.$(GIFTOPENFT_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift-openft
#
$(GIFTOPENFT_IPK_DIR)/CONTROL/control:
	@install -d $(GIFTOPENFT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gift-openft" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFTOPENFT_PRIORITY)" >>$@
	@echo "Section: $(GIFTOPENFT_SECTION)" >>$@
	@echo "Version: $(GIFTOPENFT_VERSION)-$(GIFTOPENFT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFTOPENFT_MAINTAINER)" >>$@
	@echo "Source: $(GIFTOPENFT_SITE)/$(GIFTOPENFT_SOURCE)" >>$@
	@echo "Description: $(GIFTOPENFT_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFTOPENFT_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFTOPENFT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFTOPENFT_IPK_DIR)/opt/sbin or $(GIFTOPENFT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFTOPENFT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFTOPENFT_IPK_DIR)/opt/etc/gift-openft/...
# Documentation files should be installed in $(GIFTOPENFT_IPK_DIR)/opt/doc/gift-openft/...
# Daemon startup scripts should be installed in $(GIFTOPENFT_IPK_DIR)/opt/etc/init.d/S??gift-openft
#
# You may need to patch your application to make it use these locations.
#
$(GIFTOPENFT_IPK): $(GIFTOPENFT_BUILD_DIR)/.built
	rm -rf $(GIFTOPENFT_IPK_DIR) $(BUILD_DIR)/gift-openft_*_$(TARGET_ARCH).ipk
	install -d $(GIFTOPENFT_IPK_DIR)/opt/lib/giFT
	$(STRIP_COMMAND) $(GIFTOPENFT_BUILD_DIR)/src/.libs/libOpenFT.so -o $(GIFTOPENFT_IPK_DIR)/opt/lib/giFT/libOpenFT.so
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/src/.libs/libOpenFT.la $(GIFTOPENFT_IPK_DIR)/opt/lib/giFT/libOpenFT.la
	install -d $(GIFTOPENFT_IPK_DIR)/opt/share/giFT/OpenFT
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/etc/OpenFT.conf.template $(GIFTOPENFT_IPK_DIR)/opt/share/giFT/OpenFT/OpenFT.conf.template
	install -m 644 $(GIFTOPENFT_BUILD_DIR)/data/nodes $(GIFTOPENFT_IPK_DIR)/opt/share/giFT/OpenFT/nodes
	install -d $(GIFTOPENFT_IPK_DIR)/CONTROL
	$(MAKE) $(GIFTOPENFT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFTOPENFT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-openft-ipk: $(GIFTOPENFT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-openft-clean:
	-$(MAKE) -C $(GIFTOPENFT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-openft-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFTOPENFT_DIR) $(GIFTOPENFT_BUILD_DIR) $(GIFTOPENFT_IPK_DIR) $(GIFTOPENFT_IPK)
