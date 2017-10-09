###########################################################
#
# squid3
#
###########################################################

# You must replace "squid3" and "SQUID3" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SQUID3_VERSION, SQUID3_SITE and SQUID3_SOURCE define
# the upstream location of the source code for the package.
# SQUID3_DIR is the directory which is created when the source
# archive is unpacked.
# SQUID3_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SQUID3_SITE=http://www.squid-cache.org/Versions/v3/3.5
SQUID3_VERSION=3.5.15
SQUID3_SOURCE=squid-$(SQUID3_VERSION).tar.xz
SQUID3_DIR=squid-$(SQUID3_VERSION)
SQUID3_UNZIP=xzcat

SQUID3_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQUID3_DESCRIPTION=Full-featured Web proxy cache.
SQUID3_SECTION=web
SQUID3_PRIORITY=optional
SQUID3_DEPENDS=libstdc++, openssl, expat, libxml2, gnutls, libnettle, libcap, libnetfilter-conntrack, libtool
SQUID3_SUGGESTS=
SQUID3_CONFLICTS=squid

# override SQUID3_IPK_VERSION for target specific feeds
SQUID3_IPK_VERSION=4

#
## SQUID3_CONFFILES should be a list of user-editable files
SQUID3_CONFFILES=$(TARGET_PREFIX)/etc/squid/squid.conf $(TARGET_PREFIX)/etc/init.d/S80squid

#
# SQUID3_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SQUID3_PATCHES=$(SQUID3_SOURCE_DIR)/cross_compile.patch

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
SQUID3_PATCHES += $(SQUID3_SOURCE_DIR)/linux_h.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQUID3_CPPFLAGS=
SQUID3_LDFLAGS=

#
# SQUID3_BUILD_DIR is the directory in which the build is done.
# SQUID3_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SQUID3_IPK_DIR is the directory in which the ipk is built.
# SQUID3_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SQUID3_SOURCE_DIR=$(SOURCE_DIR)/squid3

SQUID3_BUILD_DIR=$(BUILD_DIR)/squid3
SQUID3_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/squid3

SQUID3_IPK_DIR=$(BUILD_DIR)/squid3-$(SQUID3_VERSION)-ipk
SQUID3_IPK=$(BUILD_DIR)/squid3_$(SQUID3_VERSION)-$(SQUID3_IPK_VERSION)_$(TARGET_ARCH).ipk

SQUID3_INST_DIR=$(TARGET_PREFIX)
SQUID3_BIN_DIR=$(SQUID3_INST_DIR)/bin
SQUID3_SBIN_DIR=$(SQUID3_INST_DIR)/sbin
SQUID3_LIBEXEC_DIR=$(SQUID3_INST_DIR)/libexec
SQUID3_DATA_DIR=$(SQUID3_INST_DIR)/share/squid
SQUID3_SYSCONF_DIR=$(SQUID3_INST_DIR)/etc/squid
SQUID3_SHAREDSTATE_DIR=$(SQUID3_INST_DIR)/com/squid
SQUID3_LOCALSTATE_DIR=$(SQUID3_INST_DIR)/var/squid
SQUID3_LIB_DIR=$(SQUID3_INST_DIR)/lib
SQUID3_INCLUDE_DIR=$(SQUID3_INST_DIR)/include
SQUID3_INFO_DIR=$(SQUID3_INST_DIR)/info
SQUID3_MAN_DIR=$(SQUID3_INST_DIR)/man

.PHONY: squid3-source squid3-unpack squid3 squid3-stage squid3-ipk squid3-clean squid3-dirclean squid3-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SQUID3_SOURCE):
	$(WGET) -P $(@D) $(SQUID3_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
squid3-source: $(DL_DIR)/$(SQUID3_SOURCE) $(SQUID3_PATCHES)

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
$(SQUID3_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUID3_SOURCE) $(SQUID3_PATCHES) make/squid3.mk
	$(MAKE) openssl-stage expat-stage libxml2-stage gnutls-stage libnettle-stage \
		libcap-stage libnetfilter-conntrack-stage libtool-stage
	rm -rf $(BUILD_DIR)/$(SQUID3_DIR) $(@D)
	$(SQUID3_UNZIP) $(DL_DIR)/$(SQUID3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQUID3_PATCHES)" ; \
		then cat $(SQUID3_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SQUID3_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SQUID3_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SQUID3_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQUID3_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQUID3_LDFLAGS)" \
		ac_cv_header_linux_netfilter_ipv4_h=yes \
		ac_cv_epoll_works=yes \
		squid_cv_gnu_atomics=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SQUID3_INST_DIR) \
		--bindir=$(SQUID3_BIN_DIR) \
		--sbindir=$(SQUID3_SBIN_DIR) \
		--libexecdir=$(SQUID3_LIBEXEC_DIR) \
		--datadir=$(SQUID3_DATA_DIR) \
		--sysconfdir=$(SQUID3_SYSCONF_DIR) \
		--sharedstatedir=$(SQUID3_SHAREDSTATE_DIR) \
		--localstatedir=$(SQUID3_LOCALSTATE_DIR) \
		--libdir=$(SQUID3_LIB_DIR) \
		--includedir=$(SQUID3_INCLUDE_DIR) \
		--oldincludedir=$(SQUID3_INCLUDE_DIR) \
		--infodir=$(SQUID3_INFO_DIR) \
		--mandir=$(SQUID3_MAN_DIR) \
		--enable-basic-auth-helpers="NCSA" \
		--disable-nls \
		--disable-static \
		--enable-shared \
		--enable-http-violations \
		--enable-icmp \
		--enable-delay-pools \
		--enable-icap-client \
		--enable-kill-parent-hack \
		--disable-snmp \
		--enable-ssl \
		--enable-ssl-crtd \
		--enable-cache-digests \
		--enable-linux-netfilter \
		--disable-unlinkd \
		--enable-x-accelerator-vary \
		--disable-translation \
		--disable-auto-locale \
		--with-dl \
		--with-pthreads \
		--with-expat=$(STAGING_PREFIX) \
		--with-libxml2=$(STAGING_PREFIX) \
		--with-gnutls=$(STAGING_PREFIX) \
		--with-nettle=$(STAGING_PREFIX) \
		--with-openssl=$(STAGING_PREFIX) \
		--enable-epoll \
		--with-maxfd=4096 \
		--disable-external-acl-helpers \
		--disable-auth-negotiate \
		--disable-auth-ntlm \
		--disable-auth-digest \
		--disable-auth-basic \
		--disable-arch-native \
		--with-krb5-config=no \
		--without-mit-krb5 \
		--with-libcap \
		--with-netfilter-conntrack=$(STAGING_PREFIX) \
	)
	sed -i -e 's/-Werror//g' `find $(@D) -type f -name Makefile`
	touch $@

squid3-unpack: $(SQUID3_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SQUID3_BUILD_DIR)/.built: $(SQUID3_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
squid3: $(SQUID3_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SQUID3_BUILD_DIR)/.staged: $(SQUID3_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

squid3-stage: $(SQUID3_BUILD_DIR)/.staged

$(SQUID3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: squid3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQUID3_PRIORITY)" >>$@
	@echo "Section: $(SQUID3_SECTION)" >>$@
	@echo "Version: $(SQUID3_VERSION)-$(SQUID3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQUID3_MAINTAINER)" >>$@
	@echo "Source: $(SQUID3_SITE)/$(SQUID3_SOURCE)" >>$@
	@echo "Description: $(SQUID3_DESCRIPTION)" >>$@
	@echo "Depends: $(SQUID3_DEPENDS)" >>$@
	@echo "Suggests: $(SQUID3_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQUID3_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/etc/squid3/...
# Documentation files should be installed in $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/doc/squid3/...
# Daemon startup scripts should be installed in $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??squid3
#
# You may need to patch your application to make it use these locations.
#
$(SQUID3_IPK): $(SQUID3_BUILD_DIR)/.built
	rm -rf $(SQUID3_IPK_DIR) $(BUILD_DIR)/squid3_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SQUID3_BUILD_DIR) DESTDIR=$(SQUID3_IPK_DIR) install-strip
	$(INSTALL) -d $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(SQUID3_SOURCE_DIR)/rc.squid $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S80squid
	ln -sf $(TARGET_PREFIX)/etc/init.d/S80squid $(SQUID3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K80squid 
	$(INSTALL) -m 755 $(SQUID3_SOURCE_DIR)/squid.delay-start.sh $(SQUID3_IPK_DIR)$(SQUID3_SYSCONF_DIR)/squid.delay-start.sh
	$(INSTALL) -d $(SQUID3_IPK_DIR)/CONTROL
	$(MAKE) $(SQUID3_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(SQUID3_SOURCE_DIR)/postinst $(SQUID3_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 644 $(SQUID3_SOURCE_DIR)/preinst $(SQUID3_IPK_DIR)/CONTROL/preinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQUID3_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SQUID3_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
squid3-ipk: $(SQUID3_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
squid3-clean:
	-$(MAKE) -C $(SQUID3_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
squid3-dirclean:
	rm -rf $(BUILD_DIR)/$(SQUID3_DIR) $(SQUID3_BUILD_DIR) $(SQUID3_IPK_DIR) $(SQUID3_IPK)

#
# Some sanity check for the package.
#
squid3-check: $(SQUID3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
