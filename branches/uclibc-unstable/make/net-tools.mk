###########################################################
#
# net-tools
#
###########################################################

#
# NET-TOOLS_VERSION, NET-TOOLS_SITE and NET-TOOLS_SOURCE define
# the upstream location of the source code for the package.
# NET-TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# NET-TOOLS_UNZIP is the command used to unzip the source.
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
NET-TOOLS_SITE=http://www.tazenda.demon.co.uk/phil/net-tools
NET-TOOLS_VERSION=1.60
NET-TOOLS_SOURCE=net-tools-$(NET-TOOLS_VERSION).tar.bz2
NET-TOOLS_DIR=net-tools-$(NET-TOOLS_VERSION)
NET-TOOLS_UNZIP=bzcat
NET-TOOLS_MAINTAINER=Adam Baker <slug@baker-net.org.uk>
NET-TOOLS_DESCRIPTION=Network Config and Debug tools (route, arp, netstat etc.)
NET-TOOLS_SECTION=net
NET-TOOLS_PRIORITY=optional
NET-TOOLS_DEPENDS=
NET-TOOLS_SUGGESTS=
NET-TOOLS_CONFLICTS=busybox-links

#
# NET-TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
NET-TOOLS_IPK_VERSION=3

#
# NET-TOOLS_CONFFILES should be a list of user-editable files
NET-TOOLS_CONFFILES=

#
# NET-TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GCC3.3 patch taken unmodified from Linux Fromm Scratch
# config patch creates a config file as the supplied configure.sh
# doesn't try to guess anything but just asks the user.
# man/Makefile change is to fix hard coded man page location
# Makefile change is to remove hostname (conflicts with coreutils)
# Makefile changes must be applied before config.h is created otherwise
# config.h is treated as out of date
#
NET-TOOLS_PATCHES=sources/net-tools/net-tools-1.60-miitool-gcc33-1.patch \
	sources/net-tools/gcc4.patch \
	sources/net-tools/config-make.patch \
	sources/net-tools/config.patch sources/net-tools/manMakefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NET-TOOLS_CPPFLAGS=-D_GNU_SOURCE -O2
NET-TOOLS_LDFLAGS=

#
# NET-TOOLS_BUILD_DIR is the directory in which the build is done.
# NET-TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NET-TOOLS_IPK_DIR is the directory in which the ipk is built.
# NET-TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NET-TOOLS_BUILD_DIR=$(BUILD_DIR)/net-tools
NET-TOOLS_SOURCE_DIR=$(SOURCE_DIR)/net-tools
NET-TOOLS_IPK_DIR=$(BUILD_DIR)/net-tools-$(NET-TOOLS_VERSION)-ipk
NET-TOOLS_IPK=$(BUILD_DIR)/net-tools_$(NET-TOOLS_VERSION)-$(NET-TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: net-tools-source net-tools-unpack net-tools net-tools-stage net-tools-ipk net-tools-clean net-tools-dirclean net-tools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NET-TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NET-TOOLS_SITE)/$(NET-TOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
net-tools-source: $(DL_DIR)/$(NET-TOOLS_SOURCE) $(NET-TOOLS_PATCHES)

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
$(NET-TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(NET-TOOLS_SOURCE) $(NET-TOOLS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NET-TOOLS_DIR) $(NET-TOOLS_BUILD_DIR)
	$(NET-TOOLS_UNZIP) $(DL_DIR)/$(NET-TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NET-TOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(NET-TOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(NET-TOOLS_DIR) $(NET-TOOLS_BUILD_DIR)
	touch $(NET-TOOLS_BUILD_DIR)/.configured

net-tools-unpack: $(NET-TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NET-TOOLS_BUILD_DIR)/.built: $(NET-TOOLS_BUILD_DIR)/.configured
	rm -f $(NET-TOOLS_BUILD_DIR)/.built
	$(MAKE) CC=$(TARGET_CC) BASEDIR=/opt COPTS="$(STAGING_CPPFLAGS) $(NET-TOOLS_CPPFLAGS)" LOPTS="$(STAGING_LDFLAGS) $(NET-TOOLS_LDFLAGS)" -C $(NET-TOOLS_BUILD_DIR)
	touch $(NET-TOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
net-tools: $(NET-TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NET-TOOLS_BUILD_DIR)/.staged: $(NET-TOOLS_BUILD_DIR)/.built
	rm -f $(NET-TOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(NET-TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NET-TOOLS_BUILD_DIR)/.staged

net-tools-stage: $(NET-TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/net-tools
#
$(NET-TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(NET-TOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: net-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NET-TOOLS_PRIORITY)" >>$@
	@echo "Section: $(NET-TOOLS_SECTION)" >>$@
	@echo "Version: $(NET-TOOLS_VERSION)-$(NET-TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NET-TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(NET-TOOLS_SITE)/$(NET-TOOLS_SOURCE)" >>$@
	@echo "Description: $(NET-TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(NET-TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(NET-TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NET-TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NET-TOOLS_IPK_DIR)/opt/sbin or $(NET-TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NET-TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NET-TOOLS_IPK_DIR)/opt/etc/net-tools/...
# Documentation files should be installed in $(NET-TOOLS_IPK_DIR)/opt/doc/net-tools/...
# Daemon startup scripts should be installed in $(NET-TOOLS_IPK_DIR)/opt/etc/init.d/S??net-tools
#
# You may need to patch your application to make it use these locations.
#
$(NET-TOOLS_IPK): $(NET-TOOLS_BUILD_DIR)/.built
	rm -rf $(NET-TOOLS_IPK_DIR) $(BUILD_DIR)/net-tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NET-TOOLS_BUILD_DIR) BASEDIR=$(NET-TOOLS_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(NET-TOOLS_IPK_DIR)/opt/bin/*
	$(STRIP_COMMAND) $(NET-TOOLS_IPK_DIR)/opt/sbin/*
	install -d $(NET-TOOLS_IPK_DIR)/opt/etc/
	#install -m 644 $(NET-TOOLS_SOURCE_DIR)/net-tools.conf $(NET-TOOLS_IPK_DIR)/opt/etc/net-tools.conf
	#install -d $(NET-TOOLS_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(NET-TOOLS_SOURCE_DIR)/rc.net-tools $(NET-TOOLS_IPK_DIR)/opt/etc/init.d/SXXnet-tools
	$(MAKE) $(NET-TOOLS_IPK_DIR)/CONTROL/control
	#install -m 755 $(NET-TOOLS_SOURCE_DIR)/postinst $(NET-TOOLS_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(NET-TOOLS_SOURCE_DIR)/prerm $(NET-TOOLS_IPK_DIR)/CONTROL/prerm
	echo $(NET-TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(NET-TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NET-TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
net-tools-ipk: $(NET-TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
net-tools-clean:
	-$(MAKE) -C $(NET-TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
net-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(NET-TOOLS_DIR) $(NET-TOOLS_BUILD_DIR) $(NET-TOOLS_IPK_DIR) $(NET-TOOLS_IPK)

#
# Some sanity check for the package.
#
net-tools-check: $(NET-TOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NET-TOOLS_IPK)
