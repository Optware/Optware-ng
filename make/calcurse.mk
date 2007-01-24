###########################################################
#
# calcurse
#
###########################################################
#
# CALCURSE_VERSION, CALCURSE_SITE and CALCURSE_SOURCE define
# the upstream location of the source code for the package.
# CALCURSE_DIR is the directory which is created when the source
# archive is unpacked.
# CALCURSE_UNZIP is the command used to unzip the source.
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
CALCURSE_SITE=http://culot.org/cgi-bin/get.cgi?
CALCURSE_VERSION=1.7
CALCURSE_SOURCE=calcurse-$(CALCURSE_VERSION).tar.gz
CALCURSE_DIR=calcurse-$(CALCURSE_VERSION)
CALCURSE_UNZIP=zcat
CALCURSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CALCURSE_DESCRIPTION=Calcurse is a text-based personal organizer which helps keeping track of events and everyday tasks.
CALCURSE_SECTION=misc
CALCURSE_PRIORITY=optional
CALCURSE_DEPENDS=
CALCURSE_SUGGESTS=
CALCURSE_CONFLICTS=

#
# CALCURSE_IPK_VERSION should be incremented when the ipk changes.
#
CALCURSE_IPK_VERSION=1

#
# CALCURSE_CONFFILES should be a list of user-editable files
#CALCURSE_CONFFILES=/opt/etc/calcurse.conf /opt/etc/init.d/SXXcalcurse

#
# CALCURSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CALCURSE_PATCHES=$(CALCURSE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CALCURSE_CPPFLAGS=
CALCURSE_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
CALCURSE_CONFIG_ENV=ac_cv_func_malloc_0_nonnull=yes
else
CALCURSE_CONFIG_ENV=
endif

#
# CALCURSE_BUILD_DIR is the directory in which the build is done.
# CALCURSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CALCURSE_IPK_DIR is the directory in which the ipk is built.
# CALCURSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CALCURSE_BUILD_DIR=$(BUILD_DIR)/calcurse
CALCURSE_SOURCE_DIR=$(SOURCE_DIR)/calcurse
CALCURSE_IPK_DIR=$(BUILD_DIR)/calcurse-$(CALCURSE_VERSION)-ipk
CALCURSE_IPK=$(BUILD_DIR)/calcurse_$(CALCURSE_VERSION)-$(CALCURSE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: calcurse-source calcurse-unpack calcurse calcurse-stage calcurse-ipk calcurse-clean calcurse-dirclean calcurse-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CALCURSE_SOURCE):
	$(WGET) -O $(DL_DIR)/$(CALCURSE_SOURCE) "$(CALCURSE_SITE)$(CALCURSE_SOURCE)"

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
calcurse-source: $(DL_DIR)/$(CALCURSE_SOURCE) $(CALCURSE_PATCHES)

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
$(CALCURSE_BUILD_DIR)/.configured: $(DL_DIR)/$(CALCURSE_SOURCE) $(CALCURSE_PATCHES) make/calcurse.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(CALCURSE_DIR) $(CALCURSE_BUILD_DIR)
	$(CALCURSE_UNZIP) $(DL_DIR)/$(CALCURSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CALCURSE_PATCHES)" ; \
		then cat $(CALCURSE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CALCURSE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CALCURSE_DIR)" != "$(CALCURSE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CALCURSE_DIR) $(CALCURSE_BUILD_DIR) ; \
	fi
	(cd $(CALCURSE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CALCURSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CALCURSE_LDFLAGS)" \
		$(CALCURSE_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CALCURSE_BUILD_DIR)/libtool
	touch $@

calcurse-unpack: $(CALCURSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CALCURSE_BUILD_DIR)/.built: $(CALCURSE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CALCURSE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
calcurse: $(CALCURSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CALCURSE_BUILD_DIR)/.staged: $(CALCURSE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(CALCURSE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

calcurse-stage: $(CALCURSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/calcurse
#
$(CALCURSE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: calcurse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CALCURSE_PRIORITY)" >>$@
	@echo "Section: $(CALCURSE_SECTION)" >>$@
	@echo "Version: $(CALCURSE_VERSION)-$(CALCURSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CALCURSE_MAINTAINER)" >>$@
	@echo "Source: $(CALCURSE_SITE)/$(CALCURSE_SOURCE)" >>$@
	@echo "Description: $(CALCURSE_DESCRIPTION)" >>$@
	@echo "Depends: $(CALCURSE_DEPENDS)" >>$@
	@echo "Suggests: $(CALCURSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(CALCURSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CALCURSE_IPK_DIR)/opt/sbin or $(CALCURSE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CALCURSE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CALCURSE_IPK_DIR)/opt/etc/calcurse/...
# Documentation files should be installed in $(CALCURSE_IPK_DIR)/opt/doc/calcurse/...
# Daemon startup scripts should be installed in $(CALCURSE_IPK_DIR)/opt/etc/init.d/S??calcurse
#
# You may need to patch your application to make it use these locations.
#
$(CALCURSE_IPK): $(CALCURSE_BUILD_DIR)/.built
	rm -rf $(CALCURSE_IPK_DIR) $(BUILD_DIR)/calcurse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CALCURSE_BUILD_DIR) DESTDIR=$(CALCURSE_IPK_DIR) install-strip
#	install -d $(CALCURSE_IPK_DIR)/opt/etc/
#	install -m 644 $(CALCURSE_SOURCE_DIR)/calcurse.conf $(CALCURSE_IPK_DIR)/opt/etc/calcurse.conf
#	install -d $(CALCURSE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CALCURSE_SOURCE_DIR)/rc.calcurse $(CALCURSE_IPK_DIR)/opt/etc/init.d/SXXcalcurse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXcalcurse
	$(MAKE) $(CALCURSE_IPK_DIR)/CONTROL/control
#	install -m 755 $(CALCURSE_SOURCE_DIR)/postinst $(CALCURSE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CALCURSE_SOURCE_DIR)/prerm $(CALCURSE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(CALCURSE_CONFFILES) | sed -e 's/ /\n/g' > $(CALCURSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CALCURSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
calcurse-ipk: $(CALCURSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
calcurse-clean:
	rm -f $(CALCURSE_BUILD_DIR)/.built
	-$(MAKE) -C $(CALCURSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
calcurse-dirclean:
	rm -rf $(BUILD_DIR)/$(CALCURSE_DIR) $(CALCURSE_BUILD_DIR) $(CALCURSE_IPK_DIR) $(CALCURSE_IPK)
#
#
# Some sanity check for the package.
#
calcurse-check: $(CALCURSE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CALCURSE_IPK)
