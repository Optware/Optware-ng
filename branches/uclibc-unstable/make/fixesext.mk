###########################################################
#
# fixesext
#
###########################################################

#
# FIXESEXT_VERSION, FIXESEXT_SITE and FIXESEXT_SOURCE define
# the upstream location of the source code for the package.
# FIXESEXT_DIR is the directory which is created when the source
# archive is unpacked.
#
FIXESEXT_SITE=http://freedesktop.org/
FIXESEXT_SOURCE=# none - available from CVS only
FIXESEXT_VERSION=2.0.1+cvs20050130
FIXESEXT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
FIXESEXT_DIR=FixesExt
FIXESEXT_CVS_OPTS=-D20050130
FIXESEXT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
FIXESEXT_DESCRIPTION=X fixes extension headers
FIXESEXT_SECTION=lib
FIXESEXT_PRIORITY=optional

#
# FIXESEXT_IPK_VERSION should be incremented when the ipk changes.
#
FIXESEXT_IPK_VERSION=2

#
# FIXESEXT_CONFFILES should be a list of user-editable files
FIXESEXT_CONFFILES=

#
# FIXESEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FIXESEXT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FIXESEXT_CPPFLAGS=
FIXESEXT_LDFLAGS=

#
# FIXESEXT_BUILD_DIR is the directory in which the build is done.
# FIXESEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FIXESEXT_IPK_DIR is the directory in which the ipk is built.
# FIXESEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FIXESEXT_BUILD_DIR=$(BUILD_DIR)/fixesext
FIXESEXT_SOURCE_DIR=$(SOURCE_DIR)/fixesext
FIXESEXT_IPK_DIR=$(BUILD_DIR)/fixesext-$(FIXESEXT_VERSION)-ipk
FIXESEXT_IPK=$(BUILD_DIR)/fixesext_$(FIXESEXT_VERSION)-$(FIXESEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(FIXESEXT_IPK_DIR)/CONTROL/control:
	@install -d $(FIXESEXT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: fixesext" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FIXESEXT_PRIORITY)" >>$@
	@echo "Section: $(FIXESEXT_SECTION)" >>$@
	@echo "Version: $(FIXESEXT_VERSION)-$(FIXESEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FIXESEXT_MAINTAINER)" >>$@
	@echo "Source: $(FIXESEXT_SITE)/$(FIXESEXT_SOURCE)" >>$@
	@echo "Description: $(FIXESEXT_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/fixesext-$(FIXESEXT_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(FIXESEXT_DIR) && \
		cvs -d $(FIXESEXT_REPOSITORY) -z3 co $(FIXESEXT_CVS_OPTS) $(FIXESEXT_DIR) && \
		tar -czf $@ $(FIXESEXT_DIR) && \
		rm -rf $(FIXESEXT_DIR) \
	)

fixesext-source: $(DL_DIR)/fixesext-$(FIXESEXT_VERSION).tar.gz $(FIXESEXT_PATCHES)

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
$(FIXESEXT_BUILD_DIR)/.configured: $(DL_DIR)/fixesext-$(FIXESEXT_VERSION).tar.gz $(FIXESEXT_PATCHES)
	$(MAKE) x11-stage
	$(MAKE) xext-stage
	rm -rf $(BUILD_DIR)/$(FIXESEXT_DIR) $(FIXESEXT_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/fixesext-$(FIXESEXT_VERSION).tar.gz
	if test -n "$(FIXESEXT_PATCHES)" ; \
		then cat $(FIXESEXT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FIXESEXT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FIXESEXT_DIR)" != "$(FIXESEXT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FIXESEXT_DIR) $(FIXESEXT_BUILD_DIR) ; \
	fi
	(cd $(FIXESEXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FIXESEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FIXESEXT_LDFLAGS)" \
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
	touch $(FIXESEXT_BUILD_DIR)/.configured

fixesext-unpack: $(FIXESEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FIXESEXT_BUILD_DIR)/.built: $(FIXESEXT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FIXESEXT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
fixesext: $(FIXESEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FIXESEXT_BUILD_DIR)/.staged: $(FIXESEXT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FIXESEXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fixesext.pc
	touch $@

fixesext-stage: $(FIXESEXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FIXESEXT_IPK_DIR)/opt/sbin or $(FIXESEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FIXESEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FIXESEXT_IPK_DIR)/opt/etc/fixesext/...
# Documentation files should be installed in $(FIXESEXT_IPK_DIR)/opt/doc/fixesext/...
# Daemon startup scripts should be installed in $(FIXESEXT_IPK_DIR)/opt/etc/init.d/S??fixesext
#
# You may need to patch your application to make it use these locations.
#
$(FIXESEXT_IPK): $(FIXESEXT_BUILD_DIR)/.built
	rm -rf $(FIXESEXT_IPK_DIR) $(BUILD_DIR)/fixesext_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FIXESEXT_BUILD_DIR) DESTDIR=$(FIXESEXT_IPK_DIR) install
	$(MAKE) $(FIXESEXT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FIXESEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fixesext-ipk: $(FIXESEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fixesext-clean:
	-$(MAKE) -C $(FIXESEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fixesext-dirclean:
	rm -rf $(BUILD_DIR)/$(FIXESEXT_DIR) $(FIXESEXT_BUILD_DIR) $(FIXESEXT_IPK_DIR) $(FIXESEXT_IPK)
