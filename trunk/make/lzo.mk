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
LZO_NAME=lzo
LZO_SITE=http://www.oberhumer.com/opensource/lzo/download
LZO_VERSION=2.03
LZO_SOURCE=$(LZO_NAME)-$(LZO_VERSION).tar.gz
LZO_DIR=$(LZO_NAME)-$(LZO_VERSION)
LZO_UNZIP=zcat

#
# LZO_IPK_VERSION should be incremented when the ipk changes.
#
LZO_IPK_VERSION=1

#
# Control file info
#
LZO_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
LZO_DESCRIPTION=Compression library
LZO_SECTION=lib
LZO_PRIORITY=optional
LZO_CONFLICTS=
LZO_DEPENDS=

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
# Automatically create a ipkg control file
#
$(LZO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(LZO_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LZO_PRIORITY)" >>$@
	@echo "Section: $(LZO_SECTION)" >>$@
	@echo "Version: $(LZO_VERSION)-$(LZO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LZO_MAINTAINER)" >>$@
	@echo "Source: $(LZO_SITE)/$(LZO_SOURCE)" >>$@
	@echo "Description: $(LZO_DESCRIPTION)" >>$@
	@echo "Depends: $(LZO_DEPENDS)" >>$@
	@echo "Conflicts: $(LZO_CONFLICTS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LZO_SOURCE):
	$(WGET) -P $(@D) $(LZO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(LZO_BUILD_DIR)/.configured: $(DL_DIR)/$(LZO_SOURCE) $(LZO_PATCHES) make/lzo.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LZO_DIR) $(@D)
	$(LZO_UNZIP) $(DL_DIR)/$(LZO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LZO_PATCHES) | patch -d $(BUILD_DIR)/$(LZO_DIR) -p1
	mv $(BUILD_DIR)/$(LZO_DIR) $(@D)
	(cd $(@D); \
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
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

lzo-unpack: $(LZO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LZO_BUILD_DIR)/.built: $(LZO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
lzo: $(LZO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LZO_BUILD_DIR)/.staged: $(LZO_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_INCLUDE_DIR)/lzo* $(STAGING_LIB_DIR)/liblzo*
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/liblzo2.a $(STAGING_LIB_DIR)/liblzo2.la
	touch $@

lzo-stage: $(LZO_BUILD_DIR)/.staged

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
	$(MAKE) -C $(LZO_BUILD_DIR) DESTDIR=$(LZO_IPK_DIR) install-strip
	rm -f $(LZO_IPK_DIR)/opt/lib/liblzo2.a
	# Install control file
	make  $(LZO_IPK_DIR)/CONTROL/control
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

#
# Some sanity check for the package.
#
lzo-check: $(LZO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
