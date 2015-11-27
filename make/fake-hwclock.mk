###########################################################
#
# fake-hwclock
#
###########################################################
#
# FAKE_HWCLOCK_VERSION, FAKE_HWCLOCK_SITE and FAKE_HWCLOCK_SOURCE define
# the upstream location of the source code for the package.
# FAKE_HWCLOCK_DIR is the directory which is created when the source
# archive is unpacked.
# FAKE_HWCLOCK_UNZIP is the command used to unzip the source.
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
FAKE_HWCLOCK_URL=http://mirror.datacenter.by/debian/pool/main/f/fake-hwclock/$(FAKE_HWCLOCK_SOURCE)
FAKE_HWCLOCK_VERSION=0.9
FAKE_HWCLOCK_SOURCE=fake-hwclock_$(FAKE_HWCLOCK_VERSION).tar.gz
#FAKE_HWCLOCK_DIR=fake-hwclock-$(FAKE_HWCLOCK_VERSION)
FAKE_HWCLOCK_UNZIP=zcat
FAKE_HWCLOCK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FAKE_HWCLOCK_DESCRIPTION=Save/restore system clock on machines without working RTC hardware.
FAKE_HWCLOCK_SECTION=misc
FAKE_HWCLOCK_PRIORITY=optional
FAKE_HWCLOCK_DEPENDS=
FAKE_HWCLOCK_SUGGESTS=
FAKE_HWCLOCK_CONFLICTS=

#
# FAKE_HWCLOCK_IPK_VERSION should be incremented when the ipk changes.
#
FAKE_HWCLOCK_IPK_VERSION=1

#
# FAKE_HWCLOCK_CONFFILES should be a list of user-editable files
#FAKE_HWCLOCK_CONFFILES=$(TARGET_PREFIX)/etc/fake-hwclock.conf $(TARGET_PREFIX)/etc/init.d/SXXfake-hwclock

#
# FAKE_HWCLOCK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FAKE_HWCLOCK_PATCHES=$(FAKE_HWCLOCK_SOURCE_DIR)/fake-hwclock.data_location.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FAKE_HWCLOCK_CPPFLAGS=
FAKE_HWCLOCK_LDFLAGS=

#
# FAKE_HWCLOCK_BUILD_DIR is the directory in which the build is done.
# FAKE_HWCLOCK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FAKE_HWCLOCK_IPK_DIR is the directory in which the ipk is built.
# FAKE_HWCLOCK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FAKE_HWCLOCK_BUILD_DIR=$(BUILD_DIR)/fake-hwclock
FAKE_HWCLOCK_SOURCE_DIR=$(SOURCE_DIR)/fake-hwclock
FAKE_HWCLOCK_IPK_DIR=$(BUILD_DIR)/fake-hwclock-$(FAKE_HWCLOCK_VERSION)-ipk
FAKE_HWCLOCK_IPK=$(BUILD_DIR)/fake-hwclock_$(FAKE_HWCLOCK_VERSION)-$(FAKE_HWCLOCK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fake-hwclock-source fake-hwclock-unpack fake-hwclock fake-hwclock-stage fake-hwclock-ipk fake-hwclock-clean fake-hwclock-dirclean fake-hwclock-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(FAKE_HWCLOCK_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(FAKE_HWCLOCK_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(FAKE_HWCLOCK_SOURCE).sha512
#
$(DL_DIR)/$(FAKE_HWCLOCK_SOURCE):
	$(WGET) -O $@ $(FAKE_HWCLOCK_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fake-hwclock-source: $(DL_DIR)/$(FAKE_HWCLOCK_SOURCE) $(FAKE_HWCLOCK_PATCHES)

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
$(FAKE_HWCLOCK_BUILD_DIR)/.configured: $(DL_DIR)/$(FAKE_HWCLOCK_SOURCE) $(FAKE_HWCLOCK_PATCHES) make/fake-hwclock.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	$(FAKE_HWCLOCK_UNZIP) $(DL_DIR)/$(FAKE_HWCLOCK_SOURCE) | tar -C $(@D) -xvf - git/fake-hwclock --strip-components=1
	if test -n "$(FAKE_HWCLOCK_PATCHES)" ; \
		then cat $(FAKE_HWCLOCK_PATCHES) | \
		$(PATCH) -d $(@D) -p1 ; \
	fi
	touch $@

fake-hwclock-unpack: $(FAKE_HWCLOCK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FAKE_HWCLOCK_BUILD_DIR)/.built: $(FAKE_HWCLOCK_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fake-hwclock: $(FAKE_HWCLOCK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FAKE_HWCLOCK_BUILD_DIR)/.staged: $(FAKE_HWCLOCK_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

fake-hwclock-stage: $(FAKE_HWCLOCK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fake-hwclock
#
$(FAKE_HWCLOCK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: fake-hwclock" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FAKE_HWCLOCK_PRIORITY)" >>$@
	@echo "Section: $(FAKE_HWCLOCK_SECTION)" >>$@
	@echo "Version: $(FAKE_HWCLOCK_VERSION)-$(FAKE_HWCLOCK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FAKE_HWCLOCK_MAINTAINER)" >>$@
	@echo "Source: $(FAKE_HWCLOCK_URL)" >>$@
	@echo "Description: $(FAKE_HWCLOCK_DESCRIPTION)" >>$@
	@echo "Depends: $(FAKE_HWCLOCK_DEPENDS)" >>$@
	@echo "Suggests: $(FAKE_HWCLOCK_SUGGESTS)" >>$@
	@echo "Conflicts: $(FAKE_HWCLOCK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/fake-hwclock/...
# Documentation files should be installed in $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/doc/fake-hwclock/...
# Daemon startup scripts should be installed in $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??fake-hwclock
#
# You may need to patch your application to make it use these locations.
#
$(FAKE_HWCLOCK_IPK): $(FAKE_HWCLOCK_BUILD_DIR)/.built
	rm -rf $(FAKE_HWCLOCK_IPK_DIR) $(BUILD_DIR)/fake-hwclock_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FAKE_HWCLOCK_BUILD_DIR) DESTDIR=$(FAKE_HWCLOCK_IPK_DIR) install-strip
	$(INSTALL) -d $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/sbin/
	$(INSTALL) -m 755 $(FAKE_HWCLOCK_BUILD_DIR)/fake-hwclock $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/sbin/
#	$(INSTALL) -d $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(FAKE_HWCLOCK_SOURCE_DIR)/fake-hwclock.conf $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/fake-hwclock.conf
#	$(INSTALL) -d $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(FAKE_HWCLOCK_SOURCE_DIR)/rc.fake-hwclock $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfake-hwclock
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FAKE_HWCLOCK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfake-hwclock
	$(MAKE) $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(FAKE_HWCLOCK_SOURCE_DIR)/postinst $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(FAKE_HWCLOCK_SOURCE_DIR)/prerm $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FAKE_HWCLOCK_IPK_DIR)/CONTROL/postinst $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FAKE_HWCLOCK_CONFFILES) | sed -e 's/ /\n/g' > $(FAKE_HWCLOCK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FAKE_HWCLOCK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(FAKE_HWCLOCK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fake-hwclock-ipk: $(FAKE_HWCLOCK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fake-hwclock-clean:
	rm -f $(FAKE_HWCLOCK_BUILD_DIR)/.built
	-$(MAKE) -C $(FAKE_HWCLOCK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fake-hwclock-dirclean:
	rm -rf $(FAKE_HWCLOCK_BUILD_DIR) $(FAKE_HWCLOCK_IPK_DIR) $(FAKE_HWCLOCK_IPK)
#
#
# Some sanity check for the package.
#
fake-hwclock-check: $(FAKE_HWCLOCK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
