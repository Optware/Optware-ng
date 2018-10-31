###########################################################
#
# node010
#
###########################################################
#
# NODE010_VERSION, NODE010_SITE and NODE010_SOURCE define
# the upstream location of the source code for the package.
# NODE010_DIR is the directory which is created when the source
# archive is unpacked.
# NODE010_UNZIP is the command used to unzip the source.
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
NODE010_URL=http://nodejs.org/dist/v$(NODE010_VERSION)/node-v$(NODE010_VERSION).tar.gz
NODE010_VERSION=0.10.48
NODE010_SOURCE=node-v$(NODE010_VERSION).tar.gz
NODE010_DIR=node-v$(NODE010_VERSION)
NODE010_UNZIP=zcat
NODE010_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NODE010_DESCRIPTION=Node.js is a platform built on Chrome's JavaScript runtime.
NODE010_SECTION=lang
NODE010_PRIORITY=optional
NODE010_DEPENDS=libstdc++, openssl, zlib
NODE010_SUGGESTS=
NODE010_CONFLICTS=node

#
# NODE010_IPK_VERSION should be incremented when the ipk changes.
#
NODE010_IPK_VERSION=2

#
# NODE010_CONFFILES should be a list of user-editable files
#NODE010_CONFFILES=$(TARGET_PREFIX)/etc/node.conf $(TARGET_PREFIX)/etc/init.d/SXXnode

#
# NODE010_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NODE010_PATCHES=\
$(NODE010_SOURCE_DIR)/mips-no-fpu.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NODE010_CPPFLAGS=
NODE010_LDFLAGS=

NODE010_ARCH=$(strip \
	$(if $(filter powerpc, $(TARGET_ARCH)), ppc, \
	$(if $(filter i386 i686, $(TARGET_ARCH)), ia32, \
	$(if $(filter x86_64, $(TARGET_ARCH)), x64, \
	$(TARGET_ARCH)))))

NODE010_CONFIGURE_ARCH_OPTS=--dest-cpu=$(NODE010_ARCH)

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabi-ng buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
NODE010_CONFIGURE_ARCH_OPTS += \
--with-arm-float-abi=soft
endif

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armeabihf, $(OPTWARE_TARGET)))
NODE010_CONFIGURE_ARCH_OPTS += \
--with-arm-float-abi=hard
endif

ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
NODE010_CONFIGURE_ARCH_OPTS += \
--with-mips-float-abi=soft
endif

#
# NODE010_BUILD_DIR is the directory in which the build is done.
# NODE010_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NODE010_IPK_DIR is the directory in which the ipk is built.
# NODE010_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NODE010_BUILD_DIR=$(BUILD_DIR)/node010
NODE010_SOURCE_DIR=$(SOURCE_DIR)/node010
NODE010_IPK_DIR=$(BUILD_DIR)/node010-$(NODE010_VERSION)-ipk
NODE010_IPK=$(BUILD_DIR)/node010_$(NODE010_VERSION)-$(NODE010_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: node010-source node010-unpack node010 node010-stage node010-ipk node010-clean node010-dirclean node010-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(NODE010_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(NODE010_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(NODE010_SOURCE).sha512
#
$(DL_DIR)/$(NODE010_SOURCE):
	$(WGET) -O $@ $(NODE010_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
node010-source: $(DL_DIR)/$(NODE010_SOURCE) $(NODE010_PATCHES)

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
$(NODE010_BUILD_DIR)/.configured: $(DL_DIR)/$(NODE010_SOURCE) $(NODE010_PATCHES) make/node010.mk
	$(MAKE) openssl-stage python27-host-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(NODE010_DIR) $(@D)
	$(NODE010_UNZIP) $(DL_DIR)/$(NODE010_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NODE010_PATCHES)" ; \
		then cat $(NODE010_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NODE010_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NODE010_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NODE010_DIR) $(@D) ; \
	fi
	sed -i  -e "/'cflags': \[\]/s|\[|\['$(shell echo $(STAGING_CPPFLAGS) $(NODE010_CPPFLAGS) | sed "s/ /', '/g")'|" \
		-e "/'libraries': \[\]/s|\[|\['$(shell echo $(STAGING_LDFLAGS) $(NODE010_LDFLAGS) | sed "s/ /', '/g")'|" \
		-e "/'include_dirs': \[\]/s|\[|\['$(@D)/deps/cares/include'|" \
		$(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(HOST_STAGING_PREFIX)/bin/python2.7 \
		./configure \
			$(NODE010_CONFIGURE_ARCH_OPTS) \
			--dest-os=linux \
			--without-snapshot \
			--shared-zlib \
			--shared-openssl \
			--prefix=$(TARGET_PREFIX) \
	)
	touch $@

node010-unpack: $(NODE010_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NODE010_BUILD_DIR)/.built: $(NODE010_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) DESTCPU=$(NODE010_ARCH)
	touch $@

#
# This is the build convenience target.
#
node010: $(NODE010_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NODE010_BUILD_DIR)/.staged: $(NODE010_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

node010-stage: $(NODE010_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/node
#
$(NODE010_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: node010" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NODE010_PRIORITY)" >>$@
	@echo "Section: $(NODE010_SECTION)" >>$@
	@echo "Version: $(NODE010_VERSION)-$(NODE010_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NODE010_MAINTAINER)" >>$@
	@echo "Source: $(NODE010_URL)" >>$@
	@echo "Description: $(NODE010_DESCRIPTION)" >>$@
	@echo "Depends: $(NODE010_DEPENDS)" >>$@
	@echo "Suggests: $(NODE010_SUGGESTS)" >>$@
	@echo "Conflicts: $(NODE010_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NODE010_IPK_DIR)$(TARGET_PREFIX)/sbin or $(NODE010_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NODE010_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/node/...
# Documentation files should be installed in $(NODE010_IPK_DIR)$(TARGET_PREFIX)/doc/node/...
# Daemon startup scripts should be installed in $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??node
#
# You may need to patch your application to make it use these locations.
#
$(NODE010_IPK): $(NODE010_BUILD_DIR)/.built
	rm -rf $(NODE010_IPK_DIR) $(BUILD_DIR)/node010_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NODE010_BUILD_DIR) DESTDIR=$(NODE010_IPK_DIR) install
	$(STRIP_COMMAND) $(NODE010_IPK_DIR)$(TARGET_PREFIX)/bin/node
#	$(INSTALL) -d $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(NODE010_SOURCE_DIR)/node.conf $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/node.conf
#	$(INSTALL) -d $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(NODE010_SOURCE_DIR)/rc.node $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXnode
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE010_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXnode
	$(MAKE) $(NODE010_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(NODE010_SOURCE_DIR)/postinst $(NODE010_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE010_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(NODE010_SOURCE_DIR)/prerm $(NODE010_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NODE010_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NODE010_IPK_DIR)/CONTROL/postinst $(NODE010_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NODE010_CONFFILES) | sed -e 's/ /\n/g' > $(NODE010_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NODE010_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NODE010_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
node010-ipk: $(NODE010_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
node010-clean:
	rm -f $(NODE010_BUILD_DIR)/.built
	-$(MAKE) -C $(NODE010_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
node010-dirclean:
	rm -rf $(BUILD_DIR)/$(NODE010_DIR) $(NODE010_BUILD_DIR) $(NODE010_IPK_DIR) $(NODE010_IPK)
#
#
# Some sanity check for the package.
#
node010-check: $(NODE010_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
