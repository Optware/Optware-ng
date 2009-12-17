###########################################################
#
# libmms
#
###########################################################
#
# LIBMMS_VERSION, LIBMMS_SITE and LIBMMS_SOURCE define
# the upstream location of the source code for the package.
# LIBMMS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMMS_UNZIP is the command used to unzip the source.
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
LIBMMS_VERSION=0.5
LIBMMS_SITE=http://launchpad.net/libmms/trunk/$(LIBMMS_VERSION)/+download
LIBMMS_SOURCE=libmms-$(LIBMMS_VERSION).tar.gz
LIBMMS_DIR=libmms-$(LIBMMS_VERSION)
LIBMMS_UNZIP=zcat
LIBMMS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMMS_DESCRIPTION=A common library for parsing mms:// and mmsh:// type network streams
LIBMMS_SECTION=audio
LIBMMS_PRIORITY=optional
LIBMMS_DEPENDS=glib
LIBMMS_SUGGESTS=
LIBMMS_CONFLICTS=

#
# LIBMMS_IPK_VERSION should be incremented when the ipk changes.
#
LIBMMS_IPK_VERSION=1

#
# LIBMMS_CONFFILES should be a list of user-editable files
#LIBMMS_CONFFILES=/opt/etc/libmms.conf /opt/etc/init.d/SXXlibmms

#
# LIBMMS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMMS_PATCHES=$(LIBMMS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMMS_CPPFLAGS=
LIBMMS_LDFLAGS=

#
# LIBMMS_BUILD_DIR is the directory in which the build is done.
# LIBMMS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMMS_IPK_DIR is the directory in which the ipk is built.
# LIBMMS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMMS_BUILD_DIR=$(BUILD_DIR)/libmms
LIBMMS_SOURCE_DIR=$(SOURCE_DIR)/libmms
LIBMMS_IPK_DIR=$(BUILD_DIR)/libmms-$(LIBMMS_VERSION)-ipk
LIBMMS_IPK=$(BUILD_DIR)/libmms_$(LIBMMS_VERSION)-$(LIBMMS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmms-source libmms-unpack libmms libmms-stage libmms-ipk libmms-clean libmms-dirclean libmms-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMMS_SOURCE):
	$(WGET) -P $(@D) $(LIBMMS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmms-source: $(DL_DIR)/$(LIBMMS_SOURCE) $(LIBMMS_PATCHES)

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
$(LIBMMS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMMS_SOURCE) $(LIBMMS_PATCHES) make/libmms.mk
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(LIBMMS_DIR) $(@D)
	$(LIBMMS_UNZIP) $(DL_DIR)/$(LIBMMS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMMS_PATCHES)" ; \
		then cat $(LIBMMS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMMS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMMS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMMS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMMS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMMS_LDFLAGS)" \
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

libmms-unpack: $(LIBMMS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMMS_BUILD_DIR)/.built: $(LIBMMS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmms: $(LIBMMS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMMS_BUILD_DIR)/.staged: $(LIBMMS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmms.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmms.pc
	touch $@

libmms-stage: $(LIBMMS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmms
#
$(LIBMMS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmms" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMMS_PRIORITY)" >>$@
	@echo "Section: $(LIBMMS_SECTION)" >>$@
	@echo "Version: $(LIBMMS_VERSION)-$(LIBMMS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMMS_MAINTAINER)" >>$@
	@echo "Source: $(LIBMMS_SITE)/$(LIBMMS_SOURCE)" >>$@
	@echo "Description: $(LIBMMS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMMS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMMS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMMS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMMS_IPK_DIR)/opt/sbin or $(LIBMMS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMMS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMMS_IPK_DIR)/opt/etc/libmms/...
# Documentation files should be installed in $(LIBMMS_IPK_DIR)/opt/doc/libmms/...
# Daemon startup scripts should be installed in $(LIBMMS_IPK_DIR)/opt/etc/init.d/S??libmms
#
# You may need to patch your application to make it use these locations.
#
$(LIBMMS_IPK): $(LIBMMS_BUILD_DIR)/.built
	rm -rf $(LIBMMS_IPK_DIR) $(BUILD_DIR)/libmms_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMMS_BUILD_DIR) DESTDIR=$(LIBMMS_IPK_DIR) install-strip
#	install -d $(LIBMMS_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMMS_SOURCE_DIR)/libmms.conf $(LIBMMS_IPK_DIR)/opt/etc/libmms.conf
#	install -d $(LIBMMS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMMS_SOURCE_DIR)/rc.libmms $(LIBMMS_IPK_DIR)/opt/etc/init.d/SXXlibmms
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMMS_IPK_DIR)/opt/etc/init.d/SXXlibmms
	$(MAKE) $(LIBMMS_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMMS_SOURCE_DIR)/postinst $(LIBMMS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMMS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMMS_SOURCE_DIR)/prerm $(LIBMMS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMMS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMMS_IPK_DIR)/CONTROL/postinst $(LIBMMS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBMMS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMMS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMMS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmms-ipk: $(LIBMMS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmms-clean:
	rm -f $(LIBMMS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMMS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmms-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMMS_DIR) $(LIBMMS_BUILD_DIR) $(LIBMMS_IPK_DIR) $(LIBMMS_IPK)
#
#
# Some sanity check for the package.
#
libmms-check: $(LIBMMS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
