###########################################################
#
# <foo>
#
###########################################################

FINDUTILS_SITE=http://ftp.gnu.org/pub/gnu/findutils
FINDUTILS_VERSION=4.1.20
FINDUTILS_SOURCE=findutils-$(FINDUTILS_VERSION).tar.gz
FINDUTILS_DIR=findutils-$(FINDUTILS_VERSION)
FINDUTILS_UNZIP=zcat

#
# FINDUTILS_IPK_VERSION should be incremented when the ipk changes.
#
FINDUTILS_IPK_VERSION=2

#
# FINDUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FINDUTILS_CPPFLAGS=
FINDUTILS_LDFLAGS=

#
# FINDUTILS_BUILD_DIR is the directory in which the build is done.
# FINDUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FINDUTILS_IPK_DIR is the directory in which the ipk is built.
# FINDUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FINDUTILS_BUILD_DIR=$(BUILD_DIR)/findutils
FINDUTILS_SOURCE_DIR=$(SOURCE_DIR)/findutils
FINDUTILS_IPK_DIR=$(BUILD_DIR)/findutils-$(FINDUTILS_VERSION)-ipk
FINDUTILS_IPK=$(BUILD_DIR)/findutils_$(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)_armeb.ipk
FINDUTILS_DOC_IPK_DIR=$(BUILD_DIR)/findutils-doc-$(FINDUTILS_VERSION)-ipk
FINDUTILS_DOC_IPK=$(BUILD_DIR)/findutils-doc_$(FINDUTILS_VERSION)-$(FINDUTILS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FINDUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(FINDUTILS_SITE)/$(FINDUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
findutils-source: $(DL_DIR)/$(FINDUTILS_SOURCE) $(FINDUTILS_PATCHES)

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
$(FINDUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(FINDUTILS_SOURCE) $(FINDUTILS_PATCHES)
	rm -rf $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR)
	$(FINDUTILS_UNZIP) $(DL_DIR)/$(FINDUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR)
	(cd $(FINDUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FINDUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FINDUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(FINDUTILS_BUILD_DIR)/.configured

findutils-unpack: $(FINDUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(FINDUTILS_BUILD_DIR)/.built: $(FINDUTILS_BUILD_DIR)/.configured
	rm -f $(FINDUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(FINDUTILS_BUILD_DIR)
	touch $(FINDUTILS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
findutils: $(FINDUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#

#
# This builds the IPK file.
#
# Binaries should be installed into $(FINDUTILS_IPK_DIR)/opt/sbin or $(FINDUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FINDUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FINDUTILS_IPK_DIR)/opt/etc/<foo>/...
# Documentation files should be installed in $(FINDUTILS_IPK_DIR)/opt/doc/<foo>/...
# Daemon startup scripts should be installed in $(FINDUTILS_IPK_DIR)/opt/etc/init.d/S??<foo>
#
# You may need to patch your application to make it use these locations.
#
$(FINDUTILS_IPK): $(FINDUTILS_BUILD_DIR)/.built
	rm -rf $(FINDUTILS_IPK_DIR) $(BUILD_DIR)/findutils_*_armeb.ipk
	install -d $(FINDUTILS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(FINDUTILS_BUILD_DIR)/find/find -o $(FINDUTILS_IPK_DIR)/opt/bin/find
	$(STRIP_COMMAND) $(FINDUTILS_BUILD_DIR)/xargs/xargs -o $(FINDUTILS_IPK_DIR)/opt/bin/xargs
	install -d $(FINDUTILS_IPK_DIR)/CONTROL
	install -m 644 $(FINDUTILS_SOURCE_DIR)/control $(FINDUTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FINDUTILS_IPK_DIR)

$(FINDUTILS_DOC_IPK): $(FINDUTILS_BUILD_DIR)/.built
	rm -rf $(FINDUTILS_DOC_IPK_DIR) $(FINDUTILS_DOC_IPK)
	install -d $(FINDUTILS_DOC_IPK_DIR)/opt/doc/findutils
	install -m 644 $(FINDUTILS_BUILD_DIR)/doc/find.i* $(FINDUTILS_DOC_IPK_DIR)/opt/doc/findutils
	install -d $(FINDUTILS_DOC_IPK_DIR)/CONTROL
	install -m 644 $(FINDUTILS_SOURCE_DIR)/control-doc $(FINDUTILS_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FINDUTILS_DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
findutils-ipk: $(FINDUTILS_IPK) $(FINDUTILS_DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
findutils-clean:
	-$(MAKE) -C $(FINDUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
findutils-dirclean:
	rm -rf $(BUILD_DIR)/$(FINDUTILS_DIR) $(FINDUTILS_BUILD_DIR)
	rm -rf $(FINDUTILS_IPK_DIR) $(FINDUTILS_IPK) $(FINDUTILS_DOC_IPK_DIR) $(FINDUTILS_DOC_IPK)
