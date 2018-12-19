###########################################################
#
# gotty
#
###########################################################
#
# GOTTY_VERSION, GOTTY_SITE and GOTTY_SOURCE define
# the upstream location of the source code for the package.
# GOTTY_DIR is the directory which is created when the source
# archive is unpacked.
# GOTTY_UNZIP is the command used to unzip the source.
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
GOTTY_URL=https://github.com/yudai/gotty/archive/v$(GOTTY_VERSION).tar.gz
GOTTY_VERSION?=1.0.1
GOTTY_SOURCE=gotty-$(GOTTY_VERSION).tar.gz
GOTTY_DIR=gotty-$(GOTTY_VERSION)
GOTTY_UNZIP=zcat
GOTTY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GOTTY_DESCRIPTION=GoTTY - Share your terminal as a web application.
GOTTY_SECTION=net
GOTTY_PRIORITY=optional
GOTTY_DEPENDS=libgo
GOTTY_SUGGESTS=
GOTTY_CONFLICTS=

#
# GOTTY_IPK_VERSION should be incremented when the ipk changes.
#
GOTTY_IPK_VERSION?=1

#
# GOTTY_CONFFILES should be a list of user-editable files
#GOTTY_CONFFILES=$(TARGET_PREFIX)/etc/gotty.conf $(TARGET_PREFIX)/etc/init.d/SXXgotty

#
# GOTTY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GOTTY_PATCHES=\
$(GOTTY_SOURCE_DIR)/Add-mips-and-ppc-support.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GOTTY_CPPFLAGS=
GOTTY_LDFLAGS=

#
# GOTTY_BUILD_DIR is the directory in which the build is done.
# GOTTY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GOTTY_IPK_DIR is the directory in which the ipk is built.
# GOTTY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GOTTY_BUILD_DIR=$(BUILD_DIR)/gotty
GOTTY_SOURCE_DIR=$(SOURCE_DIR)/gotty
GOTTY_IPK_DIR=$(BUILD_DIR)/gotty-$(GOTTY_VERSION)-ipk
GOTTY_IPK=$(BUILD_DIR)/gotty_$(GOTTY_VERSION)-$(GOTTY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gotty-source gotty-unpack gotty gotty-stage gotty-ipk gotty-clean gotty-dirclean gotty-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(GOTTY_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(GOTTY_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(GOTTY_SOURCE).sha512
#
$(DL_DIR)/$(GOTTY_SOURCE):
	$(WGET) -O $@ $(GOTTY_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gotty-source: $(DL_DIR)/$(GOTTY_SOURCE) $(GOTTY_PATCHES)

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
$(GOTTY_BUILD_DIR)/.configured: $(DL_DIR)/$(GOTTY_SOURCE) $(GOTTY_PATCHES) make/gotty.mk
	$(MAKE) gcc-host
	rm -rf $(BUILD_DIR)/$(GOTTY_DIR) $(@D)
	$(GOTTY_UNZIP) $(DL_DIR)/$(GOTTY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GOTTY_PATCHES)" ; \
		then cat $(GOTTY_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GOTTY_DIR) -p1 ; \
	fi
	mkdir -p $(@D)/src/github.com/yudai
	mv -f $(BUILD_DIR)/$(GOTTY_DIR) $(@D)/src/github.com/yudai/gotty
	touch $@

gotty-unpack: $(GOTTY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GOTTY_BUILD_DIR)/.built: $(GOTTY_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_GCCGO_GO_ENV) GOPATH=$(@D) $(GCC_HOST_BIN_DIR)/go install -v github.com/yudai/gotty
	@if [ ! -f $(@D)/bin/linux_$(TARGET_GOARCH)/gotty ]; then \
		mkdir -p $(@D)/bin/linux_$(TARGET_GOARCH); \
		cp -af $(@D)/bin/gotty $(@D)/bin/linux_$(TARGET_GOARCH)/; \
	fi
	touch $@

#
# This is the build convenience target.
#
gotty: $(GOTTY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GOTTY_BUILD_DIR)/.staged: $(GOTTY_BUILD_DIR)/.built
	rm -f $@
	touch $@

gotty-stage: $(GOTTY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gotty
#
$(GOTTY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gotty" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GOTTY_PRIORITY)" >>$@
	@echo "Section: $(GOTTY_SECTION)" >>$@
	@echo "Version: $(GOTTY_VERSION)-$(GOTTY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GOTTY_MAINTAINER)" >>$@
	@echo "Source: $(GOTTY_URL)" >>$@
	@echo "Description: $(GOTTY_DESCRIPTION)" >>$@
	@echo "Depends: $(GOTTY_DEPENDS)" >>$@
	@echo "Suggests: $(GOTTY_SUGGESTS)" >>$@
	@echo "Conflicts: $(GOTTY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/gotty/...
# Documentation files should be installed in $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/doc/gotty/...
# Daemon startup scripts should be installed in $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gotty
#
# You may need to patch your application to make it use these locations.
#
$(GOTTY_IPK): $(GOTTY_BUILD_DIR)/.built
	rm -rf $(GOTTY_IPK_DIR) $(BUILD_DIR)/gotty_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(GOTTY_BUILD_DIR)/bin/linux_$(TARGET_GOARCH)/gotty \
		$(GOTTY_IPK_DIR)$(TARGET_PREFIX)/bin
#	$(INSTALL) -d $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GOTTY_SOURCE_DIR)/gotty.conf $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/gotty.conf
#	$(INSTALL) -d $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GOTTY_SOURCE_DIR)/rc.gotty $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgotty
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOTTY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgotty
	$(MAKE) $(GOTTY_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GOTTY_SOURCE_DIR)/postinst $(GOTTY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOTTY_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GOTTY_SOURCE_DIR)/prerm $(GOTTY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GOTTY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GOTTY_IPK_DIR)/CONTROL/postinst $(GOTTY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GOTTY_CONFFILES) | sed -e 's/ /\n/g' > $(GOTTY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GOTTY_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GOTTY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gotty-ipk: $(GOTTY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gotty-clean:
	rm -f $(GOTTY_BUILD_DIR)/.built
	-$(MAKE) -C $(GOTTY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gotty-dirclean:
	rm -rf $(BUILD_DIR)/$(GOTTY_DIR) $(GOTTY_BUILD_DIR) $(GOTTY_IPK_DIR) $(GOTTY_IPK)
#
#
# Some sanity check for the package.
#
gotty-check: $(GOTTY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
