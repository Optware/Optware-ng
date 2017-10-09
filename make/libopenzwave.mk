###########################################################
#
# libopenzwave
#
###########################################################
#
# LIBOPENZWAVE_VERSION, LIBOPENZWAVE_SITE and LIBOPENZWAVE_SOURCE define
# the upstream location of the source code for the package.
# LIBOPENZWAVE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOPENZWAVE_UNZIP is the command used to unzip the source.
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
LIBOPENZWAVE_URL=https://github.com/OpenZWave/open-zwave/archive/v$(LIBOPENZWAVE_VERSION).tar.gz
LIBOPENZWAVE_VERSION=1.4
LIBOPENZWAVE_SOURCE=open-zwave-$(LIBOPENZWAVE_VERSION).tar.gz
LIBOPENZWAVE_DIR=open-zwave-$(LIBOPENZWAVE_VERSION)
LIBOPENZWAVE_UNZIP=zcat
LIBOPENZWAVE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOPENZWAVE_DESCRIPTION=A library to control Z-Wave Networks via a Z-Wave Controller.
LIBOPENZWAVE_SECTION=lib
LIBOPENZWAVE_PRIORITY=optional
LIBOPENZWAVE_DEPENDS=libstdc++, libudev
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBOPENZWAVE_DEPENDS+=, libiconv
endif
LIBOPENZWAVE_SUGGESTS=
LIBOPENZWAVE_CONFLICTS=

#
# LIBOPENZWAVE_IPK_VERSION should be incremented when the ipk changes.
#
LIBOPENZWAVE_IPK_VERSION=3

#
# LIBOPENZWAVE_CONFFILES should be a list of user-editable files
#LIBOPENZWAVE_CONFFILES=$(TARGET_PREFIX)/etc/libopenzwave.conf $(TARGET_PREFIX)/etc/init.d/SXXlibopenzwave

#
# LIBOPENZWAVE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBOPENZWAVE_PATCHES=\
$(LIBOPENZWAVE_SOURCE_DIR)/hid_c.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOPENZWAVE_CPPFLAGS=
ifneq ($(OPTWARE_TARGET), $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
LIBOPENZWAVE_CPPFLAGS += -O3
else
LIBOPENZWAVE_CPPFLAGS += -O2
endif
LIBOPENZWAVE_LDFLAGS=-ludev
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBOPENZWAVE_LDFLAGS += -liconv
endif

#
# LIBOPENZWAVE_BUILD_DIR is the directory in which the build is done.
# LIBOPENZWAVE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOPENZWAVE_IPK_DIR is the directory in which the ipk is built.
# LIBOPENZWAVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOPENZWAVE_BUILD_DIR=$(BUILD_DIR)/libopenzwave
LIBOPENZWAVE_SOURCE_DIR=$(SOURCE_DIR)/libopenzwave
LIBOPENZWAVE_IPK_DIR=$(BUILD_DIR)/libopenzwave-$(LIBOPENZWAVE_VERSION)-ipk
LIBOPENZWAVE_IPK=$(BUILD_DIR)/libopenzwave_$(LIBOPENZWAVE_VERSION)-$(LIBOPENZWAVE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libopenzwave-source libopenzwave-unpack libopenzwave libopenzwave-stage libopenzwave-ipk libopenzwave-clean libopenzwave-dirclean libopenzwave-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBOPENZWAVE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBOPENZWAVE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBOPENZWAVE_SOURCE).sha512
#
$(DL_DIR)/$(LIBOPENZWAVE_SOURCE):
	$(WGET) -O $@ $(LIBOPENZWAVE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libopenzwave-source: $(DL_DIR)/$(LIBOPENZWAVE_SOURCE) $(LIBOPENZWAVE_PATCHES)

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
$(LIBOPENZWAVE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOPENZWAVE_SOURCE) $(LIBOPENZWAVE_PATCHES) make/libopenzwave.mk
	$(MAKE) udev-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBOPENZWAVE_DIR) $(@D)
	$(LIBOPENZWAVE_UNZIP) $(DL_DIR)/$(LIBOPENZWAVE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBOPENZWAVE_PATCHES)" ; \
		then cat $(LIBOPENZWAVE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBOPENZWAVE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBOPENZWAVE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBOPENZWAVE_DIR) $(@D) ; \
	fi
	touch $@

libopenzwave-unpack: $(LIBOPENZWAVE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOPENZWAVE_BUILD_DIR)/.built: $(LIBOPENZWAVE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/cpp/build \
		CROSS_COMPILE=$(TARGET_CROSS) \
		PREFIX=$(TARGET_PREFIX) \
		instlibdir.x86_64=/lib/ \
		BUILD=release \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOPENZWAVE_CPPFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(LIBOPENZWAVE_LDFLAGS)" \
		$(@D)/cpp/build/libopenzwave.{so.$(LIBOPENZWAVE_VERSION),pc}
	touch $@

#
# This is the build convenience target.
#
libopenzwave: $(LIBOPENZWAVE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOPENZWAVE_BUILD_DIR)/.staged: $(LIBOPENZWAVE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/cpp/build \
		PREFIX=$(STAGING_PREFIX) instlibdir.x86_64=/lib/ \
		pkgconfigdir=$(STAGING_PREFIX)/lib/pkgconfig \
		install
	sed -i -e 's|=$(TARGET_PREFIX)|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libopenzwave.pc
	sed -i -e '/^pcfile=/s|=.*|=$(STAGING_LIB_DIR)/pkgconfig/libopenzwave.pc|' $(STAGING_PREFIX)/bin/ozw_config
	touch $@

libopenzwave-stage: $(LIBOPENZWAVE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libopenzwave
#
$(LIBOPENZWAVE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libopenzwave" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOPENZWAVE_PRIORITY)" >>$@
	@echo "Section: $(LIBOPENZWAVE_SECTION)" >>$@
	@echo "Version: $(LIBOPENZWAVE_VERSION)-$(LIBOPENZWAVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOPENZWAVE_MAINTAINER)" >>$@
	@echo "Source: $(LIBOPENZWAVE_URL)" >>$@
	@echo "Description: $(LIBOPENZWAVE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOPENZWAVE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBOPENZWAVE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBOPENZWAVE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/libopenzwave/...
# Documentation files should be installed in $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/doc/libopenzwave/...
# Daemon startup scripts should be installed in $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libopenzwave
#
# You may need to patch your application to make it use these locations.
#
$(LIBOPENZWAVE_IPK): $(LIBOPENZWAVE_BUILD_DIR)/.built
	rm -rf $(LIBOPENZWAVE_IPK_DIR) $(BUILD_DIR)/libopenzwave_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOPENZWAVE_BUILD_DIR)/cpp/build \
		PREFIX=$(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX) \
		instlibdir.x86_64=/lib/ \
		 pkgconfigdir=$(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig \
		install
	sed -i -e '/^pcfile=/s|=.*|=$(TARGET_PREFIX)/lib/pkgconfig/libopenzwave.pc|' $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/bin/ozw_config
	$(STRIP_COMMAND) $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBOPENZWAVE_SOURCE_DIR)/libopenzwave.conf $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/libopenzwave.conf
#	$(INSTALL) -d $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBOPENZWAVE_SOURCE_DIR)/rc.libopenzwave $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibopenzwave
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibopenzwave
	$(MAKE) $(LIBOPENZWAVE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBOPENZWAVE_SOURCE_DIR)/postinst $(LIBOPENZWAVE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENZWAVE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBOPENZWAVE_SOURCE_DIR)/prerm $(LIBOPENZWAVE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENZWAVE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBOPENZWAVE_IPK_DIR)/CONTROL/postinst $(LIBOPENZWAVE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBOPENZWAVE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOPENZWAVE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOPENZWAVE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBOPENZWAVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libopenzwave-ipk: $(LIBOPENZWAVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libopenzwave-clean:
	rm -f $(LIBOPENZWAVE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBOPENZWAVE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libopenzwave-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOPENZWAVE_DIR) $(LIBOPENZWAVE_BUILD_DIR) $(LIBOPENZWAVE_IPK_DIR) $(LIBOPENZWAVE_IPK)
#
#
# Some sanity check for the package.
#
libopenzwave-check: $(LIBOPENZWAVE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
