###########################################################
#
# libfdk-aac
#
###########################################################
#
# LIBFDK_AAC_VERSION, LIBFDK_AAC_SITE and LIBFDK_AAC_SOURCE define
# the upstream location of the source code for the package.
# LIBFDK_AAC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBFDK_AAC_UNZIP is the command used to unzip the source.
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
LIBFDK_AAC_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/opencore-amr/fdk-aac-$(LIBFDK_AAC_VERSION).tar.gz
LIBFDK_AAC_VERSION=0.1.4
LIBFDK_AAC_SOURCE=fdk-aac-$(LIBFDK_AAC_VERSION).tar.gz
LIBFDK_AAC_DIR=fdk-aac-$(LIBFDK_AAC_VERSION)
LIBFDK_AAC_UNZIP=zcat
LIBFDK_AAC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBFDK_AAC_DESCRIPTION=Library of OpenCORE Framework implementation of Adaptive Multi Rate Narrowband and Wideband (AMR-NB and AMR-WB) speech codec.
LIBFDK_AAC_SECTION=lib
LIBFDK_AAC_PRIORITY=optional
LIBFDK_AAC_DEPENDS=libstdc++
LIBFDK_AAC_SUGGESTS=
LIBFDK_AAC_CONFLICTS=

#
# LIBFDK_AAC_IPK_VERSION should be incremented when the ipk changes.
#
LIBFDK_AAC_IPK_VERSION=2

#
# LIBFDK_AAC_CONFFILES should be a list of user-editable files
#LIBFDK_AAC_CONFFILES=$(TARGET_PREFIX)/etc/libfdk-aac.conf $(TARGET_PREFIX)/etc/init.d/SXXlibfdk-aac

#
# LIBFDK_AAC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBFDK_AAC_PATCHES=$(LIBFDK_AAC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBFDK_AAC_CPPFLAGS=-Wno-error=narrowing
LIBFDK_AAC_LDFLAGS=

#
# LIBFDK_AAC_BUILD_DIR is the directory in which the build is done.
# LIBFDK_AAC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBFDK_AAC_IPK_DIR is the directory in which the ipk is built.
# LIBFDK_AAC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBFDK_AAC_BUILD_DIR=$(BUILD_DIR)/libfdk-aac
LIBFDK_AAC_SOURCE_DIR=$(SOURCE_DIR)/libfdk-aac
LIBFDK_AAC_IPK_DIR=$(BUILD_DIR)/libfdk-aac-$(LIBFDK_AAC_VERSION)-ipk
LIBFDK_AAC_IPK=$(BUILD_DIR)/libfdk-aac_$(LIBFDK_AAC_VERSION)-$(LIBFDK_AAC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libfdk-aac-source libfdk-aac-unpack libfdk-aac libfdk-aac-stage libfdk-aac-ipk libfdk-aac-clean libfdk-aac-dirclean libfdk-aac-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBFDK_AAC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBFDK_AAC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBFDK_AAC_SOURCE).sha512
#
$(DL_DIR)/$(LIBFDK_AAC_SOURCE):
	$(WGET) -O $@ $(LIBFDK_AAC_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libfdk-aac-source: $(DL_DIR)/$(LIBFDK_AAC_SOURCE) $(LIBFDK_AAC_PATCHES)

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
$(LIBFDK_AAC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBFDK_AAC_SOURCE) $(LIBFDK_AAC_PATCHES) make/libfdk-aac.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBFDK_AAC_DIR) $(@D)
	$(LIBFDK_AAC_UNZIP) $(DL_DIR)/$(LIBFDK_AAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBFDK_AAC_PATCHES)" ; \
		then cat $(LIBFDK_AAC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBFDK_AAC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBFDK_AAC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBFDK_AAC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBFDK_AAC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBFDK_AAC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libfdk-aac-unpack: $(LIBFDK_AAC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBFDK_AAC_BUILD_DIR)/.built: $(LIBFDK_AAC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libfdk-aac: $(LIBFDK_AAC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBFDK_AAC_BUILD_DIR)/.staged: $(LIBFDK_AAC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fdk-aac.pc
	rm -f $(STAGING_LIB_DIR)/libfdk-aac.la
	touch $@

libfdk-aac-stage: $(LIBFDK_AAC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libfdk-aac
#
$(LIBFDK_AAC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libfdk-aac" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBFDK_AAC_PRIORITY)" >>$@
	@echo "Section: $(LIBFDK_AAC_SECTION)" >>$@
	@echo "Version: $(LIBFDK_AAC_VERSION)-$(LIBFDK_AAC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBFDK_AAC_MAINTAINER)" >>$@
	@echo "Source: $(LIBFDK_AAC_URL)" >>$@
	@echo "Description: $(LIBFDK_AAC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFDK_AAC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFDK_AAC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFDK_AAC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/libfdk-aac/...
# Documentation files should be installed in $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/doc/libfdk-aac/...
# Daemon startup scripts should be installed in $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libfdk-aac
#
# You may need to patch your application to make it use these locations.
#
$(LIBFDK_AAC_IPK): $(LIBFDK_AAC_BUILD_DIR)/.built
	rm -rf $(LIBFDK_AAC_IPK_DIR) $(BUILD_DIR)/libfdk-aac_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBFDK_AAC_BUILD_DIR) DESTDIR=$(LIBFDK_AAC_IPK_DIR) install-strip
	rm -f $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/lib/libfdk-aac.la
#	$(INSTALL) -d $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBFDK_AAC_SOURCE_DIR)/libfdk-aac.conf $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/libfdk-aac.conf
#	$(INSTALL) -d $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBFDK_AAC_SOURCE_DIR)/rc.libfdk-aac $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibfdk-aac
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBFDK_AAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibfdk-aac
	$(MAKE) $(LIBFDK_AAC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBFDK_AAC_SOURCE_DIR)/postinst $(LIBFDK_AAC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBFDK_AAC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBFDK_AAC_SOURCE_DIR)/prerm $(LIBFDK_AAC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBFDK_AAC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBFDK_AAC_IPK_DIR)/CONTROL/postinst $(LIBFDK_AAC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBFDK_AAC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBFDK_AAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFDK_AAC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBFDK_AAC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libfdk-aac-ipk: $(LIBFDK_AAC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libfdk-aac-clean:
	rm -f $(LIBFDK_AAC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBFDK_AAC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libfdk-aac-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBFDK_AAC_DIR) $(LIBFDK_AAC_BUILD_DIR) $(LIBFDK_AAC_IPK_DIR) $(LIBFDK_AAC_IPK)
#
#
# Some sanity check for the package.
#
libfdk-aac-check: $(LIBFDK_AAC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
