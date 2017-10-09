###########################################################
#
# ntfs-3g
#
###########################################################

# You must replace "ntfs-3g" and "NTFS-3G" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NTFS-3G_VERSION, NTFS-3G_SITE and NTFS-3G_SOURCE define
# the upstream location of the source code for the package.
# NTFS-3G_DIR is the directory which is created when the source
# archive is unpacked.
# NTFS-3G_UNZIP is the command used to unzip the source.
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
NTFS-3G_SITE=https://tuxera.com/opensource
NTFS-3G_VERSION=2015.3.14
NTFS-3G_SOURCE=ntfs-3g_ntfsprogs-$(NTFS-3G_VERSION).tgz
NTFS-3G_DIR=ntfs-3g_ntfsprogs-$(NTFS-3G_VERSION)
NTFS-3G_UNZIP=zcat
NTFS-3G_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NTFS-3G_DESCRIPTION=ntfs-3g - Third Generation Read/Write NTFS Driver.
NTFS-3G_SECTION=admin
NTFS-3G_PRIORITY=optional
NTFS-3G_DEPENDS=e2fslibs
NTFS-3G_SUGGESTS=
NTFS-3G_CONFLICTS=

#
# NTFS-3G_IPK_VERSION should be incremented when the ipk changes.
#
NTFS-3G_IPK_VERSION=3

#
# NTFS-3G_CONFFILES should be a list of user-editable files
#NTFS-3G_CONFFILES=$(TARGET_PREFIX)/etc/ntfs-3g.conf $(TARGET_PREFIX)/etc/init.d/SXXntfs-3g

#
# NTFS-3G_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NTFS-3G_PATCHES=$(NTFS-3G_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NTFS-3G_CPPFLAGS=
NTFS-3G_LDFLAGS=

#
# NTFS-3G_BUILD_DIR is the directory in which the build is done.
# NTFS-3G_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NTFS-3G_IPK_DIR is the directory in which the ipk is built.
# NTFS-3G_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NTFS-3G_BUILD_DIR=$(BUILD_DIR)/ntfs-3g
NTFS-3G_SOURCE_DIR=$(SOURCE_DIR)/ntfs-3g
NTFS-3G_IPK_DIR=$(BUILD_DIR)/ntfs-3g-$(NTFS-3G_VERSION)-ipk
NTFS-3G_IPK=$(BUILD_DIR)/ntfs-3g_$(NTFS-3G_VERSION)-$(NTFS-3G_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ntfs-3g-source ntfs-3g-unpack ntfs-3g ntfs-3g-stage ntfs-3g-ipk ntfs-3g-clean ntfs-3g-dirclean ntfs-3g-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NTFS-3G_SOURCE):
	$(WGET) -P $(@D) $(NTFS-3G_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ntfs-3g-source: $(DL_DIR)/$(NTFS-3G_SOURCE) $(NTFS-3G_PATCHES)

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
$(NTFS-3G_BUILD_DIR)/.configured: $(DL_DIR)/$(NTFS-3G_SOURCE) $(NTFS-3G_PATCHES) make/ntfs-3g.mk
	$(MAKE) e2fslibs-stage
	rm -rf $(BUILD_DIR)/$(NTFS-3G_DIR) $(@D)
	$(NTFS-3G_UNZIP) $(DL_DIR)/$(NTFS-3G_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NTFS-3G_PATCHES)" ; \
		then cat $(NTFS-3G_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NTFS-3G_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NTFS-3G_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NTFS-3G_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I../include/fuse-lite $(STAGING_CPPFLAGS) $(NTFS-3G_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NTFS-3G_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(NTFS-3G_IPK_DIR)$(TARGET_PREFIX) \
		--exec_prefix=$(NTFS-3G_IPK_DIR)$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-ldconfig \
		--disable-mount-helper \
		--program-transform-name="" \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ntfs-3g-unpack: $(NTFS-3G_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NTFS-3G_BUILD_DIR)/.built: $(NTFS-3G_BUILD_DIR)/.configured
	rm -f $(NTFS-3G_BUILD_DIR)/.built
	$(MAKE) -C $(NTFS-3G_BUILD_DIR)
	touch $(NTFS-3G_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ntfs-3g: $(NTFS-3G_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ntfs-3g
#
$(NTFS-3G_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ntfs-3g" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTFS-3G_PRIORITY)" >>$@
	@echo "Section: $(NTFS-3G_SECTION)" >>$@
	@echo "Version: $(NTFS-3G_VERSION)-$(NTFS-3G_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTFS-3G_MAINTAINER)" >>$@
	@echo "Source: $(NTFS-3G_SITE)/$(NTFS-3G_SOURCE)" >>$@
	@echo "Description: $(NTFS-3G_DESCRIPTION)" >>$@
	@echo "Depends: $(NTFS-3G_DEPENDS)" >>$@
	@echo "Suggests: $(NTFS-3G_SUGGESTS)" >>$@
	@echo "Conflicts: $(NTFS-3G_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/sbin or $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/ntfs-3g/...
# Documentation files should be installed in $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/doc/ntfs-3g/...
# Daemon startup scripts should be installed in $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ntfs-3g
#
# You may need to patch your application to make it use these locations.
#
$(NTFS-3G_IPK): $(NTFS-3G_BUILD_DIR)/.built
	rm -rf $(NTFS-3G_IPK_DIR) $(BUILD_DIR)/ntfs-3g_*_$(TARGET_ARCH).ipk
	mkdir -p $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(MAKE) -C $(NTFS-3G_BUILD_DIR) install-strip LN_S=':'
	rm -f $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	sed -i -e '/^prefix=\|^exec_prefix=/s|=.*|=$(TARGET_PREFIX)|' $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/libntfs-3g.pc
#	ln -s ../bin/ntfs-3g $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/sbin/mount.ntfs-3g
#	$(INSTALL) -d $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(NTFS-3G_SOURCE_DIR)/ntfs-3g.conf $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/ntfs-3g.conf
#	$(INSTALL) -d $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(NTFS-3G_SOURCE_DIR)/rc.ntfs-3g $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXntfs-3g
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NTFS-3G_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXntfs-3g
	$(MAKE) $(NTFS-3G_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(NTFS-3G_SOURCE_DIR)/postinst $(NTFS-3G_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NTFS-3G_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(NTFS-3G_SOURCE_DIR)/prerm $(NTFS-3G_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NTFS-3G_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NTFS-3G_IPK_DIR)/CONTROL/postinst $(NTFS-3G_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NTFS-3G_CONFFILES) | sed -e 's/ /\n/g' > $(NTFS-3G_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTFS-3G_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ntfs-3g-ipk: $(NTFS-3G_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ntfs-3g-clean:
	rm -f $(NTFS-3G_BUILD_DIR)/.built
	-$(MAKE) -C $(NTFS-3G_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ntfs-3g-dirclean:
	rm -rf $(BUILD_DIR)/$(NTFS-3G_DIR) $(NTFS-3G_BUILD_DIR) $(NTFS-3G_IPK_DIR) $(NTFS-3G_IPK)
#
#
# Some sanity check for the package.
#
ntfs-3g-check: $(NTFS-3G_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
