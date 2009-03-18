###########################################################
#
# libgpg-error
#
###########################################################

# You must replace "libgpg-error" and "LIBGPG-ERROR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBGPG-ERROR_VERSION, LIBGPG-ERROR_SITE and LIBGPG-ERROR_SOURCE define
# the upstream location of the source code for the package.
# LIBGPG-ERROR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGPG-ERROR_UNZIP is the command used to unzip the source.
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
LIBGPG-ERROR_SITE=ftp://ftp.gnupg.org/gcrypt/libgpg-error
LIBGPG-ERROR_VERSION=1.7
LIBGPG-ERROR_SOURCE=libgpg-error-$(LIBGPG-ERROR_VERSION).tar.gz
LIBGPG-ERROR_DIR=libgpg-error-$(LIBGPG-ERROR_VERSION)
LIBGPG-ERROR_UNZIP=zcat
LIBGPG-ERROR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGPG-ERROR_DESCRIPTION=Error handling library for libgcrypt
LIBGPG-ERROR_SECTION=libs
LIBGPG-ERROR_PRIORITY=optional
LIBGPG-ERROR_DEPENDS=
LIBGPG-ERROR_SUGGESTS=
LIBGPG-ERROR_CONFLICTS=

#
# LIBGPG-ERROR_IPK_VERSION should be incremented when the ipk changes.
#
LIBGPG-ERROR_IPK_VERSION=1

#
# LIBGPG-ERROR_CONFFILES should be a list of user-editable files
LIBGPG-ERROR_CONFFILES=#/opt/etc/libgpg-error.conf /opt/etc/init.d/SXXlibgpg-error

#
# LIBGPG-ERROR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBGPG-ERROR_PATCHES=#$(LIBGPG-ERROR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGPG-ERROR_CPPFLAGS=
LIBGPG-ERROR_LDFLAGS=

#
# LIBGPG-ERROR_BUILD_DIR is the directory in which the build is done.
# LIBGPG-ERROR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGPG-ERROR_IPK_DIR is the directory in which the ipk is built.
# LIBGPG-ERROR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGPG-ERROR_BUILD_DIR=$(BUILD_DIR)/libgpg-error
LIBGPG-ERROR_SOURCE_DIR=$(SOURCE_DIR)/libgpg-error
LIBGPG-ERROR_IPK_DIR=$(BUILD_DIR)/libgpg-error-$(LIBGPG-ERROR_VERSION)-ipk
LIBGPG-ERROR_IPK=$(BUILD_DIR)/libgpg-error_$(LIBGPG-ERROR_VERSION)-$(LIBGPG-ERROR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgpg-error-source libgpg-error-unpack libgpg-error libgpg-error-stage libgpg-error-ipk libgpg-error-clean libgpg-error-dirclean libgpg-error-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGPG-ERROR_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGPG-ERROR_SITE)/$(LIBGPG-ERROR_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBGPG-ERROR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgpg-error-source: $(DL_DIR)/$(LIBGPG-ERROR_SOURCE) $(LIBGPG-ERROR_PATCHES)

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
$(LIBGPG-ERROR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGPG-ERROR_SOURCE) $(LIBGPG-ERROR_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBGPG-ERROR_DIR) $(LIBGPG-ERROR_BUILD_DIR)
	$(LIBGPG-ERROR_UNZIP) $(DL_DIR)/$(LIBGPG-ERROR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBGPG-ERROR_PATCHES) | patch -d $(BUILD_DIR)/$(LIBGPG-ERROR_DIR) -p1
	mv $(BUILD_DIR)/$(LIBGPG-ERROR_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGPG-ERROR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGPG-ERROR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libgpg-error-unpack: $(LIBGPG-ERROR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGPG-ERROR_BUILD_DIR)/.built: $(LIBGPG-ERROR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libgpg-error: $(LIBGPG-ERROR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGPG-ERROR_BUILD_DIR)/.staged: $(LIBGPG-ERROR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|-I$$includedir|-I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/gpg-error-config
	rm -f $(STAGING_DIR)/opt/lib/libgpg-error.la
	touch $@

libgpg-error-stage: $(LIBGPG-ERROR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libgpg-error
#
$(LIBGPG-ERROR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libgpg-error" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGPG-ERROR_PRIORITY)" >>$@
	@echo "Section: $(LIBGPG-ERROR_SECTION)" >>$@
	@echo "Version: $(LIBGPG-ERROR_VERSION)-$(LIBGPG-ERROR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGPG-ERROR_MAINTAINER)" >>$@
	@echo "Source: $(LIBGPG-ERROR_SITE)/$(LIBGPG-ERROR_SOURCE)" >>$@
	@echo "Description: $(LIBGPG-ERROR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGPG-ERROR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGPG-ERROR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGPG-ERROR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGPG-ERROR_IPK_DIR)/opt/sbin or $(LIBGPG-ERROR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGPG-ERROR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGPG-ERROR_IPK_DIR)/opt/etc/libgpg-error/...
# Documentation files should be installed in $(LIBGPG-ERROR_IPK_DIR)/opt/doc/libgpg-error/...
# Daemon startup scripts should be installed in $(LIBGPG-ERROR_IPK_DIR)/opt/etc/init.d/S??libgpg-error
#
# You may need to patch your application to make it use these locations.
#
$(LIBGPG-ERROR_IPK): $(LIBGPG-ERROR_BUILD_DIR)/.built
	rm -rf $(LIBGPG-ERROR_IPK_DIR) $(BUILD_DIR)/libgpg-error_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGPG-ERROR_BUILD_DIR) DESTDIR=$(LIBGPG-ERROR_IPK_DIR) install-strip
	#install -d $(LIBGPG-ERROR_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBGPG-ERROR_SOURCE_DIR)/libgpg-error.conf $(LIBGPG-ERROR_IPK_DIR)/opt/etc/libgpg-error.conf
	#install -d $(LIBGPG-ERROR_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBGPG-ERROR_SOURCE_DIR)/rc.libgpg-error $(LIBGPG-ERROR_IPK_DIR)/opt/etc/init.d/SXXlibgpg-error
	$(MAKE) $(LIBGPG-ERROR_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBGPG-ERROR_SOURCE_DIR)/postinst $(LIBGPG-ERROR_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBGPG-ERROR_SOURCE_DIR)/prerm $(LIBGPG-ERROR_IPK_DIR)/CONTROL/prerm
	echo $(LIBGPG-ERROR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBGPG-ERROR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGPG-ERROR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgpg-error-ipk: $(LIBGPG-ERROR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgpg-error-clean:
	-$(MAKE) -C $(LIBGPG-ERROR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgpg-error-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGPG-ERROR_DIR) $(LIBGPG-ERROR_BUILD_DIR) $(LIBGPG-ERROR_IPK_DIR) $(LIBGPG-ERROR_IPK)

#
# Some sanity check for the package.
#
libgpg-error-check: $(LIBGPG-ERROR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
