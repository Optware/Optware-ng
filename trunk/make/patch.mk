###########################################################
#
# patch
#
###########################################################

# You must replace "patch" and "PATCH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PATCH_VERSION, PATCH_SITE and PATCH_SOURCE define
# the upstream location of the source code for the package.
# PATCH_DIR is the directory which is created when the source
# archive is unpacked.
# PATCH_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PATCH_SITE=ftp://ftp.gnu.org/gnu/patch
PATCH_VERSION=2.5.4
PATCH_SOURCE=patch-$(PATCH_VERSION).tar.gz
PATCH_DIR=patch-$(PATCH_VERSION)
PATCH_UNZIP=zcat

#
# PATCH_IPK_VERSION should be incremented when the ipk changes.
#
PATCH_IPK_VERSION=2

#
# PATCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PATCH_PATCHES=$(PATCH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PATCH_CPPFLAGS=
PATCH_LDFLAGS=

#
# PATCH_BUILD_DIR is the directory in which the build is done.
# PATCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PATCH_IPK_DIR is the directory in which the ipk is built.
# PATCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PATCH_BUILD_DIR=$(BUILD_DIR)/patch
PATCH_SOURCE_DIR=$(SOURCE_DIR)/patch
PATCH_IPK_DIR=$(BUILD_DIR)/patch-$(PATCH_VERSION)-ipk
PATCH_IPK=$(BUILD_DIR)/patch_$(PATCH_VERSION)-$(PATCH_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PATCH_SOURCE):
	$(WGET) -P $(DL_DIR) $(PATCH_SITE)/$(PATCH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
patch-source: $(DL_DIR)/$(PATCH_SOURCE) $(PATCH_PATCHES)

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
$(PATCH_BUILD_DIR)/.configured: $(DL_DIR)/$(PATCH_SOURCE) $(PATCH_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PATCH_DIR) $(PATCH_BUILD_DIR)
	$(PATCH_UNZIP) $(DL_DIR)/$(PATCH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PATCH_PATCHES) | patch -d $(BUILD_DIR)/$(PATCH_DIR) -p1
	mv $(BUILD_DIR)/$(PATCH_DIR) $(PATCH_BUILD_DIR)
	(cd $(PATCH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PATCH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PATCH_LDFLAGS)" \
		ac_cv_func_fseeko=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(PATCH_BUILD_DIR)/.configured

patch-unpack: $(PATCH_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PATCH_BUILD_DIR)/patch: $(PATCH_BUILD_DIR)/.configured
	$(MAKE) -C $(PATCH_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
patch: $(PATCH_BUILD_DIR)/patch

#
# This builds the IPK file.
#
# Binaries should be installed into $(PATCH_IPK_DIR)/opt/sbin or $(PATCH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PATCH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PATCH_IPK_DIR)/opt/etc/patch/...
# Documentation files should be installed in $(PATCH_IPK_DIR)/opt/doc/patch/...
# Daemon startup scripts should be installed in $(PATCH_IPK_DIR)/opt/etc/init.d/S??patch
#
# You may need to patch your application to make it use these locations.
#
$(PATCH_IPK): $(PATCH_BUILD_DIR)/patch
	rm -rf $(PATCH_IPK_DIR) $(PATCH_IPK)
	install -d $(PATCH_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(PATCH_BUILD_DIR)/patch -o $(PATCH_IPK_DIR)/opt/bin/patch
#	install -d $(PATCH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PATCH_SOURCE_DIR)/rc.patch $(PATCH_IPK_DIR)/opt/etc/init.d/SXXpatch
	install -d $(PATCH_IPK_DIR)/CONTROL
	install -m 644 $(PATCH_SOURCE_DIR)/control $(PATCH_IPK_DIR)/CONTROL/control
#	install -m 644 $(PATCH_SOURCE_DIR)/postinst $(PATCH_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PATCH_SOURCE_DIR)/prerm $(PATCH_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PATCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
patch-ipk: $(PATCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
patch-clean:
	-$(MAKE) -C $(PATCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
patch-dirclean:
	rm -rf $(BUILD_DIR)/$(PATCH_DIR) $(PATCH_BUILD_DIR) $(PATCH_IPK_DIR) $(PATCH_IPK)
