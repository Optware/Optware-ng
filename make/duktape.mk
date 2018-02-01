###########################################################
#
# duktape
#
###########################################################
#
# DUKTAPE_VERSION, DUKTAPE_SITE and DUKTAPE_SOURCE define
# the upstream location of the source code for the package.
# DUKTAPE_DIR is the directory which is created when the source
# archive is unpacked.
# DUKTAPE_UNZIP is the command used to unzip the source.
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
DUKTAPE_URL=http://duktape.org/$(DUKTAPE_SOURCE)
DUKTAPE_VERSION=2.2.0
DUKTAPE_SOURCE=duktape-$(DUKTAPE_VERSION).tar.xz
DUKTAPE_DIR=duktape-$(DUKTAPE_VERSION)
DUKTAPE_UNZIP=xzcat
DUKTAPE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DUKTAPE_DESCRIPTION=Duktape JavaScript engine.
DUKTAPE_SECTION=libs
DUKTAPE_PRIORITY=optional
DUKTAPE_DEPENDS=readline, ncurses
DUKTAPE_SUGGESTS=
DUKTAPE_CONFLICTS=

#
# DUKTAPE_IPK_VERSION should be incremented when the ipk changes.
#
DUKTAPE_IPK_VERSION=2

#
# DUKTAPE_CONFFILES should be a list of user-editable files
#DUKTAPE_CONFFILES=$(TARGET_PREFIX)/etc/duktape.conf $(TARGET_PREFIX)/etc/init.d/SXXduktape

#
# DUKTAPE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DUKTAPE_PATCHES=\
$(DUKTAPE_SOURCE_DIR)/shared-library.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DUKTAPE_CPPFLAGS=
DUKTAPE_LDFLAGS=

#
# DUKTAPE_BUILD_DIR is the directory in which the build is done.
# DUKTAPE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DUKTAPE_IPK_DIR is the directory in which the ipk is built.
# DUKTAPE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DUKTAPE_BUILD_DIR=$(BUILD_DIR)/duktape
DUKTAPE_SOURCE_DIR=$(SOURCE_DIR)/duktape
DUKTAPE_IPK_DIR=$(BUILD_DIR)/duktape-$(DUKTAPE_VERSION)-ipk
DUKTAPE_IPK=$(BUILD_DIR)/duktape_$(DUKTAPE_VERSION)-$(DUKTAPE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: duktape-source duktape-unpack duktape duktape-stage duktape-ipk duktape-clean duktape-dirclean duktape-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(DUKTAPE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(DUKTAPE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(DUKTAPE_SOURCE).sha512
#
$(DL_DIR)/$(DUKTAPE_SOURCE):
	$(WGET) -O $@ $(DUKTAPE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
duktape-source: $(DL_DIR)/$(DUKTAPE_SOURCE) $(DUKTAPE_PATCHES)

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
$(DUKTAPE_BUILD_DIR)/.configured: $(DL_DIR)/$(DUKTAPE_SOURCE) $(DUKTAPE_PATCHES) make/duktape.mk
	$(MAKE) readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(DUKTAPE_DIR) $(@D)
	$(DUKTAPE_UNZIP) $(DL_DIR)/$(DUKTAPE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DUKTAPE_PATCHES)" ; \
		then cat $(DUKTAPE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DUKTAPE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DUKTAPE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DUKTAPE_DIR) $(@D) ; \
	fi
	cp -af $(@D)/Makefile.sharedlibrary $(@D)/Makefile
	touch $@

duktape-unpack: $(DUKTAPE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DUKTAPE_BUILD_DIR)/.built: $(DUKTAPE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CC=$(TARGET_CC) \
		CFLAGS="$(STAGING_CPPFLAGS) $(DUKTAPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DUKTAPE_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
duktape: $(DUKTAPE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DUKTAPE_BUILD_DIR)/.staged: $(DUKTAPE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

duktape-stage: $(DUKTAPE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/duktape
#
$(DUKTAPE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: duktape" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DUKTAPE_PRIORITY)" >>$@
	@echo "Section: $(DUKTAPE_SECTION)" >>$@
	@echo "Version: $(DUKTAPE_VERSION)-$(DUKTAPE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DUKTAPE_MAINTAINER)" >>$@
	@echo "Source: $(DUKTAPE_URL)" >>$@
	@echo "Description: $(DUKTAPE_DESCRIPTION)" >>$@
	@echo "Depends: $(DUKTAPE_DEPENDS)" >>$@
	@echo "Suggests: $(DUKTAPE_SUGGESTS)" >>$@
	@echo "Conflicts: $(DUKTAPE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/duktape/...
# Documentation files should be installed in $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/doc/duktape/...
# Daemon startup scripts should be installed in $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??duktape
#
# You may need to patch your application to make it use these locations.
#
$(DUKTAPE_IPK): $(DUKTAPE_BUILD_DIR)/.built
	rm -rf $(DUKTAPE_IPK_DIR) $(BUILD_DIR)/duktape_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DUKTAPE_BUILD_DIR) DESTDIR=$(DUKTAPE_IPK_DIR) install
	$(STRIP_COMMAND) $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/lib/libduktape.so \
			$(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/bin/duk
	# avoid conflict with ossp-js
	rm -f $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/bin/js
#	$(INSTALL) -d $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(DUKTAPE_SOURCE_DIR)/duktape.conf $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/duktape.conf
#	$(INSTALL) -d $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(DUKTAPE_SOURCE_DIR)/rc.duktape $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXduktape
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DUKTAPE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXduktape
	$(MAKE) $(DUKTAPE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(DUKTAPE_SOURCE_DIR)/postinst $(DUKTAPE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DUKTAPE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(DUKTAPE_SOURCE_DIR)/prerm $(DUKTAPE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DUKTAPE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DUKTAPE_IPK_DIR)/CONTROL/postinst $(DUKTAPE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DUKTAPE_CONFFILES) | sed -e 's/ /\n/g' > $(DUKTAPE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DUKTAPE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DUKTAPE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
duktape-ipk: $(DUKTAPE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
duktape-clean:
	rm -f $(DUKTAPE_BUILD_DIR)/.built
	-$(MAKE) -C $(DUKTAPE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
duktape-dirclean:
	rm -rf $(BUILD_DIR)/$(DUKTAPE_DIR) $(DUKTAPE_BUILD_DIR) $(DUKTAPE_IPK_DIR) $(DUKTAPE_IPK)
#
#
# Some sanity check for the package.
#
duktape-check: $(DUKTAPE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
