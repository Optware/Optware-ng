###########################################################
#
# jikes
#
###########################################################

#
# JIKES_VERSION, JIKES_SITE and JIKES_SOURCE define
# the upstream location of the source code for the package.
# JIKES_DIR is the directory which is created when the source
# archive is unpacked.
# JIKES_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
JIKES_SITE=ftp://www-126.ibm.com/pub/jikes/1.22
JIKES_VERSION=1.22
JIKES_SOURCE=jikes-$(JIKES_VERSION).tar.bz2
JIKES_DIR=jikes-$(JIKES_VERSION)
JIKES_UNZIP=bzcat

#
# JIKES_IPK_VERSION should be incremented when the ipk changes.
#
JIKES_IPK_VERSION=1

#
# JIKES_CONFFILES should be a list of user-editable files
#JIKES_CONFFILES=/opt/etc/jikes.conf /opt/etc/init.d/SXXjikes

#
# JIKES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JIKES_PATCHES=$(JIKES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JIKES_CPPFLAGS=
JIKES_LDFLAGS=

#
# JIKES_BUILD_DIR is the directory in which the build is done.
# JIKES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JIKES_IPK_DIR is the directory in which the ipk is built.
# JIKES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JIKES_BUILD_DIR=$(BUILD_DIR)/jikes
JIKES_SOURCE_DIR=$(SOURCE_DIR)/jikes
JIKES_IPK_DIR=$(BUILD_DIR)/jikes-$(JIKES_VERSION)-ipk
JIKES_IPK=$(BUILD_DIR)/jikes_$(JIKES_VERSION)-$(JIKES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JIKES_SOURCE):
	$(WGET) -P $(DL_DIR) $(JIKES_SITE)/$(JIKES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jikes-source: $(DL_DIR)/$(JIKES_SOURCE) $(JIKES_PATCHES)

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
$(JIKES_BUILD_DIR)/.configured: $(DL_DIR)/$(JIKES_SOURCE) $(JIKES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(JIKES_DIR) $(JIKES_BUILD_DIR)
	$(JIKES_UNZIP) $(DL_DIR)/$(JIKES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(JIKES_PATCHES) | patch -d $(BUILD_DIR)/$(JIKES_DIR) -p1
	mv $(BUILD_DIR)/$(JIKES_DIR) $(JIKES_BUILD_DIR)
	(cd $(JIKES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JIKES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JIKES_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(JIKES_BUILD_DIR)/.configured

jikes-unpack: $(JIKES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JIKES_BUILD_DIR)/.built: $(JIKES_BUILD_DIR)/.configured
	rm -f $(JIKES_BUILD_DIR)/.built
	$(MAKE) -C $(JIKES_BUILD_DIR)
	touch $(JIKES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
jikes: $(JIKES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JIKES_BUILD_DIR)/.staged: $(JIKES_BUILD_DIR)/.built
	rm -f $(JIKES_BUILD_DIR)/.staged
	$(MAKE) -C $(JIKES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(JIKES_BUILD_DIR)/.staged

jikes-stage: $(JIKES_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(JIKES_IPK_DIR)/opt/sbin or $(JIKES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JIKES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JIKES_IPK_DIR)/opt/etc/jikes/...
# Documentation files should be installed in $(JIKES_IPK_DIR)/opt/doc/jikes/...
# Daemon startup scripts should be installed in $(JIKES_IPK_DIR)/opt/etc/init.d/S??jikes
#
# You may need to patch your application to make it use these locations.
#
$(JIKES_IPK): $(JIKES_BUILD_DIR)/.built
	rm -rf $(JIKES_IPK_DIR) $(BUILD_DIR)/jikes_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(JIKES_BUILD_DIR) DESTDIR=$(JIKES_IPK_DIR) install
	$(STRIP_COMMAND) $(JIKES_IPK_DIR)/opt/bin/jikes
#	install -d $(JIKES_IPK_DIR)/opt/etc/
#	install -m 755 $(JIKES_SOURCE_DIR)/jikes.conf $(JIKES_IPK_DIR)/opt/etc/jikes.conf
#	install -d $(JIKES_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(JIKES_SOURCE_DIR)/rc.jikes $(JIKES_IPK_DIR)/opt/etc/init.d/SXXjikes
	install -d $(JIKES_IPK_DIR)/CONTROL
	install -m 644 $(JIKES_SOURCE_DIR)/control $(JIKES_IPK_DIR)/CONTROL/control
#	install -m 644 $(JIKES_SOURCE_DIR)/postinst $(JIKES_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(JIKES_SOURCE_DIR)/prerm $(JIKES_IPK_DIR)/CONTROL/prerm
#	echo $(JIKES_CONFFILES) | sed -e 's/ /\n/g' > $(JIKES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JIKES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jikes-ipk: $(JIKES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jikes-clean:
	-$(MAKE) -C $(JIKES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jikes-dirclean:
	rm -rf $(BUILD_DIR)/$(JIKES_DIR) $(JIKES_BUILD_DIR) $(JIKES_IPK_DIR) $(JIKES_IPK)
