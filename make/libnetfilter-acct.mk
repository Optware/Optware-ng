###########################################################
#
# libnetfilter-acct
#
###########################################################
#
# LIBNETFILTER_ACCT_VERSION, LIBNETFILTER_ACCT_SITE and LIBNETFILTER_ACCT_SOURCE define
# the upstream location of the source code for the package.
# LIBNETFILTER_ACCT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNETFILTER_ACCT_UNZIP is the command used to unzip the source.
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
LIBNETFILTER_ACCT_SITE=ftp://ftp.netfilter.org/pub/libnetfilter_acct
LIBNETFILTER_ACCT_VERSION=1.0.2
LIBNETFILTER_ACCT_SOURCE=libnetfilter_acct-$(LIBNETFILTER_ACCT_VERSION).tar.bz2
LIBNETFILTER_ACCT_DIR=libnetfilter_acct-$(LIBNETFILTER_ACCT_VERSION)
LIBNETFILTER_ACCT_UNZIP=bzcat
LIBNETFILTER_ACCT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNETFILTER_ACCT_DESCRIPTION=Userspace library providing an interface to the extended netfilter accounting infrastructure.
LIBNETFILTER_ACCT_SECTION=kernel
LIBNETFILTER_ACCT_PRIORITY=optional
LIBNETFILTER_ACCT_DEPENDS=libmnl
LIBNETFILTER_ACCT_SUGGESTS=
LIBNETFILTER_ACCT_CONFLICTS=

#
# LIBNETFILTER_ACCT_IPK_VERSION should be incremented when the ipk changes.
#
LIBNETFILTER_ACCT_IPK_VERSION=1

#
# LIBNETFILTER_ACCT_CONFFILES should be a list of user-editable files
#LIBNETFILTER_ACCT_CONFFILES=$(TARGET_PREFIX)/etc/libnetfilter-acct.conf $(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-acct

#
# LIBNETFILTER_ACCT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNETFILTER_ACCT_PATCHES=$(LIBNETFILTER_ACCT_SOURCE_DIR)/configure.patch

ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)))
LIBNETFILTER_ACCT_PATCHES += $(LIBNETFILTER_ACCT_SOURCE_DIR)/no_nfnetlink_compat.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNETFILTER_ACCT_CPPFLAGS=
LIBNETFILTER_ACCT_LDFLAGS=

#
# LIBNETFILTER_ACCT_BUILD_DIR is the directory in which the build is done.
# LIBNETFILTER_ACCT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNETFILTER_ACCT_IPK_DIR is the directory in which the ipk is built.
# LIBNETFILTER_ACCT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNETFILTER_ACCT_BUILD_DIR=$(BUILD_DIR)/libnetfilter-acct
LIBNETFILTER_ACCT_SOURCE_DIR=$(SOURCE_DIR)/libnetfilter-acct
LIBNETFILTER_ACCT_IPK_DIR=$(BUILD_DIR)/libnetfilter-acct-$(LIBNETFILTER_ACCT_VERSION)-ipk
LIBNETFILTER_ACCT_IPK=$(BUILD_DIR)/libnetfilter-acct_$(LIBNETFILTER_ACCT_VERSION)-$(LIBNETFILTER_ACCT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnetfilter-acct-source libnetfilter-acct-unpack libnetfilter-acct libnetfilter-acct-stage libnetfilter-acct-ipk libnetfilter-acct-clean libnetfilter-acct-dirclean libnetfilter-acct-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNETFILTER_ACCT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNETFILTER_ACCT_SITE)/$(LIBNETFILTER_ACCT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNETFILTER_ACCT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnetfilter-acct-source: $(DL_DIR)/$(LIBNETFILTER_ACCT_SOURCE) $(LIBNETFILTER_ACCT_PATCHES)

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
$(LIBNETFILTER_ACCT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNETFILTER_ACCT_SOURCE) $(LIBNETFILTER_ACCT_PATCHES) make/libnetfilter-acct.mk
	$(MAKE) libmnl-stage
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_ACCT_DIR) $(@D)
	$(LIBNETFILTER_ACCT_UNZIP) $(DL_DIR)/$(LIBNETFILTER_ACCT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNETFILTER_ACCT_PATCHES)" ; \
		then cat $(LIBNETFILTER_ACCT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBNETFILTER_ACCT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNETFILTER_ACCT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBNETFILTER_ACCT_DIR) $(@D) ; \
	fi
ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
	sed -i -e '/#include <linux\/netfilter\/nfnetlink_compat\.h>/s|^|//|' $(@D)//include/linux/netfilter/nfnetlink.h
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNETFILTER_ACCT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNETFILTER_ACCT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
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

libnetfilter-acct-unpack: $(LIBNETFILTER_ACCT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNETFILTER_ACCT_BUILD_DIR)/.built: $(LIBNETFILTER_ACCT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libnetfilter-acct: $(LIBNETFILTER_ACCT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNETFILTER_ACCT_BUILD_DIR)/.staged: $(LIBNETFILTER_ACCT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libnetfilter_acct.pc
	rm -f $(STAGING_LIB_DIR)/libnetfilter_acct.la
	touch $@

libnetfilter-acct-stage: $(LIBNETFILTER_ACCT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnetfilter-acct
#
$(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetfilter-acct" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNETFILTER_ACCT_PRIORITY)" >>$@
	@echo "Section: $(LIBNETFILTER_ACCT_SECTION)" >>$@
	@echo "Version: $(LIBNETFILTER_ACCT_VERSION)-$(LIBNETFILTER_ACCT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNETFILTER_ACCT_MAINTAINER)" >>$@
	@echo "Source: $(LIBNETFILTER_ACCT_SITE)/$(LIBNETFILTER_ACCT_SOURCE)" >>$@
	@echo "Description: $(LIBNETFILTER_ACCT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETFILTER_ACCT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETFILTER_ACCT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETFILTER_ACCT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/libnetfilter-acct/...
# Documentation files should be installed in $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/doc/libnetfilter-acct/...
# Daemon startup scripts should be installed in $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libnetfilter-acct
#
# You may need to patch your application to make it use these locations.
#
$(LIBNETFILTER_ACCT_IPK): $(LIBNETFILTER_ACCT_BUILD_DIR)/.built
	rm -rf $(LIBNETFILTER_ACCT_IPK_DIR) $(BUILD_DIR)/libnetfilter-acct_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNETFILTER_ACCT_BUILD_DIR) DESTDIR=$(LIBNETFILTER_ACCT_IPK_DIR) install-strip
	rm -rf $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/include
#	$(INSTALL) -d $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBNETFILTER_ACCT_SOURCE_DIR)/libnetfilter-acct.conf $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/libnetfilter-acct.conf
#	$(INSTALL) -d $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBNETFILTER_ACCT_SOURCE_DIR)/rc.libnetfilter-acct $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-acct
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_ACCT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-acct
	$(MAKE) $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBNETFILTER_ACCT_SOURCE_DIR)/postinst $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBNETFILTER_ACCT_SOURCE_DIR)/prerm $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/prerm
#	echo $(LIBNETFILTER_ACCT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNETFILTER_ACCT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETFILTER_ACCT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnetfilter-acct-ipk: $(LIBNETFILTER_ACCT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnetfilter-acct-clean:
	rm -f $(LIBNETFILTER_ACCT_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNETFILTER_ACCT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnetfilter-acct-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_ACCT_DIR) $(LIBNETFILTER_ACCT_BUILD_DIR) $(LIBNETFILTER_ACCT_IPK_DIR) $(LIBNETFILTER_ACCT_IPK)
#
#
# Some sanity check for the package.
#
libnetfilter-acct-check: $(LIBNETFILTER_ACCT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
