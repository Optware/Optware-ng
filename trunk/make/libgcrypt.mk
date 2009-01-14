###########################################################
#
# libgcrypt
#
###########################################################

# You must replace "libgcrypt" and "LIBGCRYPT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBGCRYPT_VERSION, LIBGCRYPT_SITE and LIBGCRYPT_SOURCE define
# the upstream location of the source code for the package.
# LIBGCRYPT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGCRYPT_UNZIP is the command used to unzip the source.
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
LIBGCRYPT_SITE=ftp://ftp.gnupg.org/gcrypt/libgcrypt
LIBGCRYPT_VERSION=1.4.3
LIBGCRYPT_SOURCE=libgcrypt-$(LIBGCRYPT_VERSION).tar.bz2
LIBGCRYPT_DIR=libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_UNZIP=bzcat
LIBGCRYPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGCRYPT_DESCRIPTION=GNU cryptography libray, needed by gnutls
LIBGCRYPT_SECTION=libs
LIBGCRYPT_PRIORITY=optional
LIBGCRYPT_DEPENDS=libgpg-error
LIBGCRYPT_SUGGESTS=
LIBGCRYPT_CONFLICTS=

#
# LIBGCRYPT_IPK_VERSION should be incremented when the ipk changes.
#
LIBGCRYPT_IPK_VERSION=1

#
# LIBGCRYPT_CONFFILES should be a list of user-editable files
LIBGCRYPT_CONFFILES=#/opt/etc/libgcrypt.conf /opt/etc/init.d/SXXlibgcrypt

#
# LIBGCRYPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq ($(TARGET_ARCH), $(filter powerpc i386 i686, $(TARGET_ARCH)))
LIBGCRYPT_PATCHES= $(LIBGCRYPT_SOURCE_DIR)/symbol-underscore.patch
endif
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGCRYPT_CPPFLAGS=
LIBGCRYPT_LDFLAGS=

#
# LIBGCRYPT_BUILD_DIR is the directory in which the build is done.
# LIBGCRYPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGCRYPT_IPK_DIR is the directory in which the ipk is built.
# LIBGCRYPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGCRYPT_BUILD_DIR=$(BUILD_DIR)/libgcrypt
LIBGCRYPT_SOURCE_DIR=$(SOURCE_DIR)/libgcrypt
LIBGCRYPT_IPK_DIR=$(BUILD_DIR)/libgcrypt-$(LIBGCRYPT_VERSION)-ipk
LIBGCRYPT_IPK=$(BUILD_DIR)/libgcrypt_$(LIBGCRYPT_VERSION)-$(LIBGCRYPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgcrypt-source libgcrypt-unpack libgcrypt libgcrypt-stage libgcrypt-ipk libgcrypt-clean libgcrypt-dirclean libgcrypt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGCRYPT_SOURCE):
	$(WGET) -P $(@D) $(LIBGCRYPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgcrypt-source: $(DL_DIR)/$(LIBGCRYPT_SOURCE) $(LIBGCRYPT_PATCHES)

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
$(LIBGCRYPT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGCRYPT_SOURCE) $(LIBGCRYPT_PATCHES)
	$(MAKE) libgpg-error-stage
	rm -rf $(BUILD_DIR)/$(LIBGCRYPT_DIR) $(@D)
	$(LIBGCRYPT_UNZIP) $(DL_DIR)/$(LIBGCRYPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBGCRYPT_PATCHES)" ; then \
		cat $(LIBGCRYPT_PATCHES) | \
        	 patch -d $(BUILD_DIR)/$(LIBGCRYPT_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(LIBGCRYPT_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGCRYPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGCRYPT_LDFLAGS)" \
		ac_cv_sys_symbol_underscore=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-gpg-error-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libgcrypt-unpack: $(LIBGCRYPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGCRYPT_BUILD_DIR)/.built: $(LIBGCRYPT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libgcrypt: $(LIBGCRYPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGCRYPT_BUILD_DIR)/.staged: $(LIBGCRYPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) transform='' install
	sed -i -e '/_cflags=/s|-I/opt/include||g' \
	       -e '/_cflags=/s|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|' \
	       -e 's|I$$includedir|I$(STAGING_INCLUDE_DIR)|' \
		$(STAGING_PREFIX)/bin/*libgcrypt-config
	rm -f $(STAGING_LIB_DIR)/libgcrypt.la
	touch $@

libgcrypt-stage: $(LIBGCRYPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libgcrypt
#
$(LIBGCRYPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libgcrypt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGCRYPT_PRIORITY)" >>$@
	@echo "Section: $(LIBGCRYPT_SECTION)" >>$@
	@echo "Version: $(LIBGCRYPT_VERSION)-$(LIBGCRYPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGCRYPT_MAINTAINER)" >>$@
	@echo "Source: $(LIBGCRYPT_SITE)/$(LIBGCRYPT_SOURCE)" >>$@
	@echo "Description: $(LIBGCRYPT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGCRYPT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGCRYPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGCRYPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGCRYPT_IPK_DIR)/opt/sbin or $(LIBGCRYPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGCRYPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGCRYPT_IPK_DIR)/opt/etc/libgcrypt/...
# Documentation files should be installed in $(LIBGCRYPT_IPK_DIR)/opt/doc/libgcrypt/...
# Daemon startup scripts should be installed in $(LIBGCRYPT_IPK_DIR)/opt/etc/init.d/S??libgcrypt
#
# You may need to patch your application to make it use these locations.
#
$(LIBGCRYPT_IPK): $(LIBGCRYPT_BUILD_DIR)/.built
	rm -rf $(LIBGCRYPT_IPK_DIR) $(BUILD_DIR)/libgcrypt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGCRYPT_BUILD_DIR) DESTDIR=$(LIBGCRYPT_IPK_DIR) transform='' install-strip
	#install -d $(LIBGCRYPT_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBGCRYPT_SOURCE_DIR)/libgcrypt.conf $(LIBGCRYPT_IPK_DIR)/opt/etc/libgcrypt.conf
	#install -d $(LIBGCRYPT_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBGCRYPT_SOURCE_DIR)/rc.libgcrypt $(LIBGCRYPT_IPK_DIR)/opt/etc/init.d/SXXlibgcrypt
	$(MAKE) $(LIBGCRYPT_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBGCRYPT_SOURCE_DIR)/postinst $(LIBGCRYPT_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBGCRYPT_SOURCE_DIR)/prerm $(LIBGCRYPT_IPK_DIR)/CONTROL/prerm
	echo $(LIBGCRYPT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBGCRYPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGCRYPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgcrypt-ipk: $(LIBGCRYPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgcrypt-clean:
	-$(MAKE) -C $(LIBGCRYPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgcrypt-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGCRYPT_DIR) $(LIBGCRYPT_BUILD_DIR) $(LIBGCRYPT_IPK_DIR) $(LIBGCRYPT_IPK)

#
# Some sanity check for the package.
#
libgcrypt-check: $(LIBGCRYPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
