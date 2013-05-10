###########################################################
#
# libmicrohttpd
#
###########################################################
#
# LIBMICROHTTPD_VERSION, LIBMICROHTTPD_SITE and LIBMICROHTTPD_SOURCE define
# the upstream location of the source code for the package.
# LIBMICROHTTPD_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMICROHTTPD_UNZIP is the command used to unzip the source.
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
LIBMICROHTTPD_SITE=ftp://ftp.gnu.org/gnu/libmicrohttpd/
LIBMICROHTTPD_VERSION=0.9.27
LIBMICROHTTPD_SOURCE=libmicrohttpd-$(LIBMICROHTTPD_VERSION).tar.gz
LIBMICROHTTPD_DIR=libmicrohttpd-$(LIBMICROHTTPD_VERSION)
LIBMICROHTTPD_UNZIP=zcat
LIBMICROHTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMICROHTTPD_DESCRIPTION=Small C library for embedding HTTP server functionality into other applications
LIBMICROHTTPD_SECTION=libs
LIBMICROHTTPD_PRIORITY=optional
LIBMICROHTTPD_DEPENDS=
LIBMICROHTTPD_SUGGESTS=
LIBMICROHTTPD_CONFLICTS=

#
# LIBMICROHTTPD_IPK_VERSION should be incremented when the ipk changes.
#
LIBMICROHTTPD_IPK_VERSION=1

#
# LIBMICROHTTPD_CONFFILES should be a list of user-editable files
#LIBMICROHTTPD_CONFFILES=/opt/etc/libmicrohttpd.conf /opt/etc/init.d/SXXlibmicrohttpd

#
# LIBMICROHTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMICROHTTPD_PATCHES=$(LIBMICROHTTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMICROHTTPD_CPPFLAGS ?=
LIBMICROHTTPD_LDFLAGS=

#
# LIBMICROHTTPD_BUILD_DIR is the directory in which the build is done.
# LIBMICROHTTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMICROHTTPD_IPK_DIR is the directory in which the ipk is built.
# LIBMICROHTTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMICROHTTPD_BUILD_DIR=$(BUILD_DIR)/libmicrohttpd
LIBMICROHTTPD_SOURCE_DIR=$(SOURCE_DIR)/libmicrohttpd
LIBMICROHTTPD_IPK_DIR=$(BUILD_DIR)/libmicrohttpd-$(LIBMICROHTTPD_VERSION)-ipk
LIBMICROHTTPD_IPK=$(BUILD_DIR)/libmicrohttpd_$(LIBMICROHTTPD_VERSION)-$(LIBMICROHTTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmicrohttpd-source libmicrohttpd-unpack libmicrohttpd libmicrohttpd-stage libmicrohttpd-ipk libmicrohttpd-clean libmicrohttpd-dirclean libmicrohttpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMICROHTTPD_SOURCE):
	$(WGET) -P $(@D) $(LIBMICROHTTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmicrohttpd-source: $(DL_DIR)/$(LIBMICROHTTPD_SOURCE) $(LIBMICROHTTPD_PATCHES)

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
$(LIBMICROHTTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMICROHTTPD_SOURCE) $(LIBMICROHTTPD_PATCHES) make/libmicrohttpd.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMICROHTTPD_DIR) $(@D)
	$(LIBMICROHTTPD_UNZIP) $(DL_DIR)/$(LIBMICROHTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMICROHTTPD_PATCHES)" ; \
		then cat $(LIBMICROHTTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMICROHTTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMICROHTTPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMICROHTTPD_DIR) $(@D) ; \
	fi
	sed -i -e 's/(CLOCK_MONOTONIC,/(1,/' $(@D)/src/microhttpd/internal.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMICROHTTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMICROHTTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e "s/define _FILE_OFFSET_BITS.*/undef _FILE_OFFSET_BITS/" $(@D)/MHD_config.h
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmicrohttpd-unpack: $(LIBMICROHTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMICROHTTPD_BUILD_DIR)/.built: $(LIBMICROHTTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmicrohttpd: $(LIBMICROHTTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMICROHTTPD_BUILD_DIR)/.staged: $(LIBMICROHTTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libmicrohttpd-stage: $(LIBMICROHTTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmicrohttpd
#
$(LIBMICROHTTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmicrohttpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMICROHTTPD_PRIORITY)" >>$@
	@echo "Section: $(LIBMICROHTTPD_SECTION)" >>$@
	@echo "Version: $(LIBMICROHTTPD_VERSION)-$(LIBMICROHTTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMICROHTTPD_MAINTAINER)" >>$@
	@echo "Source: $(LIBMICROHTTPD_SITE)/$(LIBMICROHTTPD_SOURCE)" >>$@
	@echo "Description: $(LIBMICROHTTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMICROHTTPD_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMICROHTTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMICROHTTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMICROHTTPD_IPK_DIR)/opt/sbin or $(LIBMICROHTTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMICROHTTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMICROHTTPD_IPK_DIR)/opt/etc/libmicrohttpd/...
# Documentation files should be installed in $(LIBMICROHTTPD_IPK_DIR)/opt/doc/libmicrohttpd/...
# Daemon startup scripts should be installed in $(LIBMICROHTTPD_IPK_DIR)/opt/etc/init.d/S??libmicrohttpd
#
# You may need to patch your application to make it use these locations.
#
$(LIBMICROHTTPD_IPK): $(LIBMICROHTTPD_BUILD_DIR)/.built
	rm -rf $(LIBMICROHTTPD_IPK_DIR) $(BUILD_DIR)/libmicrohttpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMICROHTTPD_BUILD_DIR) DESTDIR=$(LIBMICROHTTPD_IPK_DIR) install-strip
	$(MAKE) $(LIBMICROHTTPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMICROHTTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmicrohttpd-ipk: $(LIBMICROHTTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmicrohttpd-clean:
	rm -f $(LIBMICROHTTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMICROHTTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmicrohttpd-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMICROHTTPD_DIR) $(LIBMICROHTTPD_BUILD_DIR) $(LIBMICROHTTPD_IPK_DIR) $(LIBMICROHTTPD_IPK)
#
#
# Some sanity check for the package.
#
libmicrohttpd-check: $(LIBMICROHTTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
