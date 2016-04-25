###########################################################
#
# attr
#
###########################################################

# You must replace "attr" and "ATTR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ATTR_VERSION, ATTR_SITE and ATTR_SOURCE define
# the upstream location of the source code for the package.
# ATTR_DIR is the directory which is created when the source
# archive is unpacked.
# ATTR_UNZIP is the command used to unzip the source.
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
ATTR_SITE=http://download.savannah.gnu.org/releases/attr
ATTR_SITE2=http://pkgs.fedoraproject.org/repo/pkgs/attr/attr-2.4.47.src.tar.gz/84f58dec00b60f2dc8fd1c9709291cc7
ATTR_VERSION=2.4.47
ATTR_SOURCE=attr-$(ATTR_VERSION).src.tar.gz
ATTR_DIR=attr-$(ATTR_VERSION)
ATTR_UNZIP=zcat
ATTR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ATTR_DESCRIPTION=The attr package contains utilities to administer the extended attributes on filesystem objects
ATTR_SECTION=misc
ATTR_PRIORITY=optional
ATTR_DEPENDS=gettext
ATTR_CONFLICTS=

#
# ATTR_IPK_VERSION should be incremented when the ipk changes.
#
ATTR_IPK_VERSION=1

#
# ATTR_CONFFILES should be a list of user-editable files
#ATTR_CONFFILES=$(TARGET_PREFIX)/etc/attr.conf $(TARGET_PREFIX)/etc/init.d/SXXattr

#
# ATTR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ATTR_PATCHES=$(ATTR_SOURCE_DIR)/libtool.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ATTR_CPPFLAGS=
ATTR_LDFLAGS=-lintl

#
# ATTR_BUILD_DIR is the directory in which the build is done.
# ATTR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ATTR_IPK_DIR is the directory in which the ipk is built.
# ATTR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ATTR_BUILD_DIR=$(BUILD_DIR)/attr
ATTR_SOURCE_DIR=$(SOURCE_DIR)/attr
ATTR_IPK_DIR=$(BUILD_DIR)/attr-$(ATTR_VERSION)-ipk
ATTR_IPK=$(BUILD_DIR)/attr_$(ATTR_VERSION)-$(ATTR_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ATTR_SOURCE):
	$(WGET) -P $(@D) $(ATTR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(ATTR_SITE2)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
attr-source: $(DL_DIR)/$(ATTR_SOURCE) $(ATTR_PATCHES)

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
$(ATTR_BUILD_DIR)/.configured: $(DL_DIR)/$(ATTR_SOURCE) $(ATTR_PATCHES) make/attr.mk
	$(MAKE) gettext-stage
	rm -rf $(BUILD_DIR)/$(ATTR_DIR) $(@D)
	$(ATTR_UNZIP) $(DL_DIR)/$(ATTR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ATTR_PATCHES)" ; \
		then cat $(ATTR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ATTR_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(ATTR_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ATTR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ATTR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-shared \
		--disable-static \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(ATTR_BUILD_DIR)/libtool
	touch $@

attr-unpack: $(ATTR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ATTR_BUILD_DIR)/.built: $(ATTR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC="$(TARGET_CC) $(STAGING_CPPFLAGS) $(ATTR_CPPFLAGS)" LD="$(TARGET_CC) $(STAGING_LDFLAGS) $(ATTR_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
attr: $(ATTR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ATTR_BUILD_DIR)/.staged: $(ATTR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DIST_ROOT=$(STAGING_DIR) install-lib install-dev
	rm -f $(STAGING_LIB_DIR)/libattr.la
	touch $@

attr-stage: $(ATTR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/attr
#
$(ATTR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(ATTR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: attr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ATTR_PRIORITY)" >>$@
	@echo "Section: $(ATTR_SECTION)" >>$@
	@echo "Version: $(ATTR_VERSION)-$(ATTR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ATTR_MAINTAINER)" >>$@
	@echo "Source: $(ATTR_SITE)/$(ATTR_SOURCE)" >>$@
	@echo "Description: $(ATTR_DESCRIPTION)" >>$@
	@echo "Depends: $(ATTR_DEPENDS)" >>$@
	@echo "Conflicts: $(ATTR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ATTR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ATTR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ATTR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/attr/...
# Documentation files should be installed in $(ATTR_IPK_DIR)$(TARGET_PREFIX)/doc/attr/...
# Daemon startup scripts should be installed in $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??attr
#
# You may need to patch your application to make it use these locations.
#
$(ATTR_IPK): $(ATTR_BUILD_DIR)/.built
	rm -rf $(ATTR_IPK_DIR) $(BUILD_DIR)/attr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ATTR_BUILD_DIR) DIST_ROOT=$(ATTR_IPK_DIR) install-lib install-dev
	$(STRIP_COMMAND) $(ATTR_IPK_DIR)$(TARGET_PREFIX)/lib/*.so $(ATTR_IPK_DIR)$(TARGET_PREFIX)/bin/*
	rm -f $(ATTR_IPK_DIR)$(TARGET_PREFIX)/lib/libattr.la
#	$(INSTALL) -d $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ATTR_SOURCE_DIR)/attr.conf $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/attr.conf
#	$(INSTALL) -d $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ATTR_SOURCE_DIR)/rc.attr $(ATTR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXattr
	$(MAKE) $(ATTR_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ATTR_SOURCE_DIR)/postinst $(ATTR_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ATTR_SOURCE_DIR)/prerm $(ATTR_IPK_DIR)/CONTROL/prerm
#	echo $(ATTR_CONFFILES) | sed -e 's/ /\n/g' > $(ATTR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ATTR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
attr-ipk: $(ATTR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
attr-clean:
	-$(MAKE) -C $(ATTR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
attr-dirclean:
	rm -rf $(BUILD_DIR)/$(ATTR_DIR) $(ATTR_BUILD_DIR) $(ATTR_IPK_DIR) $(ATTR_IPK)

#
# Some sanity check for the package.
#
attr-check: $(ATTR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
