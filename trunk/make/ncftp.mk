###########################################################
#
# ncftp
#
###########################################################

# You must replace "ncftp" and "NCFTP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NCFTP_VERSION, NCFTP_SITE and NCFTP_SOURCE define
# the upstream location of the source code for the package.
# NCFTP_DIR is the directory which is created when the source
# archive is unpacked.
# NCFTP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NCFTP_SITE=ftp://ftp.ncftp.com/ncftp
NCFTP_VERSION=3.1.8
NCFTP_SOURCE=ncftp-$(NCFTP_VERSION)-src.tar.gz
NCFTP_DIR=ncftp-$(NCFTP_VERSION)
NCFTP_UNZIP=zcat

#
# NCFTP_IPK_VERSION should be incremented when the ipk changes.
#
NCFTP_IPK_VERSION=2

#
# NCFTP_CONFFILES should be a list of user-editable files
NCFTP_CONFFILES=
#/opt/etc/ncftp.conf /opt/etc/init.d/SXXncftp

#
# NCFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NCFTP_PATCHES=$(NCFTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NCFTP_CPPFLAGS=
NCFTP_LDFLAGS=

#
# NCFTP_BUILD_DIR is the directory in which the build is done.
# NCFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NCFTP_IPK_DIR is the directory in which the ipk is built.
# NCFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NCFTP_BUILD_DIR=$(BUILD_DIR)/ncftp
NCFTP_SOURCE_DIR=$(SOURCE_DIR)/ncftp
NCFTP_IPK_DIR=$(BUILD_DIR)/ncftp-$(NCFTP_VERSION)-ipk
NCFTP_IPK=$(BUILD_DIR)/ncftp_$(NCFTP_VERSION)-$(NCFTP_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NCFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NCFTP_SITE)/$(NCFTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ncftp-source: $(DL_DIR)/$(NCFTP_SOURCE) $(NCFTP_PATCHES)

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
$(NCFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(NCFTP_SOURCE) $(NCFTP_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NCFTP_DIR) $(NCFTP_BUILD_DIR)
	$(NCFTP_UNZIP) $(DL_DIR)/$(NCFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NCFTP_PATCHES) | patch -d $(BUILD_DIR)/$(NCFTP_DIR) -p1
	mv $(BUILD_DIR)/$(NCFTP_DIR) $(NCFTP_BUILD_DIR)
	(cd $(NCFTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NCFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NCFTP_LDFLAGS)" \
                ac_cv_func_setpgrp_void=yes \
                ac_cv_func_setvbuf_reversed=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--bindir=/opt/bin \
		--mandir=/opt/man \
		--prefix=opt \
		--disable-nls \
	)
	touch $(NCFTP_BUILD_DIR)/.configured

ncftp-unpack: $(NCFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NCFTP_BUILD_DIR)/.built: $(NCFTP_BUILD_DIR)/.configured
	rm -f $(NCFTP_BUILD_DIR)/.built
	$(MAKE) -C $(NCFTP_BUILD_DIR)
	touch $(NCFTP_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ncftp: $(NCFTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libncftp.so.$(NCFTP_VERSION): $(NCFTP_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(NCFTP_BUILD_DIR)/ncftp.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(NCFTP_BUILD_DIR)/libncftp.a $(STAGING_DIR)/opt/lib
	install -m 644 $(NCFTP_BUILD_DIR)/libncftp.so.$(NCFTP_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libncftp.so.$(NCFTP_VERSION) libncftp.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libncftp.so.$(NCFTP_VERSION) libncftp.so

ncftp-stage: $(STAGING_DIR)/opt/lib/libncftp.so.$(NCFTP_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(NCFTP_IPK_DIR)/opt/sbin or $(NCFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NCFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NCFTP_IPK_DIR)/opt/etc/ncftp/...
# Documentation files should be installed in $(NCFTP_IPK_DIR)/opt/doc/ncftp/...
# Daemon startup scripts should be installed in $(NCFTP_IPK_DIR)/opt/etc/init.d/S??ncftp
#
# You may need to patch your application to make it use these locations.
#
$(NCFTP_IPK): $(NCFTP_BUILD_DIR)/.built
	rm -rf $(NCFTP_IPK_DIR) $(BUILD_DIR)/ncftp_*_armeb.ipk
	install -d $(NCFTP_IPK_DIR)/opt/bin
	$(MAKE) -C $(NCFTP_BUILD_DIR) BINDIR=$(NCFTP_IPK_DIR)/opt/bin \
		mandir=$(NCFTP_IPK_DIR)/opt/man \
		 prefix=$(NCFTP_IPK_DIR) install
	install -d $(NCFTP_IPK_DIR)/opt/etc/init.d
	install -d $(NCFTP_IPK_DIR)/CONTROL
	install -m 644 $(NCFTP_SOURCE_DIR)/control $(NCFTP_IPK_DIR)/CONTROL/control
#	install -m 644 $(NCFTP_SOURCE_DIR)/postinst $(NCFTP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ncftp-ipk: $(NCFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ncftp-clean:
	-$(MAKE) -C $(NCFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ncftp-dirclean:
	rm -rf $(BUILD_DIR)/$(NCFTP_DIR) $(NCFTP_BUILD_DIR) $(NCFTP_IPK_DIR) $(NCFTP_IPK)
