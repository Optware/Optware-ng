###########################################################
#
# samba2
#
###########################################################

# You must replace "samba2" and "SAMBA2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SAMBA2_VERSION, SAMBA2_SITE and SAMBA2_SOURCE define
# the upstream location of the source code for the package.
# SAMBA2_DIR is the directory which is created when the source
# archive is unpacked.
# SAMBA2_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SAMBA2_SITE=http://www.samba.org/samba/ftp/stable
SAMBA2_VERSION=2.2.12
SAMBA2_IPK_VERSION=1
SAMBA2_SOURCE=samba-$(SAMBA2_VERSION).tar.gz
SAMBA2_DIR=samba-$(SAMBA2_VERSION)
SAMBA2_UNZIP=zcat
SAMBA2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SAMBA2_DESCRIPTION=Lightweight Samba suite provides file and print services to SMB/CIFS clients.
SAMBA2_SECTION=net
SAMBA2_PRIORITY=optional
SAMBA2_DEPENDS=
SAMBA2_SUGGESTS=xinetd
SAMBA2_CONFLICTS=samba

#
# SAMBA2_CONFFILES should be a list of user-editable files
SAMBA2_CONFFILES=/opt/etc/init.d/S80samba \
		/opt/etc/samba/smb.conf \
		/opt/etc/xinetd.d/swat


#
# SAMBA2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SAMBA2_PATCHES=$(SAMBA2_SOURCE_DIR)/configure.in.patch $(SAMBA2_SOURCE_DIR)/Makefile.in.patch


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET), slugosbe)
SAMBA2_CPPFLAGS=-DPATH_MAX=4096
else
SAMBA2_CPPFLAGS=
endif
SAMBA2_LDFLAGS=

#
# SAMBA2_BUILD_DIR is the directory in which the build is done.
# SAMBA2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SAMBA2_IPK_DIR is the directory in which the ipk is built.
# SAMBA2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SAMBA2_BUILD_DIR=$(BUILD_DIR)/samba2
SAMBA2_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/samba2
SAMBA2_SOURCE_DIR=$(SOURCE_DIR)/samba2
SAMBA2_IPK_DIR=$(BUILD_DIR)/samba2-$(SAMBA2_VERSION)-ipk
SAMBA2_IPK=$(BUILD_DIR)/samba2_$(SAMBA2_VERSION)-$(SAMBA2_IPK_VERSION)_$(TARGET_ARCH).ipk

SAMBA2_BUILD_DIR_SRC=$(SAMBA2_BUILD_DIR)/source



ifneq ($(HOSTCC), $(TARGET_CC))
SAMBA2_CROSS_ENVS=\
		LOOK_DIRS=$(STAGING_PREFIX) \
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
		fu_cv_sys_stat_statvfs64=yes
endif

SAMBA2_INST_DIR=/opt
SAMBA2_EXEC_PREFIX=$(SAMBA2_INST_DIR)
SAMBA2_BIN_DIR=$(SAMBA2_INST_DIR)/bin
SAMBA2_SBIN_DIR=$(SAMBA2_INST_DIR)/sbin
SAMBA2_LIBEXEC_DIR=$(SAMBA2_INST_DIR)/libexec
SAMBA2_DATA_DIR=$(SAMBA2_INST_DIR)/share/samba
SAMBA2_SYSCONF_DIR=$(SAMBA2_INST_DIR)/etc/samba
SAMBA2_SHAREDSTATE_DIR=$(SAMBA2_INST_DIR)/com/samba
SAMBA2_LOCALSTATE_DIR=$(SAMBA2_INST_DIR)/var/samba
SAMBA2_LIB_DIR=$(SAMBA2_INST_DIR)/lib
SAMBA2_INCLUDE_DIR=$(SAMBA2_INST_DIR)/include
SAMBA2_INFO_DIR=$(SAMBA2_INST_DIR)/info
SAMBA2_MAN_DIR=$(SAMBA2_INST_DIR)/man
SAMBA2_SWAT_DIR=$(SAMBA2_INST_DIR)/share/swat


SAMBA2_CONFIG_OPTS = \
		--bindir=$(SAMBA2_BIN_DIR) \
		--sbindir=$(SAMBA2_SBIN_DIR) \
		--libexecdir=$(SAMBA2_LIBEXEC_DIR) \
		--datadir=$(SAMBA2_DATA_DIR) \
		--sysconfdir=$(SAMBA2_SYSCONF_DIR) \
		--sharedstatedir=$(SAMBA2_SHAREDSTATE_DIR) \
		--localstatedir=$(SAMBA2_LOCALSTATE_DIR) \
		--libdir=$(SAMBA2_LIB_DIR) \
		--includedir=$(SAMBA2_INCLUDE_DIR) \
		--oldincludedir=$(SAMBA2_INCLUDE_DIR) \
		--infodir=$(SAMBA2_INFO_DIR) \
		--mandir=$(SAMBA2_MAN_DIR) \
		--with-privatedir=$(SAMBA2_SYSCONF_DIR) \
		--with-lockdir=$(SAMBA2_LOCALSTATE_DIR) \
		--with-piddir=$(SAMBA2_LOCALSTATE_DIR) \
		--with-swatdir=$(SAMBA2_SWAT_DIR) \
		--with-configdir=$(SAMBA2_SYSCONF_DIR) \
		--with-logfilebase=$(SAMBA2_LOCALSTATE_DIR) \
		--with-libdir=$(SAMBA2_LIB_DIR) \
		--with-mandir=$(SAMBA2_MAN_DIR) \
		--with-smbmount \
		--disable-cups \
		--with-winbind=no \
		--with-quotas=no \
		--with-krb5=no \
		--disable-nls \
		--with-included-popt \
		--with-readline=no \


.PHONY: samba2-source samba2-unpack samba2 samba2-stage samba2-ipk samba2-clean samba2-dirclean samba2-check samba2-repack

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SAMBA2_SOURCE):
	$(WGET) -P $(DL_DIR) $(SAMBA2_SITE)/$(SAMBA2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
samba2-source: $(DL_DIR)/$(SAMBA2_SOURCE) $(SAMBA2_PATCHES)

#
# this builds host samba for make_codepages util
#
$(SAMBA2_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(SAMBA2_SOURCE) make/samba2.mk
	rm -rf $(HOST_BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_HOST_BUILD_DIR)
	$(SAMBA2_UNZIP) $(DL_DIR)/$(SAMBA2_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_HOST_BUILD_DIR)
	(cd $(SAMBA2_HOST_BUILD_DIR)/source; \
		autoconf configure.in > configure; \
	)
	(cd $(SAMBA2_HOST_BUILD_DIR); \
		source/configure \
		--prefix=$(SAMBA2_INST_DIR) \
		--exec-prefix=$(SAMBA2_INST_DIR) \
		$(SAMBA2_CONFIG_OPTS) \
	)
	$(MAKE) -C $(SAMBA2_HOST_BUILD_DIR)
	touch $(SAMBA2_HOST_BUILD_DIR)/.built


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
$(SAMBA2_BUILD_DIR)/.configured: $(SAMBA2_HOST_BUILD_DIR)/.built $(DL_DIR)/$(SAMBA2_SOURCE) $(SAMBA2_PATCHES)
	rm -rf $(BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_BUILD_DIR)
	$(SAMBA2_UNZIP) $(DL_DIR)/$(SAMBA2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SAMBA2_PATCHES) | patch -d $(BUILD_DIR)/$(SAMBA2_DIR) -p1
	mv $(BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_BUILD_DIR)
	(cd $(SAMBA2_BUILD_DIR)/source; \
		autoconf configure.in > configure; \
	)
	cp -f $(SOURCE_DIR)/common/config.* $(SAMBA2_BUILD_DIR)/source
	(cd $(SAMBA2_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SAMBA2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SAMBA2_LDFLAGS)" \
		$(SAMBA2_CROSS_ENVS) \
		source/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		$(SAMBA2_CONFIG_OPTS) \
	)
#	Remove Kerberos libs produced by broken configure
	sed -i -e 's/KRB5LIBS=.*/KRB5LIBS=/' $(SAMBA2_BUILD_DIR)/Makefile
	touch $(SAMBA2_BUILD_DIR)/.configured

samba2-unpack: $(SAMBA2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SAMBA2_BUILD_DIR)/.built: $(SAMBA2_BUILD_DIR)/.configured
	rm -f $(SAMBA2_BUILD_DIR)/.built
	$(MAKE) -C $(SAMBA2_BUILD_DIR)
	touch $(SAMBA2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
samba2: $(SAMBA2_BUILD_DIR)/.built
samba2-host: $(SAMBA2_HOST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SAMBA2_BUILD_DIR)/.staged: $(SAMBA2_BUILD_DIR)/.built
	rm -f $(SAMBA2_BUILD_DIR)/.staged
	$(MAKE) -C $(SAMBA2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SAMBA2_BUILD_DIR)/.staged

samba2-stage: $(SAMBA2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/samba2
#
$(SAMBA2_IPK_DIR)/CONTROL/control:
	@install -d $(SAMBA2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: samba2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SAMBA2_PRIORITY)" >>$@
	@echo "Section: $(SAMBA2_SECTION)" >>$@
	@echo "Version: $(SAMBA2_VERSION)-$(SAMBA2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SAMBA2_MAINTAINER)" >>$@
	@echo "Source: $(SAMBA2_SITE)/$(SAMBA2_SOURCE)" >>$@
	@echo "Description: $(SAMBA2_DESCRIPTION)" >>$@
	@echo "Depends: $(SAMBA2_DEPENDS)" >>$@
	@echo "Suggests: $(SAMBA2_SUGGESTS)" >>$@
	@echo "Conflicts: $(SAMBA2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SAMBA2_IPK_DIR)/opt/sbin or $(SAMBA2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SAMBA2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SAMBA2_IPK_DIR)/opt/etc/samba2/...
# Documentation files should be installed in $(SAMBA2_IPK_DIR)/opt/doc/samba2/...
# Daemon startup scripts should be installed in $(SAMBA2_IPK_DIR)/opt/etc/init.d/S??samba2
#
# You may need to patch your application to make it use these locations.
#
$(SAMBA2_IPK): $(SAMBA2_BUILD_DIR)/.built
	rm -rf $(SAMBA2_IPK_DIR) $(BUILD_DIR)/samba2_*_$(TARGET_ARCH).ipk
	install -d $(SAMBA2_IPK_DIR)/opt/share/
	$(MAKE) -C $(SAMBA2_BUILD_DIR) DESTDIR=$(SAMBA2_IPK_DIR) install
	$(STRIP_COMMAND) `ls $(SAMBA2_IPK_DIR)/opt/sbin/* | egrep -v 'mount.smbfs'`
	$(STRIP_COMMAND) `ls $(SAMBA2_IPK_DIR)/opt/bin/* | egrep -v 'findsmb|smbtar'`
	install -d $(SAMBA2_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SAMBA2_SOURCE_DIR)/rc.samba $(SAMBA2_IPK_DIR)/opt/etc/init.d/S80samba
	install -d $(SAMBA2_IPK_DIR)/opt/etc/samba
	install -d $(SAMBA2_IPK_DIR)/opt/etc/xinetd.d
	install -m 644 $(SAMBA2_SOURCE_DIR)/swat $(SAMBA2_IPK_DIR)/opt/etc/xinetd.d
	install -m 644 $(SAMBA2_SOURCE_DIR)/smb.conf $(SAMBA2_IPK_DIR)/opt/etc/samba/
	install -d $(SAMBA2_IPK_DIR)/opt/var/log/samba
	install -d $(SAMBA2_IPK_DIR)/opt/var/spool/samba
	$(MAKE) $(SAMBA2_IPK_DIR)/CONTROL/control
	install -m 644 $(SAMBA2_SOURCE_DIR)/postinst $(SAMBA2_IPK_DIR)/CONTROL/postinst
	install -m 644 $(SAMBA2_SOURCE_DIR)/preinst $(SAMBA2_IPK_DIR)/CONTROL/preinst
	echo $(SAMBA2_CONFFILES) | sed -e 's/ /\n/g' > $(SAMBA2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SAMBA2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
samba2-ipk: $(SAMBA2_IPK)

samba2-repack:
	touch $(SAMBA2_HOST_BUILD_DIR)/.built
	touch $(SAMBA2_BUILD_DIR)/.configured
	touch $(SAMBA2_BUILD_DIR)/.built
	$(MAKE) $(SAMBA2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
samba2-clean:
	-$(MAKE) -C $(SAMBA2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
samba2-dirclean:
	rm -rf $(BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_BUILD_DIR) $(SAMBA2_IPK_DIR) $(SAMBA2_IPK)
	rm -rf $(HOST_BUILD_DIR)/$(SAMBA2_DIR) $(SAMBA2_HOST_BUILD_DIR)
#
# Some sanity check for the package.
#
samba2-check: $(SAMBA2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SAMBA2_IPK)
