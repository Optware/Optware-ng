###########################################################
#
# zsync
#
###########################################################
#
# ZSYNC_VERSION, ZSYNC_SITE and ZSYNC_SOURCE define
# the upstream location of the source code for the package.
# ZSYNC_DIR is the directory which is created when the source
# archive is unpacked.
# ZSYNC_UNZIP is the command used to unzip the source.
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
ZSYNC_URL=http://zsync.moria.org.uk/download/zsync-$(ZSYNC_VERSION).tar.bz2
ZSYNC_VERSION=0.6.2
ZSYNC_SOURCE=zsync-$(ZSYNC_VERSION).tar.bz2
ZSYNC_DIR=zsync-$(ZSYNC_VERSION)
ZSYNC_UNZIP=bzcat
ZSYNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZSYNC_DESCRIPTION=client-side implementation of the rsync algorithm
ZSYNC_SECTION=net
ZSYNC_PRIORITY=optional
ZSYNC_DEPENDS=
ZSYNC_SUGGESTS=
ZSYNC_CONFLICTS=

#
# ZSYNC_IPK_VERSION should be incremented when the ipk changes.
#
ZSYNC_IPK_VERSION=2

#
# ZSYNC_CONFFILES should be a list of user-editable files
#ZSYNC_CONFFILES=$(TARGET_PREFIX)/etc/zsync.conf $(TARGET_PREFIX)/etc/init.d/SXXzsync

#
# ZSYNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ZSYNC_PATCHES=$(ZSYNC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZSYNC_CPPFLAGS=
ZSYNC_LDFLAGS=

#
# ZSYNC_BUILD_DIR is the directory in which the build is done.
# ZSYNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZSYNC_IPK_DIR is the directory in which the ipk is built.
# ZSYNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZSYNC_BUILD_DIR=$(BUILD_DIR)/zsync
ZSYNC_SOURCE_DIR=$(SOURCE_DIR)/zsync
ZSYNC_IPK_DIR=$(BUILD_DIR)/zsync-$(ZSYNC_VERSION)-ipk
ZSYNC_IPK=$(BUILD_DIR)/zsync_$(ZSYNC_VERSION)-$(ZSYNC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: zsync-source zsync-unpack zsync zsync-stage zsync-ipk zsync-clean zsync-dirclean zsync-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(ZSYNC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(ZSYNC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(ZSYNC_SOURCE).sha512
#
$(DL_DIR)/$(ZSYNC_SOURCE):
	$(WGET) -O $@ $(ZSYNC_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
zsync-source: $(DL_DIR)/$(ZSYNC_SOURCE) $(ZSYNC_PATCHES)

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
$(ZSYNC_BUILD_DIR)/.configured: $(DL_DIR)/$(ZSYNC_SOURCE) $(ZSYNC_PATCHES) make/zsync.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ZSYNC_DIR) $(@D)
	$(ZSYNC_UNZIP) $(DL_DIR)/$(ZSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZSYNC_PATCHES)" ; \
		then cat $(ZSYNC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ZSYNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ZSYNC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ZSYNC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ZSYNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ZSYNC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

zsync-unpack: $(ZSYNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZSYNC_BUILD_DIR)/.built: $(ZSYNC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
zsync: $(ZSYNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(ZSYNC_BUILD_DIR)/.staged: $(ZSYNC_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#zsync-stage: $(ZSYNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/zsync
#
$(ZSYNC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: zsync" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZSYNC_PRIORITY)" >>$@
	@echo "Section: $(ZSYNC_SECTION)" >>$@
	@echo "Version: $(ZSYNC_VERSION)-$(ZSYNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZSYNC_MAINTAINER)" >>$@
	@echo "Source: $(ZSYNC_URL)" >>$@
	@echo "Description: $(ZSYNC_DESCRIPTION)" >>$@
	@echo "Depends: $(ZSYNC_DEPENDS)" >>$@
	@echo "Suggests: $(ZSYNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZSYNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/zsync/...
# Documentation files should be installed in $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/doc/zsync/...
# Daemon startup scripts should be installed in $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??zsync
#
# You may need to patch your application to make it use these locations.
#
$(ZSYNC_IPK): $(ZSYNC_BUILD_DIR)/.built
	rm -rf $(ZSYNC_IPK_DIR) $(BUILD_DIR)/zsync_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ZSYNC_BUILD_DIR) DESTDIR=$(ZSYNC_IPK_DIR) install-strip
#	$(INSTALL) -d $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ZSYNC_SOURCE_DIR)/zsync.conf $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/zsync.conf
#	$(INSTALL) -d $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ZSYNC_SOURCE_DIR)/rc.zsync $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXzsync
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ZSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXzsync
	$(MAKE) $(ZSYNC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ZSYNC_SOURCE_DIR)/postinst $(ZSYNC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ZSYNC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ZSYNC_SOURCE_DIR)/prerm $(ZSYNC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ZSYNC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ZSYNC_IPK_DIR)/CONTROL/postinst $(ZSYNC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ZSYNC_CONFFILES) | sed -e 's/ /\n/g' > $(ZSYNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZSYNC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ZSYNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
zsync-ipk: $(ZSYNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
zsync-clean:
	rm -f $(ZSYNC_BUILD_DIR)/.built
	-$(MAKE) -C $(ZSYNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
zsync-dirclean:
	rm -rf $(BUILD_DIR)/$(ZSYNC_DIR) $(ZSYNC_BUILD_DIR) $(ZSYNC_IPK_DIR) $(ZSYNC_IPK)
#
#
# Some sanity check for the package.
#
zsync-check: $(ZSYNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
