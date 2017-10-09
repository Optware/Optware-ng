###########################################################
#
# unionfs-fuse
#
###########################################################
#
# UNIONFS_FUSE_VERSION, UNIONFS_FUSE_SITE and UNIONFS_FUSE_SOURCE define
# the upstream location of the source code for the package.
# UNIONFS_FUSE_DIR is the directory which is created when the source
# archive is unpacked.
# UNIONFS_FUSE_UNZIP is the command used to unzip the source.
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
UNIONFS_FUSE_REPOSITORY=git://github.com/rpodgorny/unionfs-fuse.git
UNIONFS_FUSE_GIT_DATE=20160829
UNIONFS_FUSE_VERSION=1.0+git$(UNIONFS_FUSE_GIT_DATE)
UNIONFS_FUSE_TREEISH=`git rev-list --max-count=1 --until=2016-08-29 HEAD`
UNIONFS_FUSE_SOURCE=unionfs-fuse-$(UNIONFS_FUSE_VERSION).tar.gz
UNIONFS_FUSE_DIR=unionfs-fuse-$(UNIONFS_FUSE_VERSION)
UNIONFS_FUSE_UNZIP=zcat
UNIONFS_FUSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNIONFS_FUSE_DESCRIPTION=unionfs-fuse overlays several directory into one single mount point
UNIONFS_FUSE_SECTION=net
UNIONFS_FUSE_PRIORITY=optional
UNIONFS_FUSE_DEPENDS=fuse
UNIONFS_FUSE_SUGGESTS=
UNIONFS_FUSE_CONFLICTS=

#
# UNIONFS_FUSE_IPK_VERSION should be incremented when the ipk changes.
#
UNIONFS_FUSE_IPK_VERSION=2

#
# UNIONFS_FUSE_CONFFILES should be a list of user-editable files
#UNIONFS_FUSE_CONFFILES=$(TARGET_PREFIX)/etc/unionfs-fuse.conf $(TARGET_PREFIX)/etc/init.d/SXXunionfs-fuse

#
# UNIONFS_FUSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UNIONFS_FUSE_PATCHES=\
$(UNIONFS_FUSE_SOURCE_DIR)/CMakeLists.txt.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNIONFS_FUSE_CPPFLAGS=-DFORTIFY_SOURCE=2
UNIONFS_FUSE_LDFLAGS=

#
# UNIONFS_FUSE_BUILD_DIR is the directory in which the build is done.
# UNIONFS_FUSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNIONFS_FUSE_IPK_DIR is the directory in which the ipk is built.
# UNIONFS_FUSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNIONFS_FUSE_BUILD_DIR=$(BUILD_DIR)/unionfs-fuse
UNIONFS_FUSE_SOURCE_DIR=$(SOURCE_DIR)/unionfs-fuse
UNIONFS_FUSE_IPK_DIR=$(BUILD_DIR)/unionfs-fuse-$(UNIONFS_FUSE_VERSION)-ipk
UNIONFS_FUSE_IPK=$(BUILD_DIR)/unionfs-fuse_$(UNIONFS_FUSE_VERSION)-$(UNIONFS_FUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unionfs-fuse-source unionfs-fuse-unpack unionfs-fuse unionfs-fuse-stage unionfs-fuse-ipk unionfs-fuse-clean unionfs-fuse-dirclean unionfs-fuse-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(UNIONFS_FUSE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(UNIONFS_FUSE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(UNIONFS_FUSE_SOURCE).sha512
#
$(DL_DIR)/$(UNIONFS_FUSE_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf unionfs-fuse && \
		git clone --bare $(UNIONFS_FUSE_REPOSITORY) unionfs-fuse && \
		(cd unionfs-fuse && \
		git archive --format=tar --prefix=$(UNIONFS_FUSE_DIR)/ $(UNIONFS_FUSE_TREEISH) | gzip > $@) && \
		rm -rf unionfs-fuse ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unionfs-fuse-source: $(DL_DIR)/$(UNIONFS_FUSE_SOURCE) $(UNIONFS_FUSE_PATCHES)

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
$(UNIONFS_FUSE_BUILD_DIR)/.configured: $(DL_DIR)/$(UNIONFS_FUSE_SOURCE) $(UNIONFS_FUSE_PATCHES) make/unionfs-fuse.mk
	$(MAKE) attr-stage fuse-stage
	rm -rf $(BUILD_DIR)/$(UNIONFS_FUSE_DIR) $(@D)
	$(UNIONFS_FUSE_UNZIP) $(DL_DIR)/$(UNIONFS_FUSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNIONFS_FUSE_PATCHES)" ; \
		then cat $(UNIONFS_FUSE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(UNIONFS_FUSE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(UNIONFS_FUSE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UNIONFS_FUSE_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(UNIONFS_FUSE_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(UNIONFS_FUSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(UNIONFS_FUSE_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(UNIONFS_FUSE_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(UNIONFS_FUSE_LDFLAGS)" \
		-DWITH_XATTR=1
	touch $@

unionfs-fuse-unpack: $(UNIONFS_FUSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNIONFS_FUSE_BUILD_DIR)/.built: $(UNIONFS_FUSE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
unionfs-fuse: $(UNIONFS_FUSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(UNIONFS_FUSE_BUILD_DIR)/.staged: $(UNIONFS_FUSE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#unionfs-fuse-stage: $(UNIONFS_FUSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unionfs-fuse
#
$(UNIONFS_FUSE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: unionfs-fuse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNIONFS_FUSE_PRIORITY)" >>$@
	@echo "Section: $(UNIONFS_FUSE_SECTION)" >>$@
	@echo "Version: $(UNIONFS_FUSE_VERSION)-$(UNIONFS_FUSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNIONFS_FUSE_MAINTAINER)" >>$@
	@echo "Source: $(UNIONFS_FUSE_REPOSITORY)" >>$@
	@echo "Description: $(UNIONFS_FUSE_DESCRIPTION)" >>$@
	@echo "Depends: $(UNIONFS_FUSE_DEPENDS)" >>$@
	@echo "Suggests: $(UNIONFS_FUSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNIONFS_FUSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/unionfs-fuse/...
# Documentation files should be installed in $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/doc/unionfs-fuse/...
# Daemon startup scripts should be installed in $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??unionfs-fuse
#
# You may need to patch your application to make it use these locations.
#
$(UNIONFS_FUSE_IPK): $(UNIONFS_FUSE_BUILD_DIR)/.built
	rm -rf $(UNIONFS_FUSE_IPK_DIR) $(BUILD_DIR)/unionfs-fuse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNIONFS_FUSE_BUILD_DIR) DESTDIR=$(UNIONFS_FUSE_IPK_DIR) install
	$(STRIP_COMMAND) $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/bin/{unionfs,unionfsctl}
#	$(INSTALL) -m 755 $(UNIONFS_FUSE_SOURCE_DIR)/rc.unionfs-fuse $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXunionfs-fuse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNIONFS_FUSE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXunionfs-fuse
	$(MAKE) $(UNIONFS_FUSE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(UNIONFS_FUSE_SOURCE_DIR)/postinst $(UNIONFS_FUSE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNIONFS_FUSE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(UNIONFS_FUSE_SOURCE_DIR)/prerm $(UNIONFS_FUSE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNIONFS_FUSE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UNIONFS_FUSE_IPK_DIR)/CONTROL/postinst $(UNIONFS_FUSE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(UNIONFS_FUSE_CONFFILES) | sed -e 's/ /\n/g' > $(UNIONFS_FUSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNIONFS_FUSE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(UNIONFS_FUSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unionfs-fuse-ipk: $(UNIONFS_FUSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unionfs-fuse-clean:
	rm -f $(UNIONFS_FUSE_BUILD_DIR)/.built
	-$(MAKE) -C $(UNIONFS_FUSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unionfs-fuse-dirclean:
	rm -rf $(BUILD_DIR)/$(UNIONFS_FUSE_DIR) $(UNIONFS_FUSE_BUILD_DIR) $(UNIONFS_FUSE_IPK_DIR) $(UNIONFS_FUSE_IPK)
#
#
# Some sanity check for the package.
#
unionfs-fuse-check: $(UNIONFS_FUSE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
