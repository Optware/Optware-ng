###########################################################
#
# libjson-c
#
###########################################################
#
# LIBJSON_C_VERSION, LIBJSON_C_SITE and LIBJSON_C_SOURCE define
# the upstream location of the source code for the package.
# LIBJSON_C_DIR is the directory which is created when the source
# archive is unpacked.
# LIBJSON_C_UNZIP is the command used to unzip the source.
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
LIBJSON_C_URL=https://s3.amazonaws.com/json-c_releases/releases/$(LIBJSON_C_SOURCE)
LIBJSON_C_VERSION=0.12.1
LIBJSON_C_SOURCE=json-c-$(LIBJSON_C_VERSION)-nodoc.tar.gz
LIBJSON_C_DIR=json-c-$(LIBJSON_C_VERSION)
LIBJSON_C_UNZIP=zcat
LIBJSON_C_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBJSON_C_DESCRIPTION=libjson-c is a library for javascript object notation backends.
LIBJSON_C_SECTION=libs
LIBJSON_C_PRIORITY=optional
LIBJSON_C_DEPENDS=
LIBJSON_C_SUGGESTS=
LIBJSON_C_CONFLICTS=

#
# LIBJSON_C_IPK_VERSION should be incremented when the ipk changes.
#
LIBJSON_C_IPK_VERSION=1

#
# LIBJSON_C_CONFFILES should be a list of user-editable files
#LIBJSON_C_CONFFILES=$(TARGET_PREFIX)/etc/libjson-c.conf $(TARGET_PREFIX)/etc/init.d/SXXlibjson-c

#
# LIBJSON_C_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBJSON_C_PATCHES=\
$(LIBJSON_C_SOURCE_DIR)/libm.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBJSON_C_CPPFLAGS=-fPIC -Wno-implicit-fallthrough
LIBJSON_C_LDFLAGS=

#
# LIBJSON_C_BUILD_DIR is the directory in which the build is done.
# LIBJSON_C_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBJSON_C_IPK_DIR is the directory in which the ipk is built.
# LIBJSON_C_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBJSON_C_BUILD_DIR=$(BUILD_DIR)/libjson-c
LIBJSON_C_SOURCE_DIR=$(SOURCE_DIR)/libjson-c
LIBJSON_C_IPK_DIR=$(BUILD_DIR)/libjson-c-$(LIBJSON_C_VERSION)-ipk
LIBJSON_C_IPK=$(BUILD_DIR)/libjson-c_$(LIBJSON_C_VERSION)-$(LIBJSON_C_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libjson-c-source libjson-c-unpack libjson-c libjson-c-stage libjson-c-ipk libjson-c-clean libjson-c-dirclean libjson-c-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBJSON_C_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBJSON_C_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBJSON_C_SOURCE).sha512
#
$(DL_DIR)/$(LIBJSON_C_SOURCE):
	$(WGET) -O $@ $(LIBJSON_C_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libjson-c-source: $(DL_DIR)/$(LIBJSON_C_SOURCE) $(LIBJSON_C_PATCHES)

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
$(LIBJSON_C_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBJSON_C_SOURCE) $(LIBJSON_C_PATCHES) make/libjson-c.mk
	rm -rf $(BUILD_DIR)/$(LIBJSON_C_DIR) $(@D)
	$(LIBJSON_C_UNZIP) $(DL_DIR)/$(LIBJSON_C_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBJSON_C_PATCHES)" ; \
		then cat $(LIBJSON_C_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBJSON_C_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBJSON_C_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBJSON_C_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBJSON_C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBJSON_C_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
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

libjson-c-unpack: $(LIBJSON_C_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBJSON_C_BUILD_DIR)/.built: $(LIBJSON_C_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libjson-c: $(LIBJSON_C_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBJSON_C_BUILD_DIR)/.staged: $(LIBJSON_C_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libjson-c.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/json-c.pc
	touch $@

libjson-c-stage: $(LIBJSON_C_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libjson-c
#
$(LIBJSON_C_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libjson-c" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBJSON_C_PRIORITY)" >>$@
	@echo "Section: $(LIBJSON_C_SECTION)" >>$@
	@echo "Version: $(LIBJSON_C_VERSION)-$(LIBJSON_C_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBJSON_C_MAINTAINER)" >>$@
	@echo "Source: $(LIBJSON_C_URL)" >>$@
	@echo "Description: $(LIBJSON_C_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBJSON_C_DEPENDS)" >>$@
	@echo "Suggests: $(LIBJSON_C_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBJSON_C_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/libjson-c/...
# Documentation files should be installed in $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/doc/libjson-c/...
# Daemon startup scripts should be installed in $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libjson-c
#
# You may need to patch your application to make it use these locations.
#
$(LIBJSON_C_IPK): $(LIBJSON_C_BUILD_DIR)/.built
	rm -rf $(LIBJSON_C_IPK_DIR) $(BUILD_DIR)/libjson-c_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBJSON_C_BUILD_DIR) DESTDIR=$(LIBJSON_C_IPK_DIR) install-strip
	rm -f $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/lib/libjson-c.la
#	$(INSTALL) -d $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBJSON_C_SOURCE_DIR)/libjson-c.conf $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/libjson-c.conf
#	$(INSTALL) -d $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBJSON_C_SOURCE_DIR)/rc.libjson-c $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibjson-c
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJSON_C_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibjson-c
	$(MAKE) $(LIBJSON_C_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBJSON_C_SOURCE_DIR)/postinst $(LIBJSON_C_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJSON_C_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBJSON_C_SOURCE_DIR)/prerm $(LIBJSON_C_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBJSON_C_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBJSON_C_IPK_DIR)/CONTROL/postinst $(LIBJSON_C_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBJSON_C_CONFFILES) | sed -e 's/ /\n/g' > $(LIBJSON_C_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBJSON_C_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBJSON_C_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libjson-c-ipk: $(LIBJSON_C_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libjson-c-clean:
	rm -f $(LIBJSON_C_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBJSON_C_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libjson-c-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBJSON_C_DIR) $(LIBJSON_C_BUILD_DIR) $(LIBJSON_C_IPK_DIR) $(LIBJSON_C_IPK)
#
#
# Some sanity check for the package.
#
libjson-c-check: $(LIBJSON_C_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
