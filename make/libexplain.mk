###########################################################
#
# libexplain
#
###########################################################

# You must replace "libexplain" and "LIBEXPLAIN" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBEXPLAIN_VERSION, LIBEXPLAIN_SITE and LIBEXPLAIN_SOURCE define
# the upstream location of the source code for the package.
# LIBEXPLAIN_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEXPLAIN_UNZIP is the command used to unzip the source.
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
LIBEXPLAIN_SITE=http://libexplain.sourceforge.net
LIBEXPLAIN_VERSION=1.4
LIBEXPLAIN_SOURCE=libexplain-$(LIBEXPLAIN_VERSION).tar.gz
LIBEXPLAIN_DIR=libexplain-$(LIBEXPLAIN_VERSION)
LIBEXPLAIN_UNZIP=zcat
LIBEXPLAIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEXPLAIN_DESCRIPTION=The libexplain project provides a library which may be used to explain Unix and Linux system call errors
LIBEXPLAIN_SECTION=lib
LIBEXPLAIN_PRIORITY=optional
LIBEXPLAIN_DEPENDS=libcap, libacl
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBEXPLAIN_DEPENDS+=, libiconv
endif
LIBEXPLAIN_CONFLICTS=

#
# LIBEXPLAIN_IPK_VERSION should be incremented when the ipk changes.
#
LIBEXPLAIN_IPK_VERSION=2

#
# LIBEXPLAIN_CONFFILES should be a list of user-editable files
#LIBEXPLAIN_CONFFILES=$(TARGET_PREFIX)/etc/libexplain.conf $(TARGET_PREFIX)/etc/init.d/SXXlibexplain

#
# LIBEXPLAIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBEXPLAIN_PATCHES=$(LIBEXPLAIN_SOURCE_DIR)/includes.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEXPLAIN_CPPFLAGS=-DSYS_SHM_H_struct_ipc_perm_underscore_key
LIBEXPLAIN_LDFLAGS=

#
# LIBEXPLAIN_BUILD_DIR is the directory in which the build is done.
# LIBEXPLAIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEXPLAIN_IPK_DIR is the directory in which the ipk is built.
# LIBEXPLAIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEXPLAIN_BUILD_DIR=$(BUILD_DIR)/libexplain
LIBEXPLAIN_SOURCE_DIR=$(SOURCE_DIR)/libexplain
LIBEXPLAIN_IPK_DIR=$(BUILD_DIR)/libexplain-$(LIBEXPLAIN_VERSION)-ipk
LIBEXPLAIN_IPK=$(BUILD_DIR)/libexplain_$(LIBEXPLAIN_VERSION)-$(LIBEXPLAIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEXPLAIN_SOURCE):
	$(WGET) -P $(@D) $(LIBEXPLAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libexplain-source: $(DL_DIR)/$(LIBEXPLAIN_SOURCE) $(LIBEXPLAIN_PATCHES)

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
$(LIBEXPLAIN_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEXPLAIN_SOURCE) $(LIBEXPLAIN_PATCHES) make/libexplain.mk
	$(MAKE) libcap-stage libacl-stage libtool-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBEXPLAIN_DIR) $(@D)
	$(LIBEXPLAIN_UNZIP) $(DL_DIR)/$(LIBEXPLAIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEXPLAIN_PATCHES)" ; \
		then cat $(LIBEXPLAIN_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBEXPLAIN_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBEXPLAIN_DIR) $(@D)
	sed -i -e 's/as_fn_error .*\("cannot run test program\)/echo \1/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEXPLAIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEXPLAIN_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		LIBTOOL=$(STAGING_PREFIX)/bin/libtool \
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
	sed -i -e '/^#define HAVE_LINUX_VIDEODEV/s|^|//|' $(@D)/libexplain/config.h
	sed -i -e '/^all:/s/all-doc//' -e '/^install:/s/install-doc//' $(@D)/Makefile
	touch $@

libexplain-unpack: $(LIBEXPLAIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEXPLAIN_BUILD_DIR)/.built: $(LIBEXPLAIN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libexplain: $(LIBEXPLAIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBEXPLAIN_BUILD_DIR)/.staged: $(LIBEXPLAIN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) clean-misc
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install -j1
	rm -f $(STAGING_LIB_DIR)/libexplain.la
	sed -i -e 's|$(TARGET_PREFIX)/|$(STAGING_PREFIX)/|' $(STAGING_LIB_DIR)/pkgconfig/libexplain.pc
	touch $@

libexplain-stage: $(LIBEXPLAIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libexplain
#
$(LIBEXPLAIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBEXPLAIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libexplain" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEXPLAIN_PRIORITY)" >>$@
	@echo "Section: $(LIBEXPLAIN_SECTION)" >>$@
	@echo "Version: $(LIBEXPLAIN_VERSION)-$(LIBEXPLAIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEXPLAIN_MAINTAINER)" >>$@
	@echo "Source: $(LIBEXPLAIN_SITE)/$(LIBEXPLAIN_SOURCE)" >>$@
	@echo "Description: $(LIBEXPLAIN_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEXPLAIN_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBEXPLAIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/libexplain/...
# Documentation files should be installed in $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/doc/libexplain/...
# Daemon startup scripts should be installed in $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libexplain
#
# You may need to patch your application to make it use these locations.
#
$(LIBEXPLAIN_IPK): $(LIBEXPLAIN_BUILD_DIR)/.built
	rm -rf $(LIBEXPLAIN_IPK_DIR) $(BUILD_DIR)/libexplain_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEXPLAIN_BUILD_DIR) DESTDIR=$(LIBEXPLAIN_IPK_DIR) clean-misc
	$(MAKE) -C $(LIBEXPLAIN_BUILD_DIR) DESTDIR=$(LIBEXPLAIN_IPK_DIR) install -j1
	$(STRIP_COMMAND) $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/bin/* $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	rm -f $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBEXPLAIN_SOURCE_DIR)/libexplain.conf $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/libexplain.conf
#	$(INSTALL) -d $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBEXPLAIN_SOURCE_DIR)/rc.libexplain $(LIBEXPLAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibexplain
	$(MAKE) $(LIBEXPLAIN_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBEXPLAIN_SOURCE_DIR)/postinst $(LIBEXPLAIN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBEXPLAIN_SOURCE_DIR)/prerm $(LIBEXPLAIN_IPK_DIR)/CONTROL/prerm
#	echo $(LIBEXPLAIN_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEXPLAIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEXPLAIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libexplain-ipk: $(LIBEXPLAIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libexplain-clean:
	-$(MAKE) -C $(LIBEXPLAIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libexplain-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEXPLAIN_DIR) $(LIBEXPLAIN_BUILD_DIR) $(LIBEXPLAIN_IPK_DIR) $(LIBEXPLAIN_IPK)

#
# Some sanity check for the package.
#
libexplain-check: $(LIBEXPLAIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
