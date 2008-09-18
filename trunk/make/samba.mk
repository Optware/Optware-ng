###########################################################
#
# samba
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
SAMBA_SITE=http://www.samba.org/samba/ftp/stable
ifneq ($(OPTWARE_TARGET),wl500g)
SAMBA_VERSION=3.2.3
SAMBA_IPK_VERSION=3
else
SAMBA_VERSION=3.0.14a
SAMBA_IPK_VERSION=5
endif
SAMBA_SOURCE=samba-$(SAMBA_VERSION).tar.gz
SAMBA_DIR=samba-$(SAMBA_VERSION)
SAMBA_UNZIP=zcat
SAMBA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SAMBA_DESCRIPTION=Samba suite provides file and print services to SMB/CIFS clients.
SAMBA_SECTION=net
SAMBA_PRIORITY=optional
SAMBA_DEPENDS=popt, readline
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA_DEPENDS +=, openldap-libs
endif
ifeq ($(OPTWARE_TARGET), $(filter nslu2, $(OPTWARE_TARGET)))
SAMBA_DEPENDS +=, gconv-modules
endif
SAMBA_SUGGESTS=cups
SAMBA_CONFLICTS=samba2

#
# SAMBA_CONFFILES should be a list of user-editable files
SAMBA_CONFFILES=/opt/etc/init.d/S08samba
SAMBA3-SWAT_CONFFILES=/opt/etc/xinetd.d/swat

#
# SAMBA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(OPTWARE_TARGET),wl500g)
SAMBA_PATCHES=$(SAMBA_SOURCE_DIR)/configure.in.patch
else
SAMBA_PATCHES=$(SAMBA_SOURCE_DIR)/configure.in-wl500g.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SAMBA_CPPFLAGS=
SAMBA_LDFLAGS=

#
# SAMBA_BUILD_DIR is the directory in which the build is done.
# SAMBA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SAMBA_IPK_DIR is the directory in which the ipk is built.
# SAMBA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SAMBA_BUILD_DIR=$(BUILD_DIR)/samba
SAMBA_SOURCE_DIR=$(SOURCE_DIR)/samba

SAMBA_IPK_DIR=$(BUILD_DIR)/samba-$(SAMBA_VERSION)-ipk
SAMBA_IPK=$(BUILD_DIR)/samba_$(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA3-DEV_IPK_DIR=$(BUILD_DIR)/samba3-dev-$(SAMBA_VERSION)-ipk
SAMBA3-DEV_IPK=$(BUILD_DIR)/samba3-dev_$(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)_$(TARGET_ARCH).ipk
SAMBA3-SWAT_IPK_DIR=$(BUILD_DIR)/samba3-swat-$(SAMBA_VERSION)-ipk
SAMBA3-SWAT_IPK=$(BUILD_DIR)/samba3-swat_$(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)_$(TARGET_ARCH).ipk

SAMBA_BUILD_DIR_SRC=$(SAMBA_BUILD_DIR)/source

SAMBA_INST_DIR=/opt
SAMBA_EXEC_PREFIX=$(SAMBA_INST_DIR)
SAMBA_BIN_DIR=$(SAMBA_INST_DIR)/bin
SAMBA_SBIN_DIR=$(SAMBA_INST_DIR)/sbin
SAMBA_LIBEXEC_DIR=$(SAMBA_INST_DIR)/libexec
SAMBA_DATA_DIR=$(SAMBA_INST_DIR)/share/samba
SAMBA_SYSCONF_DIR=$(SAMBA_INST_DIR)/etc/samba
SAMBA_SHAREDSTATE_DIR=$(SAMBA_INST_DIR)/com/samba
SAMBA_LOCALSTATE_DIR=$(SAMBA_INST_DIR)/var/samba
SAMBA_LIB_DIR=$(SAMBA_INST_DIR)/lib
SAMBA_INCLUDE_DIR=$(SAMBA_INST_DIR)/include
SAMBA_INFO_DIR=$(SAMBA_INST_DIR)/info
SAMBA_MAN_DIR=$(SAMBA_INST_DIR)/man
SAMBA_SWAT_DIR=$(SAMBA_INST_DIR)/share/swat

ifneq ($(HOSTCC), $(TARGET_CC))
SAMBA_CROSS_ENVS=\
		LOOK_DIRS=$(STAGING_PREFIX) \
		SMB_BUILD_CC_NEGATIVE_ENUM_VALUES=yes \
		linux_getgrouplist_ok=no \
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
		samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
		fu_cv_sys_stat_statvfs64=yes
  ifeq (no, $(IPV6))
SAMBA_CROSS_ENVS += libreplace_cv_HAVE_IPV6=no
  endif
  ifeq ($(OPTWARE_TARGET), $(filter oleg, $(OPTWARE_TARGET)))
SAMBA_CROSS_ENVS += ac_cv_header_linux_dqblk_xfs_h=no
  endif
endif
ifeq (openldap, $(filter openldap, $(PACKAGES)))
SAMBA_CONFIG_ARGS=--with-ldap
endif

.PHONY: samba-source samba-unpack samba samba-stage samba-ipk samba-clean samba-dirclean samba-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SAMBA_SOURCE):
	$(WGET) -P $(@D) $(SAMBA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
samba-source: $(DL_DIR)/$(SAMBA_SOURCE) $(SAMBA_PATCHES)

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
$(SAMBA_BUILD_DIR)/.configured: $(DL_DIR)/$(SAMBA_SOURCE) $(SAMBA_PATCHES)
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage 
endif
	$(MAKE) cups-stage
	rm -rf $(BUILD_DIR)/$(SAMBA_DIR) $(@D)
	$(SAMBA_UNZIP) $(DL_DIR)/$(SAMBA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SAMBA_PATCHES) | patch -d $(BUILD_DIR)/$(SAMBA_DIR) -p1
	mv $(BUILD_DIR)/$(SAMBA_DIR) $(@D)
ifeq (3.0.14a, $(SAMBA_VERSION))
	sed -i -e '/AC_TRY_RUN.*1.*5.*6.*7/s/;$$//' $(@D)/source/aclocal.m4
endif
	(cd $(@D)/source; ./autogen.sh )
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SAMBA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SAMBA_LDFLAGS)" \
		$(SAMBA_CROSS_ENVS) \
		source/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(SAMBA_INST_DIR) \
		--exec-prefix=$(SAMBA_INST_DIR) \
		--bindir=$(SAMBA_BIN_DIR) \
		--sbindir=$(SAMBA_SBIN_DIR) \
		--libexecdir=$(SAMBA_LIBEXEC_DIR) \
		--datadir=$(SAMBA_DATA_DIR) \
		--sysconfdir=$(SAMBA_SYSCONF_DIR) \
		--sharedstatedir=$(SAMBA_SHAREDSTATE_DIR) \
		--localstatedir=$(SAMBA_LOCALSTATE_DIR) \
		--libdir=$(SAMBA_LIB_DIR) \
		--includedir=$(SAMBA_INCLUDE_DIR) \
		--oldincludedir=$(SAMBA_INCLUDE_DIR) \
		--infodir=$(SAMBA_INFO_DIR) \
		--mandir=$(SAMBA_MAN_DIR) \
		--disable-pie \
		--with-privatedir=$(SAMBA_SYSCONF_DIR) \
		--with-lockdir=$(SAMBA_LOCALSTATE_DIR) \
		--with-piddir=$(SAMBA_LOCALSTATE_DIR) \
		--with-swatdir=$(SAMBA_SWAT_DIR) \
		--with-configdir=$(SAMBA_SYSCONF_DIR) \
		--with-logfilebase=$(SAMBA_LOCALSTATE_DIR) \
		--with-libdir=$(SAMBA_LIB_DIR) \
		--with-mandir=$(SAMBA_MAN_DIR) \
		--with-smbmount \
		--with-quotas \
		--with-krb5=no \
		$(SAMBA_CONFIG_ARGS) \
		--disable-nls \
	)
#	Remove Kerberos libs produced by broken configure
	sed -i -e 's/KRB5LIBS=.*/KRB5LIBS=/' $(@D)/Makefile
	touch $@

samba-unpack: $(SAMBA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SAMBA_BUILD_DIR)/.built: $(SAMBA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
samba: $(SAMBA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SAMBA_BUILD_DIR)/.staged: $(SAMBA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

samba-stage: $(SAMBA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/samba
#
$(SAMBA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: samba" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA_PRIORITY)" >>$@
	@echo "Section: $(SAMBA_SECTION)" >>$@
	@echo "Version: $(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA_SITE)/$(SAMBA_SOURCE)" >>$@
	@echo "Description: $(SAMBA_DESCRIPTION)" >>$@
	@echo "Depends: $(SAMBA_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA_CONFLICTS)" >>$@

$(SAMBA3-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: samba3-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA_PRIORITY)" >>$@
	@echo "Section: $(SAMBA_SECTION)" >>$@
	@echo "Version: $(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA_SITE)/$(SAMBA_SOURCE)" >>$@
	@echo "Description: development files for samba3" >>$@
	@echo "Depends: samba" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(SAMBA3-SWAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: samba3-swat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA_PRIORITY)" >>$@
	@echo "Section: $(SAMBA_SECTION)" >>$@
	@echo "Version: $(SAMBA_VERSION)-$(SAMBA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA_SITE)/$(SAMBA_SOURCE)" >>$@
	@echo "Description: the Samba Web Admin Tool for samba3" >>$@
	@echo "Depends: samba, xinetd" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SAMBA_IPK_DIR)/opt/sbin or $(SAMBA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SAMBA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SAMBA_IPK_DIR)/opt/etc/samba/...
# Documentation files should be installed in $(SAMBA_IPK_DIR)/opt/doc/samba/...
# Daemon startup scripts should be installed in $(SAMBA_IPK_DIR)/opt/etc/init.d/S??samba
#
# You may need to patch your application to make it use these locations.
#
$(SAMBA_IPK) $(SAMBA3-DEV_IPK) $(SAMBA3-SWAT_IPK): $(SAMBA_BUILD_DIR)/.built
	rm -rf $(SAMBA_IPK_DIR) $(BUILD_DIR)/samba_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA3-DEV_IPK_DIR) $(BUILD_DIR)/samba3-dev_*_$(TARGET_ARCH).ipk
	rm -rf $(SAMBA3-SWAT_IPK_DIR) $(BUILD_DIR)/samba3-swat_*_$(TARGET_ARCH).ipk
	# samba3
	$(MAKE) -C $(SAMBA_BUILD_DIR) DESTDIR=$(SAMBA_IPK_DIR) install
	$(STRIP_COMMAND) `ls $(SAMBA_IPK_DIR)/opt/sbin/* | egrep -v 'mount.smbfs'`
	$(STRIP_COMMAND) `ls $(SAMBA_IPK_DIR)/opt/bin/* | egrep -v 'findsmb|smbtar'`
	cd $(SAMBA_BUILD_DIR)/bin/; for f in lib*.so.[01]; \
		do cp -a $$f $(SAMBA_IPK_DIR)/opt/lib/$$f; done
	$(STRIP_COMMAND) `find $(SAMBA_IPK_DIR)/opt/lib -name '*.so'`
	install -d $(SAMBA_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SAMBA_SOURCE_DIR)/rc.samba $(SAMBA_IPK_DIR)/opt/etc/init.d/S08samba
	$(MAKE) $(SAMBA_IPK_DIR)/CONTROL/control
	install -m 644 $(SAMBA_SOURCE_DIR)/postinst $(SAMBA_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA_SOURCE_DIR)/preinst $(SAMBA_IPK_DIR)/CONTROL/preinst
ifeq ($(OPTWARE_TARGET), $(filter ds101 ds101g, $(OPTWARE_TARGET)))
	install -m 644 $(SAMBA_SOURCE_DIR)/postinst.$(OPTWARE_TARGET) $(SAMBA_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA_SOURCE_DIR)/preinst.$(OPTWARE_TARGET) $(SAMBA_IPK_DIR)/CONTROL/preinst
endif
	echo $(SAMBA_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA_IPK_DIR)/CONTROL/conffiles
	# samba3-dev
	install -d $(SAMBA3-DEV_IPK_DIR)/opt
	mv $(SAMBA_IPK_DIR)/opt/include $(SAMBA3-DEV_IPK_DIR)/opt/
	# samba3-swat
	install -d $(SAMBA3-SWAT_IPK_DIR)/opt/share $(SAMBA3-SWAT_IPK_DIR)/opt/sbin
	mv $(SAMBA_IPK_DIR)/opt/share/swat $(SAMBA3-SWAT_IPK_DIR)/opt/share/
	mv $(SAMBA_IPK_DIR)/opt/sbin/swat $(SAMBA3-SWAT_IPK_DIR)/opt/sbin/
	install -d $(SAMBA3-SWAT_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(SAMBA_SOURCE_DIR)/swat $(SAMBA3-SWAT_IPK_DIR)/opt/etc/xinetd.d/swat
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA_IPK_DIR)
	$(MAKE) $(SAMBA3-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA3-DEV_IPK_DIR)
	$(MAKE) $(SAMBA3-SWAT_IPK_DIR)/CONTROL/control
	echo $(SAMBA3-SWAT_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA3-SWAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA3-SWAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
samba-ipk: $(SAMBA_IPK) $(SAMBA3-DEV_IPK) $(SAMBA3-SWAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
samba-clean:
	-$(MAKE) -C $(SAMBA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
samba-dirclean:
	rm -rf $(BUILD_DIR)/$(SAMBA_DIR) $(SAMBA_BUILD_DIR) $(SAMBA_IPK_DIR) $(SAMBA_IPK)

#
# Some sanity check for the package.
#
samba-check: $(SAMBA_IPK) $(SAMBA3-DEV_IPK) $(SAMBA3-SWAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SAMBA_IPK) $(SAMBA3-SWAT_IPK)
