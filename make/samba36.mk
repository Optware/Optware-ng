###########################################################
#
# samba36
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
SAMBA36_SITE=http://www.samba.org/samba/ftp/stable
SAMBA36_VERSION ?= 3.6.22
SAMBA36_IPK_VERSION ?= 1
SAMBA36_SOURCE=samba-$(SAMBA36_VERSION).tar.gz
SAMBA36_DIR=samba-$(SAMBA36_VERSION)
SAMBA36_UNZIP=zcat
SAMBA36_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SAMBA36_DESCRIPTION=Samba suite provides file and print services to SMB/CIFS clients. This is a newer version.
SAMBA36_SECTION=net
SAMBA36_PRIORITY=optional
SAMBA36_DEPENDS=avahi, popt, readline, zlib, e2fsprogs
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA36_DEPENDS +=, openldap-libs
endif
ifeq (glibc, $(LIBC_STYLE))
SAMBA36_DEPENDS +=, gconv-modules
endif
SAMBA36-DEV_DEPENDS=samba36
SAMBA36-SWAT_DEPENDS=samba36, xinetd
SAMBA36_SUGGESTS=cups
SAMBA36-DEV_SUGGESTS=
SAMBA36-SWAT_SUGGESTS=
SAMBA36_CONFLICTS=samba2, samba, samba34,samba35
SAMBA36-DEV_CONFLICTS=samba2, samba3-dev,samba34-dev,samba35-dev
SAMBA36-SWAT_CONFLICTS=samba2, samba3-swat, samba34-swat,samba35-swat
SAMBA36_ADDITIONAL_CODEPAGES=CP866

#
# SAMBA36_CONFFILES should be a list of user-editable files
SAMBA36_CONFFILES=/opt/etc/init.d/S08samba
SAMBA36-SWAT_CONFFILES=/opt/etc/xinetd.d/swat

#
# SAMBA36_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SAMBA36_PATCHES=\
$(SAMBA36_SOURCE_DIR)/configure.in.patch \
$(SAMBA36_SOURCE_DIR)/IPV6_V6ONLY.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SAMBA36_CPPFLAGS= -I$(STAGING_INCLUDE_DIR)/etc
SAMBA36_LDFLAGS=

#
# SAMBA36_BUILD_DIR is the directory in which the build is done.
# SAMBA36_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SAMBA36_IPK_DIR is the directory in which the ipk is built.
# SAMBA36_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SAMBA36_BUILD_DIR=$(BUILD_DIR)/samba36
SAMBA36_SOURCE_DIR=$(SOURCE_DIR)/samba36

SAMBA36_IPK_DIR=$(BUILD_DIR)/samba36-$(SAMBA36_VERSION)-ipk
SAMBA36_IPK=$(BUILD_DIR)/samba36_$(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA36-DEV_IPK_DIR=$(BUILD_DIR)/samba36-dev-$(SAMBA36_VERSION)-ipk
SAMBA36-DEV_IPK=$(BUILD_DIR)/samba36-dev_$(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA36-SWAT_IPK_DIR=$(BUILD_DIR)/samba36-swat-$(SAMBA36_VERSION)-ipk
SAMBA36-SWAT_IPK=$(BUILD_DIR)/samba36-swat_$(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)_$(TARGET_ARCH).ipk

SAMBA36_BUILD_DIR_SRC=$(SAMBA36_BUILD_DIR)/source3

SAMBA36_INST_DIR=/opt
SAMBA36_EXEC_PREFIX=$(SAMBA36_INST_DIR)
SAMBA36_BIN_DIR=$(SAMBA36_INST_DIR)/bin
SAMBA36_SBIN_DIR=$(SAMBA36_INST_DIR)/sbin
SAMBA36_LIBEXEC_DIR=$(SAMBA36_INST_DIR)/libexec
SAMBA36_DATA_DIR=$(SAMBA36_INST_DIR)/share/samba
SAMBA36_SYSCONF_DIR=$(SAMBA36_INST_DIR)/etc/samba
SAMBA36_SHAREDSTATE_DIR=$(SAMBA36_INST_DIR)/com/samba
SAMBA36_LOCALSTATE_DIR=$(SAMBA36_INST_DIR)/var/samba
SAMBA36_LIB_DIR=$(SAMBA36_INST_DIR)/lib
SAMBA36_INCLUDE_DIR=$(SAMBA36_INST_DIR)/include
SAMBA36_INFO_DIR=$(SAMBA36_INST_DIR)/info
SAMBA36_MAN_DIR=$(SAMBA36_INST_DIR)/man
SAMBA36_SWAT_DIR=$(SAMBA36_INST_DIR)/share/swat

ifeq (uclibc, $(LIBC_STYLE))
SAMBA36_LINUX_GETGROUPLIST_OK=no
else
SAMBA36_LINUX_GETGROUPLIST_OK=yes
endif

ifneq ($(HOSTCC), $(TARGET_CC))
SAMBA36_CROSS_ENVS=\
		LINUX_LFS_SUPPORT=yes \
		libreplace_cv_READDIR_GETDIRENTRIES=no \
		libreplace_cv_READDIR_GETDENTS=no \
		libreplace_cv_HAVE_GETADDRINFO=no \
		samba_cv_HAVE_WRFILE_KEYTAB=no \
		samba_cv_has_proc_sys_kernel_core_pattern=yes \
		smb_krb5_cv_enctype_to_string_takes_krb5_context_arg=no \
		smb_krb5_cv_enctype_to_string_takes_size_t_arg=no \
		LOOK_DIRS=$(STAGING_PREFIX) \
		samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
		samba_cv_HAVE_BROKEN_GETGROUPS=$(SAMBA36_LINUX_GETGROUPLIST_OK) \
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
SAMBA36_CROSS_ENVS += libreplace_cv_HAVE_IPV6=no
  endif
  ifeq ($(OPTWARE_TARGET), $(filter oleg, $(OPTWARE_TARGET)))
SAMBA36_CROSS_ENVS += ac_cv_header_linux_dqblk_xfs_h=no
  endif
endif

ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA36_CONFIG_ARGS=--with-ldap
endif

# cifsmount does not work for some plattforms , missing fstab.h, allow override, should  patched now 
SAMBA36_CONFIG_ARGS_EXTRA ?= --with-cifsmount --with-cifsumount
SAMBA36_CONFIG_ARGS += $(SAMBA36_CONFIG_ARGS_EXTRA)

.PHONY: samba36-source samba36-unpack samba36 samba36-stage samba36-ipk samba36-clean samba36-dirclean samba36-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SAMBA36_SOURCE):
	$(WGET) -P $(@D) $(SAMBA36_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
samba36-source: $(DL_DIR)/$(SAMBA36_SOURCE) $(SAMBA36_PATCHES)

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
$(SAMBA36_BUILD_DIR)/.configured: $(DL_DIR)/$(SAMBA36_SOURCE) $(SAMBA36_PATCHES) make/samba36.mk
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage 
endif
	$(MAKE) avahi-stage cups-stage popt-stage readline-stage zlib-stage e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(SAMBA36_DIR) $(@D)
	$(SAMBA36_UNZIP) $(DL_DIR)/$(SAMBA36_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(SAMBA36_DIR) $(@D)
	cat $(SAMBA36_PATCHES) | patch -d $(@D) -p1
	(cd $(@D)/source3/; ./autogen.sh)
	(cd $(@D)/source3/; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SAMBA36_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SAMBA36_LDFLAGS)" \
		$(SAMBA36_CROSS_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SAMBA36_INST_DIR) \
		--exec-prefix=$(SAMBA36_INST_DIR) \
		--bindir=$(SAMBA36_BIN_DIR) \
		--sbindir=$(SAMBA36_SBIN_DIR) \
		--libexecdir=$(SAMBA36_LIBEXEC_DIR) \
		--datadir=$(SAMBA36_DATA_DIR) \
		--sysconfdir=$(SAMBA36_SYSCONF_DIR) \
		--sharedstatedir=$(SAMBA36_SHAREDSTATE_DIR) \
		--localstatedir=$(SAMBA36_LOCALSTATE_DIR) \
		--libdir=$(SAMBA36_LIB_DIR) \
		--includedir=$(SAMBA36_INCLUDE_DIR) \
		--oldincludedir=$(SAMBA36_INCLUDE_DIR) \
		--infodir=$(SAMBA36_INFO_DIR) \
		--mandir=$(SAMBA36_MAN_DIR) \
		--disable-pie \
		--with-privatedir=$(SAMBA36_SYSCONF_DIR) \
		--with-lockdir=$(SAMBA36_LOCALSTATE_DIR) \
		--with-piddir=$(SAMBA36_LOCALSTATE_DIR) \
		--with-swatdir=$(SAMBA36_SWAT_DIR) \
		--with-configdir=$(SAMBA36_SYSCONF_DIR) \
		--with-logfilebase=$(SAMBA36_LOCALSTATE_DIR) \
		--with-libdir=$(SAMBA36_LIB_DIR) \
		--with-mandir=$(SAMBA36_MAN_DIR) \
		--with-smbmount \
		--without-quotas \
		--without-sys-quotas\
		--with-krb5=no \
		$(SAMBA36_CONFIG_ARGS) \
		--disable-nls \
	)
#	Remove Kerberos libs produced by broken configure
#	sed -i -e 's/KRB5LIBS=.*/KRB5LIBS=/' \
#	 -e 's/-lgssapi_krb5\|-lkrb5\|-lk5crypto\|-lcom_err\|-lgnutls//g' \
#	 -e '/^TERMLIBS=/s/$$/ -ltermcap/g' \
		$(@D)/source3/Makefile
### additional codepages
	CODEPAGES="$(SAMBA36_ADDITIONAL_CODEPAGES)" SAMBA36_SOURCE_DIR=$(SAMBA36_SOURCE_DIR) SAMBA36_BUILD_DIR=$(SAMBA36_BUILD_DIR) /bin/sh $(SAMBA36_SOURCE_DIR)/addcodepages.sh
	touch $@

samba36-unpack: $(SAMBA36_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SAMBA36_BUILD_DIR)/.built: $(SAMBA36_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/source3/
	touch $@

#
# This is the build convenience target.
#
samba36: $(SAMBA36_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SAMBA36_BUILD_DIR)/.staged: $(SAMBA36_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/source3/ DESTDIR=$(STAGING_DIR) install
	touch $@

samba36-stage: $(SAMBA36_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/samba
#
$(SAMBA36_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba36" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA36_PRIORITY)" >>$@
	@echo "Section: $(SAMBA36_SECTION)" >>$@
	@echo "Version: $(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA36_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA36_SITE)/$(SAMBA36_SOURCE)" >>$@
	@echo "Description: $(SAMBA36_DESCRIPTION)" >>$@
	@echo "Depends: $(SAMBA36_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA36_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA36_CONFLICTS)" >>$@

$(SAMBA36-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba36-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA36_PRIORITY)" >>$@
	@echo "Section: $(SAMBA36_SECTION)" >>$@
	@echo "Version: $(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA36_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA36_SITE)/$(SAMBA36_SOURCE)" >>$@
	@echo "Description: development files for samba36" >>$@
	@echo "Depends: $(SAMBA36-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA36-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA36-DEV_CONFLICTS)" >>$@

$(SAMBA36-SWAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)/
	@rm -f $@
	@echo "Package: samba36-swat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA36_PRIORITY)" >>$@
	@echo "Section: $(SAMBA36_SECTION)" >>$@
	@echo "Version: $(SAMBA36_VERSION)-$(SAMBA36_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA36_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA36_SITE)/$(SAMBA36_SOURCE)" >>$@
	@echo "Description: the Samba Web Admin Tool for samba36" >>$@
	@echo "Depends: $(SAMBA36-SWAT_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA36-SWAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA36-SWAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SAMBA36_IPK_DIR)/opt/sbin or $(SAMBA36_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SAMBA36_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SAMBA36_IPK_DIR)/opt/etc/samba/...
# Documentation files should be installed in $(SAMBA36_IPK_DIR)/opt/doc/samba/...
# Daemon startup scripts should be installed in $(SAMBA36_IPK_DIR)/opt/etc/init.d/S??samba
#
# You may need to patch your application to make it use these locations.
#
$(SAMBA36_IPK) $(SAMBA36-DEV_IPK) $(SAMBA36-SWAT_IPK): $(SAMBA36_BUILD_DIR)/.built
	rm -rf $(SAMBA36_IPK_DIR) $(BUILD_DIR)/SAMBA36_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA36-DEV_IPK_DIR) $(BUILD_DIR)/samba36-dev_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA36-SWAT_IPK_DIR) $(BUILD_DIR)/samba36-swat_*_$(TARGET_ARCH).ipk
	# samba3
	$(MAKE) -C $(SAMBA36_BUILD_DIR)/source3/ DESTDIR=$(SAMBA36_IPK_DIR) install
	$(STRIP_COMMAND) `ls $(SAMBA36_IPK_DIR)/opt/sbin/* | egrep -v 'mount.smbfs'`
	$(STRIP_COMMAND) `ls $(SAMBA36_IPK_DIR)/opt/bin/* | egrep -v 'findsmb|smbtar'`
	cd $(SAMBA36_BUILD_DIR)/source3/bin/; for f in lib*.so.[01]; \
		do cp -a $$f $(SAMBA36_IPK_DIR)/opt/lib/$$f; done
	$(STRIP_COMMAND) `find $(SAMBA36_IPK_DIR)/opt/lib -name '*.so'`
	install -d $(SAMBA36_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SAMBA36_SOURCE_DIR)/rc.samba $(SAMBA36_IPK_DIR)/opt/etc/init.d/S08samba
	$(MAKE) $(SAMBA36_IPK_DIR)/CONTROL/control
	install -m 644 $(SAMBA36_SOURCE_DIR)/postinst $(SAMBA36_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA36_SOURCE_DIR)/preinst $(SAMBA36_IPK_DIR)/CONTROL/preinst
	echo $(SAMBA36_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA36_IPK_DIR)/CONTROL/conffiles
	# samba3-dev
	install -d $(SAMBA36-DEV_IPK_DIR)/opt
	mv $(SAMBA36_IPK_DIR)/opt/include $(SAMBA36-DEV_IPK_DIR)/opt/
	# samba3-swat
	install -d $(SAMBA36-SWAT_IPK_DIR)/opt/share $(SAMBA36-SWAT_IPK_DIR)/opt/sbin
	mv $(SAMBA36_IPK_DIR)/opt/share/swat $(SAMBA36-SWAT_IPK_DIR)/opt/share/
	mv $(SAMBA36_IPK_DIR)/opt/sbin/swat $(SAMBA36-SWAT_IPK_DIR)/opt/sbin/
	install -d $(SAMBA36-SWAT_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(SAMBA36_SOURCE_DIR)/swat $(SAMBA36-SWAT_IPK_DIR)/opt/etc/xinetd.d/swat
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA36_IPK_DIR)
	$(MAKE) $(SAMBA36-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA36-DEV_IPK_DIR)
	$(MAKE) $(SAMBA36-SWAT_IPK_DIR)/CONTROL/control
	echo $(SAMBA36-SWAT_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA36-SWAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA36-SWAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SAMBA36_IPK_DIR) $(SAMBA36-DEV_IPK_DIR) $(SAMBA36-SWAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
samba36-ipk: $(SAMBA36_IPK) $(SAMBA36-DEV_IPK) $(SAMBA36-SWAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
samba36-clean:
	-$(MAKE) -C $(SAMBA36_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
samba36-dirclean:
	rm -rf $(BUILD_DIR)/$(SAMBA36_DIR) $(SAMBA36_BUILD_DIR) $(SAMBA36_IPK_DIR) $(SAMBA36_IPK)

#
# Some sanity check for the package.
#
samba36-check: $(SAMBA36_IPK) $(SAMBA36-DEV_IPK) $(SAMBA36-SWAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
