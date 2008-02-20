###########################################################
#
# openvpn
#
###########################################################

# You must replace "openvpn" and "OPENVPN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.
#
# OPENVPN_VERSION, OPENVPN_SITE and OPENVPN_SOURCE define
# the upstream location of the source code for the package.
# OPENVPN_DIR is the directory which is created when the source
# archive is unpacked.
# OPENVPN_UNZIP is the command used to unzip the source.
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
OPENVPN_SITE=http://openvpn.net/release
OPENVPN_VERSION=2.1_rc7
OPENVPN_SOURCE=openvpn-$(OPENVPN_VERSION).tar.gz
OPENVPN_DIR=openvpn-$(OPENVPN_VERSION)
OPENVPN_UNZIP=zcat
OPENVPN_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
OPENVPN_DESCRIPTION=SSL based VPN server with Windows client support
OPENVPN_SECTION=net
OPENVPN_PRIORITY=optional
OPENVPN_DEPENDS=openssl, lzo
OPENVPN_SUGGESTS=kernel-module-tun
OPENVPN_CONFLICTS=

#
# OPENVPN_IPK_VERSION should be incremented when the ipk changes.
#
OPENVPN_IPK_VERSION=1

#
# OPENVPN_CONFFILES should be a list of user-editable files
OPENVPN_CONFFILES=/opt/etc/openvpn/openvpn.conf /opt/etc/openvpn/openvpn.up \
/opt/etc/init.d/S20openvpn /opt/etc/xinetd.d/openvpn

#
# OPENVPN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPENVPN_PATCHES=
#$(OPENVPN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENVPN_CPPFLAGS=-fno-inline
OPENVPN_LDFLAGS=

#
# OPENVPN_BUILD_DIR is the directory in which the build is done.
# OPENVPN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENVPN_IPK_DIR is the directory in which the ipk is built.
# OPENVPN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENVPN_BUILD_DIR=$(BUILD_DIR)/openvpn
OPENVPN_SOURCE_DIR=$(SOURCE_DIR)/openvpn
OPENVPN_IPK_DIR=$(BUILD_DIR)/openvpn-$(OPENVPN_VERSION)-ipk
OPENVPN_IPK=$(BUILD_DIR)/openvpn_$(OPENVPN_VERSION)-$(OPENVPN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openvpn-source openvpn-unpack openvpn openvpn-stage openvpn-ipk openvpn-clean openvpn-dirclean openvpn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENVPN_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENVPN_SITE)/$(OPENVPN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OPENVPN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openvpn-source: $(DL_DIR)/$(OPENVPN_SOURCE) $(OPENVPN_PATCHES)

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
$(OPENVPN_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENVPN_SOURCE) $(OPENVPN_PATCHES) make/openvpn.mk
	$(MAKE) lzo-stage
ifneq ($(HOST_MACHINE),armv5b)
	$(MAKE) openssl-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENVPN_DIR) $(@D)
	$(OPENVPN_UNZIP) $(DL_DIR)/$(OPENVPN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENVPN_PATCHES)" ; \
		then cat $(OPENVPN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENVPN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENVPN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(OPENVPN_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENVPN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENVPN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

openvpn-unpack: $(OPENVPN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENVPN_BUILD_DIR)/.built: $(OPENVPN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
openvpn: $(OPENVPN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENVPN_BUILD_DIR)/.staged: $(OPENVPN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

openvpn-stage: $(OPENVPN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openvpn
#
$(OPENVPN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: openvpn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENVPN_PRIORITY)" >>$@
	@echo "Section: $(OPENVPN_SECTION)" >>$@
	@echo "Version: $(OPENVPN_VERSION)-$(OPENVPN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENVPN_MAINTAINER)" >>$@
	@echo "Source: $(OPENVPN_SITE)/$(OPENVPN_SOURCE)" >>$@
	@echo "Description: $(OPENVPN_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENVPN_DEPENDS)" >>$@
	@echo "Suggests: $(OPENVPN_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENVPN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENVPN_IPK_DIR)/opt/sbin or $(OPENVPN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENVPN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENVPN_IPK_DIR)/opt/etc/openvpn/...
# Documentation files should be installed in $(OPENVPN_IPK_DIR)/opt/doc/openvpn/...
# Daemon startup scripts should be installed in $(OPENVPN_IPK_DIR)/opt/etc/init.d/S??openvpn
#
# You may need to patch your application to make it use these locations.
#
$(OPENVPN_IPK): $(OPENVPN_BUILD_DIR)/.built
	rm -rf $(OPENVPN_IPK_DIR) $(BUILD_DIR)/openvpn_*_$(TARGET_ARCH).ipk
	# Install server to /opt/sbin
	install -d $(OPENVPN_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(OPENVPN_BUILD_DIR)/openvpn -o $(OPENVPN_IPK_DIR)/opt/sbin/openvpn

	# xinetd startup file
	install -d $(OPENVPN_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(OPENVPN_SOURCE_DIR)/openvpn.xinetd $(OPENVPN_IPK_DIR)/opt/etc/xinetd.d/openvpn

	# init.d startup file
	install -d $(OPENVPN_IPK_DIR)/opt/etc/init.d
	install -m 755 $(OPENVPN_SOURCE_DIR)/S20openvpn $(OPENVPN_IPK_DIR)/opt/etc/init.d

	# openvpn config files
	install -d $(OPENVPN_IPK_DIR)/opt/etc/openvpn
	install -m 644 $(OPENVPN_SOURCE_DIR)/openvpn.conf $(OPENVPN_IPK_DIR)/opt/etc/openvpn
	install -m 644 $(OPENVPN_SOURCE_DIR)/openvpn.up $(OPENVPN_IPK_DIR)/opt/etc/openvpn

	# openvpn loopback test 
	install -d $(OPENVPN_IPK_DIR)/opt/etc/openvpn/sample-config-files
	install -m 644 $(OPENVPN_BUILD_DIR)/sample-config-files/* $(OPENVPN_IPK_DIR)/opt/etc/openvpn/sample-config-files

	# openvpn sample keys
	install -d $(OPENVPN_IPK_DIR)/opt/etc/openvpn/sample-keys
	install -m 644 $(OPENVPN_BUILD_DIR)/sample-keys/* $(OPENVPN_IPK_DIR)/opt/etc/openvpn/sample-keys

	# Install man pages
	install -d $(OPENVPN_IPK_DIR)/opt/man/man8
	install -m 644 $(OPENVPN_BUILD_DIR)/openvpn.8 $(OPENVPN_IPK_DIR)/opt/man/man8

	# Install control files
	make  $(OPENVPN_IPK_DIR)/CONTROL/control
#	install -m 644 $(OPENVPN_SOURCE_DIR)/postinst $(OPENVPN_IPK_DIR)/CONTROL
#	install -m 644 $(OPENVPN_SOURCE_DIR)/prerm $(OPENVPN_IPK_DIR)/CONTROL
	echo $(OPENVPN_CONFFILES) | sed -e 's/ /\n/g' > $(OPENVPN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENVPN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openvpn-ipk: $(OPENVPN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openvpn-clean:
	rm -f $(OPENVPN_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENVPN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openvpn-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENVPN_DIR) $(OPENVPN_BUILD_DIR) $(OPENVPN_IPK_DIR) $(OPENVPN_IPK)
#
#
# Some sanity check for the package.
#
openvpn-check: $(OPENVPN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENVPN_IPK)
