###########################################################
#
# gift-opennap
#
###########################################################

#
# GIFT_OPENNAP_VERSION, GIFT_OPENNAP_REPOSITORY and GIFT_OPENNAP_SOURCE define
# the upstream location of the source code for the package.
# GIFT_OPENNAP_DIR is the directory which is created when the source
# archive is unpacked.
# GIFT_OPENNAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFT_OPENNAP_REPOSITORY=:pserver:anonymous@cvs.gift-opennap.berlios.de:/cvsroot/gift-opennap
GIFT_OPENNAP_VERSION=20050212
GIFT_OPENNAP_SOURCE=gift-opennap-$(GIFT_OPENNAP_VERSION).tar.gz
GIFT_OPENNAP_TAG=-D 2005-02-12
GIFT_OPENNAP_MODULE=giFT-OpenNap 
GIFT_OPENNAP_DIR=gift-opennap-$(GIFT_OPENNAP_VERSION)
GIFT_OPENNAP_UNZIP=zcat

#
# GIFT_OPENNAP_IPK_VERSION should be incremented when the ipk changes.
#
GIFT_OPENNAP_IPK_VERSION=1

#
# GIFT_OPENNAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GIFT_OPENNAP_PATCHES=$(GIFT_OPENNAP_SOURCE_DIR)/patch.PATH

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFT_OPENNAP_CPPFLAGS=
GIFT_OPENNAP_LDFLAGS=

#
# GIFT_OPENNAP_BUILD_DIR is the directory in which the build is done.
# GIFT_OPENNAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFT_OPENNAP_IPK_DIR is the directory in which the ipk is built.
# GIFT_OPENNAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFT_OPENNAP_BUILD_DIR=$(BUILD_DIR)/gift-opennap
GIFT_OPENNAP_SOURCE_DIR=$(SOURCE_DIR)/gift-opennap
GIFT_OPENNAP_IPK_DIR=$(BUILD_DIR)/gift-opennap-$(GIFT_OPENNAP_VERSION)-ipk
GIFT_OPENNAP_IPK=$(BUILD_DIR)/gift-opennap_$(GIFT_OPENNAP_VERSION)-$(GIFT_OPENNAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from cvs.
#
$(DL_DIR)/$(GIFT_OPENNAP_SOURCE):
	cd $(DL_DIR) ; $(CVS) -z3 -d $(GIFT_OPENNAP_REPOSITORY) co $(GIFT_OPENNAP_TAG) $(GIFT_OPENNAP_MODULE)
	mv $(DL_DIR)/$(GIFT_OPENNAP_MODULE) $(DL_DIR)/$(GIFT_OPENNAP_DIR)
	cd $(DL_DIR) ; tar zcvf $(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_DIR)
	rm -rf $(DL_DIR)/$(GIFT_OPENNAP_DIR)



#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-opennap-source: $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_PATCHES)

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
$(GIFT_OPENNAP_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) $(GIFT_OPENNAP_PATCHES)
	$(MAKE) gift-stage
	rm -rf $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(GIFT_OPENNAP_BUILD_DIR)
	$(GIFT_OPENNAP_UNZIP) $(DL_DIR)/$(GIFT_OPENNAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GIFT_OPENNAP_PATCHES) | patch -d $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) -p1
	mv $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(GIFT_OPENNAP_BUILD_DIR)
	(cd $(GIFT_OPENNAP_BUILD_DIR); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		ACLOCAL="aclocal-1.9 -I m4" AUTOMAKE=automake-1.9 autoreconf -i -v; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFT_OPENNAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFT_OPENNAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-shared \
	)
	touch $(GIFT_OPENNAP_BUILD_DIR)/.configured

gift-opennap-unpack: $(GIFT_OPENNAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GIFT_OPENNAP_BUILD_DIR)/.built: $(GIFT_OPENNAP_BUILD_DIR)/.configured
	rm -f $(GIFT_OPENNAP_BUILD_DIR)/.built
	$(MAKE) -C $(GIFT_OPENNAP_BUILD_DIR)
	touch $(GIFT_OPENNAP_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gift-opennap: $(GIFT_OPENNAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgift-opennap.so.$(GIFT_OPENNAP_VERSION): $(GIFT_OPENNAP_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/gift-opennap.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/libgift-opennap.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/libgift-opennap.so.$(GIFT_OPENNAP_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-opennap.so.$(GIFT_OPENNAP_VERSION) libgift-opennap.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-opennap.so.$(GIFT_OPENNAP_VERSION) libgift-opennap.so

gift-opennap-stage: $(STAGING_DIR)/opt/lib/libgift-opennap.so.$(GIFT_OPENNAP_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFT_OPENNAP_IPK_DIR)/opt/sbin or $(GIFT_OPENNAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFT_OPENNAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFT_OPENNAP_IPK_DIR)/opt/etc/gift-opennap/...
# Documentation files should be installed in $(GIFT_OPENNAP_IPK_DIR)/opt/doc/gift-opennap/...
# Daemon startup scripts should be installed in $(GIFT_OPENNAP_IPK_DIR)/opt/etc/init.d/S??gift-opennap
#
# You may need to patch your application to make it use these locations.
#
$(GIFT_OPENNAP_IPK): $(GIFT_OPENNAP_BUILD_DIR)/.built
	rm -rf $(GIFT_OPENNAP_IPK_DIR) $(BUILD_DIR)/gift-opennap_*_$(TARGET_ARCH).ipk
	install -d $(GIFT_OPENNAP_IPK_DIR)/opt/lib/giFT
	$(STRIP_COMMAND) $(GIFT_OPENNAP_BUILD_DIR)/src/.libs/libOpenNap.so -o $(GIFT_OPENNAP_IPK_DIR)/opt/lib/giFT/libOpenNap.so
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/src/.libs/libOpenNap.la $(GIFT_OPENNAP_IPK_DIR)/opt/lib/giFT/libOpenNap.la
	install -d $(GIFT_OPENNAP_IPK_DIR)/opt/share/giFT/OpenNap
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/data/OpenNap.conf.template $(GIFT_OPENNAP_IPK_DIR)/opt/share/giFT/OpenNap/OpenNap.conf.template
	install -m 644 $(GIFT_OPENNAP_BUILD_DIR)/data/nodelist $(GIFT_OPENNAP_IPK_DIR)/opt/share/giFT/OpenNap/nodelist
	install -d $(GIFT_OPENNAP_IPK_DIR)/CONTROL
	install -m 644 $(GIFT_OPENNAP_SOURCE_DIR)/control $(GIFT_OPENNAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFT_OPENNAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-opennap-ipk: $(GIFT_OPENNAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-opennap-clean:
	-$(MAKE) -C $(GIFT_OPENNAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-opennap-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFT_OPENNAP_DIR) $(GIFT_OPENNAP_BUILD_DIR) $(GIFT_OPENNAP_IPK_DIR) $(GIFT_OPENNAP_IPK)
