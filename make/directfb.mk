###########################################################
#
# directfb
#
###########################################################
#
# DIRECTFB_VERSION, DIRECTFB_SITE and DIRECTFB_SOURCE define
# the upstream location of the source code for the package.
# DIRECTFB_DIR is the directory which is created when the source
# archive is unpacked.
# DIRECTFB_UNZIP is the command used to unzip the source.
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
DIRECTFB_SITE=http://www.directfb.org/downloads/Core
DIRECTFB_SITE2=http://www.directfb.org/downloads/Old
DIRECTFB_VERSION=1.0.0
DIRECTFB_SOURCE=DirectFB-$(DIRECTFB_VERSION).tar.gz
DIRECTFB_DIR=DirectFB-$(DIRECTFB_VERSION)
DIRECTFB_UNZIP=zcat
DIRECTFB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DIRECTFB_DESCRIPTION=DirectFB.
DIRECTFB_SECTION=graphics
DIRECTFB_PRIORITY=optional
DIRECTFB_DEPENDS=
DIRECTFB_SUGGESTS=
DIRECTFB_CONFLICTS=

#
# DIRECTFB_IPK_VERSION should be incremented when the ipk changes.
#
DIRECTFB_IPK_VERSION=1

#
# DIRECTFB_CONFFILES should be a list of user-editable files
#DIRECTFB_CONFFILES=/opt/etc/directfb.conf /opt/etc/init.d/SXXdirectfb

#
# DIRECTFB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DIRECTFB_PATCHES=$(DIRECTFB_SOURCE_DIR)/PAGE_SIZE.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIRECTFB_CPPFLAGS=
DIRECTFB_LDFLAGS=

#
# DIRECTFB_BUILD_DIR is the directory in which the build is done.
# DIRECTFB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIRECTFB_IPK_DIR is the directory in which the ipk is built.
# DIRECTFB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIRECTFB_BUILD_DIR=$(BUILD_DIR)/directfb
DIRECTFB_SOURCE_DIR=$(SOURCE_DIR)/directfb
DIRECTFB_IPK_DIR=$(BUILD_DIR)/directfb-$(DIRECTFB_VERSION)-ipk
DIRECTFB_IPK=$(BUILD_DIR)/directfb_$(DIRECTFB_VERSION)-$(DIRECTFB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: directfb-source directfb-unpack directfb directfb-stage directfb-ipk directfb-clean directfb-dirclean directfb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIRECTFB_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIRECTFB_SITE)/$(DIRECTFB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(DIRECTFB_SITE2)/$(DIRECTFB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DIRECTFB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
directfb-source: $(DL_DIR)/$(DIRECTFB_SOURCE) $(DIRECTFB_PATCHES)

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
$(DIRECTFB_BUILD_DIR)/.configured: $(DL_DIR)/$(DIRECTFB_SOURCE) $(DIRECTFB_PATCHES) make/directfb.mk
	$(MAKE) freetype-stage
	$(MAKE) libjpeg-stage
	$(MAKE) libpng-stage
	$(MAKE) libvncserver-stage
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(DIRECTFB_DIR) $(@D)
	$(DIRECTFB_UNZIP) $(DL_DIR)/$(DIRECTFB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIRECTFB_PATCHES)" ; \
		then cat $(DIRECTFB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DIRECTFB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DIRECTFB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DIRECTFB_DIR) $(@D) ; \
	fi
# ati128,cle266,cyber5k,i810,i830,mach64,matrox,neomagic,nsc,nvidia,radeon,savage,sis315,tdfx,unichrome \
#		ac_cv_header_linux_wm97xx_h=no \
		ac_cv_header_linux_sisfb_h=no \
		;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DIRECTFB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DIRECTFB_LDFLAGS)" \
		ac_cv_path_VNC_CONFIG=$(STAGING_PREFIX)/bin/libvncserver-config \
		ac_cv_path_FREETYPE_CONFIG=$(STAGING_PREFIX)/bin/freetype-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		\
		--enable-jpeg \
		--enable-png \
		--enable-fbdev \
		--enable-vnc \
		--disable-x11 \
		--enable-linux-input \
		--enable-zlib \
		--enable-freetype \
		--with-gfxdrivers=ati128,cle266,cyber5k,i810,i830,mach64,neomagic,nsc,nvidia,radeon,savage,sis315,tdfx,unichrome \
		--disable-sysfs \
		--disable-sdl \
		--disable-video4linux \
		--disable-video4linux2 \
		--disable-fusion \
		\
		--program-transform-name="" \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

directfb-unpack: $(DIRECTFB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIRECTFB_BUILD_DIR)/.built: $(DIRECTFB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
directfb: $(DIRECTFB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIRECTFB_BUILD_DIR)/.staged: $(DIRECTFB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/lib DESTDIR=$(STAGING_DIR) install
	touch $@

directfb-stage: $(DIRECTFB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/directfb
#
$(DIRECTFB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: directfb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIRECTFB_PRIORITY)" >>$@
	@echo "Section: $(DIRECTFB_SECTION)" >>$@
	@echo "Version: $(DIRECTFB_VERSION)-$(DIRECTFB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIRECTFB_MAINTAINER)" >>$@
	@echo "Source: $(DIRECTFB_SITE)/$(DIRECTFB_SOURCE)" >>$@
	@echo "Description: $(DIRECTFB_DESCRIPTION)" >>$@
	@echo "Depends: $(DIRECTFB_DEPENDS)" >>$@
	@echo "Suggests: $(DIRECTFB_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIRECTFB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIRECTFB_IPK_DIR)/opt/sbin or $(DIRECTFB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIRECTFB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIRECTFB_IPK_DIR)/opt/etc/directfb/...
# Documentation files should be installed in $(DIRECTFB_IPK_DIR)/opt/doc/directfb/...
# Daemon startup scripts should be installed in $(DIRECTFB_IPK_DIR)/opt/etc/init.d/S??directfb
#
# You may need to patch your application to make it use these locations.
#
$(DIRECTFB_IPK): $(DIRECTFB_BUILD_DIR)/.built
	rm -rf $(DIRECTFB_IPK_DIR) $(BUILD_DIR)/directfb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DIRECTFB_BUILD_DIR) install-strip \
		DESTDIR=$(DIRECTFB_IPK_DIR)
	find $(DIRECTFB_IPK_DIR)/opt/lib -name '*.la' | xargs rm -f
	$(MAKE) $(DIRECTFB_IPK_DIR)/CONTROL/control
	echo $(DIRECTFB_CONFFILES) | sed -e 's/ /\n/g' > $(DIRECTFB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIRECTFB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
directfb-ipk: $(DIRECTFB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
directfb-clean:
	rm -f $(DIRECTFB_BUILD_DIR)/.built
	-$(MAKE) -C $(DIRECTFB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
directfb-dirclean:
	rm -rf $(BUILD_DIR)/$(DIRECTFB_DIR) $(DIRECTFB_BUILD_DIR) $(DIRECTFB_IPK_DIR) $(DIRECTFB_IPK)
#
#
# Some sanity check for the package.
#
directfb-check: $(DIRECTFB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIRECTFB_IPK)
