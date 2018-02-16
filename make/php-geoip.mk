###########################################################
#
# php-geoip
#
###########################################################
#
# PHP_GEOIP_VERSION, PHP_GEOIP_SITE and PHP_GEOIP_SOURCE define
# the upstream location of the source code for the package.
# PHP_GEOIP_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_GEOIP_UNZIP is the command used to unzip the source.
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
PHP_GEOIP_SITE=https://pecl.php.net/get
PHP_GEOIP_VERSION=1.1.1
PHP_GEOIP_SOURCE=geoip-$(PHP_GEOIP_VERSION).tgz
PHP_GEOIP_DIR=geoip-$(PHP_GEOIP_VERSION)
PHP_GEOIP_UNZIP=zcat
PHP_GEOIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_GEOIP_DESCRIPTION=PHP geoip extension based on libGeoIP library.
PHP_GEOIP_SECTION=net
PHP_GEOIP_PRIORITY=optional
PHP_GEOIP_DEPENDS=php, geoip
PHP_GEOIP_SUGGESTS=
PHP_GEOIP_CONFLICTS=

#
# PHP_GEOIP_IPK_VERSION should be incremented when the ipk changes.
#
PHP_GEOIP_IPK_VERSION=1

#
# PHP_GEOIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PHP_GEOIP_PATCHES=$(PHP_GEOIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_GEOIP_CPPFLAGS=
PHP_GEOIP_LDFLAGS=-lGeoIP

#
# PHP_GEOIP_BUILD_DIR is the directory in which the build is done.
# PHP_GEOIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_GEOIP_IPK_DIR is the directory in which the ipk is built.
# PHP_GEOIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_GEOIP_BUILD_DIR=$(BUILD_DIR)/php-geoip
PHP_GEOIP_SOURCE_DIR=$(SOURCE_DIR)/php-geoip
PHP_GEOIP_IPK_DIR=$(BUILD_DIR)/php-geoip-$(PHP_GEOIP_VERSION)-ipk
PHP_GEOIP_IPK=$(BUILD_DIR)/php-geoip_$(PHP_GEOIP_VERSION)-$(PHP_GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: php-geoip-source php-geoip-unpack php-geoip php-geoip-stage php-geoip-ipk php-geoip-clean php-geoip-dirclean php-geoip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PHP_GEOIP_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PHP_GEOIP_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PHP_GEOIP_SOURCE).sha512
#
$(DL_DIR)/$(PHP_GEOIP_SOURCE):
	$(WGET) -P $(@D) $(PHP_GEOIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-geoip-source: $(DL_DIR)/$(PHP_GEOIP_SOURCE) $(PHP_GEOIP_PATCHES)

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
$(PHP_GEOIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_GEOIP_SOURCE) $(PHP_GEOIP_PATCHES) make/php-geoip.mk
	$(MAKE) geoip-stage php-stage autoconf-host-stage libtool-host-stage
	rm -rf $(BUILD_DIR)/$(PHP_GEOIP_DIR) $(@D)
	$(PHP_GEOIP_UNZIP) $(DL_DIR)/$(PHP_GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PHP_GEOIP_PATCHES)" ; \
		then cat $(PHP_GEOIP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PHP_GEOIP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PHP_GEOIP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PHP_GEOIP_DIR) $(@D) ; \
	fi
	mkdir -p $(@D)/build
	(cd $(@D); \
		$(HOST_STAGING_PREFIX)/bin/libtoolize -cifv && \
		PHP_AUTOCONF=$(HOST_STAGING_PREFIX)/bin/autoconf PHP_AUTOHEADER=$(HOST_STAGING_PREFIX)/bin/autoheader $(STAGING_DIR)/bin/phpize \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_GEOIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_GEOIP_LDFLAGS)" \
		GEOIP_DIR="$(STAGING_PREFIX)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-php-config=$(STAGING_DIR)/bin/php-config \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

php-geoip-unpack: $(PHP_GEOIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHP_GEOIP_BUILD_DIR)/.built: $(PHP_GEOIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
php-geoip: $(PHP_GEOIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHP_GEOIP_BUILD_DIR)/.staged: $(PHP_GEOIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) INSTALL_ROOT=$(STAGING_DIR) install
	touch $@

php-geoip-stage: $(PHP_GEOIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/php-geoip
#
$(PHP_GEOIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_GEOIP_PRIORITY)" >>$@
	@echo "Section: $(PHP_GEOIP_SECTION)" >>$@
	@echo "Version: $(PHP_GEOIP_VERSION)-$(PHP_GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_GEOIP_SITE)" >>$@
	@echo "Description: $(PHP_GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_GEOIP_DEPENDS)" >>$@
	@echo "Suggests: $(PHP_GEOIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHP_GEOIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/php-geoip/...
# Documentation files should be installed in $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/doc/php-geoip/...
# Daemon startup scripts should be installed in $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php-geoip
#
# You may need to patch your application to make it use these locations.
#
$(PHP_GEOIP_IPK): $(PHP_GEOIP_BUILD_DIR)/.built
	rm -rf $(PHP_GEOIP_IPK_DIR) $(BUILD_DIR)/php-geoip_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_GEOIP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	cp -af $(PHP_GEOIP_BUILD_DIR)/modules/geoip.so $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/geoip.so
	$(STRIP_COMMAND) $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/geoip.so
	echo extension=geoip.so > $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/geoip.ini
	chmod 644 $(PHP_GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/geoip.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_GEOIP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_GEOIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-geoip-ipk: $(PHP_GEOIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-geoip-clean:
	rm -f $(PHP_GEOIP_BUILD_DIR)/.built
	-$(MAKE) -C $(PHP_GEOIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-geoip-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_GEOIP_DIR) $(PHP_GEOIP_BUILD_DIR) $(PHP_GEOIP_IPK_DIR) $(PHP_GEOIP_IPK)

#
# Some sanity check for the package.
#
php-geoip-check: $(PHP_GEOIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
