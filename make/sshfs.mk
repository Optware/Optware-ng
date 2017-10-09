###########################################################
#
# sshfs
#
###########################################################
#
# SSHFS_VERSION, SSHFS_SITE and SSHFS_SOURCE define
# the upstream location of the source code for the package.
# SSHFS_DIR is the directory which is created when the source
# archive is unpacked.
# SSHFS_UNZIP is the command used to unzip the source.
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
SSHFS_URL=https://github.com/libfuse/sshfs/releases/download/sshfs-$(SSHFS_VERSION)/sshfs-$(SSHFS_VERSION).tar.gz
http://$(SOURCEFORGE_MIRROR)/sourceforge/sshfs/sshfs-$(SSHFS_VERSION).tar.gz
SSHFS_VERSION=2.7
SSHFS_SOURCE=sshfs-$(SSHFS_VERSION).tar.gz
SSHFS_DIR=sshfs-$(SSHFS_VERSION)
SSHFS_UNZIP=zcat
SSHFS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SSHFS_DESCRIPTION=A network filesystem client to connect to SSH servers.
SSHFS_SECTION=misc
SSHFS_PRIORITY=optional
SSHFS_DEPENDS=glib, libfuse, openssh
SSHFS_SUGGESTS=
SSHFS_CONFLICTS=

#
# SSHFS_IPK_VERSION should be incremented when the ipk changes.
#
SSHFS_IPK_VERSION=2

#
# SSHFS_CONFFILES should be a list of user-editable files
#SSHFS_CONFFILES=$(TARGET_PREFIX)/etc/sshfs.conf $(TARGET_PREFIX)/etc/init.d/SXXsshfs

#
# SSHFS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SSHFS_PATCHES=\
$(SSHFS_SOURCE_DIR)/configure.patch \
$(SSHFS_SOURCE_DIR)/default_ssh_cmd.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SSHFS_CPPFLAGS=
SSHFS_LDFLAGS=

#
# SSHFS_BUILD_DIR is the directory in which the build is done.
# SSHFS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SSHFS_IPK_DIR is the directory in which the ipk is built.
# SSHFS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SSHFS_BUILD_DIR=$(BUILD_DIR)/sshfs
SSHFS_SOURCE_DIR=$(SOURCE_DIR)/sshfs
SSHFS_IPK_DIR=$(BUILD_DIR)/sshfs-$(SSHFS_VERSION)-ipk
SSHFS_IPK=$(BUILD_DIR)/sshfs_$(SSHFS_VERSION)-$(SSHFS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sshfs-source sshfs-unpack sshfs sshfs-stage sshfs-ipk sshfs-clean sshfs-dirclean sshfs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SSHFS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SSHFS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SSHFS_SOURCE).sha512
#
$(DL_DIR)/$(SSHFS_SOURCE):
	$(WGET) -O $@ $(SSHFS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sshfs-source: $(DL_DIR)/$(SSHFS_SOURCE) $(SSHFS_PATCHES)

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
$(SSHFS_BUILD_DIR)/.configured: $(DL_DIR)/$(SSHFS_SOURCE) $(SSHFS_PATCHES) make/sshfs.mk
	$(MAKE) glib-stage fuse-stage
	rm -rf $(BUILD_DIR)/$(SSHFS_DIR) $(@D)
	$(SSHFS_UNZIP) $(DL_DIR)/$(SSHFS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SSHFS_PATCHES)" ; \
		then cat $(SSHFS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SSHFS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SSHFS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SSHFS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SSHFS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSHFS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--program-transform-name='s///' \
		--disable-sshnodelay \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sshfs-unpack: $(SSHFS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SSHFS_BUILD_DIR)/.built: $(SSHFS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sshfs: $(SSHFS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SSHFS_BUILD_DIR)/.staged: $(SSHFS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sshfs-stage: $(SSHFS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sshfs
#
$(SSHFS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: sshfs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SSHFS_PRIORITY)" >>$@
	@echo "Section: $(SSHFS_SECTION)" >>$@
	@echo "Version: $(SSHFS_VERSION)-$(SSHFS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SSHFS_MAINTAINER)" >>$@
	@echo "Source: $(SSHFS_URL)" >>$@
	@echo "Description: $(SSHFS_DESCRIPTION)" >>$@
	@echo "Depends: $(SSHFS_DEPENDS)" >>$@
	@echo "Suggests: $(SSHFS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SSHFS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/sshfs/...
# Documentation files should be installed in $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/doc/sshfs/...
# Daemon startup scripts should be installed in $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??sshfs
#
# You may need to patch your application to make it use these locations.
#
$(SSHFS_IPK): $(SSHFS_BUILD_DIR)/.built
	rm -rf $(SSHFS_IPK_DIR) $(BUILD_DIR)/sshfs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SSHFS_BUILD_DIR) DESTDIR=$(SSHFS_IPK_DIR) install-strip
#	$(INSTALL) -d $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SSHFS_SOURCE_DIR)/sshfs.conf $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/sshfs.conf
#	$(INSTALL) -d $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SSHFS_SOURCE_DIR)/rc.sshfs $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsshfs
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSHFS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsshfs
	$(MAKE) $(SSHFS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SSHFS_SOURCE_DIR)/postinst $(SSHFS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSHFS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SSHFS_SOURCE_DIR)/prerm $(SSHFS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSHFS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SSHFS_IPK_DIR)/CONTROL/postinst $(SSHFS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SSHFS_CONFFILES) | sed -e 's/ /\n/g' > $(SSHFS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SSHFS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SSHFS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sshfs-ipk: $(SSHFS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sshfs-clean:
	rm -f $(SSHFS_BUILD_DIR)/.built
	-$(MAKE) -C $(SSHFS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sshfs-dirclean:
	rm -rf $(BUILD_DIR)/$(SSHFS_DIR) $(SSHFS_BUILD_DIR) $(SSHFS_IPK_DIR) $(SSHFS_IPK)
#
#
# Some sanity check for the package.
#
sshfs-check: $(SSHFS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
