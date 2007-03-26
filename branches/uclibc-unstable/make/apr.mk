###########################################################
#
# apr
#
###########################################################

#
# APR_VERSION, APR_SITE and APR_SOURCE define
# the upstream location of the source code for the package.
# APR_DIR is the directory which is created when the source
# archive is unpacked.
# APR_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
APR_SITE=http://www.apache.org/dist/apr
APR_VERSION=1.2.8
APR_SOURCE=apr-$(APR_VERSION).tar.bz2
APR_DIR=apr-$(APR_VERSION)
APR_UNZIP=bzcat
APR_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
APR_DESCRIPTION=Apache Portable Runtime library
APR_SECTION=lib
APR_PRIORITY=optional
APR_DEPENDS=

#
# APR_IPK_VERSION should be incremented when the ipk changes.
#
APR_IPK_VERSION=1

#
# APR_LOCALES defines which locales get installed
#
APR_LOCALES=

#
# APR_CONFFILES should be a list of user-editable files
#APR_CONFFILES=/opt/etc/apr.conf /opt/etc/init.d/SXXapr

#
# APR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#APR_PATCHES=$(APR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APR_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/apache2
APR_LDFLAGS=-lpthread

#
# APR_BUILD_DIR is the directory in which the build is done.
# APR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APR_IPK_DIR is the directory in which the ipk is built.
# APR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APR_BUILD_DIR=$(BUILD_DIR)/apr
APR_SOURCE_DIR=$(SOURCE_DIR)/apr
APR_IPK_DIR=$(BUILD_DIR)/apr-$(APR_VERSION)-ipk
APR_IPK=$(BUILD_DIR)/apr_$(APR_VERSION)-$(APR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: apr-source apr-unpack apr apr-stage apr-ipk apr-clean apr-dirclean apr-check

#
# Automatically create a ipkg control file
#
$(APR_IPK_DIR)/CONTROL/control:
	@install -d $(APR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: apr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APR_PRIORITY)" >>$@
	@echo "Section: $(APR_SECTION)" >>$@
	@echo "Version: $(APR_VERSION)-$(APR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APR_MAINTAINER)" >>$@
	@echo "Source: $(APR_SITE)/$(APR_SOURCE)" >>$@
	@echo "Description: $(APR_DESCRIPTION)" >>$@
	@echo "Depends: $(APR_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(APR_SOURCE):
	$(WGET) -P $(DL_DIR) $(APR_SITE)/$(APR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
apr-source: $(DL_DIR)/$(APR_SOURCE) $(APR_PATCHES)

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
$(APR_BUILD_DIR)/.configured: $(DL_DIR)/$(APR_SOURCE) $(APR_PATCHES) make/apr.mk
	rm -rf $(BUILD_DIR)/$(APR_DIR) $(APR_BUILD_DIR)
	$(APR_UNZIP) $(DL_DIR)/$(APR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(APR_DIR) $(APR_BUILD_DIR)
	(cd $(APR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APR_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		ac_cv_sizeof_size_t=4 \
		ac_cv_sizeof_ssize_t=4 \
		ac_cv_sizeof_off_t=4 \
		ac_cv_sizeof_pid_t=4 \
		apr_cv_process_shared_works=no \
		ac_cv_file__dev_zero=yes \
		apr_cv_tcp_nodelay_with_cork=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(STAGING_DIR)/opt \
		--libdir=/opt/lib \
		--disable-static \
		--enable-layout=GNU \
	)
	$(PATCH_LIBTOOL) $(APR_BUILD_DIR)/libtool
	touch $(APR_BUILD_DIR)/.configured

apr-unpack: $(APR_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(APR_BUILD_DIR)/.built: $(APR_BUILD_DIR)/.configured
	rm -f $(APR_BUILD_DIR)/.built
	rm -f $(STAGING_INCLUDE_DIR)/apache2/apr*.h
	$(MAKE) -C $(APR_BUILD_DIR)
	touch $(APR_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
apr: $(APR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(APR_BUILD_DIR)/.staged: $(APR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(APR_BUILD_DIR) install libdir=$(STAGING_PREFIX)/lib
	rm -f $(STAGING_PREFIX)/lib/libapr.la
	sed -i -e 's/location=build/location=installed/' $(STAGING_PREFIX)/bin/apr-1-config
	touch $@

apr-stage: $(APR_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(APR_IPK_DIR)/opt/sbin or $(APR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APR_IPK_DIR)/opt/etc/apr/...
# Documentation files should be installed in $(APR_IPK_DIR)/opt/doc/apr/...
# Daemon startup scripts should be installed in $(APR_IPK_DIR)/opt/etc/init.d/S??apr
#
# You may need to patch your application to make it use these locations.
#
$(APR_IPK): $(APR_BUILD_DIR)/.staged
	rm -rf $(APR_IPK_DIR) $(BUILD_DIR)/apr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(APR_BUILD_DIR) DESTDIR=$(APR_IPK_DIR) libdir=/opt/lib prefix=/delete-me install
	rm -rf $(APR_IPK_DIR)/delete-me
	rm -f $(APR_IPK_DIR)/opt/lib/*.la
	$(TARGET_STRIP) $(APR_IPK_DIR)/opt/lib/*.so.[0-9]*.[0-9]*.[0-9]*
	$(MAKE) $(APR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
apr-ipk: $(APR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
apr-clean:
	-$(MAKE) -C $(APR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
apr-dirclean:
	rm -rf $(BUILD_DIR)/$(APR_DIR) $(APR_BUILD_DIR) $(APR_IPK_DIR) $(APR_IPK)

#
# Some sanity check for the package.
#
apr-check: $(APR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(APR_IPK)
