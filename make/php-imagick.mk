###########################################################
#
# php-imagick
#
###########################################################
#
# PHP_IMAGICK_VERSION, PHP_IMAGICK_SITE and PHP_IMAGICK_SOURCE define
# the upstream location of the source code for the package.
# PHP_IMAGICK_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_IMAGICK_UNZIP is the command used to unzip the source.
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
PHP_IMAGICK_URL=http://pecl.php.net/get/imagick-$(PHP_IMAGICK_VERSION).tgz
PHP_IMAGICK_VERSION=3.4.3
PHP_IMAGICK_SOURCE=php-imagick-$(PHP_IMAGICK_VERSION).tar.gz
PHP_IMAGICK_DIR=imagick-$(PHP_IMAGICK_VERSION)
PHP_IMAGICK_UNZIP=zcat
PHP_IMAGICK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_IMAGICK_DESCRIPTION=PHP extension to create and modify images using the ImageMagick API.
PHP_IMAGICK_SECTION=graphics
PHP_IMAGICK_PRIORITY=optional
PHP_IMAGICK_DEPENDS=php, imagemagick
PHP_IMAGICK_SUGGESTS=
PHP_IMAGICK_CONFLICTS=

#
# PHP_IMAGICK_IPK_VERSION should be incremented when the ipk changes.
#
PHP_IMAGICK_IPK_VERSION=2

#
# PHP_IMAGICK_CONFFILES should be a list of user-editable files
#PHP_IMAGICK_CONFFILES=$(TARGET_PREFIX)/etc/php-imagick.conf $(TARGET_PREFIX)/etc/init.d/SXXphp-imagick

#
# PHP_IMAGICK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PHP_IMAGICK_PATCHES=$(PHP_IMAGICK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_IMAGICK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ImageMagick-6
PHP_IMAGICK_LDFLAGS=-lMagickWand-6.Q16

#
# PHP_IMAGICK_BUILD_DIR is the directory in which the build is done.
# PHP_IMAGICK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_IMAGICK_IPK_DIR is the directory in which the ipk is built.
# PHP_IMAGICK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_IMAGICK_BUILD_DIR=$(BUILD_DIR)/php-imagick
PHP_IMAGICK_SOURCE_DIR=$(SOURCE_DIR)/php-imagick
PHP_IMAGICK_IPK_DIR=$(BUILD_DIR)/php-imagick-$(PHP_IMAGICK_VERSION)-ipk
PHP_IMAGICK_IPK=$(BUILD_DIR)/php-imagick_$(PHP_IMAGICK_VERSION)-$(PHP_IMAGICK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: php-imagick-source php-imagick-unpack php-imagick php-imagick-ipk php-imagick-clean php-imagick-dirclean php-imagick-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PHP_IMAGICK_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PHP_IMAGICK_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PHP_IMAGICK_SOURCE).sha512
#
$(DL_DIR)/$(PHP_IMAGICK_SOURCE):
	$(WGET) -O $@ $(PHP_IMAGICK_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-imagick-source: $(DL_DIR)/$(PHP_IMAGICK_SOURCE) $(PHP_IMAGICK_PATCHES)

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
$(PHP_IMAGICK_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_IMAGICK_SOURCE) $(PHP_IMAGICK_PATCHES) make/php-imagick.mk
	$(MAKE) php-stage imagemagick-stage autoconf-host-stage libtool-host-stage
	rm -rf $(BUILD_DIR)/$(PHP_IMAGICK_DIR) $(@D)
	$(PHP_IMAGICK_UNZIP) $(DL_DIR)/$(PHP_IMAGICK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PHP_IMAGICK_PATCHES)" ; \
		then cat $(PHP_IMAGICK_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PHP_IMAGICK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PHP_IMAGICK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PHP_IMAGICK_DIR) $(@D) ; \
	fi
	mkdir -p $(@D)/build
	(cd $(@D); \
		$(HOST_STAGING_PREFIX)/bin/libtoolize -cifv && \
		PHP_AUTOCONF=$(HOST_STAGING_PREFIX)/bin/autoconf PHP_AUTOHEADER=$(HOST_STAGING_PREFIX)/bin/autoheader $(STAGING_DIR)/bin/phpize \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_IMAGICK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_IMAGICK_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-php-config=$(STAGING_DIR)/bin/php-config \
		--with-imagick=$(STAGING_DIR) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

php-imagick-unpack: $(PHP_IMAGICK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHP_IMAGICK_BUILD_DIR)/.built: $(PHP_IMAGICK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
php-imagick: $(PHP_IMAGICK_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/php-imagick
#
$(PHP_IMAGICK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-imagick" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_IMAGICK_PRIORITY)" >>$@
	@echo "Section: $(PHP_IMAGICK_SECTION)" >>$@
	@echo "Version: $(PHP_IMAGICK_VERSION)-$(PHP_IMAGICK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_IMAGICK_MAINTAINER)" >>$@
	@echo "Source: $(PHP_IMAGICK_URL)" >>$@
	@echo "Description: $(PHP_IMAGICK_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_IMAGICK_DEPENDS)" >>$@
	@echo "Suggests: $(PHP_IMAGICK_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHP_IMAGICK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/php-imagick/...
# Documentation files should be installed in $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/doc/php-imagick/...
# Daemon startup scripts should be installed in $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php-imagick
#
# You may need to patch your application to make it use these locations.
#
$(PHP_IMAGICK_IPK): $(PHP_IMAGICK_BUILD_DIR)/.built
	rm -rf $(PHP_IMAGICK_IPK_DIR) $(BUILD_DIR)/php-imagick_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	cp -af $(PHP_IMAGICK_BUILD_DIR)/modules/imagick.so $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	$(STRIP_COMMAND) $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/imagick.so
	echo "extension=imagick.so" > $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/imagick.ini
	chmod 644 $(PHP_IMAGICK_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/imagick.ini
	$(MAKE) $(PHP_IMAGICK_IPK_DIR)/CONTROL/control
	echo $(PHP_IMAGICK_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_IMAGICK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IMAGICK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_IMAGICK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-imagick-ipk: $(PHP_IMAGICK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-imagick-clean:
	rm -f $(PHP_IMAGICK_BUILD_DIR)/.built
	-$(MAKE) -C $(PHP_IMAGICK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-imagick-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_IMAGICK_DIR) $(PHP_IMAGICK_BUILD_DIR) $(PHP_IMAGICK_IPK_DIR) $(PHP_IMAGICK_IPK)
#
#
# Some sanity check for the package.
#
php-imagick-check: $(PHP_IMAGICK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
