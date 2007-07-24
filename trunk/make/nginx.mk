###########################################################
#
# nginx
#
###########################################################
#
# NGINX_VERSION, NGINX_SITE and NGINX_SOURCE define
# the upstream location of the source code for the package.
# NGINX_DIR is the directory which is created when the source
# archive is unpacked.
# NGINX_UNZIP is the command used to unzip the source.
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
NGINX_SITE=http://sysoev.ru/nginx
NGINX_VERSION=0.6.4
NGINX_SOURCE=nginx-$(NGINX_VERSION).tar.gz
NGINX_DIR=nginx-$(NGINX_VERSION)
NGINX_UNZIP=zcat
NGINX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NGINX_DESCRIPTION=A high perfomance http and reverse proxy server, and IMAP/POP3 proxy server.
NGINX_SECTION=net
NGINX_PRIORITY=optional
NGINX_DEPENDS=openssl, pcre, zlib
NGINX_SUGGESTS=
NGINX_CONFLICTS=

#
# NGINX_IPK_VERSION should be incremented when the ipk changes.
#
NGINX_IPK_VERSION=1

NGINX_PREFIX=/opt/nginx

#
# NGINX_CONFFILES should be a list of user-editable files
NGINX_CONFFILES=\
	$(NGINX_PREFIX)/conf/nginx.conf \
	$(NGINX_PREFIX)/conf/mime.types \
	$(NGINX_PREFIX)/html/index.html \
	$(NGINX_PREFIX)/html/50x.html \

#
# NGINX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NGINX_PATCHES=

ifneq ($(HOSTCC), $(TARGET_CC))
NGINX_PATCHES+=$(NGINX_SOURCE_DIR)/cross-configure.patch
NGINX_CONFIGURE_ENV=\
NGX_SYSTEM=Linux NGX_RELEASE=2.4 NGX_MACHINE=$(TARGET_ARCH) \
cross_compiling=yes \
ngx_cache_NGX_HAVE_STRERROR_R=no \
ngx_cache_sizeof_int=4 \
ngx_cache_sizeof_long=4 \
ngx_cache_sizeof_long_long=8 \
ngx_cache_sizeof_void__=4 \
ngx_cache_sizeof_sig_atomic_t=4 \
ngx_cache_sizeof_size_t=4 \
ngx_cache_sizeof_off_t=8 \
ngx_cache_sizeof_time_t=4
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NGINX_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), slugosbe)
NGINX_CPPFLAGS+=-DIOV_MAX=1024
endif
NGINX_LDFLAGS=

#
# NGINX_BUILD_DIR is the directory in which the build is done.
# NGINX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NGINX_IPK_DIR is the directory in which the ipk is built.
# NGINX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NGINX_BUILD_DIR=$(BUILD_DIR)/nginx
NGINX_SOURCE_DIR=$(SOURCE_DIR)/nginx
NGINX_IPK_DIR=$(BUILD_DIR)/nginx-$(NGINX_VERSION)-ipk
NGINX_IPK=$(BUILD_DIR)/nginx_$(NGINX_VERSION)-$(NGINX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nginx-source nginx-unpack nginx nginx-stage nginx-ipk nginx-clean nginx-dirclean nginx-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NGINX_SOURCE):
	$(WGET) -P $(DL_DIR) $(NGINX_SITE)/$(NGINX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nginx-source: $(DL_DIR)/$(NGINX_SOURCE) $(NGINX_PATCHES)

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
$(NGINX_BUILD_DIR)/.configured: $(DL_DIR)/$(NGINX_SOURCE) $(NGINX_PATCHES) make/nginx.mk
	$(MAKE) openssl-stage pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(NGINX_DIR) $(NGINX_BUILD_DIR)
	$(NGINX_UNZIP) $(DL_DIR)/$(NGINX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NGINX_PATCHES)" ; \
		then cat $(NGINX_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(NGINX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NGINX_DIR)" != "$(NGINX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NGINX_DIR) $(NGINX_BUILD_DIR) ; \
	fi
#		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--crossbuild=linux \
                --with-threads \
		--disable-nls \
		--disable-static
	sed -i -e 's|/usr/include/|$(TARGET_LIBDIR)/../include/|' $(NGINX_BUILD_DIR)/auto/os/linux
	(cd $(NGINX_BUILD_DIR); \
	    if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*LITTLE_ENDIAN; \
		then export ngx_cache_ENDIAN=LITTLE; \
	    fi; \
	    $(NGINX_CONFIGURE_ENV) \
	    ./configure \
		--prefix=$(NGINX_PREFIX) \
		--conf-path=conf/nginx.conf \
		--error-log-path=logs/error.log \
		--pid-path=/opt/var/run/nginx.pid \
		--http-log-path=logs/access.log \
		--http-client-body-temp-path=tmp/client_body_temp \
		--http-proxy-temp-path=tmp/proxy_temp \
		--http-fastcgi-temp-path=tmp/fastcgi_temp \
                --with-cc=$(TARGET_CC) \
                --with-cpp=$(TARGET_CPP) \
                --with-cc-opt="$(STAGING_CPPFLAGS) $(NGINX_CPPFLAGS)" \
                --with-ld-opt="$(STAGING_LDFLAGS) $(NGINX_LDFLAGS)" \
                --with-http_ssl_module \
		; \
	)
	sed -i.orig \
                -e '/^install:/,$$s#/opt#$$(DESTDIR)/opt#g' \
                -e '/^CFLAGS/{s| -Werror||;s|-I/opt/include||;}' \
                $(NGINX_BUILD_DIR)/objs/Makefile
ifeq ($(OPTWARE_TARGET), nslu2)
	sed -i -e '/#define NGX_GROUP/s/nogroup/nobody/' $(NGINX_BUILD_DIR)/objs/ngx_auto_config.h
endif
ifeq ($(LIBC_STYLE), uclibc)
	sed -i -e 's/#ifndef NGX_HAVE_GNU_CRYPT_R/#if 0/' $(NGINX_BUILD_DIR)/src/os/unix/ngx_linux_config.h
endif
	touch $(NGINX_BUILD_DIR)/.configured

nginx-unpack: $(NGINX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NGINX_BUILD_DIR)/.built: $(NGINX_BUILD_DIR)/.configured
	rm -f $(NGINX_BUILD_DIR)/.built
	$(MAKE) -C $(NGINX_BUILD_DIR)
	touch $(NGINX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nginx: $(NGINX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NGINX_BUILD_DIR)/.staged: $(NGINX_BUILD_DIR)/.built
	rm -f $(NGINX_BUILD_DIR)/.staged
	$(MAKE) -C $(NGINX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NGINX_BUILD_DIR)/.staged

nginx-stage: $(NGINX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nginx
#
$(NGINX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nginx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NGINX_PRIORITY)" >>$@
	@echo "Section: $(NGINX_SECTION)" >>$@
	@echo "Version: $(NGINX_VERSION)-$(NGINX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NGINX_MAINTAINER)" >>$@
	@echo "Source: $(NGINX_SITE)/$(NGINX_SOURCE)" >>$@
	@echo "Description: $(NGINX_DESCRIPTION)" >>$@
	@echo "Depends: $(NGINX_DEPENDS)" >>$@
	@echo "Suggests: $(NGINX_SUGGESTS)" >>$@
	@echo "Conflicts: $(NGINX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NGINX_IPK_DIR)/opt/sbin or $(NGINX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NGINX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NGINX_IPK_DIR)/opt/etc/nginx/...
# Documentation files should be installed in $(NGINX_IPK_DIR)/opt/doc/nginx/...
# Daemon startup scripts should be installed in $(NGINX_IPK_DIR)/opt/etc/init.d/S??nginx
#
# You may need to patch your application to make it use these locations.
#
$(NGINX_IPK): $(NGINX_BUILD_DIR)/.built
	rm -rf $(NGINX_IPK_DIR) $(BUILD_DIR)/nginx_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NGINX_BUILD_DIR) -f objs/Makefile DESTDIR=$(NGINX_IPK_DIR) install
	$(STRIP_COMMAND) $(NGINX_IPK_DIR)$(NGINX_PREFIX)/sbin/nginx
	install -d $(NGINX_IPK_DIR)/opt/sbin; \
        	cd $(NGINX_IPK_DIR)/opt/sbin; \
        	ln -s $(NGINX_PREFIX)/sbin/nginx .
	install -d $(NGINX_IPK_DIR)/opt/share/www; \
        	cd $(NGINX_IPK_DIR)/opt/share/www; \
                ln -s $(NGINX_PREFIX)/html nginx
	install -d $(NGINX_IPK_DIR)/opt/etc; \
        	cd $(NGINX_IPK_DIR)/opt/etc; \
                ln -s $(NGINX_PREFIX)/conf nginx
	install -d $(NGINX_IPK_DIR)$(NGINX_PREFIX)/tmp
#	install -m 644 $(NGINX_SOURCE_DIR)/nginx.conf $(NGINX_IPK_DIR)/opt/etc/nginx.conf
#	install -d $(NGINX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NGINX_SOURCE_DIR)/rc.nginx $(NGINX_IPK_DIR)/opt/etc/init.d/SXXnginx
	$(MAKE) $(NGINX_IPK_DIR)/CONTROL/control
#	install -m 755 $(NGINX_SOURCE_DIR)/postinst $(NGINX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NGINX_SOURCE_DIR)/prerm $(NGINX_IPK_DIR)/CONTROL/prerm
	echo $(NGINX_CONFFILES) | sed -e 's/ /\n/g' > $(NGINX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NGINX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nginx-ipk: $(NGINX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nginx-clean:
	rm -f $(NGINX_BUILD_DIR)/.built
	-$(MAKE) -C $(NGINX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nginx-dirclean:
	rm -rf $(BUILD_DIR)/$(NGINX_DIR) $(NGINX_BUILD_DIR) $(NGINX_IPK_DIR) $(NGINX_IPK)

#
# Some sanity check for the package.
#
nginx-check: $(NGINX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NGINX_IPK)
