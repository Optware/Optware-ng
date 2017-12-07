###########################################################
#
# chromaprint
#
###########################################################
#
# CHROMAPRINT_VERSION, CHROMAPRINT_SITE and CHROMAPRINT_SOURCE define
# the upstream location of the source code for the package.
# CHROMAPRINT_DIR is the directory which is created when the source
# archive is unpacked.
# CHROMAPRINT_UNZIP is the command used to unzip the source.
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
CHROMAPRINT_REPOSITORY=https://github.com/acoustid/chromaprint.git
CHROMAPRINT_GIT_DATE=20170731
CHROMAPRINT_VERSION=1.4.2+git$(CHROMAPRINT_GIT_DATE)
CHROMAPRINT_TREEISH=`git rev-list --max-count=1 --until=2017-07-31 HEAD`
CHROMAPRINT_SOURCE=chromaprint-$(CHROMAPRINT_VERSION).tar.gz
CHROMAPRINT_DIR=chromaprint-$(CHROMAPRINT_VERSION)
CHROMAPRINT_UNZIP=zcat
CHROMAPRINT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHROMAPRINT_DESCRIPTION=Chromaprint is an audio fingerprint library developed for the AcoustID project.
CHROMAPRINT_SECTION=audio
CHROMAPRINT_PRIORITY=optional
CHROMAPRINT_DEPENDS=ffmpeg
CHROMAPRINT_SUGGESTS=
CHROMAPRINT_CONFLICTS=

#
# CHROMAPRINT_IPK_VERSION should be incremented when the ipk changes.
#
CHROMAPRINT_IPK_VERSION=3

#
# CHROMAPRINT_CONFFILES should be a list of user-editable files
#CHROMAPRINT_CONFFILES=$(TARGET_PREFIX)/etc/chromaprint.conf $(TARGET_PREFIX)/etc/init.d/SXXchromaprint

#
# CHROMAPRINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CHROMAPRINT_PATCHES=\
$(CHROMAPRINT_SOURCE_DIR)/src-cmd-CMakeLists.txt.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHROMAPRINT_CPPFLAGS=-pthread
CHROMAPRINT_LDFLAGS=-pthread

#
# CHROMAPRINT_BUILD_DIR is the directory in which the build is done.
# CHROMAPRINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHROMAPRINT_IPK_DIR is the directory in which the ipk is built.
# CHROMAPRINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHROMAPRINT_BUILD_DIR=$(BUILD_DIR)/chromaprint
CHROMAPRINT_SOURCE_DIR=$(SOURCE_DIR)/chromaprint
CHROMAPRINT_IPK_DIR=$(BUILD_DIR)/chromaprint-$(CHROMAPRINT_VERSION)-ipk
CHROMAPRINT_IPK=$(BUILD_DIR)/chromaprint_$(CHROMAPRINT_VERSION)-$(CHROMAPRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: chromaprint-source chromaprint-unpack chromaprint chromaprint-stage chromaprint-ipk chromaprint-clean chromaprint-dirclean chromaprint-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(CHROMAPRINT_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(CHROMAPRINT_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(CHROMAPRINT_SOURCE).sha512
#
$(DL_DIR)/$(CHROMAPRINT_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf chromaprint && \
		git clone --bare $(CHROMAPRINT_REPOSITORY) chromaprint && \
		(cd chromaprint && \
		git archive --format=tar --prefix=$(CHROMAPRINT_DIR)/ $(CHROMAPRINT_TREEISH) | gzip > $@) && \
		rm -rf chromaprint ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
chromaprint-source: $(DL_DIR)/$(CHROMAPRINT_SOURCE) $(CHROMAPRINT_PATCHES)

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
$(CHROMAPRINT_BUILD_DIR)/.configured: $(DL_DIR)/$(CHROMAPRINT_SOURCE) $(CHROMAPRINT_PATCHES) make/chromaprint.mk
	$(MAKE) ffmpeg-stage
	rm -rf $(BUILD_DIR)/$(CHROMAPRINT_DIR) $(@D)
	$(CHROMAPRINT_UNZIP) $(DL_DIR)/$(CHROMAPRINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CHROMAPRINT_PATCHES)" ; \
		then cat $(CHROMAPRINT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CHROMAPRINT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CHROMAPRINT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CHROMAPRINT_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(CHROMAPRINT_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(CHROMAPRINT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_TOOLS=ON \
		-DFFT_LIB=avfft \
		-DFFMPEG_ROOT=$(STAGING_PREFIX) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(CHROMAPRINT_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(CHROMAPRINT_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(CHROMAPRINT_LDFLAGS)"
	touch $@

chromaprint-unpack: $(CHROMAPRINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHROMAPRINT_BUILD_DIR)/.built: $(CHROMAPRINT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
chromaprint: $(CHROMAPRINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHROMAPRINT_BUILD_DIR)/.staged: $(CHROMAPRINT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

chromaprint-stage: $(CHROMAPRINT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/chromaprint
#
$(CHROMAPRINT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: chromaprint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHROMAPRINT_PRIORITY)" >>$@
	@echo "Section: $(CHROMAPRINT_SECTION)" >>$@
	@echo "Version: $(CHROMAPRINT_VERSION)-$(CHROMAPRINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHROMAPRINT_MAINTAINER)" >>$@
	@echo "Source: $(CHROMAPRINT_REPOSITORY)" >>$@
	@echo "Description: $(CHROMAPRINT_DESCRIPTION)" >>$@
	@echo "Depends: $(CHROMAPRINT_DEPENDS)" >>$@
	@echo "Suggests: $(CHROMAPRINT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CHROMAPRINT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/chromaprint/...
# Documentation files should be installed in $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/doc/chromaprint/...
# Daemon startup scripts should be installed in $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??chromaprint
#
# You may need to patch your application to make it use these locations.
#
$(CHROMAPRINT_IPK): $(CHROMAPRINT_BUILD_DIR)/.built
	rm -rf $(CHROMAPRINT_IPK_DIR) $(BUILD_DIR)/chromaprint_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CHROMAPRINT_BUILD_DIR) DESTDIR=$(CHROMAPRINT_IPK_DIR) install
	$(STRIP_COMMAND) $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/lib/libchromaprint.so \
		$(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/bin/fpcalc
#	$(INSTALL) -d $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(CHROMAPRINT_SOURCE_DIR)/chromaprint.conf $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/chromaprint.conf
#	$(INSTALL) -d $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(CHROMAPRINT_SOURCE_DIR)/rc.chromaprint $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXchromaprint
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHROMAPRINT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXchromaprint
	$(MAKE) $(CHROMAPRINT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(CHROMAPRINT_SOURCE_DIR)/postinst $(CHROMAPRINT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHROMAPRINT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(CHROMAPRINT_SOURCE_DIR)/prerm $(CHROMAPRINT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CHROMAPRINT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CHROMAPRINT_IPK_DIR)/CONTROL/postinst $(CHROMAPRINT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CHROMAPRINT_CONFFILES) | sed -e 's/ /\n/g' > $(CHROMAPRINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CHROMAPRINT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CHROMAPRINT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
chromaprint-ipk: $(CHROMAPRINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
chromaprint-clean:
	rm -f $(CHROMAPRINT_BUILD_DIR)/.built
	-$(MAKE) -C $(CHROMAPRINT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
chromaprint-dirclean:
	rm -rf $(BUILD_DIR)/$(CHROMAPRINT_DIR) $(CHROMAPRINT_BUILD_DIR) $(CHROMAPRINT_IPK_DIR) $(CHROMAPRINT_IPK)
#
#
# Some sanity check for the package.
#
chromaprint-check: $(CHROMAPRINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
