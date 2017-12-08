###########################################################
#
# libopus
#
###########################################################
#
# LIBOPUS_VERSION, LIBOPUS_SITE and LIBOPUS_SOURCE define
# the upstream location of the source code for the package.
# LIBOPUS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOPUS_UNZIP is the command used to unzip the source.
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
LIBOPUS_URL=https://archive.mozilla.org/pub/opus/$(LIBOPUS_SOURCE)
LIBOPUS_VERSION=1.2.1
LIBOPUS_SOURCE=opus-$(LIBOPUS_VERSION).tar.gz
LIBOPUS_DIR=opus-$(LIBOPUS_VERSION)
LIBOPUS_UNZIP=zcat
LIBOPUS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOPUS_DESCRIPTION=Opus is a lossy audio compression format.
LIBOPUS_SECTION=libs
LIBOPUS_PRIORITY=optional
LIBOPUS_DEPENDS=
LIBOPUS_SUGGESTS=
LIBOPUS_CONFLICTS=

#
# LIBOPUS_IPK_VERSION should be incremented when the ipk changes.
#
LIBOPUS_IPK_VERSION=1

#
# LIBOPUS_CONFFILES should be a list of user-editable files
#LIBOPUS_CONFFILES=$(TARGET_PREFIX)/etc/libopus.conf $(TARGET_PREFIX)/etc/init.d/SXXlibopus

#
# LIBOPUS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBOPUS_PATCHES=$(LIBOPUS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOPUS_CPPFLAGS=
LIBOPUS_LDFLAGS=

#
# LIBOPUS_BUILD_DIR is the directory in which the build is done.
# LIBOPUS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOPUS_IPK_DIR is the directory in which the ipk is built.
# LIBOPUS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOPUS_BUILD_DIR=$(BUILD_DIR)/libopus
LIBOPUS_SOURCE_DIR=$(SOURCE_DIR)/libopus
LIBOPUS_IPK_DIR=$(BUILD_DIR)/libopus-$(LIBOPUS_VERSION)-ipk
LIBOPUS_IPK=$(BUILD_DIR)/libopus_$(LIBOPUS_VERSION)-$(LIBOPUS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libopus-source libopus-unpack libopus libopus-stage libopus-ipk libopus-clean libopus-dirclean libopus-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBOPUS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBOPUS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBOPUS_SOURCE).sha512
#
$(DL_DIR)/$(LIBOPUS_SOURCE):
	$(WGET) -O $@ $(LIBOPUS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libopus-source: $(DL_DIR)/$(LIBOPUS_SOURCE) $(LIBOPUS_PATCHES)

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
$(LIBOPUS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOPUS_SOURCE) $(LIBOPUS_PATCHES) make/libopus.mk
	rm -rf $(BUILD_DIR)/$(LIBOPUS_DIR) $(@D)
	$(LIBOPUS_UNZIP) $(DL_DIR)/$(LIBOPUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBOPUS_PATCHES)" ; \
		then cat $(LIBOPUS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBOPUS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBOPUS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBOPUS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOPUS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOPUS_LDFLAGS)" \
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

libopus-unpack: $(LIBOPUS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOPUS_BUILD_DIR)/.built: $(LIBOPUS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libopus: $(LIBOPUS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOPUS_BUILD_DIR)/.staged: $(LIBOPUS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libopus.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/opus.pc
	touch $@

libopus-stage: $(LIBOPUS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libopus
#
$(LIBOPUS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libopus" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOPUS_PRIORITY)" >>$@
	@echo "Section: $(LIBOPUS_SECTION)" >>$@
	@echo "Version: $(LIBOPUS_VERSION)-$(LIBOPUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOPUS_MAINTAINER)" >>$@
	@echo "Source: $(LIBOPUS_URL)" >>$@
	@echo "Description: $(LIBOPUS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOPUS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBOPUS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBOPUS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/libopus/...
# Documentation files should be installed in $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/doc/libopus/...
# Daemon startup scripts should be installed in $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libopus
#
# You may need to patch your application to make it use these locations.
#
$(LIBOPUS_IPK): $(LIBOPUS_BUILD_DIR)/.built
	rm -rf $(LIBOPUS_IPK_DIR) $(BUILD_DIR)/libopus_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOPUS_BUILD_DIR) DESTDIR=$(LIBOPUS_IPK_DIR) install-strip
	rm -f $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/lib/libopus.la
#	$(INSTALL) -d $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBOPUS_SOURCE_DIR)/libopus.conf $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/libopus.conf
#	$(INSTALL) -d $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBOPUS_SOURCE_DIR)/rc.libopus $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibopus
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibopus
	$(MAKE) $(LIBOPUS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBOPUS_SOURCE_DIR)/postinst $(LIBOPUS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPUS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBOPUS_SOURCE_DIR)/prerm $(LIBOPUS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPUS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBOPUS_IPK_DIR)/CONTROL/postinst $(LIBOPUS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBOPUS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOPUS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOPUS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBOPUS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libopus-ipk: $(LIBOPUS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libopus-clean:
	rm -f $(LIBOPUS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBOPUS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libopus-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOPUS_DIR) $(LIBOPUS_BUILD_DIR) $(LIBOPUS_IPK_DIR) $(LIBOPUS_IPK)
#
#
# Some sanity check for the package.
#
libopus-check: $(LIBOPUS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
