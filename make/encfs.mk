###########################################################
#
# encfs
#
###########################################################
#
# ENCFS_VERSION, ENCFS_SITE and ENCFS_SOURCE define
# the upstream location of the source code for the package.
# ENCFS_DIR is the directory which is created when the source
# archive is unpacked.
# ENCFS_UNZIP is the command used to unzip the source.
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
ENCFS_URL=https://github.com/vgough/encfs/archive/v$(ENCFS_VERSION).tar.gz
ENCFS_VERSION=1.9-rc1
ENCFS_SOURCE=encfs-$(ENCFS_VERSION).tar.gz
ENCFS_DIR=encfs-$(ENCFS_VERSION)
ENCFS_UNZIP=zcat
ENCFS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENCFS_DESCRIPTION=EncFS provides an encrypted filesystem in user-space.
ENCFS_SECTION=misc
ENCFS_PRIORITY=optional
ENCFS_DEPENDS=fuse, openssl
ENCFS_SUGGESTS=
ENCFS_CONFLICTS=

#
# ENCFS_IPK_VERSION should be incremented when the ipk changes.
#
ENCFS_IPK_VERSION=5

#
# ENCFS_CONFFILES should be a list of user-editable files
#ENCFS_CONFFILES=$(TARGET_PREFIX)/etc/encfs.conf $(TARGET_PREFIX)/etc/init.d/SXXencfs

#
# ENCFS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ENCFS_PATCHES=$(ENCFS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENCFS_CPPFLAGS=-std=c++11
ENCFS_LDFLAGS=

#
# ENCFS_BUILD_DIR is the directory in which the build is done.
# ENCFS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENCFS_IPK_DIR is the directory in which the ipk is built.
# ENCFS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENCFS_BUILD_DIR=$(BUILD_DIR)/encfs
ENCFS_SOURCE_DIR=$(SOURCE_DIR)/encfs
ENCFS_IPK_DIR=$(BUILD_DIR)/encfs-$(ENCFS_VERSION)-ipk
ENCFS_IPK=$(BUILD_DIR)/encfs_$(ENCFS_VERSION)-$(ENCFS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: encfs-source encfs-unpack encfs encfs-stage encfs-ipk encfs-clean encfs-dirclean encfs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(ENCFS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(ENCFS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(ENCFS_SOURCE).sha512
#
$(DL_DIR)/$(ENCFS_SOURCE):
	$(WGET) -O $@ $(ENCFS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
encfs-source: $(DL_DIR)/$(ENCFS_SOURCE) $(ENCFS_PATCHES)

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
$(ENCFS_BUILD_DIR)/.configured: $(DL_DIR)/$(ENCFS_SOURCE) $(ENCFS_PATCHES) make/encfs.mk
	$(MAKE) fuse-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(ENCFS_DIR) $(@D)
	$(ENCFS_UNZIP) $(DL_DIR)/$(ENCFS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ENCFS_PATCHES)" ; \
		then cat $(ENCFS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ENCFS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENCFS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENCFS_DIR) $(@D) ; \
	fi
	sed -i -e '/find_package (OpenSSL/s/^/#/' -e '/list(APPEND CMAKE_CXX_FLAGS "-std=c++11")/s/^/#/' $(@D)/CMakeLists.txt
	mkdir -p $(@D)/build
	cd $(@D)/build; \
		CFLAGS="$(STAGING_CPPFLAGS) $(ENCFS_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(ENCFS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		cmake .. \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(ENCFS_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(ENCFS_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(ENCFS_LDFLAGS)" \
		-DOPENSSL_LIBRARIES="-lcrypto -lssl" \
		-DOPENSSL_INCLUDE_DIR="$(STAGING_INCLUDE_DIR)"
	touch $@

encfs-unpack: $(ENCFS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENCFS_BUILD_DIR)/.built: $(ENCFS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/build
	touch $@

#
# This is the build convenience target.
#
encfs: $(ENCFS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ENCFS_BUILD_DIR)/.staged: $(ENCFS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D)/build DESTDIR=$(STAGING_DIR) install
	touch $@

encfs-stage: $(ENCFS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/encfs
#
$(ENCFS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: encfs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENCFS_PRIORITY)" >>$@
	@echo "Section: $(ENCFS_SECTION)" >>$@
	@echo "Version: $(ENCFS_VERSION)-$(ENCFS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENCFS_MAINTAINER)" >>$@
	@echo "Source: $(ENCFS_URL)" >>$@
	@echo "Description: $(ENCFS_DESCRIPTION)" >>$@
	@echo "Depends: $(ENCFS_DEPENDS)" >>$@
	@echo "Suggests: $(ENCFS_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENCFS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/encfs/...
# Documentation files should be installed in $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/doc/encfs/...
# Daemon startup scripts should be installed in $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??encfs
#
# You may need to patch your application to make it use these locations.
#
$(ENCFS_IPK): $(ENCFS_BUILD_DIR)/.built
	rm -rf $(ENCFS_IPK_DIR) $(BUILD_DIR)/encfs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ENCFS_BUILD_DIR)/build DESTDIR=$(ENCFS_IPK_DIR) install
	$(STRIP_COMMAND) $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/bin/{encfs,encfsctl}
	chmod 755 $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/bin/encfssh
	# only static libs there
	rm -rf $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/lib
	# since we removed libs...
	rm -rf $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/include
#	$(INSTALL) -d $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ENCFS_SOURCE_DIR)/encfs.conf $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/encfs.conf
#	$(INSTALL) -d $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ENCFS_SOURCE_DIR)/rc.encfs $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXencfs
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ENCFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXencfs
	$(MAKE) $(ENCFS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ENCFS_SOURCE_DIR)/postinst $(ENCFS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ENCFS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ENCFS_SOURCE_DIR)/prerm $(ENCFS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ENCFS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ENCFS_IPK_DIR)/CONTROL/postinst $(ENCFS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ENCFS_CONFFILES) | sed -e 's/ /\n/g' > $(ENCFS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENCFS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ENCFS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
encfs-ipk: $(ENCFS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
encfs-clean:
	rm -f $(ENCFS_BUILD_DIR)/.built
	-$(MAKE) -C $(ENCFS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
encfs-dirclean:
	rm -rf $(BUILD_DIR)/$(ENCFS_DIR) $(ENCFS_BUILD_DIR) $(ENCFS_IPK_DIR) $(ENCFS_IPK)
#
#
# Some sanity check for the package.
#
encfs-check: $(ENCFS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
