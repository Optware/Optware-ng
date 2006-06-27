###########################################################
#
# wireless-tools
#
###########################################################

#
# WIRELESS-TOOLS_VERSION, WIRELESS-TOOLS_SITE and WIRELESS-TOOLS_SOURCE define
# the upstream location of the source code for the package.
# WIRELESS-TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# WIRELESS-TOOLS_UNZIP is the command used to unzip the source.
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
http://pcmcia-cs.sourceforge.net/ftp/contrib/wireless_tools.28.tar.gz
WIRELESS-TOOLS_SITE=http://pcmcia-cs.sourceforge.net/ftp/contrib
WIRELESS-TOOLS_VERSION=28
WIRELESS-TOOLS_SOURCE=wireless_tools.$(WIRELESS-TOOLS_VERSION).tar.gz
WIRELESS-TOOLS_DIR=wireless_tools.$(WIRELESS-TOOLS_VERSION)
WIRELESS-TOOLS_UNZIP=zcat
WIRELESS-TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WIRELESS-TOOLS_DESCRIPTION=Tools for configuring a WiFi network
WIRELESS-TOOLS_SECTION=net
WIRELESS-TOOLS_PRIORITY=optional
WIRELESS-TOOLS_DEPENDS=
WIRELESS-TOOLS_SUGGESTS=
WIRELESS-TOOLS_CONFLICTS=

#
# WIRELESS-TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
WIRELESS-TOOLS_IPK_VERSION=1

#
# WIRELESS-TOOLS_CONFFILES should be a list of user-editable files
#WIRELESS-TOOLS_CONFFILES=/opt/etc/wireless-tools.conf /opt/etc/init.d/SXXwireless-tools

#
# WIRELESS-TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WIRELESS-TOOLS_PATCHES=$(WIRELESS-TOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WIRELESS-TOOLS_CPPFLAGS=
WIRELESS-TOOLS_LDFLAGS=

#
# WIRELESS-TOOLS_BUILD_DIR is the directory in which the build is done.
# WIRELESS-TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WIRELESS-TOOLS_IPK_DIR is the directory in which the ipk is built.
# WIRELESS-TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WIRELESS-TOOLS_BUILD_DIR=$(BUILD_DIR)/wireless-tools
WIRELESS-TOOLS_SOURCE_DIR=$(SOURCE_DIR)/wireless-tools
WIRELESS-TOOLS_IPK_DIR=$(BUILD_DIR)/wireless-tools-$(WIRELESS-TOOLS_VERSION)-ipk
WIRELESS-TOOLS_IPK=$(BUILD_DIR)/wireless-tools_$(WIRELESS-TOOLS_VERSION)-$(WIRELESS-TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WIRELESS-TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(WIRELESS-TOOLS_SITE)/$(WIRELESS-TOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wireless-tools-source: $(DL_DIR)/$(WIRELESS-TOOLS_SOURCE) $(WIRELESS-TOOLS_PATCHES)

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
$(WIRELESS-TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(WIRELESS-TOOLS_SOURCE) $(WIRELESS-TOOLS_PATCHES) make/wireless-tools.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(WIRELESS-TOOLS_DIR) $(WIRELESS-TOOLS_BUILD_DIR)
	$(WIRELESS-TOOLS_UNZIP) $(DL_DIR)/$(WIRELESS-TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WIRELESS-TOOLS_PATCHES)" ; \
		then cat $(WIRELESS-TOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WIRELESS-TOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WIRELESS-TOOLS_DIR)" != "$(WIRELESS-TOOLS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(WIRELESS-TOOLS_DIR) $(WIRELESS-TOOLS_BUILD_DIR) ; \
	fi
	#(cd $(WIRELESS-TOOLS_BUILD_DIR); \
	#	$(TARGET_CONFIGURE_OPTS) \
	#	CPPFLAGS="$(STAGING_CPPFLAGS) $(WIRELESS-TOOLS_CPPFLAGS)" \
	#	LDFLAGS="$(STAGING_LDFLAGS) $(WIRELESS-TOOLS_LDFLAGS)" \
	#	./configure \
	#	--build=$(GNU_HOST_NAME) \
	#	--host=$(GNU_TARGET_NAME) \
	#	--target=$(GNU_TARGET_NAME) \
	#	--prefix=/opt \
	#	--disable-nls \
	#	--disable-static \
	#)
	#$(PATCH_LIBTOOL) $(WIRELESS-TOOLS_BUILD_DIR)/libtool
	touch $(WIRELESS-TOOLS_BUILD_DIR)/.configured

wireless-tools-unpack: $(WIRELESS-TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WIRELESS-TOOLS_BUILD_DIR)/.built: $(WIRELESS-TOOLS_BUILD_DIR)/.configured
	rm -f $(WIRELESS-TOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(WIRELESS-TOOLS_BUILD_DIR) CC=$(TARGET_CC) PREFIX=/opt LDFLAGS=-Wl,-rpath=/opt/lib
	touch $(WIRELESS-TOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
wireless-tools: $(WIRELESS-TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WIRELESS-TOOLS_BUILD_DIR)/.staged: $(WIRELESS-TOOLS_BUILD_DIR)/.built
	rm -f $(WIRELESS-TOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(WIRELESS-TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WIRELESS-TOOLS_BUILD_DIR)/.staged

wireless-tools-stage: $(WIRELESS-TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wireless-tools
#
$(WIRELESS-TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(WIRELESS-TOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: wireless-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WIRELESS-TOOLS_PRIORITY)" >>$@
	@echo "Section: $(WIRELESS-TOOLS_SECTION)" >>$@
	@echo "Version: $(WIRELESS-TOOLS_VERSION)-$(WIRELESS-TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WIRELESS-TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(WIRELESS-TOOLS_SITE)/$(WIRELESS-TOOLS_SOURCE)" >>$@
	@echo "Description: $(WIRELESS-TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(WIRELESS-TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(WIRELESS-TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(WIRELESS-TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WIRELESS-TOOLS_IPK_DIR)/opt/sbin or $(WIRELESS-TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WIRELESS-TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/wireless-tools/...
# Documentation files should be installed in $(WIRELESS-TOOLS_IPK_DIR)/opt/doc/wireless-tools/...
# Daemon startup scripts should be installed in $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/init.d/S??wireless-tools
#
# You may need to patch your application to make it use these locations.
#
$(WIRELESS-TOOLS_IPK): $(WIRELESS-TOOLS_BUILD_DIR)/.built
	rm -rf $(WIRELESS-TOOLS_IPK_DIR) $(BUILD_DIR)/wireless-tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WIRELESS-TOOLS_BUILD_DIR) PREFIX=$(WIRELESS-TOOLS_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(WIRELESS-TOOLS_IPK_DIR)/opt/bin/*
	$(STRIP_COMMAND) $(WIRELESS-TOOLS_IPK_DIR)/opt/sbin/*
	$(STRIP_COMMAND) $(WIRELESS-TOOLS_IPK_DIR)/opt/lib/*
	#install -d $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/
	#install -m 644 $(WIRELESS-TOOLS_SOURCE_DIR)/wireless-tools.conf $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/wireless-tools.conf
	#install -d $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(WIRELESS-TOOLS_SOURCE_DIR)/rc.wireless-tools $(WIRELESS-TOOLS_IPK_DIR)/opt/etc/init.d/SXXwireless-tools
	$(MAKE) $(WIRELESS-TOOLS_IPK_DIR)/CONTROL/control
	#install -m 755 $(WIRELESS-TOOLS_SOURCE_DIR)/postinst $(WIRELESS-TOOLS_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(WIRELESS-TOOLS_SOURCE_DIR)/prerm $(WIRELESS-TOOLS_IPK_DIR)/CONTROL/prerm
	echo $(WIRELESS-TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(WIRELESS-TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WIRELESS-TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wireless-tools-ipk: $(WIRELESS-TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wireless-tools-clean:
	rm -f $(WIRELESS-TOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(WIRELESS-TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wireless-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(WIRELESS-TOOLS_DIR) $(WIRELESS-TOOLS_BUILD_DIR) $(WIRELESS-TOOLS_IPK_DIR) $(WIRELESS-TOOLS_IPK)
