###########################################################
#
# radiusclient-ng
#
###########################################################
#
# RADIUSCLIENT_NG_VERSION, RADIUSCLIENT_NG_SITE and RADIUSCLIENT_NG_SOURCE define
# the upstream location of the source code for the package.
# RADIUSCLIENT_NG_DIR is the directory which is created when the source
# archive is unpacked.
# RADIUSCLIENT_NG_UNZIP is the command used to unzip the source.
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
RADIUSCLIENT_NG_SITE=http://ftp.iptel.org/pub/radiusclient-ng
RADIUSCLIENT_NG_VERSION=0.5.3
RADIUSCLIENT_NG_SOURCE=radiusclient-ng-$(RADIUSCLIENT_NG_VERSION).tar.gz
RADIUSCLIENT_NG_DIR=radiusclient-ng-$(RADIUSCLIENT_NG_VERSION)
RADIUSCLIENT_NG_UNZIP=zcat
RADIUSCLIENT_NG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RADIUSCLIENT_NG_DESCRIPTION=easy-to-use and standard compliant \
library suitable for developing free and commercial software that need \
support for a RADIUS protocol (RFCs 2138 and 2139)
RADIUSCLIENT_NG_SECTION=util
RADIUSCLIENT_NG_PRIORITY=optional
RADIUSCLIENT_NG_DEPENDS=
RADIUSCLIENT_NG_SUGGESTS=
RADIUSCLIENT_NG_CONFLICTS=

#
# RADIUSCLIENT_NG_IPK_VERSION should be incremented when the ipk changes.
#
RADIUSCLIENT_NG_IPK_VERSION=1

#
# RADIUSCLIENT_NG_CONFFILES should be a list of user-editable files
#RADIUSCLIENT_NG_CONFFILES=/opt/etc/radiusclient-ng.conf /opt/etc/init.d/SXXradiusclient-ng

#
# RADIUSCLIENT_NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RADIUSCLIENT_NG_PATCHES=$(RADIUSCLIENT_NG_SOURCE_DIR)/radiusclient-ng.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RADIUSCLIENT_NG_CPPFLAGS=
RADIUSCLIENT_NG_LDFLAGS=

#
# RADIUSCLIENT_NG_BUILD_DIR is the directory in which the build is done.
# RADIUSCLIENT_NG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RADIUSCLIENT_NG_IPK_DIR is the directory in which the ipk is built.
# RADIUSCLIENT_NG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RADIUSCLIENT_NG_BUILD_DIR=$(BUILD_DIR)/radiusclient-ng
RADIUSCLIENT_NG_SOURCE_DIR=$(SOURCE_DIR)/radiusclient-ng
RADIUSCLIENT_NG_IPK_DIR=$(BUILD_DIR)/radiusclient-ng-$(RADIUSCLIENT_NG_VERSION)-ipk
RADIUSCLIENT_NG_IPK=$(BUILD_DIR)/radiusclient-ng_$(RADIUSCLIENT_NG_VERSION)-$(RADIUSCLIENT_NG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: radiusclient-ng-source radiusclient-ng-unpack radiusclient-ng radiusclient-ng-stage radiusclient-ng-ipk radiusclient-ng-clean radiusclient-ng-dirclean radiusclient-ng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RADIUSCLIENT_NG_SOURCE):
	$(WGET) -P $(DL_DIR) $(RADIUSCLIENT_NG_SITE)/$(RADIUSCLIENT_NG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
radiusclient-ng-source: $(DL_DIR)/$(RADIUSCLIENT_NG_SOURCE) $(RADIUSCLIENT_NG_PATCHES)

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
$(RADIUSCLIENT_NG_BUILD_DIR)/.configured: $(DL_DIR)/$(RADIUSCLIENT_NG_SOURCE) $(RADIUSCLIENT_NG_PATCHES) make/radiusclient-ng.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RADIUSCLIENT_NG_DIR) $(RADIUSCLIENT_NG_BUILD_DIR)
	$(RADIUSCLIENT_NG_UNZIP) $(DL_DIR)/$(RADIUSCLIENT_NG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RADIUSCLIENT_NG_PATCHES)" ; \
		then cat $(RADIUSCLIENT_NG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RADIUSCLIENT_NG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RADIUSCLIENT_NG_DIR)" != "$(RADIUSCLIENT_NG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RADIUSCLIENT_NG_DIR) $(RADIUSCLIENT_NG_BUILD_DIR) ; \
	fi
	(cd $(RADIUSCLIENT_NG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RADIUSCLIENT_NG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RADIUSCLIENT_NG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(RADIUSCLIENT_NG_BUILD_DIR)/libtool
	touch $(RADIUSCLIENT_NG_BUILD_DIR)/.configured

radiusclient-ng-unpack: $(RADIUSCLIENT_NG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RADIUSCLIENT_NG_BUILD_DIR)/.built: $(RADIUSCLIENT_NG_BUILD_DIR)/.configured
	rm -f $(RADIUSCLIENT_NG_BUILD_DIR)/.built
	$(MAKE) -C $(RADIUSCLIENT_NG_BUILD_DIR)
	touch $(RADIUSCLIENT_NG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
radiusclient-ng: $(RADIUSCLIENT_NG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RADIUSCLIENT_NG_BUILD_DIR)/.staged: $(RADIUSCLIENT_NG_BUILD_DIR)/.built
	rm -f $(RADIUSCLIENT_NG_BUILD_DIR)/.staged
	$(MAKE) -C $(RADIUSCLIENT_NG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RADIUSCLIENT_NG_BUILD_DIR)/.staged

radiusclient-ng-stage: $(RADIUSCLIENT_NG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/radiusclient-ng
#
$(RADIUSCLIENT_NG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: radiusclient-ng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RADIUSCLIENT_NG_PRIORITY)" >>$@
	@echo "Section: $(RADIUSCLIENT_NG_SECTION)" >>$@
	@echo "Version: $(RADIUSCLIENT_NG_VERSION)-$(RADIUSCLIENT_NG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RADIUSCLIENT_NG_MAINTAINER)" >>$@
	@echo "Source: $(RADIUSCLIENT_NG_SITE)/$(RADIUSCLIENT_NG_SOURCE)" >>$@
	@echo "Description: $(RADIUSCLIENT_NG_DESCRIPTION)" >>$@
	@echo "Depends: $(RADIUSCLIENT_NG_DEPENDS)" >>$@
	@echo "Suggests: $(RADIUSCLIENT_NG_SUGGESTS)" >>$@
	@echo "Conflicts: $(RADIUSCLIENT_NG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RADIUSCLIENT_NG_IPK_DIR)/opt/sbin or $(RADIUSCLIENT_NG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RADIUSCLIENT_NG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RADIUSCLIENT_NG_IPK_DIR)/opt/etc/radiusclient-ng/...
# Documentation files should be installed in $(RADIUSCLIENT_NG_IPK_DIR)/opt/doc/radiusclient-ng/...
# Daemon startup scripts should be installed in $(RADIUSCLIENT_NG_IPK_DIR)/opt/etc/init.d/S??radiusclient-ng
#
# You may need to patch your application to make it use these locations.
#
$(RADIUSCLIENT_NG_IPK): $(RADIUSCLIENT_NG_BUILD_DIR)/.built
	rm -rf $(RADIUSCLIENT_NG_IPK_DIR) $(BUILD_DIR)/radiusclient-ng_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RADIUSCLIENT_NG_BUILD_DIR) DESTDIR=$(RADIUSCLIENT_NG_IPK_DIR) install-strip
	$(MAKE) $(RADIUSCLIENT_NG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RADIUSCLIENT_NG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
radiusclient-ng-ipk: $(RADIUSCLIENT_NG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
radiusclient-ng-clean:
	rm -f $(RADIUSCLIENT_NG_BUILD_DIR)/.built
	-$(MAKE) -C $(RADIUSCLIENT_NG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
radiusclient-ng-dirclean:
	rm -rf $(BUILD_DIR)/$(RADIUSCLIENT_NG_DIR) $(RADIUSCLIENT_NG_BUILD_DIR) $(RADIUSCLIENT_NG_IPK_DIR) $(RADIUSCLIENT_NG_IPK)
#
#
# Some sanity check for the package.
#
radiusclient-ng-check: $(RADIUSCLIENT_NG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RADIUSCLIENT_NG_IPK)
