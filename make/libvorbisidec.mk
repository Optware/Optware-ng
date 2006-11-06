###########################################################
#
# libvorbisidec
#
###########################################################

# You must replace "libvorbisidec" and "LIBVORBISIDEC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBVORBISIDEC_VERSION, LIBVORBISIDEC_SITE and LIBVORBISIDEC_SOURCE define
# the upstream location of the source code for the package.
# LIBVORBISIDEC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBVORBISIDEC_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBVORBISIDEC_SITE=http://nslu.sourceforge.net/downloads
LIBVORBISIDEC_VERSION=cvs-20050221
LIBVORBISIDEC_SOURCE=libvorbisidec-$(LIBVORBISIDEC_VERSION).tar.gz
LIBVORBISIDEC_DIR=libvorbisidec-$(LIBVORBISIDEC_VERSION)
LIBVORBISIDEC_UNZIP=zcat
LIBVORBISIDEC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBVORBISIDEC_DESCRIPTION=libvorbisidec is the integer-only ogg decoder library, AKA "Tremor"
LIBVORBISIDEC_SECTION=lib
LIBVORBISIDEC_PRIORITY=optional
LIBVORBISIDEC_DEPENDS=
LIBVORBISIDEC_SUGGESTS=
LIBVORBISIDEC_CONFLICTS=

#
# LIBVORBISIDEC_IPK_VERSION should be incremented when the ipk changes.
#
LIBVORBISIDEC_IPK_VERSION=2

#
# LIBVORBISIDEC_CONFFILES should be a list of user-editable files
#LIBVORBISIDEC_CONFFILES=/opt/etc/libvorbisidec.conf /opt/etc/init.d/SXXlibvorbisidec

#
# LIBVORBISIDEC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBVORBISIDEC_PATCHES=$(LIBVORBISIDEC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(TARGET_ARCH), armeb)
LIBVORBISIDEC_CPPFLAGS=-D_ARM_ASSEM_
else
LIBVORBISIDEC_CPPFLAGS=
endif
LIBVORBISIDEC_LDFLAGS=

#
# LIBVORBISIDEC_BUILD_DIR is the directory in which the build is done.
# LIBVORBISIDEC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBVORBISIDEC_IPK_DIR is the directory in which the ipk is built.
# LIBVORBISIDEC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBVORBISIDEC_BUILD_DIR=$(BUILD_DIR)/libvorbisidec
LIBVORBISIDEC_SOURCE_DIR=$(SOURCE_DIR)/libvorbisidec
LIBVORBISIDEC_IPK_DIR=$(BUILD_DIR)/libvorbisidec-$(LIBVORBISIDEC_VERSION)-ipk
LIBVORBISIDEC_IPK=$(BUILD_DIR)/libvorbisidec_$(LIBVORBISIDEC_VERSION)-$(LIBVORBISIDEC_IPK_VERSION)_${TARGET_ARCH}.ipk

.PHONY: libvorbisidec-source libvorbisidec-unpack libvorbisidec libvorbisidec-stage libvorbisidec-ipk libvorbisidec-clean libvorbisidec-dirclean libvorbisidec-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBVORBISIDEC_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVORBISIDEC_SITE)/$(LIBVORBISIDEC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libvorbisidec-source: $(DL_DIR)/$(LIBVORBISIDEC_SOURCE) $(LIBVORBISIDEC_PATCHES)

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
$(LIBVORBISIDEC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBVORBISIDEC_SOURCE) $(LIBVORBISIDEC_PATCHES) make/libvorbisidec.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBVORBISIDEC_DIR) $(LIBVORBISIDEC_BUILD_DIR)
	$(LIBVORBISIDEC_UNZIP) $(DL_DIR)/$(LIBVORBISIDEC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBVORBISIDEC_PATCHES) | patch -d $(BUILD_DIR)/$(LIBVORBISIDEC_DIR) -p1
	mv $(BUILD_DIR)/$(LIBVORBISIDEC_DIR) $(LIBVORBISIDEC_BUILD_DIR)
	(cd $(LIBVORBISIDEC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBVORBISIDEC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBISIDEC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(LIBVORBISIDEC_BUILD_DIR)/libtool
	touch $(LIBVORBISIDEC_BUILD_DIR)/.configured

libvorbisidec-unpack: $(LIBVORBISIDEC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBVORBISIDEC_BUILD_DIR)/.built: $(LIBVORBISIDEC_BUILD_DIR)/.configured
	rm -f $(LIBVORBISIDEC_BUILD_DIR)/.built
	$(MAKE) -C $(LIBVORBISIDEC_BUILD_DIR)
	touch $(LIBVORBISIDEC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libvorbisidec: $(LIBVORBISIDEC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBVORBISIDEC_BUILD_DIR)/.staged: $(LIBVORBISIDEC_BUILD_DIR)/.built
	rm -f $(LIBVORBISIDEC_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBVORBISIDEC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libvorbisidec.la
	touch $(LIBVORBISIDEC_BUILD_DIR)/.staged

libvorbisidec-stage: $(LIBVORBISIDEC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(LIBVORBISIDEC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libvorbisidec" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBVORBISIDEC_PRIORITY)" >>$@
	@echo "Section: $(LIBVORBISIDEC_SECTION)" >>$@
	@echo "Version: $(LIBVORBISIDEC_VERSION)-$(LIBVORBISIDEC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBVORBISIDEC_MAINTAINER)" >>$@
	@echo "Source: $(LIBVORBISIDEC_SITE)/$(LIBVORBISIDEC_SOURCE)" >>$@
	@echo "Description: $(LIBVORBISIDEC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBVORBISIDEC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBVORBISIDEC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBVORBISIDEC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBVORBISIDEC_IPK_DIR)/opt/sbin or $(LIBVORBISIDEC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBVORBISIDEC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBVORBISIDEC_IPK_DIR)/opt/etc/libvorbisidec/...
# Documentation files should be installed in $(LIBVORBISIDEC_IPK_DIR)/opt/doc/libvorbisidec/...
# Daemon startup scripts should be installed in $(LIBVORBISIDEC_IPK_DIR)/opt/etc/init.d/S??libvorbisidec
#
# You may need to patch your application to make it use these locations.
#
$(LIBVORBISIDEC_IPK): $(LIBVORBISIDEC_BUILD_DIR)/.built
	rm -rf $(LIBVORBISIDEC_IPK_DIR) $(BUILD_DIR)/libvorbisidec_*_${TARGET_ARCH}.ipk
	$(MAKE) -C $(LIBVORBISIDEC_BUILD_DIR) DESTDIR=$(LIBVORBISIDEC_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBVORBISIDEC_IPK_DIR)/opt/lib/libvorbisidec.so.*.*.*
	rm -f $(LIBVORBISIDEC_IPK_DIR)/opt/lib/libvorbisidec.a
	$(MAKE) $(LIBVORBISIDEC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBVORBISIDEC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libvorbisidec-ipk: $(LIBVORBISIDEC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libvorbisidec-clean:
	-$(MAKE) -C $(LIBVORBISIDEC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libvorbisidec-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBVORBISIDEC_DIR) $(LIBVORBISIDEC_BUILD_DIR) $(LIBVORBISIDEC_IPK_DIR) $(LIBVORBISIDEC_IPK)

#
#
# Some sanity check for the package.
#
libvorbisidec-check: $(LIBVORBISIDEC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBVORBISIDEC_IPK)
