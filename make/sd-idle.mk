###########################################################
#
# sd-idle
#
###########################################################
#
# SD_IDLE_VERSION, SD_IDLE_SITE and SD_IDLE_SOURCE define
# the upstream location of the source code for the package.
# SD_IDLE_DIR is the directory which is created when the source
# archive is unpacked.
# SD_IDLE_UNZIP is the command used to unzip the source.
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
SD_IDLE_URL=http://tomatousb.org/forum/t-271603/sd-idle-2-6-disk-idle-spindown-program-for-2-6
SD_IDLE_VERSION=2.6
SD_IDLE_SOURCE=$(SD_IDLE_SOURCE_DIR)/sd-idle-$(SD_IDLE_VERSION).c
SD_IDLE_UNZIP=zcat
SD_IDLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SD_IDLE_DESCRIPTION=sd-idle-2.6 is a disk idle spindown program for router firmware based on linux 2.6
SD_IDLE_SECTION=utils
SD_IDLE_PRIORITY=optional
SD_IDLE_DEPENDS=
SD_IDLE_SUGGESTS=
SD_IDLE_CONFLICTS=

#
# SD_IDLE_IPK_VERSION should be incremented when the ipk changes.
#
SD_IDLE_IPK_VERSION=1

#
# SD_IDLE_CONFFILES should be a list of user-editable files
SD_IDLE_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S16sd-idle

#
# SD_IDLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SD_IDLE_PATCHES=$(SD_IDLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SD_IDLE_CPPFLAGS=
SD_IDLE_LDFLAGS=

#
# SD_IDLE_BUILD_DIR is the directory in which the build is done.
# SD_IDLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SD_IDLE_IPK_DIR is the directory in which the ipk is built.
# SD_IDLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SD_IDLE_BUILD_DIR=$(BUILD_DIR)/sd-idle
SD_IDLE_SOURCE_DIR=$(SOURCE_DIR)/sd-idle
SD_IDLE_IPK_DIR=$(BUILD_DIR)/sd-idle-$(SD_IDLE_VERSION)-ipk
SD_IDLE_IPK=$(BUILD_DIR)/sd-idle_$(SD_IDLE_VERSION)-$(SD_IDLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sd-idle-source sd-idle-unpack sd-idle sd-idle-stage sd-idle-ipk sd-idle-clean sd-idle-dirclean sd-idle-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SD_IDLE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SD_IDLE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SD_IDLE_SOURCE).sha512
#
#$(DL_DIR)/$(SD_IDLE_SOURCE):
#	$(WGET) -O $@ $(SD_IDLE_URL) || \
#	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sd-idle-source: $(SD_IDLE_SOURCE)

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
$(SD_IDLE_BUILD_DIR)/.configured: $(SD_IDLE_SOURCE) $(SD_IDLE_PATCHES) make/sd-idle.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	touch $@

sd-idle-unpack: $(SD_IDLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SD_IDLE_BUILD_DIR)/.built: $(SD_IDLE_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CC) $(STAGING_CPPFLAGS) $(SD_IDLE_CPPFLAGS) $(STAGING_LDFLAGS) $(SD_IDLE_LDFLAGS) $(SD_IDLE_SOURCE) -o $(@D)/sd-idle
	touch $@

#
# This is the build convenience target.
#
sd-idle: $(SD_IDLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SD_IDLE_BUILD_DIR)/.staged: $(SD_IDLE_BUILD_DIR)/.built
	rm -f $@
	touch $@

sd-idle-stage: $(SD_IDLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sd-idle
#
$(SD_IDLE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: sd-idle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SD_IDLE_PRIORITY)" >>$@
	@echo "Section: $(SD_IDLE_SECTION)" >>$@
	@echo "Version: $(SD_IDLE_VERSION)-$(SD_IDLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SD_IDLE_MAINTAINER)" >>$@
	@echo "Source: $(SD_IDLE_URL)" >>$@
	@echo "Description: $(SD_IDLE_DESCRIPTION)" >>$@
	@echo "Depends: $(SD_IDLE_DEPENDS)" >>$@
	@echo "Suggests: $(SD_IDLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(SD_IDLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/etc/sd-idle/...
# Documentation files should be installed in $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/doc/sd-idle/...
# Daemon startup scripts should be installed in $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??sd-idle
#
# You may need to patch your application to make it use these locations.
#
$(SD_IDLE_IPK): $(SD_IDLE_BUILD_DIR)/.built
	rm -rf $(SD_IDLE_IPK_DIR) $(BUILD_DIR)/sd-idle_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SD_IDLE_BUILD_DIR)/sd-idle $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SD_IDLE_SOURCE_DIR)/rc.sd-idle $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S16sd-idle
	$(STRIP_COMMAND) $(SD_IDLE_IPK_DIR)$(TARGET_PREFIX)/bin/sd-idle
	$(MAKE) $(SD_IDLE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SD_IDLE_SOURCE_DIR)/postinst $(SD_IDLE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SD_IDLE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SD_IDLE_SOURCE_DIR)/prerm $(SD_IDLE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SD_IDLE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SD_IDLE_IPK_DIR)/CONTROL/postinst $(SD_IDLE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SD_IDLE_CONFFILES) | sed -e 's/ /\n/g' > $(SD_IDLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SD_IDLE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SD_IDLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sd-idle-ipk: $(SD_IDLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sd-idle-clean:
	rm -f $(SD_IDLE_BUILD_DIR)/.built
	-$(MAKE) -C $(SD_IDLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sd-idle-dirclean:
	rm -rf $(BUILD_DIR)/$(SD_IDLE_DIR) $(SD_IDLE_BUILD_DIR) $(SD_IDLE_IPK_DIR) $(SD_IDLE_IPK)
#
#
# Some sanity check for the package.
#
sd-idle-check: $(SD_IDLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
