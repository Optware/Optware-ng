###########################################################
#
# libcap
#
###########################################################

# You must replace "libcap" and "LIBCAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBCAP_VERSION, LIBCAP_SITE and LIBCAP_SOURCE define
# the upstream location of the source code for the package.
# LIBCAP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCAP_UNZIP is the command used to unzip the source.
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
LIBCAP_SITE=https://launchpad.net/ubuntu/+archive/primary/+files
LIBCAP_VERSION=2.24
LIBCAP_SOURCE=libcap-$(LIBCAP_VERSION).tar.gz
LIBCAP_DIR=libcap-$(LIBCAP_VERSION)
LIBCAP_UNZIP=zcat
LIBCAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCAP_DESCRIPTION=The libcap project provides a library which may be used to explain Unix and Linux system call errors
LIBCAP_SECTION=lib
LIBCAP_PRIORITY=optional
LIBCAP_DEPENDS=attr
LIBCAP_CONFLICTS=

#
# LIBCAP_IPK_VERSION should be incremented when the ipk changes.
#
LIBCAP_IPK_VERSION=1

#
# LIBCAP_CONFFILES should be a list of user-editable files
#LIBCAP_CONFFILES=$(TARGET_PREFIX)/etc/libcap.conf $(TARGET_PREFIX)/etc/init.d/SXXlibcap

#
# LIBCAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBCAP_PATCHES=$(LIBCAP_SOURCE_DIR)/0001-fix-Makefiles.patch \
$(LIBCAP_SOURCE_DIR)/0003-refine-setcap-error-message.patch \
$(LIBCAP_SOURCE_DIR)/0004-include-sys-xattr.patch \
$(LIBCAP_SOURCE_DIR)/undef__STRICT_ANSI__.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCAP_CPPFLAGS=
LIBCAP_LDFLAGS=

#
# LIBCAP_BUILD_DIR is the directory in which the build is done.
# LIBCAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCAP_IPK_DIR is the directory in which the ipk is built.
# LIBCAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCAP_BUILD_DIR=$(BUILD_DIR)/libcap
LIBCAP_SOURCE_DIR=$(SOURCE_DIR)/libcap
LIBCAP_IPK_DIR=$(BUILD_DIR)/libcap-$(LIBCAP_VERSION)-ipk
LIBCAP_IPK=$(BUILD_DIR)/libcap_$(LIBCAP_VERSION)-$(LIBCAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCAP_SOURCE):
	$(WGET) -O $@ $(LIBCAP_SITE)/libcap2_$(LIBCAP_VERSION).orig.tar.gz || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcap-source: $(DL_DIR)/$(LIBCAP_SOURCE) $(LIBCAP_PATCHES)

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
$(LIBCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCAP_SOURCE) $(LIBCAP_PATCHES) make/libcap.mk
	$(MAKE) attr-stage
	rm -rf $(BUILD_DIR)/$(LIBCAP_DIR) $(@D)
	$(LIBCAP_UNZIP) $(DL_DIR)/$(LIBCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBCAP_PATCHES)" ; \
		then cat $(LIBCAP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBCAP_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBCAP_DIR) $(@D)
#	fix for error: ‘XATTR_NAME_CAPS’ undeclared
	sed -i -e 's/^#define XATTR_SECURITY_PREFIX .*/#ifndef XATTR_CAPS_SUFFIX\n#define XATTR_CAPS_SUFFIX "capability"\n#endif\n#ifndef XATTR_SECURITY_PREFIX\n#define XATTR_SECURITY_PREFIX "security."\n#endif\n#ifndef XATTR_NAME_CAPS\n#define XATTR_NAME_CAPS XATTR_SECURITY_PREFIX XATTR_CAPS_SUFFIX\n#endif/' $(@D)/libcap/cap_file.c
	touch $@

libcap-unpack: $(LIBCAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBCAP_BUILD_DIR)/.built: $(LIBCAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/libcap $(TARGET_CONFIGURE_OPTS) LD="$(TARGET_CC) -shared" \
		BUILD_CC=gcc LIBATTR=yes \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCAP_LDFLAGS)" \
		prefix=$(TARGET_PREFIX) lib=lib
	touch $@

#
# This is the build convenience target.
#
libcap: $(LIBCAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCAP_BUILD_DIR)/.staged: $(LIBCAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/libcap FAKEROOT=$(STAGING_DIR) prefix=$(TARGET_PREFIX) lib=lib install
	rm -f $(STAGING_LIB_DIR)/libcap.a
	sed -i -e 's|$(TARGET_PREFIX)|$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libcap.pc
	touch $@

libcap-stage: $(LIBCAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libcap
#
$(LIBCAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBCAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libcap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCAP_PRIORITY)" >>$@
	@echo "Section: $(LIBCAP_SECTION)" >>$@
	@echo "Version: $(LIBCAP_VERSION)-$(LIBCAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCAP_MAINTAINER)" >>$@
	@echo "Source: $(LIBCAP_SITE)/$(LIBCAP_SOURCE)" >>$@
	@echo "Description: $(LIBCAP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCAP_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBCAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/libcap/...
# Documentation files should be installed in $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/doc/libcap/...
# Daemon startup scripts should be installed in $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libcap
#
# You may need to patch your application to make it use these locations.
#
$(LIBCAP_IPK): $(LIBCAP_BUILD_DIR)/.built
	rm -rf $(LIBCAP_IPK_DIR) $(BUILD_DIR)/libcap_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBCAP_BUILD_DIR)/libcap FAKEROOT=$(LIBCAP_IPK_DIR) prefix=$(TARGET_PREFIX) lib=lib install
	rm -f $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/lib/libcap.a
	$(STRIP_COMMAND) $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
#	$(INSTALL) -d $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBCAP_SOURCE_DIR)/libcap.conf $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/libcap.conf
#	$(INSTALL) -d $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBCAP_SOURCE_DIR)/rc.libcap $(LIBCAP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibcap
	$(MAKE) $(LIBCAP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBCAP_SOURCE_DIR)/postinst $(LIBCAP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBCAP_SOURCE_DIR)/prerm $(LIBCAP_IPK_DIR)/CONTROL/prerm
#	echo $(LIBCAP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBCAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcap-ipk: $(LIBCAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcap-clean:
	-$(MAKE) -C $(LIBCAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcap-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCAP_DIR) $(LIBCAP_BUILD_DIR) $(LIBCAP_IPK_DIR) $(LIBCAP_IPK)

#
# Some sanity check for the package.
#
libcap-check: $(LIBCAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
