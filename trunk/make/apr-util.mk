###########################################################
#
# apr-util
#
###########################################################

#
# APR_UTIL_VERSION, APR_UTIL_SITE and APR_UTIL_SOURCE define
# the upstream location of the source code for the package.
# APR_UTIL_DIR is the directory which is created when the source
# archive is unpacked.
# APR_UTIL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
APR_UTIL_SITE=http://www.apache.org/dist/apr
APR_UTIL_VERSION=1.2.8
APR_UTIL_SOURCE=apr-util-$(APR_UTIL_VERSION).tar.bz2
APR_UTIL_DIR=apr-util-$(APR_UTIL_VERSION)
APR_UTIL_UNZIP=bzcat
APR_UTIL_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
APR_UTIL_DESCRIPTION=Apache Portable Runtime utilities library
APR_UTIL_SECTION=lib
APR_UTIL_PRIORITY=optional
APR_UTIL_DEPENDS=apr (>= $(APR_UTIL_VERSION)), gdbm, expat, libdb $(APR_UTIL_TARGET_DEPENDS)

#
# APR_UTIL_IPK_VERSION should be incremented when the ipk changes.
#
APR_UTIL_IPK_VERSION=2

#
# APR_UTIL_LOCALES defines which locales get installed
#
APR_UTIL_LOCALES=

ifeq (openldap, $(filter openldap, $(PACKAGES)))
APR_UTIL_CONFIGURE_TARGET_ARGS= \
		--with-ldap-library=$(STAGING_LIB_DIR) \
		--with-ldap-include=$(STAGING_INCLUDE_DIR) \
		--with-ldap
APR_UTIL_TARGET_DEPENDS=, openldap-libs
else
APR_UTIL_CONFIGURE_TARGET_ARGS=
APR_UTIL_TARGET_DEPENDS=
endif

#
# APR_UTIL_CONFFILES should be a list of user-editable files
#APR_UTIL_CONFFILES=/opt/etc/apr-util.conf /opt/etc/init.d/SXXapr-util

#
# APR_UTIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
APR_UTIL_PATCHES=$(APR_UTIL_SOURCE_DIR)/dbm-detect.patch
# $(APR_UTIL_SOURCE_DIR)/hostcc.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APR_UTIL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/apache2
APR_UTIL_LDFLAGS=-Wl,-rpath-link=$(STAGING_LIB_DIR)

#
# APR_UTIL_BUILD_DIR is the directory in which the build is done.
# APR_UTIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APR_UTIL_IPK_DIR is the directory in which the ipk is built.
# APR_UTIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APR_UTIL_BUILD_DIR=$(BUILD_DIR)/apr-util
APR_UTIL_SOURCE_DIR=$(SOURCE_DIR)/apr-util
APR_UTIL_IPK_DIR=$(BUILD_DIR)/apr-util-$(APR_UTIL_VERSION)-ipk
APR_UTIL_IPK=$(BUILD_DIR)/apr-util_$(APR_UTIL_VERSION)-$(APR_UTIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: apr-util-source apr-util-unpack apr-util apr-util-stage apr-util-ipk apr-util-clean apr-util-dirclean apr-util-check

#
# Automatically create a ipkg control file
#
$(APR_UTIL_IPK_DIR)/CONTROL/control:
	@install -d $(APR_UTIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: apr-util" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APR_UTIL_PRIORITY)" >>$@
	@echo "Section: $(APR_UTIL_SECTION)" >>$@
	@echo "Version: $(APR_UTIL_VERSION)-$(APR_UTIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APR_UTIL_MAINTAINER)" >>$@
	@echo "Source: $(APR_UTIL_SITE)/$(APR_UTIL_SOURCE)" >>$@
	@echo "Description: $(APR_UTIL_DESCRIPTION)" >>$@
	@echo "Depends: $(APR_UTIL_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(APR_UTIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(APR_UTIL_SITE)/$(APR_UTIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
apr-util-source: $(DL_DIR)/$(APR_UTIL_SOURCE) $(APR_UTIL_PATCHES)

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
$(APR_UTIL_BUILD_DIR)/.configured: $(DL_DIR)/$(APR_UTIL_SOURCE) $(APR_UTIL_PATCHES) make/apr-util.mk
	$(MAKE) gdbm-stage
	$(MAKE) libdb-stage
	$(MAKE) expat-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
	$(MAKE) apr-stage
	rm -rf $(BUILD_DIR)/$(APR_UTIL_DIR) $(APR_UTIL_BUILD_DIR)
	$(APR_UTIL_UNZIP) $(DL_DIR)/$(APR_UTIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(APR_UTIL_DIR) $(APR_UTIL_BUILD_DIR)
	cat $(APR_UTIL_PATCHES) |patch -p0 -d$(APR_UTIL_BUILD_DIR)
	(cd $(APR_UTIL_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APR_UTIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APR_UTIL_LDFLAGS)" \
		ac_cv_file_dbd_apr_dbd_mysql_c=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(STAGING_DIR)/opt \
		--libdir=/opt/lib \
		--disable-static \
		--enable-layout=GNU \
		--with-apr=$(STAGING_DIR)/opt \
		--with-gdbm=$(STAGING_DIR)/opt \
		--with-expat=$(STAGING_DIR)/opt \
		--without-mysql \
		--without-pgsql \
		--without-sqlite2 \
		--without-sqlite3 \
		$(APR_UTIL_CONFIGURE_TARGET_ARGS) \
	)
	mkdir -p $(APR_UTIL_BUILD_DIR)/build
	cp $(STAGING_DIR)/opt/share/apache2/build-1/apr_rules.mk $(APR_UTIL_BUILD_DIR)/build/rules.mk
#	sed -ie '/pgsql/d;' $(APR_UTIL_BUILD_DIR)/build-outputs.mk
	touch $(APR_UTIL_BUILD_DIR)/.configured

apr-util-unpack: $(APR_UTIL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(APR_UTIL_BUILD_DIR)/.built: $(APR_UTIL_BUILD_DIR)/.configured
	rm -f $(APR_UTIL_BUILD_DIR)/.built
	$(MAKE) -C $(APR_UTIL_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $(APR_UTIL_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
apr-util: $(APR_UTIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(APR_UTIL_BUILD_DIR)/.staged: $(APR_UTIL_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_INCLUDE_DIR)/apache2/apu*.h
	$(MAKE) -C $(APR_UTIL_BUILD_DIR) install libdir=$(STAGING_PREFIX)/lib
	rm -f $(STAGING_PREFIX)/lib/libaprutil.la
	sed -i -e 's/location=build/location=installed/' $(STAGING_PREFIX)/bin/apu-1-config
	rm -f $(STAGING_PREFIX)/bin/apu-config
#	ln -s apu-1-config $(STAGING_PREFIX)/bin/apu-config
	touch $@

apr-util-stage: $(APR_UTIL_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(APR_UTIL_IPK_DIR)/opt/sbin or $(APR_UTIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APR_UTIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APR_UTIL_IPK_DIR)/opt/etc/apr-util/...
# Documentation files should be installed in $(APR_UTIL_IPK_DIR)/opt/doc/apr-util/...
# Daemon startup scripts should be installed in $(APR_UTIL_IPK_DIR)/opt/etc/init.d/S??apr-util
#
# You may need to patch your application to make it use these locations.
#
$(APR_UTIL_IPK): $(APR_UTIL_BUILD_DIR)/.staged
	rm -rf $(APR_UTIL_IPK_DIR) $(BUILD_DIR)/apr-util_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(APR_UTIL_BUILD_DIR) DESTDIR=$(APR_UTIL_IPK_DIR) libdir=/opt/lib prefix=/delete-me install
	rm -rf $(APR_UTIL_IPK_DIR)/delete-me
	rm -f $(APR_UTIL_IPK_DIR)/opt/lib/*.la
	$(TARGET_STRIP) $(APR_UTIL_IPK_DIR)/opt/lib/*.so.[0-9]*.[0-9]*.[0-9]*
	$(MAKE) $(APR_UTIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APR_UTIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
apr-util-ipk: $(APR_UTIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
apr-util-clean:
	-$(MAKE) -C $(APR_UTIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
apr-util-dirclean:
	rm -rf $(BUILD_DIR)/$(APR_UTIL_DIR) $(APR_UTIL_BUILD_DIR) $(APR_UTIL_IPK_DIR) $(APR_UTIL_IPK)

#
# Some sanity check for the package.
#
apr-util-check: $(APR_UTIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(APR_UTIL_IPK)
