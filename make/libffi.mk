###########################################################
#
# libffi
#
###########################################################

#
# LIBFFI_VERSION, LIBFFI_SITE and LIBFFI_SOURCE define
# the upstream location of the source code for the package.
# LIBFFI_DIR is the directory which is created when the source
# archive is unpacked.
# LIBFFI_UNZIP is the command used to unzip the source.
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
LIBFFI_SITE=ftp://sourceware.org/pub/libffi
LIBFFI_VERSION=3.2.1
LIBFFI_SOURCE=libffi-$(LIBFFI_VERSION).tar.gz
LIBFFI_DIR=libffi-$(LIBFFI_VERSION)
LIBFFI_UNZIP=zcat
LIBFFI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBFFI_DESCRIPTION=A Portable Foreign Function Interface Library.
LIBFFI_SECTION=misc
LIBFFI_PRIORITY=optional
LIBFFI_DEPENDS=
LIBFFI_SUGGESTS=
LIBFFI_CONFLICTS=

#
# LIBFFI_IPK_VERSION should be incremented when the ipk changes.
#
LIBFFI_IPK_VERSION=1

#
# LIBFFI_CONFFILES should be a list of user-editable files
#LIBFFI_CONFFILES=$(TARGET_PREFIX)/etc/libffi.conf $(TARGET_PREFIX)/etc/init.d/SXXlibffi

#
# LIBFFI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBFFI_PATCHES=$(LIBFFI_SOURCE_DIR)/mips.softfloat.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBFFI_CPPFLAGS=
LIBFFI_LDFLAGS=

#
# LIBFFI_BUILD_DIR is the directory in which the build is done.
# LIBFFI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBFFI_IPK_DIR is the directory in which the ipk is built.
# LIBFFI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBFFI_BUILD_DIR=$(BUILD_DIR)/libffi
LIBFFI_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/libffi
LIBFFI_SOURCE_DIR=$(SOURCE_DIR)/libffi
LIBFFI_IPK_DIR=$(BUILD_DIR)/libffi-$(LIBFFI_VERSION)-ipk
LIBFFI_IPK=$(BUILD_DIR)/libffi_$(LIBFFI_VERSION)-$(LIBFFI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libffi-source libffi-unpack libffi libffi-stage libffi-ipk libffi-clean libffi-dirclean libffi-check libffi-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBFFI_SOURCE):
	$(WGET) -P $(@D) $(LIBFFI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libffi-source: $(DL_DIR)/$(LIBFFI_SOURCE) $(LIBFFI_PATCHES)

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
$(LIBFFI_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBFFI_SOURCE) $(LIBFFI_PATCHES) make/libffi.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBFFI_DIR) $(@D)
	$(LIBFFI_UNZIP) $(DL_DIR)/$(LIBFFI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBFFI_PATCHES)" ; \
		then cat $(LIBFFI_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBFFI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBFFI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBFFI_DIR) $(@D) ; \
	fi
	# we don't want lib64 dir for 64bit target
	sed -i -e 's/multi_os_directory=.*/multi_os_directory=""/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBFFI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBFFI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libffi-unpack: $(LIBFFI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBFFI_BUILD_DIR)/.built: $(LIBFFI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libffi: $(LIBFFI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBFFI_BUILD_DIR)/.staged: $(LIBFFI_BUILD_DIR)/.built
	rm -f $@ $(STAGING_LIB_DIR)/libffi.*
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libffi.la
	mv $(STAGING_LIB_DIR)/libffi-$(LIBFFI_VERSION)/include/* $(STAGING_INCLUDE_DIR)
	rm -rf $(STAGING_LIB_DIR)/libffi-$(LIBFFI_VERSION)
	sed -i -e 's|^Libs:.*|Libs: $(STAGING_LDFLAGS) $(LIBFFI_LDFLAGS) -lffi|' \
		-e 's|^Cflags:.*|Cflags: $(STAGING_CPPFLAGS) $(LIBFFI_CPPFLAGS)|' $(STAGING_LIB_DIR)/pkgconfig/libffi.pc
	touch $@

libffi-stage: $(LIBFFI_BUILD_DIR)/.staged

$(LIBFFI_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(LIBFFI_SOURCE) make/libffi.mk
	rm -rf $(HOST_BUILD_DIR)/$(LIBFFI_DIR) $(@D)
	$(LIBFFI_UNZIP) $(DL_DIR)/$(LIBFFI_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(LIBFFI_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(LIBFFI_DIR) $(@D) ; \
	fi
	(cd $(@D); \
	    CPPFLAGS="-fPIC" \
	    ./configure \
		--prefix=/opt $(LIBFFI_HOST32) \
		--disable-nls \
		--disable-shared; \
	    $(MAKE) DESTDIR=$(HOST_STAGING_DIR) install; \
	)
	mkdir -p $(HOST_STAGING_INCLUDE_DIR)
	mv $(HOST_STAGING_LIB_DIR)/libffi-$(LIBFFI_VERSION)/include/* $(HOST_STAGING_INCLUDE_DIR)
	rm -rf $(HOST_STAGING_LIB_DIR)/libffi-$(LIBFFI_VERSION)
	sed -i -e 's|^Libs:.*|Libs: -L$(HOST_STAGING_LIB_DIR) -lffi|' \
		-e 's|^Cflags:.*|Cflags: -I$(HOST_STAGING_INCLUDE_DIR)|' $(HOST_STAGING_LIB_DIR)/pkgconfig/libffi.pc
	rm -f $(HOST_STAGING_LIB_DIR)/libffi.la
	touch $@

libffi-host-stage: $(LIBFFI_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libffi
#
$(LIBFFI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libffi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBFFI_PRIORITY)" >>$@
	@echo "Section: $(LIBFFI_SECTION)" >>$@
	@echo "Version: $(LIBFFI_VERSION)-$(LIBFFI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBFFI_MAINTAINER)" >>$@
	@echo "Source: $(LIBFFI_SITE)/$(LIBFFI_SOURCE)" >>$@
	@echo "Description: $(LIBFFI_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFFI_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFFI_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFFI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/libffi/...
# Documentation files should be installed in $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/doc/libffi/...
# Daemon startup scripts should be installed in $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libffi
#
# You may need to patch your application to make it use these locations.
#
$(LIBFFI_IPK): $(LIBFFI_BUILD_DIR)/.built
	rm -rf $(LIBFFI_IPK_DIR) $(BUILD_DIR)/libffi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBFFI_BUILD_DIR) DESTDIR=$(LIBFFI_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/lib/libffi.so.*
#	$(INSTALL) -d $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBFFI_SOURCE_DIR)/libffi.conf $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/libffi.conf
#	$(INSTALL) -d $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBFFI_SOURCE_DIR)/rc.libffi $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibffi
	rm -f $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/share/info/dir $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/lib/libffi.la
	mkdir -p $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/include
	mv $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/lib/libffi-$(LIBFFI_VERSION)/include/* $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/include
	rm -rf $(LIBFFI_IPK_DIR)$(TARGET_PREFIX)/lib/libffi-$(LIBFFI_VERSION)
	$(MAKE) $(LIBFFI_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBFFI_SOURCE_DIR)/postinst $(LIBFFI_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBFFI_SOURCE_DIR)/prerm $(LIBFFI_IPK_DIR)/CONTROL/prerm
	echo $(LIBFFI_CONFFILES) | sed -e 's/ /\n/g' > $(LIBFFI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFFI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libffi-ipk: $(LIBFFI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libffi-clean:
	rm -f $(LIBFFI_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBFFI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libffi-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBFFI_DIR) $(LIBFFI_BUILD_DIR) $(LIBFFI_IPK_DIR) $(LIBFFI_IPK)

#
# Some sanity check for the package.
#
libffi-check: $(LIBFFI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
