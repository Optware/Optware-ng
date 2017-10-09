###########################################################
#
# mesalib
#
###########################################################

# You must replace "mesalib" and "MESALIB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MESALIB_VERSION, MESALIB_SITE and MESALIB_SOURCE define
# the upstream location of the source code for the package.
# MESALIB_DIR is the directory which is created when the source
# archive is unpacked.
# MESALIB_UNZIP is the command used to unzip the source.
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
MESALIB_SITE=ftp://ftp.freedesktop.org/pub/mesa/$(MESALIB_VERSION)
MESALIB_VERSION=11.1.2
MESALIB_SOURCE=mesa-$(MESALIB_VERSION).tar.xz
MESALIB_DIR=mesa-$(MESALIB_VERSION)
MESALIB_UNZIP=xzcat
MESALIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MESALIB_DESCRIPTION=OpenGL compatible 3D graphics library.
MESALIB_SECTION=lib
MESALIB_PRIORITY=optional
MESALIB_DEPENDS=x11, xext, xcb, xdamage, xshmfence, libdrm, libudev
ifeq (wayland, $(filter wayland, $(PACKAGES)))
MESALIB_DEPENDS+=, wayland
endif
MESALIB_SUGGESTS=
MESALIB_CONFLICTS=

#
# MESALIB_IPK_VERSION should be incremented when the ipk changes.
#
MESALIB_IPK_VERSION=2

#
# MESALIB_CONFFILES should be a list of user-editable files
#MESALIB_CONFFILES=$(TARGET_PREFIX)/etc/mesalib.conf $(TARGET_PREFIX)/etc/init.d/SXXmesalib

#
# MESALIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MESALIB_PATCHES=$(MESALIB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MESALIB_CPPFLAGS=
MESALIB_LDFLAGS=

ifeq (wayland, $(filter wayland, $(PACKAGES)))
MESALIB_PLATFORMS=x11,wayland
else
MESALIB_PLATFORMS=x11
endif

#
# MESALIB_BUILD_DIR is the directory in which the build is done.
# MESALIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MESALIB_IPK_DIR is the directory in which the ipk is built.
# MESALIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MESALIB_BUILD_DIR=$(BUILD_DIR)/mesalib
MESALIB_SOURCE_DIR=$(SOURCE_DIR)/mesalib
MESALIB_IPK_DIR=$(BUILD_DIR)/mesalib-$(MESALIB_VERSION)-ipk
MESALIB_IPK=$(BUILD_DIR)/mesalib_$(MESALIB_VERSION)-$(MESALIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mesalib-source mesalib-unpack mesalib mesalib-stage mesalib-ipk mesalib-clean mesalib-dirclean mesalib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MESALIB_SOURCE):
	$(WGET) -P $(@D) $(MESALIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mesalib-source: $(DL_DIR)/$(MESALIB_SOURCE) $(MESALIB_PATCHES)

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
$(MESALIB_BUILD_DIR)/.configured: $(DL_DIR)/$(MESALIB_SOURCE) $(MESALIB_PATCHES) make/mesalib.mk
	$(MAKE) x11-stage xext-stage xcb-stage xdamage-stage xshmfence-stage libdrm-stage \
		udev-stage glproto-stage presentproto-stage dri2proto-stage dri3proto-stage
ifeq (wayland, $(filter wayland, $(PACKAGES)))
	$(MAKE) wayland-stage wayland-host-stage
endif
	rm -rf $(BUILD_DIR)/$(MESALIB_DIR) $(@D)
	$(MESALIB_UNZIP) $(DL_DIR)/$(MESALIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MESALIB_PATCHES)" ; \
		then cat $(MESALIB_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MESALIB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MESALIB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MESALIB_DIR) $(@D) ; \
	fi
ifeq (wayland, $(filter wayland, $(PACKAGES)))
	sed -i -e 's/\([^=]\)wayland_scanner/\1wayland-scanner/' $(@D)/configure.ac
	$(AUTORECONF1.14) -vif $(@D)
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I$(@D)/include $(STAGING_CPPFLAGS) $(MESALIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MESALIB_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--enable-texture-float \
		--enable-gles1 \
		--enable-gles2 \
		--enable-osmesa \
		--enable-xa \
		--disable-gbm \
		--enable-glx-tls \
		--with-egl-platforms="$(MESALIB_PLATFORMS)" \
		--enable-dri \
		--enable-dri3 \
		--with-gallium-drivers=no \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mesalib-unpack: $(MESALIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MESALIB_BUILD_DIR)/.built: $(MESALIB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) WAYLAND_SCANNER=$(HOST_STAGING_PREFIX)/bin/wayland-scanner
	touch $@

#
# This is the build convenience target.
#
mesalib: $(MESALIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MESALIB_BUILD_DIR)/.staged: $(MESALIB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libEGL.la \
		libglapi.la libGLESv1_CM.la libGLESv2.la \
		libGL.la ibOSMesa.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' \
		$(addprefix $(STAGING_LIB_DIR)/pkgconfig/, \
		dri.pc egl.pc gl.pc glesv1_cm.pc glesv2.pc \
		osmesa.pc)
ifeq (wayland, $(filter wayland, $(PACKAGES)))
	rm -f $(STAGING_LIB_DIR)/libwayland-egl.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/wayland-egl.pc
endif
	touch $@

mesalib-stage: $(MESALIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mesalib
#
$(MESALIB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mesalib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MESALIB_PRIORITY)" >>$@
	@echo "Section: $(MESALIB_SECTION)" >>$@
	@echo "Version: $(MESALIB_VERSION)-$(MESALIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MESALIB_MAINTAINER)" >>$@
	@echo "Source: $(MESALIB_SITE)/$(MESALIB_SOURCE)" >>$@
	@echo "Description: $(MESALIB_DESCRIPTION)" >>$@
	@echo "Depends: $(MESALIB_DEPENDS)" >>$@
	@echo "Suggests: $(MESALIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(MESALIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/mesalib/...
# Documentation files should be installed in $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/doc/mesalib/...
# Daemon startup scripts should be installed in $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mesalib
#
# You may need to patch your application to make it use these locations.
#
$(MESALIB_IPK): $(MESALIB_BUILD_DIR)/.built
	rm -rf $(MESALIB_IPK_DIR) $(BUILD_DIR)/mesalib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MESALIB_BUILD_DIR) DESTDIR=$(MESALIB_IPK_DIR) install-strip
	rm -f $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MESALIB_SOURCE_DIR)/mesalib.conf $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/mesalib.conf
#	$(INSTALL) -d $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MESALIB_SOURCE_DIR)/rc.mesalib $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmesalib
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MESALIB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmesalib
	$(MAKE) $(MESALIB_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MESALIB_SOURCE_DIR)/postinst $(MESALIB_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MESALIB_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MESALIB_SOURCE_DIR)/prerm $(MESALIB_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MESALIB_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MESALIB_IPK_DIR)/CONTROL/postinst $(MESALIB_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MESALIB_CONFFILES) | sed -e 's/ /\n/g' > $(MESALIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MESALIB_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MESALIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mesalib-ipk: $(MESALIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mesalib-clean:
	rm -f $(MESALIB_BUILD_DIR)/.built
	-$(MAKE) -C $(MESALIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mesalib-dirclean:
	rm -rf $(BUILD_DIR)/$(MESALIB_DIR) $(MESALIB_BUILD_DIR) $(MESALIB_IPK_DIR) $(MESALIB_IPK)
#
#
# Some sanity check for the package.
#
mesalib-check: $(MESALIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
