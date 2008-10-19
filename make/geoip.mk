###########################################################
#
# geoip
#
###########################################################
#
# GEOIP_VERSION, GEOIP_SITE and GEOIP_SOURCE define
# the upstream location of the source code for the package.
# GEOIP_DIR is the directory which is created when the source
# archive is unpacked.
# GEOIP_UNZIP is the command used to unzip the source.
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
GEOIP_SITE=http://www.maxmind.com/download/geoip/api/c
GEOIP_VERSION=1.4.5
GEOIP_SOURCE=GeoIP-$(GEOIP_VERSION).tar.gz
GEOIP_DIR=GeoIP-$(GEOIP_VERSION)
GEOIP_UNZIP=zcat
GEOIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GEOIP_DESCRIPTION=API and example lookup program to determine country, state/region, city, etc. from IP addresses.
GEOIP_SECTION=utils
GEOIP_PRIORITY=optional
GEOIP_DEPENDS=
GEOIP_SUGGESTS=
GEOIP_CONFLICTS=

#
# GEOIP_IPK_VERSION should be incremented when the ipk changes.
#
GEOIP_IPK_VERSION=1

#
# GEOIP_CONFFILES should be a list of user-editable files
#GEOIP_CONFFILES=/opt/etc/geoip.conf /opt/etc/init.d/SXXgeoip

#
# GEOIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GEOIP_PATCHES=$(GEOIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GEOIP_CPPFLAGS=
GEOIP_LDFLAGS=

#
# GEOIP_BUILD_DIR is the directory in which the build is done.
# GEOIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GEOIP_IPK_DIR is the directory in which the ipk is built.
# GEOIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GEOIP_BUILD_DIR=$(BUILD_DIR)/geoip
GEOIP_SOURCE_DIR=$(SOURCE_DIR)/geoip
GEOIP_IPK_DIR=$(BUILD_DIR)/geoip-$(GEOIP_VERSION)-ipk
GEOIP_IPK=$(BUILD_DIR)/geoip_$(GEOIP_VERSION)-$(GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: geoip-source geoip-unpack geoip geoip-stage geoip-ipk geoip-clean geoip-dirclean geoip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GEOIP_SOURCE):
	$(WGET) -P $(@D) $(GEOIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
geoip-source: $(DL_DIR)/$(GEOIP_SOURCE) $(GEOIP_PATCHES)

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
$(GEOIP_BUILD_DIR)/.configured: $(DL_DIR)/$(GEOIP_SOURCE) $(GEOIP_PATCHES) make/geoip.mk
#	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(GEOIP_DIR) $(@D)
	$(GEOIP_UNZIP) $(DL_DIR)/$(GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GEOIP_PATCHES)" ; \
		then cat $(GEOIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GEOIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GEOIP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GEOIP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GEOIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GEOIP_LDFLAGS)" \
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

geoip-unpack: $(GEOIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GEOIP_BUILD_DIR)/.built: $(GEOIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
geoip: $(GEOIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GEOIP_BUILD_DIR)/.staged: $(GEOIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libGeoIP*.la
	touch $@

geoip-stage: $(GEOIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/geoip
#
$(GEOIP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GEOIP_PRIORITY)" >>$@
	@echo "Section: $(GEOIP_SECTION)" >>$@
	@echo "Version: $(GEOIP_VERSION)-$(GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(GEOIP_SITE)/$(GEOIP_SOURCE)" >>$@
	@echo "Description: $(GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(GEOIP_DEPENDS)" >>$@
	@echo "Suggests: $(GEOIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(GEOIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GEOIP_IPK_DIR)/opt/sbin or $(GEOIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GEOIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GEOIP_IPK_DIR)/opt/etc/geoip/...
# Documentation files should be installed in $(GEOIP_IPK_DIR)/opt/doc/geoip/...
# Daemon startup scripts should be installed in $(GEOIP_IPK_DIR)/opt/etc/init.d/S??geoip
#
# You may need to patch your application to make it use these locations.
#
$(GEOIP_IPK): $(GEOIP_BUILD_DIR)/.built
	rm -rf $(GEOIP_IPK_DIR) $(BUILD_DIR)/geoip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GEOIP_BUILD_DIR) DESTDIR=$(GEOIP_IPK_DIR) install
	$(STRIP_COMMAND) $(GEOIP_IPK_DIR)/opt/bin/geoip* $(GEOIP_IPK_DIR)/opt/lib/libGeoIP*.so*
	$(MAKE) $(GEOIP_IPK_DIR)/CONTROL/control
	echo $(GEOIP_CONFFILES) | sed -e 's/ /\n/g' > $(GEOIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GEOIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
geoip-ipk: $(GEOIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
geoip-clean:
	rm -f $(GEOIP_BUILD_DIR)/.built
	-$(MAKE) -C $(GEOIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
geoip-dirclean:
	rm -rf $(BUILD_DIR)/$(GEOIP_DIR) $(GEOIP_BUILD_DIR) $(GEOIP_IPK_DIR) $(GEOIP_IPK)
#
#
# Some sanity check for the package.
#
geoip-check: $(GEOIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GEOIP_IPK)
