###########################################################
#
# exif
#
###########################################################
#
# EXIF_VERSION, EXIF_SITE and EXIF_SOURCE define
# the upstream location of the source code for the package.
# EXIF_DIR is the directory which is created when the source
# archive is unpacked.
# EXIF_UNZIP is the command used to unzip the source.
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
EXIF_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libexif
EXIF_VERSION=0.6.19
EXIF_SOURCE=exif-$(EXIF_VERSION).tar.bz2
EXIF_DIR=exif-$(EXIF_VERSION)
EXIF_UNZIP=bzcat
EXIF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EXIF_DESCRIPTION=A small command-line utility to show and change EXIF information in JPEG files.
EXIF_SECTION=tool
EXIF_PRIORITY=optional
EXIF_DEPENDS=libexif, popt
EXIF_SUGGESTS=
EXIF_CONFLICTS=

#
# EXIF_IPK_VERSION should be incremented when the ipk changes.
#
EXIF_IPK_VERSION=1

#
# EXIF_CONFFILES should be a list of user-editable files
#EXIF_CONFFILES=/opt/etc/exif.conf /opt/etc/init.d/SXXexif

#
# EXIF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#EXIF_PATCHES=$(EXIF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXIF_CPPFLAGS=
EXIF_LDFLAGS=

#
# EXIF_BUILD_DIR is the directory in which the build is done.
# EXIF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXIF_IPK_DIR is the directory in which the ipk is built.
# EXIF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXIF_BUILD_DIR=$(BUILD_DIR)/exif
EXIF_SOURCE_DIR=$(SOURCE_DIR)/exif
EXIF_IPK_DIR=$(BUILD_DIR)/exif-$(EXIF_VERSION)-ipk
EXIF_IPK=$(BUILD_DIR)/exif_$(EXIF_VERSION)-$(EXIF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: exif-source exif-unpack exif exif-stage exif-ipk exif-clean exif-dirclean exif-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EXIF_SOURCE):
	$(WGET) -P $(@D) $(EXIF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
exif-source: $(DL_DIR)/$(EXIF_SOURCE) $(EXIF_PATCHES)

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
$(EXIF_BUILD_DIR)/.configured: $(DL_DIR)/$(EXIF_SOURCE) $(EXIF_PATCHES) make/exif.mk
	$(MAKE) libexif-stage popt-stage
	rm -rf $(BUILD_DIR)/$(EXIF_DIR) $(@D)
	$(EXIF_UNZIP) $(DL_DIR)/$(EXIF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EXIF_PATCHES)" ; \
		then cat $(EXIF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EXIF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EXIF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(EXIF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXIF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXIF_LDFLAGS)" \
		LIBEXIF_CFLAGS="$(STAGING_CPPFLAGS)" \
		LIBEXIF_LIBS="$(STAGING_LDFLAGS) -lexif" \
		POPT_CFLAGS="$(STAGING_CPPFLAGS)" \
		POPT_LIBS="$(STAGING_LDFLAGS) -lpopt" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

exif-unpack: $(EXIF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EXIF_BUILD_DIR)/.built: $(EXIF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
exif: $(EXIF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EXIF_BUILD_DIR)/.staged: $(EXIF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

exif-stage: $(EXIF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/exif
#
$(EXIF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: exif" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EXIF_PRIORITY)" >>$@
	@echo "Section: $(EXIF_SECTION)" >>$@
	@echo "Version: $(EXIF_VERSION)-$(EXIF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EXIF_MAINTAINER)" >>$@
	@echo "Source: $(EXIF_SITE)/$(EXIF_SOURCE)" >>$@
	@echo "Description: $(EXIF_DESCRIPTION)" >>$@
	@echo "Depends: $(EXIF_DEPENDS)" >>$@
	@echo "Suggests: $(EXIF_SUGGESTS)" >>$@
	@echo "Conflicts: $(EXIF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXIF_IPK_DIR)/opt/sbin or $(EXIF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXIF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EXIF_IPK_DIR)/opt/etc/exif/...
# Documentation files should be installed in $(EXIF_IPK_DIR)/opt/doc/exif/...
# Daemon startup scripts should be installed in $(EXIF_IPK_DIR)/opt/etc/init.d/S??exif
#
# You may need to patch your application to make it use these locations.
#
$(EXIF_IPK): $(EXIF_BUILD_DIR)/.built
	rm -rf $(EXIF_IPK_DIR) $(BUILD_DIR)/exif_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EXIF_BUILD_DIR) DESTDIR=$(EXIF_IPK_DIR) install-strip
#	install -d $(EXIF_IPK_DIR)/opt/etc/
#	install -m 644 $(EXIF_SOURCE_DIR)/exif.conf $(EXIF_IPK_DIR)/opt/etc/exif.conf
#	install -d $(EXIF_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(EXIF_SOURCE_DIR)/rc.exif $(EXIF_IPK_DIR)/opt/etc/init.d/SXXexif
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXIF_IPK_DIR)/opt/etc/init.d/SXXexif
	$(MAKE) $(EXIF_IPK_DIR)/CONTROL/control
#	install -m 755 $(EXIF_SOURCE_DIR)/postinst $(EXIF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXIF_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(EXIF_SOURCE_DIR)/prerm $(EXIF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(EXIF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(EXIF_IPK_DIR)/CONTROL/postinst $(EXIF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(EXIF_CONFFILES) | sed -e 's/ /\n/g' > $(EXIF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXIF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
exif-ipk: $(EXIF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
exif-clean:
	rm -f $(EXIF_BUILD_DIR)/.built
	-$(MAKE) -C $(EXIF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
exif-dirclean:
	rm -rf $(BUILD_DIR)/$(EXIF_DIR) $(EXIF_BUILD_DIR) $(EXIF_IPK_DIR) $(EXIF_IPK)
#
#
# Some sanity check for the package.
#
exif-check: $(EXIF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
