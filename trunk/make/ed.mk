###########################################################
#
# ed
#
###########################################################

# You must replace "ed" and "ED" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ED_VERSION, ED_SITE and ED_SOURCE define
# the upstream location of the source code for the package.
# ED_DIR is the directory which is created when the source
# archive is unpacked.
# ED_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ED_SITE=ftp://ftp.gnu.org/gnu/ed
ED_VERSION=0.2
ED_SOURCE=ed-$(ED_VERSION).tar.gz
ED_DIR=ed-$(ED_VERSION)
ED_UNZIP=zcat

#
# ED_IPK_VERSION should be incremented when the ipk changes.
#
ED_IPK_VERSION=1

#
# ED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ED_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ED_CPPFLAGS=
ED_LDFLAGS=

#
# ED_BUILD_DIR is the directory in which the build is done.
# ED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ED_IPK_DIR is the directory in which the ipk is built.
# ED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ED_BUILD_DIR=$(BUILD_DIR)/ed
ED_SOURCE_DIR=$(SOURCE_DIR)/ed
ED_IPK_DIR=$(BUILD_DIR)/ed-$(ED_VERSION)-ipk
ED_IPK=$(BUILD_DIR)/ed_$(ED_VERSION)-$(ED_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ED_SOURCE):
	$(WGET) -P $(DL_DIR) $(ED_SITE)/$(ED_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ed-source: $(DL_DIR)/$(ED_SOURCE) $(ED_PATCHES)

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
$(ED_BUILD_DIR)/.configured: $(DL_DIR)/$(ED_SOURCE) $(ED_PATCHES)
	rm -rf $(BUILD_DIR)/$(ED_DIR) $(ED_BUILD_DIR)
	$(ED_UNZIP) $(DL_DIR)/$(ED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ED_PATCHES) | patch -d $(BUILD_DIR)/$(ED_DIR) -p1
	mv $(BUILD_DIR)/$(ED_DIR) $(ED_BUILD_DIR)
	(cd $(ED_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(ED_BUILD_DIR)/.configured

ed-unpack: $(ED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ED_BUILD_DIR)/.built: $(ED_BUILD_DIR)/.configured
	rm -f $(ED_BUILD_DIR)/.built
	$(MAKE) -C $(ED_BUILD_DIR)
	touch $(ED_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ed: $(ED_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(ED_IPK_DIR)/opt/sbin or $(ED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ED_IPK_DIR)/opt/etc/ed/...
# Documentation files should be installed in $(ED_IPK_DIR)/opt/doc/ed/...
# Daemon startup scripts should be installed in $(ED_IPK_DIR)/opt/etc/init.d/S??ed
#
# You may need to patch your application to make it use these locations.
#
$(ED_IPK): $(ED_BUILD_DIR)/.built
	rm -rf $(ED_IPK_DIR) $(BUILD_DIR)/ed_*_armeb.ipk
	$(MAKE) -C $(ED_BUILD_DIR) DESTDIR=$(ED_IPK_DIR) install
	install -d $(ED_IPK_DIR)/CONTROL
	install -m 644 $(ED_SOURCE_DIR)/control $(ED_IPK_DIR)/CONTROL/control
#	echo $(ED_CONFFILES) | sed -e 's/ /\n/g' > $(ED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ed-ipk: $(ED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ed-clean:
	-$(MAKE) -C $(ED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ed-dirclean:
	rm -rf $(BUILD_DIR)/$(ED_DIR) $(ED_BUILD_DIR) $(ED_IPK_DIR) $(ED_IPK)
