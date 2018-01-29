###########################################################
#
# cmake
#
###########################################################
#
# CMAKE_VERSION, CMAKE_SITE and CMAKE_SOURCE define
# the upstream location of the source code for the package.
# CMAKE_DIR is the directory which is created when the source
# archive is unpacked.
# CMAKE_UNZIP is the command used to unzip the source.
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
CMAKE_SITE=http://www.cmake.org/files/v3.10
CMAKE_VERSION=3.10.2
CMAKE_SOURCE=cmake-$(CMAKE_VERSION).tar.gz
CMAKE_DIR=cmake-$(CMAKE_VERSION)
CMAKE_UNZIP=zcat
CMAKE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CMAKE_DESCRIPTION=CMake build configuration tool.
CMAKE_SECTION=misc
CMAKE_PRIORITY=optional
CMAKE_DEPENDS=libstdc++, libcurl, zlib, ncurses
CMAKE_SUGGESTS=
CMAKE_CONFLICTS=

#
# CMAKE_IPK_VERSION should be incremented when the ipk changes.
#
CMAKE_IPK_VERSION=1

#
# CMAKE_CONFFILES should be a list of user-editable files
#CMAKE_CONFFILES=$(TARGET_PREFIX)/etc/cmake.conf $(TARGET_PREFIX)/etc/init.d/SXXcmake

#
# CMAKE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CMAKE_PATCHES=$(CMAKE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CMAKE_CPPFLAGS=
CMAKE_LDFLAGS=

#
# CMAKE_BUILD_DIR is the directory in which the build is done.
# CMAKE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CMAKE_IPK_DIR is the directory in which the ipk is built.
# CMAKE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CMAKE_BUILD_DIR=$(BUILD_DIR)/cmake
CMAKE_SOURCE_DIR=$(SOURCE_DIR)/cmake
CMAKE_IPK_DIR=$(BUILD_DIR)/cmake-$(CMAKE_VERSION)-ipk
CMAKE_IPK=$(BUILD_DIR)/cmake_$(CMAKE_VERSION)-$(CMAKE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cmake-source cmake-unpack cmake cmake-stage cmake-ipk cmake-clean cmake-dirclean cmake-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CMAKE_SOURCE):
	$(WGET) -P $(@D) $(CMAKE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cmake-source: $(DL_DIR)/$(CMAKE_SOURCE) $(CMAKE_PATCHES)

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
$(CMAKE_BUILD_DIR)/.configured: $(DL_DIR)/$(CMAKE_SOURCE) $(CMAKE_PATCHES) make/cmake.mk
	$(MAKE) libcurl-stage zlib-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(CMAKE_DIR) $(@D)
	$(CMAKE_UNZIP) $(DL_DIR)/$(CMAKE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CMAKE_PATCHES)" ; \
		then cat $(CMAKE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CMAKE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CMAKE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CMAKE_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(CMAKE_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(CMAKE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(CMAKE_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(CMAKE_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(CMAKE_LDFLAGS)" \
		-DCMAKE_USE_SYSTEM_CURL=ON \
		-DZLIB_INCLUDE_DIR=$(STAGING_INCLUDE_DIR)/ \
		-DZLIB_LIBRARY=$(STAGING_LIB_DIR)/libz.so \
		-DCURL_INCLUDE_DIR=$(STAGING_INCLUDE_DIR)/ \
		-DCURL_LIBRARY=$(STAGING_LIB_DIR)/libcurl.so \
		-DKWSYS_LFS_WORKS=1 \
		-DCMake_TEST_Qt4=0 \
		-DCMake_TEST_Qt5=0
	touch $@

cmake-unpack: $(CMAKE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CMAKE_BUILD_DIR)/.built: $(CMAKE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cmake: $(CMAKE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CMAKE_BUILD_DIR)/.staged: $(CMAKE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cmake-stage: $(CMAKE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cmake
#
$(CMAKE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cmake" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CMAKE_PRIORITY)" >>$@
	@echo "Section: $(CMAKE_SECTION)" >>$@
	@echo "Version: $(CMAKE_VERSION)-$(CMAKE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CMAKE_MAINTAINER)" >>$@
	@echo "Source: $(CMAKE_SITE)/$(CMAKE_SOURCE)" >>$@
	@echo "Description: $(CMAKE_DESCRIPTION)" >>$@
	@echo "Depends: $(CMAKE_DEPENDS)" >>$@
	@echo "Suggests: $(CMAKE_SUGGESTS)" >>$@
	@echo "Conflicts: $(CMAKE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/cmake/...
# Documentation files should be installed in $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/doc/cmake/...
# Daemon startup scripts should be installed in $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cmake
#
# You may need to patch your application to make it use these locations.
#
$(CMAKE_IPK): $(CMAKE_BUILD_DIR)/.built
	rm -rf $(CMAKE_IPK_DIR) $(BUILD_DIR)/cmake_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CMAKE_BUILD_DIR) DESTDIR=$(CMAKE_IPK_DIR) install
	cd $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/bin; \
		$(STRIP_COMMAND) ccmake cmake cpack ctest
#	$(INSTALL) -d $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(CMAKE_SOURCE_DIR)/cmake.conf $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/cmake.conf
#	$(INSTALL) -d $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(CMAKE_SOURCE_DIR)/rc.cmake $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcmake
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CMAKE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcmake
	$(MAKE) $(CMAKE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(CMAKE_SOURCE_DIR)/postinst $(CMAKE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CMAKE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(CMAKE_SOURCE_DIR)/prerm $(CMAKE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CMAKE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CMAKE_IPK_DIR)/CONTROL/postinst $(CMAKE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CMAKE_CONFFILES) | sed -e 's/ /\n/g' > $(CMAKE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CMAKE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CMAKE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cmake-ipk: $(CMAKE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cmake-clean:
	rm -f $(CMAKE_BUILD_DIR)/.built
	-$(MAKE) -C $(CMAKE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cmake-dirclean:
	rm -rf $(BUILD_DIR)/$(CMAKE_DIR) $(CMAKE_BUILD_DIR) $(CMAKE_IPK_DIR) $(CMAKE_IPK)
#
#
# Some sanity check for the package.
#
cmake-check: $(CMAKE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
