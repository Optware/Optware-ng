###########################################################
#
# sox
#
###########################################################
#
# SOX_VERSION, SOX_SITE and SOX_SOURCE define
# the upstream location of the source code for the package.
# SOX_DIR is the directory which is created when the source
# archive is unpacked.
# SOX_UNZIP is the command used to unzip the source.
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
SOX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/sox
SOX_VERSION=14.2.0
SOX_SOURCE=sox-$(SOX_VERSION).tar.gz
SOX_DIR=sox-$(SOX_VERSION)
SOX_UNZIP=zcat
SOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SOX_DESCRIPTION=Sound eXchange, command line utility that can convert various formats of audio files.
SOX_SECTION=audio
SOX_PRIORITY=optional
SOX_DEPENDS=file, libpng, zlib
SOX_DEPENDS +=, ffmpeg, flac, libao, libid3tag, libmad, libogg, libvorbis, wavpack
ifneq (, $(filter i686, $(TARGET_ARCH)))
SOX_DEPENDS +=, libsamplerate
endif
ifneq (, $(filter libsndfile, $(PACKAGES)))
SOX_DEPENDS +=, libsndfile
endif
SOX_CONFLICTS=

#
# SOX_IPK_VERSION should be incremented when the ipk changes.
#
SOX_IPK_VERSION=2

#
# SOX_CONFFILES should be a list of user-editable files
#SOX_CONFFILES=/opt/etc/sox.conf /opt/etc/init.d/SXXsox

#
# SOX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SOX_PATCHES=$(SOX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifdef NO_BUILTIN_MATH
SOX_CPPFLAGS=-fno-builtin-log -fno-builtin-exp
endif
SOX_LDFLAGS=

SOX_CONFIGURE_ARGS = --without-libltdl
ifneq (, $(filter i686, $(TARGET_ARCH)))
SOX_CONFIGURE_ARGS += --with-samplerate
else
SOX_CONFIGURE_ARGS += --without-samplerate
endif

#
# SOX_BUILD_DIR is the directory in which the build is done.
# SOX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SOX_IPK_DIR is the directory in which the ipk is built.
# SOX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SOX_BUILD_DIR=$(BUILD_DIR)/sox
SOX_SOURCE_DIR=$(SOURCE_DIR)/sox
SOX_IPK_DIR=$(BUILD_DIR)/sox-$(SOX_VERSION)-ipk
SOX_IPK=$(BUILD_DIR)/sox_$(SOX_VERSION)-$(SOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sox-source sox-unpack sox sox-stage sox-ipk sox-clean sox-dirclean sox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SOX_SOURCE):
	$(WGET) -P $(@D) $(SOX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sox-source: $(DL_DIR)/$(SOX_SOURCE) $(SOX_PATCHES)

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
$(SOX_BUILD_DIR)/.configured: $(DL_DIR)/$(SOX_SOURCE) $(SOX_PATCHES) make/sox.mk
	$(MAKE) file-stage libpng-stage zlib-stage
	$(MAKE) ffmpeg-stage flac-stage wavpack-stage
	$(MAKE) libao-stage libid3tag-stage libmad-stage
	$(MAKE) libogg-stage libvorbis-stage
ifneq (, $(filter i686, $(TARGET_ARCH)))
	$(MAKE) libsamplerate-stage
endif
ifneq (, $(filter libsndfile, $(PACKAGES)))
	$(MAKE) libsndfile-stage
endif
	rm -rf $(BUILD_DIR)/$(SOX_DIR) $(@D)
	$(SOX_UNZIP) $(DL_DIR)/$(SOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SOX_PATCHES)" ; \
		then cat $(SOX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SOX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SOX_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SOX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SOX_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(SOX_CONFIGURE_ARGS) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sox-unpack: $(SOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SOX_BUILD_DIR)/.built: $(SOX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sox: $(SOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SOX_BUILD_DIR)/.staged: $(SOX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libsox*.la $(STAGING_LIB_DIR)/sox/*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/sox.pc
	touch $@

sox-stage: $(SOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sox
#
$(SOX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SOX_PRIORITY)" >>$@
	@echo "Section: $(SOX_SECTION)" >>$@
	@echo "Version: $(SOX_VERSION)-$(SOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SOX_MAINTAINER)" >>$@
	@echo "Source: $(SOX_SITE)/$(SOX_SOURCE)" >>$@
	@echo "Description: $(SOX_DESCRIPTION)" >>$@
	@echo "Depends: $(SOX_DEPENDS)" >>$@
	@echo "Suggests: $(SOX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SOX_IPK_DIR)/opt/sbin or $(SOX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SOX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SOX_IPK_DIR)/opt/etc/sox/...
# Documentation files should be installed in $(SOX_IPK_DIR)/opt/doc/sox/...
# Daemon startup scripts should be installed in $(SOX_IPK_DIR)/opt/etc/init.d/S??sox
#
# You may need to patch your application to make it use these locations.
#
$(SOX_IPK): $(SOX_BUILD_DIR)/.built
	rm -rf $(SOX_IPK_DIR) $(BUILD_DIR)/sox_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SOX_BUILD_DIR) install-strip DESTDIR=$(SOX_IPK_DIR) transform=''
	$(MAKE) $(SOX_IPK_DIR)/CONTROL/control
	echo $(SOX_CONFFILES) | sed -e 's/ /\n/g' > $(SOX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sox-ipk: $(SOX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sox-clean:
	rm -f $(SOX_BUILD_DIR)/.built
	-$(MAKE) -C $(SOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sox-dirclean:
	rm -rf $(BUILD_DIR)/$(SOX_DIR) $(SOX_BUILD_DIR) $(SOX_IPK_DIR) $(SOX_IPK)
#
#
# Some sanity check for the package.
#
sox-check: $(SOX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
