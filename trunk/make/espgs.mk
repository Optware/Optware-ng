###########################################################
#
# espgs
#
###########################################################

# You must replace "espgs" and "ESPGS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ESPGS_VERSION, ESPGS_SITE and ESPGS_SOURCE define
# the upstream location of the source code for the package.
# ESPGS_DIR is the directory which is created when the source
# archive is unpacked.
# ESPGS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ESPGS_SITE=http://ftp.easysw.com/pub/ghostscript/test
ESPGS_VERSION=8.15rc2
ESPGS_SOURCE=espgs-$(ESPGS_VERSION)-source.tar.bz2
ESPGS_DIR=espgs-$(ESPGS_VERSION)
ESPGS_UNZIP=bzcat

#
# ESPGS_IPK_VERSION should be incremented when the ipk changes.
#
ESPGS_IPK_VERSION=1

#
# ESPGS_CONFFILES should be a list of user-editable files
ESPGS_CONFFILES=/opt/etc/espgs.conf /opt/etc/init.d/SXXespgs
PATH=$(TARGET_PATH)

#
## ESPGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ESPGS_PATCHES=$(ESPGS_SOURCE_DIR)/patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ESPGS_CPPFLAGS=
ESPGS_LDFLAGS=

#
# ESPGS_BUILD_DIR is the directory in which the build is done.
# ESPGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ESPGS_IPK_DIR is the directory in which the ipk is built.
# ESPGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ESPGS_BUILD_DIR=$(BUILD_DIR)/espgs
ESPGS_SOURCE_DIR=$(SOURCE_DIR)/espgs
ESPGS_IPK_DIR=$(BUILD_DIR)/espgs-$(ESPGS_VERSION)-ipk
ESPGS_IPK=$(BUILD_DIR)/espgs_$(ESPGS_VERSION)-$(ESPGS_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ESPGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ESPGS_SITE)/$(ESPGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#espgs-source: $(DL_DIR)/$(ESPGS_SOURCE) $(ESPGS_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(ESPGS_BUILD_DIR)/.configured: $(DL_DIR)/$(ESPGS_SOURCE) $(ESPGS_PATCHES)
	$(MAKE) libjpeg-stage zlib-stage libpng-stage libtiff-stage cups-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR)
	$(ESPGS_UNZIP) $(DL_DIR)/$(ESPGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ESPGS_PATCHES) | patch -d $(BUILD_DIR)/$(ESPGS_DIR) -p1
	mv $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR)
	(cd $(ESPGS_BUILD_DIR); \
		ln -s src/unix-gcc.mak Makefile ; \
		mkdir obj; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESPGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESPGS_LDFLAGS)" \
		$(MAKE) obj/arch.h ; \
		cp obj/arch.h obj/arch.h.orig; \
		cp $(ESPGS_SOURCE_DIR)/arch.h obj/arch.h; \
		$(MAKE) obj/genconf obj/echogs; \
		ln -s ../../builds/libjpeg jpeg; \
		ln -s ../../builds/zlib zlib; \
		ln -s ../../builds/libpng libpng; \
	)
	touch $(ESPGS_BUILD_DIR)/.configured

espgs-unpack: $(ESPGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ESPGS_BUILD_DIR)/.built: $(ESPGS_BUILD_DIR)/.configured
	rm -f $(ESPGS_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
        CPPFLAGS="$(STAGING_CPPFLAGS) $(ESPGS_CPPFLAGS)" \
        LDFLAGS="$(STAGING_LDFLAGS) $(ESPGS_LDFLAGS)" \
	$(MAKE) prefix=/opt CC=$(TARGET_CC) CCFLAGS=-I$(STAGING_INCLUDE_DIR) LD=$(TARGET_LD) -C $(ESPGS_BUILD_DIR)
	touch $(ESPGS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
espgs: $(ESPGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ESPGS_BUILD_DIR)/.staged: $(ESPGS_BUILD_DIR)/.built
	rm -f $(ESPGS_BUILD_DIR)/.staged
	$(MAKE) -C $(ESPGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ESPGS_BUILD_DIR)/.staged

espgs-stage: $(ESPGS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ESPGS_IPK_DIR)/opt/sbin or $(ESPGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ESPGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ESPGS_IPK_DIR)/opt/etc/espgs/...
# Documentation files should be installed in $(ESPGS_IPK_DIR)/opt/doc/espgs/...
# Daemon startup scripts should be installed in $(ESPGS_IPK_DIR)/opt/etc/init.d/S??espgs
#
# You may need to patch your application to make it use these locations.
#
$(ESPGS_IPK): $(ESPGS_BUILD_DIR)/.built
	rm -rf $(ESPGS_IPK_DIR) $(BUILD_DIR)/espgs_*_armeb.ipk
	cat $(ESPGS_BUILD_DIR)/pstoraster/pstopxl.in | sed 's/@bindir@/\/opt\/bin/g' | sed 's/@prefix@/\/opt/g'| sed 's/@exec_prefix@/\/opt/g' |sed 's/@GS_VERSION_MAJOR@/8/g'|  sed 's/@GS_VERSION_MINOR@/15/g' |  sed 's/@GS_VERSION_PATCH@//g' |  sed 's/@GS@/gs/g' > $(ESPGS_BUILD_DIR)/pstoraster/pstopxl
	cat $(ESPGS_BUILD_DIR)/pstoraster/pstoraster.in | sed 's/@bindir@/\/opt\/bin/g' | sed 's/@prefix@/\/opt/g'| sed 's/@exec_prefix@/\/opt/g' |sed 's/@GS_VERSION_MAJOR@/8/g'|  sed 's/@GS_VERSION_MINOR@/15/g' |  sed 's/@GS_VERSION_PATCH@//g' |  sed 's/@GS@/gs/g' > $(ESPGS_BUILD_DIR)/pstoraster/pstoraster
	$(MAKE) -C $(ESPGS_BUILD_DIR) install_prefix=$(ESPGS_IPK_DIR) prefix=$(ESPGS_IPK_DIR)/opt DESTDIR=$(ESPGS_IPK_DIR) install
	install -d $(ESPGS_IPK_DIR)/CONTROL
	install -m 644 $(ESPGS_SOURCE_DIR)/control $(ESPGS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ESPGS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
espgs-ipk: $(ESPGS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
espgs-clean:
	-$(MAKE) -C $(ESPGS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
espgs-dirclean:
	rm -rf $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR) $(ESPGS_IPK_DIR) $(ESPGS_IPK)
