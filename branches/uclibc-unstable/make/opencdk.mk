###########################################################
#
# opencdk
#
###########################################################

# You must replace "opencdk" and "OPENCDK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# OPENCDK_VERSION, OPENCDK_SITE and OPENCDK_SOURCE define
# the upstream location of the source code for the package.
# OPENCDK_DIR is the directory which is created when the source
# archive is unpacked.
# OPENCDK_UNZIP is the command used to unzip the source.
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
OPENCDK_SITE=http://josefsson.org/gnutls/releases/opencdk
# http://ftp.gnupg.org/GnuPG/alpha/gnutls/opencdk
OPENCDK_VERSION=0.5.13
OPENCDK_SOURCE=opencdk-$(OPENCDK_VERSION).tar.gz
OPENCDK_DIR=opencdk-$(OPENCDK_VERSION)
OPENCDK_UNZIP=zcat
OPENCDK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENCDK_DESCRIPTION=GNU cryptographic library.
OPENCDK_SECTION=libs
OPENCDK_PRIORITY=optional
OPENCDK_DEPENDS=libgcrypt
OPENCDK_SUGGESTS=
OPENCDK_CONFLICTS=

#
# OPENCDK_IPK_VERSION should be incremented when the ipk changes.
#
OPENCDK_IPK_VERSION=1

#
# OPENCDK_CONFFILES should be a list of user-editable files
OPENCDK_CONFFILES=#/opt/etc/opencdk.conf /opt/etc/init.d/SXXopencdk

#
# OPENCDK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPENCDK_PATCHES=#$(OPENCDK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENCDK_CPPFLAGS=
OPENCDK_LDFLAGS=

#
# OPENCDK_BUILD_DIR is the directory in which the build is done.
# OPENCDK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENCDK_IPK_DIR is the directory in which the ipk is built.
# OPENCDK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENCDK_BUILD_DIR=$(BUILD_DIR)/opencdk
OPENCDK_SOURCE_DIR=$(SOURCE_DIR)/opencdk
OPENCDK_IPK_DIR=$(BUILD_DIR)/opencdk-$(OPENCDK_VERSION)-ipk
OPENCDK_IPK=$(BUILD_DIR)/opencdk_$(OPENCDK_VERSION)-$(OPENCDK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: opencdk-source opencdk-unpack opencdk opencdk-stage opencdk-ipk opencdk-clean opencdk-dirclean opencdk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENCDK_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENCDK_SITE)/$(OPENCDK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
opencdk-source: $(DL_DIR)/$(OPENCDK_SOURCE) $(OPENCDK_PATCHES)

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
$(OPENCDK_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENCDK_SOURCE) $(OPENCDK_PATCHES)
	$(MAKE) libgcrypt-stage
	rm -rf $(BUILD_DIR)/$(OPENCDK_DIR) $(OPENCDK_BUILD_DIR)
	$(OPENCDK_UNZIP) $(DL_DIR)/$(OPENCDK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(OPENCDK_PATCHES) | patch -d $(BUILD_DIR)/$(OPENCDK_DIR) -p1
	mv $(BUILD_DIR)/$(OPENCDK_DIR) $(OPENCDK_BUILD_DIR)
	(cd $(OPENCDK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENCDK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENCDK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libgcrypt-prefix=$(STAGING_DIR)/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(OPENCDK_BUILD_DIR)/libtool
	touch $(OPENCDK_BUILD_DIR)/.configured

opencdk-unpack: $(OPENCDK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENCDK_BUILD_DIR)/.built: $(OPENCDK_BUILD_DIR)/.configured
	rm -f $(OPENCDK_BUILD_DIR)/.built
	$(MAKE) -C $(OPENCDK_BUILD_DIR)
	touch $(OPENCDK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
opencdk: $(OPENCDK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENCDK_BUILD_DIR)/.staged: $(OPENCDK_BUILD_DIR)/.built
	rm -f $(OPENCDK_BUILD_DIR)/.staged
	$(MAKE) -C $(OPENCDK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^opencdk_cflags/s|-I/opt/include ||g' \
	       -e '/^opencdk_cflags/s|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|' \
	       -e '/includes=/s|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|' \
		$(STAGING_PREFIX)/bin/opencdk-config
	rm -f $(STAGING_DIR)/opt/lib/libopencdk.la
	touch $(OPENCDK_BUILD_DIR)/.staged

opencdk-stage: $(OPENCDK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/opencdk
#
$(OPENCDK_IPK_DIR)/CONTROL/control:
	@install -d $(OPENCDK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: opencdk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENCDK_PRIORITY)" >>$@
	@echo "Section: $(OPENCDK_SECTION)" >>$@
	@echo "Version: $(OPENCDK_VERSION)-$(OPENCDK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENCDK_MAINTAINER)" >>$@
	@echo "Source: $(OPENCDK_SITE)/$(OPENCDK_SOURCE)" >>$@
	@echo "Description: $(OPENCDK_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENCDK_DEPENDS)" >>$@
	@echo "Suggests: $(OPENCDK_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENCDK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENCDK_IPK_DIR)/opt/sbin or $(OPENCDK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENCDK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENCDK_IPK_DIR)/opt/etc/opencdk/...
# Documentation files should be installed in $(OPENCDK_IPK_DIR)/opt/doc/opencdk/...
# Daemon startup scripts should be installed in $(OPENCDK_IPK_DIR)/opt/etc/init.d/S??opencdk
#
# You may need to patch your application to make it use these locations.
#
$(OPENCDK_IPK): $(OPENCDK_BUILD_DIR)/.built
	rm -rf $(OPENCDK_IPK_DIR) $(BUILD_DIR)/opencdk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPENCDK_BUILD_DIR) DESTDIR=$(OPENCDK_IPK_DIR) install-strip
	#install -d $(OPENCDK_IPK_DIR)/opt/etc/
	#install -m 644 $(OPENCDK_SOURCE_DIR)/opencdk.conf $(OPENCDK_IPK_DIR)/opt/etc/opencdk.conf
	#install -d $(OPENCDK_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(OPENCDK_SOURCE_DIR)/rc.opencdk $(OPENCDK_IPK_DIR)/opt/etc/init.d/SXXopencdk
	$(MAKE) $(OPENCDK_IPK_DIR)/CONTROL/control
	#install -m 755 $(OPENCDK_SOURCE_DIR)/postinst $(OPENCDK_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(OPENCDK_SOURCE_DIR)/prerm $(OPENCDK_IPK_DIR)/CONTROL/prerm
	echo $(OPENCDK_CONFFILES) | sed -e 's/ /\n/g' > $(OPENCDK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENCDK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
opencdk-ipk: $(OPENCDK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
opencdk-clean:
	-$(MAKE) -C $(OPENCDK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
opencdk-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENCDK_DIR) $(OPENCDK_BUILD_DIR) $(OPENCDK_IPK_DIR) $(OPENCDK_IPK)

#
# Some sanity check for the package.
#
opencdk-check: $(OPENCDK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENCDK_IPK)
