###########################################################
#
# icu
#
###########################################################

# You must replace "icu" and "ICU" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ICU_VERSION, ICU_SITE and ICU_SOURCE define
# the upstream location of the source code for the package.
# ICU_DIR is the directory which is created when the source
# archive is unpacked.
# ICU_UNZIP is the command used to unzip the source.
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
ICU_SITE=http://download.icu-project.org/files/icu4c/$(ICU_VERSION)
ICU_VERSION=56.1
ICU_SOURCE=icu4c-56_1-src.tgz
ICU_DIR=icu
ICU_UNZIP=zcat
ICU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ICU_DESCRIPTION=ICU is a mature, widely used set of portable libraries for Unicode support, software internationalization and globalization.
ICU_SECTION=admin
ICU_PRIORITY=optional
ICU_DEPENDS=
ICU_SUGGESTS=
ICU_CONFLICTS=

#
# ICU_IPK_VERSION should be incremented when the ipk changes.
#
ICU_IPK_VERSION=4

#
# ICU_CONFFILES should be a list of user-editable files
#ICU_CONFFILES=$(TARGET_PREFIX)/etc/icu.conf $(TARGET_PREFIX)/etc/init.d/SXXicu

#
# ICU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ICU_PATCHES=\
$(ICU_SOURCE_DIR)/link-icudata-as-data-only.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ICU_CPPFLAGS=
ICU_LDFLAGS=

#
# ICU_BUILD_DIR is the directory in which the build is done.
# ICU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ICU_IPK_DIR is the directory in which the ipk is built.
# ICU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ICU_BUILD_DIR=$(BUILD_DIR)/icu
ICU_SOURCE_DIR=$(SOURCE_DIR)/icu
ICU_IPK_DIR=$(BUILD_DIR)/icu-$(ICU_VERSION)-ipk
ICU_IPK=$(BUILD_DIR)/icu_$(ICU_VERSION)-$(ICU_IPK_VERSION)_$(TARGET_ARCH).ipk
ICU_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/icu

.PHONY: icu-source icu-unpack icu icu-stage icu-ipk icu-clean icu-dirclean icu-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ICU_SOURCE):
	$(WGET) -P $(@D) $(ICU_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
icu-source: $(DL_DIR)/$(ICU_SOURCE) $(ICU_PATCHES)

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
$(ICU_BUILD_DIR)/.configured: 	$(DL_DIR)/$(ICU_SOURCE) $(ICU_PATCHES) make/icu.mk \
				$(ICU_HOST_BUILD_DIR)/.built
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ICU_DIR) $(@D)
	$(ICU_UNZIP) $(DL_DIR)/$(ICU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ICU_PATCHES)" ; \
		then cat $(ICU_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ICU_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ICU_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ICU_DIR) $(@D) ; \
	fi
	(cd $(@D)/source; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(TARGET_CFLAGS) $(ICU_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,-rpath,$(TARGET_PREFIX)/lib $(ICU_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-cross-build=$(ICU_HOST_BUILD_DIR) \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

icu-unpack: $(ICU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ICU_BUILD_DIR)/.built: $(ICU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/source
	touch $@

#
# This is the build convenience target.
#
icu: $(ICU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ICU_BUILD_DIR)/.staged: $(ICU_BUILD_DIR)/.built
	$(MAKE) -C $(@D)/source DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix =/s|=.*|= $(STAGING_PREFIX)|' 	$(STAGING_LIB_DIR)/pkgconfig/icu*.pc \
								$(STAGING_LIB_DIR)/icu/$(ICU_VERSION)/Makefile.inc
	touch $@

icu-stage: $(ICU_BUILD_DIR)/.staged

$(ICU_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(ICU_SOURCE) make/icu.mk
	rm -rf $(HOST_BUILD_DIR)/$(ICU_DIR) $(@D)
	$(ICU_UNZIP) $(DL_DIR)/$(ICU_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(ICU_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(ICU_DIR) $(@D) ; \
	fi
	mv $(@D)/source/* $(@D)/
	(cd $(@D); \
		./configure \
		--disable-threads \
	)
	$(MAKE) -C $(@D)
	touch $@

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/icu
#
$(ICU_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: icu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ICU_PRIORITY)" >>$@
	@echo "Section: $(ICU_SECTION)" >>$@
	@echo "Version: $(ICU_VERSION)-$(ICU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ICU_MAINTAINER)" >>$@
	@echo "Source: $(ICU_SITE)/$(ICU_SOURCE)" >>$@
	@echo "Description: $(ICU_DESCRIPTION)" >>$@
	@echo "Depends: $(ICU_DEPENDS)" >>$@
	@echo "Suggests: $(ICU_SUGGESTS)" >>$@
	@echo "Conflicts: $(ICU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ICU_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ICU_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ICU_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/icu/...
# Documentation files should be installed in $(ICU_IPK_DIR)$(TARGET_PREFIX)/doc/icu/...
# Daemon startup scripts should be installed in $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??icu
#
# You may need to patch your application to make it use these locations.
#
$(ICU_IPK): $(ICU_BUILD_DIR)/.built
	rm -rf $(ICU_IPK_DIR) $(BUILD_DIR)/icu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ICU_BUILD_DIR)/source DESTDIR=$(ICU_IPK_DIR) install
	$(STRIP_COMMAND) \
		`ls $(ICU_IPK_DIR)$(TARGET_PREFIX)/bin/* | grep -v icu-config` \
		$(ICU_IPK_DIR)$(TARGET_PREFIX)/sbin/* \
		$(ICU_IPK_DIR)$(TARGET_PREFIX)/lib/lib*.so.*.*
	sed -i -e 's|$(TARGET_AR)|$(TARGET_PREFIX)/bin/ar|g' -e 's|$(TARGET_CC)|$(TARGET_PREFIX)/bin/gcc|g' \
		-e 's|$(TARGET_CXX)|$(TARGET_PREFIX)/bin/g++|g' -e 's|$(TARGET_RANLIB)|$(TARGET_PREFIX)/bin/ranlib|g' \
			$(ICU_IPK_DIR)$(TARGET_PREFIX)/bin/icu-config
#	$(INSTALL) -d $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ICU_SOURCE_DIR)/icu.conf $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/icu.conf
#	$(INSTALL) -d $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ICU_SOURCE_DIR)/rc.icu $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXicu
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXicu
	$(MAKE) $(ICU_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ICU_SOURCE_DIR)/postinst $(ICU_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ICU_SOURCE_DIR)/prerm $(ICU_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ICU_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ICU_IPK_DIR)/CONTROL/postinst $(ICU_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ICU_CONFFILES) | sed -e 's/ /\n/g' > $(ICU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ICU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
icu-ipk: $(ICU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
icu-clean:
	rm -f $(ICU_BUILD_DIR)/.built
	-$(MAKE) -C $(ICU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
icu-dirclean:
	rm -rf $(BUILD_DIR)/$(ICU_DIR) $(ICU_BUILD_DIR) $(ICU_HOST_BUILD_DIR) $(ICU_IPK_DIR) $(ICU_IPK)
#
#
# Some sanity check for the package.
#
icu-check: $(ICU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
