###########################################################
#
# libhid
#
###########################################################
#
# LIBHID_VERSION, LIBHID_SITE and LIBHID_SOURCE define
# the upstream location of the source code for the package.
# LIBHID_DIR is the directory which is created when the source
# archive is unpacked.
# LIBHID_UNZIP is the command used to unzip the source.
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
LIBHID_SITE=https://alioth.debian.org/frs/download.php/1958
LIBHID_VERSION=0.2.16
LIBHID_SOURCE=libhid-$(LIBHID_VERSION).tar.gz
LIBHID_DIR=libhid-$(LIBHID_VERSION)
LIBHID_UNZIP=zcat
LIBHID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBHID_DESCRIPTION=libhid provides a generic and flexible way to access and interact with USB HID devices
LIBHID_SECTION=lib
LIBHID_PRIORITY=optional
LIBHID_DEPENDS=libusb
LIBHID_SUGGESTS=
LIBHID_CONFLICTS=

#
# LIBHID_IPK_VERSION should be incremented when the ipk changes.
#
LIBHID_IPK_VERSION=2

#
# LIBHID_CONFFILES should be a list of user-editable files
#LIBHID_CONFFILES=/opt/etc/libhid.conf /opt/etc/init.d/SXXlibhid

#
# LIBHID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBHID_PATCHES=$(LIBHID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBHID_CPPFLAGS=
LIBHID_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
LIBHID_SWIG_ENV=SWIG="$(HOST_STAGING_PREFIX)/bin/swig" SWIG_LIB="$(HOST_STAGING_PREFIX)/share/swig/$(SWIG_VERSION)"
endif

#
# LIBHID_BUILD_DIR is the directory in which the build is done.
# LIBHID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBHID_IPK_DIR is the directory in which the ipk is built.
# LIBHID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBHID_BUILD_DIR=$(BUILD_DIR)/libhid
LIBHID_SOURCE_DIR=$(SOURCE_DIR)/libhid
LIBHID_IPK_DIR=$(BUILD_DIR)/libhid-$(LIBHID_VERSION)-ipk
LIBHID_IPK=$(BUILD_DIR)/libhid_$(LIBHID_VERSION)-$(LIBHID_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libhid-source libhid-unpack libhid libhid-stage libhid-ipk libhid-clean libhid-dirclean libhid-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBHID_SOURCE):
	$(WGET) --no-check-certificate -P $(@D) $(LIBHID_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libhid-source: $(DL_DIR)/$(LIBHID_SOURCE) $(LIBHID_PATCHES)

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
$(LIBHID_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBHID_SOURCE) $(LIBHID_PATCHES) make/libhid.mk
	$(MAKE) libusb-stage
	rm -rf $(BUILD_DIR)/$(LIBHID_DIR) $(@D)
	$(LIBHID_UNZIP) $(DL_DIR)/$(LIBHID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBHID_PATCHES)" ; \
		then cat $(LIBHID_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBHID_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBHID_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBHID_DIR) $(@D) ; \
	fi
	sed -i -e '/LDFLAGS=.*OS_LDFLAGS/s|$$| $$LDFLAGS)|' \
	       -e '/^ $$LDFLAGS)$$/d' \
		$(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBHID_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBHID_LDFLAGS)" \
		PKG_CONFIG="$(STAGING_LIB_DIR)/pkgconfig" \
		bash ./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-swig \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libhid-unpack: $(LIBHID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBHID_BUILD_DIR)/.built: $(LIBHID_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) # $(LIBHID_SWIG_ENV)
	touch $@

#
# This is the build convenience target.
#
libhid: $(LIBHID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBHID_BUILD_DIR)/.staged: $(LIBHID_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR)
	rm -f $(STAGING_LIB_DIR)/libhid.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libhid.pc
	touch $@

libhid-stage: $(LIBHID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libhid
#
$(LIBHID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libhid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBHID_PRIORITY)" >>$@
	@echo "Section: $(LIBHID_SECTION)" >>$@
	@echo "Version: $(LIBHID_VERSION)-$(LIBHID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBHID_MAINTAINER)" >>$@
	@echo "Source: $(LIBHID_SITE)/$(LIBHID_SOURCE)" >>$@
	@echo "Description: $(LIBHID_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBHID_DEPENDS)" >>$@
	@echo "Suggests: $(LIBHID_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBHID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBHID_IPK_DIR)/opt/sbin or $(LIBHID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBHID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBHID_IPK_DIR)/opt/etc/libhid/...
# Documentation files should be installed in $(LIBHID_IPK_DIR)/opt/doc/libhid/...
# Daemon startup scripts should be installed in $(LIBHID_IPK_DIR)/opt/etc/init.d/S??libhid
#
# You may need to patch your application to make it use these locations.
#
$(LIBHID_IPK): $(LIBHID_BUILD_DIR)/.built
	rm -rf $(LIBHID_IPK_DIR) $(BUILD_DIR)/libhid_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBHID_BUILD_DIR) DESTDIR=$(LIBHID_IPK_DIR) install-strip
#	install -d $(LIBHID_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBHID_SOURCE_DIR)/libhid.conf $(LIBHID_IPK_DIR)/opt/etc/libhid.conf
#	install -d $(LIBHID_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBHID_SOURCE_DIR)/rc.libhid $(LIBHID_IPK_DIR)/opt/etc/init.d/SXXlibhid
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBHID_IPK_DIR)/opt/etc/init.d/SXXlibhid
	$(MAKE) $(LIBHID_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBHID_SOURCE_DIR)/postinst $(LIBHID_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBHID_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBHID_SOURCE_DIR)/prerm $(LIBHID_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBHID_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBHID_IPK_DIR)/CONTROL/postinst $(LIBHID_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBHID_CONFFILES) | sed -e 's/ /\n/g' > $(LIBHID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBHID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libhid-ipk: $(LIBHID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libhid-clean:
	rm -f $(LIBHID_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBHID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libhid-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBHID_DIR) $(LIBHID_BUILD_DIR) $(LIBHID_IPK_DIR) $(LIBHID_IPK)
#
#
# Some sanity check for the package.
#
libhid-check: $(LIBHID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
