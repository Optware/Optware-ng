###########################################################
#
# tar
#
###########################################################

# You must replace "tar" and "TAR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TAR_VERSION, TAR_SITE and TAR_SOURCE define
# the upstream location of the source code for the package.
# TAR_DIR is the directory which is created when the source
# archive is unpacked.
# TAR_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TAR_SITE=http://ftp.gnu.org/gnu/tar
TAR_VERSION=1.14
TAR_SOURCE=tar-$(TAR_VERSION).tar.gz
TAR_DIR=tar-$(TAR_VERSION)
TAR_UNZIP=zcat

#
# TAR_IPK_VERSION should be incremented when the ipk changes.
#
TAR_IPK_VERSION=1

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TAR_CPPFLAGS=
TAR_LDFLAGS=

#
# TAR_BUILD_DIR is the directory in which the build is done.
# TAR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TAR_IPK_DIR is the directory in which the ipk is built.
# TAR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TAR_BUILD_DIR=$(BUILD_DIR)/tar
TAR_SOURCE_DIR=$(SOURCE_DIR)/tar
TAR_IPK_DIR=$(BUILD_DIR)/tar-$(TAR_VERSION)-ipk
TAR_IPK=$(BUILD_DIR)/tar_$(TAR_VERSION)-$(TAR_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TAR_SOURCE):
	$(WGET) -P $(DL_DIR) $(TAR_SITE)/$(TAR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tar-source: $(DL_DIR)/$(TAR_SOURCE) $(TAR_PATCHES)

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
$(TAR_BUILD_DIR)/.configured: $(DL_DIR)/$(TAR_SOURCE) $(TAR_PATCHES)
	rm -rf $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR)
	$(TAR_UNZIP) $(DL_DIR)/$(TAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR)
	(cd $(TAR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TAR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TAR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(TAR_BUILD_DIR)/.configured

tar-unpack: $(TAR_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(TAR_BUILD_DIR)/.built: $(TAR_BUILD_DIR)/.configured
	rm -f $(TAR_BUILD_DIR)/.built
	$(MAKE) -C $(TAR_BUILD_DIR)
	touch $(TAR_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
tar: $(TAR_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(TAR_IPK_DIR)/opt/sbin or $(TAR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TAR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TAR_IPK_DIR)/opt/etc/tar/...
# Documentation files should be installed in $(TAR_IPK_DIR)/opt/doc/tar/...
# Daemon startup scripts should be installed in $(TAR_IPK_DIR)/opt/etc/init.d/S??tar
#
# You may need to patch your application to make it use these locations.
#
$(TAR_IPK): $(TAR_BUILD_DIR)/.built
	rm -rf $(TAR_IPK_DIR) $(TAR_IPK)
	install -d $(TAR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TAR_BUILD_DIR)/src/tar -o $(TAR_IPK_DIR)/opt/bin/tar
	install -d $(TAR_IPK_DIR)/opt/libexec
	$(STRIP_COMMAND) $(TAR_BUILD_DIR)/src/rmt -o $(TAR_IPK_DIR)/opt/libexec/rmt
	install -d $(TAR_IPK_DIR)/CONTROL
	install -m 644 $(TAR_SOURCE_DIR)/control $(TAR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TAR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tar-ipk: $(TAR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tar-clean:
	-$(MAKE) -C $(TAR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tar-dirclean:
	rm -rf $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR) $(TAR_IPK_DIR) $(TAR_IPK)
