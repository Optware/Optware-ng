###########################################################
#
# recordext
#
###########################################################

#
# RECORDEXT_VERSION, RECORDEXT_SITE and RECORDEXT_SOURCE define
# the upstream location of the source code for the package.
# RECORDEXT_DIR is the directory which is created when the source
# archive is unpacked.
#
RECORDEXT_SITE=http://freedesktop.org/
RECORDEXT_SOURCE=# none - available from CVS only
RECORDEXT_VERSION=1.13+cvs20050130
RECORDEXT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
RECORDEXT_DIR=RecordExt
RECORDEXT_CVS_OPTS=-D20050130
RECORDEXT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
RECORDEXT_DESCRIPTION=X record extension headers
RECORDEXT_SECTION=lib
RECORDEXT_PRIORITY=optional

#
# RECORDEXT_IPK_VERSION should be incremented when the ipk changes.
#
RECORDEXT_IPK_VERSION=2

#
# RECORDEXT_CONFFILES should be a list of user-editable files
RECORDEXT_CONFFILES=

#
# RECORDEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RECORDEXT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RECORDEXT_CPPFLAGS=
RECORDEXT_LDFLAGS=

#
# RECORDEXT_BUILD_DIR is the directory in which the build is done.
# RECORDEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RECORDEXT_IPK_DIR is the directory in which the ipk is built.
# RECORDEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RECORDEXT_BUILD_DIR=$(BUILD_DIR)/recordext
RECORDEXT_SOURCE_DIR=$(SOURCE_DIR)/recordext
RECORDEXT_IPK_DIR=$(BUILD_DIR)/recordext-$(RECORDEXT_VERSION)-ipk
RECORDEXT_IPK=$(BUILD_DIR)/recordext_$(RECORDEXT_VERSION)-$(RECORDEXT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(RECORDEXT_IPK_DIR)/CONTROL/control:
	@install -d $(RECORDEXT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: recordext" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RECORDEXT_PRIORITY)" >>$@
	@echo "Section: $(RECORDEXT_SECTION)" >>$@
	@echo "Version: $(RECORDEXT_VERSION)-$(RECORDEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RECORDEXT_MAINTAINER)" >>$@
	@echo "Source: $(RECORDEXT_SITE)/$(RECORDEXT_SOURCE)" >>$@
	@echo "Description: $(RECORDEXT_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/recordext-$(RECORDEXT_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(RECORDEXT_DIR) && \
		cvs -d $(RECORDEXT_REPOSITORY) -z3 co $(RECORDEXT_CVS_OPTS) $(RECORDEXT_DIR) && \
		tar -czf $@ $(RECORDEXT_DIR) && \
		rm -rf $(RECORDEXT_DIR) \
	)

recordext-source: $(DL_DIR)/recordext-$(RECORDEXT_VERSION).tar.gz $(RECORDEXT_PATCHES)

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
$(RECORDEXT_BUILD_DIR)/.configured: $(DL_DIR)/recordext-$(RECORDEXT_VERSION).tar.gz \
		$(STAGING_INCLUDE_DIR)/X11/X.h \
		$(RECORDEXT_PATCHES)
	rm -rf $(BUILD_DIR)/$(RECORDEXT_DIR) $(RECORDEXT_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/recordext-$(RECORDEXT_VERSION).tar.gz
	if test -n "$(RECORDEXT_PATCHES)" ; \
		then cat $(RECORDEXT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RECORDEXT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RECORDEXT_DIR)" != "$(RECORDEXT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RECORDEXT_DIR) $(RECORDEXT_BUILD_DIR) ; \
	fi
	(cd $(RECORDEXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RECORDEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RECORDEXT_LDFLAGS)" \
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
	touch $(RECORDEXT_BUILD_DIR)/.configured

recordext-unpack: $(RECORDEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RECORDEXT_BUILD_DIR)/.built: $(RECORDEXT_BUILD_DIR)/.configured
	rm -f $(RECORDEXT_BUILD_DIR)/.built
	$(MAKE) -C $(RECORDEXT_BUILD_DIR)
	touch $(RECORDEXT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
recordext: $(RECORDEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RECORDEXT_BUILD_DIR)/.staged: $(RECORDEXT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(RECORDEXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/recordext.pc
	touch $@

recordext-stage: $(RECORDEXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(RECORDEXT_IPK_DIR)/opt/sbin or $(RECORDEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RECORDEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RECORDEXT_IPK_DIR)/opt/etc/recordext/...
# Documentation files should be installed in $(RECORDEXT_IPK_DIR)/opt/doc/recordext/...
# Daemon startup scripts should be installed in $(RECORDEXT_IPK_DIR)/opt/etc/init.d/S??recordext
#
# You may need to patch your application to make it use these locations.
#
$(RECORDEXT_IPK): $(RECORDEXT_BUILD_DIR)/.built
	rm -rf $(RECORDEXT_IPK_DIR) $(BUILD_DIR)/recordext_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RECORDEXT_BUILD_DIR) DESTDIR=$(RECORDEXT_IPK_DIR) install
	$(MAKE) $(RECORDEXT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RECORDEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
recordext-ipk: $(RECORDEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
recordext-clean:
	-$(MAKE) -C $(RECORDEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
recordext-dirclean:
	rm -rf $(BUILD_DIR)/$(RECORDEXT_DIR) $(RECORDEXT_BUILD_DIR) $(RECORDEXT_IPK_DIR) $(RECORDEXT_IPK)
