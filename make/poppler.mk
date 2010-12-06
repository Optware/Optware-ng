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
POPPLER_VERSION=0.14.5
POPPLER_SOURCE=poppler-$(POPPLER_VERSION).tar.gz
POPPLER_DIR=poppler-$(POPPLER_VERSION)
POPPLER_UNZIP=zcat
POPPLER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POPPLER_DESCRIPTION=Poppler is a PDF rendering library.
POPPLER_SECTION=misc
POPPLER_PRIORITY=optional
POPPLER_DEPENDS=fontconfig, freetype, libcurl, libpng, liblcms, libxml2, libstdc++, openjpeg, zlib
POPPLER_SUGGESTS=
POPPLER_CONFLICTS=

#
# POPPLER_IPK_VERSION should be incremented when the ipk changes.
#
POPPLER_IPK_VERSION=1

#
# POPPLER_CONFFILES should be a list of user-editable files
#POPPLER_CONFFILES=/opt/etc/poppler.conf /opt/etc/init.d/SXXpoppler

#
# POPPLER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#POPPLER_PATCHES=$(POPPLER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POPPLER_CPPFLAGS=
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
	$(MAKE) fontconfig-stage freetype-stage libcurl-stage \
		libjpeg-stage liblcms-stage libpng-stage libstdc++-stage \
		openjpeg-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(POPPLER_DIR) $(@D)
	$(POPPLER_UNZIP) $(DL_DIR)/$(POPPLER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POPPLER_PATCHES)" ; \
		then cat $(POPPLER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(POPPLER_DIR) -p0 ; \
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
		--prefix=/opt \
		--enable-libcurl \
		--enable-libopenjpeg \
		--enable-zlib \
		--disable-poppler-glib \
		--disable-gdk \
		--disable-gtk-test \
		--disable-splash-output \
		--disable-nls \
		--disable-static \
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
	touch $@

poppler-stage: $(POPPLER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/poppler
#
$(POPPLER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(POPPLER_IPK_DIR)/opt/sbin or $(POPPLER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POPPLER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POPPLER_IPK_DIR)/opt/etc/poppler/...
# Documentation files should be installed in $(POPPLER_IPK_DIR)/opt/doc/poppler/...
# Daemon startup scripts should be installed in $(POPPLER_IPK_DIR)/opt/etc/init.d/S??poppler
#
# You may need to patch your application to make it use these locations.
#
$(POPPLER_IPK): $(POPPLER_BUILD_DIR)/.built
	rm -rf $(POPPLER_IPK_DIR) $(BUILD_DIR)/poppler_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POPPLER_BUILD_DIR) DESTDIR=$(POPPLER_IPK_DIR) install-strip
#	install -d $(POPPLER_IPK_DIR)/opt/etc/
#	install -m 644 $(POPPLER_SOURCE_DIR)/poppler.conf $(POPPLER_IPK_DIR)/opt/etc/poppler.conf
#	install -d $(POPPLER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(POPPLER_SOURCE_DIR)/rc.poppler $(POPPLER_IPK_DIR)/opt/etc/init.d/SXXpoppler
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)/opt/etc/init.d/SXXpoppler
	$(MAKE) $(POPPLER_IPK_DIR)/CONTROL/control
#	install -m 755 $(POPPLER_SOURCE_DIR)/postinst $(POPPLER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(POPPLER_SOURCE_DIR)/prerm $(POPPLER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POPPLER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(POPPLER_IPK_DIR)/CONTROL/postinst $(POPPLER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(POPPLER_CONFFILES) | sed -e 's/ /\n/g' > $(POPPLER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POPPLER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
poppler-ipk: $(POPPLER_IPK)

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
	rm -rf $(BUILD_DIR)/$(POPPLER_DIR) $(POPPLER_BUILD_DIR) $(POPPLER_IPK_DIR) $(POPPLER_IPK)
#
#
# Some sanity check for the package.
#
poppler-check: $(POPPLER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
