###########################################################
#
# libwebsockets
#
###########################################################
#
# LIBWEBSOCKETS_VERSION, LIBWEBSOCKETS_SITE and LIBWEBSOCKETS_SOURCE define
# the upstream location of the source code for the package.
# LIBWEBSOCKETS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBWEBSOCKETS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
LIBWEBSOCKETS_URL=https://github.com/warmcat/libwebsockets/archive/v$(LIBWEBSOCKETS_VERSION).tar.gz
LIBWEBSOCKETS_VERSION=2.0.2
LIBWEBSOCKETS_SOURCE=libwebsockets-$(LIBWEBSOCKETS_VERSION).tar.gz
LIBWEBSOCKETS_DIR=libwebsockets-$(LIBWEBSOCKETS_VERSION)
LIBWEBSOCKETS_UNZIP=zcat
LIBWEBSOCKETS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBWEBSOCKETS_DESCRIPTION=Libwebsockets is a lightweight pure C library built to use minimal CPU and memory resources, and provide fast throughput in both directions as client or server.
LIBWEBSOCKETS_SECTION=lib
LIBWEBSOCKETS_PRIORITY=optional
LIBWEBSOCKETS_DEPENDS=zlib, openssl
LIBWEBSOCKETS_SUGGESTS=
LIBWEBSOCKETS_CONFLICTS=

#
# LIBWEBSOCKETS_IPK_VERSION should be incremented when the ipk changes.
#
LIBWEBSOCKETS_IPK_VERSION=5

#
# LIBWEBSOCKETS_CONFFILES should be a list of user-editable files
#LIBWEBSOCKETS_CONFFILES=$(TARGET_PREFIX)/etc/libwebsockets.conf $(TARGET_PREFIX)/etc/init.d/SXXlibwebsockets

#
# LIBWEBSOCKETS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBWEBSOCKETS_PATCHES=\
$(LIBWEBSOCKETS_SOURCE_DIR)/skip_find_package_openssl.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq (, $(filter buildroot-ppc-603e, $(OPTWARE_TARGET)))
# Only valid for GCC 7+
LIBWEBSOCKETS_CPPFLAGS=-Wno-error=format-overflow
else
LIBWEBSOCKETS_CPPFLAGS=
endif
LIBWEBSOCKETS_LDFLAGS=

#
# LIBWEBSOCKETS_BUILD_DIR is the directory in which the build is done.
# LIBWEBSOCKETS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBWEBSOCKETS_IPK_DIR is the directory in which the ipk is built.
# LIBWEBSOCKETS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBWEBSOCKETS_BUILD_DIR=$(BUILD_DIR)/libwebsockets
LIBWEBSOCKETS_SOURCE_DIR=$(SOURCE_DIR)/libwebsockets
LIBWEBSOCKETS_IPK_DIR=$(BUILD_DIR)/libwebsockets-$(LIBWEBSOCKETS_VERSION)-ipk
LIBWEBSOCKETS_IPK=$(BUILD_DIR)/libwebsockets_$(LIBWEBSOCKETS_VERSION)-$(LIBWEBSOCKETS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libwebsockets-source libwebsockets-unpack libwebsockets libwebsockets-stage libwebsockets-ipk libwebsockets-clean libwebsockets-dirclean libwebsockets-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBWEBSOCKETS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBWEBSOCKETS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBWEBSOCKETS_SOURCE).sha512
#
$(DL_DIR)/$(LIBWEBSOCKETS_SOURCE):
	$(WGET) -O $@ $(LIBWEBSOCKETS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libwebsockets-source: $(DL_DIR)/$(LIBWEBSOCKETS_SOURCE) $(LIBWEBSOCKETS_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(LIBWEBSOCKETS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBWEBSOCKETS_SOURCE) $(LIBWEBSOCKETS_PATCHES) make/libwebsockets.mk
	$(MAKE) zlib-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(LIBWEBSOCKETS_DIR) $(@D)
	$(LIBWEBSOCKETS_UNZIP) $(DL_DIR)/$(LIBWEBSOCKETS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBWEBSOCKETS_PATCHES)" ; \
		then cat $(LIBWEBSOCKETS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBWEBSOCKETS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBWEBSOCKETS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBWEBSOCKETS_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBWEBSOCKETS_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(LIBWEBSOCKETS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(LIBWEBSOCKETS_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(LIBWEBSOCKETS_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBWEBSOCKETS_LDFLAGS)" \
		-DLWS_WITH_HTTP2=1 \
		-DOPENSSL_ROOT_DIR=$(STAGING_PREFIX) \
		-DCMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE=$(STAGING_PREFIX) \
		-DOPENSSL_LIBRARIES="-lcrypto -lssl" \
		-DOPENSSL_INCLUDE_DIRS="$(STAGING_INCLUDE_DIR)"
	touch $@

libwebsockets-unpack: $(LIBWEBSOCKETS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBWEBSOCKETS_BUILD_DIR)/.built: $(LIBWEBSOCKETS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libwebsockets: $(LIBWEBSOCKETS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBWEBSOCKETS_BUILD_DIR)/.staged: $(LIBWEBSOCKETS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libwebsockets.pc
	touch $@

libwebsockets-stage: $(LIBWEBSOCKETS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libwebsockets
#
$(LIBWEBSOCKETS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libwebsockets" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBWEBSOCKETS_PRIORITY)" >>$@
	@echo "Section: $(LIBWEBSOCKETS_SECTION)" >>$@
	@echo "Version: $(LIBWEBSOCKETS_VERSION)-$(LIBWEBSOCKETS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBWEBSOCKETS_MAINTAINER)" >>$@
	@echo "Source: $(LIBWEBSOCKETS_URL)" >>$@
	@echo "Description: $(LIBWEBSOCKETS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBWEBSOCKETS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBWEBSOCKETS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBWEBSOCKETS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/libwebsockets/...
# Documentation files should be installed in $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/doc/libwebsockets/...
# Daemon startup scripts should be installed in $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libwebsockets
#
# You may need to patch your application to make it use these locations.
#
$(LIBWEBSOCKETS_IPK): $(LIBWEBSOCKETS_BUILD_DIR)/.built
	rm -rf $(LIBWEBSOCKETS_IPK_DIR) $(BUILD_DIR)/libwebsockets_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBWEBSOCKETS_BUILD_DIR) DESTDIR=$(LIBWEBSOCKETS_IPK_DIR) install
	rm -f $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(STRIP_COMMAND) $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/{lib/*.so,bin/*}
#	$(INSTALL) -d $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBWEBSOCKETS_SOURCE_DIR)/libwebsockets.conf $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/libwebsockets.conf
#	$(INSTALL) -d $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBWEBSOCKETS_SOURCE_DIR)/rc.libwebsockets $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibwebsockets
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBWEBSOCKETS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibwebsockets
	$(MAKE) $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBWEBSOCKETS_SOURCE_DIR)/postinst $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBWEBSOCKETS_SOURCE_DIR)/prerm $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBWEBSOCKETS_IPK_DIR)/CONTROL/postinst $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBWEBSOCKETS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBWEBSOCKETS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBWEBSOCKETS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBWEBSOCKETS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libwebsockets-ipk: $(LIBWEBSOCKETS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libwebsockets-clean:
	rm -f $(LIBWEBSOCKETS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBWEBSOCKETS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libwebsockets-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBWEBSOCKETS_DIR) $(LIBWEBSOCKETS_BUILD_DIR) $(LIBWEBSOCKETS_IPK_DIR) $(LIBWEBSOCKETS_IPK)
#
#
# Some sanity check for the package.
#
libwebsockets-check: $(LIBWEBSOCKETS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
