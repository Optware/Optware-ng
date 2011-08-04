###########################################################
#
# samba34
#
###########################################################

# You must replace "samba" and "SAMBA" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SAMBA_VERSION, SAMBA_SITE and SAMBA_SOURCE define
# the upstream location of the source code for the package.
# SAMBA_DIR is the directory which is created when the source
# archive is unpacked.
# SAMBA_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SAMBA34_SITE=http://www.samba.org/samba/ftp/stable
SAMBA34_VERSION ?= 3.4.14
SAMBA34_IPK_VERSION ?= 1
SAMBA34_SOURCE=samba-$(SAMBA34_VERSION).tar.gz
SAMBA34_DIR=samba-$(SAMBA34_VERSION)
SAMBA34_UNZIP=zcat
SAMBA34_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SAMBA34_DESCRIPTION=Samba suite provides file and print services to SMB/CIFS clients. This is a newer version.
SAMBA34_SECTION=net
SAMBA34_PRIORITY=optional
SAMBA34_DEPENDS=avahi, popt, readline, zlib
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA34_DEPENDS +=, openldap-libs
endif
ifeq (glibc, $(LIBC_STYLE))
SAMBA34_DEPENDS +=, gconv-modules
endif
SAMBA34-DEV_DEPENDS=samba34
SAMBA34-SWAT_DEPENDS=samba34, xinetd
SAMBA34_SUGGESTS=cups
SAMBA34-DEV_SUGGESTS=
SAMBA34-SWAT_SUGGESTS=
SAMBA34_CONFLICTS=samba2, samba, samba35
SAMBA34-DEV_CONFLICTS=samba2, samba3-dev, samba35-dev
SAMBA34-SWAT_CONFLICTS=samba2, samba3-swat, samba35-swat
SAMBA34_ADDITIONAL_CODEPAGES=CP866

#
# SAMBA34_CONFFILES should be a list of user-editable files
SAMBA34_CONFFILES=/opt/etc/init.d/S08samba
SAMBA34-SWAT_CONFFILES=/opt/etc/xinetd.d/swat

#
# SAMBA34_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SAMBA34_PATCHES=$(SAMBA34_SOURCE_DIR)/configure.in.patch \
$(SAMBA34_SOURCE_DIR)/mtab.patch \

ifeq (uclibc, $(LIBC_STYLE))
SAMBA34_PATCHES += $(SAMBA34_SOURCE_DIR)/mount.cifs.c.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SAMBA34_CPPFLAGS=
SAMBA34_LDFLAGS=

#
# SAMBA34_BUILD_DIR is the directory in which the build is done.
# SAMBA34_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SAMBA34_IPK_DIR is the directory in which the ipk is built.
# SAMBA34_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SAMBA34_BUILD_DIR=$(BUILD_DIR)/samba34
SAMBA34_SOURCE_DIR=$(SOURCE_DIR)/samba34

SAMBA34_IPK_DIR=$(BUILD_DIR)/samba34-$(SAMBA34_VERSION)-ipk
SAMBA34_IPK=$(BUILD_DIR)/samba34_$(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA34-DEV_IPK_DIR=$(BUILD_DIR)/samba34-dev-$(SAMBA34_VERSION)-ipk
SAMBA34-DEV_IPK=$(BUILD_DIR)/samba34-dev_$(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA34-SWAT_IPK_DIR=$(BUILD_DIR)/samba34-swat-$(SAMBA34_VERSION)-ipk
SAMBA34-SWAT_IPK=$(BUILD_DIR)/samba34-swat_$(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)_$(TARGET_ARCH).ipk

SAMBA34_BUILD_DIR_SRC=$(SAMBA34_BUILD_DIR)/source3

SAMBA34_INST_DIR=/opt
SAMBA34_EXEC_PREFIX=$(SAMBA34_INST_DIR)
SAMBA34_BIN_DIR=$(SAMBA34_INST_DIR)/bin
SAMBA34_SBIN_DIR=$(SAMBA34_INST_DIR)/sbin
SAMBA34_LIBEXEC_DIR=$(SAMBA34_INST_DIR)/libexec
SAMBA34_DATA_DIR=$(SAMBA34_INST_DIR)/share/samba
SAMBA34_SYSCONF_DIR=$(SAMBA34_INST_DIR)/etc/samba
SAMBA34_SHAREDSTATE_DIR=$(SAMBA34_INST_DIR)/com/samba
SAMBA34_LOCALSTATE_DIR=$(SAMBA34_INST_DIR)/var/samba
SAMBA34_LIB_DIR=$(SAMBA34_INST_DIR)/lib
SAMBA34_INCLUDE_DIR=$(SAMBA34_INST_DIR)/include
SAMBA34_INFO_DIR=$(SAMBA34_INST_DIR)/info
SAMBA34_MAN_DIR=$(SAMBA34_INST_DIR)/man
SAMBA34_SWAT_DIR=$(SAMBA34_INST_DIR)/share/swat

ifeq (uclibc, $(LIBC_STYLE))
SAMBA34_LINUX_GETGROUPLIST_OK=no
else
SAMBA34_LINUX_GETGROUPLIST_OK=yes
endif

ifneq ($(HOSTCC), $(TARGET_CC))
SAMBA34_CROSS_ENVS=\
		LINUX_LFS_SUPPORT=yes \
		libreplace_cv_READDIR_GETDIRENTRIES=no \
		libreplace_cv_READDIR_GETDENTS=no \
		samba_cv_HAVE_WRFILE_KEYTAB=no \
		smb_krb5_cv_enctype_to_string_takes_krb5_context_arg=no \
		smb_krb5_cv_enctype_to_string_takes_size_t_arg=no \
		LOOK_DIRS=$(STAGING_PREFIX) \
		samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
		linux_getgrouplist_ok=$(SAMBA34_LINUX_GETGROUPLIST_OK) \
		samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
		samba_cv_have_setresuid=yes \
		samba_cv_have_setresgid=yes \
		samba_cv_USE_SETRESUID=yes \
		samba_cv_HAVE_IFACE_IFCONF=yes \
		samba_cv_SIZEOF_OFF_T=yes \
		samba_cv_SIZEOF_INO_T=yes \
		samba_cv_HAVE_DEVICE_MAJOR_FN=yes \
		samba_cv_HAVE_DEVICE_MINOR_FN=yes \
		samba_cv_HAVE_MAKEDEV=yes \
		samba_cv_HAVE_UNSIGNED_CHAR=yes \
		samba_cv_HAVE_C99_VSNPRINTF=yes \
		samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
		samba_cv_HAVE_KERNEL_CHANGE_NOTIFY=yes \
		samba_cv_HAVE_KERNEL_SHARE_MODES=yes \
		samba_cv_HAVE_FTRUNCATE_EXTEND=yes \
		samba_cv_HAVE_SECURE_MKSTEMP=yes \
		samba_cv_SYSCONF_SC_NGROUPS_MAX=yes \
		samba_cv_HAVE_MMAP=yes \
		samba_cv_HAVE_FCNTL_LOCK=yes \
		samba_cv_HAVE_STRUCT_FLOCK64=yes \
		samba_cv_have_longlong=yes \
		samba_cv_HAVE_OFF64_T=no \
		samba_cv_HAVE_INO64_T=no \
		samba_cv_HAVE_DEV64_T=no \
		samba_cv_HAVE_BROKEN_READDIR=no \
		samba_cv_HAVE_IRIX_SPECIFIC_CAPABILITIES=no \
		samba_cv_HAVE_WORKING_AF_LOCAL=yes \
		samba_cv_HAVE_BROKEN_GETGROUPS=no \
		samba_cv_REPLACE_INET_NTOA=no \
		samba_cv_SYSCONF_SC_NPROC_ONLN=no \
		samba_cv_HAVE_IFACE_AIX=no \
		samba_cv_HAVE_BROKEN_FCNTL64_LOCKS=no \
		samba_cv_REALPATH_TAKES_NULL=no \
		samba_cv_HAVE_TRUNCATED_SALT=no \
		fu_cv_sys_stat_statvfs64=yes
  ifeq (no, $(IPV6))
SAMBA34_CROSS_ENVS += libreplace_cv_HAVE_IPV6=no
  endif
  ifeq ($(OPTWARE_TARGET), $(filter oleg, $(OPTWARE_TARGET)))
SAMBA34_CROSS_ENVS += ac_cv_header_linux_dqblk_xfs_h=no
  endif
endif
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA34_CONFIG_ARGS=--with-ldap
endif

.PHONY: samba34-source samba34-unpack samba34 samba34-stage samba34-ipk samba34-clean samba34-dirclean samba34-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SAMBA34_SOURCE):
	$(WGET) -P $(@D) $(SAMBA34_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
samba34-source: $(DL_DIR)/$(SAMBA34_SOURCE) $(SAMBA34_PATCHES)

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
$(SAMBA34_BUILD_DIR)/.configured: $(DL_DIR)/$(SAMBA34_SOURCE) $(SAMBA34_PATCHES) make/samba34.mk
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage 
endif
	$(MAKE) avahi-stage cups-stage popt-stage readline-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(SAMBA34_DIR) $(@D)
	$(SAMBA34_UNZIP) $(DL_DIR)/$(SAMBA34_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SAMBA34_PATCHES) | patch -d $(BUILD_DIR)/$(SAMBA34_DIR) -p1
	mv $(BUILD_DIR)/$(SAMBA34_DIR) $(@D)
ifeq (3.0.14a, $(SAMBA34_VERSION))
	sed -i -e '/AC_TRY_RUN.*1.*5.*6.*7/s/;$$//' $(@D)/source/aclocal.m4
endif
ifeq ($(OPTWARE_TARGET), $(filter ddwrt oleg openwrt-ixp4xx, $(OPTWARE_TARGET)))
	#sed -i -e 's/^static size_t strl/size_t strl/' $(@D)/source3/client/mount.cifs.c
endif
	(cd $(@D)/source3/; ./autogen.sh )
	(cd $(@D)/source3/; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SAMBA34_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SAMBA34_LDFLAGS)" \
		$(SAMBA34_CROSS_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SAMBA34_INST_DIR) \
		--exec-prefix=$(SAMBA34_INST_DIR) \
		--bindir=$(SAMBA34_BIN_DIR) \
		--sbindir=$(SAMBA34_SBIN_DIR) \
		--libexecdir=$(SAMBA34_LIBEXEC_DIR) \
		--datadir=$(SAMBA34_DATA_DIR) \
		--sysconfdir=$(SAMBA34_SYSCONF_DIR) \
		--sharedstatedir=$(SAMBA34_SHAREDSTATE_DIR) \
		--localstatedir=$(SAMBA34_LOCALSTATE_DIR) \
		--libdir=$(SAMBA34_LIB_DIR) \
		--includedir=$(SAMBA34_INCLUDE_DIR) \
		--oldincludedir=$(SAMBA34_INCLUDE_DIR) \
		--infodir=$(SAMBA34_INFO_DIR) \
		--mandir=$(SAMBA34_MAN_DIR) \
		--disable-pie \
		--with-privatedir=$(SAMBA34_SYSCONF_DIR) \
		--with-lockdir=$(SAMBA34_LOCALSTATE_DIR) \
		--with-piddir=$(SAMBA34_LOCALSTATE_DIR) \
		--with-swatdir=$(SAMBA34_SWAT_DIR) \
		--with-configdir=$(SAMBA34_SYSCONF_DIR) \
		--with-logfilebase=$(SAMBA34_LOCALSTATE_DIR) \
		--with-libdir=$(SAMBA34_LIB_DIR) \
		--with-mandir=$(SAMBA34_MAN_DIR) \
		--with-smbmount \
		--with-quotas \
		--with-krb5=no \
		$(SAMBA34_CONFIG_ARGS) \
		--disable-nls \
	)
#	Remove Kerberos libs produced by broken configure
	sed -i -e 's/KRB5LIBS=.*/KRB5LIBS=/' \
	 -e 's/-lgssapi_krb5\|-lkrb5\|-lk5crypto\|-lcom_err\|-lgnutls//g' \
		$(@D)/source3/Makefile
### additional codepages
	CODEPAGES="$(SAMBA34_ADDITIONAL_CODEPAGES)" SAMBA34_SOURCE_DIR=$(SAMBA34_SOURCE_DIR) SAMBA34_BUILD_DIR=$(SAMBA34_BUILD_DIR) /bin/sh $(SAMBA34_SOURCE_DIR)/addcodepages.sh
	touch $@

samba34-unpack: $(SAMBA34_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SAMBA34_BUILD_DIR)/.built: $(SAMBA34_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/source3/
	touch $@

#
# This is the build convenience target.
#
samba34: $(SAMBA34_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SAMBA34_BUILD_DIR)/.staged: $(SAMBA34_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/source3/ DESTDIR=$(STAGING_DIR) install
	touch $@

samba34-stage: $(SAMBA34_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/samba
#
$(SAMBA34_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba34" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA34_PRIORITY)" >>$@
	@echo "Section: $(SAMBA34_SECTION)" >>$@
	@echo "Version: $(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA34_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA34_SITE)/$(SAMBA34_SOURCE)" >>$@
	@echo "Description: $(SAMBA34_DESCRIPTION)" >>$@
	@echo "Depends: $(SAMBA34_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA34_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA34_CONFLICTS)" >>$@

$(SAMBA34-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba34-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA34_PRIORITY)" >>$@
	@echo "Section: $(SAMBA34_SECTION)" >>$@
	@echo "Version: $(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA34_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA34_SITE)/$(SAMBA34_SOURCE)" >>$@
	@echo "Description: development files for samba34" >>$@
	@echo "Depends: $(SAMBA34-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA34-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA34-DEV_CONFLICTS)" >>$@

$(SAMBA34-SWAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba34-swat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA34_PRIORITY)" >>$@
	@echo "Section: $(SAMBA34_SECTION)" >>$@
	@echo "Version: $(SAMBA34_VERSION)-$(SAMBA34_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA34_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA34_SITE)/$(SAMBA34_SOURCE)" >>$@
	@echo "Description: the Samba Web Admin Tool for samba34" >>$@
	@echo "Depends: $(SAMBA34-SWAT_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA34-SWAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA34-SWAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SAMBA34_IPK_DIR)/opt/sbin or $(SAMBA34_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SAMBA34_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SAMBA34_IPK_DIR)/opt/etc/samba/...
# Documentation files should be installed in $(SAMBA34_IPK_DIR)/opt/doc/samba/...
# Daemon startup scripts should be installed in $(SAMBA34_IPK_DIR)/opt/etc/init.d/S??samba
#
# You may need to patch your application to make it use these locations.
#
$(SAMBA34_IPK) $(SAMBA34-DEV_IPK) $(SAMBA34-SWAT_IPK): $(SAMBA34_BUILD_DIR)/.built
	rm -rf $(SAMBA34_IPK_DIR) $(BUILD_DIR)/SAMBA34_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA34-DEV_IPK_DIR) $(BUILD_DIR)/samba34-dev_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA34-SWAT_IPK_DIR) $(BUILD_DIR)/samba34-swat_*_$(TARGET_ARCH).ipk
	# samba3
	$(MAKE) -C $(SAMBA34_BUILD_DIR)/source3/ DESTDIR=$(SAMBA34_IPK_DIR) install
	$(STRIP_COMMAND) `ls $(SAMBA34_IPK_DIR)/opt/sbin/* | egrep -v 'mount.smbfs'`
	$(STRIP_COMMAND) `ls $(SAMBA34_IPK_DIR)/opt/bin/* | egrep -v 'findsmb|smbtar'`
	cd $(SAMBA34_BUILD_DIR)/source3/bin/; for f in lib*.so.[01]; \
		do cp -a $$f $(SAMBA34_IPK_DIR)/opt/lib/$$f; done
	$(STRIP_COMMAND) `find $(SAMBA34_IPK_DIR)/opt/lib -name '*.so'`
	install -d $(SAMBA34_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SAMBA34_SOURCE_DIR)/rc.samba $(SAMBA34_IPK_DIR)/opt/etc/init.d/S08samba
	$(MAKE) $(SAMBA34_IPK_DIR)/CONTROL/control
	install -m 644 $(SAMBA34_SOURCE_DIR)/postinst $(SAMBA34_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA34_SOURCE_DIR)/preinst $(SAMBA34_IPK_DIR)/CONTROL/preinst
ifeq ($(OPTWARE_TARGET), $(filter ds101 ds101g, $(OPTWARE_TARGET)))
	install -m 644 $(SAMBA34_SOURCE_DIR)/postinst.$(OPTWARE_TARGET) $(SAMBA34_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA34_SOURCE_DIR)/preinst.$(OPTWARE_TARGET) $(SAMBA34_IPK_DIR)/CONTROL/preinst
endif
	echo $(SAMBA34_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA34_IPK_DIR)/CONTROL/conffiles
	# samba3-dev
	install -d $(SAMBA34-DEV_IPK_DIR)/opt
	mv $(SAMBA34_IPK_DIR)/opt/include $(SAMBA34-DEV_IPK_DIR)/opt/
	# samba3-swat
	install -d $(SAMBA34-SWAT_IPK_DIR)/opt/share $(SAMBA34-SWAT_IPK_DIR)/opt/sbin
	mv $(SAMBA34_IPK_DIR)/opt/share/swat $(SAMBA34-SWAT_IPK_DIR)/opt/share/
	mv $(SAMBA34_IPK_DIR)/opt/sbin/swat $(SAMBA34-SWAT_IPK_DIR)/opt/sbin/
	install -d $(SAMBA34-SWAT_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(SAMBA34_SOURCE_DIR)/swat $(SAMBA34-SWAT_IPK_DIR)/opt/etc/xinetd.d/swat
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA34_IPK_DIR)
	$(MAKE) $(SAMBA34-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA34-DEV_IPK_DIR)
	$(MAKE) $(SAMBA34-SWAT_IPK_DIR)/CONTROL/control
	echo $(SAMBA34-SWAT_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA34-SWAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA34-SWAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SAMBA34_IPK_DIR) $(SAMBA34-DEV_IPK_DIR) $(SAMBA34-SWAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
samba34-ipk: $(SAMBA34_IPK) $(SAMBA34-DEV_IPK) $(SAMBA34-SWAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
samba34-clean:
	-$(MAKE) -C $(SAMBA34_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
samba34-dirclean:
	rm -rf $(BUILD_DIR)/$(SAMBA34_DIR) $(SAMBA34_BUILD_DIR) $(SAMBA34_IPK_DIR) $(SAMBA34_IPK)

#
# Some sanity check for the package.
#
samba34-check: $(SAMBA34_IPK) $(SAMBA34-DEV_IPK) $(SAMBA34-SWAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
