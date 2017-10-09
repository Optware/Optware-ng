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
DBUS_VERSION=1.11.4
DBUS_IPK_VERSION=6
DBUS_SOURCE=dbus-$(DBUS_VERSION).tar.gz
DBUS_DIR=dbus-$(DBUS_VERSION)
DBUS_UNZIP=zcat
DBUS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DBUS_DESCRIPTION=D-Bus is a message bus system, a simple way for applications to talk to one another.
DBUS_LAUNCH_DESCRIPTION=dbus-launch command is used to start a session bus instance of dbus-daemon from a shell script. Built with X11 support
LIBDBUS_DESCRIPTION=D-Bus client library
DBUS_SECTION=misc
DBUS_LAUNCH_SECTION=misc
LIBDBUS_SECTION=libs
DBUS_PRIORITY=optional
DBUS_LAUNCH_PRIORITY=optional
LIBDBUS_PRIORITY=optional
DBUS_DEPENDS=libdbus, expat, start-stop-daemon
LIBDBUS_DEPENDS=
DBUS_LAUNCH_DEPENDS=dbus, x11, sm
DBUS_SUGGESTS=
DBUS_CONFLICTS=


#
# DBUS_CONFFILES should be a list of user-editable files
DBUS_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S20dbus $(TARGET_PREFIX)/etc/default/dbus

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

DBUS_CROSS_CONFIG_ENVS=ac_cv_have_abstract_sockets=yes

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

LIBDBUS_IPK_DIR=$(BUILD_DIR)/libdbus-$(DBUS_VERSION)-ipk
LIBDBUS_IPK=$(BUILD_DIR)/libdbus_$(DBUS_VERSION)-$(DBUS_IPK_VERSION)_$(TARGET_ARCH).ipk

DBUS_LAUNCH_IPK_DIR=$(BUILD_DIR)/dbus-launch-$(DBUS_VERSION)-ipk
DBUS_LAUNCH_IPK=$(BUILD_DIR)/dbus-launch_$(DBUS_VERSION)-$(DBUS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dbus-source dbus-unpack dbus dbus-stage dbus-ipk dbus-clean dbus-dirclean dbus-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DBUS_SOURCE):
	$(WGET) -P $(@D) $(DBUS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
	$(MAKE) expat-stage x11-stage sm-stage
	rm -rf $(BUILD_DIR)/$(DBUS_DIR) $(DBUS_BUILD_DIR)
	$(DBUS_UNZIP) $(DL_DIR)/$(DBUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DBUS_PATCHES)" ; \
		then cat $(DBUS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DBUS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DBUS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DBUS_DIR) $(@D) ; \
	fi
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
		sed -i -e '/CFLAGS=.* -Wno-pointer-sign/s/ -Wno-pointer-sign//' $(@D)/configure; \
	fi
	sed -i -e 's|/etc/machine-id|$(TARGET_PREFIX)/etc/machine-id|' $(@D)/dbus/dbus-sysdeps-unix.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DBUS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DBUS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		$(DBUS_CROSS_CONFIG_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-abstract-sockets \
		--with-xml=expat \
		--with-x \
		--disable-doxygen-docs \
		--disable-xml-docs \
		--disable-nls \
		--disable-static \
		--with-dbus-user=nobody \
		--with-test-user=messagebus \
	)
ifdef DBUS_NO_DAEMON_LDFLAGS
	sed -i -e '/^dbus_daemon_LDFLAGS/s|^|#|' $(@D)/bus/Makefile
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

dbus-unpack: $(DBUS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DBUS_BUILD_DIR)/.built: $(DBUS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
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
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) transform='' install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/dbus-*.pc
	rm -f $(STAGING_LIB_DIR)/libdbus-1.la
	touch $@

dbus-stage: $(DBUS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dbus
#
$(DBUS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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

$(LIBDBUS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libdbus" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDBUS_PRIORITY)" >>$@
	@echo "Section: $(LIBDBUS_SECTION)" >>$@
	@echo "Version: $(DBUS_VERSION)-$(DBUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_SITE)/$(DBUS_SOURCE)" >>$@
	@echo "Description: $(LIBDBUS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDBUS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDBUS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDBUS_CONFLICTS)" >>$@

$(DBUS_LAUNCH_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dbus-launch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DBUS_LAUNCH_PRIORITY)" >>$@
	@echo "Section: $(DBUS_LAUNCH_SECTION)" >>$@
	@echo "Version: $(DBUS_VERSION)-$(DBUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DBUS_MAINTAINER)" >>$@
	@echo "Source: $(DBUS_SITE)/$(DBUS_SOURCE)" >>$@
	@echo "Description: $(DBUS_LAUNCH_DESCRIPTION)" >>$@
	@echo "Depends: $(DBUS_LAUNCH_DEPENDS)" >>$@
	@echo "Suggests: $(DBUS_LAUNCH_SUGGESTS)" >>$@
	@echo "Conflicts: $(DBUS_LAUNCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DBUS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DBUS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DBUS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/dbus/...
# Documentation files should be installed in $(DBUS_IPK_DIR)$(TARGET_PREFIX)/doc/dbus/...
# Daemon startup scripts should be installed in $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??dbus
#
# You may need to patch your application to make it use these locations.
#
$(DBUS_IPK) $(LIBDBUS_IPK) $(DBUS_LAUNCH_IPK): $(DBUS_BUILD_DIR)/.built
	rm -rf  $(DBUS_IPK_DIR) $(BUILD_DIR)/dbus_*_$(TARGET_ARCH).ipk \
		$(LIBDBUS_IPK_DIR) $(BUILD_DIR)/libdbus_*_$(TARGET_ARCH).ipk \
		$(DBUS_LAUNCH_IPK_DIR) $(BUILD_DIR)/dbus-launch_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DBUS_BUILD_DIR) DESTDIR=$(DBUS_IPK_DIR) transform='' install
	rm -f $(DBUS_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(STRIP_COMMAND) \
		$(DBUS_IPK_DIR)$(TARGET_PREFIX)/bin/* \
		$(DBUS_IPK_DIR)$(TARGET_PREFIX)/libexec/dbus-daemon-launch-helper \
		$(DBUS_IPK_DIR)$(TARGET_PREFIX)/lib/libdbus-*.so.*.*.*
#	$(INSTALL) -d $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(DBUS_SOURCE_DIR)/dbus.conf $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/dbus.conf
	$(INSTALL) -d $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/default
	$(INSTALL) -m 644 $(DBUS_SOURCE_DIR)/dbus.default $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/default/dbus
	$(INSTALL) -d $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DBUS_SOURCE_DIR)/dbus.init $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S20dbus
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S20dbus
	$(INSTALL) -d $(LIBDBUS_IPK_DIR)$(TARGET_PREFIX)
	mv -f $(DBUS_IPK_DIR)$(TARGET_PREFIX)/{lib,include} $(LIBDBUS_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(LIBDBUS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDBUS_IPK_DIR)
	$(INSTALL) -d $(DBUS_LAUNCH_IPK_DIR)$(TARGET_PREFIX)/bin
	mv -f $(DBUS_IPK_DIR)$(TARGET_PREFIX)/bin/dbus-launch $(DBUS_LAUNCH_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) $(DBUS_LAUNCH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DBUS_LAUNCH_IPK_DIR)
	$(MAKE) $(DBUS_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(DBUS_SOURCE_DIR)/postinst $(DBUS_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(DBUS_SOURCE_DIR)/prerm $(DBUS_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DBUS_IPK_DIR)/CONTROL/prerm
	echo $(DBUS_CONFFILES) | sed -e 's/ /\n/g' > $(DBUS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DBUS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dbus-ipk: $(DBUS_IPK) $(LIBDBUS_IPK) $(DBUS_LAUNCH_IPK)

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
	rm -rf  $(BUILD_DIR)/$(DBUS_DIR) $(DBUS_BUILD_DIR) \
		$(DBUS_IPK_DIR) $(DBUS_IPK) \
		$(LIBDBUS_IPK_DIR) $(LIBDBUS_IPK)
#
#
# Some sanity check for the package.
#
dbus-check: $(DBUS_IPK) $(LIBDBUS_IPK) $(DBUS_LAUNCH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
