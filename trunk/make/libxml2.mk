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
LIBXML2_SITE=http://xmlsoft.org/sources
LIBXML2_VERSION=2.6.17
LIBXML2_SOURCE=libxml2-$(LIBXML2_VERSION).tar.gz
LIBXML2_DIR=libxml2-$(LIBXML2_VERSION)
LIBXML2_UNZIP=zcat

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
LIBXML2_PATCHES=$(LIBXML2_SOURCE_DIR)/libxml2-testModule.c.patch

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
LIBXML2_IPK=$(BUILD_DIR)/libxml2_$(LIBXML2_VERSION)-$(LIBXML2_IPK_VERSION)_armeb.ipk

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
$(LIBXML2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXML2_SOURCE) $(LIBXML2_PATCHES)
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
		--without-python \
	)
	touch $(LIBXML2_BUILD_DIR)/.configured

libxml2-unpack: $(LIBXML2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXML2_BUILD_DIR)/.built: $(LIBXML2_BUILD_DIR)/.configured
	rm -f $(LIBXML2_BUILD_DIR)/.built
	$(MAKE) -C $(LIBXML2_BUILD_DIR)
	touch $(LIBXML2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libxml2: $(LIBXML2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXML2_BUILD_DIR)/.staged: $(LIBXML2_BUILD_DIR)/.built
	rm -f $(LIBXML2_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBXML2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	# move xml2-config to .../staging/bin so other .mk's can find it
	mv $(STAGING_DIR)/opt/bin/xml2-config $(STAGING_DIR)/bin
	# remove .la to avoid libtool problems
	rm $(STAGING_LIB_DIR)/libxml2.la
	touch $(LIBXML2_BUILD_DIR)/.staged

libxml2-stage: $(LIBXML2_BUILD_DIR)/.staged

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
	rm -rf $(LIBXML2_IPK_DIR) $(BUILD_DIR)/libxml2_*_armeb.ipk
	$(MAKE) -C $(LIBXML2_BUILD_DIR) DESTDIR=$(LIBXML2_IPK_DIR) install
	# remove .la to avoid libtool problems
	rm $(LIBXML2_IPK_DIR)/opt/lib/libxml2.la
#	install -d $(LIBXML2_IPK_DIR)/opt/etc/
#	install -m 755 $(LIBXML2_SOURCE_DIR)/libxml2.conf $(LIBXML2_IPK_DIR)/opt/etc/libxml2.conf
#	install -d $(LIBXML2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBXML2_SOURCE_DIR)/rc.libxml2 $(LIBXML2_IPK_DIR)/opt/etc/init.d/SXXlibxml2
	install -d $(LIBXML2_IPK_DIR)/CONTROL
	install -m 644 $(LIBXML2_SOURCE_DIR)/control $(LIBXML2_IPK_DIR)/CONTROL/control
#	install -m 644 $(LIBXML2_SOURCE_DIR)/postinst $(LIBXML2_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(LIBXML2_SOURCE_DIR)/prerm $(LIBXML2_IPK_DIR)/CONTROL/prerm
#	echo $(LIBXML2_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXML2_IPK_DIR)/CONTROL/conffiles
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
