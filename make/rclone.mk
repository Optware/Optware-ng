###########################################################
#
# rclone
#
###########################################################
#
# RCLONE_VERSION, RCLONE_SITE and RCLONE_SOURCE define
# the upstream location of the source code for the package.
# RCLONE_DIR is the directory which is created when the source
# archive is unpacked.
# RCLONE_UNZIP is the command used to unzip the source.
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
RCLONE_URL=https://github.com/ncw/rclone/archive/v$(RCLONE_VERSION).tar.gz
RCLONE_VERSION=1.39
RCLONE_SOURCE=rclone-$(RCLONE_VERSION).tar.gz
RCLONE_DIR=rclone-$(RCLONE_VERSION)
RCLONE_UNZIP=zcat
RCLONE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RCLONE_DESCRIPTION=Rclone is a command line program to sync files and directories to and from cloud storages.
RCLONE_SECTION=net
RCLONE_PRIORITY=optional
RCLONE_DEPENDS=cacerts
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
RCLONE_DEPENDS += , libgo
endif
RCLONE_SUGGESTS=
RCLONE_CONFLICTS=

#
# RCLONE_IPK_VERSION should be incremented when the ipk changes.
#
RCLONE_IPK_VERSION=3

#
# RCLONE_CONFFILES should be a list of user-editable files
#RCLONE_CONFFILES=$(TARGET_PREFIX)/etc/rclone.conf $(TARGET_PREFIX)/etc/init.d/SXXrclone

#
# RCLONE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RCLONE_PATCHES=\
$(RCLONE_SOURCE_DIR)/conf-path.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RCLONE_CPPFLAGS=
RCLONE_LDFLAGS=

#
# RCLONE_BUILD_DIR is the directory in which the build is done.
# RCLONE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RCLONE_IPK_DIR is the directory in which the ipk is built.
# RCLONE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RCLONE_BUILD_DIR=$(BUILD_DIR)/rclone
RCLONE_SOURCE_DIR=$(SOURCE_DIR)/rclone
RCLONE_IPK_DIR=$(BUILD_DIR)/rclone-$(RCLONE_VERSION)-ipk
RCLONE_IPK=$(BUILD_DIR)/rclone_$(RCLONE_VERSION)-$(RCLONE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rclone-source rclone-unpack rclone rclone-stage rclone-ipk rclone-clean rclone-dirclean rclone-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(RCLONE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(RCLONE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(RCLONE_SOURCE).sha512
#
$(DL_DIR)/$(RCLONE_SOURCE):
	$(WGET) -O $@ $(RCLONE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rclone-source: $(DL_DIR)/$(RCLONE_SOURCE) $(RCLONE_PATCHES)

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
$(RCLONE_BUILD_DIR)/.configured: $(DL_DIR)/$(RCLONE_SOURCE) $(RCLONE_PATCHES) make/rclone.mk
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
	$(MAKE) gcc-host golang-host
else
	$(MAKE) golang
endif
	rm -rf $(BUILD_DIR)/$(RCLONE_DIR) $(@D)
	$(RCLONE_UNZIP) $(DL_DIR)/$(RCLONE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RCLONE_PATCHES)" ; \
		then cat $(RCLONE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RCLONE_DIR) -p1 ; \
	fi
	mkdir -p $(@D)/src/github.com/ncw
	mv -f $(BUILD_DIR)/$(RCLONE_DIR) $(@D)/src/github.com/ncw/rclone
	touch $@

rclone-unpack: $(RCLONE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RCLONE_BUILD_DIR)/.built: $(RCLONE_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
	GOPATH=$(@D) GCCGO=$(TARGET_GCCGO) CC=$(TARGET_CC) \
		GOARCH=$(GOLANG_ARCH) GOOS=linux\
		$(GOLANG_HOST_BUILD_DIR)/bin/go install -v -compiler gccgo github.com/ncw/rclone/vendor/golang.org/x/sys/unix
	$(TARGET_GCCGO_GO_ENV) GOPATH=$(@D) $(GCC_HOST_BIN_DIR)/go install -v github.com/ncw/rclone
else
	CC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	GOOS=linux \
	GOARCH=$(GOLANG_ARCH) \
	GOPATH=$(@D) \
	$(GOLANG_BUILD_DIR)/bin/go install -v github.com/ncw/rclone
endif
	@if [ ! -f $(@D)/bin/linux_$(TARGET_GOARCH)/rclone ]; then \
		mkdir -p $(@D)/bin/linux_$(TARGET_GOARCH); \
		cp -af $(@D)/bin/rclone $(@D)/bin/linux_$(TARGET_GOARCH)/; \
	fi
	touch $@

#
# This is the build convenience target.
#
rclone: $(RCLONE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RCLONE_BUILD_DIR)/.staged: $(RCLONE_BUILD_DIR)/.built
	rm -f $@
	touch $@

rclone-stage: $(RCLONE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rclone
#
$(RCLONE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: rclone" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RCLONE_PRIORITY)" >>$@
	@echo "Section: $(RCLONE_SECTION)" >>$@
	@echo "Version: $(RCLONE_VERSION)-$(RCLONE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RCLONE_MAINTAINER)" >>$@
	@echo "Source: $(RCLONE_URL)" >>$@
	@echo "Description: $(RCLONE_DESCRIPTION)" >>$@
	@echo "Depends: $(RCLONE_DEPENDS)" >>$@
	@echo "Suggests: $(RCLONE_SUGGESTS)" >>$@
	@echo "Conflicts: $(RCLONE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/rclone/...
# Documentation files should be installed in $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/doc/rclone/...
# Daemon startup scripts should be installed in $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??rclone
#
# You may need to patch your application to make it use these locations.
#
$(RCLONE_IPK): $(RCLONE_BUILD_DIR)/.built
	rm -rf $(RCLONE_IPK_DIR) $(BUILD_DIR)/rclone_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(RCLONE_BUILD_DIR)/bin/linux_$(TARGET_GOARCH)/rclone \
		$(RCLONE_IPK_DIR)$(TARGET_PREFIX)/bin
#	$(INSTALL) -d $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(RCLONE_SOURCE_DIR)/rclone.conf $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/rclone.conf
#	$(INSTALL) -d $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(RCLONE_SOURCE_DIR)/rc.rclone $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrclone
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RCLONE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrclone
	$(MAKE) $(RCLONE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(RCLONE_SOURCE_DIR)/postinst $(RCLONE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RCLONE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(RCLONE_SOURCE_DIR)/prerm $(RCLONE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RCLONE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(RCLONE_IPK_DIR)/CONTROL/postinst $(RCLONE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(RCLONE_CONFFILES) | sed -e 's/ /\n/g' > $(RCLONE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RCLONE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RCLONE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rclone-ipk: $(RCLONE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rclone-clean:
	rm -f $(RCLONE_BUILD_DIR)/.built
	-$(MAKE) -C $(RCLONE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rclone-dirclean:
	rm -rf $(BUILD_DIR)/$(RCLONE_DIR) $(RCLONE_BUILD_DIR) $(RCLONE_IPK_DIR) $(RCLONE_IPK)
#
#
# Some sanity check for the package.
#
rclone-check: $(RCLONE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
