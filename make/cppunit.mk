###########################################################
#
# cppunit
#
###########################################################

# You must replace "cppunit" and "CPPUNIT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CPPUNIT_VERSION, CPPUNIT_SITE and CPPUNIT_SOURCE define
# the upstream location of the source code for the package.
# CPPUNIT_DIR is the directory which is created when the source
# archive is unpacked.
# CPPUNIT_UNZIP is the command used to unzip the source.
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
CPPUNIT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/cppunit
CPPUNIT_VERSION=1.12.1
CPPUNIT_SOURCE=cppunit-$(CPPUNIT_VERSION).tar.gz
CPPUNIT_DIR=cppunit-$(CPPUNIT_VERSION)
CPPUNIT_UNZIP=zcat
CPPUNIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CPPUNIT_DESCRIPTION=CppUnit is the C++ port of the famous JUnit framework for unit testing.
CPPUNIT_SECTION=lib
CPPUNIT_PRIORITY=optional
CPPUNIT_DEPENDS=libstdc++
CPPUNIT_SUGGESTS=
CPPUNIT_CONFLICTS=

#
# CPPUNIT_IPK_VERSION should be incremented when the ipk changes.
#
CPPUNIT_IPK_VERSION=2

#
# CPPUNIT_CONFFILES should be a list of user-editable files
#CPPUNIT_CONFFILES=$(TARGET_PREFIX)/etc/cppunit.conf $(TARGET_PREFIX)/etc/init.d/SXXcppunit

#
# CPPUNIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CPPUNIT_PATCHES=$(CPPUNIT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CPPUNIT_CPPFLAGS=
CPPUNIT_LDFLAGS=

#
# CPPUNIT_BUILD_DIR is the directory in which the build is done.
# CPPUNIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CPPUNIT_IPK_DIR is the directory in which the ipk is built.
# CPPUNIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CPPUNIT_BUILD_DIR=$(BUILD_DIR)/cppunit
CPPUNIT_SOURCE_DIR=$(SOURCE_DIR)/cppunit
CPPUNIT_IPK_DIR=$(BUILD_DIR)/cppunit-$(CPPUNIT_VERSION)-ipk
CPPUNIT_IPK=$(BUILD_DIR)/cppunit_$(CPPUNIT_VERSION)-$(CPPUNIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cppunit-source cppunit-unpack cppunit cppunit-stage cppunit-ipk cppunit-clean cppunit-dirclean cppunit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CPPUNIT_SOURCE):
	$(WGET) -P $(@D) $(CPPUNIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cppunit-source: $(DL_DIR)/$(CPPUNIT_SOURCE) $(CPPUNIT_PATCHES)

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
$(CPPUNIT_BUILD_DIR)/.configured: $(DL_DIR)/$(CPPUNIT_SOURCE) $(CPPUNIT_PATCHES) make/cppunit.mk
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(CPPUNIT_DIR) $(@D)
	$(CPPUNIT_UNZIP) $(DL_DIR)/$(CPPUNIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CPPUNIT_PATCHES)" ; \
		then cat $(CPPUNIT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CPPUNIT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CPPUNIT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CPPUNIT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CPPUNIT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CPPUNIT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cppunit-unpack: $(CPPUNIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CPPUNIT_BUILD_DIR)/.built: $(CPPUNIT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cppunit: $(CPPUNIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CPPUNIT_BUILD_DIR)/.staged: $(CPPUNIT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/cppunit.pc \
							$(STAGING_PREFIX)/bin/cppunit-config
	rm -f $(STAGING_LIB_DIR)/libcppunit.la
	touch $@

cppunit-stage: $(CPPUNIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cppunit
#
$(CPPUNIT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cppunit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CPPUNIT_PRIORITY)" >>$@
	@echo "Section: $(CPPUNIT_SECTION)" >>$@
	@echo "Version: $(CPPUNIT_VERSION)-$(CPPUNIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CPPUNIT_MAINTAINER)" >>$@
	@echo "Source: $(CPPUNIT_SITE)/$(CPPUNIT_SOURCE)" >>$@
	@echo "Description: $(CPPUNIT_DESCRIPTION)" >>$@
	@echo "Depends: $(CPPUNIT_DEPENDS)" >>$@
	@echo "Suggests: $(CPPUNIT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CPPUNIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/cppunit/...
# Documentation files should be installed in $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/doc/cppunit/...
# Daemon startup scripts should be installed in $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cppunit
#
# You may need to patch your application to make it use these locations.
#
$(CPPUNIT_IPK): $(CPPUNIT_BUILD_DIR)/.built
	rm -rf $(CPPUNIT_IPK_DIR) $(BUILD_DIR)/cppunit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CPPUNIT_BUILD_DIR) DESTDIR=$(CPPUNIT_IPK_DIR) install-strip
	rm -f $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(CPPUNIT_SOURCE_DIR)/cppunit.conf $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/cppunit.conf
#	$(INSTALL) -d $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(CPPUNIT_SOURCE_DIR)/rc.cppunit $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcppunit
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPPUNIT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXcppunit
	$(MAKE) $(CPPUNIT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(CPPUNIT_SOURCE_DIR)/postinst $(CPPUNIT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPPUNIT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(CPPUNIT_SOURCE_DIR)/prerm $(CPPUNIT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CPPUNIT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CPPUNIT_IPK_DIR)/CONTROL/postinst $(CPPUNIT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CPPUNIT_CONFFILES) | sed -e 's/ /\n/g' > $(CPPUNIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CPPUNIT_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(CPPUNIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cppunit-ipk: $(CPPUNIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cppunit-clean:
	rm -f $(CPPUNIT_BUILD_DIR)/.built
	-$(MAKE) -C $(CPPUNIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cppunit-dirclean:
	rm -rf $(BUILD_DIR)/$(CPPUNIT_DIR) $(CPPUNIT_BUILD_DIR) $(CPPUNIT_IPK_DIR) $(CPPUNIT_IPK)
#
#
# Some sanity check for the package.
#
cppunit-check: $(CPPUNIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
