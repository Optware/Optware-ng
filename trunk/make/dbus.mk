###########################################################
#
# dbus
#
###########################################################
#
# DBUS_VERSION, DBUS_SITE and DBUS_SOURCE define
# the upstream location of the source code for the package.
# DBUS_DIR is the directory which is created when the source
# archive is unpacked.
# DBUS_UNZIP is the command used to unzip the source.
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
DBUS_SITE=http://dbus.freedesktop.org/releases/dbus
DBUS_VERSION=1.0.2
DBUS_SOURCE=dbus-$(DBUS_VERSION).tar.gz
DBUS_DIR=dbus-$(DBUS_VERSION)
DBUS_UNZIP=zcat
DBUS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DBUS_DESCRIPTION=D-Bus is a message bus system, a simple way for applications to talk to one another.
DBUS_SECTION=misc
DBUS_PRIORITY=optional
DBUS_DEPENDS=
DBUS_SUGGESTS=
DBUS_CONFLICTS=

#
# DBUS_IPK_VERSION should be incremented when the ipk changes.
#
DBUS_IPK_VERSION=1

#
# DBUS_CONFFILES should be a list of user-editable files
#DBUS_CONFFILES=/opt/etc/dbus.conf /opt/etc/init.d/SXXdbus

#
# DBUS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DBUS_PATCHES=$(DBUS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DBUS_CPPFLAGS=
DBUS_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
DBUS_CROSS_CONFIG_ENVS=ac_cv_have_abstract_sockets=yes
endif

#
# DBUS_BUILD_DIR is the directory in which the build is done.
# DBUS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DBUS_IPK_DIR is the directory in which the ipk is built.
# DBUS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DBUS_BUILD_DIR=$(BUILD_DIR)/dbus
DBUS_SOURCE_DIR=$(SOURCE_DIR)/dbus
DBUS_IPK_DIR=$(BUILD_DIR)/dbus-$(DBUS_VERSION)-ipk
DBUS_IPK=$(BUILD_DIR)/dbus_$(DBUS_VERSION)-$(DBUS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dbus-source dbus-unpack dbus dbus-stage dbus-ipk dbus-clean dbus-dirclean dbus-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DBUS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DBUS_SITE)/$(DBUS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DBUS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dbus-source: $(DL_DIR)/$(DBUS_SOURCE) $(DBUS_PATCHES)

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
$(DBUS_BUILD_DIR)/.configured: $(DL_DIR)/$(DBUS_SOURCE) $(DBUS_PATCHES) make/dbus.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DBUS_DIR) $(DBUS_BUILD_DIR)
	$(DBUS_UNZIP) $(DL_DIR)/$(DBUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PATCHES)" ; \
		then cat $(DBUS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DBUS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DBUS_DIR)" != "$(DBUS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DBUS_DIR) $(DBUS_BUILD_DIR) ; \
	fi
	(cd $(DBUS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_LDFLAGS)" \
		$(DBUS_CROSS_CONFIG_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-abstract-sockets \
		--without-x \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(DBUS_BUILD_DIR)/libtool
	touch $@

dbus-unpack: $(DBUS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DBUS_BUILD_DIR)/.built: $(DBUS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DBUS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
dbus: $(DBUS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DBUS_BUILD_DIR)/.staged: $(DBUS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DBUS_BUILD_DIR) DESTDIR=$(STAGING_DIR) transform='' install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/dbus-*.pc
	touch $@

dbus-stage: $(DBUS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dbus
#
$(DBUS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dbus" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_PRIORITY)" >>$@
	@echo "Section: $(DBUS_SECTION)" >>$@
	@echo "Version: $(DBUS_VERSION)-$(DBUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_SITE)/$(DBUS_SOURCE)" >>$@
	@echo "Description: $(DBUS_DESCRIPTION)" >>$@
	@echo "Depends: $(DBUS_DEPENDS)" >>$@
	@echo "Suggests: $(DBUS_SUGGESTS)" >>$@
	@echo "Conflicts: $(DBUS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DBUS_IPK_DIR)/opt/sbin or $(DBUS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DBUS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DBUS_IPK_DIR)/opt/etc/dbus/...
# Documentation files should be installed in $(DBUS_IPK_DIR)/opt/doc/dbus/...
# Daemon startup scripts should be installed in $(DBUS_IPK_DIR)/opt/etc/init.d/S??dbus
#
# You may need to patch your application to make it use these locations.
#
$(DBUS_IPK): $(DBUS_BUILD_DIR)/.built
	rm -rf $(DBUS_IPK_DIR) $(BUILD_DIR)/dbus_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_BUILD_DIR) DESTDIR=$(DBUS_IPK_DIR) transform='' install
	$(STRIP_COMMAND) $(DBUS_IPK_DIR)/opt/bin/* $(DBUS_IPK_DIR)/opt/lib/libdbus-*.so.*.*.*
#	install -d $(DBUS_IPK_DIR)/opt/etc/
#	install -m 644 $(DBUS_SOURCE_DIR)/dbus.conf $(DBUS_IPK_DIR)/opt/etc/dbus.conf
#	install -d $(DBUS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DBUS_SOURCE_DIR)/rc.dbus $(DBUS_IPK_DIR)/opt/etc/init.d/SXXdbus
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)/opt/etc/init.d/SXXdbus
	$(MAKE) $(DBUS_IPK_DIR)/CONTROL/control
#	install -m 755 $(DBUS_SOURCE_DIR)/postinst $(DBUS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DBUS_SOURCE_DIR)/prerm $(DBUS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)/CONTROL/prerm
	echo $(DBUS_CONFFILES) | sed -e 's/ /\n/g' > $(DBUS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DBUS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dbus-ipk: $(DBUS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dbus-clean:
	rm -f $(DBUS_BUILD_DIR)/.built
	-$(MAKE) -C $(DBUS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dbus-dirclean:
	rm -rf $(BUILD_DIR)/$(DBUS_DIR) $(DBUS_BUILD_DIR) $(DBUS_IPK_DIR) $(DBUS_IPK)
#
#
# Some sanity check for the package.
#
dbus-check: $(DBUS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DBUS_IPK)
