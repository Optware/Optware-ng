###########################################################
#
# squeezelite
#
###########################################################
#
# SQUEEZELITE_VERSION, SQUEEZELITE_SITE and SQUEEZELITE_SOURCE define
# the upstream location of the source code for the package.
# SQUEEZELITE_DIR is the directory which is created when the source
# archive is unpacked.
# SQUEEZELITE_UNZIP is the command used to unzip the source.
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
SQUEEZELITE_GIT=https://code.google.com/p/squeezelite
SQUEEZELITE_COMMIT=8b8dfe6918ebe45ade5f3d9b68d453d7b8128d99
SQUEEZELITE_VERSION=1.8
SQUEEZELITE_SOURCE=squeezelite-$(SQUEEZELITE_VERSION).tar.gz
SQUEEZELITE_DIR=squeezelite-$(SQUEEZELITE_VERSION)
SQUEEZELITE_UNZIP=zcat
SQUEEZELITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQUEEZELITE_DESCRIPTION=Squeezelite is a small headless squeezebox emulator for linux using alsa audio output.
SQUEEZELITE_SECTION=audio
SQUEEZELITE_PRIORITY=optional
SQUEEZELITE_DEPENDS=flac, libvorbis, libmad, faad2, mpg123, alsa-lib, libsoxr, ffmpeg
SQUEEZELITE_SUGGESTS=
SQUEEZELITE_CONFLICTS=

#
# SQUEEZELITE_IPK_VERSION should be incremented when the ipk changes.
#
SQUEEZELITE_IPK_VERSION=3

#
# SQUEEZELITE_CONFFILES should be a list of user-editable files
#SQUEEZELITE_CONFFILES=$(TARGET_PREFIX)/etc/squeezelite.conf $(TARGET_PREFIX)/etc/init.d/SXXsqueezelite

#
# SQUEEZELITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SQUEEZELITE_PATCHES=\
$(SQUEEZELITE_SOURCE_DIR)/clear_dynlink_errors.patch \
$(SQUEEZELITE_SOURCE_DIR)/wait_for_nonzero_mac.patch \
$(SQUEEZELITE_SOURCE_DIR)/Makefile-tweaks.patch \
$(SQUEEZELITE_SOURCE_DIR)/ffmpeg_2.9.patch \
$(SQUEEZELITE_SOURCE_DIR)/rename-logs.patch \
$(SQUEEZELITE_SOURCE_DIR)/rename-FF_INPUT_BUFFER_PADDING_SIZE-to-AV_INPUT_BUFFER_PADDING_SIZE.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQUEEZELITE_CPPFLAGS=-DFFMPEG -DDSD -DRESAMPLE -DLINKALL
SQUEEZELITE_LDFLAGS=-pthread -lasound -lm -lrt

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
SQUEEZELITE_CPPFLAGS += -DSELFPIPE=1
endif

#
# SQUEEZELITE_BUILD_DIR is the directory in which the build is done.
# SQUEEZELITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQUEEZELITE_IPK_DIR is the directory in which the ipk is built.
# SQUEEZELITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQUEEZELITE_BUILD_DIR=$(BUILD_DIR)/squeezelite
SQUEEZELITE_SOURCE_DIR=$(SOURCE_DIR)/squeezelite
SQUEEZELITE_IPK_DIR=$(BUILD_DIR)/squeezelite-$(SQUEEZELITE_VERSION)-ipk
SQUEEZELITE_IPK=$(BUILD_DIR)/squeezelite_$(SQUEEZELITE_VERSION)-$(SQUEEZELITE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: squeezelite-source squeezelite-unpack squeezelite squeezelite-stage squeezelite-ipk squeezelite-clean squeezelite-dirclean squeezelite-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SQUEEZELITE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SQUEEZELITE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SQUEEZELITE_SOURCE).sha512
#
$(DL_DIR)/$(SQUEEZELITE_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf squeezelite && \
		git clone --bare $(SQUEEZELITE_GIT) squeezelite && \
		(cd squeezelite && \
		git archive --format=tar --prefix=$(SQUEEZELITE_DIR)/ $(SQUEEZELITE_COMMIT) | gzip > $@) && \
		rm -rf squeezelite ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
squeezelite-source: $(DL_DIR)/$(SQUEEZELITE_SOURCE) $(SQUEEZELITE_PATCHES)

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
$(SQUEEZELITE_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUEEZELITE_SOURCE) $(SQUEEZELITE_PATCHES) make/squeezelite.mk
	$(MAKE) flac-stage libvorbis-stage libmad-stage faad2-stage mpg123-stage alsa-lib-stage libsoxr-stage ffmpeg-stage
	rm -rf $(BUILD_DIR)/$(SQUEEZELITE_DIR) $(@D)
	$(SQUEEZELITE_UNZIP) $(DL_DIR)/$(SQUEEZELITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQUEEZELITE_PATCHES)" ; \
		then cat $(SQUEEZELITE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SQUEEZELITE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SQUEEZELITE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SQUEEZELITE_DIR) $(@D) ; \
	fi
	touch $@

squeezelite-unpack: $(SQUEEZELITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQUEEZELITE_BUILD_DIR)/.built: $(SQUEEZELITE_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
		OPTS="$(STAGING_CPPFLAGS) $(SQUEEZELITE_CPPFLAGS)" \
		LDADD="$(STAGING_LDFLAGS) $(SQUEEZELITE_LDFLAGS)" \
			$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
squeezelite: $(SQUEEZELITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SQUEEZELITE_BUILD_DIR)/.staged: $(SQUEEZELITE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#squeezelite-stage: $(SQUEEZELITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/squeezelite
#
$(SQUEEZELITE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: squeezelite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQUEEZELITE_PRIORITY)" >>$@
	@echo "Section: $(SQUEEZELITE_SECTION)" >>$@
	@echo "Version: $(SQUEEZELITE_VERSION)-$(SQUEEZELITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQUEEZELITE_MAINTAINER)" >>$@
	@echo "Source: $(SQUEEZELITE_GIT)" >>$@
	@echo "Description: $(SQUEEZELITE_DESCRIPTION)" >>$@
	@echo "Depends: $(SQUEEZELITE_DEPENDS)" >>$@
	@echo "Suggests: $(SQUEEZELITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQUEEZELITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/etc/squeezelite/...
# Documentation files should be installed in $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/doc/squeezelite/...
# Daemon startup scripts should be installed in $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??squeezelite
#
# You may need to patch your application to make it use these locations.
#
$(SQUEEZELITE_IPK): $(SQUEEZELITE_BUILD_DIR)/.built
	rm -rf $(SQUEEZELITE_IPK_DIR) $(BUILD_DIR)/squeezelite_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SQUEEZELITE_BUILD_DIR)/squeezelite $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(SQUEEZELITE_IPK_DIR)$(TARGET_PREFIX)/bin/squeezelite
	$(MAKE) $(SQUEEZELITE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SQUEEZELITE_SOURCE_DIR)/postinst $(SQUEEZELITE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SQUEEZELITE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SQUEEZELITE_SOURCE_DIR)/prerm $(SQUEEZELITE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SQUEEZELITE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SQUEEZELITE_IPK_DIR)/CONTROL/postinst $(SQUEEZELITE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SQUEEZELITE_CONFFILES) | sed -e 's/ /\n/g' > $(SQUEEZELITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQUEEZELITE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SQUEEZELITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
squeezelite-ipk: $(SQUEEZELITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
squeezelite-clean:
	rm -f $(SQUEEZELITE_BUILD_DIR)/.built
	-$(MAKE) -C $(SQUEEZELITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
squeezelite-dirclean:
	rm -rf $(BUILD_DIR)/$(SQUEEZELITE_DIR) $(SQUEEZELITE_BUILD_DIR) $(SQUEEZELITE_IPK_DIR) $(SQUEEZELITE_IPK)
#
#
# Some sanity check for the package.
#
squeezelite-check: $(SQUEEZELITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
