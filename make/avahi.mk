###########################################################
#
# avahi
#
###########################################################
#
# AVAHI_VERSION, AVAHI_SITE and AVAHI_SOURCE define
# the upstream location of the source code for the package.
# AVAHI_DIR is the directory which is created when the source
# archive is unpacked.
# AVAHI_UNZIP is the command used to unzip the source.
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
AVAHI_SITE=https://github.com/lathiat/avahi/releases/download/v$(AVAHI_VERSION)
AVAHI_VERSION=0.7
AVAHI_SOURCE=avahi-$(AVAHI_VERSION).tar.gz
AVAHI_DIR=avahi-$(AVAHI_VERSION)
AVAHI_UNZIP=zcat
AVAHI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AVAHI_DESCRIPTION=A system for multicast DNS service discovery, an implementation of Zeroconf.
LIBAVAHI_COMMON_DESCRIPTION=Avahi common library
LIBAVAHI_CLIENT_DESCRIPTION=Avahi client library
LIBAVAHI_CORE_DESCRIPTION=Avahi core library
LIBAVAHI_GLIB_DESCRIPTION=Avahi glib library
LIBAVAHI_GOBJECT_DESCRIPTION=Avahi gobject library
LIBAVAHI_COMPAT_LIBDNS_SD_DESCRIPTION=Avahi compat libdns_sd library
AVAHI_SECTION=net
LIBAVAHI_COMMON_SECTION=libs
LIBAVAHI_CLIENT_SECTION=libs
LIBAVAHI_CORE_SECTION=libs
LIBAVAHI_GLIB_SECTION=libs
LIBAVAHI_GOBJECT_SECTION=libs
AVAHI_PRIORITY=optional
LIBAVAHI_COMMON_PRIORITY=optional
LIBAVAHI_CLIENT_PRIORITY=optional
LIBAVAHI_CORE_PRIORITY=optional
LIBAVAHI_GLIB_PRIORITY=optional
LIBAVAHI_GOBJECT_PRIORITY=optional
AVAHI_DEPENDS=libavahi-common, libavahi-client, libavahi-core, libavahi-glib, libavahi-gobject, libcap, expat, libdaemon, dbus, gdbm
ifeq (uclibc,$(LIBC_STYLE))
LIBAVAHI_COMMON_DEPENDS=libintl
else
LIBAVAHI_COMMON_DEPENDS=
endif
LIBAVAHI_CLIENT_DEPENDS=libavahi-common, libdbus
LIBAVAHI_CORE_DEPENDS=libavahi-common
LIBAVAHI_GLIB_DEPENDS=libavahi-common, glib
LIBAVAHI_GOBJECT_DEPENDS=libavahi-common, libavahi-client, libavahi-glib
LIBAVAHI_COMPAT_LIBDNS_SD_DEPENDS=libavahi-client, libdbus, libavahi-common
AVAHI_SUGGESTS=
AVAHI_CONFLICTS=

#
# AVAHI_IPK_VERSION should be incremented when the ipk changes.
#
AVAHI_IPK_VERSION=4

#
# AVAHI_CONFFILES should be a list of user-editable files
AVAHI_CONFFILES=\
$(TARGET_PREFIX)/etc/avahi/avahi-autoipd.action \
$(TARGET_PREFIX)/etc/avahi/avahi-daemon.conf \
$(TARGET_PREFIX)/etc/avahi/avahi-dnsconfd.action \
$(TARGET_PREFIX)/etc/avahi/hosts \
$(TARGET_PREFIX)/etc/avahi/services/sftp-ssh.service \
$(TARGET_PREFIX)/etc/avahi/services/ssh.service \
$(TARGET_PREFIX)/etc/dbus-1/system.d/avahi-dbus.conf \
$(TARGET_PREFIX)/etc/init.d/S68avahi-daemon

#
# AVAHI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
AVAHI_PATCHES=\
$(AVAHI_SOURCE_DIR)/avahi-core_socket.h.patch \
$(AVAHI_SOURCE_DIR)/configure.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AVAHI_CPPFLAGS=
AVAHI_LDFLAGS=
ifeq (uclibc,$(LIBC_STYLE))
AVAHI_LDFLAGS+=-lintl
endif

#
# AVAHI_BUILD_DIR is the directory in which the build is done.
# AVAHI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AVAHI_IPK_DIR is the directory in which the ipk is built.
# AVAHI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AVAHI_BUILD_DIR=$(BUILD_DIR)/avahi
AVAHI_SOURCE_DIR=$(SOURCE_DIR)/avahi

AVAHI_IPK_DIR=$(BUILD_DIR)/avahi-$(AVAHI_VERSION)-ipk
AVAHI_IPK=$(BUILD_DIR)/avahi_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_COMMON_IPK_DIR=$(BUILD_DIR)/libavahi-common-$(AVAHI_VERSION)-ipk
LIBAVAHI_COMMON_IPK=$(BUILD_DIR)/libavahi-common_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_CLIENT_IPK_DIR=$(BUILD_DIR)/libavahi-client-$(AVAHI_VERSION)-ipk
LIBAVAHI_CLIENT_IPK=$(BUILD_DIR)/libavahi-client_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_CORE_IPK_DIR=$(BUILD_DIR)/libavahi-core-$(AVAHI_VERSION)-ipk
LIBAVAHI_CORE_IPK=$(BUILD_DIR)/libavahi-core_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_GLIB_IPK_DIR=$(BUILD_DIR)/libavahi-glib-$(AVAHI_VERSION)-ipk
LIBAVAHI_GLIB_IPK=$(BUILD_DIR)/libavahi-glib_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_GOBJECT_IPK_DIR=$(BUILD_DIR)/libavahi-gobject-$(AVAHI_VERSION)-ipk
LIBAVAHI_GOBJECT_IPK=$(BUILD_DIR)/libavahi-gobject_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR=$(BUILD_DIR)/libavahi-compat-libdns-sd-$(AVAHI_VERSION)-ipk
LIBAVAHI_COMPAT_LIBDNS_SD_IPK=$(BUILD_DIR)/libavahi-compat-libdns-sd_$(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: avahi-source avahi-unpack avahi avahi-stage avahi-ipk avahi-clean avahi-dirclean avahi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AVAHI_SOURCE):
	$(WGET) -P $(@D) $(AVAHI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
avahi-source: $(DL_DIR)/$(AVAHI_SOURCE) $(AVAHI_PATCHES)

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
$(AVAHI_BUILD_DIR)/.configured: $(DL_DIR)/$(AVAHI_SOURCE) $(AVAHI_PATCHES) make/avahi.mk
	$(MAKE) dbus-stage expat-stage gdbm-stage glib-stage libdaemon-stage libcap-stage gdbm-stage
ifeq (uclibc,$(LIBC_STYLE))
	$(MAKE) gettext-stage
endif
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) glib-host-stage
endif
	rm -rf $(BUILD_DIR)/$(AVAHI_DIR) $(@D)
	$(AVAHI_UNZIP) $(DL_DIR)/$(AVAHI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AVAHI_PATCHES)" ; \
		then cat $(AVAHI_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(AVAHI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AVAHI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AVAHI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AVAHI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AVAHI_LDFLAGS)" \
		DBUS_CFLAGS="-I$(STAGING_INCLUDE_DIR)/dbus-1.0 -I$(STAGING_LIB_DIR)/dbus-1.0/include -Ddbus_connection_disconnect=dbus_connection_close" \
		DBUS_LIBS="-ldbus-1" \
		LIBDAEMON_CFLAGS="" \
		LIBDAEMON_LIBS="-ldaemon" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		\
		--with-avahi-user=nobody \
		--with-avahi-group=nobody \
		--with-avahi-priv-access-group=nobody \
		--enable-libdaemon \
		--with-distro=none \
		--enable-dbus \
		--disable-gtk \
		--disable-gtk3 \
		--disable-mono \
		--disable-python \
		--disable-qt3 \
		--disable-qt4 \
		--disable-stack-protector \
		\
		--disable-nls \
		--disable-static \
		--disable-introspection \
		--enable-compat-libdns_sd \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

avahi-unpack: $(AVAHI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AVAHI_BUILD_DIR)/.built: $(AVAHI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(if $(filter $(HOSTCC), $(TARGET_CC)),,PATH=$$PATH:$(HOST_STAGING_PREFIX)/bin)
	touch $@

#
# This is the build convenience target.
#
avahi: $(AVAHI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AVAHI_BUILD_DIR)/.staged: $(AVAHI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libavahi*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/avahi-*.pc
	touch $@

avahi-stage: $(AVAHI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/avahi
#
$(AVAHI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: avahi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AVAHI_PRIORITY)" >>$@
	@echo "Section: $(AVAHI_SECTION)" >>$@
	@echo "Version: $(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AVAHI_MAINTAINER)" >>$@
	@echo "Source: $(AVAHI_SITE)/$(AVAHI_SOURCE)" >>$@
	@echo "Description: $(AVAHI_DESCRIPTION)" >>$@
	@echo "Depends: $(AVAHI_DEPENDS)" >>$@
	@echo "Suggests: $(AVAHI_SUGGESTS)" >>$@
	@echo "Conflicts: $(AVAHI_CONFLICTS)" >>$@

$(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libavahi-compat-libdns-sd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AVAHI_PRIORITY)" >>$@
	@echo "Section: libs" >>$@
	@echo "Version: $(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AVAHI_MAINTAINER)" >>$@
	@echo "Source: $(AVAHI_SITE)/$(AVAHI_SOURCE)" >>$@
	@echo "Description: $(LIBAVAHI_COMPAT_LIBDNS_SD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBAVAHI_COMPAT_LIBDNS_SD_DEPENDS)" >>$@
	@echo "Suggests: $(LIBAVAHI_COMPAT_LIBDNS_SD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBAVAHI_COMPAT_LIBDNS_SD_CONFLICTS)" >>$@

$(BUILD_DIR)/libavahi-%-$(AVAHI_VERSION)-ipk/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libavahi-$*" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AVAHI_PRIORITY)" >>$@
	@echo "Section: libs" >>$@
	@echo "Version: $(AVAHI_VERSION)-$(AVAHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AVAHI_MAINTAINER)" >>$@
	@echo "Source: $(AVAHI_SITE)/$(AVAHI_SOURCE)" >>$@
	@echo "Description: $(LIBAVAHI_$(shell echo $* | tr a-z A-Z)_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBAVAHI_$(shell echo $* | tr a-z A-Z)_DEPENDS)" >>$@
	@echo "Suggests: $(LIBAVAHI_$(shell echo $* | tr a-z A-Z)_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBAVAHI_$(shell echo $* | tr a-z A-Z)_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/avahi/...
# Documentation files should be installed in $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/doc/avahi/...
# Daemon startup scripts should be installed in $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??avahi
#
# You may need to patch your application to make it use these locations.
#
$(AVAHI_IPK) $(LIBAVAHI_COMMON_IPK) $(LIBAVAHI_CLIENT_IPK) $(LIBAVAHI_CORE_IPK) \
$(LIBAVAHI_GLIB_IPK) $(LIBAVAHI_GOBJECT_IPK) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK): $(AVAHI_BUILD_DIR)/.built
	rm -rf  $(AVAHI_IPK_DIR) $(BUILD_DIR)/avahi_*_$(TARGET_ARCH).ipk \
		$(LIBAVAHI_COMMON_IPK_DIR) $(BUILD_DIR)/libavahi-common_*_$(TARGET_ARCH).ipk \
		$(LIBAVAHI_CLIENT_IPK_DIR) $(BUILD_DIR)/libavahi-client_*_$(TARGET_ARCH).ipk \
		$(LIBAVAHI_CORE_IPK_DIR) $(BUILD_DIR)/libavahi-core_*_$(TARGET_ARCH).ipk \
		$(LIBAVAHI_GLIB_IPK_DIR) $(BUILD_DIR)/libavahi-glib_*_$(TARGET_ARCH).ipk \
		$(LIBAVAHI_GOBJECT_IPK_DIR) $(BUILD_DIR)/libavahi-gobject_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AVAHI_BUILD_DIR) DESTDIR=$(AVAHI_IPK_DIR) install-strip
	$(INSTALL) -d $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/var/run/avahi-daemon
	rm -rf $(AVAHI_IPK_DIR)/run
	sed -i -e '/rlimit-nproc/s/^/#/' $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/avahi/avahi-daemon.conf
	rm -f $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	for lib in common client core glib gobject; do \
		$(INSTALL) -d $(BUILD_DIR)/libavahi-$$lib-$(AVAHI_VERSION)-ipk$(TARGET_PREFIX)/lib; \
		mv -f $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/lib/libavahi-$${lib}.so* $(BUILD_DIR)/libavahi-$$lib-$(AVAHI_VERSION)-ipk$(TARGET_PREFIX)/lib; \
		$(MAKE) $(BUILD_DIR)/libavahi-$$lib-$(AVAHI_VERSION)-ipk/CONTROL/control; \
		(cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILD_DIR)/libavahi-$$lib-$(AVAHI_VERSION)-ipk); \
		$(WHAT_TO_DO_WITH_IPK_DIR) $(BUILD_DIR)/libavahi-$$lib-$(AVAHI_VERSION)-ipk; \
	done
	$(INSTALL) -d $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/lib/libdns_sd.so* $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR)
#	$(INSTALL) -d $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(AVAHI_SOURCE_DIR)/avahi.conf $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/avahi.conf
	$(INSTALL) -d $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(AVAHI_SOURCE_DIR)/rc.avahi-daemon $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S68avahi-daemon
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AVAHI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXavahi
	$(MAKE) $(AVAHI_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(AVAHI_SOURCE_DIR)/postinst $(AVAHI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AVAHI_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(AVAHI_SOURCE_DIR)/prerm $(AVAHI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(AVAHI_IPK_DIR)/CONTROL/prerm
	echo $(AVAHI_CONFFILES) | sed -e 's/ /\n/g' > $(AVAHI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AVAHI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(AVAHI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
avahi-ipk: $(AVAHI_IPK) $(LIBAVAHI_COMMON_IPK) $(LIBAVAHI_CLIENT_IPK) $(LIBAVAHI_CORE_IPK) \
	   $(LIBAVAHI_GLIB_IPK) $(LIBAVAHI_GOBJECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
avahi-clean:
	rm -f $(AVAHI_BUILD_DIR)/.built
	-$(MAKE) -C $(AVAHI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
avahi-dirclean:
	rm -rf  $(BUILD_DIR)/$(AVAHI_DIR) $(AVAHI_BUILD_DIR) \
		$(AVAHI_IPK_DIR) $(AVAHI_IPK) \
		$(LIBAVAHI_COMMON_IPK_DIR) $(LIBAVAHI_COMMON_IPK) \
		$(LIBAVAHI_CLIENT_IPK_DIR) $(LIBAVAHI_CLIENT_IPK) \
		$(LIBAVAHI_CORE_IPK_DIR) $(LIBAVAHI_CORE_IPK) \
		$(LIBAVAHI_GLIB_IPK_DIR) $(LIBAVAHI_GLIB_IPK) \
		$(LIBAVAHI_GOBJECT_IPK_DIR) $(LIBAVAHI_GOBJECT_IPK) \
		$(LIBAVAHI_COMPAT_LIBDNS_SD_IPK_DIR) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK)
#
#
# Some sanity check for the package.
#
avahi-check: $(AVAHI_IPK) $(LIBAVAHI_COMMON_IPK) $(LIBAVAHI_CLIENT_IPK) $(LIBAVAHI_CORE_IPK) \
	     $(LIBAVAHI_GLIB_IPK) $(LIBAVAHI_GOBJECT_IPK) $(LIBAVAHI_COMPAT_LIBDNS_SD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
