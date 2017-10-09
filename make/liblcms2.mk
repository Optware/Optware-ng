###########################################################
#
# liblcms2
#
###########################################################
#
# LIBLCMS2_VERSION, LIBLCMS2_SITE and LIBLCMS2_SOURCE define
# the upstream location of the source code for the package.
# LIBLCMS2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBLCMS2_UNZIP is the command used to unzip the source.
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
LIBLCMS2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/lcms
LIBLCMS2_VERSION=2.7
LIBLCMS2_SOURCE=lcms2-$(LIBLCMS2_VERSION).tar.gz
LIBLCMS2_DIR=lcms2-$(LIBLCMS2_VERSION)
LIBLCMS2_UNZIP=zcat
LIBLCMS2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBLCMS2_DESCRIPTION=A small-footprint, speed optimized color management engine.
LIBLCMS2_SECTION=graphics
LIBLCMS2_PRIORITY=optional
LIBLCMS2_DEPENDS=libjpeg, libtiff
LIBLCMS2_SUGGESTS=
LIBLCMS2_CONFLICTS=

#
# LIBLCMS2_IPK_VERSION should be incremented when the ipk changes.
#
LIBLCMS2_IPK_VERSION=3

#
# LIBLCMS2_CONFFILES should be a list of user-editable files
#LIBLCMS2_CONFFILES=$(TARGET_PREFIX)/etc/liblcms2.conf $(TARGET_PREFIX)/etc/init.d/SXXliblcms2

#
# LIBLCMS2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBLCMS2_PATCHES=$(LIBLCMS2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBLCMS2_CPPFLAGS=
LIBLCMS2_LDFLAGS=

#
# LIBLCMS2_BUILD_DIR is the directory in which the build is done.
# LIBLCMS2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBLCMS2_IPK_DIR is the directory in which the ipk is built.
# LIBLCMS2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBLCMS2_BUILD_DIR=$(BUILD_DIR)/liblcms2
LIBLCMS2_SOURCE_DIR=$(SOURCE_DIR)/liblcms2
LIBLCMS2_IPK_DIR=$(BUILD_DIR)/liblcms2-$(LIBLCMS2_VERSION)-ipk
LIBLCMS2_IPK=$(BUILD_DIR)/liblcms2_$(LIBLCMS2_VERSION)-$(LIBLCMS2_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBLCMS2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBLCMS2_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
liblcms2-source: $(DL_DIR)/$(LIBLCMS2_SOURCE) $(LIBLCMS2_PATCHES)

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
$(LIBLCMS2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBLCMS2_SOURCE) $(LIBLCMS2_PATCHES) make/liblcms2.mk
	$(MAKE) libjpeg-stage libtiff-stage
	rm -rf $(BUILD_DIR)/$(LIBLCMS2_DIR) $(@D)
	$(LIBLCMS2_UNZIP) $(DL_DIR)/$(LIBLCMS2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBLCMS2_PATCHES)" ; \
		then cat $(LIBLCMS2_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBLCMS2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBLCMS2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBLCMS2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBLCMS2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBLCMS2_LDFLAGS)" \
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

liblcms2-unpack: $(LIBLCMS2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBLCMS2_BUILD_DIR)/.built: $(LIBLCMS2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
liblcms2: $(LIBLCMS2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBLCMS2_BUILD_DIR)/.staged: $(LIBLCMS2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/liblcms2.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/lcms2.pc
	touch $@

liblcms2-stage: $(LIBLCMS2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/liblcms2
#
$(LIBLCMS2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: liblcms2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBLCMS2_PRIORITY)" >>$@
	@echo "Section: $(LIBLCMS2_SECTION)" >>$@
	@echo "Version: $(LIBLCMS2_VERSION)-$(LIBLCMS2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBLCMS2_MAINTAINER)" >>$@
	@echo "Source: $(LIBLCMS2_SITE)/$(LIBLCMS2_SOURCE)" >>$@
	@echo "Description: $(LIBLCMS2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBLCMS2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBLCMS2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBLCMS2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/liblcms2/...
# Documentation files should be installed in $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/doc/liblcms2/...
# Daemon startup scripts should be installed in $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??liblcms2
#
# You may need to patch your application to make it use these locations.
#
$(LIBLCMS2_IPK): $(LIBLCMS2_BUILD_DIR)/.built
	rm -rf $(LIBLCMS2_IPK_DIR) $(BUILD_DIR)/liblcms2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBLCMS2_BUILD_DIR) DESTDIR=$(LIBLCMS2_IPK_DIR) install-strip
#	$(INSTALL) -d $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBLCMS2_SOURCE_DIR)/liblcms2.conf $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/liblcms2.conf
#	$(INSTALL) -d $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBLCMS2_SOURCE_DIR)/rc.liblcms2 $(LIBLCMS2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXliblcms2
	$(MAKE) $(LIBLCMS2_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBLCMS2_SOURCE_DIR)/postinst $(LIBLCMS2_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBLCMS2_SOURCE_DIR)/prerm $(LIBLCMS2_IPK_DIR)/CONTROL/prerm
	echo $(LIBLCMS2_CONFFILES) | sed -e 's/ /\n/g' > $(LIBLCMS2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBLCMS2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
liblcms2-ipk: $(LIBLCMS2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
liblcms2-clean:
	rm -f $(LIBLCMS2_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBLCMS2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
liblcms2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBLCMS2_DIR) $(LIBLCMS2_BUILD_DIR) $(LIBLCMS2_IPK_DIR) $(LIBLCMS2_IPK)

#
# Some sanity check for the package.
#
liblcms2-check: $(LIBLCMS2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
