###########################################################
#
# cups
#
###########################################################

# You must replace "cups" and "CUPS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CUPS_VERSION, CUPS_SITE and CUPS_SOURCE define
# the upstream location of the source code for the package.
# CUPS_DIR is the directory which is created when the source
# archive is unpacked.
# CUPS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CUPS_SITE=http://ftp.easysw.com/pub/cups/1.1.23/
CUPS_VERSION=1.1.23
CUPS_SOURCE=cups-$(CUPS_VERSION)-source.tar.gz
CUPS_DIR=cups-$(CUPS_VERSION)
CUPS_UNZIP=zcat

#
# CUPS_IPK_VERSION should be incremented when the ipk changes.
#
CUPS_IPK_VERSION=1

#
# CUPS_CONFFILES should be a list of user-editable files
CUPS_CONFFILES=/opt/etc/cups.conf /opt/etc/init.d/SXXcups

#
# CUPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CUPS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUPS_CPPFLAGS=
CUPS_LDFLAGS=

#
# CUPS_BUILD_DIR is the directory in which the build is done.
# CUPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS_IPK_DIR is the directory in which the ipk is built.
# CUPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS_BUILD_DIR=$(BUILD_DIR)/cups
CUPS_SOURCE_DIR=$(SOURCE_DIR)/cups
CUPS_IPK_DIR=$(BUILD_DIR)/cups-$(CUPS_VERSION)-ipk
CUPS_IPK=$(BUILD_DIR)/cups_$(CUPS_VERSION)-$(CUPS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CUPS_SITE)/$(CUPS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-source: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES)

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
$(CUPS_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS_SOURCE) $(CUPS_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR)
	$(CUPS_UNZIP) $(DL_DIR)/$(CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(CUPS_PATCHES) | patch -d $(BUILD_DIR)/$(CUPS_DIR) -p1
	mv $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR)
	(cd $(CUPS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CUPS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CUPS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--exec_prefix=/opt \
		--disable-nls \
		--with-openssl-libs=$(STAGING_DIR)/opt/lib \
		--with-openssl-includes=$(STAGING_DIR)/opt/include \
	)
	touch $(CUPS_BUILD_DIR)/.configured

cups-unpack: $(CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CUPS_BUILD_DIR)/.built: $(CUPS_BUILD_DIR)/.configured
	rm -f $(CUPS_BUILD_DIR)/.built
	$(MAKE) -C $(CUPS_BUILD_DIR) LDFLAGS="$(STAGING_LDFLAGS) -L../cups -L../filter $(RC_CFLAGS) -L/home/edmondsc/unslung/staging/opt/lib -Wl,-rpath,$(STAGING_DIR)/opt/lib -Wl,-rpath,/opt/lib $(OPTIM)"
	$(MAKE) install -C $(CUPS_BUILD_DIR) BUILDROOT=$(CUPS_BUILD_DIR)/install/ 
	touch $(CUPS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
cups: $(CUPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libcups.so.$(CUPS_VERSION): $(CUPS_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(CUPS_BUILD_DIR)/cups.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(CUPS_BUILD_DIR)/libcups.a $(STAGING_DIR)/opt/lib
	install -m 644 $(CUPS_BUILD_DIR)/libcups.so.$(CUPS_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libcups.so.$(CUPS_VERSION) libcups.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libcups.so.$(CUPS_VERSION) libcups.so

cups-stage: $(STAGING_DIR)/opt/lib/libcups.so.$(CUPS_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUPS_IPK_DIR)/opt/sbin or $(CUPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CUPS_IPK_DIR)/opt/etc/cups/...
# Documentation files should be installed in $(CUPS_IPK_DIR)/opt/doc/cups/...
# Daemon startup scripts should be installed in $(CUPS_IPK_DIR)/opt/etc/init.d/S??cups
#
# You may need to patch your application to make it use these locations.
#
$(CUPS_IPK): $(CUPS_BUILD_DIR)/.built
	rm -rf $(CUPS_IPK_DIR) $(BUILD_DIR)/cups_*_armeb.ipk
	install -d $(CUPS_IPK_DIR)
#	install -m 755 $(CUPS_SOURCE_DIR)/rc.cups $(CUPS_IPK_DIR)/opt/etc/init.d/SXXcups
	cp -rf $(CUPS_BUILD_DIR)/install/* $(CUPS_IPK_DIR)
	rm -r $(CUPS_IPK_DIR)/etc
	install -d $(CUPS_IPK_DIR)/CONTROL
	install -m 644 $(CUPS_SOURCE_DIR)/control $(CUPS_IPK_DIR)/CONTROL/control
#	install -m 644 $(CUPS_SOURCE_DIR)/postinst $(CUPS_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(CUPS_SOURCE_DIR)/prerm $(CUPS_IPK_DIR)/CONTROL/prerm
#	echo $(CUPS_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cups-ipk: $(CUPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cups-clean:
	-$(MAKE) -C $(CUPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cups-dirclean:
	rm -rf $(BUILD_DIR)/$(CUPS_DIR) $(CUPS_BUILD_DIR) $(CUPS_IPK_DIR) $(CUPS_IPK)
