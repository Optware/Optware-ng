###########################################################
#
# popt
#
###########################################################

# You must replace "popt" and "POPT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POPT_VERSION, POPT_SITE and POPT_SOURCE define
# the upstream location of the source code for the package.
# POPT_DIR is the directory which is created when the source
# archive is unpacked.
# POPT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
POPT_SITE=http://ftp.debian.org/debian/pool/main/p/popt
POPT_VERSION=1.7
POPT_SOURCE=popt_$(POPT_VERSION).orig.tar.gz
POPT_DIR=popt-$(POPT_VERSION)
POPT_UNZIP=zcat

#
# POPT_IPK_VERSION should be incremented when the ipk changes.
#
POPT_IPK_VERSION=1

#
# POPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# POPT_PATCHES=$(POPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POPT_CPPFLAGS=
POPT_LDFLAGS=

#
# POPT_BUILD_DIR is the directory in which the build is done.
# POPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POPT_IPK_DIR is the directory in which the ipk is built.
# POPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POPT_BUILD_DIR=$(BUILD_DIR)/popt
POPT_SOURCE_DIR=$(SOURCE_DIR)/popt
POPT_IPK_DIR=$(BUILD_DIR)/popt-$(POPT_VERSION)-ipk
POPT_IPK=$(BUILD_DIR)/popt_$(POPT_VERSION)-$(POPT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(POPT_SITE)/$(POPT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
popt-source: $(DL_DIR)/$(POPT_SOURCE) $(POPT_PATCHES)

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
$(POPT_BUILD_DIR)/.configured: $(DL_DIR)/$(POPT_SOURCE) $(POPT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR)
	$(POPT_UNZIP) $(DL_DIR)/$(POPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(POPT_PATCHES) | patch -d $(BUILD_DIR)/$(POPT_DIR) -p1
	mv $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR)
	(cd $(POPT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POPT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(POPT_BUILD_DIR)/.configured

popt-unpack: $(POPT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(POPT_BUILD_DIR)/.built: $(POPT_BUILD_DIR)/.configured
	rm -f $(POPT_BUILD_DIR)/.built
	$(MAKE) -C $(POPT_BUILD_DIR)
	touch $(POPT_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
popt: $(POPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libpopt.a: $(POPT_BUILD_DIR)/.built
	$(MAKE) -C $(POPT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-includeHEADERS install-exec-am

popt-stage: $(STAGING_DIR)/opt/lib/libpopt.a

#
# This builds the IPK file.
#
# Binaries should be installed into $(POPT_IPK_DIR)/opt/sbin or $(POPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POPT_IPK_DIR)/opt/etc/popt/...
# Documentation files should be installed in $(POPT_IPK_DIR)/opt/doc/popt/...
# Daemon startup scripts should be installed in $(POPT_IPK_DIR)/opt/etc/init.d/S??popt
#
# You may need to patch your application to make it use these locations.
#
$(POPT_IPK): $(POPT_BUILD_DIR)/.built
	rm -rf $(POPT_IPK_DIR) $(BUILD_DIR)/popt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POPT_BUILD_DIR) DESTDIR=$(POPT_IPK_DIR) install-includeHEADERS install-exec-am
	install -d $(POPT_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(POPT_VERSION)/" \
		-e "s/@RELEASE@/$(POPT_IPK_VERSION)/" $(POPT_SOURCE_DIR)/control > $(POPT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
popt-ipk: $(POPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
popt-clean:
	-$(MAKE) -C $(POPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
popt-dirclean:
	rm -rf $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR) $(POPT_IPK_DIR) $(POPT_IPK)
