###########################################################
#
# unzip
#
###########################################################

#
# UNZIP_VERSION, UNZIP_SITE and UNZIP_SOURCE define
# the upstream location of the source code for the package.
# UNZIP_DIR is the directory which is created when the source
# archive is unpacked.
# UNZIP_UNZIP is the command used to unzip the source.
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
#UNZIP_SITE=ftp://ftp.info-zip.org/pub/infozip/src
UNZIP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/infozip
UNZIP_VERSION=5.52
UNZIP_SOURCE=unzip552.tar.gz
UNZIP_DIR=unzip-$(UNZIP_VERSION)
UNZIP_UNZIP=zcat
UNZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNZIP_DESCRIPTION=A (de)compression library for the ZIP format
UNZIP_SECTION=console/utils
UNZIP_PRIORITY=optional
UNZIP_DEPENDS=
UNZIP_SUGGESTS=
UNZIP_CONFLICTS=

#
# UNZIP_IPK_VERSION should be incremented when the ipk changes.
#
UNZIP_IPK_VERSION=1

#
# UNZIP_CONFFILES should be a list of user-editable files
UNZIP_CONFFILES=

#
# UNZIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UNZIP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNZIP_CPPFLAGS=
UNZIP_LDFLAGS=

#
# UNZIP_BUILD_DIR is the directory in which the build is done.
# UNZIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNZIP_IPK_DIR is the directory in which the ipk is built.
# UNZIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNZIP_BUILD_DIR=$(BUILD_DIR)/unzip
UNZIP_SOURCE_DIR=$(SOURCE_DIR)/unzip
UNZIP_IPK_DIR=$(BUILD_DIR)/unzip-$(UNZIP_VERSION)-ipk
UNZIP_IPK=$(BUILD_DIR)/unzip_$(UNZIP_VERSION)-$(UNZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNZIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNZIP_SITE)/$(UNZIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unzip-source: $(DL_DIR)/$(UNZIP_SOURCE) $(UNZIP_PATCHES)

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
$(UNZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(UNZIP_SOURCE) $(UNZIP_PATCHES)
	rm -rf $(BUILD_DIR)/$(UNZIP_DIR) $(UNZIP_BUILD_DIR)
	$(UNZIP_UNZIP) $(DL_DIR)/$(UNZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNZIP_PATCHES)" ; \
		then cat $(UNZIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UNZIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNZIP_DIR)" != "$(UNZIP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UNZIP_DIR) $(UNZIP_BUILD_DIR) ; \
	fi
	touch $(UNZIP_BUILD_DIR)/.configured

unzip-unpack: $(UNZIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNZIP_BUILD_DIR)/.built: $(UNZIP_BUILD_DIR)/.configured
	rm -f $(UNZIP_BUILD_DIR)/.built
	$(MAKE) -C $(UNZIP_BUILD_DIR) -f unix/Makefile generic \
		$(TARGET_CONFIGURE_OPTS) LD=$(TARGET_CC)
	touch $(UNZIP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
unzip: $(UNZIP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unzip
#
$(UNZIP_IPK_DIR)/CONTROL/control:
	@install -d $(UNZIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: unzip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNZIP_PRIORITY)" >>$@
	@echo "Section: $(UNZIP_SECTION)" >>$@
	@echo "Version: $(UNZIP_VERSION)-$(UNZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNZIP_MAINTAINER)" >>$@
	@echo "Source: $(UNZIP_SITE)/$(UNZIP_SOURCE)" >>$@
	@echo "Description: $(UNZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(UNZIP_DEPENDS)" >>$@
	@echo "Suggests: $(UNZIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNZIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNZIP_IPK_DIR)/opt/sbin or $(UNZIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNZIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNZIP_IPK_DIR)/opt/etc/unzip/...
# Documentation files should be installed in $(UNZIP_IPK_DIR)/opt/doc/unzip/...
# Daemon startup scripts should be installed in $(UNZIP_IPK_DIR)/opt/etc/init.d/S??unzip
#
# You may need to patch your application to make it use these locations.
#
$(UNZIP_IPK): $(UNZIP_BUILD_DIR)/.built
	rm -rf $(UNZIP_IPK_DIR) $(BUILD_DIR)/unzip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNZIP_BUILD_DIR) -f unix/Makefile prefix=$(UNZIP_IPK_DIR)/opt install
	$(MAKE) $(UNZIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNZIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unzip-ipk: $(UNZIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unzip-clean:
	rm -f $(UNZIP_BUILD_DIR)/.built
	-$(MAKE) -C $(UNZIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unzip-dirclean:
	rm -rf $(BUILD_DIR)/$(UNZIP_DIR) $(UNZIP_BUILD_DIR) $(UNZIP_IPK_DIR) $(UNZIP_IPK)
