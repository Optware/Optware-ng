##########################################################
#
# netkit-telnet
#
###########################################################

# You must replace "netkit-telnet" and "NETKIT-TELNET" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NETKIT-TELNET_VERSION, NETKIT-TELNET_SITE and NETKIT-TELNET_SOURCE define
# the upstream location of the source code for the package.
# NETKIT-TELNET_DIR is the directory which is created when the source
# archive is unpacked.
# NETKIT-TELNET_UNZIP is the command used to unzip the source.
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
NETKIT-TELNET_SITE=ftp://ftp.uk.linux.org/pub/linux/Networking/netkit
NETKIT-TELNET_VERSION=0.17
NETKIT-TELNET_SOURCE=netkit-telnet-$(NETKIT-TELNET_VERSION).tar.gz
NETKIT-TELNET_DIR=netkit-telnet-$(NETKIT-TELNET_VERSION)
NETKIT-TELNET_UNZIP=zcat
NETKIT-TELNET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETKIT-TELNET_DESCRIPTION=This package contains telnet client and server programs.
NETKIT-TELNET_SECTION=
NETKIT-TELNET_PRIORITY=optional
NETKIT-TELNET_DEPENDS=
NETKIT-TELNET_SUGGESTS=
NETKIT-TELNET_CONFLICTS=

#
# NETKIT-TELNET_IPK_VERSION should be incremented when the ipk changes.
#
NETKIT-TELNET_IPK_VERSION=1

#
# NETKIT-TELNET_CONFFILES should be a list of user-editable files
NETKIT-TELNET_CONFFILES=/opt/etc/netkit-telnet.conf /opt/etc/init.d/SXXnetkit-telnet

#
# NETKIT-TELNET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NETKIT-TELNET_PATCHES=$(NETKIT-TELNET_SOURCE_DIR)/configure.patch $(NETKIT-TELNET_SOURCE_DIR)/missing-includes.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETKIT-TELNET_CPPFLAGS=
NETKIT-TELNET_LDFLAGS=

#
# NETKIT-TELNET_BUILD_DIR is the directory in which the build is done.
# NETKIT-TELNET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETKIT-TELNET_IPK_DIR is the directory in which the ipk is built.
# NETKIT-TELNET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETKIT-TELNET_BUILD_DIR=$(BUILD_DIR)/netkit-telnet
NETKIT-TELNET_SOURCE_DIR=$(SOURCE_DIR)/netkit-telnet
NETKIT-TELNET_IPK_DIR=$(BUILD_DIR)/netkit-telnet-$(NETKIT-TELNET_VERSION)-ipk
NETKIT-TELNET_IPK=$(BUILD_DIR)/netkit-telnet_$(NETKIT-TELNET_VERSION)-$(NETKIT-TELNET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: netkit-telnet-source netkit-telnet-unpack netkit-telnet netkit-telnet-stage netkit-telnet-ipk netkit-telnet-clean netkit-telnet-dirclean netkit-telnet-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETKIT-TELNET_SOURCE):
	$(WGET) -P $(DL_DIR) $(NETKIT-TELNET_SITE)/$(NETKIT-TELNET_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NETKIT-TELNET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netkit-telnet-source: $(DL_DIR)/$(NETKIT-TELNET_SOURCE) $(NETKIT-TELNET_PATCHES)

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
$(NETKIT-TELNET_BUILD_DIR)/.configured: $(DL_DIR)/$(NETKIT-TELNET_SOURCE) $(NETKIT-TELNET_PATCHES) make/netkit-telnet.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NETKIT-TELNET_DIR) $(NETKIT-TELNET_BUILD_DIR)
	$(NETKIT-TELNET_UNZIP) $(DL_DIR)/$(NETKIT-TELNET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NETKIT-TELNET_PATCHES)" ; \
		then cat $(NETKIT-TELNET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NETKIT-TELNET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NETKIT-TELNET_DIR)" != "$(NETKIT-TELNET_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NETKIT-TELNET_DIR) $(NETKIT-TELNET_BUILD_DIR) ; \
	fi
	(cd $(NETKIT-TELNET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETKIT-TELNET_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(NETKIT-TELNET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETKIT-TELNET_LDFLAGS)" \
		./configure \
		--prefix=/opt \
		--with-c-compiler=$(TARGET_CC) \
		--with-c++-compiler=$(TARGET_CPP) \
	)
#	$(PATCH_LIBTOOL) $(NETKIT-TELNET_BUILD_DIR)/libtool
	touch $@

netkit-telnet-unpack: $(NETKIT-TELNET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETKIT-TELNET_BUILD_DIR)/.built: $(NETKIT-TELNET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NETKIT-TELNET_BUILD_DIR) SUB=telnet
	touch $@

#
# This is the build convenience target.
#
netkit-telnet: $(NETKIT-TELNET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETKIT-TELNET_BUILD_DIR)/.staged: $(NETKIT-TELNET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NETKIT-TELNET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

netkit-telnet-stage: $(NETKIT-TELNET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netkit-telnet
#
$(NETKIT-TELNET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: netkit-telnet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETKIT-TELNET_PRIORITY)" >>$@
	@echo "Section: $(NETKIT-TELNET_SECTION)" >>$@
	@echo "Version: $(NETKIT-TELNET_VERSION)-$(NETKIT-TELNET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETKIT-TELNET_MAINTAINER)" >>$@
	@echo "Source: $(NETKIT-TELNET_SITE)/$(NETKIT-TELNET_SOURCE)" >>$@
	@echo "Description: $(NETKIT-TELNET_DESCRIPTION)" >>$@
	@echo "Depends: $(NETKIT-TELNET_DEPENDS)" >>$@
	@echo "Suggests: $(NETKIT-TELNET_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETKIT-TELNET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETKIT-TELNET_IPK_DIR)/opt/sbin or $(NETKIT-TELNET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETKIT-TELNET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETKIT-TELNET_IPK_DIR)/opt/etc/netkit-telnet/...
# Documentation files should be installed in $(NETKIT-TELNET_IPK_DIR)/opt/doc/netkit-telnet/...
# Daemon startup scripts should be installed in $(NETKIT-TELNET_IPK_DIR)/opt/etc/init.d/S??netkit-telnet
#
# You may need to patch your application to make it use these locations.
#
$(NETKIT-TELNET_IPK): $(NETKIT-TELNET_BUILD_DIR)/.built
	rm -rf $(NETKIT-TELNET_IPK_DIR) $(BUILD_DIR)/netkit-telnet_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NETKIT-TELNET_BUILD_DIR) DESTDIR=$(NETKIT-TELNET_IPK_DIR) install-strip
	install -d $(NETKIT-TELNET_IPK_DIR)/opt/etc/
	install -m 644 $(NETKIT-TELNET_SOURCE_DIR)/netkit-telnet.conf $(NETKIT-TELNET_IPK_DIR)/opt/etc/netkit-telnet.conf
	install -d $(NETKIT-TELNET_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NETKIT-TELNET_SOURCE_DIR)/rc.netkit-telnet $(NETKIT-TELNET_IPK_DIR)/opt/etc/init.d/SXXnetkit-telnet
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETKIT-TELNET_IPK_DIR)/opt/etc/init.d/SXXnetkit-telnet
	$(MAKE) $(NETKIT-TELNET_IPK_DIR)/CONTROL/control
	install -m 755 $(NETKIT-TELNET_SOURCE_DIR)/postinst $(NETKIT-TELNET_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETKIT-TELNET_IPK_DIR)/CONTROL/postinst
	install -m 755 $(NETKIT-TELNET_SOURCE_DIR)/prerm $(NETKIT-TELNET_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETKIT-TELNET_IPK_DIR)/CONTROL/prerm
	echo $(NETKIT-TELNET_CONFFILES) | sed -e 's/ /\n/g' > $(NETKIT-TELNET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETKIT-TELNET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netkit-telnet-ipk: $(NETKIT-TELNET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netkit-telnet-clean:
	rm -f $(NETKIT-TELNET_BUILD_DIR)/.built
	-$(MAKE) -C $(NETKIT-TELNET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netkit-telnet-dirclean:
	rm -rf $(BUILD_DIR)/$(NETKIT-TELNET_DIR) $(NETKIT-TELNET_BUILD_DIR) $(NETKIT-TELNET_IPK_DIR) $(NETKIT-TELNET_IPK)
#
#
# Some sanity check for the package.
#
netkit-telnet-check: $(NETKIT-TELNET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NETKIT-TELNET_IPK)
