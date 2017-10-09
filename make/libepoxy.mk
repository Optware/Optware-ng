###########################################################
#
# libepoxy
#
###########################################################

# You must replace "libepoxy" and "LIBEPOXY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBEPOXY_VERSION, LIBEPOXY_SITE and LIBEPOXY_SOURCE define
# the upstream location of the source code for the package.
# LIBEPOXY_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEPOXY_UNZIP is the command used to unzip the source.
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
LIBEPOXY_SITE=http://crux.nu/files
LIBEPOXY_VERSION=1.2
LIBEPOXY_SOURCE=libepoxy-$(LIBEPOXY_VERSION).tar.gz
LIBEPOXY_DIR=libepoxy-$(LIBEPOXY_VERSION)
LIBEPOXY_UNZIP=zcat
LIBEPOXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEPOXY_DESCRIPTION=Library for handling OpenGL function pointer management.
LIBEPOXY_SECTION=lib
LIBEPOXY_PRIORITY=optional
LIBEPOXY_DEPENDS=mesalib
LIBEPOXY_SUGGESTS=
LIBEPOXY_CONFLICTS=

#
# LIBEPOXY_IPK_VERSION should be incremented when the ipk changes.
#
LIBEPOXY_IPK_VERSION=2

#
# LIBEPOXY_CONFFILES should be a list of user-editable files
#LIBEPOXY_CONFFILES=$(TARGET_PREFIX)/etc/libepoxy.conf $(TARGET_PREFIX)/etc/init.d/SXXlibepoxy

#
# LIBEPOXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEPOXY_PATCHES=$(LIBEPOXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEPOXY_CPPFLAGS=
LIBEPOXY_LDFLAGS=

#
# LIBEPOXY_BUILD_DIR is the directory in which the build is done.
# LIBEPOXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEPOXY_IPK_DIR is the directory in which the ipk is built.
# LIBEPOXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEPOXY_BUILD_DIR=$(BUILD_DIR)/libepoxy
LIBEPOXY_SOURCE_DIR=$(SOURCE_DIR)/libepoxy
LIBEPOXY_IPK_DIR=$(BUILD_DIR)/libepoxy-$(LIBEPOXY_VERSION)-ipk
LIBEPOXY_IPK=$(BUILD_DIR)/libepoxy_$(LIBEPOXY_VERSION)-$(LIBEPOXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libepoxy-source libepoxy-unpack libepoxy libepoxy-stage libepoxy-ipk libepoxy-clean libepoxy-dirclean libepoxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEPOXY_SOURCE):
	$(WGET) -P $(@D) $(LIBEPOXY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libepoxy-source: $(DL_DIR)/$(LIBEPOXY_SOURCE) $(LIBEPOXY_PATCHES)

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
$(LIBEPOXY_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEPOXY_SOURCE) $(LIBEPOXY_PATCHES) make/libepoxy.mk
	$(MAKE) xorg-macros-stage x11-stage mesalib-stage
	rm -rf $(BUILD_DIR)/$(LIBEPOXY_DIR) $(@D)
	$(LIBEPOXY_UNZIP) $(DL_DIR)/$(LIBEPOXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEPOXY_PATCHES)" ; \
		then cat $(LIBEPOXY_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBEPOXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEPOXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBEPOXY_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEPOXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEPOXY_LDFLAGS)" \
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

libepoxy-unpack: $(LIBEPOXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEPOXY_BUILD_DIR)/.built: $(LIBEPOXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libepoxy: $(LIBEPOXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEPOXY_BUILD_DIR)/.staged: $(LIBEPOXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libepoxy.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/epoxy.pc
	touch $@

libepoxy-stage: $(LIBEPOXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libepoxy
#
$(LIBEPOXY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libepoxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEPOXY_PRIORITY)" >>$@
	@echo "Section: $(LIBEPOXY_SECTION)" >>$@
	@echo "Version: $(LIBEPOXY_VERSION)-$(LIBEPOXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEPOXY_MAINTAINER)" >>$@
	@echo "Source: $(LIBEPOXY_SITE)/$(LIBEPOXY_SOURCE)" >>$@
	@echo "Description: $(LIBEPOXY_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEPOXY_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEPOXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEPOXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/libepoxy/...
# Documentation files should be installed in $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/doc/libepoxy/...
# Daemon startup scripts should be installed in $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libepoxy
#
# You may need to patch your application to make it use these locations.
#
$(LIBEPOXY_IPK): $(LIBEPOXY_BUILD_DIR)/.built
	rm -rf $(LIBEPOXY_IPK_DIR) $(BUILD_DIR)/libepoxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEPOXY_BUILD_DIR) DESTDIR=$(LIBEPOXY_IPK_DIR) install-strip
	rm -f $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBEPOXY_SOURCE_DIR)/libepoxy.conf $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/libepoxy.conf
#	$(INSTALL) -d $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBEPOXY_SOURCE_DIR)/rc.libepoxy $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibepoxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEPOXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibepoxy
	$(MAKE) $(LIBEPOXY_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBEPOXY_SOURCE_DIR)/postinst $(LIBEPOXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEPOXY_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBEPOXY_SOURCE_DIR)/prerm $(LIBEPOXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBEPOXY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBEPOXY_IPK_DIR)/CONTROL/postinst $(LIBEPOXY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBEPOXY_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEPOXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEPOXY_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBEPOXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libepoxy-ipk: $(LIBEPOXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libepoxy-clean:
	rm -f $(LIBEPOXY_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBEPOXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libepoxy-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEPOXY_DIR) $(LIBEPOXY_BUILD_DIR) $(LIBEPOXY_IPK_DIR) $(LIBEPOXY_IPK)
#
#
# Some sanity check for the package.
#
libepoxy-check: $(LIBEPOXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
