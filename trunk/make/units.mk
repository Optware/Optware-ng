###########################################################
#
# units
#
###########################################################

# You must replace "units" and "UNITS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UNITS_VERSION, UNITS_SITE and UNITS_SOURCE define
# the upstream location of the source code for the package.
# UNITS_DIR is the directory which is created when the source
# archive is unpacked.
# UNITS_UNZIP is the command used to unzip the source.
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
UNITS_SITE=ftp://ftp.gnu.org/gnu/units/
UNITS_VERSION=1.87
UNITS_SOURCE=units-$(UNITS_VERSION).tar.gz
UNITS_DIR=units-$(UNITS_VERSION)
UNITS_UNZIP=zcat
UNITS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNITS_DESCRIPTION=GNU units converts between different systems of units.
UNITS_SECTION=misc
UNITS_PRIORITY=optional
UNITS_DEPENDS=readline

#
# UNITS_IPK_VERSION should be incremented when the ipk changes.
#
UNITS_IPK_VERSION=1

#
# UNITS_CONFFILES should be a list of user-editable files
# UNITS_CONFFILES=/opt/etc/units.conf /opt/etc/init.d/SXXunits

#
# UNITS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UNITS_PATCHES=$(UNITS_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNITS_CPPFLAGS=
UNITS_LDFLAGS=

#
# UNITS_BUILD_DIR is the directory in which the build is done.
# UNITS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNITS_IPK_DIR is the directory in which the ipk is built.
# UNITS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNITS_BUILD_DIR=$(BUILD_DIR)/units
UNITS_SOURCE_DIR=$(SOURCE_DIR)/units
UNITS_IPK_DIR=$(BUILD_DIR)/units-$(UNITS_VERSION)-ipk
UNITS_IPK=$(BUILD_DIR)/units_$(UNITS_VERSION)-$(UNITS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: units-source units-unpack units units-stage units-ipk units-clean units-dirclean units-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNITS_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNITS_SITE)/$(UNITS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
units-source: $(DL_DIR)/$(UNITS_SOURCE) $(UNITS_PATCHES)

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
$(UNITS_BUILD_DIR)/.configured: $(DL_DIR)/$(UNITS_SOURCE) $(UNITS_PATCHES) make/units.mk
	$(MAKE) readline-stage
	rm -rf $(BUILD_DIR)/$(UNITS_DIR) $(UNITS_BUILD_DIR)
	$(UNITS_UNZIP) $(DL_DIR)/$(UNITS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNITS_PATCHES)"; \
		then cat $(UNITS_PATCHES) | patch -d $(BUILD_DIR)/$(UNITS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(UNITS_DIR) $(UNITS_BUILD_DIR)
	(cd $(UNITS_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(UNITS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNITS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

units-unpack: $(UNITS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNITS_BUILD_DIR)/.built: $(UNITS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UNITS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
units: $(UNITS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNITS_BUILD_DIR)/.staged: $(UNITS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UNITS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

units-stage: $(UNITS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/units
#
$(UNITS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: units" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNITS_PRIORITY)" >>$@
	@echo "Section: $(UNITS_SECTION)" >>$@
	@echo "Version: $(UNITS_VERSION)-$(UNITS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNITS_MAINTAINER)" >>$@
	@echo "Source: $(UNITS_SITE)/$(UNITS_SOURCE)" >>$@
	@echo "Description: $(UNITS_DESCRIPTION)" >>$@
	@echo "Depends: $(UNITS_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNITS_IPK_DIR)/opt/sbin or $(UNITS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNITS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNITS_IPK_DIR)/opt/etc/units/...
# Documentation files should be installed in $(UNITS_IPK_DIR)/opt/doc/units/...
# Daemon startup scripts should be installed in $(UNITS_IPK_DIR)/opt/etc/init.d/S??units
#
# You may need to patch your application to make it use these locations.
#
$(UNITS_IPK): $(UNITS_BUILD_DIR)/.built
	rm -rf $(UNITS_IPK_DIR) $(BUILD_DIR)/units_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNITS_BUILD_DIR) DESTDIR=$(UNITS_IPK_DIR) install
	$(STRIP_COMMAND) $(UNITS_IPK_DIR)/opt/bin/units
	$(MAKE) $(UNITS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNITS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
units-ipk: $(UNITS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
units-clean:
	-$(MAKE) -C $(UNITS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
units-dirclean:
	rm -rf $(BUILD_DIR)/$(UNITS_DIR) $(UNITS_BUILD_DIR) $(UNITS_IPK_DIR) $(UNITS_IPK)

#
# Some sanity check for the package.
#
units-check: $(UNITS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UNITS_IPK)
