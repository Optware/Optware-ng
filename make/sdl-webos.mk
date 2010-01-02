###########################################################
#
# sdl
#
###########################################################
#
# SDL-WEBOS_VERSION, SDL-WEBOS_SITE and SDL-WEBOS_SOURCE define
# the upstream location of the source code for the package.
# SDL-WEBOS_DIR is the directory which is created when the source
# archive is unpacked.
# SDL-WEBOS_UNZIP is the command used to unzip the source.
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
SDL-WEBOS_SITE=http://www.libsdl.org/release
SDL-WEBOS_VERSION=1.2.13
SDL-WEBOS_SOURCE=SDL-$(SDL-WEBOS_VERSION).tar.gz
SDL-WEBOS_DIR=SDL-$(SDL-WEBOS_VERSION)
SDL-WEBOS_UNZIP=zcat
SDL-WEBOS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SDL-WEBOS_DESCRIPTION=Simple direct media library.
SDL-WEBOS_SECTION=lib
SDL-WEBOS_PRIORITY=optional
SDL-WEBOS_DEPENDS=x11, xext
SDL-WEBOS_SUGGESTS=
SDL-WEBOS_CONFLICTS=

#
# SDL-WEBOS_IPK_VERSION should be incremented when the ipk changes.
#
SDL-WEBOS_IPK_VERSION=1

#
# SDL-WEBOS_CONFFILES should be a list of user-editable files
SDL-WEBOS_CONFFILES=

#
# SDL-WEBOS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SDL-WEBOS_PATCHES=$(SDL-WEBOS_SOURCE_DIR)/libsdl-1.2-patch $(SDL-WEBOS_SOURCE_DIR)/configure-in.patch \
$(SDL-WEBOS_SOURCE_DIR)/derived_headers1.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SDL-WEBOS_CPPFLAGS=
SDL-WEBOS_LDFLAGS=

#
# SDL-WEBOS_BUILD_DIR is the directory in which the build is done.
# SDL-WEBOS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SDL-WEBOS_IPK_DIR is the directory in which the ipk is built.
# SDL-WEBOS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SDL-WEBOS_BUILD_DIR=$(BUILD_DIR)/sdl-webos
SDL-WEBOS_SOURCE_DIR=$(SOURCE_DIR)/sdl-webos
SDL-WEBOS_IPK_DIR=$(BUILD_DIR)/sdl-webos-$(SDL-WEBOS_VERSION)-ipk
SDL-WEBOS_IPK=$(BUILD_DIR)/sdl-webos_$(SDL-WEBOS_VERSION)-$(SDL-WEBOS_IPK_VERSION)_$(TARGET_ARCH).ipk
SDL-WEBOS_DEV_IPK_DIR=$(BUILD_DIR)/sdl-webos-dev-$(SDL-WEBOS_VERSION)-ipk
SDL-WEBOS_DEV_IPK=$(BUILD_DIR)/sdl-webos-dev_$(SDL-WEBOS_VERSION)-$(SDL-WEBOS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SDL-WEBOS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SDL-WEBOS_SITE)/$(SDL-WEBOS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sdl-webos-source: $(DL_DIR)/$(SDL-WEBOS_SOURCE) $(SDL-WEBOS_PATCHES)

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
#		--x-includes=$(STAGING_INCLUDE_DIR) \
#		--x-libraries=$(STAGING_LIB_DIR) \

$(SDL-WEBOS_BUILD_DIR)/.configured: $(DL_DIR)/$(SDL-WEBOS_SOURCE) $(SDL-WEBOS_PATCHES) make/sdl.mk
#	$(MAKE) x11-stage
#	$(MAKE) xext-stage
	rm -rf $(BUILD_DIR)/$(SDL-WEBOS_DIR) $(SDL-WEBOS_BUILD_DIR)
	$(SDL-WEBOS_UNZIP) $(DL_DIR)/$(SDL-WEBOS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SDL-WEBOS_PATCHES) | patch -d $(BUILD_DIR)/$(SDL-WEBOS_DIR) -p1
	mv $(BUILD_DIR)/$(SDL-WEBOS_DIR) $(SDL-WEBOS_BUILD_DIR)
	(cd $(SDL-WEBOS_BUILD_DIR); ./autogen.sh )
	(cd $(SDL-WEBOS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SDL-WEBOS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SDL-WEBOS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-ipod \
		--enable-webos \
		--enable-video-opengles \
		--disable-cdrom \
		--disable-diskaudio \
		--disable-esd \
		--disable-oss \
		--disable-video-oga \
		--disable-video-directfb \
		--disable-video-dummy \
		--disable-video-x11 \
		--disable-nls \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(SDL-WEBOS_BUILD_DIR)/libtool
	touch $(SDL-WEBOS_BUILD_DIR)/.configured

sdl-webos-unpack: $(SDL-WEBOS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SDL-WEBOS_BUILD_DIR)/.built: $(SDL-WEBOS_BUILD_DIR)/.configured
	rm -f $(SDL-WEBOS_BUILD_DIR)/.built
	$(MAKE) -C $(SDL-WEBOS_BUILD_DIR)
	touch $(SDL-WEBOS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
sdl-webos: $(SDL-WEBOS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SDL-WEBOS_BUILD_DIR)/.staged: $(SDL-WEBOS_BUILD_DIR)/.built
	rm -f $(SDL-WEBOS_BUILD_DIR)/.staged
	$(MAKE) -C $(SDL-WEBOS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libSDL.la
	cp $(STAGING_PREFIX)/bin/sdl-config $(STAGING_DIR)/bin/
	touch $(SDL-WEBOS_BUILD_DIR)/.staged

sdl-webos-stage: $(SDL-WEBOS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sdl
#
$(SDL-WEBOS_IPK_DIR)/CONTROL/control:
	@install -d $(SDL-WEBOS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sdl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SDL-WEBOS_PRIORITY)" >>$@
	@echo "Section: $(SDL-WEBOS_SECTION)" >>$@
	@echo "Version: $(SDL-WEBOS_VERSION)-$(SDL-WEBOS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SDL-WEBOS_MAINTAINER)" >>$@
	@echo "Source: $(SDL-WEBOS_SITE)/$(SDL-WEBOS_SOURCE)" >>$@
	@echo "Description: $(SDL-WEBOS_DESCRIPTION)" >>$@
	@echo "Depends: $(SDL-WEBOS_DEPENDS)" >>$@
	@echo "Suggests: $(SDL-WEBOS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SDL-WEBOS_CONFLICTS)" >>$@

$(SDL-WEBOS_DEV_IPK_DIR)/CONTROL/control:
	@install -d $(SDL-WEBOS_DEV_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sdl-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SDL-WEBOS_PRIORITY)" >>$@
	@echo "Section: $(SDL-WEBOS_SECTION)" >>$@
	@echo "Version: $(SDL-WEBOS_VERSION)-$(SDL-WEBOS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SDL-WEBOS_MAINTAINER)" >>$@
	@echo "Source: $(SDL-WEBOS_SITE)/$(SDL-WEBOS_SOURCE)" >>$@
	@echo "Description: Development stuff for native compiling SDL apps." >>$@
	@echo "Depends: sdl" >>$@

#
# This builds the IPK file.
#
$(SDL-WEBOS_IPK): $(SDL-WEBOS_BUILD_DIR)/.built
	rm -rf $(SDL-WEBOS_IPK_DIR) $(BUILD_DIR)/sdl_*_$(TARGET_ARCH).ipk
	rm -rf $(SDL-WEBOS_DEV_IPK_DIR) $(BUILD_DIR)/sdl-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SDL-WEBOS_BUILD_DIR) DESTDIR=$(SDL-WEBOS_DEV_IPK_DIR) install
	$(MAKE) $(SDL-WEBOS_DEV_IPK_DIR)/CONTROL/control
	$(MAKE) $(SDL-WEBOS_IPK_DIR)/CONTROL/control
	mkdir -p $(SDL-WEBOS_IPK_DIR)/opt
	mv $(SDL-WEBOS_DEV_IPK_DIR)/opt/lib $(SDL-WEBOS_IPK_DIR)/opt
	rm -f $(SDL-WEBOS_IPK_DIR)/opt/lib/libSDL.la
	-$(STRIP_COMMAND) $(SDL-WEBOS_IPK_DIR)/opt/lib/*.so.*
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SDL-WEBOS_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SDL-WEBOS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sdl-webos-ipk: $(SDL-WEBOS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sdl-webos-clean:
	-$(MAKE) -C $(SDL-WEBOS_BUILD_DIR) clean
	rm -f $(SDL-WEBOS_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sdl-webos-dirclean:
	rm -rf $(BUILD_DIR)/$(SDL-WEBOS_DIR) $(SDL-WEBOS_BUILD_DIR) $(SDL-WEBOS_IPK_DIR) $(SDL-WEBOS_IPK) $(SDL-WEBOS_DEV_IPK_DIR) $(SDL-WEBOS_DEV_IPK)
