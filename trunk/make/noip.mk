###########################################################
#
# noip
#
###########################################################

# You must replace "noip" and "NOIP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NOIP_VERSION, NOIP_SITE and NOIP_SOURCE define
# the upstream location of the source code for the package.
# NOIP_DIR is the directory which is created when the source
# archive is unpacked.
# NOIP_UNZIP is the command used to unzip the source.
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
NOIP_SITE=http://www.no-ip.com/client/linux
NOIP_VERSION=2.1.3
NOIP_SOURCE=noip-duc-linux.tar.gz
NOIP_DIR=noip-$(NOIP_VERSION)
NOIP_UNZIP=zcat
NOIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NOIP_DESCRIPTION=www.no-ip.com Dynamic Update Client
NOIP_SECTION=net
NOIP_PRIORITY=optional
NOIP_DEPENDS=
NOIP_SUGGESTS=
NOIP_CONFLICTS=

#
# NOIP_IPK_VERSION should be incremented when the ipk changes.
#
NOIP_IPK_VERSION=1

#
# NOIP_CONFFILES should be a list of user-editable files
NOIP_CONFFILES=

#
# NOIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NOIP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NOIP_CPPFLAGS=
NOIP_LDFLAGS=

#
# NOIP_BUILD_DIR is the directory in which the build is done.
# NOIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NOIP_IPK_DIR is the directory in which the ipk is built.
# NOIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NOIP_BUILD_DIR=$(BUILD_DIR)/noip
NOIP_SOURCE_DIR=$(SOURCE_DIR)/noip
NOIP_IPK_DIR=$(BUILD_DIR)/noip-$(NOIP_VERSION)-ipk
NOIP_IPK=$(BUILD_DIR)/noip_$(NOIP_VERSION)-$(NOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NOIP_SOURCE): make/noip.mk
	rm -f $(DL_DIR)/$(NOIP_SOURCE)
	$(WGET) -P $(DL_DIR) $(NOIP_SITE)/$(NOIP_SOURCE)
	touch $(DL_DIR)/$(NOIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
noip-source: $(DL_DIR)/$(NOIP_SOURCE) $(NOIP_PATCHES)

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
$(NOIP_BUILD_DIR)/.configured: $(DL_DIR)/$(NOIP_SOURCE) $(NOIP_PATCHES)
	rm -rf $(BUILD_DIR)/$(NOIP_DIR) $(NOIP_BUILD_DIR)
	$(NOIP_UNZIP) $(DL_DIR)/$(NOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NOIP_PATCHES)" ; \
		then cat $(NOIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NOIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NOIP_DIR)" != "$(NOIP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NOIP_DIR) $(NOIP_BUILD_DIR) ; \
	fi
	touch $(NOIP_BUILD_DIR)/.configured

noip-unpack: $(NOIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NOIP_BUILD_DIR)/.built: $(NOIP_BUILD_DIR)/.configured
	rm -f $(NOIP_BUILD_DIR)/.built
	$(MAKE) -C $(NOIP_BUILD_DIR) PREFIX=/opt $(TARGET_CONFIGURE_OPTS)
	touch $(NOIP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
noip: $(NOIP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/noip
#
$(NOIP_IPK_DIR)/CONTROL/control:
	@install -d $(NOIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: noip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NOIP_PRIORITY)" >>$@
	@echo "Section: $(NOIP_SECTION)" >>$@
	@echo "Version: $(NOIP_VERSION)-$(NOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NOIP_MAINTAINER)" >>$@
	@echo "Source: $(NOIP_SITE)/$(NOIP_SOURCE)" >>$@
	@echo "Description: $(NOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(NOIP_DEPENDS)" >>$@
	@echo "Suggests: $(NOIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NOIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NOIP_IPK_DIR)/opt/sbin or $(NOIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NOIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NOIP_IPK_DIR)/opt/etc/noip/...
# Documentation files should be installed in $(NOIP_IPK_DIR)/opt/doc/noip/...
# Daemon startup scripts should be installed in $(NOIP_IPK_DIR)/opt/etc/init.d/S??noip
#
# You may need to patch your application to make it use these locations.
#
$(NOIP_IPK): $(NOIP_BUILD_DIR)/.built
	rm -rf $(NOIP_IPK_DIR) $(BUILD_DIR)/noip_*_$(TARGET_ARCH).ipk
	install -d $(NOIP_IPK_DIR)/opt/bin
	install -m 755 $(NOIP_BUILD_DIR)/noip2 $(NOIP_IPK_DIR)/opt/bin
	install -d $(NOIP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NOIP_SOURCE_DIR)/rc.noip $(NOIP_IPK_DIR)/opt/etc/init.d/SXXnoip
	$(MAKE) $(NOIP_IPK_DIR)/CONTROL/control
#	install -m 755 $(NOIP_SOURCE_DIR)/postinst $(NOIP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NOIP_SOURCE_DIR)/prerm $(NOIP_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NOIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
noip-ipk: $(NOIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
noip-clean:
	rm -f $(NOIP_BUILD_DIR)/.built
	-$(MAKE) -C $(NOIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
noip-dirclean:
	rm -rf $(BUILD_DIR)/$(NOIP_DIR) $(NOIP_BUILD_DIR) $(NOIP_IPK_DIR) $(NOIP_IPK)
