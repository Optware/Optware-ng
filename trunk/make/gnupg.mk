###########################################################
#
# gnupg
#
###########################################################

#
# GNUPG_VERSION, GNUPG_SITE and GNUPG_SOURCE define
# the upstream location of the source code for the package.
# GNUPG_DIR is the directory which is created when the source
# archive is unpacked.
# GNUPG_UNZIP is the command used to unzip the source.
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
GNUPG_SITE=ftp://ftp.gnupg.org/gcrypt/gnupg
GNUPG_VERSION=2.0.9
GNUPG_SOURCE=gnupg-$(GNUPG_VERSION).tar.bz2
GNUPG_DIR=gnupg-$(GNUPG_VERSION)
GNUPG_UNZIP=bzcat
GNUPG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNUPG_DESCRIPTION=GNU privacy guard - a free PGP replacement.
GNUPG_SECTION=misc
GNUPG_PRIORITY=optional
GNUPG_DEPENDS=libusb, zlib, bzip2, readline, libcurl, openldap-libs, libgcrypt, libpth, libksba, pinentry
GNUPG_SUGGESTS=
GNUPG_CONFLICTS=

#
# GNUPG_IPK_VERSION should be incremented when the ipk changes.
#
GNUPG_IPK_VERSION=2

#
# GNUPG_CONFFILES should be a list of user-editable files
#GNUPG_CONFFILES=/opt/etc/gnupg.conf /opt/etc/init.d/SXXgnupg

#
# GNUPG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GNUPG_PATCHES=$(GNUPG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNUPG_CPPFLAGS=
GNUPG_LDFLAGS=

#
# GNUPG_BUILD_DIR is the directory in which the build is done.
# GNUPG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNUPG_IPK_DIR is the directory in which the ipk is built.
# GNUPG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNUPG_BUILD_DIR=$(BUILD_DIR)/gnupg
GNUPG_SOURCE_DIR=$(SOURCE_DIR)/gnupg
GNUPG_IPK_DIR=$(BUILD_DIR)/gnupg-$(GNUPG_VERSION)-ipk
GNUPG_IPK=$(BUILD_DIR)/gnupg_$(GNUPG_VERSION)-$(GNUPG_IPK_VERSION)_$(TARGET_ARCH).ipk

# uclibc 0.9.28 is missing dn_skipname() impleemtation
ifeq ($(LIBC_STYLE), uclibc)
GNUPG_CFG_OPTS= --disable-dns-pka --disable-dns-cert --disable-dns-srv
endif
ifeq ($(TARGET_ARCH), $(filter powerpc i386 i686, $(TARGET_ARCH)))
GNUPG_CFG_ENV=ac_cv_sys_symbol_underscore=no
endif

.PHONY: gnupg-source gnupg-unpack gnupg gnupg-stage gnupg-ipk gnupg-clean gnupg-dirclean gnupg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNUPG_SOURCE):
	$(WGET) -P $(@D) $(GNUPG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnupg-source: $(DL_DIR)/$(GNUPG_SOURCE) $(GNUPG_PATCHES)

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
$(GNUPG_BUILD_DIR)/.configured: $(DL_DIR)/$(GNUPG_SOURCE) $(GNUPG_PATCHES) make/gnupg.mk
	$(MAKE) libusb-stage bzip2-stage zlib-stage readline-stage libcurl-stage openldap-stage
	$(MAKE) libassuan-stage libgpg-error-stage libgcrypt-stage libpth-stage libksba-stage
	rm -rf $(BUILD_DIR)/$(GNUPG_DIR) $(GNUPG_BUILD_DIR)
	$(GNUPG_UNZIP) $(DL_DIR)/$(GNUPG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GNUPG_PATCHES) | patch -d $(BUILD_DIR)/$(GNUPG_DIR) -p1
	mv $(BUILD_DIR)/$(GNUPG_DIR) $(GNUPG_BUILD_DIR)
	(cd $(GNUPG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNUPG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNUPG_LDFLAGS)" \
		$(GNUPG_CFG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-libusb=$(STAGING_PREFIX) \
		--with-zlib=$(STAGING_PREFIX) \
		--with-readline=$(STAGING_PREFIX) \
		--with-libcurl=$(STAGING_PREFIX) \
		--with-ldap=$(STAGING_PREFIX) \
		--prefix=/opt \
		--with-gpg-error-prefix=$(STAGING_PREFIX) \
		--with-libgcrypt-prefix=$(STAGING_PREFIX) \
		--with-pth-prefix=$(STAGING_PREFIX) \
		--with-ksba-prefix=$(STAGING_PREFIX) \
		--with-libassuan-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		$(GNUPG_CFG_OPTS) \
	)
	touch $@

gnupg-unpack: $(GNUPG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNUPG_BUILD_DIR)/.built: $(GNUPG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GNUPG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gnupg: $(GNUPG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNUPG_BUILD_DIR)/.staged: $(GNUPG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GNUPG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

gnupg-stage: $(GNUPG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnupg
#
$(GNUPG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnupg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUPG_PRIORITY)" >>$@
	@echo "Section: $(GNUPG_SECTION)" >>$@
	@echo "Version: $(GNUPG_VERSION)-$(GNUPG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUPG_MAINTAINER)" >>$@
	@echo "Source: $(GNUPG_SITE)/$(GNUPG_SOURCE)" >>$@
	@echo "Description: $(GNUPG_DESCRIPTION)" >>$@
	@echo "Depends: $(GNUPG_DEPENDS)" >>$@
	@echo "Suggests: $(GNUPG_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNUPG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNUPG_IPK_DIR)/opt/sbin or $(GNUPG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNUPG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNUPG_IPK_DIR)/opt/etc/gnupg/...
# Documentation files should be installed in $(GNUPG_IPK_DIR)/opt/doc/gnupg/...
# Daemon startup scripts should be installed in $(GNUPG_IPK_DIR)/opt/etc/init.d/S??gnupg
#
# You may need to patch your application to make it use these locations.
#
$(GNUPG_IPK): $(GNUPG_BUILD_DIR)/.built
	rm -rf $(GNUPG_IPK_DIR) $(BUILD_DIR)/gnupg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNUPG_BUILD_DIR) DESTDIR=$(GNUPG_IPK_DIR) install-strip
	$(MAKE) $(GNUPG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUPG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnupg-ipk: $(GNUPG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnupg-clean:
	-$(MAKE) -C $(GNUPG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnupg-dirclean:
	rm -rf $(BUILD_DIR)/$(GNUPG_DIR) $(GNUPG_BUILD_DIR) $(GNUPG_IPK_DIR) $(GNUPG_IPK)

#
# Some sanity check for the package.
#
gnupg-check: $(GNUPG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNUPG_IPK)
