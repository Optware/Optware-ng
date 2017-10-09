###########################################################
#
# libnetfilter-conntrack
#
###########################################################
#
# LIBNETFILTER_CONNTRACK_VERSION, LIBNETFILTER_CONNTRACK_SITE and LIBNETFILTER_CONNTRACK_SOURCE define
# the upstream location of the source code for the package.
# LIBNETFILTER_CONNTRACK_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNETFILTER_CONNTRACK_UNZIP is the command used to unzip the source.
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
LIBNETFILTER_CONNTRACK_SITE=ftp://ftp.netfilter.org/pub/libnetfilter_conntrack
LIBNETFILTER_CONNTRACK_VERSION=1.0.4
LIBNETFILTER_CONNTRACK_SOURCE=libnetfilter_conntrack-$(LIBNETFILTER_CONNTRACK_VERSION).tar.bz2
LIBNETFILTER_CONNTRACK_DIR=libnetfilter_conntrack-$(LIBNETFILTER_CONNTRACK_VERSION)
LIBNETFILTER_CONNTRACK_UNZIP=bzcat
LIBNETFILTER_CONNTRACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNETFILTER_CONNTRACK_DESCRIPTION=Netfilter conntrack userspace library.
LIBNETFILTER_CONNTRACK_SECTION=kernel
LIBNETFILTER_CONNTRACK_PRIORITY=optional
LIBNETFILTER_CONNTRACK_DEPENDS=libnfnetlink, libmnl
LIBNETFILTER_CONNTRACK_SUGGESTS=
LIBNETFILTER_CONNTRACK_CONFLICTS=

#
# LIBNETFILTER_CONNTRACK_IPK_VERSION should be incremented when the ipk changes.
#
LIBNETFILTER_CONNTRACK_IPK_VERSION=2

#
# LIBNETFILTER_CONNTRACK_CONFFILES should be a list of user-editable files
#LIBNETFILTER_CONNTRACK_CONFFILES=$(TARGET_PREFIX)/etc/libnetfilter-conntrack.conf $(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-conntrack

#
# LIBNETFILTER_CONNTRACK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNETFILTER_CONNTRACK_PATCHES=$(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/configure.patch
ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
LIBNETFILTER_CONNTRACK_PATCHES+=$(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/linux_netlink_h_for_old_kernel.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNETFILTER_CONNTRACK_CPPFLAGS=-Wno-incompatible-pointer-types
LIBNETFILTER_CONNTRACK_LDFLAGS=

#
# LIBNETFILTER_CONNTRACK_BUILD_DIR is the directory in which the build is done.
# LIBNETFILTER_CONNTRACK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNETFILTER_CONNTRACK_IPK_DIR is the directory in which the ipk is built.
# LIBNETFILTER_CONNTRACK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNETFILTER_CONNTRACK_BUILD_DIR=$(BUILD_DIR)/libnetfilter-conntrack
LIBNETFILTER_CONNTRACK_SOURCE_DIR=$(SOURCE_DIR)/libnetfilter-conntrack
LIBNETFILTER_CONNTRACK_IPK_DIR=$(BUILD_DIR)/libnetfilter-conntrack-$(LIBNETFILTER_CONNTRACK_VERSION)-ipk
LIBNETFILTER_CONNTRACK_IPK=$(BUILD_DIR)/libnetfilter-conntrack_$(LIBNETFILTER_CONNTRACK_VERSION)-$(LIBNETFILTER_CONNTRACK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnetfilter-conntrack-source libnetfilter-conntrack-unpack libnetfilter-conntrack libnetfilter-conntrack-stage libnetfilter-conntrack-ipk libnetfilter-conntrack-clean libnetfilter-conntrack-dirclean libnetfilter-conntrack-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNETFILTER_CONNTRACK_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNETFILTER_CONNTRACK_SITE)/$(LIBNETFILTER_CONNTRACK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBNETFILTER_CONNTRACK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnetfilter-conntrack-source: $(DL_DIR)/$(LIBNETFILTER_CONNTRACK_SOURCE) $(LIBNETFILTER_CONNTRACK_PATCHES)

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
$(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNETFILTER_CONNTRACK_SOURCE) $(LIBNETFILTER_CONNTRACK_PATCHES) make/libnetfilter-conntrack.mk
	$(MAKE) libnfnetlink-stage libmnl-stage
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_CONNTRACK_DIR) $(LIBNETFILTER_CONNTRACK_BUILD_DIR)
	$(LIBNETFILTER_CONNTRACK_UNZIP) $(DL_DIR)/$(LIBNETFILTER_CONNTRACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNETFILTER_CONNTRACK_PATCHES)" ; \
		then cat $(LIBNETFILTER_CONNTRACK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBNETFILTER_CONNTRACK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNETFILTER_CONNTRACK_DIR)" != "$(LIBNETFILTER_CONNTRACK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBNETFILTER_CONNTRACK_DIR) $(LIBNETFILTER_CONNTRACK_BUILD_DIR) ; \
	fi
	(cd $(LIBNETFILTER_CONNTRACK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNETFILTER_CONNTRACK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNETFILTER_CONNTRACK_LDFLAGS)" \
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
	$(PATCH_LIBTOOL) $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/libtool
	touch $@

libnetfilter-conntrack-unpack: $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.built: $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libnetfilter-conntrack: $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.staged: $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libnetfilter_conntrack.pc
	rm -f $(STAGING_LIB_DIR)/libnetfilter_conntrack.la
	touch $@

libnetfilter-conntrack-stage: $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnetfilter-conntrack
#
$(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnetfilter-conntrack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNETFILTER_CONNTRACK_PRIORITY)" >>$@
	@echo "Section: $(LIBNETFILTER_CONNTRACK_SECTION)" >>$@
	@echo "Version: $(LIBNETFILTER_CONNTRACK_VERSION)-$(LIBNETFILTER_CONNTRACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNETFILTER_CONNTRACK_MAINTAINER)" >>$@
	@echo "Source: $(LIBNETFILTER_CONNTRACK_SITE)/$(LIBNETFILTER_CONNTRACK_SOURCE)" >>$@
	@echo "Description: $(LIBNETFILTER_CONNTRACK_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNETFILTER_CONNTRACK_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNETFILTER_CONNTRACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNETFILTER_CONNTRACK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/libnetfilter-conntrack/...
# Documentation files should be installed in $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/doc/libnetfilter-conntrack/...
# Daemon startup scripts should be installed in $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libnetfilter-conntrack
#
# You may need to patch your application to make it use these locations.
#
$(LIBNETFILTER_CONNTRACK_IPK): $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.built
	rm -rf $(LIBNETFILTER_CONNTRACK_IPK_DIR) $(BUILD_DIR)/libnetfilter-conntrack_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNETFILTER_CONNTRACK_BUILD_DIR) DESTDIR=$(LIBNETFILTER_CONNTRACK_IPK_DIR) install-strip
	rm -rf $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/include
#	$(INSTALL) -d $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/libnetfilter-conntrack.conf $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/libnetfilter-conntrack.conf
#	$(INSTALL) -d $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/rc.libnetfilter-conntrack $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-conntrack
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_CONNTRACK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnetfilter-conntrack
	$(MAKE) $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/postinst $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBNETFILTER_CONNTRACK_SOURCE_DIR)/prerm $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/prerm
#	echo $(LIBNETFILTER_CONNTRACK_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNETFILTER_CONNTRACK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNETFILTER_CONNTRACK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnetfilter-conntrack-ipk: $(LIBNETFILTER_CONNTRACK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnetfilter-conntrack-clean:
	rm -f $(LIBNETFILTER_CONNTRACK_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNETFILTER_CONNTRACK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnetfilter-conntrack-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNETFILTER_CONNTRACK_DIR) $(LIBNETFILTER_CONNTRACK_BUILD_DIR) $(LIBNETFILTER_CONNTRACK_IPK_DIR) $(LIBNETFILTER_CONNTRACK_IPK)
#
#
# Some sanity check for the package.
#
libnetfilter-conntrack-check: $(LIBNETFILTER_CONNTRACK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBNETFILTER_CONNTRACK_IPK)
