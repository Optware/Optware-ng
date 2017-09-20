###########################################################
#
# php-memcached
#
###########################################################
#
# PHP_MEMCACHED_VERSION, PHP_MEMCACHED_SITE and PHP_MEMCACHED_SOURCE define
# the upstream location of the source code for the package.
# PHP_MEMCACHED_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_MEMCACHED_UNZIP is the command used to unzip the source.
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
PHP_MEMCACHED_REPOSITORY=https://github.com/php-memcached-dev/php-memcached.git
PHP_MEMCACHED_VERSION=2.2.0+git20160613
PHP_MEMCACHED_TREEISH=`git rev-list --max-count=1 --until=2016-06-13 HEAD`
PHP_MEMCACHED_SOURCE=php-memcached-$(PHP_MEMCACHED_VERSION).tar.gz
PHP_MEMCACHED_DIR=php-memcached-$(PHP_MEMCACHED_VERSION)
PHP_MEMCACHED_UNZIP=zcat
PHP_MEMCACHED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_MEMCACHED_DESCRIPTION=PHP memcached extension based on libmemcached library.
PHP_MEMCACHED_SECTION=net
PHP_MEMCACHED_PRIORITY=optional
PHP_MEMCACHED_DEPENDS=php, libmemcached
PHP_MEMCACHED_SUGGESTS=
PHP_MEMCACHED_CONFLICTS=

#
# PHP_MEMCACHED_IPK_VERSION should be incremented when the ipk changes.
#
PHP_MEMCACHED_IPK_VERSION=3

#
# PHP_MEMCACHED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PHP_MEMCACHED_PATCHES=$(PHP_MEMCACHED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_MEMCACHED_CPPFLAGS=
PHP_MEMCACHED_LDFLAGS=

#
# PHP_MEMCACHED_BUILD_DIR is the directory in which the build is done.
# PHP_MEMCACHED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_MEMCACHED_IPK_DIR is the directory in which the ipk is built.
# PHP_MEMCACHED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_MEMCACHED_BUILD_DIR=$(BUILD_DIR)/php-memcached
PHP_MEMCACHED_SOURCE_DIR=$(SOURCE_DIR)/php-memcached
PHP_MEMCACHED_IPK_DIR=$(BUILD_DIR)/php-memcached-$(PHP_MEMCACHED_VERSION)-ipk
PHP_MEMCACHED_IPK=$(BUILD_DIR)/php-memcached_$(PHP_MEMCACHED_VERSION)-$(PHP_MEMCACHED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: php-memcached-source php-memcached-unpack php-memcached php-memcached-stage php-memcached-ipk php-memcached-clean php-memcached-dirclean php-memcached-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PHP_MEMCACHED_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PHP_MEMCACHED_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PHP_MEMCACHED_SOURCE).sha512
#
$(DL_DIR)/$(PHP_MEMCACHED_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf php-memcached && \
		git clone --bare $(PHP_MEMCACHED_REPOSITORY) php-memcached && \
		(cd php-memcached && \
		git archive --format=tar --prefix=$(PHP_MEMCACHED_DIR)/ $(PHP_MEMCACHED_TREEISH) | gzip > $@) && \
		rm -rf php-memcached ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-memcached-source: $(DL_DIR)/$(PHP_MEMCACHED_SOURCE) $(PHP_MEMCACHED_PATCHES)

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
$(PHP_MEMCACHED_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_MEMCACHED_SOURCE) $(PHP_MEMCACHED_PATCHES) make/php-memcached.mk
	$(MAKE) libmemcached-stage php-stage autoconf-host-stage libtool-host-stage
	rm -rf $(BUILD_DIR)/$(PHP_MEMCACHED_DIR) $(@D)
	$(PHP_MEMCACHED_UNZIP) $(DL_DIR)/$(PHP_MEMCACHED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PHP_MEMCACHED_PATCHES)" ; \
		then cat $(PHP_MEMCACHED_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PHP_MEMCACHED_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PHP_MEMCACHED_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PHP_MEMCACHED_DIR) $(@D) ; \
	fi
	mkdir -p $(@D)/build
	(cd $(@D); \
		$(HOST_STAGING_PREFIX)/bin/libtoolize -cifv && \
		PHP_AUTOCONF=$(HOST_STAGING_PREFIX)/bin/autoconf PHP_AUTOHEADER=$(HOST_STAGING_PREFIX)/bin/autoheader $(STAGING_DIR)/bin/phpize \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_MEMCACHED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_MEMCACHED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--with-libmemcached-dir=$(STAGING_PREFIX) \
		--with-php-config=$(STAGING_DIR)/bin/php-config \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

php-memcached-unpack: $(PHP_MEMCACHED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHP_MEMCACHED_BUILD_DIR)/.built: $(PHP_MEMCACHED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
php-memcached: $(PHP_MEMCACHED_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/php-memcached
#
$(PHP_MEMCACHED_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-memcached" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_MEMCACHED_PRIORITY)" >>$@
	@echo "Section: $(PHP_MEMCACHED_SECTION)" >>$@
	@echo "Version: $(PHP_MEMCACHED_VERSION)-$(PHP_MEMCACHED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MEMCACHED_MAINTAINER)" >>$@
	@echo "Source: $(PHP_MEMCACHED_REPOSITORY)" >>$@
	@echo "Description: $(PHP_MEMCACHED_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_MEMCACHED_DEPENDS)" >>$@
	@echo "Suggests: $(PHP_MEMCACHED_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHP_MEMCACHED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/php-memcached/...
# Documentation files should be installed in $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/doc/php-memcached/...
# Daemon startup scripts should be installed in $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php-memcached
#
# You may need to patch your application to make it use these locations.
#
$(PHP_MEMCACHED_IPK): $(PHP_MEMCACHED_BUILD_DIR)/.built
	rm -rf $(PHP_MEMCACHED_IPK_DIR) $(BUILD_DIR)/php-memcached_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MEMCACHED_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	cp -af $(PHP_MEMCACHED_BUILD_DIR)/modules/memcached.so $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/memcached.so
	$(STRIP_COMMAND) $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/memcached.so
	echo extension=memcached.so > $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/memcached.ini
	chmod 644 $(PHP_MEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/memcached.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MEMCACHED_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_MEMCACHED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-memcached-ipk: $(PHP_MEMCACHED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-memcached-clean:
	rm -f $(PHP_MEMCACHED_BUILD_DIR)/.built
	-$(MAKE) -C $(PHP_MEMCACHED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-memcached-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_MEMCACHED_DIR) $(PHP_MEMCACHED_BUILD_DIR) $(PHP_MEMCACHED_IPK_DIR) $(PHP_MEMCACHED_IPK)
#
#
# Some sanity check for the package.
#
php-memcached-check: $(PHP_MEMCACHED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
