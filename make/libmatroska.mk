###########################################################
#
# libmatroska
#
###########################################################
#
# LIBMATROSKA_VERSION, LIBMATROSKA_SITE and LIBMATROSKA_SOURCE define
# the upstream location of the source code for the package.
# LIBMATROSKA_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMATROSKA_UNZIP is the command used to unzip the source.
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
LIBMATROSKA_SITE=http://bunkus.org/videotools/mkvtoolnix/sources
LIBMATROSKA_VERSION=1.4.2
LIBMATROSKA_SOURCE=libmatroska-$(LIBMATROSKA_VERSION).tar.bz2
LIBMATROSKA_DIR=libmatroska-$(LIBMATROSKA_VERSION)
LIBMATROSKA_UNZIP=bzcat
LIBMATROSKA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMATROSKA_DESCRIPTION=lib to access Matroska (an extensible open standard Audio/Video container format)
LIBMATROSKA_SECTION=libs
LIBMATROSKA_PRIORITY=optional
LIBMATROSKA_DEPENDS=libebml
LIBMATROSKA_SUGGESTS=
LIBMATROSKA_CONFLICTS=

#
# LIBMATROSKA_IPK_VERSION should be incremented when the ipk changes.
#
LIBMATROSKA_IPK_VERSION=2

#
# LIBMATROSKA_CONFFILES should be a list of user-editable files
#LIBMATROSKA_CONFFILES=$(TARGET_PREFIX)/etc/libmatroska.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmatroska

#
# LIBMATROSKA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMATROSKA_PATCHES=$(LIBMATROSKA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMATROSKA_CPPFLAGS=
LIBMATROSKA_LDFLAGS=

#
# LIBMATROSKA_BUILD_DIR is the directory in which the build is done.
# LIBMATROSKA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMATROSKA_IPK_DIR is the directory in which the ipk is built.
# LIBMATROSKA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMATROSKA_BUILD_DIR=$(BUILD_DIR)/libmatroska
LIBMATROSKA_SOURCE_DIR=$(SOURCE_DIR)/libmatroska
LIBMATROSKA_IPK_DIR=$(BUILD_DIR)/libmatroska-$(LIBMATROSKA_VERSION)-ipk
LIBMATROSKA_IPK=$(BUILD_DIR)/libmatroska_$(LIBMATROSKA_VERSION)-$(LIBMATROSKA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmatroska-source libmatroska-unpack libmatroska libmatroska-stage libmatroska-ipk libmatroska-clean libmatroska-dirclean libmatroska-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMATROSKA_SOURCE):
	$(WGET) -P $(@D) $(LIBMATROSKA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmatroska-source: $(DL_DIR)/$(LIBMATROSKA_SOURCE) $(LIBMATROSKA_PATCHES)

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
$(LIBMATROSKA_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMATROSKA_SOURCE) $(LIBMATROSKA_PATCHES) make/libmatroska.mk
	$(MAKE) libebml-stage
	rm -rf $(BUILD_DIR)/$(LIBMATROSKA_DIR) $(@D)
	rm -rf $(STAGING_INCLUDE_DIR)/matroska $(STAGING_LIB_DIR)/libmatroska*
	$(LIBMATROSKA_UNZIP) $(DL_DIR)/$(LIBMATROSKA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMATROSKA_PATCHES)" ; \
		then cat $(LIBMATROSKA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMATROSKA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMATROSKA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMATROSKA_DIR) $(@D) ; \
	fi
#	sed -i -e 's|-shared|$$(LDFLAGS) &|' $(@D)/make/linux/Makefile
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMATROSKA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMATROSKA_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmatroska-unpack: $(LIBMATROSKA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMATROSKA_BUILD_DIR)/.built: $(LIBMATROSKA_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)/make/linux \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMATROSKA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMATROSKA_LDFLAGS)" \
		prefix=$(TARGET_PREFIX)
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmatroska: $(LIBMATROSKA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMATROSKA_BUILD_DIR)/.staged: $(LIBMATROSKA_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D)/make/linux install_sharedlib install_headers \
		DESTDIR=$(STAGING_DIR) \
		prefix=$(STAGING_PREFIX)
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmatroska.pc
	rm -f $(STAGING_LIB_DIR)/libmatroska.la
	touch $@

libmatroska-stage: $(LIBMATROSKA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmatroska
#
$(LIBMATROSKA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmatroska" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMATROSKA_PRIORITY)" >>$@
	@echo "Section: $(LIBMATROSKA_SECTION)" >>$@
	@echo "Version: $(LIBMATROSKA_VERSION)-$(LIBMATROSKA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMATROSKA_MAINTAINER)" >>$@
	@echo "Source: $(LIBMATROSKA_SITE)/$(LIBMATROSKA_SOURCE)" >>$@
	@echo "Description: $(LIBMATROSKA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMATROSKA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMATROSKA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMATROSKA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/etc/libmatroska/...
# Documentation files should be installed in $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/doc/libmatroska/...
# Daemon startup scripts should be installed in $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmatroska
#
# You may need to patch your application to make it use these locations.
#
$(LIBMATROSKA_IPK): $(LIBMATROSKA_BUILD_DIR)/.built
	rm -rf $(LIBMATROSKA_IPK_DIR) $(BUILD_DIR)/libmatroska_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(LIBMATROSKA_BUILD_DIR)/make/linux install_sharedlib \
		DESTDIR=$(LIBMATROSKA_IPK_DIR) \
		prefix=$(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) -C $(LIBMATROSKA_BUILD_DIR) install DESTDIR=$(LIBMATROSKA_IPK_DIR)
	rm -f $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/lib/libmatroska.la
	$(STRIP_COMMAND) $(LIBMATROSKA_IPK_DIR)$(TARGET_PREFIX)/lib/libmatroska.so.*
	$(MAKE) $(LIBMATROSKA_IPK_DIR)/CONTROL/control
	echo $(LIBMATROSKA_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMATROSKA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMATROSKA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmatroska-ipk: $(LIBMATROSKA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmatroska-clean:
	rm -f $(LIBMATROSKA_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMATROSKA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmatroska-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMATROSKA_DIR) $(LIBMATROSKA_BUILD_DIR) $(LIBMATROSKA_IPK_DIR) $(LIBMATROSKA_IPK)
#
#
# Some sanity check for the package.
#
libmatroska-check: $(LIBMATROSKA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
