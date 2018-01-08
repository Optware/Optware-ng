###########################################################
#
# rpcbind
#
###########################################################
#
# RPCBIND_VERSION, RPCBIND_SITE and RPCBIND_SOURCE define
# the upstream location of the source code for the package.
# RPCBIND_DIR is the directory which is created when the source
# archive is unpacked.
# RPCBIND_UNZIP is the command used to unzip the source.
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
RPCBIND_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/rpcbind/$(RPCBIND_SOURCE)
RPCBIND_VERSION=0.2.4
RPCBIND_SOURCE=rpcbind-$(RPCBIND_VERSION).tar.bz2
RPCBIND_DIR=rpcbind-$(RPCBIND_VERSION)
RPCBIND_UNZIP=bzcat
RPCBIND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RPCBIND_DESCRIPTION=The rpcbind program is a replacement for portmap. It is required for import or export of Network File System (NFS) shared directories.
RPCBIND_SECTION=net
RPCBIND_PRIORITY=optional
RPCBIND_DEPENDS=libtirpc, busybox-base
RPCBIND_SUGGESTS=
RPCBIND_CONFLICTS=

#
# RPCBIND_IPK_VERSION should be incremented when the ipk changes.
#
RPCBIND_IPK_VERSION=1

#
# RPCBIND_CONFFILES should be a list of user-editable files
RPCBIND_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S22rpcbind

#
# RPCBIND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RPCBIND_PATCHES=\
$(RPCBIND_SOURCE_DIR)/vulnerability_fixes-1.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RPCBIND_CPPFLAGS=
RPCBIND_LDFLAGS=

#
# RPCBIND_BUILD_DIR is the directory in which the build is done.
# RPCBIND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RPCBIND_IPK_DIR is the directory in which the ipk is built.
# RPCBIND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RPCBIND_BUILD_DIR=$(BUILD_DIR)/rpcbind
RPCBIND_SOURCE_DIR=$(SOURCE_DIR)/rpcbind
RPCBIND_IPK_DIR=$(BUILD_DIR)/rpcbind-$(RPCBIND_VERSION)-ipk
RPCBIND_IPK=$(BUILD_DIR)/rpcbind_$(RPCBIND_VERSION)-$(RPCBIND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rpcbind-source rpcbind-unpack rpcbind rpcbind-stage rpcbind-ipk rpcbind-clean rpcbind-dirclean rpcbind-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(RPCBIND_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(RPCBIND_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(RPCBIND_SOURCE).sha512
#
$(DL_DIR)/$(RPCBIND_SOURCE):
	$(WGET) -O $@ $(RPCBIND_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rpcbind-source: $(DL_DIR)/$(RPCBIND_SOURCE) $(RPCBIND_PATCHES)

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
$(RPCBIND_BUILD_DIR)/.configured: $(DL_DIR)/$(RPCBIND_SOURCE) $(RPCBIND_PATCHES) make/rpcbind.mk
	$(MAKE) libtirpc-stage
	rm -rf $(BUILD_DIR)/$(RPCBIND_DIR) $(@D)
	$(RPCBIND_UNZIP) $(DL_DIR)/$(RPCBIND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RPCBIND_PATCHES)" ; \
		then cat $(RPCBIND_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RPCBIND_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RPCBIND_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RPCBIND_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RPCBIND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RPCBIND_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--bindir=$(TARGET_PREFIX)/sbin \
		--with-rpcuser=root \
		--enable-warmstarts \
		--without-systemdsystemunitdir \
	)
	touch $@

rpcbind-unpack: $(RPCBIND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RPCBIND_BUILD_DIR)/.built: $(RPCBIND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
rpcbind: $(RPCBIND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RPCBIND_BUILD_DIR)/.staged: $(RPCBIND_BUILD_DIR)/.built
	rm -f $@
	touch $@

rpcbind-stage: $(RPCBIND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rpcbind
#
$(RPCBIND_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: rpcbind" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RPCBIND_PRIORITY)" >>$@
	@echo "Section: $(RPCBIND_SECTION)" >>$@
	@echo "Version: $(RPCBIND_VERSION)-$(RPCBIND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RPCBIND_MAINTAINER)" >>$@
	@echo "Source: $(RPCBIND_URL)" >>$@
	@echo "Description: $(RPCBIND_DESCRIPTION)" >>$@
	@echo "Depends: $(RPCBIND_DEPENDS)" >>$@
	@echo "Suggests: $(RPCBIND_SUGGESTS)" >>$@
	@echo "Conflicts: $(RPCBIND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/rpcbind/...
# Documentation files should be installed in $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/doc/rpcbind/...
# Daemon startup scripts should be installed in $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??rpcbind
#
# You may need to patch your application to make it use these locations.
#
$(RPCBIND_IPK): $(RPCBIND_BUILD_DIR)/.built
	rm -rf $(RPCBIND_IPK_DIR) $(BUILD_DIR)/rpcbind_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RPCBIND_BUILD_DIR) DESTDIR=$(RPCBIND_IPK_DIR) install-strip
#	$(INSTALL) -d $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(RPCBIND_SOURCE_DIR)/rpcbind.conf $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/rpcbind.conf
	$(INSTALL) -d $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(RPCBIND_SOURCE_DIR)/rc.rpcbind $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S22rpcbind
	ln -sf S22rpcbind $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K49rpcbind
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RPCBIND_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrpcbind
	$(MAKE) $(RPCBIND_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(RPCBIND_SOURCE_DIR)/postinst $(RPCBIND_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RPCBIND_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(RPCBIND_SOURCE_DIR)/prerm $(RPCBIND_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RPCBIND_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(RPCBIND_IPK_DIR)/CONTROL/postinst $(RPCBIND_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(RPCBIND_CONFFILES) | sed -e 's/ /\n/g' > $(RPCBIND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RPCBIND_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RPCBIND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rpcbind-ipk: $(RPCBIND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rpcbind-clean:
	rm -f $(RPCBIND_BUILD_DIR)/.built
	-$(MAKE) -C $(RPCBIND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rpcbind-dirclean:
	rm -rf $(BUILD_DIR)/$(RPCBIND_DIR) $(RPCBIND_BUILD_DIR) $(RPCBIND_IPK_DIR) $(RPCBIND_IPK)
#
#
# Some sanity check for the package.
#
rpcbind-check: $(RPCBIND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
