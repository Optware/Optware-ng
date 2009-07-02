###########################################################
#
# gdchart
#
###########################################################

# You must replace "gdchart" and "GDCHART" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GDCHART_VERSION, GDCHART_SITE and GDCHART_SOURCE define
# the upstream location of the source code for the package.
# GDCHART_DIR is the directory which is created when the source
# archive is unpacked.
# GDCHART_UNZIP is the command used to unzip the source.
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
GDCHART_SITE=http://www.fred.net/brv/chart
GDCHART_VERSION=0.11.5dev
GDCHART_SOURCE=gdchart$(GDCHART_VERSION).tar.gz
GDCHART_DIR=gdchart$(GDCHART_VERSION)
GDCHART_UNZIP=zcat
GDCHART_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GDCHART_DESCRIPTION=Easy to use C API for create charts and graphs in PNG, GIF and WBMP format.
GDCHART_SECTION=misc
GDCHART_PRIORITY=optional
GDCHART_DEPENDS=libgd,zlib,libpng,freetype,libjpeg
GDCHART_SUGGESTS=
GDCHART_CONFLICTS=

#
# GDCHART_IPK_VERSION should be incremented when the ipk changes.
#
GDCHART_IPK_VERSION=2

#
# GDCHART_CONFFILES should be a list of user-editable files
#GDCHART_CONFFILES=/opt/etc/gdchart.conf /opt/etc/init.d/SXXgdchart

#
# GDCHART_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GDCHART_PATCHES=$(GDCHART_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GDCHART_CPPFLAGS=
GDCHART_LDFLAGS=

#
# GDCHART_BUILD_DIR is the directory in which the build is done.
# GDCHART_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GDCHART_IPK_DIR is the directory in which the ipk is built.
# GDCHART_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GDCHART_BUILD_DIR=$(BUILD_DIR)/gdchart
GDCHART_SOURCE_DIR=$(SOURCE_DIR)/gdchart
GDCHART_IPK_DIR=$(BUILD_DIR)/gdchart-$(GDCHART_VERSION)-ipk
GDCHART_IPK=$(BUILD_DIR)/gdchart_$(GDCHART_VERSION)-$(GDCHART_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GDCHART_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDCHART_SITE)/$(GDCHART_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gdchart-source: $(DL_DIR)/$(GDCHART_SOURCE) $(GDCHART_PATCHES)

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
$(GDCHART_BUILD_DIR)/.configured: $(DL_DIR)/$(GDCHART_SOURCE) $(GDCHART_PATCHES)
	$(MAKE) libgd-stage zlib-stage libpng-stage freetype-stage libjpeg-stage
	rm -rf $(BUILD_DIR)/$(GDCHART_DIR) $(GDCHART_BUILD_DIR)
	$(GDCHART_UNZIP) $(DL_DIR)/$(GDCHART_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GDCHART_PATCHES) | patch -d $(BUILD_DIR)/$(GDCHART_DIR) -p1
	mv $(BUILD_DIR)/$(GDCHART_DIR) $(GDCHART_BUILD_DIR)
	touch $(GDCHART_BUILD_DIR)/.configured

gdchart-unpack: $(GDCHART_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GDCHART_BUILD_DIR)/.built: $(GDCHART_BUILD_DIR)/.configured
	rm -f $(GDCHART_BUILD_DIR)/.built
	$(MAKE) -C $(GDCHART_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		PREFIX_INC=$(STAGING_INCLUDE_DIR)/ \
		PREFIX_LIB=$(STAGING_LIB_DIR)/ \
		GD_INCL=$(STAGING_INCLUDE_DIR)/ \
		GD_LD=$(STAGING_LIB_DIR)/ \
                CFLAGS="$(STAGING_CPPFLAGS) $(GDCHART_CPPFLAGS)" \
                LDFLAGS="$(STAGING_LDFLAGS) $(GDCHART_LDFLAGS)" \
		all
	touch $(GDCHART_BUILD_DIR)/.built


#
# This is the build convenience target.
#
gdchart: $(GDCHART_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GDCHART_BUILD_DIR)/.staged: $(GDCHART_BUILD_DIR)/.built
	rm -f $(GDCHART_BUILD_DIR)/.staged
	$(MAKE) -C $(GDCHART_BUILD_DIR) \
		PREFIX_INC=$(STAGING_INCLUDE_DIR) \
		PREFIX_LIB=$(STAGING_LIB_DIR) \
		GD_INCL=$(STAGING_INCLUDE_DIR)/ \
		GD_LD=$(STAGING_LIB_DIR)/ \
		install
	touch $(GDCHART_BUILD_DIR)/.staged

gdchart-stage: $(GDCHART_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gdchart
#
$(GDCHART_IPK_DIR)/CONTROL/control:
	@install -d $(GDCHART_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gdchart" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GDCHART_PRIORITY)" >>$@
	@echo "Section: $(GDCHART_SECTION)" >>$@
	@echo "Version: $(GDCHART_VERSION)-$(GDCHART_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GDCHART_MAINTAINER)" >>$@
	@echo "Source: $(GDCHART_SITE)/$(GDCHART_SOURCE)" >>$@
	@echo "Description: $(GDCHART_DESCRIPTION)" >>$@
	@echo "Depends: $(GDCHART_DEPENDS)" >>$@
	@echo "Suggests: $(GDCHART_SUGGESTS)" >>$@
	@echo "Conflicts: $(GDCHART_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GDCHART_IPK_DIR)/opt/sbin or $(GDCHART_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GDCHART_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GDCHART_IPK_DIR)/opt/etc/gdchart/...
# Documentation files should be installed in $(GDCHART_IPK_DIR)/opt/doc/gdchart/...
# Daemon startup scripts should be installed in $(GDCHART_IPK_DIR)/opt/etc/init.d/S??gdchart
#
# You may need to patch your application to make it use these locations.
#
$(GDCHART_IPK): $(GDCHART_BUILD_DIR)/.built
	rm -rf $(GDCHART_IPK_DIR) $(BUILD_DIR)/gdchart_*_$(TARGET_ARCH).ipk
	install -d $(GDCHART_IPK_DIR)/opt/include $(GDCHART_IPK_DIR)/opt/lib
	$(MAKE) -C $(GDCHART_BUILD_DIR) \
		PREFIX_INC=$(GDCHART_IPK_DIR)/opt/include \
		PREFIX_LIB=$(GDCHART_IPK_DIR)/opt/lib \
		GD_INCL=$(STAGING_INCLUDE_DIR)/ \
		GD_LD=$(STAGING_LIB_DIR)/ \
		install
	$(MAKE) $(GDCHART_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDCHART_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gdchart-ipk: $(GDCHART_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gdchart-clean:
	-$(MAKE) -C $(GDCHART_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gdchart-dirclean:
	rm -rf $(BUILD_DIR)/$(GDCHART_DIR) $(GDCHART_BUILD_DIR) $(GDCHART_IPK_DIR) $(GDCHART_IPK)
