###########################################################
#
# libtorrent-rasterbar
#
###########################################################

# You must replace "libtorrent-rasterbar" and "LIBTORRENT-RASTERBAR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTORRENT-RASTERBAR_VERSION, LIBTORRENT-RASTERBAR_SITE and LIBTORRENT-RASTERBAR_SOURCE define
# the upstream location of the source code for the package.
# LIBTORRENT-RASTERBAR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTORRENT-RASTERBAR_UNZIP is the command used to unzip the source.
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
LIBTORRENT-RASTERBAR_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libtorrent
LIBTORRENT-RASTERBAR_VERSION=0.14.1
LIBTORRENT-RASTERBAR_SOURCE=libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION).tar.gz
LIBTORRENT-RASTERBAR_DIR=libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION)
LIBTORRENT-RASTERBAR_UNZIP=zcat
LIBTORRENT-RASTERBAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTORRENT-RASTERBAR_DESCRIPTION=libtorrent rasterbar.
LIBTORRENT-RASTERBAR_SECTION=net
LIBTORRENT-RASTERBAR_PRIORITY=optional
LIBTORRENT-RASTERBAR_DEPENDS= openssl, boost-system, boost-filesystem, boost-date-time, boost-thread
LIBTORRENT-RASTERBAR_SUGGESTS=
LIBTORRENT-RASTERBAR_CONFLICTS=

#
# LIBTORRENT-RASTERBAR_IPK_VERSION should be incremented when the ipk changes.
#
LIBTORRENT-RASTERBAR_IPK_VERSION=1

#
# LIBTORRENT-RASTERBAR_CONFFILES should be a list of user-editable files
#LIBTORRENT-RASTERBAR_CONFFILES=/opt/etc/libtorrent-rasterbar.conf /opt/etc/init.d/SXXlibtorrent-rasterbar

#
# LIBTORRENT-RASTERBAR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBTORRENT-RASTERBAR_PATCHES=$(LIBTORRENT-RASTERBAR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTORRENT-RASTERBAR_CPPFLAGS=
LIBTORRENT-RASTERBAR_LDFLAGS=
LIBTORRENT-RASTERBAR_BOOST_CPPFLAGS=$(STAGING_CPPFLAGS)
LIBTORRENT-RASTERBAR_BOOST_LDFLAGS= -lboost_system-mt -lboost_filesystem-mt -lboost_date_time-mt -lboost_thread-mt

#
# LIBTORRENT-RASTERBAR_BUILD_DIR is the directory in which the build is done.
# LIBTORRENT-RASTERBAR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTORRENT-RASTERBAR_IPK_DIR is the directory in which the ipk is built.
# LIBTORRENT-RASTERBAR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTORRENT-RASTERBAR_BUILD_DIR=$(BUILD_DIR)/libtorrent-rasterbar
LIBTORRENT-RASTERBAR_SOURCE_DIR=$(SOURCE_DIR)/libtorrent-rasterbar
LIBTORRENT-RASTERBAR_IPK_DIR=$(BUILD_DIR)/libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION)-ipk
LIBTORRENT-RASTERBAR_IPK=$(BUILD_DIR)/libtorrent-rasterbar_$(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtorrent-rasterbar-source libtorrent-rasterbar-unpack libtorrent-rasterbar libtorrent-rasterbar-stage libtorrent-rasterbar-ipk libtorrent-rasterbar-clean libtorrent-rasterbar-dirclean libtorrent-rasterbar-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE):
	$(WGET) -P $(@D) $(LIBTORRENT-RASTERBAR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtorrent-rasterbar-source: $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) $(LIBTORRENT-RASTERBAR_PATCHES)

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
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) $(LIBTORRENT-RASTERBAR_PATCHES) make/libtorrent-rasterbar.mk
	$(MAKE) boost-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(@D)
	$(LIBTORRENT-RASTERBAR_UNZIP) $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTORRENT-RASTERBAR_PATCHES)" ; \
		then cat $(LIBTORRENT-RASTERBAR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(@D) ; \
	fi
	sed -i -e "s|/usr/local/ssl /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr|$(STAGING_DIR)/opt|" $(@D)/m4/check_ssl.m4
	sed -i -e "s|/usr/local/ssl\n                            /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr|$(STAGING_DIR)/opt|" $(@D)/m4/check_ssl.m4
	sed -i -e "s|/usr /usr/local /opt /opt/local|$(STAGING_DIR)/opt|" $(@D)/m4/ax_boost_base-fixed.m4
	sed -i -e "s|/usr/include|$(STAGING_DIR)/opt/include|" $(@D)/m4/ax_boost_python-fixed.m4
	sed -i -e "s|namespace libtorrent|#ifndef IPV6_V6ONLY\n#  define IPV6_V6ONLY 26\n#endif\n\nnamespace libtorrent|" $(@D)/include/libtorrent/socket.hpp
	sed -i -e "s|namespace libtorrent { namespace|#ifndef IPV6_V6ONLY\n#  define IPV6_V6ONLY 26\n#endif\n\nnamespace libtorrent { namespace|" $(@D)/src/enum_net.cpp
	autoreconf -vif $(@D)
	sed -i -e "s|/usr/include|$(STAGING_DIR)/opt/include|" $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT-RASTERBAR_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT-RASTERBAR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTORRENT-RASTERBAR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ssl \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtorrent-rasterbar-unpack: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libtorrent-rasterbar: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.staged: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libtorrent-rasterbar-stage: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtorrent-rasterbar
#
$(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libtorrent-rasterbar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT-RASTERBAR_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT-RASTERBAR_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT-RASTERBAR_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT-RASTERBAR_SITE)/$(LIBTORRENT-RASTERBAR_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT-RASTERBAR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT-RASTERBAR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT-RASTERBAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT-RASTERBAR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/sbin or $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/libtorrent-rasterbar/...
# Documentation files should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/doc/libtorrent-rasterbar/...
# Daemon startup scripts should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/init.d/S??libtorrent-rasterbar
#
# You may need to patch your application to make it use these locations.
#
$(LIBTORRENT-RASTERBAR_IPK): $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT-RASTERBAR_IPK_DIR) $(BUILD_DIR)/libtorrent-rasterbar_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTORRENT-RASTERBAR_BUILD_DIR) DESTDIR=$(LIBTORRENT-RASTERBAR_IPK_DIR) install-strip
#	install -d $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/libtorrent-rasterbar.conf $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/libtorrent-rasterbar.conf
#	install -d $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/rc.libtorrent-rasterbar $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/init.d/SXXlibtorrent-rasterbar
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)/opt/etc/init.d/SXXlibtorrent-rasterbar
	$(MAKE) $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/postinst $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/prerm $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBTORRENT-RASTERBAR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT-RASTERBAR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtorrent-rasterbar-ipk: $(LIBTORRENT-RASTERBAR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtorrent-rasterbar-clean:
	rm -f $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBTORRENT-RASTERBAR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtorrent-rasterbar-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(LIBTORRENT-RASTERBAR_BUILD_DIR) $(LIBTORRENT-RASTERBAR_IPK_DIR) $(LIBTORRENT-RASTERBAR_IPK)
#
#
# Some sanity check for the package.
#
libtorrent-rasterbar-check: $(LIBTORRENT-RASTERBAR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
