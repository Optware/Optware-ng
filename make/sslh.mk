###########################################################
#
# sslh
#
###########################################################
#
# SSLH_VERSION, SSLH_SITE and SSLH_SOURCE define
# the upstream location of the source code for the package.
# SSLH_DIR is the directory which is created when the source
# archive is unpacked.
# SSLH_UNZIP is the command used to unzip the source.
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
SSLH_URL=http://rutschle.net/tech/sslh-v$(SSLH_VERSION).tar.gz
SSLH_VERSION=1.17
SSLH_SOURCE=sslh-v$(SSLH_VERSION).tar.gz
SSLH_DIR=sslh-v$(SSLH_VERSION)
SSLH_UNZIP=zcat
SSLH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SSLH_DESCRIPTION=Applicative protocol multiplexer.
SSLH_SECTION=net
SSLH_PRIORITY=optional
SSLH_DEPENDS=pcre, libcap, libconfig, start-stop-daemon
SSLH_SUGGESTS=
SSLH_CONFLICTS=

#
# SSLH_IPK_VERSION should be incremented when the ipk changes.
#
SSLH_IPK_VERSION=2

#
# SSLH_CONFFILES should be a list of user-editable files
SSLH_CONFFILES=$(TARGET_PREFIX)/etc/sslh/sslh.cfg $(TARGET_PREFIX)/etc/init.d/S14sslh.sh

#
# SSLH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SSLH_PATCHES=$(SSLH_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SSLH_CPPFLAGS=
SSLH_LDFLAGS=

#
# SSLH_BUILD_DIR is the directory in which the build is done.
# SSLH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SSLH_IPK_DIR is the directory in which the ipk is built.
# SSLH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SSLH_BUILD_DIR=$(BUILD_DIR)/sslh
SSLH_SOURCE_DIR=$(SOURCE_DIR)/sslh
SSLH_IPK_DIR=$(BUILD_DIR)/sslh-$(SSLH_VERSION)-ipk
SSLH_IPK=$(BUILD_DIR)/sslh_$(SSLH_VERSION)-$(SSLH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sslh-source sslh-unpack sslh sslh-stage sslh-ipk sslh-clean sslh-dirclean sslh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SSLH_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SSLH_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SSLH_SOURCE).sha512
#
$(DL_DIR)/$(SSLH_SOURCE):
	$(WGET) -O $@ $(SSLH_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sslh-source: $(DL_DIR)/$(SSLH_SOURCE) $(SSLH_PATCHES)

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
$(SSLH_BUILD_DIR)/.configured: $(DL_DIR)/$(SSLH_SOURCE) $(SSLH_PATCHES) make/sslh.mk
	$(MAKE) pcre-stage libcap-stage libconfig-stage
	rm -rf $(BUILD_DIR)/$(SSLH_DIR) $(@D)
	$(SSLH_UNZIP) $(DL_DIR)/$(SSLH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SSLH_PATCHES)" ; \
		then cat $(SSLH_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SSLH_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SSLH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SSLH_DIR) $(@D) ; \
	fi
	touch $@

sslh-unpack: $(SSLH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SSLH_BUILD_DIR)/.built: $(SSLH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) -j1 \
		CC="$(TARGET_CC)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(SSLH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSLH_LDFLAGS)" \
		PREFIX=$(TARGET_PREFIX) \
		USELIBCAP=1 \
		USELIBCONFIG=1 \
		USELIBWRAP=
	touch $@

#
# This is the build convenience target.
#
sslh: $(SSLH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SSLH_BUILD_DIR)/.staged: $(SSLH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sslh-stage: $(SSLH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sslh
#
$(SSLH_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: sslh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SSLH_PRIORITY)" >>$@
	@echo "Section: $(SSLH_SECTION)" >>$@
	@echo "Version: $(SSLH_VERSION)-$(SSLH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SSLH_MAINTAINER)" >>$@
	@echo "Source: $(SSLH_URL)" >>$@
	@echo "Description: $(SSLH_DESCRIPTION)" >>$@
	@echo "Depends: $(SSLH_DEPENDS)" >>$@
	@echo "Suggests: $(SSLH_SUGGESTS)" >>$@
	@echo "Conflicts: $(SSLH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SSLH_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SSLH_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SSLH_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/sslh/...
# Documentation files should be installed in $(SSLH_IPK_DIR)$(TARGET_PREFIX)/doc/sslh/...
# Daemon startup scripts should be installed in $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??sslh
#
# You may need to patch your application to make it use these locations.
#
$(SSLH_IPK): $(SSLH_BUILD_DIR)/.built
	rm -rf $(SSLH_IPK_DIR) $(BUILD_DIR)/sslh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SSLH_BUILD_DIR) PREFIX=$(TARGET_PREFIX) DESTDIR=$(SSLH_IPK_DIR) install
	$(INSTALL) -m 755 $(SSLH_BUILD_DIR)/sslh-select $(SSLH_IPK_DIR)$(TARGET_PREFIX)/sbin/sslh-select
	$(STRIP_COMMAND) $(SSLH_IPK_DIR)$(TARGET_PREFIX)/sbin/sslh*
	$(INSTALL) -d $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/sslh
	$(INSTALL) -m 644 $(SSLH_BUILD_DIR)/basic.cfg $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/sslh/sslh.cfg
	$(INSTALL) -d $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(SSLH_SOURCE_DIR)/rc.sslh $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S14sslh.sh
	$(INSTALL) -d $(SSLH_IPK_DIR)$(TARGET_PREFIX)/share/doc/sslh
	$(INSTALL) -m 644 $(SSLH_BUILD_DIR)/example.cfg $(SSLH_IPK_DIR)$(TARGET_PREFIX)/share/doc/sslh
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsslh
	$(MAKE) $(SSLH_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SSLH_SOURCE_DIR)/postinst $(SSLH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLH_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SSLH_SOURCE_DIR)/prerm $(SSLH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SSLH_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SSLH_IPK_DIR)/CONTROL/postinst $(SSLH_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SSLH_CONFFILES) | sed -e 's/ /\n/g' > $(SSLH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SSLH_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SSLH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sslh-ipk: $(SSLH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sslh-clean:
	rm -f $(SSLH_BUILD_DIR)/.built
	-$(MAKE) -C $(SSLH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sslh-dirclean:
	rm -rf $(BUILD_DIR)/$(SSLH_DIR) $(SSLH_BUILD_DIR) $(SSLH_IPK_DIR) $(SSLH_IPK)
#
#
# Some sanity check for the package.
#
sslh-check: $(SSLH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
