###########################################################
#
# bridge-utils
#
###########################################################
#
# BRIDGE-UTILS_VERSION, BRIDGE-UTILS_SITE and BRIDGE-UTILS_SOURCE define
# the upstream location of the source code for the package.
# BRIDGE-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BRIDGE-UTILS_UNZIP is the command used to unzip the source.
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
BRIDGE-UTILS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bridge
BRIDGE-UTILS_VERSION=1.2
BRIDGE-UTILS_SOURCE=bridge-utils-$(BRIDGE-UTILS_VERSION).tar.gz
BRIDGE-UTILS_DIR=bridge-utils-$(BRIDGE-UTILS_VERSION)
BRIDGE-UTILS_UNZIP=zcat
BRIDGE-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BRIDGE-UTILS_DESCRIPTION=Describe bridge-utils here.
BRIDGE-UTILS_SECTION=net
BRIDGE-UTILS_PRIORITY=optional
BRIDGE-UTILS_DEPENDS=
BRIDGE-UTILS_SUGGESTS=
BRIDGE-UTILS_CONFLICTS=

#
# BRIDGE-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
BRIDGE-UTILS_IPK_VERSION=1

#
# BRIDGE-UTILS_CONFFILES should be a list of user-editable files
#BRIDGE-UTILS_CONFFILES=/opt/etc/bridge-utils.conf /opt/etc/init.d/SXXbridge-utils

#
# BRIDGE-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BRIDGE-UTILS_PATCHES=$(BRIDGE-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BRIDGE-UTILS_CPPFLAGS=
BRIDGE-UTILS_LDFLAGS=

#
# BRIDGE-UTILS_BUILD_DIR is the directory in which the build is done.
# BRIDGE-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BRIDGE-UTILS_IPK_DIR is the directory in which the ipk is built.
# BRIDGE-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BRIDGE-UTILS_BUILD_DIR=$(BUILD_DIR)/bridge-utils
BRIDGE-UTILS_SOURCE_DIR=$(SOURCE_DIR)/bridge-utils
BRIDGE-UTILS_IPK_DIR=$(BUILD_DIR)/bridge-utils-$(BRIDGE-UTILS_VERSION)-ipk
BRIDGE-UTILS_IPK=$(BUILD_DIR)/bridge-utils_$(BRIDGE-UTILS_VERSION)-$(BRIDGE-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bridge-utils-source bridge-utils-unpack bridge-utils bridge-utils-stage bridge-utils-ipk bridge-utils-clean bridge-utils-dirclean bridge-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BRIDGE-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(BRIDGE-UTILS_SITE)/$(BRIDGE-UTILS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(BRIDGE-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bridge-utils-source: $(DL_DIR)/$(BRIDGE-UTILS_SOURCE) $(BRIDGE-UTILS_PATCHES)

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
$(BRIDGE-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BRIDGE-UTILS_SOURCE) $(BRIDGE-UTILS_PATCHES) make/bridge-utils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BRIDGE-UTILS_DIR) $(BRIDGE-UTILS_BUILD_DIR)
	$(BRIDGE-UTILS_UNZIP) $(DL_DIR)/$(BRIDGE-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BRIDGE-UTILS_PATCHES)" ; \
		then cat $(BRIDGE-UTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BRIDGE-UTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BRIDGE-UTILS_DIR)" != "$(BRIDGE-UTILS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BRIDGE-UTILS_DIR) $(BRIDGE-UTILS_BUILD_DIR) ; \
	fi
	(cd $(BRIDGE-UTILS_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BRIDGE-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BRIDGE-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(BRIDGE-UTILS_BUILD_DIR)/libtool
	touch $@

bridge-utils-unpack: $(BRIDGE-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BRIDGE-UTILS_BUILD_DIR)/.built: $(BRIDGE-UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(BRIDGE-UTILS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
bridge-utils: $(BRIDGE-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BRIDGE-UTILS_BUILD_DIR)/.staged: $(BRIDGE-UTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(BRIDGE-UTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

bridge-utils-stage: $(BRIDGE-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bridge-utils
#
$(BRIDGE-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bridge-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BRIDGE-UTILS_PRIORITY)" >>$@
	@echo "Section: $(BRIDGE-UTILS_SECTION)" >>$@
	@echo "Version: $(BRIDGE-UTILS_VERSION)-$(BRIDGE-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BRIDGE-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(BRIDGE-UTILS_SITE)/$(BRIDGE-UTILS_SOURCE)" >>$@
	@echo "Description: $(BRIDGE-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BRIDGE-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BRIDGE-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BRIDGE-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BRIDGE-UTILS_IPK_DIR)/opt/sbin or $(BRIDGE-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BRIDGE-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BRIDGE-UTILS_IPK_DIR)/opt/etc/bridge-utils/...
# Documentation files should be installed in $(BRIDGE-UTILS_IPK_DIR)/opt/doc/bridge-utils/...
# Daemon startup scripts should be installed in $(BRIDGE-UTILS_IPK_DIR)/opt/etc/init.d/S??bridge-utils
#
# You may need to patch your application to make it use these locations.
#
$(BRIDGE-UTILS_IPK): $(BRIDGE-UTILS_BUILD_DIR)/.built
	rm -rf $(BRIDGE-UTILS_IPK_DIR) $(BUILD_DIR)/bridge-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BRIDGE-UTILS_BUILD_DIR) install \
		DESTDIR=$(BRIDGE-UTILS_IPK_DIR) SUBDIRS="brctl doc"
	$(STRIP_COMMAND) $(BRIDGE-UTILS_IPK_DIR)/opt/sbin/brctl
	$(MAKE) $(BRIDGE-UTILS_IPK_DIR)/CONTROL/control
	echo $(BRIDGE-UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(BRIDGE-UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BRIDGE-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bridge-utils-ipk: $(BRIDGE-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bridge-utils-clean:
	rm -f $(BRIDGE-UTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(BRIDGE-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bridge-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(BRIDGE-UTILS_DIR) $(BRIDGE-UTILS_BUILD_DIR) $(BRIDGE-UTILS_IPK_DIR) $(BRIDGE-UTILS_IPK)
#
#
# Some sanity check for the package.
#
bridge-utils-check: $(BRIDGE-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BRIDGE-UTILS_IPK)
