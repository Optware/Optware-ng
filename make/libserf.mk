###########################################################
#
# libserf
#
###########################################################
#
# LIBSERF_VERSION, LIBSERF_SITE and LIBSERF_SOURCE define
# the upstream location of the source code for the package.
# LIBSERF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSERF_UNZIP is the command used to unzip the source.
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
LIBSERF_URL=https://archive.apache.org/dist/serf/$(LIBSERF_SOURCE)
LIBSERF_VERSION=1.3.8
LIBSERF_SOURCE=serf-$(LIBSERF_VERSION).tar.bz2
LIBSERF_DIR=serf-$(LIBSERF_VERSION)
LIBSERF_UNZIP=bzcat
LIBSERF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSERF_DESCRIPTION=Serf library is a C-based HTTP client library built upon the Apache Portable Runtime (APR) library.
LIBSERF_SECTION=libs
LIBSERF_PRIORITY=optional
LIBSERF_DEPENDS=apr, apr-util, openssl, zlib
LIBSERF_SUGGESTS=
LIBSERF_CONFLICTS=

#
# LIBSERF_IPK_VERSION should be incremented when the ipk changes.
#
LIBSERF_IPK_VERSION=3

#
# LIBSERF_CONFFILES should be a list of user-editable files
#LIBSERF_CONFFILES=$(TARGET_PREFIX)/etc/libserf.conf $(TARGET_PREFIX)/etc/init.d/SXXlibserf

#
# LIBSERF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBSERF_PATCHES=$(LIBSERF_SOURCE_DIR)/disable.auto-rpath.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSERF_CPPFLAGS=
LIBSERF_LDFLAGS=

LIBSERF_SCONS_VARS=\
		CC=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSERF_CPPFLAGS)" \
		LINKFLAGS="$(STAGING_LDFLAGS) $(LIBSERF_LDFLAGS)" \
		PREFIX=$(TARGET_PREFIX) \
		APU=$(STAGING_PREFIX)/bin/apu-1-config \
		APR=$(STAGING_PREFIX)/bin/apr-1-config \
		OPENSSL=$(STAGING_PREFIX) \
		ZLIB=$(STAGING_PREFIX) \

#
# LIBSERF_BUILD_DIR is the directory in which the build is done.
# LIBSERF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSERF_IPK_DIR is the directory in which the ipk is built.
# LIBSERF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSERF_BUILD_DIR=$(BUILD_DIR)/libserf
LIBSERF_SOURCE_DIR=$(SOURCE_DIR)/libserf
LIBSERF_IPK_DIR=$(BUILD_DIR)/libserf-$(LIBSERF_VERSION)-ipk
LIBSERF_IPK=$(BUILD_DIR)/libserf_$(LIBSERF_VERSION)-$(LIBSERF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libserf-source libserf-unpack libserf libserf-stage libserf-ipk libserf-clean libserf-dirclean libserf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBSERF_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBSERF_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBSERF_SOURCE).sha512
#
$(DL_DIR)/$(LIBSERF_SOURCE):
	$(WGET) -O $@ $(LIBSERF_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libserf-source: $(DL_DIR)/$(LIBSERF_SOURCE) $(LIBSERF_PATCHES)

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
$(LIBSERF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSERF_SOURCE) $(LIBSERF_PATCHES) make/libserf.mk
	$(MAKE) apr-stage apr-util-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBSERF_DIR) $(@D)
	$(LIBSERF_UNZIP) $(DL_DIR)/$(LIBSERF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSERF_PATCHES)" ; \
		then cat $(LIBSERF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBSERF_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSERF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBSERF_DIR) $(@D) ; \
	fi
	touch $@

libserf-unpack: $(LIBSERF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSERF_BUILD_DIR)/.built: $(LIBSERF_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); \
		scons $(LIBSERF_SCONS_VARS)
	touch $@

#
# This is the build convenience target.
#
libserf: $(LIBSERF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSERF_BUILD_DIR)/.staged: $(LIBSERF_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_LIB_DIR)/libserf-1.*
	cd $(@D); \
		scons install -j1 $(LIBSERF_SCONS_VARS) PREFIX=$(STAGING_PREFIX)
	rm -f $(STAGING_LIB_DIR)/libserf-1.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' -e '/^libdir=/s|=.*|=$(STAGING_LIB_DIR)|' \
			$(STAGING_LIB_DIR)/pkgconfig/serf-1.pc
	touch $@

libserf-stage: $(LIBSERF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libserf
#
$(LIBSERF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libserf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSERF_PRIORITY)" >>$@
	@echo "Section: $(LIBSERF_SECTION)" >>$@
	@echo "Version: $(LIBSERF_VERSION)-$(LIBSERF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSERF_MAINTAINER)" >>$@
	@echo "Source: $(LIBSERF_URL)" >>$@
	@echo "Description: $(LIBSERF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSERF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSERF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSERF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/libserf/...
# Documentation files should be installed in $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/doc/libserf/...
# Daemon startup scripts should be installed in $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libserf
#
# You may need to patch your application to make it use these locations.
#
$(LIBSERF_IPK): $(LIBSERF_BUILD_DIR)/.built
	rm -rf $(LIBSERF_IPK_DIR) $(BUILD_DIR)/libserf_*_$(TARGET_ARCH).ipk
	cd $(LIBSERF_BUILD_DIR); \
		scons install -j1 $(LIBSERF_SCONS_VARS) PREFIX=$(LIBSERF_IPK_DIR)$(TARGET_PREFIX)
	rm -f $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/lib/libserf-1.a
	$(STRIP_COMMAND) $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBSERF_SOURCE_DIR)/libserf.conf $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/libserf.conf
#	$(INSTALL) -d $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBSERF_SOURCE_DIR)/rc.libserf $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibserf
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSERF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibserf
	$(MAKE) $(LIBSERF_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBSERF_SOURCE_DIR)/postinst $(LIBSERF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSERF_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBSERF_SOURCE_DIR)/prerm $(LIBSERF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSERF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBSERF_IPK_DIR)/CONTROL/postinst $(LIBSERF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBSERF_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSERF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSERF_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBSERF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libserf-ipk: $(LIBSERF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libserf-clean:
	rm -f $(LIBSERF_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSERF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libserf-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSERF_DIR) $(LIBSERF_BUILD_DIR) $(LIBSERF_IPK_DIR) $(LIBSERF_IPK)
#
#
# Some sanity check for the package.
#
libserf-check: $(LIBSERF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
