###########################################################
#
# libxkbcommon
#
###########################################################

# You must replace "libxkbcommon" and "LIBXKBCOMMON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBXKBCOMMON_VERSION, LIBXKBCOMMON_SITE and LIBXKBCOMMON_SOURCE define
# the upstream location of the source code for the package.
# LIBXKBCOMMON_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXKBCOMMON_UNZIP is the command used to unzip the source.
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
LIBXKBCOMMON_SITE=http://xkbcommon.org/download
LIBXKBCOMMON_VERSION=0.5.0
LIBXKBCOMMON_SOURCE=libxkbcommon-$(LIBXKBCOMMON_VERSION).tar.xz
LIBXKBCOMMON_DIR=libxkbcommon-$(LIBXKBCOMMON_VERSION)
LIBXKBCOMMON_UNZIP=xzcat
LIBXKBCOMMON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBXKBCOMMON_DESCRIPTION=xkbcommon is a library to handle keyboard descriptions
LIBXKBCOMMON_SECTION=lib
LIBXKBCOMMON_PRIORITY=optional
LIBXKBCOMMON_DEPENDS=xcb
LIBXKBCOMMON_SUGGESTS=
LIBXKBCOMMON_CONFLICTS=

#
# LIBXKBCOMMON_IPK_VERSION should be incremented when the ipk changes.
#
LIBXKBCOMMON_IPK_VERSION=1

#
# LIBXKBCOMMON_CONFFILES should be a list of user-editable files
#LIBXKBCOMMON_CONFFILES=/opt/etc/libxkbcommon.conf /opt/etc/init.d/SXXlibxkbcommon

#
# LIBXKBCOMMON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBXKBCOMMON_PATCHES=$(LIBXKBCOMMON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXKBCOMMON_CPPFLAGS=
LIBXKBCOMMON_LDFLAGS=

#
# LIBXKBCOMMON_BUILD_DIR is the directory in which the build is done.
# LIBXKBCOMMON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXKBCOMMON_IPK_DIR is the directory in which the ipk is built.
# LIBXKBCOMMON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXKBCOMMON_BUILD_DIR=$(BUILD_DIR)/libxkbcommon
LIBXKBCOMMON_SOURCE_DIR=$(SOURCE_DIR)/libxkbcommon
LIBXKBCOMMON_IPK_DIR=$(BUILD_DIR)/libxkbcommon-$(LIBXKBCOMMON_VERSION)-ipk
LIBXKBCOMMON_IPK=$(BUILD_DIR)/libxkbcommon_$(LIBXKBCOMMON_VERSION)-$(LIBXKBCOMMON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libxkbcommon-source libxkbcommon-unpack libxkbcommon libxkbcommon-stage libxkbcommon-ipk libxkbcommon-clean libxkbcommon-dirclean libxkbcommon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBXKBCOMMON_SOURCE):
	$(WGET) -P $(@D) $(LIBXKBCOMMON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxkbcommon-source: $(DL_DIR)/$(LIBXKBCOMMON_SOURCE) $(LIBXKBCOMMON_PATCHES)

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
$(LIBXKBCOMMON_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXKBCOMMON_SOURCE) $(LIBXKBCOMMON_PATCHES) make/libxkbcommon.mk
	$(MAKE) xcb-stage
	rm -rf $(BUILD_DIR)/$(LIBXKBCOMMON_DIR) $(@D)
	$(LIBXKBCOMMON_UNZIP) $(DL_DIR)/$(LIBXKBCOMMON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBXKBCOMMON_PATCHES)" ; \
		then cat $(LIBXKBCOMMON_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBXKBCOMMON_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBXKBCOMMON_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBXKBCOMMON_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXKBCOMMON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXKBCOMMON_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libxkbcommon-unpack: $(LIBXKBCOMMON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXKBCOMMON_BUILD_DIR)/.built: $(LIBXKBCOMMON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libxkbcommon: $(LIBXKBCOMMON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXKBCOMMON_BUILD_DIR)/.staged: $(LIBXKBCOMMON_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xkbcommon.pc \
		$(STAGING_LIB_DIR)/pkgconfig/xkbcommon-x11.pc
	rm -f $(STAGING_LIB_DIR)/libxkbcommon.la $(STAGING_LIB_DIR)/libxkbcommon-x11.la
	touch $@

libxkbcommon-stage: $(LIBXKBCOMMON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libxkbcommon
#
$(LIBXKBCOMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libxkbcommon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXKBCOMMON_PRIORITY)" >>$@
	@echo "Section: $(LIBXKBCOMMON_SECTION)" >>$@
	@echo "Version: $(LIBXKBCOMMON_VERSION)-$(LIBXKBCOMMON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXKBCOMMON_MAINTAINER)" >>$@
	@echo "Source: $(LIBXKBCOMMON_SITE)/$(LIBXKBCOMMON_SOURCE)" >>$@
	@echo "Description: $(LIBXKBCOMMON_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXKBCOMMON_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXKBCOMMON_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXKBCOMMON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXKBCOMMON_IPK_DIR)/opt/sbin or $(LIBXKBCOMMON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXKBCOMMON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBXKBCOMMON_IPK_DIR)/opt/etc/libxkbcommon/...
# Documentation files should be installed in $(LIBXKBCOMMON_IPK_DIR)/opt/doc/libxkbcommon/...
# Daemon startup scripts should be installed in $(LIBXKBCOMMON_IPK_DIR)/opt/etc/init.d/S??libxkbcommon
#
# You may need to patch your application to make it use these locations.
#
$(LIBXKBCOMMON_IPK): $(LIBXKBCOMMON_BUILD_DIR)/.built
	rm -rf $(LIBXKBCOMMON_IPK_DIR) $(BUILD_DIR)/libxkbcommon_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBXKBCOMMON_BUILD_DIR) DESTDIR=$(LIBXKBCOMMON_IPK_DIR) install-strip
	rm -f $(LIBXKBCOMMON_IPK_DIR)/opt/lib/*.la
#	install -d $(LIBXKBCOMMON_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBXKBCOMMON_SOURCE_DIR)/libxkbcommon.conf $(LIBXKBCOMMON_IPK_DIR)/opt/etc/libxkbcommon.conf
#	install -d $(LIBXKBCOMMON_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBXKBCOMMON_SOURCE_DIR)/rc.libxkbcommon $(LIBXKBCOMMON_IPK_DIR)/opt/etc/init.d/SXXlibxkbcommon
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXKBCOMMON_IPK_DIR)/opt/etc/init.d/SXXlibxkbcommon
	$(MAKE) $(LIBXKBCOMMON_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBXKBCOMMON_SOURCE_DIR)/postinst $(LIBXKBCOMMON_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXKBCOMMON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBXKBCOMMON_SOURCE_DIR)/prerm $(LIBXKBCOMMON_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXKBCOMMON_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBXKBCOMMON_IPK_DIR)/CONTROL/postinst $(LIBXKBCOMMON_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBXKBCOMMON_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXKBCOMMON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXKBCOMMON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXKBCOMMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libxkbcommon-ipk: $(LIBXKBCOMMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libxkbcommon-clean:
	rm -f $(LIBXKBCOMMON_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBXKBCOMMON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxkbcommon-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXKBCOMMON_DIR) $(LIBXKBCOMMON_BUILD_DIR) $(LIBXKBCOMMON_IPK_DIR) $(LIBXKBCOMMON_IPK)
#
#
# Some sanity check for the package.
#
libxkbcommon-check: $(LIBXKBCOMMON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
