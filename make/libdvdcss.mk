###########################################################
#
# libdvdcss
#
###########################################################
#
# LIBDVDCSS_VERSION, LIBDVDCSS_SITE and LIBDVDCSS_SOURCE define
# the upstream location of the source code for the package.
# LIBDVDCSS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDVDCSS_UNZIP is the command used to unzip the source.
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
LIBDVDCSS_VERSION=1.2.9
LIBDVDCSS_SITE=http://download.videolan.org/pub/videolan/libdvdcss/$(LIBDVDCSS_VERSION)
LIBDVDCSS_SOURCE=libdvdcss-$(LIBDVDCSS_VERSION).tar.bz2
LIBDVDCSS_DIR=libdvdcss-$(LIBDVDCSS_VERSION)
LIBDVDCSS_UNZIP=bzcat
LIBDVDCSS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDVDCSS_DESCRIPTION=A portable abstraction library for DVD decryption.
LIBDVDCSS_SECTION=lib
LIBDVDCSS_PRIORITY=optional
LIBDVDCSS_DEPENDS=
LIBDVDCSS_SUGGESTS=
LIBDVDCSS_CONFLICTS=

#
# LIBDVDCSS_IPK_VERSION should be incremented when the ipk changes.
#
LIBDVDCSS_IPK_VERSION=1

#
# LIBDVDCSS_CONFFILES should be a list of user-editable files
#LIBDVDCSS_CONFFILES=/opt/etc/libdvdcss.conf /opt/etc/init.d/SXXlibdvdcss

#
# LIBDVDCSS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDVDCSS_PATCHES=$(LIBDVDCSS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDVDCSS_CPPFLAGS=
LIBDVDCSS_LDFLAGS=

#
# LIBDVDCSS_BUILD_DIR is the directory in which the build is done.
# LIBDVDCSS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDVDCSS_IPK_DIR is the directory in which the ipk is built.
# LIBDVDCSS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDVDCSS_BUILD_DIR=$(BUILD_DIR)/libdvdcss
LIBDVDCSS_SOURCE_DIR=$(SOURCE_DIR)/libdvdcss
LIBDVDCSS_IPK_DIR=$(BUILD_DIR)/libdvdcss-$(LIBDVDCSS_VERSION)-ipk
LIBDVDCSS_IPK=$(BUILD_DIR)/libdvdcss_$(LIBDVDCSS_VERSION)-$(LIBDVDCSS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdvdcss-source libdvdcss-unpack libdvdcss libdvdcss-stage libdvdcss-ipk libdvdcss-clean libdvdcss-dirclean libdvdcss-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDVDCSS_SOURCE):
	$(WGET) -P $(@D) $(LIBDVDCSS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdvdcss-source: $(DL_DIR)/$(LIBDVDCSS_SOURCE) $(LIBDVDCSS_PATCHES)

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
$(LIBDVDCSS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDVDCSS_SOURCE) $(LIBDVDCSS_PATCHES) make/libdvdcss.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDVDCSS_DIR) $(@D)
	$(LIBDVDCSS_UNZIP) $(DL_DIR)/$(LIBDVDCSS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDVDCSS_PATCHES)" ; \
		then cat $(LIBDVDCSS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDVDCSS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDVDCSS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBDVDCSS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDVDCSS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDVDCSS_LDFLAGS)" \
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

libdvdcss-unpack: $(LIBDVDCSS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDVDCSS_BUILD_DIR)/.built: $(LIBDVDCSS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libdvdcss: $(LIBDVDCSS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDVDCSS_BUILD_DIR)/.staged: $(LIBDVDCSS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libdvdcss-stage: $(LIBDVDCSS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdvdcss
#
$(LIBDVDCSS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdvdcss" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDVDCSS_PRIORITY)" >>$@
	@echo "Section: $(LIBDVDCSS_SECTION)" >>$@
	@echo "Version: $(LIBDVDCSS_VERSION)-$(LIBDVDCSS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDVDCSS_MAINTAINER)" >>$@
	@echo "Source: $(LIBDVDCSS_SITE)/$(LIBDVDCSS_SOURCE)" >>$@
	@echo "Description: $(LIBDVDCSS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDVDCSS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDVDCSS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDVDCSS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDVDCSS_IPK_DIR)/opt/sbin or $(LIBDVDCSS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDVDCSS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDVDCSS_IPK_DIR)/opt/etc/libdvdcss/...
# Documentation files should be installed in $(LIBDVDCSS_IPK_DIR)/opt/doc/libdvdcss/...
# Daemon startup scripts should be installed in $(LIBDVDCSS_IPK_DIR)/opt/etc/init.d/S??libdvdcss
#
# You may need to patch your application to make it use these locations.
#
$(LIBDVDCSS_IPK): $(LIBDVDCSS_BUILD_DIR)/.built
	rm -rf $(LIBDVDCSS_IPK_DIR) $(BUILD_DIR)/libdvdcss_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDVDCSS_BUILD_DIR) DESTDIR=$(LIBDVDCSS_IPK_DIR) install-strip
#	install -d $(LIBDVDCSS_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBDVDCSS_SOURCE_DIR)/libdvdcss.conf $(LIBDVDCSS_IPK_DIR)/opt/etc/libdvdcss.conf
#	install -d $(LIBDVDCSS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBDVDCSS_SOURCE_DIR)/rc.libdvdcss $(LIBDVDCSS_IPK_DIR)/opt/etc/init.d/SXXlibdvdcss
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDCSS_IPK_DIR)/opt/etc/init.d/SXXlibdvdcss
	$(MAKE) $(LIBDVDCSS_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBDVDCSS_SOURCE_DIR)/postinst $(LIBDVDCSS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDCSS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBDVDCSS_SOURCE_DIR)/prerm $(LIBDVDCSS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDCSS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBDVDCSS_IPK_DIR)/CONTROL/postinst $(LIBDVDCSS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBDVDCSS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDVDCSS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDVDCSS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdvdcss-ipk: $(LIBDVDCSS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdvdcss-clean:
	rm -f $(LIBDVDCSS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDVDCSS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdvdcss-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDVDCSS_DIR) $(LIBDVDCSS_BUILD_DIR) $(LIBDVDCSS_IPK_DIR) $(LIBDVDCSS_IPK)
#
#
# Some sanity check for the package.
#
libdvdcss-check: $(LIBDVDCSS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBDVDCSS_IPK)
