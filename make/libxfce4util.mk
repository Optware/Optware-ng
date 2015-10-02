###########################################################
#
# libxfce4util
#
###########################################################

# You must replace "libxfce4util" and "LIBXFCE4UTIL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBXFCE4UTIL_VERSION, LIBXFCE4UTIL_SITE and LIBXFCE4UTIL_SOURCE define
# the upstream location of the source code for the package.
# LIBXFCE4UTIL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBXFCE4UTIL_UNZIP is the command used to unzip the source.
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
LIBXFCE4UTIL_SITE=http://archive.xfce.org/src/xfce/libxfce4util/4.12
LIBXFCE4UTIL_VERSION=4.12.1
LIBXFCE4UTIL_SOURCE=libxfce4util-$(LIBXFCE4UTIL_VERSION).tar.bz2
LIBXFCE4UTIL_DIR=libxfce4util-$(LIBXFCE4UTIL_VERSION)
LIBXFCE4UTIL_UNZIP=bzcat
LIBXFCE4UTIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBXFCE4UTIL_DESCRIPTION=Basic utility library for the Xfce desktop environment.
LIBXFCE4UTIL_SECTION=lib
LIBXFCE4UTIL_PRIORITY=optional
LIBXFCE4UTIL_DEPENDS=glib
LIBXFCE4UTIL_SUGGESTS=
LIBXFCE4UTIL_CONFLICTS=

#
# LIBXFCE4UTIL_IPK_VERSION should be incremented when the ipk changes.
#
LIBXFCE4UTIL_IPK_VERSION=1

#
# LIBXFCE4UTIL_CONFFILES should be a list of user-editable files
#LIBXFCE4UTIL_CONFFILES=/opt/etc/libxfce4util.conf /opt/etc/init.d/SXXlibxfce4util

#
# LIBXFCE4UTIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBXFCE4UTIL_PATCHES=$(LIBXFCE4UTIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBXFCE4UTIL_CPPFLAGS=
LIBXFCE4UTIL_LDFLAGS=

#
# LIBXFCE4UTIL_BUILD_DIR is the directory in which the build is done.
# LIBXFCE4UTIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBXFCE4UTIL_IPK_DIR is the directory in which the ipk is built.
# LIBXFCE4UTIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBXFCE4UTIL_BUILD_DIR=$(BUILD_DIR)/libxfce4util
LIBXFCE4UTIL_SOURCE_DIR=$(SOURCE_DIR)/libxfce4util
LIBXFCE4UTIL_IPK_DIR=$(BUILD_DIR)/libxfce4util-$(LIBXFCE4UTIL_VERSION)-ipk
LIBXFCE4UTIL_IPK=$(BUILD_DIR)/libxfce4util_$(LIBXFCE4UTIL_VERSION)-$(LIBXFCE4UTIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libxfce4util-source libxfce4util-unpack libxfce4util libxfce4util-stage libxfce4util-ipk libxfce4util-clean libxfce4util-dirclean libxfce4util-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBXFCE4UTIL_SOURCE):
	$(WGET) -P $(@D) $(LIBXFCE4UTIL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libxfce4util-source: $(DL_DIR)/$(LIBXFCE4UTIL_SOURCE) $(LIBXFCE4UTIL_PATCHES)

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
$(LIBXFCE4UTIL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBXFCE4UTIL_SOURCE) $(LIBXFCE4UTIL_PATCHES) make/libxfce4util.mk
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(LIBXFCE4UTIL_DIR) $(@D)
	$(LIBXFCE4UTIL_UNZIP) $(DL_DIR)/$(LIBXFCE4UTIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBXFCE4UTIL_PATCHES)" ; \
		then cat $(LIBXFCE4UTIL_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBXFCE4UTIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBXFCE4UTIL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBXFCE4UTIL_DIR) $(@D) ; \
	fi
	sed -i -e 's:/usr/share\|/usr/local/share:/opt/share:g' $(@D)/libxfce4util/xfce-resource.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBXFCE4UTIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBXFCE4UTIL_LDFLAGS)" \
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

libxfce4util-unpack: $(LIBXFCE4UTIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBXFCE4UTIL_BUILD_DIR)/.built: $(LIBXFCE4UTIL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libxfce4util: $(LIBXFCE4UTIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBXFCE4UTIL_BUILD_DIR)/.staged: $(LIBXFCE4UTIL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libxfce4util.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libxfce4util-1.0.pc
	touch $@

libxfce4util-stage: $(LIBXFCE4UTIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libxfce4util
#
$(LIBXFCE4UTIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libxfce4util" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBXFCE4UTIL_PRIORITY)" >>$@
	@echo "Section: $(LIBXFCE4UTIL_SECTION)" >>$@
	@echo "Version: $(LIBXFCE4UTIL_VERSION)-$(LIBXFCE4UTIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBXFCE4UTIL_MAINTAINER)" >>$@
	@echo "Source: $(LIBXFCE4UTIL_SITE)/$(LIBXFCE4UTIL_SOURCE)" >>$@
	@echo "Description: $(LIBXFCE4UTIL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBXFCE4UTIL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBXFCE4UTIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBXFCE4UTIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBXFCE4UTIL_IPK_DIR)/opt/sbin or $(LIBXFCE4UTIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBXFCE4UTIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/libxfce4util/...
# Documentation files should be installed in $(LIBXFCE4UTIL_IPK_DIR)/opt/doc/libxfce4util/...
# Daemon startup scripts should be installed in $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/init.d/S??libxfce4util
#
# You may need to patch your application to make it use these locations.
#
$(LIBXFCE4UTIL_IPK): $(LIBXFCE4UTIL_BUILD_DIR)/.built
	rm -rf $(LIBXFCE4UTIL_IPK_DIR) $(BUILD_DIR)/libxfce4util_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBXFCE4UTIL_BUILD_DIR) DESTDIR=$(LIBXFCE4UTIL_IPK_DIR) install-strip
	rm -f $(LIBXFCE4UTIL_IPK_DIR)/opt/lib/*.la
#	$(INSTALL) -d $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(LIBXFCE4UTIL_SOURCE_DIR)/libxfce4util.conf $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/libxfce4util.conf
#	$(INSTALL) -d $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(LIBXFCE4UTIL_SOURCE_DIR)/rc.libxfce4util $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/init.d/SXXlibxfce4util
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UTIL_IPK_DIR)/opt/etc/init.d/SXXlibxfce4util
	$(MAKE) $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBXFCE4UTIL_SOURCE_DIR)/postinst $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBXFCE4UTIL_SOURCE_DIR)/prerm $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBXFCE4UTIL_IPK_DIR)/CONTROL/postinst $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBXFCE4UTIL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBXFCE4UTIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBXFCE4UTIL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBXFCE4UTIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libxfce4util-ipk: $(LIBXFCE4UTIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libxfce4util-clean:
	rm -f $(LIBXFCE4UTIL_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBXFCE4UTIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libxfce4util-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBXFCE4UTIL_DIR) $(LIBXFCE4UTIL_BUILD_DIR) $(LIBXFCE4UTIL_IPK_DIR) $(LIBXFCE4UTIL_IPK)
#
#
# Some sanity check for the package.
#
libxfce4util-check: $(LIBXFCE4UTIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
