###########################################################
#
# libmemcache
#
###########################################################

#
# LIBMEMCACHE_VERSION, LIBMEMCACHE_SITE and LIBMEMCACHE_SOURCE define
# the upstream location of the source code for the package.
# LIBMEMCACHE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMEMCACHE_UNZIP is the command used to unzip the source.
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
LIBMEMCACHE_SITE=http://people.freebsd.org/~seanc/libmemcache
LIBMEMCACHE_VERSION=1.4.0.rc2
LIBMEMCACHE_SOURCE=libmemcache-$(LIBMEMCACHE_VERSION).tar.bz2
LIBMEMCACHE_DIR=libmemcache-$(LIBMEMCACHE_VERSION)
LIBMEMCACHE_UNZIP=bzcat
LIBMEMCACHE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMEMCACHE_DESCRIPTION=The C API for memcached.
LIBMEMCACHE_SECTION=lib
LIBMEMCACHE_PRIORITY=optional
LIBMEMCACHE_DEPENDS=
LIBMEMCACHE_SUGGESTS=
LIBMEMCACHE_CONFLICTS=

#
# LIBMEMCACHE_IPK_VERSION should be incremented when the ipk changes.
#
LIBMEMCACHE_IPK_VERSION=3

#
# LIBMEMCACHE_CONFFILES should be a list of user-editable files
#LIBMEMCACHE_CONFFILES=/opt/etc/libmemcache.conf /opt/etc/init.d/SXXlibmemcache

#
# LIBMEMCACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMEMCACHE_PATCHES=$(LIBMEMCACHE_SOURCE_DIR)/configure.ac.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMEMCACHE_CPPFLAGS=-D__linux
LIBMEMCACHE_LDFLAGS=

#
# LIBMEMCACHE_BUILD_DIR is the directory in which the build is done.
# LIBMEMCACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMEMCACHE_IPK_DIR is the directory in which the ipk is built.
# LIBMEMCACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMEMCACHE_BUILD_DIR=$(BUILD_DIR)/libmemcache
LIBMEMCACHE_SOURCE_DIR=$(SOURCE_DIR)/libmemcache
LIBMEMCACHE_IPK_DIR=$(BUILD_DIR)/libmemcache-$(LIBMEMCACHE_VERSION)-ipk
LIBMEMCACHE_IPK=$(BUILD_DIR)/libmemcache_$(LIBMEMCACHE_VERSION)-$(LIBMEMCACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMEMCACHE_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMEMCACHE_SITE)/$(LIBMEMCACHE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmemcache-source: $(DL_DIR)/$(LIBMEMCACHE_SOURCE) $(LIBMEMCACHE_PATCHES)

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
$(LIBMEMCACHE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMEMCACHE_SOURCE) $(LIBMEMCACHE_PATCHES) make/libmemcache.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMEMCACHE_DIR) $(LIBMEMCACHE_BUILD_DIR)
	$(LIBMEMCACHE_UNZIP) $(DL_DIR)/$(LIBMEMCACHE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMEMCACHE_PATCHES)" ; \
		then cat $(LIBMEMCACHE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMEMCACHE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMEMCACHE_DIR)" != "$(LIBMEMCACHE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMEMCACHE_DIR) $(LIBMEMCACHE_BUILD_DIR) ; \
	fi
ifeq (, $(filter -pipe, $(TARGET_CUSTOM_FLAGS)))
	sed -i -e 's|-Wall -pipe|-Wall|' $(@D)/configure.ac
endif
	(cd $(LIBMEMCACHE_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMEMCACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMEMCACHE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMEMCACHE_BUILD_DIR)/libtool
	touch $(LIBMEMCACHE_BUILD_DIR)/.configured

libmemcache-unpack: $(LIBMEMCACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMEMCACHE_BUILD_DIR)/.built: $(LIBMEMCACHE_BUILD_DIR)/.configured
	rm -f $(LIBMEMCACHE_BUILD_DIR)/.built
	$(MAKE) -C $(LIBMEMCACHE_BUILD_DIR)
	touch $(LIBMEMCACHE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libmemcache: $(LIBMEMCACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMEMCACHE_BUILD_DIR)/.staged: $(LIBMEMCACHE_BUILD_DIR)/.built
	rm -f $(LIBMEMCACHE_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBMEMCACHE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmemcache*.la
	touch $(LIBMEMCACHE_BUILD_DIR)/.staged

libmemcache-stage: $(LIBMEMCACHE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmemcache
#
$(LIBMEMCACHE_IPK_DIR)/CONTROL/control:
	@install -d $(LIBMEMCACHE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libmemcache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMEMCACHE_PRIORITY)" >>$@
	@echo "Section: $(LIBMEMCACHE_SECTION)" >>$@
	@echo "Version: $(LIBMEMCACHE_VERSION)-$(LIBMEMCACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMEMCACHE_MAINTAINER)" >>$@
	@echo "Source: $(LIBMEMCACHE_SITE)/$(LIBMEMCACHE_SOURCE)" >>$@
	@echo "Description: $(LIBMEMCACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMEMCACHE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMEMCACHE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMEMCACHE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMEMCACHE_IPK_DIR)/opt/sbin or $(LIBMEMCACHE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMEMCACHE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMEMCACHE_IPK_DIR)/opt/etc/libmemcache/...
# Documentation files should be installed in $(LIBMEMCACHE_IPK_DIR)/opt/doc/libmemcache/...
# Daemon startup scripts should be installed in $(LIBMEMCACHE_IPK_DIR)/opt/etc/init.d/S??libmemcache
#
# You may need to patch your application to make it use these locations.
#
$(LIBMEMCACHE_IPK): $(LIBMEMCACHE_BUILD_DIR)/.built
	rm -rf $(LIBMEMCACHE_IPK_DIR) $(BUILD_DIR)/libmemcache_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMEMCACHE_BUILD_DIR) DESTDIR=$(LIBMEMCACHE_IPK_DIR) install
	rm -f $(LIBMEMCACHE_IPK_DIR)/opt/lib/*.la
	$(STRIP_COMMAND) $(LIBMEMCACHE_IPK_DIR)/opt/lib/libmemcache.so.[0-9]*.[0-9]*.[0-9]*
#	install -d $(LIBMEMCACHE_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMEMCACHE_SOURCE_DIR)/libmemcache.conf $(LIBMEMCACHE_IPK_DIR)/opt/etc/libmemcache.conf
#	install -d $(LIBMEMCACHE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMEMCACHE_SOURCE_DIR)/rc.libmemcache $(LIBMEMCACHE_IPK_DIR)/opt/etc/init.d/SXXlibmemcache
	$(MAKE) $(LIBMEMCACHE_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMEMCACHE_SOURCE_DIR)/postinst $(LIBMEMCACHE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMEMCACHE_SOURCE_DIR)/prerm $(LIBMEMCACHE_IPK_DIR)/CONTROL/prerm
	echo $(LIBMEMCACHE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMEMCACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMEMCACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmemcache-ipk: $(LIBMEMCACHE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmemcache-clean:
	rm -f $(LIBMEMCACHE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMEMCACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmemcache-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMEMCACHE_DIR) $(LIBMEMCACHE_BUILD_DIR) $(LIBMEMCACHE_IPK_DIR) $(LIBMEMCACHE_IPK)
