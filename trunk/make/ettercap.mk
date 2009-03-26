###########################################################
#
# ettercap
#
###########################################################

# You must replace "ettercap" and "ETTERCAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ETTERCAP_VERSION, ETTERCAP_SITE and ETTERCAP_SOURCE define
# the upstream location of the source code for the package.
# ETTERCAP_DIR is the directory which is created when the source
# archive is unpacked.
# ETTERCAP_UNZIP is the command used to unzip the source.
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
ETTERCAP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ettercap
ETTERCAP_VERSION=0.6.b
ETTERCAP_SOURCE=ettercap-$(ETTERCAP_VERSION).tar.gz
ETTERCAP_DIR=ettercap-$(ETTERCAP_VERSION)
ETTERCAP_UNZIP=zcat
ETTERCAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ETTERCAP_DESCRIPTION=Ettercap is a suite for man in the middle attacks on LAN. It features sniffing of live connections, content filtering on the fly and many other interesting tricks.
ETTERCAP_SECTION=net
ETTERCAP_PRIORITY=optional
ETTERCAP_DEPENDS=libtool, libpcap, ncurses
#ETTERCAP_SUGGESTS=
#ETTERCAP_CONFLICTS=

#
# ETTERCAP_IPK_VERSION should be incremented when the ipk changes.
#
ETTERCAP_IPK_VERSION=1

#
# ETTERCAP_CONFFILES should be a list of user-editable files
#ETTERCAP_CONFFILES=/opt/etc/ettercap.conf /opt/etc/init.d/SXXettercap

#
# ETTERCAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ETTERCAP_PATCHES=$(ETTERCAP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ETTERCAP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
ETTERCAP_LDFLAGS=

#
# ETTERCAP_BUILD_DIR is the directory in which the build is done.
# ETTERCAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ETTERCAP_IPK_DIR is the directory in which the ipk is built.
# ETTERCAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ETTERCAP_BUILD_DIR=$(BUILD_DIR)/ettercap
ETTERCAP_SOURCE_DIR=$(SOURCE_DIR)/ettercap
ETTERCAP_IPK_DIR=$(BUILD_DIR)/ettercap-$(ETTERCAP_VERSION)-ipk
ETTERCAP_IPK=$(BUILD_DIR)/ettercap_$(ETTERCAP_VERSION)-$(ETTERCAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ettercap-source ettercap-unpack ettercap ettercap-stage ettercap-ipk ettercap-clean ettercap-dirclean ettercap-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ETTERCAP_SOURCE):
	$(WGET) -P $(@D) $(ETTERCAP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ettercap-source: $(DL_DIR)/$(ETTERCAP_SOURCE) $(ETTERCAP_PATCHES)

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
$(ETTERCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(ETTERCAP_SOURCE) $(ETTERCAP_PATCHES) make/ettercap.mk
	$(MAKE) libpcap-stage openssl-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(ETTERCAP_DIR) $(@D)
	$(ETTERCAP_UNZIP) $(DL_DIR)/$(ETTERCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ETTERCAP_PATCHES)" ; \
		then cat $(ETTERCAP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ETTERCAP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ETTERCAP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ETTERCAP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ETTERCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ETTERCAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--includedir=$(STAGING_INCLUDE_DIR) \
		--without-openssl \
		--with-libtool \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-gtk \
		COPTS="$(STAGING_CPPFLAGS) $(ETTERCAP_CPPFLAGS)" \
		LOPTS="$(STAGING_LDFLAGS) $(ETTERCAP_LDFLAGS)" \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ettercap-unpack: $(ETTERCAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ETTERCAP_BUILD_DIR)/.built: $(ETTERCAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ettercap: $(ETTERCAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ETTERCAP_BUILD_DIR)/.staged: $(ETTERCAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ettercap-stage: $(ETTERCAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ettercap
#
$(ETTERCAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ettercap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ETTERCAP_PRIORITY)" >>$@
	@echo "Section: $(ETTERCAP_SECTION)" >>$@
	@echo "Version: $(ETTERCAP_VERSION)-$(ETTERCAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ETTERCAP_MAINTAINER)" >>$@
	@echo "Source: $(ETTERCAP_SITE)/$(ETTERCAP_SOURCE)" >>$@
	@echo "Description: $(ETTERCAP_DESCRIPTION)" >>$@
	@echo "Depends: $(ETTERCAP_DEPENDS)" >>$@
	@echo "Suggests: $(ETTERCAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(ETTERCAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ETTERCAP_IPK_DIR)/opt/sbin or $(ETTERCAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ETTERCAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ETTERCAP_IPK_DIR)/opt/etc/ettercap/...
# Documentation files should be installed in $(ETTERCAP_IPK_DIR)/opt/doc/ettercap/...
# Daemon startup scripts should be installed in $(ETTERCAP_IPK_DIR)/opt/etc/init.d/S??ettercap
#
# You may need to patch your application to make it use these locations.
#
$(ETTERCAP_IPK): $(ETTERCAP_BUILD_DIR)/.built
	rm -rf $(ETTERCAP_IPK_DIR) $(BUILD_DIR)/ettercap_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ETTERCAP_BUILD_DIR) DESTDIR=$(ETTERCAP_IPK_DIR) install
#	install -d $(ETTERCAP_IPK_DIR)/opt/sbin/
#	install -m 755 $(ETTERCAP_BUILD_DIR)/ettercap $(ETTERCAP_IPK_DIR)/opt/sbin/ettercap
#	install -m 644 $(ETTERCAP_SOURCE_DIR)/ettercap.conf $(ETTERCAP_IPK_DIR)/opt/etc/ettercap.conf
#	install -d $(ETTERCAP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ETTERCAP_SOURCE_DIR)/rc.ettercap $(ETTERCAP_IPK_DIR)/opt/etc/init.d/SXXettercap
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ETTERCAP_IPK_DIR)/opt/etc/init.d/SXXettercap
	$(MAKE) $(ETTERCAP_IPK_DIR)/CONTROL/control
#	install -m 755 $(ETTERCAP_SOURCE_DIR)/postinst $(ETTERCAP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ETTERCAP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ETTERCAP_SOURCE_DIR)/prerm $(ETTERCAP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ETTERCAP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ETTERCAP_IPK_DIR)/CONTROL/postinst $(ETTERCAP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ETTERCAP_CONFFILES) | sed -e 's/ /\n/g' > $(ETTERCAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ETTERCAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ettercap-ipk: $(ETTERCAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ettercap-clean:
	rm -f $(ETTERCAP_BUILD_DIR)/.built
	-$(MAKE) -C $(ETTERCAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ettercap-dirclean:
	rm -rf $(BUILD_DIR)/$(ETTERCAP_DIR) $(ETTERCAP_BUILD_DIR) $(ETTERCAP_IPK_DIR) $(ETTERCAP_IPK)
#
#
# Some sanity check for the package.
#
ettercap-check: $(ETTERCAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
