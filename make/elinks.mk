###########################################################
#
# elinks
#
###########################################################

# You must replace "elinks" and "ELINKS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ELINKS_VERSION, ELINKS_SITE and ELINKS_SOURCE define
# the upstream location of the source code for the package.
# ELINKS_DIR is the directory which is created when the source
# archive is unpacked.
# ELINKS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ELINKS_SITE=http://elinks.or.cz/download
ELINKS_VERSION=0.10.1
ELINKS_SOURCE=elinks-$(ELINKS_VERSION).tar.gz
ELINKS_DIR=elinks-$(ELINKS_VERSION)
ELINKS_UNZIP=zcat

#
# ELINKS_IPK_VERSION should be incremented when the ipk changes.
#
ELINKS_IPK_VERSION=1

#
# ELINKS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ELINKS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ELINKS_CPPFLAGS=
ELINKS_LDFLAGS=

#
# ELINKS_BUILD_DIR is the directory in which the build is done.
# ELINKS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ELINKS_IPK_DIR is the directory in which the ipk is built.
# ELINKS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ELINKS_BUILD_DIR=$(BUILD_DIR)/elinks
ELINKS_SOURCE_DIR=$(SOURCE_DIR)/elinks
ELINKS_IPK_DIR=$(BUILD_DIR)/elinks-$(ELINKS_VERSION)-ipk
ELINKS_IPK=$(BUILD_DIR)/elinks_$(ELINKS_VERSION)-$(ELINKS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ELINKS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ELINKS_SITE)/$(ELINKS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
elinks-source: $(DL_DIR)/$(ELINKS_SOURCE) $(ELINKS_PATCHES)

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
$(ELINKS_BUILD_DIR)/.configured: $(DL_DIR)/$(ELINKS_SOURCE) $(ELINKS_PATCHES)
	$(MAKE) zlib-stage bzip2-stage expat-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(ELINKS_DIR) $(ELINKS_BUILD_DIR)
	$(ELINKS_UNZIP) $(DL_DIR)/$(ELINKS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ELINKS_PATCHES) | patch -d $(BUILD_DIR)/$(ELINKS_DIR) -p1
	mv $(BUILD_DIR)/$(ELINKS_DIR) $(ELINKS_BUILD_DIR)
	(cd $(ELINKS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ELINKS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ELINKS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-256-colors \
	)
	touch $(ELINKS_BUILD_DIR)/.configured

elinks-unpack: $(ELINKS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ELINKS_BUILD_DIR)/.built: $(ELINKS_BUILD_DIR)/.configured
	rm -f $(ELINKS_BUILD_DIR)/.built
	$(MAKE) -C $(ELINKS_BUILD_DIR)
	touch $(ELINKS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
elinks: $(ELINKS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ELINKS_BUILD_DIR)/.staged: $(ELINKS_BUILD_DIR)/.built
	rm -f $(ELINKS_BUILD_DIR)/.staged
	$(MAKE) -C $(ELINKS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ELINKS_BUILD_DIR)/.staged

elinks-stage: $(ELINKS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ELINKS_IPK_DIR)/opt/sbin or $(ELINKS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ELINKS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ELINKS_IPK_DIR)/opt/etc/elinks/...
# Documentation files should be installed in $(ELINKS_IPK_DIR)/opt/doc/elinks/...
# Daemon startup scripts should be installed in $(ELINKS_IPK_DIR)/opt/etc/init.d/S??elinks
#
# You may need to patch your application to make it use these locations.
#
$(ELINKS_IPK): $(ELINKS_BUILD_DIR)/.built
	rm -rf $(ELINKS_IPK_DIR) $(BUILD_DIR)/elinks_*_armeb.ipk
	$(MAKE) -C $(ELINKS_BUILD_DIR) DESTDIR=$(ELINKS_IPK_DIR) install
	install -d $(ELINKS_IPK_DIR)/opt/etc/
	install -m 755 $(ELINKS_SOURCE_DIR)/elinks.conf $(ELINKS_IPK_DIR)/opt/etc/elinks.conf
	install -d $(ELINKS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(ELINKS_SOURCE_DIR)/rc.elinks $(ELINKS_IPK_DIR)/opt/etc/init.d/SXXelinks
	install -d $(ELINKS_IPK_DIR)/CONTROL
	install -m 644 $(ELINKS_SOURCE_DIR)/control $(ELINKS_IPK_DIR)/CONTROL/control
	install -m 644 $(ELINKS_SOURCE_DIR)/postinst $(ELINKS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(ELINKS_SOURCE_DIR)/prerm $(ELINKS_IPK_DIR)/CONTROL/prerm
	echo $(ELINKS_CONFFILES) | sed -e 's/ /\n/g' > $(ELINKS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ELINKS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
elinks-ipk: $(ELINKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
elinks-clean:
	-$(MAKE) -C $(ELINKS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
elinks-dirclean:
	rm -rf $(BUILD_DIR)/$(ELINKS_DIR) $(ELINKS_BUILD_DIR) $(ELINKS_IPK_DIR) $(ELINKS_IPK)
