###########################################################
#
# nfs-utils
#
###########################################################
#
# NFS_UTILS_VERSION, NFS_UTILS_SITE and NFS_UTILS_SOURCE define
# the upstream location of the source code for the package.
# NFS_UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# NFS_UTILS_UNZIP is the command used to unzip the source.
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
NFS_UTILS_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/nfs/$(NFS_UTILS_SOURCE)
NFS_UTILS_VERSION=2.3.1
NFS_UTILS_SOURCE=nfs-utils-$(NFS_UTILS_VERSION).tar.xz
NFS_UTILS_DIR=nfs-utils-$(NFS_UTILS_VERSION)
NFS_UTILS_UNZIP=xzcat
NFS_UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NFS_UTILS_DESCRIPTION=Kernel NFS Server
NFS_UTILS_SECTION=net
NFS_UTILS_PRIORITY=optional
NFS_UTILS_DEPENDS=libtirpc, rpcbind, busybox-base
NFS_UTILS_SUGGESTS=
NFS_UTILS_CONFLICTS=

#
# NFS_UTILS_IPK_VERSION should be incremented when the ipk changes.
#
NFS_UTILS_IPK_VERSION=2

#
# NFS_UTILS_CONFFILES should be a list of user-editable files
NFS_UTILS_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S56nfs-utils

#
# NFS_UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NFS_UTILS_PATCHES=\
$(NFS_UTILS_SOURCE_DIR)/optware-paths.patch \
$(NFS_UTILS_SOURCE_DIR)/network.c.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NFS_UTILS_CPPFLAGS=
NFS_UTILS_LDFLAGS=

#
# NFS_UTILS_BUILD_DIR is the directory in which the build is done.
# NFS_UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NFS_UTILS_IPK_DIR is the directory in which the ipk is built.
# NFS_UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NFS_UTILS_BUILD_DIR=$(BUILD_DIR)/nfs-utils
NFS_UTILS_SOURCE_DIR=$(SOURCE_DIR)/nfs-utils
NFS_UTILS_IPK_DIR=$(BUILD_DIR)/nfs-utils-$(NFS_UTILS_VERSION)-ipk
NFS_UTILS_IPK=$(BUILD_DIR)/nfs-utils_$(NFS_UTILS_VERSION)-$(NFS_UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nfs-utils-source nfs-utils-unpack nfs-utils nfs-utils-stage nfs-utils-ipk nfs-utils-clean nfs-utils-dirclean nfs-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(NFS_UTILS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(NFS_UTILS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(NFS_UTILS_SOURCE).sha512
#
$(DL_DIR)/$(NFS_UTILS_SOURCE):
	$(WGET) -O $@ $(NFS_UTILS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nfs-utils-source: $(DL_DIR)/$(NFS_UTILS_SOURCE) $(NFS_UTILS_PATCHES)

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
$(NFS_UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(NFS_UTILS_SOURCE) $(NFS_UTILS_PATCHES) make/nfs-utils.mk
	$(MAKE) libtirpc-stage
	rm -rf $(BUILD_DIR)/$(NFS_UTILS_DIR) $(@D)
	$(NFS_UTILS_UNZIP) $(DL_DIR)/$(NFS_UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NFS_UTILS_PATCHES)" ; \
		then cat $(NFS_UTILS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NFS_UTILS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NFS_UTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NFS_UTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NFS_UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NFS_UTILS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-statdpath=$(TARGET_PREFIX)/var/lib/nfs \
		--with-statedir=$(TARGET_PREFIX)/var/lib/nfs \
		--with-mountfile=$(TARGET_PREFIX)/etc/nfsmount.conf \
		--with-nfsconfig=$(TARGET_PREFIX)/etc/nfs.conf \
		--disable-nls \
		--disable-static \
		--disable-ldap \
		--disable-uuid \
		--with-statduser=nobody \
		--enable-nfsv3 \
		--disable-nfsv4 \
		--disable-gss \
		--without-tcp-wrappers \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nfs-utils-unpack: $(NFS_UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NFS_UTILS_BUILD_DIR)/.built: $(NFS_UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/tools/locktest \
		CPPFLAGS=""
	$(MAKE) -C $(@D) \
		startstatd=$(TARGET_PREFIX)/sbin/start-statd
	touch $@

#
# This is the build convenience target.
#
nfs-utils: $(NFS_UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NFS_UTILS_BUILD_DIR)/.staged: $(NFS_UTILS_BUILD_DIR)/.built
	rm -f $@
	touch $@

nfs-utils-stage: $(NFS_UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nfs-utils
#
$(NFS_UTILS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: nfs-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NFS_UTILS_PRIORITY)" >>$@
	@echo "Section: $(NFS_UTILS_SECTION)" >>$@
	@echo "Version: $(NFS_UTILS_VERSION)-$(NFS_UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NFS_UTILS_MAINTAINER)" >>$@
	@echo "Source: $(NFS_UTILS_URL)" >>$@
	@echo "Description: $(NFS_UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(NFS_UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(NFS_UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NFS_UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/nfs-utils/...
# Documentation files should be installed in $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/doc/nfs-utils/...
# Daemon startup scripts should be installed in $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??nfs-utils
#
# You may need to patch your application to make it use these locations.
#
$(NFS_UTILS_IPK): $(NFS_UTILS_BUILD_DIR)/.built
	rm -rf $(NFS_UTILS_IPK_DIR) $(BUILD_DIR)/nfs-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NFS_UTILS_BUILD_DIR) DESTDIR=$(NFS_UTILS_IPK_DIR) install-strip \
		sbindir=$(TARGET_PREFIX)/sbin
	$(INSTALL) -d $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/share/doc/nfs-utils
	$(INSTALL) -m 644 $(NFS_UTILS_SOURCE_DIR)/exports $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/share/doc/nfs-utils
#	$(INSTALL) -d $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(NFS_UTILS_SOURCE_DIR)/nfs-utils.conf $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/nfs-utils.conf
	$(INSTALL) -d $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(NFS_UTILS_SOURCE_DIR)/rc.nfs-utils $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S56nfs-utils
	ln -sf S56nfs-utils $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K48nfs-utils
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NFS_UTILS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXnfs-utils
	$(MAKE) $(NFS_UTILS_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(NFS_UTILS_SOURCE_DIR)/postinst $(NFS_UTILS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NFS_UTILS_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(NFS_UTILS_SOURCE_DIR)/prerm $(NFS_UTILS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NFS_UTILS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NFS_UTILS_IPK_DIR)/CONTROL/postinst $(NFS_UTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NFS_UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(NFS_UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NFS_UTILS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NFS_UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nfs-utils-ipk: $(NFS_UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nfs-utils-clean:
	rm -f $(NFS_UTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(NFS_UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nfs-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(NFS_UTILS_DIR) $(NFS_UTILS_BUILD_DIR) $(NFS_UTILS_IPK_DIR) $(NFS_UTILS_IPK)
#
#
# Some sanity check for the package.
#
nfs-utils-check: $(NFS_UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
