###########################################################
#
# hrktorrent
#
###########################################################

# You must replace "hrktorrent" and "HRKTORRENT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# HRKTORRENT_VERSION, HRKTORRENT_SITE and HRKTORRENT_SOURCE define
# the upstream location of the source code for the package.
# HRKTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# HRKTORRENT_UNZIP is the command used to unzip the source.
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
HRKTORRENT_SITE=http://50hz.ws/hrktorrent
HRKTORRENT_VERSION=0.3.5
HRKTORRENT_SOURCE=hrktorrent-$(HRKTORRENT_VERSION).tar.bz2
HRKTORRENT_DIR=hrktorrent-$(HRKTORRENT_VERSION)
HRKTORRENT_UNZIP=bzcat
HRKTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HRKTORRENT_DESCRIPTION=hrktorrent is a light console torrent client written in C++, using rasterbar\'s libtorrent. It features DHT, an IP Filter and reads a configuration file at $$HOME/.hrktorrent
HRKTORRENT_SECTION=net
HRKTORRENT_PRIORITY=optional
HRKTORRENT_DEPENDS=libtorrent-rasterbar
HRKTORRENT_SUGGESTS=
HRKTORRENT_CONFLICTS=

#
# HRKTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
HRKTORRENT_IPK_VERSION=1

#
# HRKTORRENT_CONFFILES should be a list of user-editable files
#HRKTORRENT_CONFFILES=/opt/etc/hrktorrent.conf /opt/etc/init.d/SXXhrktorrent

#
# HRKTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HRKTORRENT_PATCHES=$(HRKTORRENT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HRKTORRENT_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libtorrent -DTORRENT_USE_OPENSSL \
		-DWITH_SHIPPED_GEOIP_H -DBOOST_ASIO_HASH_MAP_BUCKETS=1021 -DBOOST_EXCEPTION_DISABLE \
		-DBOOST_ASIO_ENABLE_CANCELIO -DBOOST_ASIO_DYN_LINK -DTORRENT_LINKING_SHARED
HRKTORRENT_LDFLAGS=-ltorrent-rasterbar -lboost_system -lrt -lpthread -lpthread -lssl -lcrypto

#
# HRKTORRENT_BUILD_DIR is the directory in which the build is done.
# HRKTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HRKTORRENT_IPK_DIR is the directory in which the ipk is built.
# HRKTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HRKTORRENT_BUILD_DIR=$(BUILD_DIR)/hrktorrent
HRKTORRENT_SOURCE_DIR=$(SOURCE_DIR)/hrktorrent
HRKTORRENT_IPK_DIR=$(BUILD_DIR)/hrktorrent-$(HRKTORRENT_VERSION)-ipk
HRKTORRENT_IPK=$(BUILD_DIR)/hrktorrent_$(HRKTORRENT_VERSION)-$(HRKTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hrktorrent-source hrktorrent-unpack hrktorrent hrktorrent-stage hrktorrent-ipk hrktorrent-clean hrktorrent-dirclean hrktorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HRKTORRENT_SOURCE):
	$(WGET) -P $(@D) $(HRKTORRENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hrktorrent-source: $(DL_DIR)/$(HRKTORRENT_SOURCE) $(HRKTORRENT_PATCHES)

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
$(HRKTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(HRKTORRENT_SOURCE) $(HRKTORRENT_PATCHES) make/hrktorrent.mk
	$(MAKE) libtorrent-rasterbar-stage
	rm -rf $(BUILD_DIR)/$(HRKTORRENT_DIR) $(@D)
	$(HRKTORRENT_UNZIP) $(DL_DIR)/$(HRKTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HRKTORRENT_PATCHES)" ; \
		then cat $(HRKTORRENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HRKTORRENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HRKTORRENT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HRKTORRENT_DIR) $(@D) ; \
	fi
	sed -i -e "s|^PREFIX.*|PREFIX = /opt|" -e "s|^CXX?.*|CXX = $(TARGET_CXX)|" \
		-e "s|^CXXFLAGS.*|CXXFLAGS = $(STAGING_CPPFLAGS) $(HRKTORRENT_CPPFLAGS)|" \
		-e "s|^LIBS.*|LIBS = $(STAGING_LDFLAGS) $(HRKTORRENT_LDFLAGS)|" $(@D)/vars.mk
	touch $@

hrktorrent-unpack: $(HRKTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HRKTORRENT_BUILD_DIR)/.built: $(HRKTORRENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
hrktorrent: $(HRKTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HRKTORRENT_BUILD_DIR)/.staged: $(HRKTORRENT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

hrktorrent-stage: $(HRKTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hrktorrent
#
$(HRKTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hrktorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HRKTORRENT_PRIORITY)" >>$@
	@echo "Section: $(HRKTORRENT_SECTION)" >>$@
	@echo "Version: $(HRKTORRENT_VERSION)-$(HRKTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HRKTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(HRKTORRENT_SITE)/$(HRKTORRENT_SOURCE)" >>$@
	@echo "Description: $(HRKTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(HRKTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(HRKTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(HRKTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HRKTORRENT_IPK_DIR)/opt/sbin or $(HRKTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HRKTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HRKTORRENT_IPK_DIR)/opt/etc/hrktorrent/...
# Documentation files should be installed in $(HRKTORRENT_IPK_DIR)/opt/doc/hrktorrent/...
# Daemon startup scripts should be installed in $(HRKTORRENT_IPK_DIR)/opt/etc/init.d/S??hrktorrent
#
# You may need to patch your application to make it use these locations.
#
$(HRKTORRENT_IPK): $(HRKTORRENT_BUILD_DIR)/.built
	rm -rf $(HRKTORRENT_IPK_DIR) $(BUILD_DIR)/hrktorrent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HRKTORRENT_BUILD_DIR) DESTDIR=$(HRKTORRENT_IPK_DIR) install-strip
#	install -d $(HRKTORRENT_IPK_DIR)/opt/etc/
#	install -m 644 $(HRKTORRENT_SOURCE_DIR)/hrktorrent.conf $(HRKTORRENT_IPK_DIR)/opt/etc/hrktorrent.conf
#	install -d $(HRKTORRENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HRKTORRENT_SOURCE_DIR)/rc.hrktorrent $(HRKTORRENT_IPK_DIR)/opt/etc/init.d/SXXhrktorrent
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HRKTORRENT_IPK_DIR)/opt/etc/init.d/SXXhrktorrent
	$(MAKE) $(HRKTORRENT_IPK_DIR)/CONTROL/control
#	install -m 755 $(HRKTORRENT_SOURCE_DIR)/postinst $(HRKTORRENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HRKTORRENT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HRKTORRENT_SOURCE_DIR)/prerm $(HRKTORRENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HRKTORRENT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HRKTORRENT_IPK_DIR)/CONTROL/postinst $(HRKTORRENT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HRKTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(HRKTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HRKTORRENT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(HRKTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hrktorrent-ipk: $(HRKTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hrktorrent-clean:
	rm -f $(HRKTORRENT_BUILD_DIR)/.built
	-$(MAKE) -C $(HRKTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hrktorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(HRKTORRENT_DIR) $(HRKTORRENT_BUILD_DIR) $(HRKTORRENT_IPK_DIR) $(HRKTORRENT_IPK)
#
#
# Some sanity check for the package.
#
hrktorrent-check: $(HRKTORRENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
