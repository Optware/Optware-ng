###########################################################
#
# gerbera
#
###########################################################
#
# GERBERA_VERSION, GERBERA_SITE and GERBERA_SOURCE define
# the upstream location of the source code for the package.
# GERBERA_DIR is the directory which is created when the source
# archive is unpacked.
# GERBERA_UNZIP is the command used to unzip the source.
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
GERBERA_URL=https://github.com/gerbera/gerbera/archive/v$(GERBERA_VERSION).tar.gz
GERBERA_VERSION:=1.1.0
GERBERA_SOURCE=gerbera-$(GERBERA_VERSION).tar.gz
GERBERA_DIR=gerbera-$(GERBERA_VERSION)

GERBERA_GIT=https://github.com/gerbera/gerbera.git
GERBERA_GIT_DATE=20180125

ifdef GERBERA_GIT_DATE
  GERBERA_VERSION:=$(GERBERA_VERSION)+git$(GERBERA_GIT_DATE)
  # This should be updated when GERBERA_GIT_DATE changes
  GERBERA_GIT_TREEISH=df247e33d49bd5f0bd7924414584ddd3aa3bde77
endif

GERBERA_UNZIP=zcat
GERBERA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GERBERA_DESCRIPTION=UPnP Media Server 2018 (Based on MediaTomb 12.1)
GERBERA_SECTION=media
GERBERA_PRIORITY=optional
GERBERA_DEPENDS=start-stop-daemon, ffmpeg, duktape, libupnp, \
		sqlite, libcurl, libtheora, file, libexif, \
		expat, libvorbis, e2fslibs, ffmpegthumbnailer, \
		libstdc++
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GERBERA_DEPENDS +=, libiconv
endif
GERBERA_SUGGESTS=
GERBERA_CONFLICTS=

#
# GERBERA_IPK_VERSION should be incremented when the ipk changes.
#
GERBERA_IPK_VERSION=1

#
# GERBERA_CONFFILES should be a list of user-editable files
GERBERA_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S98gerbera

#
# GERBERA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GERBERA_PATCHES=\
#$(GERBERA_SOURCE_DIR)/configure.patch \

ifeq (, $(filter libiconv, $(PACKAGES)))
GERBERA_PATCHES += $(GERBERA_SOURCE_DIR)/no-libiconv.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GERBERA_CPPFLAGS=
GERBERA_LDFLAGS=

#
# GERBERA_BUILD_DIR is the directory in which the build is done.
# GERBERA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GERBERA_IPK_DIR is the directory in which the ipk is built.
# GERBERA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GERBERA_BUILD_DIR=$(BUILD_DIR)/gerbera
GERBERA_SOURCE_DIR=$(SOURCE_DIR)/gerbera
GERBERA_IPK_DIR=$(BUILD_DIR)/gerbera-$(GERBERA_VERSION)-ipk
GERBERA_IPK=$(BUILD_DIR)/gerbera_$(GERBERA_VERSION)-$(GERBERA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gerbera-source gerbera-unpack gerbera gerbera-stage gerbera-ipk gerbera-clean gerbera-dirclean gerbera-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(GERBERA_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(GERBERA_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(GERBERA_SOURCE).sha512
#
ifdef GERBERA_GIT_TREEISH
$(DL_DIR)/$(GERBERA_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf gerbera && \
		git clone --bare $(GERBERA_GIT) gerbera && \
		(cd gerbera && \
		git archive --format=tar --prefix=$(GERBERA_DIR)/ $(GERBERA_GIT_TREEISH) | gzip > $@) && \
		rm -rf golang ; \
	)
else
$(DL_DIR)/$(GERBERA_SOURCE):
	$(WGET) -O $@ $(GERBERA_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gerbera-source: $(DL_DIR)/$(GERBERA_SOURCE) $(GERBERA_PATCHES)

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
$(GERBERA_BUILD_DIR)/.configured: $(DL_DIR)/$(GERBERA_SOURCE) $(GERBERA_PATCHES) make/gerbera.mk
	$(MAKE) ffmpeg-stage duktape-stage libupnp-stage sqlite-stage libcurl-stage \
		libtheora-stage file-stage libexif-stage expat-stage libvorbis-stage \
		e2fsprogs-stage ffmpegthumbnailer-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GERBERA_DIR) $(@D)
	$(GERBERA_UNZIP) $(DL_DIR)/$(GERBERA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GERBERA_PATCHES)" ; \
		then cat $(GERBERA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GERBERA_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GERBERA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GERBERA_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(GERBERA_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(GERBERA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DGERBERA_C_FLAGS="$(STAGING_CPPFLAGS) $(GERBERA_CPPFLAGS)" \
		-DGERBERA_CXX_FLAGS="$(STAGING_CPPFLAGS) $(GERBERA_CPPFLAGS)" \
		-DGERBERA_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DGERBERA_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DGERBERA_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DGERBERA_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DGERBERA_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DGERBERA_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(GERBERA_LDFLAGS)" \
		-DWITH_MYSQL=0 \
		-DWITH_TAGLIB=0 \
		-DWITH_AVCODEC=1 \
		-DWITH_FFMPEGTHUMBNAILER=1 \
		-DWITH_DEBUG_LOGGING=0 \
		-DWITH_SYSTEMD=0
	touch $@

gerbera-unpack: $(GERBERA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GERBERA_BUILD_DIR)/.built: $(GERBERA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gerbera: $(GERBERA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GERBERA_BUILD_DIR)/.staged: $(GERBERA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gerbera-stage: $(GERBERA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gerbera
#
$(GERBERA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gerbera" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GERBERA_PRIORITY)" >>$@
	@echo "Section: $(GERBERA_SECTION)" >>$@
	@echo "Version: $(GERBERA_VERSION)-$(GERBERA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GERBERA_MAINTAINER)" >>$@
ifdef GERBERA_GIT_TREEISH
	@echo "Source: $(GERBERA_GIT)" >>$@
else
	@echo "Source: $(GERBERA_URL)" >>$@
endif
	@echo "Description: $(GERBERA_DESCRIPTION)" >>$@
	@echo "Depends: $(GERBERA_DEPENDS)" >>$@
	@echo "Suggests: $(GERBERA_SUGGESTS)" >>$@
	@echo "Conflicts: $(GERBERA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/gerbera/...
# Documentation files should be installed in $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/doc/gerbera/...
# Daemon startup scripts should be installed in $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gerbera
#
# You may need to patch your application to make it use these locations.
#
$(GERBERA_IPK): $(GERBERA_BUILD_DIR)/.built
	rm -rf $(GERBERA_IPK_DIR) $(BUILD_DIR)/gerbera_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GERBERA_BUILD_DIR) DESTDIR=$(GERBERA_IPK_DIR) install
	$(STRIP_COMMAND) $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/bin/gerbera
#	$(INSTALL) -d $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GERBERA_SOURCE_DIR)/gerbera.conf $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/gerbera.conf
	$(INSTALL) -d $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(GERBERA_SOURCE_DIR)/rc.gerbera $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98gerbera
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GERBERA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgerbera
	$(MAKE) $(GERBERA_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GERBERA_SOURCE_DIR)/postinst $(GERBERA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GERBERA_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GERBERA_SOURCE_DIR)/prerm $(GERBERA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GERBERA_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GERBERA_IPK_DIR)/CONTROL/postinst $(GERBERA_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GERBERA_CONFFILES) | sed -e 's/ /\n/g' > $(GERBERA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GERBERA_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GERBERA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gerbera-ipk: $(GERBERA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gerbera-clean:
	rm -f $(GERBERA_BUILD_DIR)/.built
	-$(MAKE) -C $(GERBERA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gerbera-dirclean:
	rm -rf $(BUILD_DIR)/$(GERBERA_DIR) $(GERBERA_BUILD_DIR) $(GERBERA_IPK_DIR) $(GERBERA_IPK)
#
#
# Some sanity check for the package.
#
gerbera-check: $(GERBERA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
