###########################################################
#
# xmu
#
###########################################################

#
# XMU_VERSION, XMU_SITE and XMU_SOURCE define
# the upstream location of the source code for the package.
# XMU_DIR is the directory which is created when the source
# archive is unpacked.
#
XMU_SITE=http://freedesktop.org
XMU_SOURCE=# none - available from CVS only
XMU_VERSION=6.2.3+cvs20050130
XMU_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XMU_DIR=Xmu
XMU_CVS_OPTS=-D20050130
XMU_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XMU_DESCRIPTION=X miscellaneous utilities libraries
XMU_SECTION=lib
XMU_PRIORITY=optional
XMU_DEPENDS=xext

#
# XMU_IPK_VERSION should be incremented when the ipk changes.
#
XMU_IPK_VERSION=1

#
# XMU_CONFFILES should be a list of user-editable files
XMU_CONFFILES=

#
# XMU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XMU_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XMU_CPPFLAGS=
XMU_LDFLAGS=

#
# XMU_BUILD_DIR is the directory in which the build is done.
# XMU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XMU_IPK_DIR is the directory in which the ipk is built.
# XMU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XMU_BUILD_DIR=$(BUILD_DIR)/xmu
XMU_SOURCE_DIR=$(SOURCE_DIR)/xmu
XMU_IPK_DIR=$(BUILD_DIR)/xmu-$(XMU_VERSION)-ipk
XMU_IPK=$(BUILD_DIR)/xmu_$(XMU_VERSION)-$(XMU_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(XMU_IPK_DIR)/CONTROL/control:
	@install -d $(XMU_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xmu" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(XMU_PRIORITY)" >>$@
	@echo "Section: $(XMU_SECTION)" >>$@
	@echo "Version: $(XMU_VERSION)-$(XMU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XMU_MAINTAINER)" >>$@
	@echo "Source: $(XMU_SITE)/$(XMU_SOURCE)" >>$@
	@echo "Description: $(XMU_DESCRIPTION)" >>$@
	@echo "Depends: $(XMU_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(XMU_BUILD_DIR)/.fetched:
	rm -rf $(XMU_BUILD_DIR) $(BUILD_DIR)/$(XMU_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(XMU_REPOSITORY) -z3 co $(XMU_CVS_OPTS) $(XMU_DIR); \
	)
	mv $(BUILD_DIR)/$(XMU_DIR) $(XMU_BUILD_DIR)
	#cat $(XMU_PATCHES) | patch -d $(XMU_BUILD_DIR) -p0
	touch $@

xmu-source: $(XMU_BUILD_DIR)/.fetched $(XMU_PATCHES)

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
$(XMU_BUILD_DIR)/.configured: $(XMU_BUILD_DIR)/.fetched $(XMU_PATCHES)
	$(MAKE) xext-stage
	$(MAKE) xt-stage
	(cd $(XMU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XMU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XMU_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ACLOCAL=aclocal-1.9 \
		AUTOMAKE=automake-1.9 \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(XMU_BUILD_DIR)/.configured

xmu-unpack: $(XMU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XMU_BUILD_DIR)/.built: $(XMU_BUILD_DIR)/.configured
	rm -f $(XMU_BUILD_DIR)/.built
	$(MAKE) -C $(XMU_BUILD_DIR)
	touch $(XMU_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xmu: $(XMU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XMU_BUILD_DIR)/.staged: $(XMU_BUILD_DIR)/.built
	rm -f $(XMU_BUILD_DIR)/.staged
	$(MAKE) -C $(XMU_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libXmu.la
	rm -f $(STAGING_LIB_DIR)/libXmuu.la
	touch $(XMU_BUILD_DIR)/.staged

xmu-stage: $(XMU_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XMU_IPK_DIR)/opt/sbin or $(XMU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XMU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XMU_IPK_DIR)/opt/etc/xmu/...
# Documentation files should be installed in $(XMU_IPK_DIR)/opt/doc/xmu/...
# Daemon startup scripts should be installed in $(XMU_IPK_DIR)/opt/etc/init.d/S??xmu
#
# You may need to patch your application to make it use these locations.
#
$(XMU_IPK): $(XMU_BUILD_DIR)/.built
	rm -rf $(XMU_IPK_DIR) $(BUILD_DIR)/xmu_*_armeb.ipk
	$(MAKE) -C $(XMU_BUILD_DIR) DESTDIR=$(XMU_IPK_DIR) install-strip
	$(MAKE) $(XMU_IPK_DIR)/CONTROL/control
	rm -f $(XMU_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XMU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xmu-ipk: $(XMU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xmu-clean:
	-$(MAKE) -C $(XMU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xmu-dirclean:
	rm -rf $(BUILD_DIR)/$(XMU_DIR) $(XMU_BUILD_DIR) $(XMU_IPK_DIR) $(XMU_IPK)
