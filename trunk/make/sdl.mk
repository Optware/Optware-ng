###########################################################
#
# sdl
#
###########################################################
#
# SDL_VERSION, SDL_SITE and SDL_SOURCE define
# the upstream location of the source code for the package.
# SDL_DIR is the directory which is created when the source
# archive is unpacked.
# SDL_UNZIP is the command used to unzip the source.
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
SDL_SITE=http://www.libsdl.org/release
SDL_VERSION=1.2.11
SDL_SOURCE=SDL-$(SDL_VERSION).tar.gz
SDL_DIR=SDL-$(SDL_VERSION)
SDL_UNZIP=zcat
SDL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SDL_DESCRIPTION=Simple direct media library.
SDL_SECTION=lib
SDL_PRIORITY=optional
SDL_DEPENDS=x11, xext
SDL_SUGGESTS=
SDL_CONFLICTS=

#
# SDL_IPK_VERSION should be incremented when the ipk changes.
#
SDL_IPK_VERSION=2

#
# SDL_CONFFILES should be a list of user-editable files
SDL_CONFFILES=

#
# SDL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SDL_PATCHES=$(SDL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SDL_CPPFLAGS=
SDL_LDFLAGS=

#
# SDL_BUILD_DIR is the directory in which the build is done.
# SDL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SDL_IPK_DIR is the directory in which the ipk is built.
# SDL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SDL_BUILD_DIR=$(BUILD_DIR)/sdl
SDL_SOURCE_DIR=$(SOURCE_DIR)/sdl
SDL_IPK_DIR=$(BUILD_DIR)/sdl-$(SDL_VERSION)-ipk
SDL_IPK=$(BUILD_DIR)/sdl_$(SDL_VERSION)-$(SDL_IPK_VERSION)_$(TARGET_ARCH).ipk
SDL_DEV_IPK_DIR=$(BUILD_DIR)/sdl-dev-$(SDL_VERSION)-ipk
SDL_DEV_IPK=$(BUILD_DIR)/sdl-dev_$(SDL_VERSION)-$(SDL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SDL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SDL_SITE)/$(SDL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sdl-source: $(DL_DIR)/$(SDL_SOURCE) $(SDL_PATCHES)

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
$(SDL_BUILD_DIR)/.configured: $(DL_DIR)/$(SDL_SOURCE) $(SDL_PATCHES) make/sdl.mk
	$(MAKE) x11-stage
	$(MAKE) xext-stage
	rm -rf $(BUILD_DIR)/$(SDL_DIR) $(SDL_BUILD_DIR)
	$(SDL_UNZIP) $(DL_DIR)/$(SDL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(SDL_PATCHES) | patch -d $(BUILD_DIR)/$(SDL_DIR) -p1
	mv $(BUILD_DIR)/$(SDL_DIR) $(SDL_BUILD_DIR)
	(cd $(SDL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SDL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SDL_LDFLAGS)" \
		ac_cv_lib_ICE_IceConnectionNumber=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--disable-nls \
		--disable-static \
		--enable-shared \
		--disable-alsa \
		--disable-esd \
		--disable-arts \
		--enable-video-x11 \
		--disable-video-x11-vm \
		--disable-video-x11-xv \
		--disable-video-x11-xinerama \
		--disable-video-x11-xme \
		--disable-dga \
		--disable-video-dga \
		--disable-video-svga \
		--disable-video-opengl \
		--disable-video-aalib \
		--disable-video-fbcon \
	)
	$(PATCH_LIBTOOL) $(SDL_BUILD_DIR)/libtool
	touch $(SDL_BUILD_DIR)/.configured

sdl-unpack: $(SDL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SDL_BUILD_DIR)/.built: $(SDL_BUILD_DIR)/.configured
	rm -f $(SDL_BUILD_DIR)/.built
	$(MAKE) -C $(SDL_BUILD_DIR)
	touch $(SDL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
sdl: $(SDL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SDL_BUILD_DIR)/.staged: $(SDL_BUILD_DIR)/.built
	rm -f $(SDL_BUILD_DIR)/.staged
	$(MAKE) -C $(SDL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libSDL.la
	cp $(STAGING_PREFIX)/bin/sdl-config $(STAGING_DIR)/bin/
	touch $(SDL_BUILD_DIR)/.staged

sdl-stage: $(SDL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sdl
#
$(SDL_IPK_DIR)/CONTROL/control:
	@install -d $(SDL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sdl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SDL_PRIORITY)" >>$@
	@echo "Section: $(SDL_SECTION)" >>$@
	@echo "Version: $(SDL_VERSION)-$(SDL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SDL_MAINTAINER)" >>$@
	@echo "Source: $(SDL_SITE)/$(SDL_SOURCE)" >>$@
	@echo "Description: $(SDL_DESCRIPTION)" >>$@
	@echo "Depends: $(SDL_DEPENDS)" >>$@
	@echo "Suggests: $(SDL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SDL_CONFLICTS)" >>$@

$(SDL_DEV_IPK_DIR)/CONTROL/control:
	@install -d $(SDL_DEV_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sdl-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SDL_PRIORITY)" >>$@
	@echo "Section: $(SDL_SECTION)" >>$@
	@echo "Version: $(SDL_VERSION)-$(SDL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SDL_MAINTAINER)" >>$@
	@echo "Source: $(SDL_SITE)/$(SDL_SOURCE)" >>$@
	@echo "Description: Development stuff for native compiling SDL apps." >>$@
	@echo "Depends: sdl" >>$@

#
# This builds the IPK file.
#
$(SDL_IPK): $(SDL_BUILD_DIR)/.built
	rm -rf $(SDL_IPK_DIR) $(BUILD_DIR)/sdl_*_$(TARGET_ARCH).ipk
	rm -rf $(SDL_DEV_IPK_DIR) $(BUILD_DIR)/sdl-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SDL_BUILD_DIR) DESTDIR=$(SDL_DEV_IPK_DIR) install
	$(MAKE) $(SDL_DEV_IPK_DIR)/CONTROL/control
	$(MAKE) $(SDL_IPK_DIR)/CONTROL/control
	mkdir -p $(SDL_IPK_DIR)/opt
	mv $(SDL_DEV_IPK_DIR)/opt/lib $(SDL_IPK_DIR)/opt
	rm -f $(SDL_IPK_DIR)/opt/lib/libSDL.la
	-$(STRIP_COMMAND) $(SDL_IPK_DIR)/opt/lib/*.so.*
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SDL_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SDL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sdl-ipk: $(SDL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sdl-clean:
	-$(MAKE) -C $(SDL_BUILD_DIR) clean
	rm -f $(SDL_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sdl-dirclean:
	rm -rf $(BUILD_DIR)/$(SDL_DIR) $(SDL_BUILD_DIR) $(SDL_IPK_DIR) $(SDL_IPK) $(SDL_DEV_IPK_DIR) $(SDL_DEV_IPK)
