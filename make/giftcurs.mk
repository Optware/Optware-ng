###########################################################
#
# giFTcurs
#
###########################################################

# You must replace "giFTcurs" and "GIFTCURS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFTCURS_VERSION, GIFTCURS_SITE and GIFTCURS_SOURCE define
# the upstream location of the source code for the package.
# GIFTCURS_DIR is the directory which is created when the source
# archive is unpacked.
# GIFTCURS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFTCURS_SITE=http://savannah.nongnu.org/download/giftcurs
GIFTCURS_VERSION=0.6.2
GIFTCURS_SOURCE=giFTcurs-$(GIFTCURS_VERSION).tar.gz
GIFTCURS_DIR=giFTcurs-$(GIFTCURS_VERSION)
GIFTCURS_UNZIP=zcat

#
# GIFTCURS_IPK_VERSION should be incremented when the ipk changes.
#
GIFTCURS_IPK_VERSION=1

#
# GIFTCURS_CONFFILES should be a list of user-editable files
GIFTCURS_CONFFILES=/opt/etc/giFTcurs.conf /opt/etc/init.d/SXXgiFTcurs

#
# GIFTCURS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GIFTCURS_PATCHES=$(GIFTCURS_SOURCE_DIR)/patch.noglibtest

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFTCURS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0
GIFTCURS_LDFLAGS=$(STAGING_LIB_DIR)/libglib-2.0.so

#
# GIFTCURS_BUILD_DIR is the directory in which the build is done.
# GIFTCURS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFTCURS_IPK_DIR is the directory in which the ipk is built.
# GIFTCURS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFTCURS_BUILD_DIR=$(BUILD_DIR)/giftcurs
GIFTCURS_SOURCE_DIR=$(SOURCE_DIR)/giftcurs
GIFTCURS_IPK_DIR=$(BUILD_DIR)/giftcurs-$(GIFTCURS_VERSION)-ipk
GIFTCURS_IPK=$(BUILD_DIR)/giftcurs_$(GIFTCURS_VERSION)-$(GIFTCURS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFTCURS_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIFTCURS_SITE)/$(GIFTCURS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
giftcurs-source: $(DL_DIR)/$(GIFTCURS_SOURCE) $(GIFTCURS_PATCHES)

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
$(GIFTCURS_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFTCURS_SOURCE) $(GIFTCURS_PATCHES)
	$(MAKE) gift-stage glib
	rm -rf $(BUILD_DIR)/$(GIFTCURS_DIR) $(GIFTCURS_BUILD_DIR)
	$(GIFTCURS_UNZIP) $(DL_DIR)/$(GIFTCURS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GIFTCURS_PATCHES) | patch -d $(BUILD_DIR)/$(GIFTCURS_DIR) -p1
	mv $(BUILD_DIR)/$(GIFTCURS_DIR) $(GIFTCURS_BUILD_DIR)
	(cd $(GIFTCURS_BUILD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFTCURS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFTCURS_LDFLAGS)" \
		./configure \
		--disable-glibtest \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ncurses=$(STAGING_DIR)/opt \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFTCURS_BUILD_DIR)/.configured

giftcurs-unpack: $(GIFTCURS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIFTCURS_BUILD_DIR)/.built: $(GIFTCURS_BUILD_DIR)/.configured
	rm -f $(GIFTCURS_BUILD_DIR)/.built
	$(MAKE) -C $(GIFTCURS_BUILD_DIR)
	touch $(GIFTCURS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
giftcurs: $(GIFTCURS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgiFTcurs.so.$(GIFTCURS_VERSION): $(GIFTCURS_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFTCURS_BUILD_DIR)/giFTcurs.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTCURS_BUILD_DIR)/libgiFTcurs.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTCURS_BUILD_DIR)/libgiFTcurs.so.$(GIFTCURS_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiFTcurs.so.$(GIFTCURS_VERSION) libgiFTcurs.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiFTcurs.so.$(GIFTCURS_VERSION) libgiFTcurs.so

giFTcurs-stage: $(STAGING_DIR)/opt/lib/libgiFTcurs.so.$(GIFTCURS_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFTCURS_IPK_DIR)/opt/sbin or $(GIFTCURS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFTCURS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFTCURS_IPK_DIR)/opt/etc/giFTcurs/...
# Documentation files should be installed in $(GIFTCURS_IPK_DIR)/opt/doc/giFTcurs/...
# Daemon startup scripts should be installed in $(GIFTCURS_IPK_DIR)/opt/etc/init.d/S??giFTcurs
#
# You may need to patch your application to make it use these locations.
#
$(GIFTCURS_IPK): $(GIFTCURS_BUILD_DIR)/.built
	rm -rf $(GIFTCURS_IPK_DIR) $(BUILD_DIR)/giftcurs_*_armeb.ipk
	install -d $(GIFTCURS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(GIFTCURS_BUILD_DIR)/src/giFTcurs -o $(GIFTCURS_IPK_DIR)/opt/bin/giFTcurs
	install -d $(GIFTCURS_IPK_DIR)/CONTROL
	install -m 644 $(GIFTCURS_SOURCE_DIR)/control $(GIFTCURS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFTCURS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
giftcurs-ipk: $(GIFTCURS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
giftcurs-clean:
	-$(MAKE) -C $(GIFTCURS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
giftcurs-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFTCURS_DIR) $(GIFTCURS_BUILD_DIR) $(GIFTCURS_IPK_DIR) $(GIFTCURS_IPK)
