###########################################################
#
# expat
#
###########################################################

#
# EXPAT_VERSION, EXPAT_SITE and EXPAT_SOURCE define
# the upstream location of the source code for the package.
# EXPAT_DIR is the directory which is created when the source
# archive is unpacked.
# EXPAT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
EXPAT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/expat
EXPAT_VERSION=2.0.1
EXPAT_SOURCE=expat-$(EXPAT_VERSION).tar.gz
EXPAT_DIR=expat-$(EXPAT_VERSION)
EXPAT_UNZIP=zcat
EXPAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EXPAT_DESCRIPTION=XML Parser library
EXPAT_SECTION=libraries
EXPAT_PRIORITY=optional
EXPAT_DEPENDS=
EXPAT_CONFLICTS=

#
# EXPAT_IPK_VERSION should be incremented when the ipk changes.
#
EXPAT_IPK_VERSION=1

#
# EXPAT_CONFFILES should be a list of user-editable files
EXPAT_CONFFILES=

#
# EXPAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EXPAT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXPAT_CPPFLAGS=
EXPAT_LDFLAGS=

#
# EXPAT_BUILD_DIR is the directory in which the build is done.
# EXPAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXPAT_IPK_DIR is the directory in which the ipk is built.
# EXPAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXPAT_BUILD_DIR=$(BUILD_DIR)/expat
EXPAT_SOURCE_DIR=$(SOURCE_DIR)/expat
EXPAT_IPK_DIR=$(BUILD_DIR)/expat-$(EXPAT_VERSION)-ipk
EXPAT_IPK=$(BUILD_DIR)/expat_$(EXPAT_VERSION)-$(EXPAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: expat-source expat-unpack expat expat-stage expat-ipk expat-clean expat-dirclean expat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EXPAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(EXPAT_SITE)/$(EXPAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
expat-source: $(DL_DIR)/$(EXPAT_SOURCE) $(EXPAT_PATCHES)

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
$(EXPAT_BUILD_DIR)/.configured: $(DL_DIR)/$(EXPAT_SOURCE) $(EXPAT_PATCHES) make/expat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR)
	$(EXPAT_UNZIP) $(DL_DIR)/$(EXPAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(EXPAT_PATCHES) | patch -d $(BUILD_DIR)/$(EXPAT_DIR) -p1
	mv $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR)
	(cd $(EXPAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXPAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXPAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-static \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(EXPAT_BUILD_DIR)/libtool
	touch $(EXPAT_BUILD_DIR)/.configured


expat-unpack: $(EXPAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EXPAT_BUILD_DIR)/.built: $(EXPAT_BUILD_DIR)/.configured
	rm -f $(EXPAT_BUILD_DIR)/.built
	$(MAKE) -C $(EXPAT_BUILD_DIR)
	touch $(EXPAT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
expat: $(EXPAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EXPAT_BUILD_DIR)/.staged: $(EXPAT_BUILD_DIR)/.built
	rm -f $(EXPAT_BUILD_DIR)/.staged
	mkdir -p $(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR)
	(cd $(EXPAT_BUILD_DIR); \
		./libtool --mode=install install -c libexpat.la $(STAGING_LIB_DIR)/libexpat.la ; \
		install -c -m 644 ./lib/expat.h ./lib/expat_external.h $(STAGING_INCLUDE_DIR) ; \
	)
	sed -i -e 's%$(STAGING_DIR)%%' $(STAGING_DIR)/opt/lib/libexpat.la
	touch $(EXPAT_BUILD_DIR)/.staged

expat-stage: $(EXPAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/expat
#
$(EXPAT_IPK_DIR)/CONTROL/control:
	@install -d $(EXPAT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: expat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EXPAT_PRIORITY)" >>$@
	@echo "Section: $(EXPAT_SECTION)" >>$@
	@echo "Version: $(EXPAT_VERSION)-$(EXPAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EXPAT_MAINTAINER)" >>$@
	@echo "Source: $(EXPAT_SITE)/$(EXPAT_SOURCE)" >>$@
	@echo "Description: $(EXPAT_DESCRIPTION)" >>$@
	@echo "Depends: $(EXPAT_DEPENDS)" >>$@
	@echo "Conflicts: $(EXPAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXPAT_IPK_DIR)/opt/sbin or $(EXPAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXPAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EXPAT_IPK_DIR)/opt/etc/expat/...
# Documentation files should be installed in $(EXPAT_IPK_DIR)/opt/doc/expat/...
# Daemon startup scripts should be installed in $(EXPAT_IPK_DIR)/opt/etc/init.d/S??expat
#
# You may need to patch your application to make it use these locations.
#
$(EXPAT_IPK): $(EXPAT_BUILD_DIR)/.built
	rm -rf $(EXPAT_IPK_DIR) $(BUILD_DIR)/expat_*_$(TARGET_ARCH).ipk
	install -d $(EXPAT_IPK_DIR)/opt/lib $(EXPAT_IPK_DIR)/opt/include
	(cd $(EXPAT_BUILD_DIR); \
		./libtool --mode=install install -c libexpat.la $(EXPAT_IPK_DIR)/opt/lib/libexpat.la ; \
		install -c -m 644 ./lib/expat.h ./lib/expat_external.h $(EXPAT_IPK_DIR)/opt/include ; \
	)
	$(STRIP_COMMAND) $(EXPAT_IPK_DIR)/opt/lib/libexpat.so
	# avoid problems with libtool later
	rm -f $(EXPAT_IPK_DIR)/opt/lib/libexpat.la
	$(MAKE) $(EXPAT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXPAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
expat-ipk: $(EXPAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
expat-clean:
	-$(MAKE) -C $(EXPAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
expat-dirclean:
	rm -rf $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR) $(EXPAT_IPK_DIR) $(EXPAT_IPK)

#
# Some sanity check for the package.
#
expat-check: $(EXPAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(EXPAT_IPK)
