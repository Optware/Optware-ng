###########################################################
#
# strongswan
#
###########################################################

# You must replace "strongswan" and "STRONGSWAN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# STRONGSWAN_VERSION, STRONGSWAN_SITE and STRONGSWAN_SOURCE define
# the upstream location of the source code for the package.
# STRONGSWAN_DIR is the directory which is created when the source
# archive is unpacked.
# STRONGSWAN_UNZIP is the command used to unzip the source.
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
STRONGSWAN_SITE=http://download.strongswan.org/
STRONGSWAN_VERSION=4.5.3
STRONGSWAN_SOURCE=strongswan-$(STRONGSWAN_VERSION).tar.gz
STRONGSWAN_DIR=strongswan-$(STRONGSWAN_VERSION)
STRONGSWAN_UNZIP=zcat
STRONGSWAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STRONGSWAN_DESCRIPTION=A IPsec implementation.
STRONGSWAN_SECTION=net
STRONGSWAN_PRIORITY=optional
STRONGSWAN_DEPENDS=libgmp,libsoup,libcurl,libldap
STRONGSWAN_SUGGESTS=
STRONGSWAN_CONFLICTS=

#
# STRONGSWAN_IPK_VERSION should be incremented when the ipk changes.
#
STRONGSWAN_IPK_VERSION=1

#
# STRONGSWAN_CONFFILES should be a list of user-editable files
#STRONGSWAN_CONFFILES=/opt/etc/strongswan.conf /opt/etc/init.d/SXXstrongswan

#
# STRONGSWAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
STRONGSWAN_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STRONGSWAN_CPPFLAGS=
STRONGSWAN_LDFLAGS=

#
# STRONGSWAN_BUILD_DIR is the directory in which the build is done.
# STRONGSWAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STRONGSWAN_IPK_DIR is the directory in which the ipk is built.
# STRONGSWAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STRONGSWAN_BUILD_DIR=$(BUILD_DIR)/strongswan
STRONGSWAN_SOURCE_DIR=$(SOURCE_DIR)/strongswan
STRONGSWAN_IPK_DIR=$(BUILD_DIR)/strongswan-$(STRONGSWAN_VERSION)-ipk
STRONGSWAN_IPK=$(BUILD_DIR)/strongswan_$(STRONGSWAN_VERSION)-$(STRONGSWAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: strongswan-source strongswan-unpack strongswan strongswan-stage strongswan-ipk strongswan-clean strongswan-dirclean strongswan-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STRONGSWAN_SOURCE):
	$(WGET) -P $(@D) $(STRONGSWAN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
strongswan-source: $(DL_DIR)/$(STRONGSWAN_SOURCE) $(STRONGSWAN_PATCHES)

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
$(STRONGSWAN_BUILD_DIR)/.configured: $(DL_DIR)/$(STRONGSWAN_SOURCE) $(STRONGSWAN_PATCHES) make/strongswan.mk
	$(MAKE) libgmp-stage libsoup-stage libcurl-stage openldap-stage
	rm -rf $(BUILD_DIR)/$(STRONGSWAN_DIR) $(@D)
	$(STRONGSWAN_UNZIP) $(DL_DIR)/$(STRONGSWAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(STRONGSWAN_PATCHES)" ; \
		then cat $(STRONGSWAN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(STRONGSWAN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(STRONGSWAN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(STRONGSWAN_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STRONGSWAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STRONGSWAN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--exec-prefix=/opt \
		--datadir=/opt \
		--disable-static \
		--enable-curl \
		--enable-ldap \
		--enable-eap-tls \
		--enable-eap-ttls \
		--enable-eap-peap \
		--enable-agent \
		--enable-monolithic \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

strongswan-unpack: $(STRONGSWAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(STRONGSWAN_BUILD_DIR)/.built: $(STRONGSWAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
strongswan: $(STRONGSWAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STRONGSWAN_BUILD_DIR)/.staged: $(STRONGSWAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

strongswan-stage: $(STRONGSWAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/strongswan
#
$(STRONGSWAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: strongswan" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STRONGSWAN_PRIORITY)" >>$@
	@echo "Section: $(STRONGSWAN_SECTION)" >>$@
	@echo "Version: $(STRONGSWAN_VERSION)-$(STRONGSWAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STRONGSWAN_MAINTAINER)" >>$@
	@echo "Source: $(STRONGSWAN_SITE)/$(STRONGSWAN_SOURCE)" >>$@
	@echo "Description: $(STRONGSWAN_DESCRIPTION)" >>$@
	@echo "Depends: $(STRONGSWAN_DEPENDS)" >>$@
	@echo "Suggests: $(STRONGSWAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(STRONGSWAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STRONGSWAN_IPK_DIR)/opt/sbin or $(STRONGSWAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STRONGSWAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STRONGSWAN_IPK_DIR)/opt/etc/strongswan/...
# Documentation files should be installed in $(STRONGSWAN_IPK_DIR)/opt/doc/strongswan/...
# Daemon startup scripts should be installed in $(STRONGSWAN_IPK_DIR)/opt/etc/init.d/S??strongswan
#
# You may need to patch your application to make it use these locations.
#
$(STRONGSWAN_IPK): $(STRONGSWAN_BUILD_DIR)/.built
	rm -rf $(STRONGSWAN_IPK_DIR) $(BUILD_DIR)/strongswan_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(STRONGSWAN_BUILD_DIR) DESTDIR=$(STRONGSWAN_IPK_DIR) install-strip
	install -d $(STRONGSWAN_BUILD_DIR)/opt/lib
	install -m 644 $(STRONGSWAN_BUILD_DIR)/src/libstrongswan/.libs/libstrongswan.so.0.0.0  $(STRONGSWAN_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(STRONGSWAN_IPK_DIR)/opt/lib/libstrongswan.so.0.0.0
	cd $(STRONGSWAN_IPK_DIR)/opt/lib && ln -fs libstrongswan.so.0.0.0 libstrongswan.so.0
	cd $(STRONGSWAN_IPK_DIR)/opt/lib && ln -fs libstrongswan.so.0.0.0 libstrongswan.so
	install -m 644 $(STRONGSWAN_BUILD_DIR)/src/libcharon/.libs/libcharon.so.0.0.0  $(STRONGSWAN_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(STRONGSWAN_IPK_DIR)/opt/lib/libcharon.so.0.0.0
	cd $(STRONGSWAN_IPK_DIR)/opt/lib && ln -fs libcharon.so.0.0.0 libcharon.so.0
	cd $(STRONGSWAN_IPK_DIR)/opt/lib && ln -fs libcharon.so.0.0.0 libcharon.so

#	install -d $(STRONGSWAN_IPK_DIR)/opt/etc/
#	install -m 644 $(STRONGSWAN_SOURCE_DIR)/strongswan.conf $(STRONGSWAN_IPK_DIR)/opt/etc/strongswan.conf
#	install -d $(STRONGSWAN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(STRONGSWAN_SOURCE_DIR)/rc.strongswan $(STRONGSWAN_IPK_DIR)/opt/etc/init.d/SXXstrongswan
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STRONGSWAN_IPK_DIR)/opt/etc/init.d/SXXstrongswan
	$(MAKE) $(STRONGSWAN_IPK_DIR)/CONTROL/control
#	install -m 755 $(STRONGSWAN_SOURCE_DIR)/postinst $(STRONGSWAN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STRONGSWAN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(STRONGSWAN_SOURCE_DIR)/prerm $(STRONGSWAN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STRONGSWAN_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(STRONGSWAN_IPK_DIR)/CONTROL/postinst $(STRONGSWAN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(STRONGSWAN_CONFFILES) | sed -e 's/ /\n/g' > $(STRONGSWAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STRONGSWAN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(STRONGSWAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
strongswan-ipk: $(STRONGSWAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
strongswan-clean:
	rm -f $(STRONGSWAN_BUILD_DIR)/.built
	-$(MAKE) -C $(STRONGSWAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
strongswan-dirclean:
	rm -rf $(BUILD_DIR)/$(STRONGSWAN_DIR) $(STRONGSWAN_BUILD_DIR) $(STRONGSWAN_IPK_DIR) $(STRONGSWAN_IPK)
#
#
# Some sanity check for the package.
#
strongswan-check: $(STRONGSWAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
