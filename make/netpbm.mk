###########################################################
#
# netpbm
#
###########################################################

# You must replace "netpbm" and "NETPBM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NETPBM_VERSION, NETPBM_SITE and NETPBM_SOURCE define
# the upstream location of the source code for the package.
# NETPBM_DIR is the directory which is created when the source
# archive is unpacked.
# NETPBM_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NETPBM_SITE=http://dl.sourceforge.net/sourceforge/netpbm
NETPBM_VERSION=10.18.17
NETPBM_SOURCE=netpbm-$(NETPBM_VERSION).tgz
NETPBM_DIR=netpbm-$(NETPBM_VERSION)
NETPBM_UNZIP=zcat

#
# NETPBM_IPK_VERSION should be incremented when the ipk changes.
#
NETPBM_IPK_VERSION=1

#
# NETPBM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NETPBM_PATCHES=$(NETPBM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETPBM_CPPFLAGS=
NETPBM_LDFLAGS=

#
# NETPBM_BUILD_DIR is the directory in which the build is done.
# NETPBM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETPBM_IPK_DIR is the directory in which the ipk is built.
# NETPBM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETPBM_BUILD_DIR=$(BUILD_DIR)/netpbm
NETPBM_SOURCE_DIR=$(SOURCE_DIR)/netpbm
NETPBM_IPK_DIR=$(BUILD_DIR)/netpbm-$(NETPBM_VERSION)-ipk
NETPBM_IPK=$(BUILD_DIR)/netpbm_$(NETPBM_VERSION)-$(NETPBM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETPBM_SOURCE):
	$(WGET) -P $(DL_DIR) $(NETPBM_SITE)/$(NETPBM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netpbm-source: $(DL_DIR)/$(NETPBM_SOURCE) $(NETPBM_PATCHES)

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
$(NETPBM_BUILD_DIR)/.configured: $(DL_DIR)/$(NETPBM_SOURCE) $(NETPBM_PATCHES)
	$(MAKE) libjpeg-stage libpng-stage zlib-stage libtiff-stage
	rm -rf $(BUILD_DIR)/$(NETPBM_DIR) $(NETPBM_BUILD_DIR)
	$(NETPBM_UNZIP) $(DL_DIR)/$(NETPBM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(NETPBM_PATCHES) | patch -d $(BUILD_DIR)/$(NETPBM_DIR) -p1
	mv $(BUILD_DIR)/$(NETPBM_DIR) $(NETPBM_BUILD_DIR)
	(cd $(NETPBM_BUILD_DIR); \
		(echo; echo gnu; echo regular; echo shared; echo y; \
		 echo libjpeg.so; echo $(STAGING_DIR)/opt/lib; \
		 echo libtiff.so; echo $(STAGING_DIR)/opt/lib; \
		 echo libpng.so; echo $(STAGING_DIR)/opt/lib; \
		 echo libz.so; echo $(STAGING_DIR)/opt/lib; \
		 echo none; echo "http://netpbm.sourceforge.net/doc" ) | \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETPBM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETPBM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(NETPBM_BUILD_DIR)/.configured

netpbm-unpack: $(NETPBM_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NETPBM_BUILD_DIR)/.built: $(NETPBM_BUILD_DIR)/.configured
	rm -f $(NETPBM_BUILD_DIR)/.built
	$(MAKE) -C $(NETPBM_BUILD_DIR)
	touch $(NETPBM_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
netpbm: $(NETPBM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libnetpbm.so.$(NETPBM_VERSION): $(NETPBM_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(NETPBM_BUILD_DIR)/netpbm.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(NETPBM_BUILD_DIR)/libnetpbm.a $(STAGING_DIR)/opt/lib
	install -m 644 $(NETPBM_BUILD_DIR)/libnetpbm.so.$(NETPBM_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libnetpbm.so.$(NETPBM_VERSION) libnetpbm.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libnetpbm.so.$(NETPBM_VERSION) libnetpbm.so

netpbm-stage: $(STAGING_DIR)/opt/lib/libnetpbm.so.$(NETPBM_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETPBM_IPK_DIR)/opt/sbin or $(NETPBM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETPBM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETPBM_IPK_DIR)/opt/etc/netpbm/...
# Documentation files should be installed in $(NETPBM_IPK_DIR)/opt/doc/netpbm/...
# Daemon startup scripts should be installed in $(NETPBM_IPK_DIR)/opt/etc/init.d/S??netpbm
#
# You may need to patch your application to make it use these locations.
#
$(NETPBM_IPK): $(NETPBM_BUILD_DIR)/.built
	rm -rf $(NETPBM_IPK_DIR) $(NETPBM_IPK)
	install -d $(NETPBM_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(NETPBM_BUILD_DIR)/netpbm -o $(NETPBM_IPK_DIR)/opt/bin/netpbm
	install -d $(NETPBM_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NETPBM_SOURCE_DIR)/rc.netpbm $(NETPBM_IPK_DIR)/opt/etc/init.d/SXXnetpbm
	install -d $(NETPBM_IPK_DIR)/CONTROL
	install -m 644 $(NETPBM_SOURCE_DIR)/control $(NETPBM_IPK_DIR)/CONTROL/control
	install -m 644 $(NETPBM_SOURCE_DIR)/postinst $(NETPBM_IPK_DIR)/CONTROL/postinst
	install -m 644 $(NETPBM_SOURCE_DIR)/prerm $(NETPBM_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETPBM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netpbm-ipk: $(NETPBM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netpbm-clean:
	-$(MAKE) -C $(NETPBM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netpbm-dirclean:
	rm -rf $(BUILD_DIR)/$(NETPBM_DIR) $(NETPBM_BUILD_DIR) $(NETPBM_IPK_DIR) $(NETPBM_IPK)
