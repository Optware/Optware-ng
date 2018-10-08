###########################################################
#
# node
#
###########################################################
#
# NODE_VERSION, NODE_SITE and NODE_SOURCE define
# the upstream location of the source code for the package.
# NODE_DIR is the directory which is created when the source
# archive is unpacked.
# NODE_UNZIP is the command used to unzip the source.
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
NODE_URL=http://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION).tar.gz
NODE_VERSION=6.11.2
NODE_SOURCE=node-v$(NODE_VERSION).tar.gz
NODE_DIR=node-v$(NODE_VERSION)
NODE_UNZIP=zcat
NODE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NODE_DESCRIPTION=Node.js is a platform built on Chrome's JavaScript runtime.
NODE_SECTION=lang
NODE_PRIORITY=optional
NODE_DEPENDS=libstdc++, libuv, icu, openssl, zlib
NODE_SUGGESTS=
NODE_CONFLICTS=node010

#
# NODE_IPK_VERSION should be incremented when the ipk changes.
#
NODE_IPK_VERSION=3

#
# NODE_CONFFILES should be a list of user-editable files
#NODE_CONFFILES=$(TARGET_PREFIX)/etc/node.conf $(TARGET_PREFIX)/etc/init.d/SXXnode

#
# NODE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NODE_PATCHES=\
$(NODE_SOURCE_DIR)/mips_arm-no-fpu.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NODE_CPPFLAGS=
NODE_LDFLAGS=

NODE_ARCH=$(strip \
	$(if $(filter powerpc, $(TARGET_ARCH)), ppc, \
	$(if $(filter i386 i686, $(TARGET_ARCH)), ia32, \
	$(if $(filter x86_64, $(TARGET_ARCH)), x64, \
	$(TARGET_ARCH)))))

NODE_CONFIGURE_ARCH_OPTS=--dest-cpu=$(NODE_ARCH)

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabi-ng buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
NODE_CONFIGURE_ARCH_OPTS += \
--with-arm-float-abi=softfp \
--with-arm-fpu=none
endif

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabihf, $(OPTWARE_TARGET)))
NODE_CONFIGURE_ARCH_OPTS += \
--with-arm-float-abi=hard \
--with-arm-fpu=vfpv3-d16
endif

ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
NODE_CONFIGURE_ARCH_OPTS += \
--with-mips-arch=r2 \
--with-mips-float-abi=soft \
--with-mips-fpu=soft
endif

#
# NODE_BUILD_DIR is the directory in which the build is done.
# NODE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NODE_IPK_DIR is the directory in which the ipk is built.
# NODE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NODE_BUILD_DIR=$(BUILD_DIR)/node
NODE_SOURCE_DIR=$(SOURCE_DIR)/node
NODE_IPK_DIR=$(BUILD_DIR)/node-$(NODE_VERSION)-ipk
NODE_IPK=$(BUILD_DIR)/node_$(NODE_VERSION)-$(NODE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: node-source node-unpack node node-stage node-ipk node-clean node-dirclean node-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(NODE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(NODE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(NODE_SOURCE).sha512
#
$(DL_DIR)/$(NODE_SOURCE):
	$(WGET) -O $@ $(NODE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
node-source: $(DL_DIR)/$(NODE_SOURCE) $(NODE_PATCHES)

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
$(NODE_BUILD_DIR)/.configured: $(DL_DIR)/$(NODE_SOURCE) $(NODE_PATCHES) make/node.mk
	$(MAKE) libuv-stage icu-stage openssl-stage python27-host-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(NODE_DIR) $(@D)
	$(NODE_UNZIP) $(DL_DIR)/$(NODE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NODE_PATCHES)" ; \
		then cat $(NODE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NODE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NODE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NODE_DIR) $(@D) ; \
	fi
	sed -i  -e "/'cflags': \[\]/s|\[|\['$(shell echo $(STAGING_CPPFLAGS) $(NODE_CPPFLAGS) | sed "s/ /', '/g")'|" \
		-e "/'libraries': \[\]/s|\[|\['$(shell echo $(STAGING_LDFLAGS) $(NODE_LDFLAGS) | sed "s/ /', '/g")'|" \
		-e "/'include_dirs': \[\]/s|\[|\['$(@D)/deps/cares/include'|" \
		$(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(HOST_STAGING_PREFIX)/bin/python2.7 \
		./configure \
			$(NODE_CONFIGURE_ARCH_OPTS) \
			--dest-os=linux \
			--without-snapshot \
			--shared-zlib \
			--shared-openssl \
			--shared-libuv \
			--with-intl=system-icu \
			--prefix=$(TARGET_PREFIX) \
	)
	touch $@

node-unpack: $(NODE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NODE_BUILD_DIR)/.built: $(NODE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) DESTCPU=$(NODE_ARCH)
	touch $@

#
# This is the build convenience target.
#
node: $(NODE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NODE_BUILD_DIR)/.staged: $(NODE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

node-stage: $(NODE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/node
#
$(NODE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: node" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NODE_PRIORITY)" >>$@
	@echo "Section: $(NODE_SECTION)" >>$@
	@echo "Version: $(NODE_VERSION)-$(NODE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NODE_MAINTAINER)" >>$@
	@echo "Source: $(NODE_URL)" >>$@
	@echo "Description: $(NODE_DESCRIPTION)" >>$@
	@echo "Depends: $(NODE_DEPENDS)" >>$@
	@echo "Suggests: $(NODE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NODE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NODE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(NODE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NODE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/node/...
# Documentation files should be installed in $(NODE_IPK_DIR)$(TARGET_PREFIX)/doc/node/...
# Daemon startup scripts should be installed in $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??node
#
# You may need to patch your application to make it use these locations.
#
$(NODE_IPK): $(NODE_BUILD_DIR)/.built
	rm -rf $(NODE_IPK_DIR) $(BUILD_DIR)/node_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NODE_BUILD_DIR) DESTDIR=$(NODE_IPK_DIR) install
	$(STRIP_COMMAND) $(NODE_IPK_DIR)$(TARGET_PREFIX)/bin/node
#	$(INSTALL) -d $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(NODE_SOURCE_DIR)/node.conf $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/node.conf
#	$(INSTALL) -d $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(NODE_SOURCE_DIR)/rc.node $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXnode
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXnode
	$(MAKE) $(NODE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(NODE_SOURCE_DIR)/postinst $(NODE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(NODE_SOURCE_DIR)/prerm $(NODE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NODE_IPK_DIR)/CONTROL/postinst $(NODE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NODE_CONFFILES) | sed -e 's/ /\n/g' > $(NODE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NODE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NODE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
node-ipk: $(NODE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
node-clean:
	rm -f $(NODE_BUILD_DIR)/.built
	-$(MAKE) -C $(NODE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
node-dirclean:
	rm -rf $(BUILD_DIR)/$(NODE_DIR) $(NODE_BUILD_DIR) $(NODE_IPK_DIR) $(NODE_IPK)
#
#
# Some sanity check for the package.
#
node-check: $(NODE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
