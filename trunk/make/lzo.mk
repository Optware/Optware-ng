###########################################################
#
# lzo
#
###########################################################

# You must replace "lzo" and "LZO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LZO_VERSION, LZO_SITE and LZO_SOURCE define
# the upstream location of the source code for the package.
# LZO_DIR is the directory which is created when the source
# archive is unpacked.
# LZO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LZO_SITE=http://www.oberhumer.com/opensource/lzo/download/
LZO_VERSION=1.08
LZO_SOURCE=lzo-$(LZO_VERSION).tar.gz
LZO_DIR=lzo-$(LZO_VERSION)
LZO_UNZIP=zcat

#
# LZO_IPK_VERSION should be incremented when the ipk changes.
#
LZO_IPK_VERSION=1

#
# LZO_CONFFILES should be a list of user-editable files
#LZO_CONFFILES=/opt/etc/lzo.conf /opt/etc/init.d/SXXlzo

#
# LZO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LZO_PATCHES=$(LZO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LZO_CPPFLAGS=
LZO_LDFLAGS=

#
# LZO_BUILD_DIR is the directory in which the build is done.
# LZO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LZO_IPK_DIR is the directory in which the ipk is built.
# LZO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LZO_BUILD_DIR=$(BUILD_DIR)/lzo
LZO_SOURCE_DIR=$(SOURCE_DIR)/lzo
LZO_IPK_DIR=$(BUILD_DIR)/lzo-$(LZO_VERSION)-ipk
LZO_IPK=$(BUILD_DIR)/lzo_$(LZO_VERSION)-$(LZO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LZO_SOURCE):
	$(WGET) -P $(DL_DIR) $(LZO_SITE)/$(LZO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lzo-source: $(DL_DIR)/$(LZO_SOURCE) $(LZO_PATCHES)

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
$(LZO_BUILD_DIR)/.configured: $(DL_DIR)/$(LZO_SOURCE) $(LZO_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LZO_DIR) $(LZO_BUILD_DIR)
	$(LZO_UNZIP) $(DL_DIR)/$(LZO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LZO_PATCHES) | patch -d $(BUILD_DIR)/$(LZO_DIR) -p1
	mv $(BUILD_DIR)/$(LZO_DIR) $(LZO_BUILD_DIR)
	(cd $(LZO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LZO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LZO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--disable-nls \
	)
	touch $(LZO_BUILD_DIR)/.configured

lzo-unpack: $(LZO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LZO_BUILD_DIR)/.built: $(LZO_BUILD_DIR)/.configured
	rm -f $(LZO_BUILD_DIR)/.built
	$(MAKE) -C $(LZO_BUILD_DIR)
	touch $(LZO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lzo: $(LZO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/liblzo.so.$(LZO_VERSION): $(LZO_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzoconf.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzoutil.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo16bit.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1.h  $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1a.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1b.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1c.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1f.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1x.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1y.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1z.h $(STAGING_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo2a.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	cd $(LZO_BUILD_DIR)/src ; /bin/sh ../libtool --mode=install install -c liblzo.la $(STAGING_DIR)/opt/lib
        # That creepy libtool won't let us set the right version number, so clean it up
        # Must be a better way than renaming the files, deleting the symlinks and recreating them


lzo-stage: $(STAGING_DIR)/opt/lib/liblzo.so.$(LZO_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(LZO_IPK_DIR)/opt/sbin or $(LZO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LZO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LZO_IPK_DIR)/opt/etc/lzo/...
# Documentation files should be installed in $(LZO_IPK_DIR)/opt/doc/lzo/...
# Daemon startup scripts should be installed in $(LZO_IPK_DIR)/opt/etc/init.d/S??lzo
#
# You may need to patch your application to make it use these locations.
#
$(LZO_IPK): $(LZO_BUILD_DIR)/.built
	rm -rf $(LZO_IPK_DIR) $(BUILD_DIR)/lzo_*_$(TARGET_ARCH).ipk
#	install -d $(LZO_IPK_DIR)/opt/bin
#	$(STRIP_COMMAND) $(LZO_BUILD_DIR)/lzo -o $(LZO_IPK_DIR)/opt/bin/lzo
	# Install include files
	install -d $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzoconf.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzoutil.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo16bit.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1a.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1b.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1c.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1f.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1x.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1y.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo1z.h $(LZO_IPK_DIR)/opt/include
	install -m 644 $(LZO_BUILD_DIR)/include/lzo2a.h $(LZO_IPK_DIR)/opt/include
	# Install lib files
	install -d $(LZO_IPK_DIR)/opt/lib
	cd $(LZO_BUILD_DIR)/src ; /bin/sh ../libtool --mode=install install -c liblzo.la $(LZO_IPK_DIR)/opt/lib
#	install -d $(LZO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LZO_SOURCE_DIR)/rc.lzo $(LZO_IPK_DIR)/opt/etc/init.d/SXXlzo
	install -d $(LZO_IPK_DIR)/CONTROL
	install -m 644 $(LZO_SOURCE_DIR)/control $(LZO_IPK_DIR)/CONTROL
#	install -m 644 $(LZO_SOURCE_DIR)/postinst $(LZO_IPK_DIR)/CONTROL
#	install -m 644 $(LZO_SOURCE_DIR)/prerm $(LZO_IPK_DIR)/CONTROL
	echo $(LZO_CONFFILES) | sed -e 's/ /\n/g' > $(LZO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LZO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lzo-ipk: $(LZO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lzo-clean:
	-$(MAKE) -C $(LZO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lzo-dirclean:
	rm -rf $(BUILD_DIR)/$(LZO_DIR) $(LZO_BUILD_DIR) $(LZO_IPK_DIR) $(LZO_IPK)
