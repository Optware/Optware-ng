###########################################################
#
# samba35
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
SAMBA35_SITE=http://www.samba.org/samba/ftp/stable
SAMBA35_VERSION ?= 3.5.16
SAMBA35_IPK_VERSION ?= 1
SAMBA35_SOURCE=samba-$(SAMBA35_VERSION).tar.gz
SAMBA35_DIR=samba-$(SAMBA35_VERSION)
SAMBA35_UNZIP=zcat
SAMBA35_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SAMBA35_DESCRIPTION=Samba suite provides file and print services to SMB/CIFS clients. This is a newer version.
SAMBA35_SECTION=net
SAMBA35_PRIORITY=optional
SAMBA35_DEPENDS=avahi, popt, readline, zlib, e2fsprogs
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA35_DEPENDS +=, openldap-libs
endif
ifeq (glibc, $(LIBC_STYLE))
SAMBA35_DEPENDS +=, gconv-modules
endif
SAMBA35-DEV_DEPENDS=samba35
SAMBA35-SWAT_DEPENDS=samba35, xinetd
SAMBA35_SUGGESTS=cups
SAMBA35-DEV_SUGGESTS=
SAMBA35-SWAT_SUGGESTS=
SAMBA35_CONFLICTS=samba2, samba, samba34
SAMBA35-DEV_CONFLICTS=samba2, samba3-dev,samba34-dev
SAMBA35-SWAT_CONFLICTS=samba2, samba3-swat, samba34-swat
SAMBA35_ADDITIONAL_CODEPAGES=CP866

#
# SAMBA35_CONFFILES should be a list of user-editable files
SAMBA35_CONFFILES=/opt/etc/init.d/S08samba
SAMBA35-SWAT_CONFFILES=/opt/etc/xinetd.d/swat

#
# SAMBA35_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SAMBA35_PATCHES=\
$(SAMBA35_SOURCE_DIR)/configure.in.patch \
$(SAMBA35_SOURCE_DIR)/mtab.patch \
$(SAMBA35_SOURCE_DIR)/IPV6_V6ONLY.patch \

ifeq ($(OPTWARE_TARGET), $(filter ddwrt dns323 gumstix1151 mbwe-bluering oleg openwrt-brcm24 openwrt-ixp4xx wdtv, $(OPTWARE_TARGET)))
SAMBA35_PATCHES+=$(SAMBA35_SOURCE_DIR)/mount.cifs.c.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SAMBA35_CPPFLAGS= -I$(STAGING_INCLUDE_DIR)/et
SAMBA35_LDFLAGS=

#
# SAMBA35_BUILD_DIR is the directory in which the build is done.
# SAMBA35_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SAMBA35_IPK_DIR is the directory in which the ipk is built.
# SAMBA35_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SAMBA35_BUILD_DIR=$(BUILD_DIR)/samba35
SAMBA35_SOURCE_DIR=$(SOURCE_DIR)/samba35

SAMBA35_IPK_DIR=$(BUILD_DIR)/samba35-$(SAMBA35_VERSION)-ipk
SAMBA35_IPK=$(BUILD_DIR)/samba35_$(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA35-DEV_IPK_DIR=$(BUILD_DIR)/samba35-dev-$(SAMBA35_VERSION)-ipk
SAMBA35-DEV_IPK=$(BUILD_DIR)/samba35-dev_$(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA35-SWAT_IPK_DIR=$(BUILD_DIR)/samba35-swat-$(SAMBA35_VERSION)-ipk
SAMBA35-SWAT_IPK=$(BUILD_DIR)/samba35-swat_$(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)_$(TARGET_ARCH).ipk

SAMBA35_BUILD_DIR_SRC=$(SAMBA35_BUILD_DIR)/source3

SAMBA35_INST_DIR=/opt
SAMBA35_EXEC_PREFIX=$(SAMBA35_INST_DIR)
SAMBA35_BIN_DIR=$(SAMBA35_INST_DIR)/bin
SAMBA35_SBIN_DIR=$(SAMBA35_INST_DIR)/sbin
SAMBA35_LIBEXEC_DIR=$(SAMBA35_INST_DIR)/libexec
SAMBA35_DATA_DIR=$(SAMBA35_INST_DIR)/share/samba
SAMBA35_SYSCONF_DIR=$(SAMBA35_INST_DIR)/etc/samba
SAMBA35_SHAREDSTATE_DIR=$(SAMBA35_INST_DIR)/com/samba
SAMBA35_LOCALSTATE_DIR=$(SAMBA35_INST_DIR)/var/samba
SAMBA35_LIB_DIR=$(SAMBA35_INST_DIR)/lib
SAMBA35_INCLUDE_DIR=$(SAMBA35_INST_DIR)/include
SAMBA35_INFO_DIR=$(SAMBA35_INST_DIR)/info
SAMBA35_MAN_DIR=$(SAMBA35_INST_DIR)/man
SAMBA35_SWAT_DIR=$(SAMBA35_INST_DIR)/share/swat

ifeq (uclibc, $(LIBC_STYLE))
SAMBA35_LINUX_GETGROUPLIST_OK=no
else
SAMBA35_LINUX_GETGROUPLIST_OK=yes
endif

ifneq ($(HOSTCC), $(TARGET_CC))
SAMBA35_CROSS_ENVS=\
		LINUX_LFS_SUPPORT=yes \
		libreplace_cv_READDIR_GETDIRENTRIES=no \
		libreplace_cv_READDIR_GETDENTS=no \
		samba_cv_HAVE_WRFILE_KEYTAB=no \
		smb_krb5_cv_enctype_to_string_takes_krb5_context_arg=no \
		smb_krb5_cv_enctype_to_string_takes_size_t_arg=no \
		LOOK_DIRS=$(STAGING_PREFIX) \
		samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
		samba_cv_HAVE_BROKEN_GETGROUPS=$(SAMBA35_LINUX_GETGROUPLIST_OK) \
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
SAMBA35_CROSS_ENVS += libreplace_cv_HAVE_IPV6=no
  endif
  ifeq ($(OPTWARE_TARGET), $(filter oleg, $(OPTWARE_TARGET)))
SAMBA35_CROSS_ENVS += ac_cv_header_linux_dqblk_xfs_h=no
  endif
endif

ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA35_CONFIG_ARGS=--with-ldap
endif

# cifsmount does not work for some plattforms , missing fstab.h, allow override, should  patched now 
SAMBA35_CONFIG_ARGS_EXTRA ?= --with-cifsmount --with-cifsumount
SAMBA35_CONFIG_ARGS += $(SAMBA35_CONFIG_ARGS_EXTRA)

.PHONY: samba35-source samba35-unpack samba35 samba35-stage samba35-ipk samba35-clean samba35-dirclean samba35-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SAMBA35_SOURCE):
	$(WGET) -P $(@D) $(SAMBA35_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
samba35-source: $(DL_DIR)/$(SAMBA35_SOURCE) $(SAMBA35_PATCHES)

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
$(SAMBA35_BUILD_DIR)/.configured: $(DL_DIR)/$(SAMBA35_SOURCE) $(SAMBA35_PATCHES) make/samba35.mk
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage 
endif
	$(MAKE) avahi-stage cups-stage popt-stage readline-stage zlib-stage e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(SAMBA35_DIR) $(@D)
	$(SAMBA35_UNZIP) $(DL_DIR)/$(SAMBA35_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SAMBA35_PATCHES) | patch -d $(BUILD_DIR)/$(SAMBA35_DIR) -p1
	mv $(BUILD_DIR)/$(SAMBA35_DIR) $(@D)
ifeq (3.0.14a, $(SAMBA35_VERSION))
	sed -i -e '/AC_TRY_RUN.*1.*5.*6.*7/s/;$$//' $(@D)/source/aclocal.m4
endif
	(cd $(@D)/source3/; ./autogen.sh)
	(cd $(@D)/source3/; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SAMBA35_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SAMBA35_LDFLAGS)" \
		$(SAMBA35_CROSS_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SAMBA35_INST_DIR) \
		--exec-prefix=$(SAMBA35_INST_DIR) \
		--bindir=$(SAMBA35_BIN_DIR) \
		--sbindir=$(SAMBA35_SBIN_DIR) \
		--libexecdir=$(SAMBA35_LIBEXEC_DIR) \
		--datadir=$(SAMBA35_DATA_DIR) \
		--sysconfdir=$(SAMBA35_SYSCONF_DIR) \
		--sharedstatedir=$(SAMBA35_SHAREDSTATE_DIR) \
		--localstatedir=$(SAMBA35_LOCALSTATE_DIR) \
		--libdir=$(SAMBA35_LIB_DIR) \
		--includedir=$(SAMBA35_INCLUDE_DIR) \
		--oldincludedir=$(SAMBA35_INCLUDE_DIR) \
		--infodir=$(SAMBA35_INFO_DIR) \
		--mandir=$(SAMBA35_MAN_DIR) \
		--disable-pie \
		--with-privatedir=$(SAMBA35_SYSCONF_DIR) \
		--with-lockdir=$(SAMBA35_LOCALSTATE_DIR) \
		--with-piddir=$(SAMBA35_LOCALSTATE_DIR) \
		--with-swatdir=$(SAMBA35_SWAT_DIR) \
		--with-configdir=$(SAMBA35_SYSCONF_DIR) \
		--with-logfilebase=$(SAMBA35_LOCALSTATE_DIR) \
		--with-libdir=$(SAMBA35_LIB_DIR) \
		--with-mandir=$(SAMBA35_MAN_DIR) \
		--with-smbmount \
		--with-quotas \
		--with-krb5=no \
		$(SAMBA35_CONFIG_ARGS) \
		--disable-nls \
	)
#	Remove Kerberos libs produced by broken configure
#	sed -i -e 's/KRB5LIBS=.*/KRB5LIBS=/' \
#	 -e 's/-lgssapi_krb5\|-lkrb5\|-lk5crypto\|-lcom_err\|-lgnutls//g' \
#	 -e '/^TERMLIBS=/s/$$/ -ltermcap/g' \
		$(@D)/source3/Makefile
### additional codepages
	CODEPAGES="$(SAMBA35_ADDITIONAL_CODEPAGES)" SAMBA35_SOURCE_DIR=$(SAMBA35_SOURCE_DIR) SAMBA35_BUILD_DIR=$(SAMBA35_BUILD_DIR) /bin/sh $(SAMBA35_SOURCE_DIR)/addcodepages.sh
	touch $@

samba35-unpack: $(SAMBA35_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SAMBA35_BUILD_DIR)/.built: $(SAMBA35_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/source3/
	touch $@

#
# This is the build convenience target.
#
samba35: $(SAMBA35_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SAMBA35_BUILD_DIR)/.staged: $(SAMBA35_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/source3/ DESTDIR=$(STAGING_DIR) install
	touch $@

samba35-stage: $(SAMBA35_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/samba
#
$(SAMBA35_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba35" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA35_PRIORITY)" >>$@
	@echo "Section: $(SAMBA35_SECTION)" >>$@
	@echo "Version: $(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA35_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA35_SITE)/$(SAMBA35_SOURCE)" >>$@
	@echo "Description: $(SAMBA35_DESCRIPTION)" >>$@
	@echo "Depends: $(SAMBA35_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA35_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA35_CONFLICTS)" >>$@

$(SAMBA35-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba35-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA35_PRIORITY)" >>$@
	@echo "Section: $(SAMBA35_SECTION)" >>$@
	@echo "Version: $(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA35_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA35_SITE)/$(SAMBA35_SOURCE)" >>$@
	@echo "Description: development files for samba35" >>$@
	@echo "Depends: $(SAMBA35-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA35-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA35-DEV_CONFLICTS)" >>$@

$(SAMBA35-SWAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba35-swat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA35_PRIORITY)" >>$@
	@echo "Section: $(SAMBA35_SECTION)" >>$@
	@echo "Version: $(SAMBA35_VERSION)-$(SAMBA35_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA35_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA35_SITE)/$(SAMBA35_SOURCE)" >>$@
	@echo "Description: the Samba Web Admin Tool for samba35" >>$@
	@echo "Depends: $(SAMBA35-SWAT_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA35-SWAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA35-SWAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SAMBA35_IPK_DIR)/opt/sbin or $(SAMBA35_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SAMBA35_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SAMBA35_IPK_DIR)/opt/etc/samba/...
# Documentation files should be installed in $(SAMBA35_IPK_DIR)/opt/doc/samba/...
# Daemon startup scripts should be installed in $(SAMBA35_IPK_DIR)/opt/etc/init.d/S??samba
#
# You may need to patch your application to make it use these locations.
#
$(SAMBA35_IPK) $(SAMBA35-DEV_IPK) $(SAMBA35-SWAT_IPK): $(SAMBA35_BUILD_DIR)/.built
	rm -rf $(SAMBA35_IPK_DIR) $(BUILD_DIR)/SAMBA35_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA35-DEV_IPK_DIR) $(BUILD_DIR)/samba35-dev_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA35-SWAT_IPK_DIR) $(BUILD_DIR)/samba35-swat_*_$(TARGET_ARCH).ipk
	# samba3
	$(MAKE) -C $(SAMBA35_BUILD_DIR)/source3/ DESTDIR=$(SAMBA35_IPK_DIR) install
	$(STRIP_COMMAND) `ls $(SAMBA35_IPK_DIR)/opt/sbin/* | egrep -v 'mount.smbfs'`
	$(STRIP_COMMAND) `ls $(SAMBA35_IPK_DIR)/opt/bin/* | egrep -v 'findsmb|smbtar'`
	cd $(SAMBA35_BUILD_DIR)/source3/bin/; for f in lib*.so.[01]; \
		do cp -a $$f $(SAMBA35_IPK_DIR)/opt/lib/$$f; done
	$(STRIP_COMMAND) `find $(SAMBA35_IPK_DIR)/opt/lib -name '*.so'`
	install -d $(SAMBA35_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SAMBA35_SOURCE_DIR)/rc.samba $(SAMBA35_IPK_DIR)/opt/etc/init.d/S08samba
	$(MAKE) $(SAMBA35_IPK_DIR)/CONTROL/control
	install -m 644 $(SAMBA35_SOURCE_DIR)/postinst $(SAMBA35_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA35_SOURCE_DIR)/preinst $(SAMBA35_IPK_DIR)/CONTROL/preinst
ifeq ($(OPTWARE_TARGET), $(filter ds101 ds101g, $(OPTWARE_TARGET)))
	install -m 644 $(SAMBA35_SOURCE_DIR)/postinst.$(OPTWARE_TARGET) $(SAMBA35_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA35_SOURCE_DIR)/preinst.$(OPTWARE_TARGET) $(SAMBA35_IPK_DIR)/CONTROL/preinst
endif
	echo $(SAMBA35_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA35_IPK_DIR)/CONTROL/conffiles
	# samba3-dev
	install -d $(SAMBA35-DEV_IPK_DIR)/opt
	mv $(SAMBA35_IPK_DIR)/opt/include $(SAMBA35-DEV_IPK_DIR)/opt/
	# samba3-swat
	install -d $(SAMBA35-SWAT_IPK_DIR)/opt/share $(SAMBA35-SWAT_IPK_DIR)/opt/sbin
	mv $(SAMBA35_IPK_DIR)/opt/share/swat $(SAMBA35-SWAT_IPK_DIR)/opt/share/
	mv $(SAMBA35_IPK_DIR)/opt/sbin/swat $(SAMBA35-SWAT_IPK_DIR)/opt/sbin/
	install -d $(SAMBA35-SWAT_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(SAMBA35_SOURCE_DIR)/swat $(SAMBA35-SWAT_IPK_DIR)/opt/etc/xinetd.d/swat
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA35_IPK_DIR)
	$(MAKE) $(SAMBA35-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA35-DEV_IPK_DIR)
	$(MAKE) $(SAMBA35-SWAT_IPK_DIR)/CONTROL/control
	echo $(SAMBA35-SWAT_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA35-SWAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA35-SWAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SAMBA35_IPK_DIR) $(SAMBA35-DEV_IPK_DIR) $(SAMBA35-SWAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
samba35-ipk: $(SAMBA35_IPK) $(SAMBA35-DEV_IPK) $(SAMBA35-SWAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
samba35-clean:
	-$(MAKE) -C $(SAMBA35_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
samba35-dirclean:
	rm -rf $(BUILD_DIR)/$(SAMBA35_DIR) $(SAMBA35_BUILD_DIR) $(SAMBA35_IPK_DIR) $(SAMBA35_IPK)

#
# Some sanity check for the package.
#
samba35-check: $(SAMBA35_IPK) $(SAMBA35-DEV_IPK) $(SAMBA35-SWAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
