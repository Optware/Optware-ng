###########################################################
#
# pcre
#
###########################################################

# You must replace "pcre" and "PCRE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PCRE_VERSION, PCRE_SITE and PCRE_SOURCE define
# the upstream location of the source code for the package.
# PCRE_DIR is the directory which is created when the source
# archive is unpacked.
# PCRE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PCRE_SITE=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
PCRE_VERSION=5.0
PCRE_SOURCE=pcre-$(PCRE_VERSION).tar.bz2
PCRE_DIR=pcre-$(PCRE_VERSION)
PCRE_UNZIP=bzcat

ifeq ($(HOST_MACHINE),armv5b)
	PCRE_LIBTOOL_TAG=""
else
	PCRE_LIBTOOL_TAG="--tag=CXX"
endif

#
# PCRE_IPK_VERSION should be incremented when the ipk changes.
#
PCRE_IPK_VERSION=2

#
# PCRE_CONFFILES should be a list of user-editable files
#PCRE_CONFFILES=/opt/etc/pcre.conf /opt/etc/init.d/SXXpcre
PCRE_CONFFILES=

#
# PCRE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PCRE_PATCHES=$(PCRE_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCRE_CPPFLAGS=
PCRE_LDFLAGS=

#
# PCRE_BUILD_DIR is the directory in which the build is done.
# PCRE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCRE_IPK_DIR is the directory in which the ipk is built.
# PCRE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCRE_BUILD_DIR=$(BUILD_DIR)/pcre
PCRE_SOURCE_DIR=$(SOURCE_DIR)/pcre
PCRE_IPK_DIR=$(BUILD_DIR)/pcre-$(PCRE_VERSION)-ipk
PCRE_IPK=$(BUILD_DIR)/pcre_$(PCRE_VERSION)-$(PCRE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCRE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PCRE_SITE)/$(PCRE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pcre-source: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES)

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
$(PCRE_BUILD_DIR)/.configured: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	$(PCRE_UNZIP) $(DL_DIR)/$(PCRE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PCRE_PATCHES) | patch -d $(BUILD_DIR)/$(PCRE_DIR) -p1
	mv $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	(cd $(PCRE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CC_FOR_BUILD=$(HOSTCC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCRE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCRE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(PCRE_BUILD_DIR)/.configured

pcre-unpack: $(PCRE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCRE_BUILD_DIR)/.built: $(PCRE_BUILD_DIR)/.configured
	rm -f $(PCRE_BUILD_DIR)/.built
	$(MAKE) -C $(PCRE_BUILD_DIR) LIBTOOL_TAG=$(PCRE_LIBTOOL_TAG)
	touch $(PCRE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
pcre: $(PCRE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCRE_BUILD_DIR)/.staged: $(PCRE_BUILD_DIR)/.built
	rm -f $(PCRE_BUILD_DIR)/.staged
	$(MAKE) -C $(PCRE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PCRE_BUILD_DIR)/.staged

pcre-stage: $(PCRE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCRE_IPK_DIR)/opt/sbin or $(PCRE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCRE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PCRE_IPK_DIR)/opt/etc/pcre/...
# Documentation files should be installed in $(PCRE_IPK_DIR)/opt/doc/pcre/...
# Daemon startup scripts should be installed in $(PCRE_IPK_DIR)/opt/etc/init.d/S??pcre
#
# You may need to patch your application to make it use these locations.
#
$(PCRE_IPK): $(PCRE_BUILD_DIR)/.built
	rm -rf $(PCRE_IPK_DIR) $(BUILD_DIR)/pcre_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCRE_BUILD_DIR) DESTDIR=$(PCRE_IPK_DIR) install
	find $(PCRE_IPK_DIR) -type d -exec chmod go+rx {} \;
	install -d $(PCRE_IPK_DIR)/CONTROL
	install -m 644 $(PCRE_SOURCE_DIR)/control $(PCRE_IPK_DIR)/CONTROL/control
#	install -m 644 $(PCRE_SOURCE_DIR)/postinst $(PCRE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PCRE_SOURCE_DIR)/prerm $(PCRE_IPK_DIR)/CONTROL/prerm
	echo $(PCRE_CONFFILES) | sed -e 's/ /\n/g' > $(PCRE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCRE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pcre-ipk: $(PCRE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pcre-clean:
	-$(MAKE) -C $(PCRE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pcre-dirclean:
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR) $(PCRE_IPK_DIR) $(PCRE_IPK)
