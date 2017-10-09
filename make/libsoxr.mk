###########################################################
#
# libsoxr
#
###########################################################
#
# LIBSOXR_VERSION, LIBSOXR_SITE and LIBSOXR_SOURCE define
# the upstream location of the source code for the package.
# LIBSOXR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSOXR_UNZIP is the command used to unzip the source.
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
LIBSOXR_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/soxr/$(LIBSOXR_SOURCE)
LIBSOXR_VERSION=0.1.2
LIBSOXR_SOURCE=soxr-$(LIBSOXR_VERSION)-Source.tar.xz
LIBSOXR_DIR=soxr-$(LIBSOXR_VERSION)-Source
LIBSOXR_UNZIP=xzcat
LIBSOXR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSOXR_DESCRIPTION=High quality, one-dimensional sample-rate conversion library.
LIBSOXR_SECTION=libs
LIBSOXR_PRIORITY=optional
LIBSOXR_DEPENDS=
LIBSOXR_SUGGESTS=
LIBSOXR_CONFLICTS=

#
# LIBSOXR_IPK_VERSION should be incremented when the ipk changes.
#
LIBSOXR_IPK_VERSION=3

#
# LIBSOXR_CONFFILES should be a list of user-editable files
#LIBSOXR_CONFFILES=$(TARGET_PREFIX)/etc/libsoxr.conf $(TARGET_PREFIX)/etc/init.d/SXXlibsoxr

#
# LIBSOXR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSOXR_PATCHES=$(LIBSOXR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSOXR_CPPFLAGS=
LIBSOXR_LDFLAGS=

#
# LIBSOXR_BUILD_DIR is the directory in which the build is done.
# LIBSOXR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSOXR_IPK_DIR is the directory in which the ipk is built.
# LIBSOXR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSOXR_BUILD_DIR=$(BUILD_DIR)/libsoxr
LIBSOXR_SOURCE_DIR=$(SOURCE_DIR)/libsoxr
LIBSOXR_IPK_DIR=$(BUILD_DIR)/libsoxr-$(LIBSOXR_VERSION)-ipk
LIBSOXR_IPK=$(BUILD_DIR)/libsoxr_$(LIBSOXR_VERSION)-$(LIBSOXR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libsoxr-source libsoxr-unpack libsoxr libsoxr-stage libsoxr-ipk libsoxr-clean libsoxr-dirclean libsoxr-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBSOXR_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBSOXR_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBSOXR_SOURCE).sha512
#
$(DL_DIR)/$(LIBSOXR_SOURCE):
	$(WGET) -O $@ $(LIBSOXR_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsoxr-source: $(DL_DIR)/$(LIBSOXR_SOURCE) $(LIBSOXR_PATCHES) $(LIBSOXR_SOURCE_DIR)/%.pc

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
$(LIBSOXR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSOXR_SOURCE) $(LIBSOXR_PATCHES) make/libsoxr.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBSOXR_DIR) $(@D)
	$(LIBSOXR_UNZIP) $(DL_DIR)/$(LIBSOXR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSOXR_PATCHES)" ; \
		then cat $(LIBSOXR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBSOXR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSOXR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBSOXR_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBSOXR_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(LIBSOXR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(LIBSOXR_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(LIBSOXR_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBSOXR_LDFLAGS)" \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_STATIC_LIBS=OFF \
		-DBUILD_TESTS=0 \
		-DBUILD_EXAMPLES=0 \
		-DHAVE_WORDS_BIGENDIAN_EXITCODE=`if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; then \
							echo 0; \
						else \
							echo 1; \
						fi;`
	touch $@

libsoxr-unpack: $(LIBSOXR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSOXR_BUILD_DIR)/.built: $(LIBSOXR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libsoxr: $(LIBSOXR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSOXR_BUILD_DIR)/.staged: $(LIBSOXR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	for pkg in soxr soxr-lsr; do \
		sed '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(LIBSOXR_SOURCE_DIR)/$${pkg}.pc > $(STAGING_LIB_DIR)/pkgconfig/$${pkg}.pc; \
	done
	touch $@

libsoxr-stage: $(LIBSOXR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsoxr
#
$(LIBSOXR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libsoxr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSOXR_PRIORITY)" >>$@
	@echo "Section: $(LIBSOXR_SECTION)" >>$@
	@echo "Version: $(LIBSOXR_VERSION)-$(LIBSOXR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSOXR_MAINTAINER)" >>$@
	@echo "Source: $(LIBSOXR_URL)" >>$@
	@echo "Description: $(LIBSOXR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSOXR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSOXR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSOXR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/libsoxr/...
# Documentation files should be installed in $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/doc/libsoxr/...
# Daemon startup scripts should be installed in $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libsoxr
#
# You may need to patch your application to make it use these locations.
#
$(LIBSOXR_IPK): $(LIBSOXR_BUILD_DIR)/.built
	rm -rf $(LIBSOXR_IPK_DIR) $(BUILD_DIR)/libsoxr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSOXR_BUILD_DIR) DESTDIR=$(LIBSOXR_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBSOXR_SOURCE_DIR)/libsoxr.conf $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/libsoxr.conf
#	$(INSTALL) -d $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBSOXR_SOURCE_DIR)/rc.libsoxr $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibsoxr
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSOXR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibsoxr
	$(MAKE) $(LIBSOXR_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBSOXR_SOURCE_DIR)/postinst $(LIBSOXR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSOXR_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBSOXR_SOURCE_DIR)/prerm $(LIBSOXR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSOXR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBSOXR_IPK_DIR)/CONTROL/postinst $(LIBSOXR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBSOXR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSOXR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSOXR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBSOXR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsoxr-ipk: $(LIBSOXR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsoxr-clean:
	rm -f $(LIBSOXR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSOXR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsoxr-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSOXR_DIR) $(LIBSOXR_BUILD_DIR) $(LIBSOXR_IPK_DIR) $(LIBSOXR_IPK)
#
#
# Some sanity check for the package.
#
libsoxr-check: $(LIBSOXR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
