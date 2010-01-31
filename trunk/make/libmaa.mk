###########################################################
#
# libmaa
#
###########################################################
#
# LIBMAA_VERSION, LIBMAA_SITE and LIBMAA_SOURCE define
# the upstream location of the source code for the package.
# LIBMAA_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMAA_UNZIP is the command used to unzip the source.
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
LIBMAA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dict
LIBMAA_VERSION=1.2.0
LIBMAA_SOURCE=libmaa-$(LIBMAA_VERSION).tar.gz
LIBMAA_DIR=libmaa-$(LIBMAA_VERSION)
LIBMAA_UNZIP=zcat
LIBMAA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMAA_DESCRIPTION=The LIBMAA library provides many low-level data structures which are helpful for writing compilers, including hash tables, sets, lists, debugging support, and memory management.
LIBMAA_SECTION=lib
LIBMAA_PRIORITY=optional
LIBMAA_DEPENDS=
LIBMAA_SUGGESTS=
LIBMAA_CONFLICTS=

#
# LIBMAA_IPK_VERSION should be incremented when the ipk changes.
#
LIBMAA_IPK_VERSION=1

#
# LIBMAA_CONFFILES should be a list of user-editable files
#LIBMAA_CONFFILES=/opt/etc/libmaa.conf /opt/etc/init.d/SXXlibmaa

#
# LIBMAA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMAA_PATCHES=$(LIBMAA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMAA_CPPFLAGS=
LIBMAA_LDFLAGS=

#
# LIBMAA_BUILD_DIR is the directory in which the build is done.
# LIBMAA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMAA_IPK_DIR is the directory in which the ipk is built.
# LIBMAA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMAA_BUILD_DIR=$(BUILD_DIR)/libmaa
LIBMAA_SOURCE_DIR=$(SOURCE_DIR)/libmaa
LIBMAA_IPK_DIR=$(BUILD_DIR)/libmaa-$(LIBMAA_VERSION)-ipk
LIBMAA_IPK=$(BUILD_DIR)/libmaa_$(LIBMAA_VERSION)-$(LIBMAA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmaa-source libmaa-unpack libmaa libmaa-stage libmaa-ipk libmaa-clean libmaa-dirclean libmaa-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMAA_SOURCE):
	$(WGET) -P $(@D) $(LIBMAA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmaa-source: $(DL_DIR)/$(LIBMAA_SOURCE) $(LIBMAA_PATCHES)

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
$(LIBMAA_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMAA_SOURCE) $(LIBMAA_PATCHES) make/libmaa.mk
	$(MAKE) libtool-stage
	rm -rf $(BUILD_DIR)/$(LIBMAA_DIR) $(@D)
	$(LIBMAA_UNZIP) $(DL_DIR)/$(LIBMAA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMAA_PATCHES)" ; \
		then cat $(LIBMAA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMAA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMAA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMAA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMAA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMAA_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmaa-unpack: $(LIBMAA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMAA_BUILD_DIR)/.built: $(LIBMAA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LIBTOOL="$(STAGING_PREFIX)/bin/libtool"
	touch $@

#
# This is the build convenience target.
#
libmaa: $(LIBMAA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMAA_BUILD_DIR)/.staged: $(LIBMAA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install \
		DESTDIR=$(STAGING_DIR) LIBTOOL="$(STAGING_PREFIX)/bin/libtool"
	rm -f $(STAGING_LIB_DIR)/libmaa.a $(STAGING_LIB_DIR)/libmaa.la
	touch $@

libmaa-stage: $(LIBMAA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmaa
#
$(LIBMAA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmaa" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMAA_PRIORITY)" >>$@
	@echo "Section: $(LIBMAA_SECTION)" >>$@
	@echo "Version: $(LIBMAA_VERSION)-$(LIBMAA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMAA_MAINTAINER)" >>$@
	@echo "Source: $(LIBMAA_SITE)/$(LIBMAA_SOURCE)" >>$@
	@echo "Description: $(LIBMAA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMAA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMAA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMAA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMAA_IPK_DIR)/opt/sbin or $(LIBMAA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMAA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMAA_IPK_DIR)/opt/etc/libmaa/...
# Documentation files should be installed in $(LIBMAA_IPK_DIR)/opt/doc/libmaa/...
# Daemon startup scripts should be installed in $(LIBMAA_IPK_DIR)/opt/etc/init.d/S??libmaa
#
# You may need to patch your application to make it use these locations.
#
$(LIBMAA_IPK): $(LIBMAA_BUILD_DIR)/.built
	rm -rf $(LIBMAA_IPK_DIR) $(BUILD_DIR)/libmaa_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<D) install \
		DESTDIR=$(LIBMAA_IPK_DIR) LIBTOOL="$(STAGING_PREFIX)/bin/libtool"
	$(STRIP_COMMAND) $(LIBMAA_IPK_DIR)/opt/lib/libmaa.so.[0-9]*.[0-9]*.[0-9]*
	rm -f $(LIBMAA_IPK_DIR)/opt/lib/libmaa.a
	$(MAKE) $(LIBMAA_IPK_DIR)/CONTROL/control
	echo $(LIBMAA_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMAA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMAA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmaa-ipk: $(LIBMAA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmaa-clean:
	rm -f $(LIBMAA_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMAA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmaa-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMAA_DIR) $(LIBMAA_BUILD_DIR) $(LIBMAA_IPK_DIR) $(LIBMAA_IPK)
#
#
# Some sanity check for the package.
#
libmaa-check: $(LIBMAA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
