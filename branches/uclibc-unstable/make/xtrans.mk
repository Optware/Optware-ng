###########################################################
#
# xtrans
#
###########################################################

#
# XTRANS_VERSION, XTRANS_SITE and XTRANS_SOURCE define
# the upstream location of the source code for the package.
# XTRANS_DIR is the directory which is created when the source
# archive is unpacked.
#
XTRANS_SITE=http://freedesktop.org
XTRANS_SOURCE=# none - available from CVS only
XTRANS_VERSION=0.1+cvs20050130
XTRANS_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XTRANS_DIR=xtrans
XTRANS_CVS_OPTS=-D20050130
XTRANS_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XTRANS_DESCRIPTION=X transport headers
XTRANS_SECTION=lib
XTRANS_PRIORITY=optional

#
# XTRANS_IPK_VERSION should be incremented when the ipk changes.
#
XTRANS_IPK_VERSION=2

#
# XTRANS_CONFFILES should be a list of user-editable files
XTRANS_CONFFILES=

#
# XTRANS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XTRANS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XTRANS_CPPFLAGS=
XTRANS_LDFLAGS=

#
# XTRANS_BUILD_DIR is the directory in which the build is done.
# XTRANS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XTRANS_IPK_DIR is the directory in which the ipk is built.
# XTRANS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XTRANS_BUILD_DIR=$(BUILD_DIR)/xtrans
XTRANS_SOURCE_DIR=$(SOURCE_DIR)/xtrans
XTRANS_IPK_DIR=$(BUILD_DIR)/xtrans-$(XTRANS_VERSION)-ipk
XTRANS_IPK=$(BUILD_DIR)/xtrans_$(XTRANS_VERSION)-$(XTRANS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XTRANS_IPK_DIR)/CONTROL/control:
	@install -d $(XTRANS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xtrans" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XTRANS_PRIORITY)" >>$@
	@echo "Section: $(XTRANS_SECTION)" >>$@
	@echo "Version: $(XTRANS_VERSION)-$(XTRANS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XTRANS_MAINTAINER)" >>$@
	@echo "Source: $(XTRANS_SITE)/$(XTRANS_SOURCE)" >>$@
	@echo "Description: $(XTRANS_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xtrans-$(XTRANS_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XTRANS_DIR) && \
		cvs -d $(XTRANS_REPOSITORY) -z3 co $(XTRANS_CVS_OPTS) $(XTRANS_DIR) && \
		tar -czf $@ $(XTRANS_DIR) && \
		rm -rf $(XTRANS_DIR) \
	)

xtrans-source: $(DL_DIR)/xtrans-$(XTRANS_VERSION).tar.gz $(XTRANS_PATCHES)

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
$(XTRANS_BUILD_DIR)/.configured: $(DL_DIR)/xtrans-$(XTRANS_VERSION).tar.gz \
		$(XTRANS_PATCHES)
	rm -rf $(BUILD_DIR)/$(XTRANS_DIR) $(XTRANS_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xtrans-$(XTRANS_VERSION).tar.gz
	if test -n "$(XTRANS_PATCHES)" ; \
		then cat $(XTRANS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XTRANS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XTRANS_DIR)" != "$(XTRANS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XTRANS_DIR) $(XTRANS_BUILD_DIR) ; \
	fi
	(cd $(XTRANS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XTRANS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XTRANS_LDFLAGS)" \
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
	touch $(XTRANS_BUILD_DIR)/.configured

xtrans-unpack: $(XTRANS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XTRANS_BUILD_DIR)/.built: $(XTRANS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XTRANS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xtrans: $(XTRANS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XTRANS_BUILD_DIR)/.staged: $(XTRANS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XTRANS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xtrans.pc
	touch $@

xtrans-stage: $(XTRANS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XTRANS_IPK_DIR)/opt/sbin or $(XTRANS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XTRANS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XTRANS_IPK_DIR)/opt/etc/xtrans/...
# Documentation files should be installed in $(XTRANS_IPK_DIR)/opt/doc/xtrans/...
# Daemon startup scripts should be installed in $(XTRANS_IPK_DIR)/opt/etc/init.d/S??xtrans
#
# You may need to patch your application to make it use these locations.
#
$(XTRANS_IPK): $(XTRANS_BUILD_DIR)/.built
	rm -rf $(XTRANS_IPK_DIR) $(BUILD_DIR)/xtrans_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XTRANS_BUILD_DIR) DESTDIR=$(XTRANS_IPK_DIR) install
	$(MAKE) $(XTRANS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XTRANS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xtrans-ipk: $(XTRANS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xtrans-clean:
	-$(MAKE) -C $(XTRANS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xtrans-dirclean:
	rm -rf $(BUILD_DIR)/$(XTRANS_DIR) $(XTRANS_BUILD_DIR) $(XTRANS_IPK_DIR) $(XTRANS_IPK)
