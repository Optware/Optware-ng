###########################################################
#
# xdmcp
#
###########################################################

#
# XDMCP_VERSION, XDMCP_SITE and XDMCP_SOURCE define
# the upstream location of the source code for the package.
# XDMCP_DIR is the directory which is created when the source
# archive is unpacked.
#
XDMCP_SITE=http://freedesktop.org
XDMCP_SOURCE=# none - available from CVS only
XDMCP_VERSION=0.1.3+cvs20050130
XDMCP_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XDMCP_DIR=Xdmcp
XDMCP_CVS_OPTS=-D20050130
XDMCP_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XDMCP_DESCRIPTION=XDMCP protocol library
XDMCP_SECTION=lib
XDMCP_PRIORITY=optional

#
# XDMCP_IPK_VERSION should be incremented when the ipk changes.
#
XDMCP_IPK_VERSION=2

#
# XDMCP_CONFFILES should be a list of user-editable files
XDMCP_CONFFILES=

#
# XDMCP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XDMCP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XDMCP_CPPFLAGS=
XDMCP_LDFLAGS=

#
# XDMCP_BUILD_DIR is the directory in which the build is done.
# XDMCP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XDMCP_IPK_DIR is the directory in which the ipk is built.
# XDMCP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XDMCP_BUILD_DIR=$(BUILD_DIR)/xdmcp
XDMCP_SOURCE_DIR=$(SOURCE_DIR)/xdmcp
XDMCP_IPK_DIR=$(BUILD_DIR)/xdmcp-$(XDMCP_VERSION)-ipk
XDMCP_IPK=$(BUILD_DIR)/xdmcp_$(XDMCP_VERSION)-$(XDMCP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XDMCP_IPK_DIR)/CONTROL/control:
	@install -d $(XDMCP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xdmcp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XDMCP_PRIORITY)" >>$@
	@echo "Section: $(XDMCP_SECTION)" >>$@
	@echo "Version: $(XDMCP_VERSION)-$(XDMCP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XDMCP_MAINTAINER)" >>$@
	@echo "Source: $(XDMCP_SITE)/$(XDMCP_SOURCE)" >>$@
	@echo "Description: $(XDMCP_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xdmcp-$(XDMCP_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XDMCP_DIR) && \
		cvs -d $(XDMCP_REPOSITORY) -z3 co $(XDMCP_CVS_OPTS) $(XDMCP_DIR) && \
		tar -czf $@ $(XDMCP_DIR) && \
		rm -rf $(XDMCP_DIR) \
	)

xdmcp-source: $(DL_DIR)/xdmcp-$(XDMCP_VERSION).tar.gz $(XDMCP_PATCHES)

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
$(XDMCP_BUILD_DIR)/.configured: $(DL_DIR)/xdmcp-$(XDMCP_VERSION).tar.gz \
		$(XDMCP_PATCHES)
	$(MAKE) xproto-stage
	rm -rf $(BUILD_DIR)/$(XDMCP_DIR) $(XDMCP_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xdmcp-$(XDMCP_VERSION).tar.gz
	if test -n "$(XDMCP_PATCHES)" ; \
		then cat $(XDMCP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XDMCP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XDMCP_DIR)" != "$(XDMCP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XDMCP_DIR) $(XDMCP_BUILD_DIR) ; \
	fi
	(cd $(XDMCP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XDMCP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XDMCP_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(XDMCP_BUILD_DIR)/.configured

xdmcp-unpack: $(XDMCP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XDMCP_BUILD_DIR)/.built: $(XDMCP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XDMCP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xdmcp: $(XDMCP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XDMCP_BUILD_DIR)/.staged: $(XDMCP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XDMCP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xdmcp.pc
	rm -f $(STAGING_LIB_DIR)/libXdmcp.la
	touch $@

xdmcp-stage: $(XDMCP_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XDMCP_IPK_DIR)/opt/sbin or $(XDMCP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XDMCP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XDMCP_IPK_DIR)/opt/etc/xdmcp/...
# Documentation files should be installed in $(XDMCP_IPK_DIR)/opt/doc/xdmcp/...
# Daemon startup scripts should be installed in $(XDMCP_IPK_DIR)/opt/etc/init.d/S??xdmcp
#
# You may need to patch your application to make it use these locations.
#
$(XDMCP_IPK): $(XDMCP_BUILD_DIR)/.built
	rm -rf $(XDMCP_IPK_DIR) $(BUILD_DIR)/xdmcp_*_$(TARGET_ARCH).ipk $(XDMCP_SOURCE_DIR)/control
	$(MAKE) -C $(XDMCP_BUILD_DIR) DESTDIR=$(XDMCP_IPK_DIR) install-strip
	$(MAKE) $(XDMCP_IPK_DIR)/CONTROL/control
	rm -f $(XDMCP_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XDMCP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xdmcp-ipk: $(XDMCP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xdmcp-clean:
	-$(MAKE) -C $(XDMCP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xdmcp-dirclean:
	rm -rf $(BUILD_DIR)/$(XDMCP_DIR) $(XDMCP_BUILD_DIR) $(XDMCP_IPK_DIR) $(XDMCP_IPK)
