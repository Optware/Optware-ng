###########################################################
#
# snort
#
###########################################################

# You must replace "snort" and "SNORT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SNORT_VERSION, SNORT_SITE and SNORT_SOURCE define
# the upstream location of the source code for the package.
# SNORT_DIR is the directory which is created when the source
# archive is unpacked.
# SNORT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SNORT_SITE=http://www.snort.org/dl/
SNORT_VERSION=2.3.0
SNORT_SOURCE=snort-$(SNORT_VERSION).tar.gz
SNORT_DIR=snort-$(SNORT_VERSION)
SNORT_UNZIP=zcat

#
# SNORT_IPK_VERSION should be incremented when the ipk changes.
#
SNORT_IPK_VERSION=1

#
# SNORT_CONFFILES should be a list of user-editable files
#SNORT_CONFFILES=/opt/etc/snort.conf /opt/etc/init.d/SXXsnort

#
# SNORT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SNORT_PATCHES=$(SNORT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SNORT_CPPFLAGS=
SNORT_LDFLAGS=

#
# SNORT_BUILD_DIR is the directory in which the build is done.
# SNORT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SNORT_IPK_DIR is the directory in which the ipk is built.
# SNORT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SNORT_BUILD_DIR=$(BUILD_DIR)/snort
SNORT_SOURCE_DIR=$(SOURCE_DIR)/snort
SNORT_IPK_DIR=$(BUILD_DIR)/snort-$(SNORT_VERSION)-ipk
SNORT_IPK=$(BUILD_DIR)/snort_$(SNORT_VERSION)-$(SNORT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SNORT_SOURCE):
	$(WGET) -P $(DL_DIR) $(SNORT_SITE)/$(SNORT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
snort-source: $(DL_DIR)/$(SNORT_SOURCE) $(SNORT_PATCHES)

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
$(SNORT_BUILD_DIR)/.configured: $(DL_DIR)/$(SNORT_SOURCE) $(SNORT_PATCHES)
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(SNORT_DIR) $(SNORT_BUILD_DIR)
	$(SNORT_UNZIP) $(DL_DIR)/$(SNORT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(SNORT_PATCHES) | patch -d $(BUILD_DIR)/$(SNORT_DIR) -p1
	mv $(BUILD_DIR)/$(SNORT_DIR) $(SNORT_BUILD_DIR)
	(cd $(SNORT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SNORT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SNORT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(SNORT_BUILD_DIR)/.configured

snort-unpack: $(SNORT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SNORT_BUILD_DIR)/.built: $(SNORT_BUILD_DIR)/.configured
	rm -f $(SNORT_BUILD_DIR)/.built
	$(MAKE) -C $(SNORT_BUILD_DIR)
	touch $(SNORT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
snort: $(SNORT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SNORT_BUILD_DIR)/.staged: $(SNORT_BUILD_DIR)/.built
	rm -f $(SNORT_BUILD_DIR)/.staged
	$(MAKE) -C $(SNORT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SNORT_BUILD_DIR)/.staged

snort-stage: $(SNORT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(SNORT_IPK_DIR)/opt/sbin or $(SNORT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SNORT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SNORT_IPK_DIR)/opt/etc/snort/...
# Documentation files should be installed in $(SNORT_IPK_DIR)/opt/doc/snort/...
# Daemon startup scripts should be installed in $(SNORT_IPK_DIR)/opt/etc/init.d/S??snort
#
# You may need to patch your application to make it use these locations.
#
$(SNORT_IPK): $(SNORT_BUILD_DIR)/.built
	rm -rf $(SNORT_IPK_DIR) $(BUILD_DIR)/snort_*_armeb.ipk
	$(MAKE) -C $(SNORT_BUILD_DIR) DESTDIR=$(SNORT_IPK_DIR) install
	install -d $(SNORT_IPK_DIR)/opt/etc/
#	install -m 644 $(SNORT_SOURCE_DIR)/snort.conf $(SNORT_IPK_DIR)/opt/etc/snort.conf
#	install -d $(SNORT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SNORT_SOURCE_DIR)/rc.snort $(SNORT_IPK_DIR)/opt/etc/init.d/SXXsnort
	install -d $(SNORT_IPK_DIR)/CONTROL
	install -m 644 $(SNORT_SOURCE_DIR)/control $(SNORT_IPK_DIR)/CONTROL/control
#	install -m 644 $(SNORT_SOURCE_DIR)/postinst $(SNORT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(SNORT_SOURCE_DIR)/prerm $(SNORT_IPK_DIR)/CONTROL/prerm
	echo $(SNORT_CONFFILES) | sed -e 's/ /\n/g' > $(SNORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SNORT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
snort-ipk: $(SNORT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
snort-clean:
	-$(MAKE) -C $(SNORT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
snort-dirclean:
	rm -rf $(BUILD_DIR)/$(SNORT_DIR) $(SNORT_BUILD_DIR) $(SNORT_IPK_DIR) $(SNORT_IPK)
