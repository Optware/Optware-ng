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
SQUID3_SITE=http://www.squid-cache.org/Versions/v3/3.1
SQUID3_VERSION=3.1.8
SQUID3_SOURCE=squid-$(SQUID3_VERSION).tar.bz2
SQUID3_DIR=squid-$(SQUID3_VERSION)
SQUID3_UNZIP=bzcat

SQUID3_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQUID3_DESCRIPTION=Full-featured Web proxy cache.
SQUID3_SECTION=web
SQUID3_PRIORITY=optional
SQUID3_DEPENDS=
SQUID3_SUGGESTS=
SQUID3_CONFLICTS=squid

# override SQUID3_IPK_VERSION for target specific feeds
SQUID3_IPK_VERSION ?= 1

#
## SQUID3_CONFFILES should be a list of user-editable files
SQUID3_CONFFILES=/opt/etc/squid/squid.conf /opt/etc/init.d/S80squid

#
# SQUID3_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SQUID3_PATCHES=$(SQUID3_SOURCE_DIR)/squidv3-build-cf_gen.patch \
		$(SQUID3_SOURCE_DIR)/fix-runs-in-configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SQUID3_CPPFLAGS=
SQUID3_LDFLAGS=
SQUID3_EPOLL ?= $(strip \
$(if $(filter syno-e500, $(OPTWARE_TARGET)),--disable-epoll, \
$(if $(filter module-init-tools, $(PACKAGES)),--enable-epoll, \
--disable-epoll)))

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

SQUID3_INST_DIR=/opt
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

ifneq ($(HOSTCC), $(TARGET_CC))
SQUID3_CROSS_CONFIG_ENVS=\
	ac_cv_sizeof_int8_t=1 \
	ac_cv_sizeof_uint8_t=1 \
	ac_cv_sizeof_u_int8_t=1 \
	ac_cv_sizeof_int16_t=2 \
	ac_cv_sizeof_uint16_t=2 \
	ac_cv_sizeof_u_int16_t=2 \
	ac_cv_sizeof_int32_t=4 \
	ac_cv_sizeof_uint32_t=4 \
	ac_cv_sizeof_u_int32_t=4 \
	ac_cv_sizeof_int64_t=8 \
	ac_cv_sizeof_uint64_t=8 \
	ac_cv_sizeof_u_int64_t=8 \
	ac_cv_sizeof___int64=0 \
	ac_cv_af_unix_large_dgram=yes \
	ac_cv_func_setresuid=yes \
	ac_cv_func_va_copy=yes \
	ac_cv_func___va_copy=yes \
	ac_cv_c_bigendian=no
ifeq (--enable-epoll, $(SQUID3_EPOLL))
SQUID3_CROSS_CONFIG_OPTIONS=--enable-epoll
SQUID3_CROSS_CONFIG_ENVS+= ac_cv_epoll_works=yes
else
SQUID3_CROSS_CONFIG_OPTIONS=--disable-epoll
endif
endif

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

$(SQUID3_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(SQUID3_SOURCE) make/squid3.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(HOST_BUILD_DIR)/$(SQUID3_DIR) $(@D)
	$(SQUID3_UNZIP) $(DL_DIR)/$(SQUID3_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(SQUID3_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(SQUID3_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=/opt \
	)
	$(MAKE) -C $(@D)
	touch $@
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
ifeq ($(HOSTCC), $(TARGET_CC))
$(SQUID3_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUID3_SOURCE) $(SQUID3_PATCHES) make/squid3.mk
else
$(SQUID3_BUILD_DIR)/.configured: $(SQUID3_HOST_BUILD_DIR)/.built $(SQUID3_PATCHES)
endif
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SQUID3_DIR) $(@D)
	$(SQUID3_UNZIP) $(DL_DIR)/$(SQUID3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQUID3_PATCHES)" ; \
		then cat $(SQUID3_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SQUID3_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SQUID3_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SQUID3_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SQUID3_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SQUID3_LDFLAGS)" \
		$(SQUID3_CROSS_CONFIG_ENVS) \
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
		$(SQUID3_CROSS_CONFIG_OPTIONS) \
		--enable-basic-auth-helpers="NCSA" \
		--disable-nls \
	)
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e 's|./cf_gen |$(SQUID3_HOST_BUILD_DIR)/src/cf_gen |g' $(@D)/src/Makefile
endif
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
	@install -d $(@D)
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
# Binaries should be installed into $(SQUID3_IPK_DIR)/opt/sbin or $(SQUID3_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SQUID3_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SQUID3_IPK_DIR)/opt/etc/squid3/...
# Documentation files should be installed in $(SQUID3_IPK_DIR)/opt/doc/squid3/...
# Daemon startup scripts should be installed in $(SQUID3_IPK_DIR)/opt/etc/init.d/S??squid3
#
# You may need to patch your application to make it use these locations.
#
$(SQUID3_IPK): $(SQUID3_BUILD_DIR)/.built
	rm -rf $(SQUID3_IPK_DIR) $(BUILD_DIR)/squid3_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SQUID3_BUILD_DIR) DESTDIR=$(SQUID3_IPK_DIR) install
	cd $(SQUID3_IPK_DIR)/opt; \
	$(STRIP_COMMAND) bin/squidclient sbin/squid \
		libexec/cachemgr.cgi libexec/ncsa_auth libexec/unlinkd \
		libexec/digest_pw_auth \
		libexec/diskd \
		libexec/fakeauth_auth \
		libexec/ip_user_check \
		libexec/ntlm_smb_lm_auth \
		libexec/squid_unix_group \
		;
	install -d $(SQUID3_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SQUID3_SOURCE_DIR)/rc.squid $(SQUID3_IPK_DIR)/opt/etc/init.d/S80squid
	ln -sf /opt/etc/init.d/S80squid $(SQUID3_IPK_DIR)/opt/etc/init.d/K80squid 
	install -m 755 $(SQUID3_SOURCE_DIR)/squid.delay-start.sh $(SQUID3_IPK_DIR)$(SQUID3_SYSCONF_DIR)/squid.delay-start.sh
	install -d $(SQUID3_IPK_DIR)/CONTROL
	$(MAKE) $(SQUID3_IPK_DIR)/CONTROL/control
	install -m 644 $(SQUID3_SOURCE_DIR)/postinst $(SQUID3_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SQUID3_SOURCE_DIR)/preinst $(SQUID3_IPK_DIR)/CONTROL/preinst
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
