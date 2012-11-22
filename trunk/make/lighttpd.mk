###########################################################
#
# lighttpd
#
###########################################################

# You must replace "lighttpd" and "LIGHTTPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIGHTTPD_VERSION, LIGHTTPD_SITE and LIGHTTPD_SOURCE define
# the upstream location of the source code for the package.
# LIGHTTPD_DIR is the directory which is created when the source
# archive is unpacked.
# LIGHTTPD_UNZIP is the command used to unzip the source.
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
LIGHTTPD_SITE=http://download.lighttpd.net/lighttpd/releases-1.4.x
LIGHTTPD_VERSION=1.4.32
LIGHTTPD_SOURCE=lighttpd-$(LIGHTTPD_VERSION).tar.bz2
LIGHTTPD_DIR=lighttpd-$(LIGHTTPD_VERSION)
LIGHTTPD_UNZIP=bzcat
LIGHTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIGHTTPD_DESCRIPTION=A fast webserver with minimal memory footprint.
LIGHTTPD_SECTION=net
LIGHTTPD_PRIORITY=optional
LIGHTTPD_DEPENDS=pcre, zlib, libstdc++, openssl, spawn-fcgi

LIGHTTPD_SUGGESTS=bzip2, e2fsprogs, libxml2, lua, sqlite
ifeq (openldap, $(filter openldap, $(PACKAGES)))
LIGHTTPD_SUGGESTS+=, openldap-libs
endif

ifeq (libmemcache, $(filter libmemcache, $(PACKAGES)))
LIGHTTPD_WITH_MEMCACHE=yes
endif

ifeq (mysql, $(filter mysql, $(PACKAGES)))
ifneq (dns323, $(OPTWARE_TARGET))
LIGHTTPD_WITH_MYSQL=yes
endif
endif

ifdef LIGHTTPD_WITH_MYSQL
LIGHTTPD_SUGGESTS+=, mysql
endif

ifdef LIGHTTPD_WITH_MEMCACHE
LIGHTTD_SUGGESTS+=, libmemcache, memcached
endif

LIGHTTPD_CONFLICTS=

#
# LIGHTTPD_IPK_VERSION should be incremented when the ipk changes.
#
LIGHTTPD_IPK_VERSION=1

#
# LIGHTTPD_CONFFILES should be a list of user-editable files
LIGHTTPD_CONFFILES=\
	/opt/etc/lighttpd/lighttpd.conf \
	/opt/etc/lighttpd/conf.d/01-default.conf \
	/opt/etc/init.d/S80lighttpd

#
# LIGHTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIGHTTPD_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIGHTTPD_CPPFLAGS=
LIGHTTPD_LDFLAGS=

ifdef LIGHTTPD_WITH_MYSQL
LIGHTTPD_CONFIG_ARGS=--with-mysql=$(STAGING_PREFIX)/bin/mysql_config
else
LIGHTTPD_CONFIG_ARGS=--without-mysql
endif

ifdef LIGHTTPD_WITH_MEMCACHE
LIGHTTPD_CONFIG_ARGS+=--with-memcache
else
LIGHTTPD_CONFIG_ARGS+=--without-memcache
endif

ifeq ($(OPTWARE_TARGET), $(filter openwrt-ixp4xx dns323 nslu2 syno-x07 wdtv, $(OPTWARE_TARGET)))
LIGHTTPD_CONFIG_ARGS+= --disable-ipv6
endif
ifeq (no, $(IPV6))
LIGHTTPD_CONFIG_ARGS+= --disable-ipv6
endif

#
# LIGHTTPD_BUILD_DIR is the directory in which the build is done.
# LIGHTTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIGHTTPD_IPK_DIR is the directory in which the ipk is built.
# LIGHTTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIGHTTPD_BUILD_DIR=$(BUILD_DIR)/lighttpd
LIGHTTPD_SOURCE_DIR=$(SOURCE_DIR)/lighttpd
LIGHTTPD_IPK_DIR=$(BUILD_DIR)/lighttpd-$(LIGHTTPD_VERSION)-ipk
LIGHTTPD_IPK=$(BUILD_DIR)/lighttpd_$(LIGHTTPD_VERSION)-$(LIGHTTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lighttpd-source lighttpd-unpack lighttpd lighttpd-stage lighttpd-ipk lighttpd-clean lighttpd-dirclean lighttpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIGHTTPD_SOURCE):
	$(WGET) -P $(@D) $(LIGHTTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lighttpd-source: $(DL_DIR)/$(LIGHTTPD_SOURCE) $(LIGHTTPD_PATCHES)

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
$(LIGHTTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIGHTTPD_SOURCE) $(LIGHTTPD_PATCHES) make/lighttpd.mk
	$(MAKE) bzip2-stage libxml2-stage lua-stage
	$(MAKE) openssl-stage pcre-stage sqlite-stage zlib-stage
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage
endif
ifdef LIGHTTPD_WITH_MYSQL
	$(MAKE) mysql-stage
endif
ifdef LIGHTTPD_WITH_MEMCACHE
	$(MAKE) libmemcache-stage memcached-stage
endif
	rm -rf $(BUILD_DIR)/$(LIGHTTPD_DIR) $(@D)
	$(LIGHTTPD_UNZIP) $(DL_DIR)/$(LIGHTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIGHTTPD_PATCHES)" ; \
		then cat $(LIGHTTPD_PATCHES) | \
		patch --ignore-whitespace -bd $(BUILD_DIR)/$(LIGHTTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIGHTTPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIGHTTPD_DIR) $(@D) ; \
	fi
	sed -i '/#define _CONFIG_PARSER_H_/a#include <linux/limits.h>' $(@D)/src/configfile.h
	sed -i '/cross_compiling.*WITH_PCRE/s/"x$$cross_compiling" = xno -a //' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIGHTTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIGHTTPD_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		SQLITE_CFLAGS="-I$(STAGING_INCLUDE_DIR)" \
		ac_cv_lib_memcache_mc_new=yes \
		ac_cv_path_PCRECONFIG=$(STAGING_PREFIX)/bin/pcre-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir=/opt/lib/lighttpd \
		--with-bzip2 \
		--with-ldap \
		--with-lua \
		$(LIGHTTPD_CONFIG_ARGS) \
		--with-pcre \
		--with-openssl \
		--with-webdav-locks \
		--with-webdav-props \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

lighttpd-unpack: $(LIGHTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIGHTTPD_BUILD_DIR)/.built: $(LIGHTTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
lighttpd: $(LIGHTTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIGHTTPD_BUILD_DIR)/.staged: $(LIGHTTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

lighttpd-stage: $(LIGHTTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lighttpd
#
$(LIGHTTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lighttpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIGHTTPD_PRIORITY)" >>$@
	@echo "Section: $(LIGHTTPD_SECTION)" >>$@
	@echo "Version: $(LIGHTTPD_VERSION)-$(LIGHTTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIGHTTPD_MAINTAINER)" >>$@
	@echo "Source: $(LIGHTTPD_SITE)/$(LIGHTTPD_SOURCE)" >>$@
	@echo "Description: $(LIGHTTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIGHTTPD_DEPENDS)" >>$@
	@echo "Suggests: $(LIGHTTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIGHTTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIGHTTPD_IPK_DIR)/opt/sbin or $(LIGHTTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIGHTTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIGHTTPD_IPK_DIR)/opt/etc/lighttpd/...
# Documentation files should be installed in $(LIGHTTPD_IPK_DIR)/opt/doc/lighttpd/...
# Daemon startup scripts should be installed in $(LIGHTTPD_IPK_DIR)/opt/etc/init.d/S??lighttpd
#
# You may need to patch your application to make it use these locations.
#
$(LIGHTTPD_IPK): $(LIGHTTPD_BUILD_DIR)/.built
	rm -rf $(LIGHTTPD_IPK_DIR) $(BUILD_DIR)/lighttpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIGHTTPD_BUILD_DIR) \
	    DESTDIR=$(LIGHTTPD_IPK_DIR) program_transform_name="" install-strip
	rm -f $(LIGHTTPD_IPK_DIR)/opt/bin/spawn-fcgi
	rm -f $(LIGHTTPD_IPK_DIR)/opt/share/man/man1/spawn-fcgi.1
	rm -f $(LIGHTTPD_IPK_DIR)/opt/lib/lighttpd/*.la
	install -d $(LIGHTTPD_IPK_DIR)/opt/share/doc/lighttpd
	install -d $(LIGHTTPD_IPK_DIR)/opt/share/www/lighttpd
	install -d $(LIGHTTPD_IPK_DIR)/opt/var/log/lighttpd
	rsync -av $(LIGHTTPD_BUILD_DIR)/doc/* $(LIGHTTPD_IPK_DIR)/opt/share/doc/lighttpd/
	install -m 644 $(LIGHTTPD_SOURCE_DIR)/index.html $(LIGHTTPD_IPK_DIR)/opt/share/www/lighttpd/
	install -d $(LIGHTTPD_IPK_DIR)/opt/etc/lighttpd
	install -m 644 $(LIGHTTPD_SOURCE_DIR)/lighttpd.conf $(LIGHTTPD_IPK_DIR)/opt/etc/lighttpd/
	install -d $(LIGHTTPD_IPK_DIR)/opt/etc/lighttpd/conf.d
	echo > $(LIGHTTPD_IPK_DIR)/opt/etc/lighttpd/conf.d/01-default.conf
	install -d $(LIGHTTPD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(LIGHTTPD_SOURCE_DIR)/rc.lighttpd $(LIGHTTPD_IPK_DIR)/opt/etc/init.d/S80lighttpd
	$(MAKE) $(LIGHTTPD_IPK_DIR)/CONTROL/control
	install -m 755 $(LIGHTTPD_SOURCE_DIR)/postinst $(LIGHTTPD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(LIGHTTPD_SOURCE_DIR)/prerm $(LIGHTTPD_IPK_DIR)/CONTROL/prerm
	echo $(LIGHTTPD_CONFFILES) | sed -e 's/ /\n/g' > $(LIGHTTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIGHTTPD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIGHTTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lighttpd-ipk: $(LIGHTTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lighttpd-clean:
	rm -f $(LIGHTTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(LIGHTTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lighttpd-dirclean:
	rm -rf $(BUILD_DIR)/$(LIGHTTPD_DIR) $(LIGHTTPD_BUILD_DIR) $(LIGHTTPD_IPK_DIR) $(LIGHTTPD_IPK)

#
# Some sanity check for the package.
#
lighttpd-check: $(LIGHTTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
