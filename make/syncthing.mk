###########################################################
#
# syncthing
#
###########################################################
#
# SYNCTHING_VERSION, SYNCTHING_SITE and SYNCTHING_SOURCE define
# the upstream location of the source code for the package.
# SYNCTHING_DIR is the directory which is created when the source
# archive is unpacked.
# SYNCTHING_UNZIP is the command used to unzip the source.
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
SYNCTHING_URL=https://github.com/syncthing/syncthing/archive/v$(SYNCTHING_VERSION).tar.gz
SYNCTHING_VERSION=0.14.52
SYNCTHING_SOURCE=syncthing-$(SYNCTHING_VERSION).tar.gz
SYNCTHING_DIR=syncthing-$(SYNCTHING_VERSION)
SYNCTHING_UNZIP=zcat
SYNCTHING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SYNCTHING_DESCRIPTION=Utility for synchronization of a folder between a number of collaborating devices.
SYNCTHING_SECTION=net
SYNCTHING_PRIORITY=optional
#ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
ifeq ($(OPTWARE_TARGET), $(filter , $(OPTWARE_TARGET)))
SYNCTHING_DEPENDS=libgo
else
SYNCTHING_DEPENDS=
endif
SYNCTHING_SUGGESTS=
SYNCTHING_CONFLICTS=

#
# SYNCTHING_IPK_VERSION should be incremented when the ipk changes.
#
SYNCTHING_IPK_VERSION=1

#
# SYNCTHING_CONFFILES should be a list of user-editable files
#SYNCTHING_CONFFILES=$(TARGET_PREFIX)/etc/syncthing.conf $(TARGET_PREFIX)/etc/init.d/SXXsyncthing

#
# SYNCTHING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SYNCTHING_PATCHES=\
$(SYNCTHING_SOURCE_DIR)/optware_paths.patch \
$(SYNCTHING_SOURCE_DIR)/targetcc.patch \
$(SYNCTHING_SOURCE_DIR)/gccgo.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SYNCTHING_CPPFLAGS=
SYNCTHING_LDFLAGS=

#
# SYNCTHING_BUILD_DIR is the directory in which the build is done.
# SYNCTHING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SYNCTHING_IPK_DIR is the directory in which the ipk is built.
# SYNCTHING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SYNCTHING_BUILD_DIR=$(BUILD_DIR)/syncthing
SYNCTHING_SOURCE_DIR=$(SOURCE_DIR)/syncthing
SYNCTHING_IPK_DIR=$(BUILD_DIR)/syncthing-$(SYNCTHING_VERSION)-ipk
SYNCTHING_IPK=$(BUILD_DIR)/syncthing_$(SYNCTHING_VERSION)-$(SYNCTHING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: syncthing-source syncthing-unpack syncthing syncthing-stage syncthing-ipk syncthing-clean syncthing-dirclean syncthing-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SYNCTHING_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SYNCTHING_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SYNCTHING_SOURCE).sha512
#
$(DL_DIR)/$(SYNCTHING_SOURCE):
	$(WGET) -O $@ $(SYNCTHING_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
syncthing-source: $(DL_DIR)/$(SYNCTHING_SOURCE) $(SYNCTHING_PATCHES)

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
$(SYNCTHING_BUILD_DIR)/.configured: $(DL_DIR)/$(SYNCTHING_SOURCE) $(SYNCTHING_PATCHES) make/syncthing.mk
#ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
ifeq ($(OPTWARE_TARGET), $(filter , $(OPTWARE_TARGET)))
	$(MAKE) gcc-host golang-host
else
	if [ "$(GOLANG_ARCH)" = amd64 ]; then \
		$(MAKE) golang-host; \
	else \
		$(MAKE) golang; \
	fi
endif
	rm -rf $(BUILD_DIR)/$(SYNCTHING_DIR) $(@D)
	$(SYNCTHING_UNZIP) $(DL_DIR)/$(SYNCTHING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SYNCTHING_PATCHES)" ; \
		then cat $(SYNCTHING_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SYNCTHING_DIR) -p1 ; \
	fi
	mkdir -p $(@D)/src/github.com/syncthing
	mv -f $(BUILD_DIR)/$(SYNCTHING_DIR) $(@D)/src/github.com/syncthing/syncthing
#ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
ifeq ($(OPTWARE_TARGET), $(filter , $(OPTWARE_TARGET)))
	mkdir -p $(@D)/src/math
	cp -af $(GOLANG_HOST_BUILD_DIR)/src/math/bits $(@D)/src/math/
endif
	touch $@

syncthing-unpack: $(SYNCTHING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SYNCTHING_BUILD_DIR)/.built: $(SYNCTHING_BUILD_DIR)/.configured
	rm -f $@
#ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
ifeq ($(OPTWARE_TARGET), $(filter , $(OPTWARE_TARGET)))
	GOPATH=$(@D) GCCGO=$(TARGET_GCCGO) CC=$(TARGET_CC) \
		GOARCH=$(GOLANG_ARCH) GOOS=linux\
		$(GOLANG_HOST_BUILD_DIR)/bin/go install -v -compiler gccgo github.com/syncthing/syncthing/vendor/golang.org/x/sys/unix
	cd $(@D)/src/github.com/syncthing/syncthing; \
		PATH=$(GCC_HOST_BIN_DIR):$$PATH \
		GOPATH=$(@D) \
		go run build.go -goos linux -goarch $(GOLANG_ARCH) -targetcc $(TARGET_CC) -gccgo $(TARGET_GCCGO) -version v$(SYNCTHING_VERSION) -no-upgrade build
else
	if [ "$(GOLANG_ARCH)" = amd64 ]; then \
	cd $(@D)/src/github.com/syncthing/syncthing; \
		PATH=$(GOLANG_HOST_BUILD_DIR)/bin:$$PATH \
		GOPATH=$(@D) \
		go run build.go -goos linux -goarch $(GOLANG_ARCH) -targetcc $(TARGET_CC) -version v$(SYNCTHING_VERSION) -no-upgrade build ;\
	else \
	cd $(@D)/src/github.com/syncthing/syncthing; \
		PATH=$(GOLANG_BUILD_DIR)/bin:$$PATH \
		GOPATH=$(@D) \
		go run build.go -goos linux -goarch $(GOLANG_ARCH) -targetcc $(TARGET_CC) -version v$(SYNCTHING_VERSION) -no-upgrade build; \
	fi
endif
	touch $@

#
# This is the build convenience target.
#
syncthing: $(SYNCTHING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SYNCTHING_BUILD_DIR)/.staged: $(SYNCTHING_BUILD_DIR)/.built
	rm -f $@
	touch $@

syncthing-stage: $(SYNCTHING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/syncthing
#
$(SYNCTHING_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: syncthing" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SYNCTHING_PRIORITY)" >>$@
	@echo "Section: $(SYNCTHING_SECTION)" >>$@
	@echo "Version: $(SYNCTHING_VERSION)-$(SYNCTHING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SYNCTHING_MAINTAINER)" >>$@
	@echo "Source: $(SYNCTHING_URL)" >>$@
	@echo "Description: $(SYNCTHING_DESCRIPTION)" >>$@
	@echo "Depends: $(SYNCTHING_DEPENDS)" >>$@
	@echo "Suggests: $(SYNCTHING_SUGGESTS)" >>$@
	@echo "Conflicts: $(SYNCTHING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/syncthing/...
# Documentation files should be installed in $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/doc/syncthing/...
# Daemon startup scripts should be installed in $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??syncthing
#
# You may need to patch your application to make it use these locations.
#
$(SYNCTHING_IPK): $(SYNCTHING_BUILD_DIR)/.built
	rm -rf $(SYNCTHING_IPK_DIR) $(BUILD_DIR)/syncthing_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SYNCTHING_BUILD_DIR)/src/github.com/syncthing/syncthing/syncthing \
		$(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/bin
#	$(INSTALL) -d $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SYNCTHING_SOURCE_DIR)/syncthing.conf $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/syncthing.conf
#	$(INSTALL) -d $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SYNCTHING_SOURCE_DIR)/rc.syncthing $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsyncthing
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SYNCTHING_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXsyncthing
	$(MAKE) $(SYNCTHING_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SYNCTHING_SOURCE_DIR)/postinst $(SYNCTHING_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SYNCTHING_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SYNCTHING_SOURCE_DIR)/prerm $(SYNCTHING_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SYNCTHING_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SYNCTHING_IPK_DIR)/CONTROL/postinst $(SYNCTHING_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SYNCTHING_CONFFILES) | sed -e 's/ /\n/g' > $(SYNCTHING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SYNCTHING_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SYNCTHING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
syncthing-ipk: $(SYNCTHING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
syncthing-clean:
	rm -f $(SYNCTHING_BUILD_DIR)/.built
	-$(MAKE) -C $(SYNCTHING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
syncthing-dirclean:
	rm -rf $(BUILD_DIR)/$(SYNCTHING_DIR) $(SYNCTHING_BUILD_DIR) $(SYNCTHING_IPK_DIR) $(SYNCTHING_IPK)
#
#
# Some sanity check for the package.
#
syncthing-check: $(SYNCTHING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
