###########################################################
#
# libmm
#
###########################################################
#
# LIBMM_VERSION, LIBMM_SITE and LIBMM_SOURCE define
# the upstream location of the source code for the package.
# LIBMM_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMM_UNZIP is the command used to unzip the source.
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
LIBMM_URL=http://smstools3.kekekasvi.com/packages/mm-$(LIBMM_VERSION).tar.gz
LIBMM_VERSION=1.4.2
LIBMM_SOURCE=mm-$(LIBMM_VERSION).tar.gz
LIBMM_DIR=mm-$(LIBMM_VERSION)
LIBMM_UNZIP=zcat
LIBMM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMM_DESCRIPTION=Shared memory library.
LIBMM_SECTION=libs
LIBMM_PRIORITY=optional
LIBMM_DEPENDS=
LIBMM_SUGGESTS=
LIBMM_CONFLICTS=

#
# LIBMM_IPK_VERSION should be incremented when the ipk changes.
#
LIBMM_IPK_VERSION=1

#
# LIBMM_CONFFILES should be a list of user-editable files
#LIBMM_CONFFILES=$(TARGET_PREFIX)/etc/libmm.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmm

#
# LIBMM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMM_PATCHES=$(LIBMM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMM_CPPFLAGS=
LIBMM_LDFLAGS=

#
# LIBMM_BUILD_DIR is the directory in which the build is done.
# LIBMM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMM_IPK_DIR is the directory in which the ipk is built.
# LIBMM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMM_BUILD_DIR=$(BUILD_DIR)/libmm
LIBMM_SOURCE_DIR=$(SOURCE_DIR)/libmm
LIBMM_IPK_DIR=$(BUILD_DIR)/libmm-$(LIBMM_VERSION)-ipk
LIBMM_IPK=$(BUILD_DIR)/libmm_$(LIBMM_VERSION)-$(LIBMM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmm-source libmm-unpack libmm libmm-stage libmm-ipk libmm-clean libmm-dirclean libmm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBMM_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBMM_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBMM_SOURCE).sha512
#
$(DL_DIR)/$(LIBMM_SOURCE):
	$(WGET) -O $@ $(LIBMM_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmm-source: $(DL_DIR)/$(LIBMM_SOURCE) $(LIBMM_PATCHES)

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
$(LIBMM_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMM_SOURCE) $(LIBMM_PATCHES) make/libmm.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMM_DIR) $(@D)
	$(LIBMM_UNZIP) $(DL_DIR)/$(LIBMM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMM_PATCHES)" ; \
		then cat $(LIBMM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMM_LDFLAGS)" \
		ac_cv_maxsegsize=33554432 \
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

libmm-unpack: $(LIBMM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMM_BUILD_DIR)/.built: $(LIBMM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmm: $(LIBMM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMM_BUILD_DIR)/.staged: $(LIBMM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmm.la
	touch $@

libmm-stage: $(LIBMM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmm
#
$(LIBMM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMM_PRIORITY)" >>$@
	@echo "Section: $(LIBMM_SECTION)" >>$@
	@echo "Version: $(LIBMM_VERSION)-$(LIBMM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMM_MAINTAINER)" >>$@
	@echo "Source: $(LIBMM_URL)" >>$@
	@echo "Description: $(LIBMM_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMM_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMM_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/libmm/...
# Documentation files should be installed in $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/doc/libmm/...
# Daemon startup scripts should be installed in $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmm
#
# You may need to patch your application to make it use these locations.
#
$(LIBMM_IPK): $(LIBMM_BUILD_DIR)/.built
	rm -rf $(LIBMM_IPK_DIR) $(BUILD_DIR)/libmm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMM_BUILD_DIR) DESTDIR=$(LIBMM_IPK_DIR) install
	rm -f $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(STRIP_COMMAND) $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBMM_SOURCE_DIR)/libmm.conf $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/libmm.conf
#	$(INSTALL) -d $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBMM_SOURCE_DIR)/rc.libmm $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmm
	$(MAKE) $(LIBMM_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMM_SOURCE_DIR)/postinst $(LIBMM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMM_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMM_SOURCE_DIR)/prerm $(LIBMM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMM_IPK_DIR)/CONTROL/postinst $(LIBMM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBMM_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMM_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBMM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmm-ipk: $(LIBMM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmm-clean:
	rm -f $(LIBMM_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmm-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMM_DIR) $(LIBMM_BUILD_DIR) $(LIBMM_IPK_DIR) $(LIBMM_IPK)
#
#
# Some sanity check for the package.
#
libmm-check: $(LIBMM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
