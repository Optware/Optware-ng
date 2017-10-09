###########################################################
#
# sshguard
#
###########################################################
#
# SSHGUARD_VERSION, SSHGUARD_SITE and SSHGUARD_SOURCE define
# the upstream location of the source code for the package.
# SSHGUARD_DIR is the directory which is created when the source
# archive is unpacked.
# SSHGUARD_UNZIP is the command used to unzip the source.
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
SSHGUARD_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/sshguard/sshguard-$(SSHGUARD_VERSION).tar.gz
SSHGUARD_VERSION=1.7.1
SSHGUARD_SOURCE=sshguard-$(SSHGUARD_VERSION).tar.gz
SSHGUARD_DIR=sshguard-$(SSHGUARD_VERSION)
SSHGUARD_UNZIP=zcat
SSHGUARD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SSHGUARD_DESCRIPTION=sshguard protects hosts from brute-force attacks against SSH and other services.
SSHGUARD_SECTION=misc
SSHGUARD_PRIORITY=optional
SSHGUARD_DEPENDS=start-stop-daemon
SSHGUARD_SUGGESTS=
SSHGUARD_CONFLICTS=

#
# SSHGUARD_IPK_VERSION should be incremented when the ipk changes.
#
SSHGUARD_IPK_VERSION=4

#
# SSHGUARD_CONFFILES should be a list of user-editable files
SSHGUARD_CONFFILES=$(TARGET_PREFIX)/etc/sshguard/whitelist $(TARGET_PREFIX)/etc/init.d/S15sshguard

#
# SSHGUARD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SSHGUARD_PATCHES=$(SSHGUARD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SSHGUARD_CPPFLAGS=
SSHGUARD_LDFLAGS=

#
# SSHGUARD_BUILD_DIR is the directory in which the build is done.
# SSHGUARD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SSHGUARD_IPK_DIR is the directory in which the ipk is built.
# SSHGUARD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SSHGUARD_BUILD_DIR=$(BUILD_DIR)/sshguard
SSHGUARD_SOURCE_DIR=$(SOURCE_DIR)/sshguard
SSHGUARD_IPK_DIR=$(BUILD_DIR)/sshguard-$(SSHGUARD_VERSION)-ipk
SSHGUARD_IPK=$(BUILD_DIR)/sshguard_$(SSHGUARD_VERSION)-$(SSHGUARD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sshguard-source sshguard-unpack sshguard sshguard-stage sshguard-ipk sshguard-clean sshguard-dirclean sshguard-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SSHGUARD_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SSHGUARD_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SSHGUARD_SOURCE).sha512
#
$(DL_DIR)/$(SSHGUARD_SOURCE):
	$(WGET) -O $@ $(SSHGUARD_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sshguard-source: $(DL_DIR)/$(SSHGUARD_SOURCE) $(SSHGUARD_PATCHES)

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
$(SSHGUARD_BUILD_DIR)/.configured: $(DL_DIR)/$(SSHGUARD_SOURCE) $(SSHGUARD_PATCHES) make/sshguard.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SSHGUARD_DIR) $(@D)
	$(SSHGUARD_UNZIP) $(DL_DIR)/$(SSHGUARD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SSHGUARD_PATCHES)" ; \
		then cat $(SSHGUARD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SSHGUARD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SSHGUARD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SSHGUARD_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SSHGUARD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSHGUARD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-firewall=iptables \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sshguard-unpack: $(SSHGUARD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SSHGUARD_BUILD_DIR)/.built: $(SSHGUARD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sshguard: $(SSHGUARD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SSHGUARD_BUILD_DIR)/.staged: $(SSHGUARD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sshguard-stage: $(SSHGUARD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sshguard
#
$(SSHGUARD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: sshguard" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SSHGUARD_PRIORITY)" >>$@
	@echo "Section: $(SSHGUARD_SECTION)" >>$@
	@echo "Version: $(SSHGUARD_VERSION)-$(SSHGUARD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SSHGUARD_MAINTAINER)" >>$@
	@echo "Source: $(SSHGUARD_URL)" >>$@
	@echo "Description: $(SSHGUARD_DESCRIPTION)" >>$@
	@echo "Depends: $(SSHGUARD_DEPENDS)" >>$@
	@echo "Suggests: $(SSHGUARD_SUGGESTS)" >>$@
	@echo "Conflicts: $(SSHGUARD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/sshguard/...
# Documentation files should be installed in $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/doc/sshguard/...
# Daemon startup scripts should be installed in $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??sshguard
#
# You may need to patch your application to make it use these locations.
#
$(SSHGUARD_IPK): $(SSHGUARD_BUILD_DIR)/.built
	rm -rf $(SSHGUARD_IPK_DIR) $(BUILD_DIR)/sshguard_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SSHGUARD_BUILD_DIR) DESTDIR=$(SSHGUARD_IPK_DIR) install-strip
	$(INSTALL) -d $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/sshguard
	$(INSTALL) -m 644 $(SSHGUARD_SOURCE_DIR)/whitelist $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/sshguard
	$(INSTALL) -d $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(SSHGUARD_SOURCE_DIR)/rc.sshguard $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S15sshguard
	ln -s S15sshguard $(SSHGUARD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K80sshguard
	$(MAKE) $(SSHGUARD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SSHGUARD_SOURCE_DIR)/postinst $(SSHGUARD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSHGUARD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SSHGUARD_SOURCE_DIR)/prerm $(SSHGUARD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSHGUARD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SSHGUARD_IPK_DIR)/CONTROL/postinst $(SSHGUARD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SSHGUARD_CONFFILES) | sed -e 's/ /\n/g' > $(SSHGUARD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SSHGUARD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SSHGUARD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sshguard-ipk: $(SSHGUARD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sshguard-clean:
	rm -f $(SSHGUARD_BUILD_DIR)/.built
	-$(MAKE) -C $(SSHGUARD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sshguard-dirclean:
	rm -rf $(BUILD_DIR)/$(SSHGUARD_DIR) $(SSHGUARD_BUILD_DIR) $(SSHGUARD_IPK_DIR) $(SSHGUARD_IPK)
#
#
# Some sanity check for the package.
#
sshguard-check: $(SSHGUARD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
