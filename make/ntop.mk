###########################################################
#
# ntop
#
###########################################################

# You must replace "ntop" and "NTOP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NTOP_VERSION, NTOP_SITE and NTOP_SOURCE define
# the upstream location of the source code for the package.
# NTOP_DIR is the directory which is created when the source
# archive is unpacked.
# NTOP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NTOP_NAME=ntop
NTOP_VERSION=cvs
NTOP_DIR=$(NTOP_NAME)
# Tarball info
NTOP_SITE=# none - available from CVS only
NTOP_SOURCE=# none - available from CVS only

# Util info
NTOP_UNZIP=zcat
# Control info
NTOP_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
NTOP_DESCRIPTION=Network monitoring software
NTOP_SECTION=net
NTOP_PRIORITY=optional
NTOP_DEPENDS=openssl, zlib, gdbm, libgd

# CVS info
NTOP_REPOSITORY=:pserver:anonymous:ntop@cvs.ntop.org:/export/home/ntop


#
# NTOP_IPK_VERSION should be incremented when the ipk changes.
#
NTOP_IPK_VERSION=1

#
# NTOP_CONFFILES should be a list of user-editable files
NTOP_CONFFILES=
#/opt/etc/ntop.conf /opt/etc/init.d/SXXntop

#
# NTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NTOP_PATCHES=$(NTOP_SOURCE_DIR)/configure.patch \
	$(NTOP_SOURCE_DIR)/ltconfig.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NTOP_CPPFLAGS=
NTOP_LDFLAGS=-ljpeg -lfreetype -lfontconfig -lexpat -lpng12 -lz

#
# NTOP_BUILD_DIR is the directory in which the build is done.
# NTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NTOP_IPK_DIR is the directory in which the ipk is built.
# NTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NTOP_BUILD_DIR=$(BUILD_DIR)/ntop
NTOP_SOURCE_DIR=$(SOURCE_DIR)/ntop
NTOP_IPK_DIR=$(BUILD_DIR)/ntop-$(NTOP_VERSION)-ipk
NTOP_IPK=$(BUILD_DIR)/ntop_$(NTOP_VERSION)-$(NTOP_IPK_VERSION)_$(TARGET_ARCH).ipk


#
# Automatically create a ipkg control file
#
$(NTOP_IPK_DIR)/CONTROL/control:
	@install -d $(NTOP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: $(NTOP_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTOP_PRIORITY)" >>$@
	@echo "Section: $(NTOP_SECTION)" >>$@
	@echo "Version: $(NTOP_VERSION)-$(NTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTOP_MAINTAINER)" >>$@
	@echo "Source: $(NTOP_SITE)/$(NTOP_SOURCE)" >>$@
	@echo "Description: $(NTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(NTOP_DEPENDS)" >>$@


#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(NTOP_BUILD_DIR)/.fetched:
	rm -rf $(NTOP_BUILD_DIR) $(BUILD_DIR)/$(NTOP_DIR)
	( cd $(BUILD_DIR) ; \
		cvs -d $(NTOP_REPOSITORY) -z3 co $(NTOP_CVS_OPTS) $(NTOP_DIR); \
	)
#	mv $(BUILD_DIR)/$(NTOP_DIR) $(NTOP_BUILD_DIR)
	cat $(NTOP_PATCHES) | patch -d $(NTOP_BUILD_DIR) -p1
	touch $@


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ntop-source: $(NTOP_BUILD_DIR)/.fetched $(NTOP_PATCHES)

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
$(NTOP_BUILD_DIR)/.configured: $(NTOP_BUILD_DIR)/.fetched $(NTOP_PATCHES)
	$(MAKE) openssl-stage zlib-stage libpcap-stage gdbm-stage libgd-stage
#	rm -rf $(BUILD_DIR)/$(NTOP_DIR) $(NTOP_BUILD_DIR)
#	$(NTOP_UNZIP) $(DL_DIR)/$(NTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(NTOP_PATCHES) | patch -d $(BUILD_DIR)/$(NTOP_DIR) -p1
#	mv $(BUILD_DIR)/$(NTOP_DIR) $(NTOP_BUILD_DIR)
	(cd $(NTOP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NTOP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NTOP_LDFLAGS)" \
		ac_cv_file_aclocal_m4=yes \
		ac_cv_file_depcomp=yes \
		ac_cv_lib_gd_gdImageDestroy=yes \
		ac_cv_lib_png_main=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-ipv6 \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(NTOP_BUILD_DIR)/.configured

ntop-unpack: $(NTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NTOP_BUILD_DIR)/.built: $(NTOP_BUILD_DIR)/.configured
	rm -f $(NTOP_BUILD_DIR)/.built
	$(MAKE) -C $(NTOP_BUILD_DIR)
	touch $(NTOP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ntop: $(NTOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NTOP_BUILD_DIR)/.staged: $(NTOP_BUILD_DIR)/.built
	rm -f $(NTOP_BUILD_DIR)/.staged
	$(MAKE) -C $(NTOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NTOP_BUILD_DIR)/.staged

ntop-stage: $(NTOP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(NTOP_IPK_DIR)/opt/sbin or $(NTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NTOP_IPK_DIR)/opt/etc/ntop/...
# Documentation files should be installed in $(NTOP_IPK_DIR)/opt/doc/ntop/...
# Daemon startup scripts should be installed in $(NTOP_IPK_DIR)/opt/etc/init.d/S??ntop
#
# You may need to patch your application to make it use these locations.
#
$(NTOP_IPK): $(NTOP_BUILD_DIR)/.built
	rm -rf $(NTOP_IPK_DIR) $(BUILD_DIR)/ntop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NTOP_BUILD_DIR) DESTDIR=$(NTOP_IPK_DIR) install-strip
	install -d $(NTOP_IPK_DIR)/opt/etc/
#	install -m 644 $(NTOP_SOURCE_DIR)/ntop.conf $(NTOP_IPK_DIR)/opt/etc/ntop.conf
#	install -d $(NTOP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NTOP_SOURCE_DIR)/rc.ntop $(NTOP_IPK_DIR)/opt/etc/init.d/SXXntop
	$(MAKE) $(NTOP_IPK_DIR)/CONTROL/control
#	install -m 755 $(NTOP_SOURCE_DIR)/postinst $(NTOP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NTOP_SOURCE_DIR)/prerm $(NTOP_IPK_DIR)/CONTROL/prerm
#	echo $(NTOP_CONFFILES) | sed -e 's/ /\n/g' > $(NTOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ntop-ipk: $(NTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ntop-clean:
	-$(MAKE) -C $(NTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ntop-dirclean:
	rm -rf $(BUILD_DIR)/$(NTOP_DIR) $(NTOP_BUILD_DIR) $(NTOP_IPK_DIR) $(NTOP_IPK)


#		--with-pcap-root=$(STAGING_DIR)/opt \
#		--with-gdbm-root=$(STAGING_DIR)/opt \
#		--with-gd-root=$(STAGING_DIR)/opt \
#		--with-zlib-root=$(STAGING_DIR)/opt \
#		--with-libpng-root=$(STAGING_DIR)/opt \
#		--with-ossl-root=$(STAGING_DIR)/opt \


#		CVSROOT="$(NTOP_REPOSITORY)" ;\
#		export CVSROOT ; \
#		cvs login  ; \
#		cvs checkout ntop ; \
