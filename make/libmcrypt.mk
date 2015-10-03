###########################################################
#
# libmcrypt
#
###########################################################
#
# LIBMCRYPT_VERSION, LIBMCRYPT_SITE and LIBMCRYPT_SOURCE define
# the upstream location of the source code for the package.
# LIBMCRYPT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMCRYPT_UNZIP is the command used to unzip the source.
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
LIBMCRYPT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mcrypt
LIBMCRYPT_VERSION=2.5.8
LIBMCRYPT_SOURCE=libmcrypt-$(LIBMCRYPT_VERSION).tar.bz2
LIBMCRYPT_DIR=libmcrypt-$(LIBMCRYPT_VERSION)
LIBMCRYPT_UNZIP=bzcat
LIBMCRYPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMCRYPT_DESCRIPTION=libmcrypt is the library which implements all the algorithms and modes found in mcrypt. 
LIBMCRYPT_SECTION=lib
LIBMCRYPT_PRIORITY=optional
LIBMCRYPT_DEPENDS=
LIBMCRYPT_SUGGESTS=
LIBMCRYPT_CONFLICTS=

#
# LIBMCRYPT_IPK_VERSION should be incremented when the ipk changes.
#
LIBMCRYPT_IPK_VERSION=1

#
# LIBMCRYPT_CONFFILES should be a list of user-editable files
#LIBMCRYPT_CONFFILES=$(TARGET_PREFIX)/etc/libmcrypt.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmcrypt

#
# LIBMCRYPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMCRYPT_PATCHES=$(LIBMCRYPT_SOURCE_DIR)/fixes.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMCRYPT_CPPFLAGS=
LIBMCRYPT_LDFLAGS=

#
# LIBMCRYPT_BUILD_DIR is the directory in which the build is done.
# LIBMCRYPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMCRYPT_IPK_DIR is the directory in which the ipk is built.
# LIBMCRYPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMCRYPT_BUILD_DIR=$(BUILD_DIR)/libmcrypt
LIBMCRYPT_SOURCE_DIR=$(SOURCE_DIR)/libmcrypt
LIBMCRYPT_IPK_DIR=$(BUILD_DIR)/libmcrypt-$(LIBMCRYPT_VERSION)-ipk
LIBMCRYPT_IPK=$(BUILD_DIR)/libmcrypt_$(LIBMCRYPT_VERSION)-$(LIBMCRYPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmcrypt-source libmcrypt-unpack libmcrypt libmcrypt-stage libmcrypt-ipk libmcrypt-clean libmcrypt-dirclean libmcrypt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMCRYPT_SOURCE):
	$(WGET) -P $(@D) $(LIBMCRYPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmcrypt-source: $(DL_DIR)/$(LIBMCRYPT_SOURCE) $(LIBMCRYPT_PATCHES)

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
$(LIBMCRYPT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMCRYPT_SOURCE) $(LIBMCRYPT_PATCHES) make/libmcrypt.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMCRYPT_DIR) $(@D)
	$(LIBMCRYPT_UNZIP) $(DL_DIR)/$(LIBMCRYPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMCRYPT_PATCHES)" ; \
		then cat $(LIBMCRYPT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMCRYPT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMCRYPT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMCRYPT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMCRYPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMCRYPT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--program-transform-name='s,^,,' \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	(echo 		'#undef malloc'; \
		echo 	'#undef realloc'; \
		echo 	'#define HAVE_MALLOC 1') >> $(@D)/config.h
	touch $@

libmcrypt-unpack: $(LIBMCRYPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMCRYPT_BUILD_DIR)/.built: $(LIBMCRYPT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmcrypt: $(LIBMCRYPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMCRYPT_BUILD_DIR)/.staged: $(LIBMCRYPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmcrypt.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/libmcrypt-config
	touch $@

libmcrypt-stage: $(LIBMCRYPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmcrypt
#
$(LIBMCRYPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmcrypt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMCRYPT_PRIORITY)" >>$@
	@echo "Section: $(LIBMCRYPT_SECTION)" >>$@
	@echo "Version: $(LIBMCRYPT_VERSION)-$(LIBMCRYPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMCRYPT_MAINTAINER)" >>$@
	@echo "Source: $(LIBMCRYPT_SITE)/$(LIBMCRYPT_SOURCE)" >>$@
	@echo "Description: $(LIBMCRYPT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMCRYPT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMCRYPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMCRYPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/libmcrypt/...
# Documentation files should be installed in $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/doc/libmcrypt/...
# Daemon startup scripts should be installed in $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmcrypt
#
# You may need to patch your application to make it use these locations.
#
$(LIBMCRYPT_IPK): $(LIBMCRYPT_BUILD_DIR)/.built
	rm -rf $(LIBMCRYPT_IPK_DIR) $(BUILD_DIR)/libmcrypt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMCRYPT_BUILD_DIR) DESTDIR=$(LIBMCRYPT_IPK_DIR) install-strip
	rm -f $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/lib/libmcrypt.la
#	$(INSTALL) -d $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBMCRYPT_SOURCE_DIR)/libmcrypt.conf $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/libmcrypt.conf
#	$(INSTALL) -d $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBMCRYPT_SOURCE_DIR)/rc.libmcrypt $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmcrypt
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmcrypt
	$(MAKE) $(LIBMCRYPT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMCRYPT_SOURCE_DIR)/postinst $(LIBMCRYPT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMCRYPT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMCRYPT_SOURCE_DIR)/prerm $(LIBMCRYPT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMCRYPT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMCRYPT_IPK_DIR)/CONTROL/postinst $(LIBMCRYPT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBMCRYPT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMCRYPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMCRYPT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBMCRYPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmcrypt-ipk: $(LIBMCRYPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmcrypt-clean:
	rm -f $(LIBMCRYPT_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMCRYPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmcrypt-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMCRYPT_DIR) $(LIBMCRYPT_BUILD_DIR) $(LIBMCRYPT_IPK_DIR) $(LIBMCRYPT_IPK)
#
#
# Some sanity check for the package.
#
libmcrypt-check: $(LIBMCRYPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
