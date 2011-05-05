###########################################################
#
# jfsutils
#
###########################################################

#
# JFSUTILS-UTILS_VERSION, JFSUTILS_SITE and JFSUTILS_SOURCE define
# the upstream location of the source code for the package.
# JFSUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# JFSUTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
JFSUTILS_SITE=http://jfs.sourceforge.net/project/pub/
JFSUTILS_VERSION=1.1.15
JFSUTILS_SOURCE=jfsutils-1.1.15.tar.gz
JFSUTILS_DIR=jfsutils-$(JFSUTILS_VERSION)
JFSUTILS_UNZIP=zcat
JFSUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
JFSUTILS_DESCRIPTION=Linux Filesystem Utilities for IBMs JFS
JFSUTILS_SECTION=utils
JFSUTILS_PRIORITY=optional
JFSUTILS_DEPENDS=
JFSUTILS_SUGGESTS=
JFSUTILS_CONFLICTS=

#
# JFSUTILS_IPK_VERSION should be incremented when the ipk changes.
#
JFSUTILS_IPK_VERSION=1

#
# JFSUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
JFSUTILS_PATCHES=
#
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#JFSUTILS_CPPFLAGS=
#JFSUTILS_LDFLAGS=

#
# JFSUTILS_BUILD_DIR is the directory in which the build is done.
# JFSUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JFSUTILS_IPK_DIR is the directory in which the ipk is built.
# JFSUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JFSUTILS_BUILD_DIR=$(BUILD_DIR)/jfsutils
JFSUTILS_SOURCE_DIR=$(SOURCE_DIR)/jfsutils
JFSUTILS_IPK_DIR=$(BUILD_DIR)/jfsutils-$(JFSUTILS_VERSION)-ipk
JFSUTILS_IPK=$(BUILD_DIR)/jfsutils_$(JFSUTILS_VERSION)-$(JFSUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JFSUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(JFSUTILS_SITE)/$(JFSUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jfsutils-source: $(DL_DIR)/$(JFSUTILS_SOURCE) $(JFSUTILS_PATCHES)

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
$(JFSUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(JFSUTILS_SOURCE) $(JFSUTILS_PATCHES) make/jfsutils.mk
	$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(JFSUTILS_DIR) $(@D)
	$(JFSUTILS_UNZIP) $(DL_DIR)/$(JFSUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	chmod u+w $(BUILD_DIR)/$(JFSUTILS_DIR)/*
	mv $(BUILD_DIR)/$(JFSUTILS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) "  \
		LDFLAGS="$(STAGING_LDFLAGS) " \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
  		--libdir=/opt/lib          \
	)
	touch $@

jfsutils-unpack: $(JFSUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(JFSUTILS_BUILD_DIR)/.built: $(JFSUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JFSUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JFSUTILS_LDFLAGS)" \
;
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
jfsutils: $(JFSUTILS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jfsutils
#
$(JFSUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: jfsutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JFSUTILS_PRIORITY)" >>$@
	@echo "Section: $(JFSUTILS_SECTION)" >>$@
	@echo "Version: $(JFSUTILS_VERSION)-$(JFSUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JFSUTILS_MAINTAINER)" >>$@
	@echo "Source: $(JFSUTILS_SITE)/$(JFSUTILS_SOURCE)" >>$@
	@echo "Description: $(JFSUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(JFSUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(JFSUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(JFSUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JFSUTILS_IPK_DIR)/opt/sbin or $(JFSUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JFSUTILS_IPK_DIR)/opt/{lib,include}
# 
#
# You may need to patch your application to make it use these locations.
#
$(JFSUTILS_IPK): $(JFSUTILS_BUILD_DIR)/.built
	rm -rf $(JFSUTILS_IPK_DIR) $(BUILD_DIR)/jfsutils_*_$(TARGET_ARCH).ipk
	install -d $(JFSUTILS_IPK_DIR)/opt/sbin
	$(MAKE) -C $(JFSUTILS_BUILD_DIR) DESTDIR=$(JFSUTILS_IPK_DIR) install-strip
	$(MAKE) $(JFSUTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JFSUTILS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(JFSUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jfsutils-ipk: $(JFSUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jfsutils-clean:
	-$(MAKE) -C $(JFSUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jfsutils-dirclean:
	rm -rf $(BUILD_DIR)/$(JFSUTILS_DIR) $(JFSUTILS_BUILD_DIR) $(JFSUTILS_IPK_DIR) $(JFSUTILS_IPK)

#
# Some sanity check for the package.
#
jfsutils-check: $(JFSUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
