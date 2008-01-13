###########################################################
#
# sysfsutils
#
###########################################################
#
# SYSFSUTILS_VERSION, SYSFSUTILS_SITE and SYSFSUTILS_SOURCE define
# the upstream location of the source code for the package.
# SYSFSUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# SYSFSUTILS_UNZIP is the command used to unzip the source.
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
SYSFSUTILS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/linux-diag
SYSFSUTILS_VERSION=2.1.0
SYSFSUTILS_SOURCE=sysfsutils-$(SYSFSUTILS_VERSION).tar.gz
SYSFSUTILS_DIR=sysfsutils-$(SYSFSUTILS_VERSION)
SYSFSUTILS_UNZIP=zcat
SYSFSUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SYSFSUTILS_DESCRIPTION=A set of utilites built upon sysfs, a new virtual filesystem in Linux kernel versions 2.5+ that exposes system device tree. Including libsysfs and systool.
SYSFSUTILS_SECTION=sysadmin
SYSFSUTILS_PRIORITY=optional
SYSFSUTILS_DEPENDS=
SYSFSUTILS_SUGGESTS=
SYSFSUTILS_CONFLICTS=

#
# SYSFSUTILS_IPK_VERSION should be incremented when the ipk changes.
#
SYSFSUTILS_IPK_VERSION=1

#
# SYSFSUTILS_CONFFILES should be a list of user-editable files
#SYSFSUTILS_CONFFILES=/opt/etc/sysfsutils.conf /opt/etc/init.d/SXXsysfsutils

#
# SYSFSUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SYSFSUTILS_PATCHES=$(SYSFSUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SYSFSUTILS_CPPFLAGS=
SYSFSUTILS_LDFLAGS=

#
# SYSFSUTILS_BUILD_DIR is the directory in which the build is done.
# SYSFSUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SYSFSUTILS_IPK_DIR is the directory in which the ipk is built.
# SYSFSUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SYSFSUTILS_BUILD_DIR=$(BUILD_DIR)/sysfsutils
SYSFSUTILS_SOURCE_DIR=$(SOURCE_DIR)/sysfsutils
SYSFSUTILS_IPK_DIR=$(BUILD_DIR)/sysfsutils-$(SYSFSUTILS_VERSION)-ipk
SYSFSUTILS_IPK=$(BUILD_DIR)/sysfsutils_$(SYSFSUTILS_VERSION)-$(SYSFSUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sysfsutils-source sysfsutils-unpack sysfsutils sysfsutils-stage sysfsutils-ipk sysfsutils-clean sysfsutils-dirclean sysfsutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SYSFSUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SYSFSUTILS_SITE)/$(SYSFSUTILS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SYSFSUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sysfsutils-source: $(DL_DIR)/$(SYSFSUTILS_SOURCE) $(SYSFSUTILS_PATCHES)

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
$(SYSFSUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(SYSFSUTILS_SOURCE) $(SYSFSUTILS_PATCHES) make/sysfsutils.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SYSFSUTILS_DIR) $(@D)
	$(SYSFSUTILS_UNZIP) $(DL_DIR)/$(SYSFSUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SYSFSUTILS_PATCHES)" ; \
		then cat $(SYSFSUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SYSFSUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SYSFSUTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SYSFSUTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYSFSUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYSFSUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sysfsutils-unpack: $(SYSFSUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SYSFSUTILS_BUILD_DIR)/.built: $(SYSFSUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sysfsutils: $(SYSFSUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SYSFSUTILS_BUILD_DIR)/.staged: $(SYSFSUTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install SUBDIRS=lib
	rm -f $(STAGING_LIB_DIR)/libsysfs*.la
	touch $@

sysfsutils-stage: $(SYSFSUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sysfsutils
#
$(SYSFSUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sysfsutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SYSFSUTILS_PRIORITY)" >>$@
	@echo "Section: $(SYSFSUTILS_SECTION)" >>$@
	@echo "Version: $(SYSFSUTILS_VERSION)-$(SYSFSUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SYSFSUTILS_MAINTAINER)" >>$@
	@echo "Source: $(SYSFSUTILS_SITE)/$(SYSFSUTILS_SOURCE)" >>$@
	@echo "Description: $(SYSFSUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(SYSFSUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(SYSFSUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SYSFSUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SYSFSUTILS_IPK_DIR)/opt/sbin or $(SYSFSUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SYSFSUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SYSFSUTILS_IPK_DIR)/opt/etc/sysfsutils/...
# Documentation files should be installed in $(SYSFSUTILS_IPK_DIR)/opt/doc/sysfsutils/...
# Daemon startup scripts should be installed in $(SYSFSUTILS_IPK_DIR)/opt/etc/init.d/S??sysfsutils
#
# You may need to patch your application to make it use these locations.
#
$(SYSFSUTILS_IPK): $(SYSFSUTILS_BUILD_DIR)/.built
	rm -rf $(SYSFSUTILS_IPK_DIR) $(BUILD_DIR)/sysfsutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SYSFSUTILS_BUILD_DIR) DESTDIR=$(SYSFSUTILS_IPK_DIR) install-strip
	rm -f $(SYSFSUTILS_IPK_DIR)/opt/lib/libsysfs*.la
	$(MAKE) $(SYSFSUTILS_IPK_DIR)/CONTROL/control
	echo $(SYSFSUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(SYSFSUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SYSFSUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sysfsutils-ipk: $(SYSFSUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sysfsutils-clean:
	rm -f $(SYSFSUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(SYSFSUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sysfsutils-dirclean:
	rm -rf $(BUILD_DIR)/$(SYSFSUTILS_DIR) $(SYSFSUTILS_BUILD_DIR) $(SYSFSUTILS_IPK_DIR) $(SYSFSUTILS_IPK)
#
#
# Some sanity check for the package.
#
sysfsutils-check: $(SYSFSUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SYSFSUTILS_IPK)
