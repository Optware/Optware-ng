###########################################################
#
# ffmpegthumbnailer
#
###########################################################
#
# FFMPEGTHUMBNAILER_VERSION, FFMPEGTHUMBNAILER_SITE and FFMPEGTHUMBNAILER_SOURCE define
# the upstream location of the source code for the package.
# FFMPEGTHUMBNAILER_DIR is the directory which is created when the source
# archive is unpacked.
# FFMPEGTHUMBNAILER_UNZIP is the command used to unzip the source.
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
FFMPEGTHUMBNAILER_SITE=https://github.com/dirkvdb/ffmpegthumbnailer/archive
FFMPEGTHUMBNAILER_VERSION=2.2.0
FFMPEGTHUMBNAILER_SOURCE=$(FFMPEGTHUMBNAILER_VERSION).tar.gz
FFMPEGTHUMBNAILER_SOURCE_SAVE=ffmpegthumbnailer-$(FFMPEGTHUMBNAILER_VERSION).tar.gz
FFMPEGTHUMBNAILER_DIR=ffmpegthumbnailer-$(FFMPEGTHUMBNAILER_VERSION)
FFMPEGTHUMBNAILER_UNZIP=zcat
FFMPEGTHUMBNAILER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FFMPEGTHUMBNAILER_DESCRIPTION=Lightweight video thumbnailer.
FFMPEGTHUMBNAILER_SECTION=tool
FFMPEGTHUMBNAILER_PRIORITY=optional
FFMPEGTHUMBNAILER_DEPENDS=ffmpeg, libjpeg, libpng
FFMPEGTHUMBNAILER_SUGGESTS=
FFMPEGTHUMBNAILER_CONFLICTS=

#
# FFMPEGTHUMBNAILER_IPK_VERSION should be incremented when the ipk changes.
#
FFMPEGTHUMBNAILER_IPK_VERSION=1

#
# FFMPEGTHUMBNAILER_CONFFILES should be a list of user-editable files
#FFMPEGTHUMBNAILER_CONFFILES=$(TARGET_PREFIX)/etc/ffmpegthumbnailer.conf $(TARGET_PREFIX)/etc/init.d/SXXffmpegthumbnailer

#
# FFMPEGTHUMBNAILER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FFMPEGTHUMBNAILER_PATCHES=$(FFMPEGTHUMBNAILER_SOURCE_DIR)/locale.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FFMPEGTHUMBNAILER_CPPFLAGS=
FFMPEGTHUMBNAILER_LDFLAGS=

#
# FFMPEGTHUMBNAILER_BUILD_DIR is the directory in which the build is done.
# FFMPEGTHUMBNAILER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FFMPEGTHUMBNAILER_IPK_DIR is the directory in which the ipk is built.
# FFMPEGTHUMBNAILER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FFMPEGTHUMBNAILER_BUILD_DIR=$(BUILD_DIR)/ffmpegthumbnailer
FFMPEGTHUMBNAILER_SOURCE_DIR=$(SOURCE_DIR)/ffmpegthumbnailer
FFMPEGTHUMBNAILER_IPK_DIR=$(BUILD_DIR)/ffmpegthumbnailer-$(FFMPEGTHUMBNAILER_VERSION)-ipk
FFMPEGTHUMBNAILER_IPK=$(BUILD_DIR)/ffmpegthumbnailer_$(FFMPEGTHUMBNAILER_VERSION)-$(FFMPEGTHUMBNAILER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ffmpegthumbnailer-source ffmpegthumbnailer-unpack ffmpegthumbnailer ffmpegthumbnailer-stage ffmpegthumbnailer-ipk ffmpegthumbnailer-clean ffmpegthumbnailer-dirclean ffmpegthumbnailer-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FFMPEGTHUMBNAILER_SOURCE_SAVE):
	$(WGET) -O $@ $(FFMPEGTHUMBNAILER_SITE)/$(FFMPEGTHUMBNAILER_SOURCE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ffmpegthumbnailer-source: $(DL_DIR)/$(FFMPEGTHUMBNAILER_SOURCE_SAVE) $(FFMPEGTHUMBNAILER_PATCHES)

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
$(FFMPEGTHUMBNAILER_BUILD_DIR)/.configured: $(DL_DIR)/$(FFMPEGTHUMBNAILER_SOURCE_SAVE) $(FFMPEGTHUMBNAILER_PATCHES) make/ffmpegthumbnailer.mk
	$(MAKE) ffmpeg-stage libjpeg-stage libpng-stage
	rm -rf $(BUILD_DIR)/$(FFMPEGTHUMBNAILER_DIR) $(@D)
	$(FFMPEGTHUMBNAILER_UNZIP) $(DL_DIR)/$(FFMPEGTHUMBNAILER_SOURCE_SAVE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FFMPEGTHUMBNAILER_PATCHES)" ; \
		then cat $(FFMPEGTHUMBNAILER_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FFMPEGTHUMBNAILER_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FFMPEGTHUMBNAILER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FFMPEGTHUMBNAILER_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(FFMPEGTHUMBNAILER_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(FFMPEGTHUMBNAILER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_BUILD_TYPE=Release \
		-DFFMPEG_ROOT=$(STAGING_PREFIX) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(FFMPEGTHUMBNAILER_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(FFMPEGTHUMBNAILER_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(FFMPEGTHUMBNAILER_LDFLAGS)"
	touch $@

ffmpegthumbnailer-unpack: $(FFMPEGTHUMBNAILER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FFMPEGTHUMBNAILER_BUILD_DIR)/.built: $(FFMPEGTHUMBNAILER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ffmpegthumbnailer: $(FFMPEGTHUMBNAILER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FFMPEGTHUMBNAILER_BUILD_DIR)/.staged: $(FFMPEGTHUMBNAILER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libffmpegthumbnailer.pc
	touch $@

ffmpegthumbnailer-stage: $(FFMPEGTHUMBNAILER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ffmpegthumbnailer
#
$(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ffmpegthumbnailer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FFMPEGTHUMBNAILER_PRIORITY)" >>$@
	@echo "Section: $(FFMPEGTHUMBNAILER_SECTION)" >>$@
	@echo "Version: $(FFMPEGTHUMBNAILER_VERSION)-$(FFMPEGTHUMBNAILER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FFMPEGTHUMBNAILER_MAINTAINER)" >>$@
	@echo "Source: $(FFMPEGTHUMBNAILER_SITE)/$(FFMPEGTHUMBNAILER_SOURCE)" >>$@
	@echo "Description: $(FFMPEGTHUMBNAILER_DESCRIPTION)" >>$@
	@echo "Depends: $(FFMPEGTHUMBNAILER_DEPENDS)" >>$@
	@echo "Suggests: $(FFMPEGTHUMBNAILER_SUGGESTS)" >>$@
	@echo "Conflicts: $(FFMPEGTHUMBNAILER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/ffmpegthumbnailer/...
# Documentation files should be installed in $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/doc/ffmpegthumbnailer/...
# Daemon startup scripts should be installed in $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ffmpegthumbnailer
#
# You may need to patch your application to make it use these locations.
#
$(FFMPEGTHUMBNAILER_IPK): $(FFMPEGTHUMBNAILER_BUILD_DIR)/.built
	rm -rf $(FFMPEGTHUMBNAILER_IPK_DIR) $(BUILD_DIR)/ffmpegthumbnailer_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FFMPEGTHUMBNAILER_BUILD_DIR) DESTDIR=$(FFMPEGTHUMBNAILER_IPK_DIR) install
	$(STRIP_COMMAND) $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/{bin/*,lib/*.so}
	rm -f $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(FFMPEGTHUMBNAILER_SOURCE_DIR)/ffmpegthumbnailer.conf $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/ffmpegthumbnailer.conf
#	$(INSTALL) -d $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(FFMPEGTHUMBNAILER_SOURCE_DIR)/rc.ffmpegthumbnailer $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXffmpegthumbnailer
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FFMPEGTHUMBNAILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXffmpegthumbnailer
	$(MAKE) $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(FFMPEGTHUMBNAILER_SOURCE_DIR)/postinst $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(FFMPEGTHUMBNAILER_SOURCE_DIR)/prerm $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/postinst $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FFMPEGTHUMBNAILER_CONFFILES) | sed -e 's/ /\n/g' > $(FFMPEGTHUMBNAILER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FFMPEGTHUMBNAILER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(FFMPEGTHUMBNAILER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ffmpegthumbnailer-ipk: $(FFMPEGTHUMBNAILER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ffmpegthumbnailer-clean:
	rm -f $(FFMPEGTHUMBNAILER_BUILD_DIR)/.built
	-$(MAKE) -C $(FFMPEGTHUMBNAILER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ffmpegthumbnailer-dirclean:
	rm -rf $(BUILD_DIR)/$(FFMPEGTHUMBNAILER_DIR) $(FFMPEGTHUMBNAILER_BUILD_DIR) $(FFMPEGTHUMBNAILER_IPK_DIR) $(FFMPEGTHUMBNAILER_IPK)
#
#
# Some sanity check for the package.
#
ffmpegthumbnailer-check: $(FFMPEGTHUMBNAILER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
