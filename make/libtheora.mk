###########################################################
#
# libtheora
#
###########################################################
#
# LIBTHEORA_VERSION, LIBTHEORA_SITE and LIBTHEORA_SOURCE define
# the upstream location of the source code for the package.
# LIBTHEORA_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTHEORA_UNZIP is the command used to unzip the source.
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
LIBTHEORA_SITE=http://downloads.xiph.org/releases/theora
LIBTHEORA_VERSION=1.1.1
LIBTHEORA_SOURCE=libtheora-$(LIBTHEORA_VERSION).tar.bz2
LIBTHEORA_DIR=libtheora-$(LIBTHEORA_VERSION)
LIBTHEORA_UNZIP=bzcat
LIBTHEORA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTHEORA_DESCRIPTION=A free and open video compression format from the Xiph.org Foundation.
LIBTHEORA_SECTION=lib
LIBTHEORA_PRIORITY=optional
LIBTHEORA_DEPENDS=libogg
LIBTHEORA_SUGGESTS=
LIBTHEORA_CONFLICTS=

#
# LIBTHEORA_IPK_VERSION should be incremented when the ipk changes.
#
LIBTHEORA_IPK_VERSION=1

#
# LIBTHEORA_CONFFILES should be a list of user-editable files
#LIBTHEORA_CONFFILES=$(TARGET_PREFIX)/etc/libtheora.conf $(TARGET_PREFIX)/etc/init.d/SXXlibtheora

#
# LIBTHEORA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBTHEORA_PATCHES=$(LIBTHEORA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTHEORA_CPPFLAGS=
LIBTHEORA_LDFLAGS=

#
# LIBTHEORA_BUILD_DIR is the directory in which the build is done.
# LIBTHEORA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTHEORA_IPK_DIR is the directory in which the ipk is built.
# LIBTHEORA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTHEORA_BUILD_DIR=$(BUILD_DIR)/libtheora
LIBTHEORA_SOURCE_DIR=$(SOURCE_DIR)/libtheora
LIBTHEORA_IPK_DIR=$(BUILD_DIR)/libtheora-$(LIBTHEORA_VERSION)-ipk
LIBTHEORA_IPK=$(BUILD_DIR)/libtheora_$(LIBTHEORA_VERSION)-$(LIBTHEORA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtheora-source libtheora-unpack libtheora libtheora-stage libtheora-ipk libtheora-clean libtheora-dirclean libtheora-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTHEORA_SOURCE):
	$(WGET) -P $(@D) $(LIBTHEORA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtheora-source: $(DL_DIR)/$(LIBTHEORA_SOURCE) $(LIBTHEORA_PATCHES)

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
$(LIBTHEORA_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTHEORA_SOURCE) $(LIBTHEORA_PATCHES) make/libtheora.mk
	$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(LIBTHEORA_DIR) $(@D)
	$(LIBTHEORA_UNZIP) $(DL_DIR)/$(LIBTHEORA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTHEORA_PATCHES)" ; \
		then cat $(LIBTHEORA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBTHEORA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTHEORA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBTHEORA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTHEORA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTHEORA_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-examples \
		$(if $(filter i686, $(TARGET_ARCH)),--enable-float,--disable--float) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtheora-unpack: $(LIBTHEORA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTHEORA_BUILD_DIR)/.built: $(LIBTHEORA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libtheora: $(LIBTHEORA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTHEORA_BUILD_DIR)/.staged: $(LIBTHEORA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libtheora*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/theora*.pc
	touch $@

libtheora-stage: $(LIBTHEORA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtheora
#
$(LIBTHEORA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libtheora" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTHEORA_PRIORITY)" >>$@
	@echo "Section: $(LIBTHEORA_SECTION)" >>$@
	@echo "Version: $(LIBTHEORA_VERSION)-$(LIBTHEORA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTHEORA_MAINTAINER)" >>$@
	@echo "Source: $(LIBTHEORA_SITE)/$(LIBTHEORA_SOURCE)" >>$@
	@echo "Description: $(LIBTHEORA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTHEORA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTHEORA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTHEORA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/libtheora/...
# Documentation files should be installed in $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/doc/libtheora/...
# Daemon startup scripts should be installed in $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libtheora
#
# You may need to patch your application to make it use these locations.
#
$(LIBTHEORA_IPK): $(LIBTHEORA_BUILD_DIR)/.built
	rm -rf $(LIBTHEORA_IPK_DIR) $(BUILD_DIR)/libtheora_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTHEORA_BUILD_DIR) DESTDIR=$(LIBTHEORA_IPK_DIR) install-strip
#	$(INSTALL) -d $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBTHEORA_SOURCE_DIR)/libtheora.conf $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/libtheora.conf
#	$(INSTALL) -d $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBTHEORA_SOURCE_DIR)/rc.libtheora $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtheora
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTHEORA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtheora
	$(MAKE) $(LIBTHEORA_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBTHEORA_SOURCE_DIR)/postinst $(LIBTHEORA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTHEORA_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBTHEORA_SOURCE_DIR)/prerm $(LIBTHEORA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTHEORA_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBTHEORA_IPK_DIR)/CONTROL/postinst $(LIBTHEORA_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBTHEORA_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTHEORA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTHEORA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtheora-ipk: $(LIBTHEORA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtheora-clean:
	rm -f $(LIBTHEORA_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBTHEORA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtheora-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTHEORA_DIR) $(LIBTHEORA_BUILD_DIR) $(LIBTHEORA_IPK_DIR) $(LIBTHEORA_IPK)
#
#
# Some sanity check for the package.
#
libtheora-check: $(LIBTHEORA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
