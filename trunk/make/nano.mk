###########################################################
#
# nano
#
###########################################################

#
# NANO_VERSION, NANO_SITE and NANO_SOURCE define
# the upstream location of the source code for the package.
# NANO_DIR is the directory which is created when the source
# archive is unpacked.
# NANO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
NANO_SITE=http://www.nano-editor.org/dist/v1.2
NANO_VERSION=1.2.4
NANO_SOURCE=nano-$(NANO_VERSION).tar.gz
NANO_DIR=nano-$(NANO_VERSION)
NANO_UNZIP=zcat

#
# NANO_IPK_VERSION should be incremented when the ipk changes.
#
NANO_IPK_VERSION=1

#
# NANO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NANO_PATCHES="$(NANO_SOURCE_DIR)/configure.patch"

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NANO_CPPFLAGS=-I$(STAGING_PREFIX)/include/ncurses
NANO_LDFLAGS=

#
# NANO_BUILD_DIR is the directory in which the build is done.
# NANO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NANO_IPK_DIR is the directory in which the ipk is built.
# NANO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NANO_BUILD_DIR=$(BUILD_DIR)/nano
NANO_SOURCE_DIR=$(SOURCE_DIR)/nano
NANO_IPK_DIR=$(BUILD_DIR)/nano-$(NANO_VERSION)-ipk
NANO_IPK=$(BUILD_DIR)/nano_$(NANO_VERSION)-$(NANO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NANO_SOURCE):
	$(WGET) -P $(DL_DIR) $(NANO_SITE)/$(NANO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nano-source: $(DL_DIR)/$(NANO_SOURCE) $(NANO_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# we run a fake configure and then copy the correct makefile in...
#
$(NANO_BUILD_DIR)/.configured: $(DL_DIR)/$(NANO_SOURCE)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR)
	$(NANO_UNZIP) $(DL_DIR)/$(NANO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NANO_PATCHES) | patch -d $(BUILD_DIR)/$(NANO_DIR)
	mv $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR)
	(cd $(NANO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NANO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NANO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(NANO_BUILD_DIR)/.configured

nano-unpack: $(NANO_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NANO_BUILD_DIR)/nano: $(NANO_BUILD_DIR)/.configured
	$(MAKE) -C $(NANO_BUILD_DIR)

#
# These are the dependencies for the package.  Again, you should change
# the final dependency to refer directly to the main binary which is built.
#
nano: ncurses $(NANO_BUILD_DIR)/nano

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/lib/libnano.so.$(NANO_VERSION): $(NANO_BUILD_DIR)/libnano.so.$(NANO_VERSION)
	install -d $(STAGING_DIR)/include
	install -m 644 $(NANO_BUILD_DIR)/nano.h $(STAGING_DIR)/include
	install -d $(STAGING_DIR)/lib
	install -m 644 $(NANO_BUILD_DIR)/libnano.a $(STAGING_DIR)/lib
	install -m 644 $(NANO_BUILD_DIR)/libnano.so.$(NANO_VERSION) $(STAGING_DIR)/lib
	cd $(STAGING_DIR)/lib && ln -fs libnano.so.$(NANO_VERSION) libnano.so.1
	cd $(STAGING_DIR)/lib && ln -fs libnano.so.$(NANO_VERSION) libnano.so

nano-stage: $(STAGING_DIR)/lib/libnano.so.$(NANO_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(NANO_IPK_DIR)/opt/sbin or $(NANO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NANO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NANO_IPK_DIR)/opt/etc/nano/...
# Documentation files should be installed in $(NANO_IPK_DIR)/opt/doc/nano/...
# Daemon startup scripts should be installed in $(NANO_IPK_DIR)/opt/etc/init.d/S??nano
#
# You may need to patch your application to make it use these locations.
#
#	install -d $(NANO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NANO_SOURCE_DIR)/rc.nano $(NANO_IPK_DIR)/opt/etc/init.d/SXXnano
#	install -m 644 $(NANO_SOURCE_DIR)/postinst $(NANO_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(NANO_SOURCE_DIR)/prerm $(NANO_IPK_DIR)/CONTROL/prerm
#
#
$(NANO_IPK): $(NANO_BUILD_DIR)/nano
	install -d $(NANO_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(NANO_BUILD_DIR)/nano -o $(NANO_IPK_DIR)/opt/bin/nano
	install -d $(NANO_IPK_DIR)/CONTROL
	install -m 644 $(NANO_SOURCE_DIR)/control $(NANO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NANO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nano-ipk: $(NANO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nano-clean:
	-$(MAKE) -C $(NANO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nano-dirclean:
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR) $(NANO_IPK_DIR) $(NANO_IPK)
