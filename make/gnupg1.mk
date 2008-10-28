###########################################################
#
# gnupg1
#
###########################################################

#
# GNUPG1_VERSION, GNUPG1_SITE and GNUPG1_SOURCE define
# the upstream location of the source code for the package.
# GNUPG1_DIR is the directory which is created when the source
# archive is unpacked.
# GNUPG1_UNZIP is the command used to unzip the source.
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
GNUPG1_SITE=ftp://ftp.gnupg.org/gcrypt/gnupg
GNUPG1_VERSION=1.4.9
GNUPG1_SOURCE=gnupg-$(GNUPG1_VERSION).tar.bz2
GNUPG1_DIR=gnupg-$(GNUPG1_VERSION)
GNUPG1_UNZIP=bzcat
GNUPG1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNUPG1_DESCRIPTION=GNU privacy guard - a free PGP replacement.
GNUPG1_SECTION=misc
GNUPG1_PRIORITY=optional
GNUPG1_DEPENDS=libusb, zlib, bzip2, readline, libcurl, openldap-libs
GNUPG1_SUGGESTS=
GNUPG1_CONFLICTS=

#
# GNUPG1_IPK_VERSION should be incremented when the ipk changes.
#
GNUPG1_IPK_VERSION=1

#
# GNUPG1_CONFFILES should be a list of user-editable files
#GNUPG1_CONFFILES=/opt/etc/gnupg1.conf /opt/etc/init.d/SXXgnupg1

#
# GNUPG1_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GNUPG1_PATCHES=$(GNUPG1_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNUPG1_CPPFLAGS=
GNUPG1_LDFLAGS=

#
# GNUPG1_BUILD_DIR is the directory in which the build is done.
# GNUPG1_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNUPG1_IPK_DIR is the directory in which the ipk is built.
# GNUPG1_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNUPG1_BUILD_DIR=$(BUILD_DIR)/gnupg1
GNUPG1_SOURCE_DIR=$(SOURCE_DIR)/gnupg1
GNUPG1_IPK_DIR=$(BUILD_DIR)/gnupg1-$(GNUPG1_VERSION)-ipk
GNUPG1_IPK=$(BUILD_DIR)/gnupg1_$(GNUPG1_VERSION)-$(GNUPG1_IPK_VERSION)_$(TARGET_ARCH).ipk

# uclibc 0.9.28 is missing dn_skipname() impleemtation
ifeq ($(LIBC_STYLE), uclibc)
GNUPG1_CFG_OPTS= --disable-dns-pka --disable-dns-cert --disable-dns-srv
endif
ifeq ($(TARGET_ARCH), $(filter powerpc i386 i686, $(TARGET_ARCH)))
GNUPG1_CFG_ENV=ac_cv_sys_symbol_underscore=no
endif

.PHONY: gnupg1-source gnupg1-unpack gnupg gnupg1-stage gnupg1-ipk gnupg1-clean gnupg1-dirclean gnupg1-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNUPG1_SOURCE):
	$(WGET) -P $(@D) $(GNUPG1_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnupg1-source: $(DL_DIR)/$(GNUPG1_SOURCE) $(GNUPG1_PATCHES)

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
$(GNUPG1_BUILD_DIR)/.configured: $(DL_DIR)/$(GNUPG1_SOURCE) $(GNUPG1_PATCHES) make/gnupg1.mk
	$(MAKE) libusb-stage bzip2-stage zlib-stage readline-stage libcurl-stage openldap-stage
	rm -rf $(BUILD_DIR)/$(GNUPG1_DIR) $(GNUPG1_BUILD_DIR)
	$(GNUPG1_UNZIP) $(DL_DIR)/$(GNUPG1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GNUPG1_PATCHES) | patch -d $(BUILD_DIR)/$(GNUPG1_DIR) -p1
	mv $(BUILD_DIR)/$(GNUPG1_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNUPG1_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNUPG1_LDFLAGS)" \
		$(GNUPG1_CFG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-libusb=$(STAGING_DIR)/opt \
		--with-zlib=$(STAGING_DIR)/opt \
		--with-readline=$(STAGING_DIR)/opt \
		--with-libcurl=$(STAGING_DIR)/opt \
		--with-ldap=$(STAGING_DIR)/opt \
		--prefix=/opt \
		--disable-nls \
		$(GNUPG1_CFG_OPTS) \
	)
	touch $@

gnupg1-unpack: $(GNUPG1_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNUPG1_BUILD_DIR)/.built: $(GNUPG1_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gnupg1: $(GNUPG1_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNUPG1_BUILD_DIR)/.staged: $(GNUPG1_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gnupg1-stage: $(GNUPG1_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnupg1
#
$(GNUPG1_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnupg1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUPG1_PRIORITY)" >>$@
	@echo "Section: $(GNUPG1_SECTION)" >>$@
	@echo "Version: $(GNUPG1_VERSION)-$(GNUPG1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUPG1_MAINTAINER)" >>$@
	@echo "Source: $(GNUPG1_SITE)/$(GNUPG1_SOURCE)" >>$@
	@echo "Description: $(GNUPG1_DESCRIPTION)" >>$@
	@echo "Depends: $(GNUPG1_DEPENDS)" >>$@
	@echo "Suggests: $(GNUPG1_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNUPG1_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNUPG1_IPK_DIR)/opt/sbin or $(GNUPG1_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNUPG1_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNUPG1_IPK_DIR)/opt/etc/gnupg1/...
# Documentation files should be installed in $(GNUPG1_IPK_DIR)/opt/doc/gnupg1/...
# Daemon startup scripts should be installed in $(GNUPG1_IPK_DIR)/opt/etc/init.d/S??gnupg1
#
# You may need to patch your application to make it use these locations.
#
$(GNUPG1_IPK): $(GNUPG1_BUILD_DIR)/.built
	rm -rf $(GNUPG1_IPK_DIR) $(BUILD_DIR)/gnupg1_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<D) DESTDIR=$(GNUPG1_IPK_DIR) install-strip
	mv $(GNUPG1_IPK_DIR)/opt/share/gnupg $(GNUPG1_IPK_DIR)/opt/share/gnupg1
	$(MAKE) $(GNUPG1_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUPG1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnupg1-ipk: $(GNUPG1_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnupg1-clean:
	-$(MAKE) -C $(GNUPG1_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnupg1-dirclean:
	rm -rf $(BUILD_DIR)/$(GNUPG1_DIR) $(GNUPG1_BUILD_DIR) $(GNUPG1_IPK_DIR) $(GNUPG1_IPK)

#
# Some sanity check for the package.
#
gnupg1-check: $(GNUPG1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNUPG1_IPK)
