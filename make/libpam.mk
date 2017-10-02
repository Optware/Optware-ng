###########################################################
#
# libpam
#
###########################################################
#
# LIBPAM_VERSION, LIBPAM_SITE and LIBPAM_SOURCE define
# the upstream location of the source code for the package.
# LIBPAM_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPAM_UNZIP is the command used to unzip the source.
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
LIBPAM_SITE=http://http.debian.net/debian/pool/main/p/pam
LIBPAM_VERSION=1.1.8
LIBPAM_SOURCE=pam_$(LIBPAM_VERSION).orig.tar.gz
LIBPAM_DIR=Linux-PAM-$(LIBPAM_VERSION)
LIBPAM_UNZIP=zcat
LIBPAM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPAM_DESCRIPTION=Shared library for Linux-PAM, a library that enables the local system administrator to choose how applications authenticate users.
LIBPAM_SECTION=lib
LIBPAM_PRIORITY=optional
LIBPAM_DEPENDS=
LIBPAM_SUGGESTS=
LIBPAM_CONFLICTS=

#
# LIBPAM_IPK_VERSION should be incremented when the ipk changes.
#
LIBPAM_IPK_VERSION=4

#
# LIBPAM_CONFFILES should be a list of user-editable files
LIBPAM_CONFFILES=\
$(TARGET_PREFIX)/etc/pam.conf \
$(TARGET_PREFIX)/etc/security/time.conf \
$(TARGET_PREFIX)/etc/security/access.conf \
$(TARGET_PREFIX)/etc/security/pam_env.conf \
$(TARGET_PREFIX)/etc/security/group.conf \
$(TARGET_PREFIX)/etc/security/namespace.conf \
$(TARGET_PREFIX)/etc/security/limits.conf \
$(TARGET_PREFIX)/etc/pam.d/common-account \
$(TARGET_PREFIX)/etc/pam.d/common-auth \
$(TARGET_PREFIX)/etc/pam.d/common-password \
$(TARGET_PREFIX)/etc/pam.d/common-session \
$(TARGET_PREFIX)/etc/pam.d/other \

#
# LIBPAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBPAM_PATCHES=\
$(LIBPAM_SOURCE_DIR)/pam_unix_fix_sgid_shadow_auth.patch \
$(LIBPAM_SOURCE_DIR)/pam_unix_dont_trust_chkpwd_caller.patch \
$(LIBPAM_SOURCE_DIR)/000-optware_paths.patch \
$(LIBPAM_SOURCE_DIR)/001-buildroot-patches.patch \
$(LIBPAM_SOURCE_DIR)/002-configure_libcrypt.patch \
$(LIBPAM_SOURCE_DIR)/007_modules_pam_unix \
$(LIBPAM_SOURCE_DIR)/008_modules_pam_limits_chroot \
$(LIBPAM_SOURCE_DIR)/021_nis_cleanup \
$(LIBPAM_SOURCE_DIR)/022_pam_unix_group_time_miscfixes \
$(LIBPAM_SOURCE_DIR)/026_pam_unix_passwd_unknown_user \
$(LIBPAM_SOURCE_DIR)/do_not_check_nis_accidentally \
$(LIBPAM_SOURCE_DIR)/027_pam_limits_better_init_allow_explicit_root \
$(LIBPAM_SOURCE_DIR)/031_pam_include  \
$(LIBPAM_SOURCE_DIR)/032_pam_limits_EPERM_NOT_FATAL \
$(LIBPAM_SOURCE_DIR)/036_pam_wheel_getlogin_considered_harmful \
$(LIBPAM_SOURCE_DIR)/hurd_no_setfsuid \
$(LIBPAM_SOURCE_DIR)/040_pam_limits_log_failure \
$(LIBPAM_SOURCE_DIR)/045_pam_dispatch_jump_is_ignore \
$(LIBPAM_SOURCE_DIR)/054_pam_security_abstract_securetty_handling \
$(LIBPAM_SOURCE_DIR)/055_pam_unix_nullok_secure \
$(LIBPAM_SOURCE_DIR)/056-pam_unix_no_pass_expiry.patch \
$(LIBPAM_SOURCE_DIR)/cve-2011-4708.patch \
$(LIBPAM_SOURCE_DIR)/update-motd \
$(LIBPAM_SOURCE_DIR)/no_PATH_MAX_on_hurd \
$(LIBPAM_SOURCE_DIR)/lib_security_multiarch_compat \
$(LIBPAM_SOURCE_DIR)/pam-loginuid-in-containers \
$(LIBPAM_SOURCE_DIR)/cve-2013-7041.patch \
$(LIBPAM_SOURCE_DIR)/cve-2014-2583.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPAM_CPPFLAGS=
LIBPAM_LDFLAGS=-lpthread

#
# LIBPAM_BUILD_DIR is the directory in which the build is done.
# LIBPAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPAM_IPK_DIR is the directory in which the ipk is built.
# LIBPAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPAM_BUILD_DIR=$(BUILD_DIR)/libpam
LIBPAM_SOURCE_DIR=$(SOURCE_DIR)/libpam
LIBPAM_IPK_DIR=$(BUILD_DIR)/libpam-$(LIBPAM_VERSION)-ipk
LIBPAM_IPK=$(BUILD_DIR)/libpam_$(LIBPAM_VERSION)-$(LIBPAM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpam-source libpam-unpack libpam libpam-stage libpam-ipk libpam-clean libpam-dirclean libpam-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPAM_SOURCE):
	$(WGET) -P $(@D) $(LIBPAM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpam-source: $(DL_DIR)/$(LIBPAM_SOURCE) $(LIBPAM_PATCHES)

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
$(LIBPAM_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPAM_SOURCE) $(LIBPAM_PATCHES) make/libpam.mk
	$(MAKE) gettext-host-stage
	rm -rf $(BUILD_DIR)/$(LIBPAM_DIR) $(@D)
	$(LIBPAM_UNZIP) $(DL_DIR)/$(LIBPAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBPAM_PATCHES)" ; \
		then cat $(LIBPAM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBPAM_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBPAM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBPAM_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPAM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPAM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--libdir=$(TARGET_PREFIX)/lib \
		--disable-nls \
		--disable-static \
		--disable-audit \
		--disable-prelude \
		--disable-isadir \
		--disable-nis \
		--disable-db \
		--disable-regenerate-docu \
		--with-mailspool=$(TARGET_PREFIX)/var/spool/mail \
		--with-xauth=$(TARGET_PREFIX)/bin/xauth \
		--enable-securedir=$(TARGET_PREFIX)/lib/security \
		--libdir=$(TARGET_PREFIX)/lib \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libpam-unpack: $(LIBPAM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBPAM_BUILD_DIR)/.built: $(LIBPAM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libpam: $(LIBPAM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPAM_BUILD_DIR)/.staged: $(LIBPAM_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_INCLUDE_DIR)/security
	$(MAKE) -C $(@D)/libpam DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpam*.la
	mkdir -p $(STAGING_INCLUDE_DIR)/security
	for h in _pam_types.h _pam_compat.h pam_modutil.h pam_modules.h pam_ext.h pam_appl.h _pam_macros.h; do \
		ln -sf ../$$h $(STAGING_INCLUDE_DIR)/security/$$h; \
	done
	touch $@

libpam-stage: $(LIBPAM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpam
#
$(LIBPAM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libpam" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPAM_PRIORITY)" >>$@
	@echo "Section: $(LIBPAM_SECTION)" >>$@
	@echo "Version: $(LIBPAM_VERSION)-$(LIBPAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPAM_MAINTAINER)" >>$@
	@echo "Source: $(LIBPAM_SITE)/$(LIBPAM_SOURCE)" >>$@
	@echo "Description: $(LIBPAM_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPAM_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPAM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/libpam/...
# Documentation files should be installed in $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/doc/libpam/...
# Daemon startup scripts should be installed in $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libpam
#
# You may need to patch your application to make it use these locations.
#
$(LIBPAM_IPK): $(LIBPAM_BUILD_DIR)/.built
	rm -rf $(LIBPAM_IPK_DIR) $(BUILD_DIR)/libpam_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBPAM_BUILD_DIR) DESTDIR=$(LIBPAM_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBPAM_IPK_DIR)/$(TARGET_PREFIX)/lib{,/security}/*.so \
			$(LIBPAM_IPK_DIR)/$(TARGET_PREFIX)/lib/security/pam_filter/upperLOWER \
			$(LIBPAM_IPK_DIR)/$(TARGET_PREFIX)/sbin/*
	find $(LIBPAM_IPK_DIR)/$(TARGET_PREFIX) -type f -name '*.la' -exec rm -f {} \;
	$(INSTALL) -d $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/pam.d
	$(INSTALL) -m 644 $(LIBPAM_BUILD_DIR)/conf/pam.conf $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/pam.conf
	$(INSTALL) -m 644 $(LIBPAM_SOURCE_DIR)/conf/{common-account,common-auth,common-password,common-session,other} $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/pam.d
#	$(INSTALL) -d $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBPAM_SOURCE_DIR)/rc.libpam $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibpam
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPAM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibpam
	$(MAKE) $(LIBPAM_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBPAM_SOURCE_DIR)/postinst $(LIBPAM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPAM_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBPAM_SOURCE_DIR)/prerm $(LIBPAM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBPAM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBPAM_IPK_DIR)/CONTROL/postinst $(LIBPAM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBPAM_CONFFILES) | sed -e 's/ /\n/g' > $(LIBPAM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPAM_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBPAM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpam-ipk: $(LIBPAM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpam-clean:
	rm -f $(LIBPAM_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBPAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpam-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPAM_DIR) $(LIBPAM_BUILD_DIR) $(LIBPAM_IPK_DIR) $(LIBPAM_IPK)
#
#
# Some sanity check for the package.
#
libpam-check: $(LIBPAM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
