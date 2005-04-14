###########################################################
#
# flac
#
###########################################################

# You must replace "<foo>" and "<FOO>" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FLAC_VERSION, FLAC_SITE and FLAC_SOURCE define
# the upstream location of the source code for the package.
# FLAC_DIR is the directory which is created when the source
# archive is unpacked.
# FLAC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FLAC_SITE=http://dl.sourceforge.net/sourceforge/flac
FLAC_VERSION=1.1.2
FLAC_SOURCE=flac-$(FLAC_VERSION).tar.gz
FLAC_DIR=flac-$(FLAC_VERSION)
FLAC_UNZIP=zcat

#
# FLAC_IPK_VERSION should be incremented when the ipk changes.
#
FLAC_IPK_VERSION=2

#
# FLAC_CONFFILES should be a list of user-editable files
FLAC_CONFFILES=

#
# FLAC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FLAC_PATCHES=$(FLAC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FLAC_CPPFLAGS=
FLAC_LDFLAGS=

#
# FLAC_BUILD_DIR is the directory in which the build is done.
# FLAC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FLAC_IPK_DIR is the directory in which the ipk is built.
# FLAC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FLAC_BUILD_DIR=$(BUILD_DIR)/flac
FLAC_SOURCE_DIR=$(SOURCE_DIR)/flac
FLAC_IPK_DIR=$(BUILD_DIR)/flac-$(FLAC_VERSION)-ipk
FLAC_IPK=$(BUILD_DIR)/flac_$(FLAC_VERSION)-$(FLAC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FLAC_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLAC_SITE)/$(FLAC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
flac-source: $(DL_DIR)/$(FLAC_SOURCE) $(FLAC_PATCHES)

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
$(FLAC_BUILD_DIR)/.configured: $(DL_DIR)/$(FLAC_SOURCE) $(FLAC_PATCHES)
	#[JEC] we need libogg-1.1.2 but right now there's only libogg-1.0
	#$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(FLAC_DIR) $(FLAC_BUILD_DIR)
	$(FLAC_UNZIP) $(DL_DIR)/$(FLAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(FLAC_PATCHES) | patch -d $(BUILD_DIR)/$(FLAC_DIR) -p0
	mv $(BUILD_DIR)/$(FLAC_DIR) $(FLAC_BUILD_DIR)
	(cd $(FLAC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FLAC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FLAC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-ogg \
	)
	touch $(FLAC_BUILD_DIR)/.configured

flac-unpack: $(FLAC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FLAC_BUILD_DIR)/.built: $(FLAC_BUILD_DIR)/.configured
	rm -f $(FLAC_BUILD_DIR)/.built
	$(MAKE) -C $(FLAC_BUILD_DIR)
	touch $(FLAC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
flac: $(FLAC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FLAC_BUILD_DIR)/.staged: $(FLAC_BUILD_DIR)/.built
	rm -f $(FLAC_BUILD_DIR)/.staged
	$(MAKE) -C $(FLAC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FLAC_BUILD_DIR)/.staged

flac-stage: $(FLAC_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FLAC_IPK_DIR)/opt/sbin or $(FLAC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FLAC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FLAC_IPK_DIR)/opt/etc/flac/...
# Documentation files should be installed in $(FLAC_IPK_DIR)/opt/doc/flac/...
# Daemon startup scripts should be installed in $(FLAC_IPK_DIR)/opt/etc/init.d/S??flac
#
# You may need to patch your application to make it use these locations.
#
$(FLAC_IPK): $(FLAC_BUILD_DIR)/.built
	rm -rf $(FLAC_IPK_DIR) $(BUILD_DIR)/flac_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FLAC_BUILD_DIR) DESTDIR=$(FLAC_IPK_DIR) install
	#[JEC]install -d $(FLAC_IPK_DIR)/opt/etc/
	#[JEC]install -m 644 $(FLAC_SOURCE_DIR)/flac.conf $(FLAC_IPK_DIR)/opt/etc/flac.conf
	#[JEC]install -d $(FLAC_IPK_DIR)/opt/etc/init.d
	#[JEC]install -m 755 $(FLAC_SOURCE_DIR)/rc.flac $(FLAC_IPK_DIR)/opt/etc/init.d/SXXflac
	install -d $(FLAC_IPK_DIR)/CONTROL
	install -m 644 $(FLAC_SOURCE_DIR)/control $(FLAC_IPK_DIR)/CONTROL/control
	#[JEC]install -m 755 $(FLAC_SOURCE_DIR)/postinst $(FLAC_IPK_DIR)/CONTROL/postinst
	#[JEC]install -m 755 $(FLAC_SOURCE_DIR)/prerm $(FLAC_IPK_DIR)/CONTROL/prerm
	#[JEC]echo $(FLAC_CONFFILES) | sed -e 's/ /\n/g' > $(FLAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLAC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
flac-ipk: $(FLAC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
flac-clean:
	-$(MAKE) -C $(FLAC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
flac-dirclean:
	rm -rf $(BUILD_DIR)/$(FLAC_DIR) $(FLAC_BUILD_DIR) $(FLAC_IPK_DIR) $(FLAC_IPK)
