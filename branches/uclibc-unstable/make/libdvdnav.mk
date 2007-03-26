###########################################################
#
# libdvdnav
#
###########################################################
#
# LIBDVDNAV_VERSION, LIBDVDNAV_SITE and LIBDVDNAV_SOURCE define
# the upstream location of the source code for the package.
# LIBDVDNAV_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDVDNAV_UNZIP is the command used to unzip the source.
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
LIBDVDNAV_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dvd
LIBDVDNAV_VERSION=0.1.10
LIBDVDNAV_SOURCE=libdvdnav-$(LIBDVDNAV_VERSION).tar.gz
LIBDVDNAV_DIR=libdvdnav-$(LIBDVDNAV_VERSION)
LIBDVDNAV_UNZIP=zcat
LIBDVDNAV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDVDNAV_DESCRIPTION=dvdnav
LIBDVDNAV_SECTION=multimedia
LIBDVDNAV_PRIORITY=optional
LIBDVDNAV_DEPENDS=
LIBDVDNAV_SUGGESTS=
LIBDVDNAV_CONFLICTS=

#
# LIBDVDNAV_IPK_VERSION should be incremented when the ipk changes.
#
LIBDVDNAV_IPK_VERSION=1

#
# LIBDVDNAV_CONFFILES should be a list of user-editable files
#LIBDVDNAV_CONFFILES=/opt/etc/libdvdnav.conf /opt/etc/init.d/SXXlibdvdnav

#
# LIBDVDNAV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDVDNAV_PATCHES=$(LIBDVDNAV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDVDNAV_CPPFLAGS=
LIBDVDNAV_LDFLAGS=

#
# LIBDVDNAV_BUILD_DIR is the directory in which the build is done.
# LIBDVDNAV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDVDNAV_IPK_DIR is the directory in which the ipk is built.
# LIBDVDNAV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDVDNAV_BUILD_DIR=$(BUILD_DIR)/libdvdnav
LIBDVDNAV_SOURCE_DIR=$(SOURCE_DIR)/libdvdnav
LIBDVDNAV_IPK_DIR=$(BUILD_DIR)/libdvdnav-$(LIBDVDNAV_VERSION)-ipk
LIBDVDNAV_IPK=$(BUILD_DIR)/libdvdnav_$(LIBDVDNAV_VERSION)-$(LIBDVDNAV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdvdnav-source libdvdnav-unpack libdvdnav libdvdnav-stage libdvdnav-ipk libdvdnav-clean libdvdnav-dirclean libdvdnav-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDVDNAV_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDVDNAV_SITE)/$(LIBDVDNAV_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBDVDNAV_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdvdnav-source: $(DL_DIR)/$(LIBDVDNAV_SOURCE) $(LIBDVDNAV_PATCHES)

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
$(LIBDVDNAV_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDVDNAV_SOURCE) $(LIBDVDNAV_PATCHES) make/libdvdnav.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDVDNAV_DIR) $(LIBDVDNAV_BUILD_DIR)
	$(LIBDVDNAV_UNZIP) $(DL_DIR)/$(LIBDVDNAV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDVDNAV_PATCHES)" ; \
		then cat $(LIBDVDNAV_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDVDNAV_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDVDNAV_DIR)" != "$(LIBDVDNAV_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBDVDNAV_DIR) $(LIBDVDNAV_BUILD_DIR) ; \
	fi
	(cd $(LIBDVDNAV_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDVDNAV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDVDNAV_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBDVDNAV_BUILD_DIR)/libtool
	touch $@

libdvdnav-unpack: $(LIBDVDNAV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDVDNAV_BUILD_DIR)/.built: $(LIBDVDNAV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBDVDNAV_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libdvdnav: $(LIBDVDNAV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDVDNAV_BUILD_DIR)/.staged: $(LIBDVDNAV_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBDVDNAV_BUILD_DIR) DESTDIR=$(STAGING_DIR) transform="" install
	rm -f $(STAGING_LIB_DIR)/libdvdnav.la
	sed -ie 's|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|g' $(STAGING_PREFIX)/bin/dvdnav-config
	touch $@

libdvdnav-stage: $(LIBDVDNAV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdvdnav
#
$(LIBDVDNAV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdvdnav" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDVDNAV_PRIORITY)" >>$@
	@echo "Section: $(LIBDVDNAV_SECTION)" >>$@
	@echo "Version: $(LIBDVDNAV_VERSION)-$(LIBDVDNAV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDVDNAV_MAINTAINER)" >>$@
	@echo "Source: $(LIBDVDNAV_SITE)/$(LIBDVDNAV_SOURCE)" >>$@
	@echo "Description: $(LIBDVDNAV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDVDNAV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDVDNAV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDVDNAV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDVDNAV_IPK_DIR)/opt/sbin or $(LIBDVDNAV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDVDNAV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDVDNAV_IPK_DIR)/opt/etc/libdvdnav/...
# Documentation files should be installed in $(LIBDVDNAV_IPK_DIR)/opt/doc/libdvdnav/...
# Daemon startup scripts should be installed in $(LIBDVDNAV_IPK_DIR)/opt/etc/init.d/S??libdvdnav
#
# You may need to patch your application to make it use these locations.
#
$(LIBDVDNAV_IPK): $(LIBDVDNAV_BUILD_DIR)/.built
	rm -rf $(LIBDVDNAV_IPK_DIR) $(BUILD_DIR)/libdvdnav_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDVDNAV_BUILD_DIR) DESTDIR=$(LIBDVDNAV_IPK_DIR) transform="" install-strip
	rm -f $(LIBDVDNAV_IPK_DIR)/opt/lib/libdvdnav.la
#	install -d $(LIBDVDNAV_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBDVDNAV_SOURCE_DIR)/libdvdnav.conf $(LIBDVDNAV_IPK_DIR)/opt/etc/libdvdnav.conf
#	install -d $(LIBDVDNAV_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBDVDNAV_SOURCE_DIR)/rc.libdvdnav $(LIBDVDNAV_IPK_DIR)/opt/etc/init.d/SXXlibdvdnav
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDNAV_IPK_DIR)/opt/etc/init.d/SXXlibdvdnav
	$(MAKE) $(LIBDVDNAV_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBDVDNAV_SOURCE_DIR)/postinst $(LIBDVDNAV_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDNAV_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBDVDNAV_SOURCE_DIR)/prerm $(LIBDVDNAV_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDVDNAV_IPK_DIR)/CONTROL/prerm
	echo $(LIBDVDNAV_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDVDNAV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDVDNAV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdvdnav-ipk: $(LIBDVDNAV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdvdnav-clean:
	rm -f $(LIBDVDNAV_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDVDNAV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdvdnav-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDVDNAV_DIR) $(LIBDVDNAV_BUILD_DIR) $(LIBDVDNAV_IPK_DIR) $(LIBDVDNAV_IPK)
#
#
# Some sanity check for the package.
#
libdvdnav-check: $(LIBDVDNAV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBDVDNAV_IPK)
