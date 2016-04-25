###########################################################
#
# libacl
#
###########################################################

# You must replace "libacl" and "LIBACL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBACL_VERSION, LIBACL_SITE and LIBACL_SOURCE define
# the upstream location of the source code for the package.
# LIBACL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBACL_UNZIP is the command used to unzip the source.
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
LIBACL_SITE=https://launchpad.net/ubuntu/+archive/primary/+files
LIBACL_VERSION=2.2.49
LIBACL_SOURCE=acl-$(LIBACL_VERSION).tar.gz
LIBACL_DIR=acl-$(LIBACL_VERSION)
LIBACL_UNZIP=zcat
LIBACL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBACL_DESCRIPTION=POSIX 1003.1e draft standard 17 functions for manipulating access control lists
LIBACL_SECTION=lib
LIBACL_PRIORITY=optional
LIBACL_DEPENDS=attr
LIBACL_CONFLICTS=

#
# LIBACL_IPK_VERSION should be incremented when the ipk changes.
#
LIBACL_IPK_VERSION=1

#
# LIBACL_CONFFILES should be a list of user-editable files
#LIBACL_CONFFILES=$(TARGET_PREFIX)/etc/libacl.conf $(TARGET_PREFIX)/etc/init.d/SXXlibacl

#
# LIBACL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBACL_PATCHES=$(LIBACL_SOURCE_DIR)/libtool.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBACL_CPPFLAGS=
LIBACL_LDFLAGS=

#
# LIBACL_BUILD_DIR is the directory in which the build is done.
# LIBACL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBACL_IPK_DIR is the directory in which the ipk is built.
# LIBACL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBACL_BUILD_DIR=$(BUILD_DIR)/libacl
LIBACL_SOURCE_DIR=$(SOURCE_DIR)/libacl
LIBACL_IPK_DIR=$(BUILD_DIR)/libacl-$(LIBACL_VERSION)-ipk
LIBACL_IPK=$(BUILD_DIR)/libacl_$(LIBACL_VERSION)-$(LIBACL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBACL_SOURCE):
	$(WGET) -O $@ $(LIBACL_SITE)/acl_$(LIBACL_VERSION).orig.tar.gz || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libacl-source: $(DL_DIR)/$(LIBACL_SOURCE) $(LIBACL_PATCHES)

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
$(LIBACL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBACL_SOURCE) $(LIBACL_PATCHES) make/libacl.mk
	$(MAKE) attr-stage
	rm -rf $(BUILD_DIR)/$(LIBACL_DIR) $(@D)
	$(LIBACL_UNZIP) $(DL_DIR)/$(LIBACL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBACL_PATCHES)" ; \
		then cat $(LIBACL_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBACL_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBACL_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBACL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBACL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-shared \
		--disable-static \
		--disable-nls \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e '/^PKG_DEVLIB_DIR/s|.*|PKG_DEVLIB_DIR	= \$${exec_prefix}/lib|' $(@D)/include/builddefs
	touch $@

libacl-unpack: $(LIBACL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBACL_BUILD_DIR)/.built: $(LIBACL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC="$(TARGET_CC) $(STAGING_CPPFLAGS) $(LIBACL_CPPFLAGS)" LD="$(TARGET_CC) $(STAGING_LDFLAGS) $(LIBACL_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
libacl: $(LIBACL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBACL_BUILD_DIR)/.staged: $(LIBACL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DIST_ROOT=$(STAGING_DIR) install-lib install-dev
	rm -f $(STAGING_LIB_DIR)/libacl.la
	touch $@

libacl-stage: $(LIBACL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libacl
#
$(LIBACL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBACL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libacl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBACL_PRIORITY)" >>$@
	@echo "Section: $(LIBACL_SECTION)" >>$@
	@echo "Version: $(LIBACL_VERSION)-$(LIBACL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBACL_MAINTAINER)" >>$@
	@echo "Source: $(LIBACL_SITE)/$(LIBACL_SOURCE)" >>$@
	@echo "Description: $(LIBACL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBACL_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBACL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/libacl/...
# Documentation files should be installed in $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/doc/libacl/...
# Daemon startup scripts should be installed in $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libacl
#
# You may need to patch your application to make it use these locations.
#
$(LIBACL_IPK): $(LIBACL_BUILD_DIR)/.built
	rm -rf $(LIBACL_IPK_DIR) $(BUILD_DIR)/libacl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBACL_BUILD_DIR) DIST_ROOT=$(LIBACL_IPK_DIR) install-lib install-dev
	rm -f $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/lib/libacl.la
	$(STRIP_COMMAND) $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBACL_SOURCE_DIR)/libacl.conf $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/libacl.conf
#	$(INSTALL) -d $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBACL_SOURCE_DIR)/rc.libacl $(LIBACL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibacl
	$(MAKE) $(LIBACL_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBACL_SOURCE_DIR)/postinst $(LIBACL_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBACL_SOURCE_DIR)/prerm $(LIBACL_IPK_DIR)/CONTROL/prerm
#	echo $(LIBACL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBACL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBACL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libacl-ipk: $(LIBACL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libacl-clean:
	-$(MAKE) -C $(LIBACL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libacl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBACL_DIR) $(LIBACL_BUILD_DIR) $(LIBACL_IPK_DIR) $(LIBACL_IPK)

#
# Some sanity check for the package.
#
libacl-check: $(LIBACL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
