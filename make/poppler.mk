###########################################################
#
# poppler
#
###########################################################
#
# POPPLER_VERSION, POPPLER_SITE and POPPLER_SOURCE define
# the upstream location of the source code for the package.
# POPPLER_DIR is the directory which is created when the source
# archive is unpacked.
# POPPLER_UNZIP is the command used to unzip the source.
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
POPPLER_SITE=http://poppler.freedesktop.org
POPPLER_VERSION=0.47.0
POPPLER_SOURCE=poppler-$(POPPLER_VERSION).tar.xz
POPPLER_DIR=poppler-$(POPPLER_VERSION)
POPPLER_UNZIP=xzcat
POPPLER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POPPLER_DESCRIPTION=The Poppler package contains a PDF rendering library and command line tools used to manipulate PDF files.
LIBPOPPLER_DESCRIPTION=Poppler PDF rendering library.
LIBPOPPLER_DEV_DESCRIPTION=Poppler PDF rendering library development files.
POPPLER_SECTION=misc
LIBPOPPLER_SECTION=lib
LIBPOPPLER_DEV_SECTION=dev
POPPLER_PRIORITY=optional
LIBPOPPLER_PRIORITY=optional
LIBPOPPLER_DEV_PRIORITY=optional
POPPLER_DEPENDS=libpoppler
LIBPOPPLER_DEPENDS=fontconfig, libcurl, libjpeg, libpng, liblcms2, libstdc++, openjpeg, zlib, libtiff
LIBPOPPLER_DEV_DEPENDS=libpoppler
ifneq ($(filter libiconv, $(PACKAGES)), )
POPPLER_DEPENDS +=, libiconv
endif
POPPLER_SUGGESTS=
POPPLER_CONFLICTS=

#
# POPPLER_IPK_VERSION should be incremented when the ipk changes.
#
POPPLER_IPK_VERSION=3

#
# POPPLER_CONFFILES should be a list of user-editable files
#POPPLER_CONFFILES=$(TARGET_PREFIX)/etc/poppler.conf $(TARGET_PREFIX)/etc/init.d/SXXpoppler

#
# POPPLER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#POPPLER_PATCHES=$(POPPLER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POPPLER_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/freetype2
POPPLER_LDFLAGS=

#
# POPPLER_BUILD_DIR is the directory in which the build is done.
# POPPLER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POPPLER_IPK_DIR is the directory in which the ipk is built.
# POPPLER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POPPLER_BUILD_DIR=$(BUILD_DIR)/poppler
POPPLER_SOURCE_DIR=$(SOURCE_DIR)/poppler

POPPLER_IPK_DIR=$(BUILD_DIR)/poppler-$(POPPLER_VERSION)-ipk
POPPLER_IPK=$(BUILD_DIR)/poppler_$(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBPOPPLER_IPK_DIR=$(BUILD_DIR)/libpoppler-$(POPPLER_VERSION)-ipk
LIBPOPPLER_IPK=$(BUILD_DIR)/libpoppler_$(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBPOPPLER_DEV_IPK_DIR=$(BUILD_DIR)/libpoppler-dev-$(POPPLER_VERSION)-ipk
LIBPOPPLER_DEV_IPK=$(BUILD_DIR)/libpoppler-dev_$(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: poppler-source poppler-unpack poppler poppler-stage poppler-ipk poppler-clean poppler-dirclean poppler-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POPPLER_SOURCE):
	$(WGET) -P $(@D) $(POPPLER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
poppler-source: $(DL_DIR)/$(POPPLER_SOURCE) $(POPPLER_PATCHES)

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
$(POPPLER_BUILD_DIR)/.configured: $(DL_DIR)/$(POPPLER_SOURCE) $(POPPLER_PATCHES) make/poppler.mk
	$(MAKE) fontconfig-stage libcurl-stage \
		libjpeg-stage liblcms2-stage libpng-stage libstdc++-stage \
		openjpeg-stage zlib-stage libtiff-stage
ifneq ($(filter libiconv, $(PACKAGES)), )
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(POPPLER_DIR) $(@D)
	$(POPPLER_UNZIP) $(DL_DIR)/$(POPPLER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POPPLER_PATCHES)" ; \
		then cat $(POPPLER_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(POPPLER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(POPPLER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(POPPLER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POPPLER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POPPLER_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-libcurl \
		--enable-libopenjpeg=openjpeg1 \
		--enable-zlib \
		--enable-libtiff \
		--enable-xpdf-headers \
		--enable-splash-output \
		--disable-poppler-glib \
		--disable-cairo-output \
		--disable-introspection \
		--disable-nss \
		--disable-gtk-test \
		--disable-nls \
		--disable-static \
		--disable-poppler-qt4 \
		--disable-poppler-qt5 \
		--without-x \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

poppler-unpack: $(POPPLER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POPPLER_BUILD_DIR)/.built: $(POPPLER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
poppler: $(POPPLER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POPPLER_BUILD_DIR)/.staged: $(POPPLER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpoppler{,-cpp}.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/poppler{,-cpp}.pc
	touch $@

poppler-stage: $(POPPLER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/poppler
#
$(POPPLER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: poppler" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POPPLER_PRIORITY)" >>$@
	@echo "Section: $(POPPLER_SECTION)" >>$@
	@echo "Version: $(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POPPLER_MAINTAINER)" >>$@
	@echo "Source: $(POPPLER_SITE)/$(POPPLER_SOURCE)" >>$@
	@echo "Description: $(POPPLER_DESCRIPTION)" >>$@
	@echo "Depends: $(POPPLER_DEPENDS)" >>$@
	@echo "Suggests: $(POPPLER_SUGGESTS)" >>$@
	@echo "Conflicts: $(POPPLER_CONFLICTS)" >>$@

$(LIBPOPPLER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libpoppler" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPOPPLER_PRIORITY)" >>$@
	@echo "Section: $(LIBPOPPLER_SECTION)" >>$@
	@echo "Version: $(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POPPLER_MAINTAINER)" >>$@
	@echo "Source: $(POPPLER_SITE)/$(POPPLER_SOURCE)" >>$@
	@echo "Description: $(LIBPOPPLER_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPOPPLER_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPOPPLER_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPOPPLER_CONFLICTS)" >>$@

$(LIBPOPPLER_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libpoppler-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPOPPLER_DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBPOPPLER_DEV_SECTION)" >>$@
	@echo "Version: $(POPPLER_VERSION)-$(POPPLER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POPPLER_MAINTAINER)" >>$@
	@echo "Source: $(POPPLER_SITE)/$(POPPLER_SOURCE)" >>$@
	@echo "Description: $(LIBPOPPLER_DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPOPPLER_DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPOPPLER_DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPOPPLER_DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/poppler/...
# Documentation files should be installed in $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/doc/poppler/...
# Daemon startup scripts should be installed in $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??poppler
#
# You may need to patch your application to make it use these locations.
#
$(POPPLER_IPK) $(LIBPOPPLER_IPK) $(LIBPOPPLER_DEV_IPK): $(POPPLER_BUILD_DIR)/.built
	rm -rf  $(POPPLER_IPK_DIR) $(BUILD_DIR)/poppler_*_$(TARGET_ARCH).ipk \
		$(LIBPOPPLER_IPK_DIR) $(BUILD_DIR)/libpoppler_*_$(TARGET_ARCH).ipk \
		$(LIBPOPPLER_DEV_IPK_DIR) $(BUILD_DIR)/libpoppler-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POPPLER_BUILD_DIR) DESTDIR=$(POPPLER_IPK_DIR) install-strip
#	$(INSTALL) -d $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(POPPLER_SOURCE_DIR)/poppler.conf $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/poppler.conf
#	$(INSTALL) -d $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(POPPLER_SOURCE_DIR)/rc.poppler $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXpoppler
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXpoppler
	$(INSTALL) -d $(LIBPOPPLER_IPK_DIR)$(TARGET_PREFIX)
	mv -f $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/lib $(LIBPOPPLER_IPK_DIR)$(TARGET_PREFIX)
	$(INSTALL) -d $(LIBPOPPLER_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(LIBPOPPLER_IPK_DIR)$(TARGET_PREFIX)/lib/{*.so,pkgconfig} $(LIBPOPPLER_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(POPPLER_IPK_DIR)$(TARGET_PREFIX)/include $(LIBPOPPLER_DEV_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(POPPLER_IPK_DIR)/CONTROL/control $(LIBPOPPLER_IPK_DIR)/CONTROL/control \
		$(LIBPOPPLER_DEV_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(POPPLER_SOURCE_DIR)/postinst $(POPPLER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(POPPLER_SOURCE_DIR)/prerm $(POPPLER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(POPPLER_IPK_DIR)/CONTROL/postinst $(POPPLER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(POPPLER_CONFFILES) | sed -e 's/ /\n/g' > $(POPPLER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POPPLER_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPOPPLER_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPOPPLER_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(POPPLER_IPK_DIR) $(LIBPOPPLER_IPK_DIR) $(LIBPOPPLER_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
poppler-ipk: $(POPPLER_IPK) $(LIBPOPPLER_IPK) $(LIBPOPPLER_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
poppler-clean:
	rm -f $(POPPLER_BUILD_DIR)/.built
	-$(MAKE) -C $(POPPLER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
poppler-dirclean:
	rm -rf  $(BUILD_DIR)/$(POPPLER_DIR) $(POPPLER_BUILD_DIR) \
		$(POPPLER_IPK_DIR) $(POPPLER_IPK) \
		$(LIBPOPPLER_IPK_DIR) $(LIBPOPPLER_IPK) \
		$(LIBPOPPLER_DEV_IPK_DIR) $(LIBPOPPLER_DEV_IPK)
#
#
# Some sanity check for the package.
#
poppler-check: $(POPPLER_IPK) $(LIBPOPPLER_IPK) $(LIBPOPPLER_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
