###########################################################
#
# dbus-glib
#
###########################################################
#
# DBUS-GLIB_VERSION, DBUS-GLIB_SITE and DBUS-GLIB_SOURCE define
# the upstream location of the source code for the package.
# DBUS-GLIB_DIR is the directory which is created when the source
# archive is unpacked.
# DBUS-GLIB_UNZIP is the command used to unzip the source.
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
DBUS-GLIB_SITE=http://dbus.freedesktop.org/releases/dbus-glib
DBUS-GLIB_VERSION=0.80
DBUS-GLIB_SOURCE=dbus-glib-$(DBUS-GLIB_VERSION).tar.gz
DBUS-GLIB_DIR=dbus-glib-$(DBUS-GLIB_VERSION)
DBUS-GLIB_UNZIP=zcat
DBUS-GLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DBUS-GLIB_DESCRIPTION=D-Bus Glib bindings
DBUS-GLIB_SECTION=devel
DBUS-GLIB_PRIORITY=optional
DBUS-GLIB_DEPENDS=dbus, glib
DBUS-GLIB_SUGGESTS=
DBUS-GLIB_CONFLICTS=

#
# DBUS-GLIB_IPK_VERSION should be incremented when the ipk changes.
#
DBUS-GLIB_IPK_VERSION=1

#
# DBUS-GLIB_CONFFILES should be a list of user-editable files
#DBUS-GLIB_CONFFILES=

#
# DBUS-GLIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DBUS-GLIB_PATCHES=$(DBUS-GLIB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DBUS-GLIB_CPPFLAGS=
DBUS-GLIB_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
DBUS-GLIB_CROSS_CONFIG_ENVS=ac_cv_func_posix_getpwnam_r=yes ac_cv_have_abstract_sockets=yes
endif

#
# DBUS-GLIB_BUILD_DIR is the directory in which the build is done.
# DBUS-GLIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DBUS-GLIB_IPK_DIR is the directory in which the ipk is built.
# DBUS-GLIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DBUS-GLIB_BUILD_DIR=$(BUILD_DIR)/dbus-glib
DBUS-GLIB_SOURCE_DIR=$(SOURCE_DIR)/dbus-glib
DBUS-GLIB_IPK_DIR=$(BUILD_DIR)/dbus-glib-$(DBUS-GLIB_VERSION)-ipk
DBUS-GLIB_IPK=$(BUILD_DIR)/dbus-glib_$(DBUS-GLIB_VERSION)-$(DBUS-GLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dbus-glib-source dbus-glib-unpack dbus-glib dbus-glib-stage dbus-glib-ipk dbus-glib-clean dbus-glib-dirclean dbus-glib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DBUS-GLIB_SOURCE):
	$(WGET) -P $(@D) $(DBUS-GLIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dbus-glib-source: $(DL_DIR)/$(DBUS-GLIB_SOURCE) $(DBUS-GLIB_PATCHES)

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
$(DBUS-GLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(DBUS-GLIB_SOURCE) $(DBUS-GLIB_PATCHES) make/dbus-glib.mk
	$(MAKE) dbus-stage glib-stage
	rm -rf $(BUILD_DIR)/$(DBUS-GLIB_DIR) $(@D)
	$(DBUS-GLIB_UNZIP) $(DL_DIR)/$(DBUS-GLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS-GLIB_PATCHES)" ; \
		then cat $(DBUS-GLIB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DBUS-GLIB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DBUS-GLIB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DBUS-GLIB_DIR) $(@D) ; \
	fi
	sed -i -e '/^SUBDIRS/s/=.*/= dbus/' $(@D)/Makefile.in
	sed -i -e '/^SUBDIRS/s/=.*/= ./' $(@D)/dbus/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS-GLIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS-GLIB_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(DBUS-GLIB_CROSS_CONFIG_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-abstract-sockets \
		--with-xml=expat \
		--without-x \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

dbus-glib-unpack: $(DBUS-GLIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DBUS-GLIB_BUILD_DIR)/.built: $(DBUS-GLIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dbus-glib: $(DBUS-GLIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DBUS-GLIB_BUILD_DIR)/.staged: $(DBUS-GLIB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) transform='' install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/dbus-glib-*.pc
	rm -f $(STAGING_LIB_DIR)/dbus-glib*.la
	touch $@

dbus-glib-stage: $(DBUS-GLIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dbus-glib
#
$(DBUS-GLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dbus-glib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS-GLIB_PRIORITY)" >>$@
	@echo "Section: $(DBUS-GLIB_SECTION)" >>$@
	@echo "Version: $(DBUS-GLIB_VERSION)-$(DBUS-GLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS-GLIB_MAINTAINER)" >>$@
	@echo "Source: $(DBUS-GLIB_SITE)/$(DBUS-GLIB_SOURCE)" >>$@
	@echo "Description: $(DBUS-GLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(DBUS-GLIB_DEPENDS)" >>$@
	@echo "Suggests: $(DBUS-GLIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(DBUS-GLIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DBUS-GLIB_IPK_DIR)/opt/sbin or $(DBUS-GLIB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DBUS-GLIB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DBUS-GLIB_IPK_DIR)/opt/etc/dbus-glib/...
# Documentation files should be installed in $(DBUS-GLIB_IPK_DIR)/opt/doc/dbus-glib/...
# Daemon startup scripts should be installed in $(DBUS-GLIB_IPK_DIR)/opt/etc/init.d/S??dbus-glib
#
# You may need to patch your application to make it use these locations.
#
$(DBUS-GLIB_IPK): $(DBUS-GLIB_BUILD_DIR)/.built
	rm -rf $(DBUS-GLIB_IPK_DIR) $(BUILD_DIR)/dbus-glib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS-GLIB_BUILD_DIR) DESTDIR=$(DBUS-GLIB_IPK_DIR) transform='' install-strip
#	install -d $(DBUS-GLIB_IPK_DIR)/opt/etc/
#	install -m 644 $(DBUS-GLIB_SOURCE_DIR)/dbus-glib.conf $(DBUS-GLIB_IPK_DIR)/opt/etc/dbus-glib.conf
#	install -d $(DBUS-GLIB_IPK_DIR)/opt/etc/default
#	install -m 644 $(DBUS-GLIB_SOURCE_DIR)/dbus-glib.default $(DBUS-GLIB_IPK_DIR)/opt/etc/default/dbus-glib
#	install -d $(DBUS-GLIB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DBUS-GLIB_SOURCE_DIR)/dbus-glib.init $(DBUS-GLIB_IPK_DIR)/opt/etc/init.d/S20dbus-glib
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS-GLIB_IPK_DIR)/opt/etc/init.d/S20dbus-glib
	$(MAKE) $(DBUS-GLIB_IPK_DIR)/CONTROL/control
#	install -m 755 $(DBUS-GLIB_SOURCE_DIR)/postinst $(DBUS-GLIB_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS-GLIB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DBUS-GLIB_SOURCE_DIR)/prerm $(DBUS-GLIB_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS-GLIB_IPK_DIR)/CONTROL/prerm
	echo $(DBUS-GLIB_CONFFILES) | sed -e 's/ /\n/g' > $(DBUS-GLIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DBUS-GLIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dbus-glib-ipk: $(DBUS-GLIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dbus-glib-clean:
	rm -f $(DBUS-GLIB_BUILD_DIR)/.built
	-$(MAKE) -C $(DBUS-GLIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dbus-glib-dirclean:
	rm -rf $(BUILD_DIR)/$(DBUS-GLIB_DIR) $(DBUS-GLIB_BUILD_DIR) $(DBUS-GLIB_IPK_DIR) $(DBUS-GLIB_IPK)
#
#
# Some sanity check for the package.
#
dbus-glib-check: $(DBUS-GLIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
