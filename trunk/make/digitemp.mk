###########################################################
#
# digitemp
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#

DIGITEMP_SITE=http://www.digitemp.com/software/linux
DIGITEMP_VERSION=3.6.0
DIGITEMP_SOURCE=digitemp-$(DIGITEMP_VERSION).tar.gz
DIGITEMP_DIR=digitemp-$(DIGITEMP_VERSION)
DIGITEMP_UNZIP=zcat
DIGITEMP_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
DIGITEMP_DESCRIPTION=Reads 1-Wire Temperature sensor (http://www.digitemp.com)
DIGITEMP_SECTION=misc
DIGITEMP_PRIORITY=optional
DIGITEMP_DEPENDS=libusb
DIGITEMP_SUGGESTS=
DIGITEMP_CONFLICTS=

#
# DIGITEMP_IPK_VERSION should be incremented when the ipk changes.
#
DIGITEMP_IPK_VERSION=1

#
# DIGITEMP_CONFFILES should be a list of user-editable files
# DIGITEMP_CONFFILES=/opt/etc/digitemp.conf /opt/etc/init.d/SXXdigitemp

#
# DIGITEMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DIGITEMP_PATCHES=$(DIGITEMP_SOURCE_DIR)/Makefile.patch $(DIGITEMP_SOURCE_DIR)/linebuf.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIGITEMP_CPPFLAGS=
DIGITEMP_LDFLAGS=

#
# DIGITEMP_BUILD_DIR is the directory in which the build is done.
# DIGITEMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIGITEMP_IPK_DIR is the directory in which the ipk is built.
# DIGITEMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIGITEMP_BUILD_DIR=$(BUILD_DIR)/digitemp
DIGITEMP_SOURCE_DIR=$(SOURCE_DIR)/digitemp
DIGITEMP_IPK_DIR=$(BUILD_DIR)/digitemp-$(DIGITEMP_VERSION)-ipk
DIGITEMP_IPK=$(BUILD_DIR)/digitemp_$(DIGITEMP_VERSION)-$(DIGITEMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: digitemp-source digitemp-unpack digitemp digitemp-stage digitemp-ipk digitemp-clean digitemp-dirclean digitemp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIGITEMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIGITEMP_SITE)/$(DIGITEMP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
digitemp-source: $(DL_DIR)/$(DIGITEMP_SOURCE) $(DIGITEMP_PATCHES)

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
$(DIGITEMP_BUILD_DIR)/.configured: $(DL_DIR)/$(DIGITEMP_SOURCE) $(DIGITEMP_PATCHES)
	$(MAKE) libusb-stage
	rm -rf $(BUILD_DIR)/$(DIGITEMP_DIR) $(DIGITEMP_BUILD_DIR)
	$(DIGITEMP_UNZIP) $(DL_DIR)/$(DIGITEMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DIGITEMP_PATCHES)" ; \
		then cat $(DIGITEMP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DIGITEMP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DIGITEMP_DIR)" != "$(DIGITEMP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DIGITEMP_DIR) $(DIGITEMP_BUILD_DIR) ; \
	fi
	touch $(DIGITEMP_BUILD_DIR)/.configured
#	sed -i '/^CC/d' $(DIGITEMP_BUILD_DIR)/Makefile

digitemp-unpack: $(DIGITEMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DIGITEMP_BUILD_DIR)/.built: $(DIGITEMP_BUILD_DIR)/.configured
	echo
	echo $(TARGET_CONFIGURE_OPTS)
	echo
	rm -f $(DIGITEMP_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(DIGITEMP_BUILD_DIR) \
			STAGING_DIR=$(STAGING_DIR) ds9097 ds9097u 
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(DIGITEMP_BUILD_DIR) \
	                STAGING_DIR=$(STAGING_DIR) clean ds2490
	touch $(DIGITEMP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
digitemp: $(DIGITEMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DIGITEMP_BUILD_DIR)/.staged: $(DIGITEMP_BUILD_DIR)/.built
#	rm -f $(DIGITEMP_BUILD_DIR)/.staged
#	$(MAKE) -C $(DIGITEMP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(DIGITEMP_BUILD_DIR)/.staged
#
#digitemp-stage: $(DIGITEMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/digitemp
#
$(DIGITEMP_IPK_DIR)/CONTROL/control:
	@install -d $(DIGITEMP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: digitemp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIGITEMP_PRIORITY)" >>$@
	@echo "Section: $(DIGITEMP_SECTION)" >>$@
	@echo "Version: $(DIGITEMP_VERSION)-$(DIGITEMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIGITEMP_MAINTAINER)" >>$@
	@echo "Source: $(DIGITEMP_SITE)/$(DIGITEMP_SOURCE)" >>$@
	@echo "Description: $(DIGITEMP_DESCRIPTION)" >>$@
	@echo "Depends: $(DIGITEMP_DEPENDS)" >>$@
	@echo "Suggests: $(DIGITEMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(DIGITEMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIGITEMP_IPK_DIR)/opt/sbin or $(DIGITEMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIGITEMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIGITEMP_IPK_DIR)/opt/etc/digitemp/...
# Documentation files should be installed in $(DIGITEMP_IPK_DIR)/opt/doc/digitemp/...
# Daemon startup scripts should be installed in $(DIGITEMP_IPK_DIR)/opt/etc/init.d/S??digitemp
#
# You may need to patch your application to make it use these locations.
#
$(DIGITEMP_IPK): $(DIGITEMP_BUILD_DIR)/.built
	rm -rf $(DIGITEMP_IPK_DIR) $(BUILD_DIR)/digitemp_*_$(TARGET_ARCH).ipk
	install -d $(DIGITEMP_IPK_DIR)/opt/bin
	install -m 755 $(DIGITEMP_BUILD_DIR)/digitemp_DS9097 $(DIGITEMP_IPK_DIR)/opt/bin
	install -m 755 $(DIGITEMP_BUILD_DIR)/digitemp_DS9097U $(DIGITEMP_IPK_DIR)/opt/bin
	install -m 755 $(DIGITEMP_BUILD_DIR)/digitemp_DS2490 $(DIGITEMP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(DIGITEMP_IPK_DIR)/opt/bin/digitemp_DS9097
	$(STRIP_COMMAND) $(DIGITEMP_IPK_DIR)/opt/bin/digitemp_DS9097U
	$(STRIP_COMMAND) $(DIGITEMP_IPK_DIR)/opt/bin/digitemp_DS2490
	$(MAKE) $(DIGITEMP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIGITEMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
digitemp-ipk: $(DIGITEMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
digitemp-clean:
	rm -f $(DIGITEMP_BUILD_DIR)/.built
	-$(MAKE) -C $(DIGITEMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
digitemp-dirclean:
	rm -rf $(BUILD_DIR)/$(DIGITEMP_DIR) $(DIGITEMP_BUILD_DIR) $(DIGITEMP_IPK_DIR) $(DIGITEMP_IPK)

#
# Some sanity check for the package.
#
digitemp-check: $(DIGITEMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIGITEMP_IPK)
