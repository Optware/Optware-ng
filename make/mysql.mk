###########################################################
#
# mysql
#
###########################################################

# You must replace "mysql" and "MYSQL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MYSQL_VERSION, MYSQL_SITE and MYSQL_SOURCE define
# the upstream location of the source code for the package.
# MYSQL_DIR is the directory which is created when the source
# archive is unpacked.
# MYSQL_UNZIP is the command used to unzip the source.
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
#MYSQL_OLD_TARGETS:=\
buildroot-mipsel-ng \
buildroot-armv5eabi-ng \
buildroot-ppc-603e

MYSQL_NO_64BIT_ATOMICS:=\
buildroot-mipsel-ng \
buildroot-armv5eabi-ng \
buildroot-armv5eabi-ng-legacy \
buildroot-ppc-603e \
ct-ng-ppc-e500v2

ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
MYSQL_SITE=https://dev.mysql.com/get/Downloads/MySQL-5.7
MYSQL_VERSION=5.7.9
MYSQL_DIR=mysql-$(MYSQL_VERSION)
MYSQL_IPK_VERSION=9
else
# some needed gcc atomic builtins are missing, which
# makes compiling newer mysql impossible
MYSQL_SITE=https://github.com/mysql/mysql-server/archive
MYSQL_VERSION=5.7.4
MYSQL_DIR=mysql-server-mysql-$(MYSQL_VERSION)
MYSQL_IPK_VERSION=8
endif
MYSQL_SOURCE=mysql-$(MYSQL_VERSION).tar.gz
MYSQL_UNZIP=zcat
MYSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MYSQL_DESCRIPTION=Popular free SQL database system
MYSQL_SECTION=misc
MYSQL_PRIORITY=optional
MYSQL_DEPENDS=zlib, ncurses, libevent
ifneq (, $(filter libstdc++, $(PACKAGES)))
MYSQL_DEPENDS +=, libstdc++
endif
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
MYSQL_DEPENDS +=, openssl
else
MYSQL_DEPENDS +=, perl
endif
MYSQL_CONFLICTS=

# recent mysql needs boost headers only,
# and requires a specific version at that
MYSQL_BOOST_VERSION=1_59_0
MYSQL_BOOST_SOURCE=boost_$(MYSQL_BOOST_VERSION).tar.gz


#
# MYSQL_CONFFILES should be a list of user-editable files
MYSQL_CONFFILES=\
$(TARGET_PREFIX)/etc/my.cnf\
$(TARGET_PREFIX)/share/mysql/support-files/mysql.server

#
# MYSQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
MYSQL_PATCHES=\
$(MYSQL_SOURCE_DIR)/auth_utils.patch \
$(MYSQL_SOURCE_DIR)/disable-mysql-test.patch \
$(MYSQL_SOURCE_DIR)/find-system-zlib.patch \
$(MYSQL_SOURCE_DIR)/gen_lex.patch \
$(MYSQL_SOURCE_DIR)/hostname.patch \
$(MYSQL_SOURCE_DIR)/my.cnf_location.patch \
$(MYSQL_SOURCE_DIR)/my_default.patch \
$(MYSQL_SOURCE_DIR)/mysqld.patch \
$(MYSQL_SOURCE_DIR)/no_64bit_atomics.patch \
$(MYSQL_SOURCE_DIR)/sasl_defs.patch \
$(MYSQL_SOURCE_DIR)/yassl_lock.hpp.patch \
$(MYSQL_SOURCE_DIR)/fix-bug_21847825-not-possible-to-use-ALTER-USER-when-running-under--skip-grant-tables.patch
else
MYSQL_PATCHES=\
$(MYSQL_SOURCE_DIR)/bison3.fix.patch \
$(MYSQL_SOURCE_DIR)/disable-mysql-test.patch \
$(MYSQL_SOURCE_DIR)/find-system-zlib.old.patch \
$(MYSQL_SOURCE_DIR)/gen_lex.patch \
$(MYSQL_SOURCE_DIR)/hostname.patch \
$(MYSQL_SOURCE_DIR)/includes.fix.patch \
$(MYSQL_SOURCE_DIR)/my.cnf_location.patch \
$(MYSQL_SOURCE_DIR)/my_default.patch \
$(MYSQL_SOURCE_DIR)/mysql_install_db.pl.patch \
$(MYSQL_SOURCE_DIR)/sasl_defs.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSQL_CPPFLAGS=\
-Wno-deprecated-declarations \
-DHAVE_IB_GCC_SYNC_SYNCHRONISE \
-DHAVE_IB_GCC_ATOMIC_COMPARE_EXCHANGE \
-DHAVE_IB_GCC_ATOMIC_THREAD_FENCE \
-DHAVE_IB_ATOMIC_PTHREAD_T_GCC

ifeq ($(OPTWARE_TARGET), $(filter $(MYSQL_NO_64BIT_ATOMICS), $(OPTWARE_TARGET)))
MYSQL_CPPFLAGS += \
-DHAVE_GCC_ATOMIC_BUILTINS \
-DHAVE_NO_64BIT_ATOMICS
endif

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
MYSQL_CPPFLAGS += -DNO_FALLOCATE
endif

ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
MYSQL_CONFIGURE_ARGS=\
-DCMAKE_FIND_ROOT_PATH="$(STAGING_PREFIX);$(TARGET_CROSS_TOP);$(MYSQL_HOST_BUILD_DIR)"
-DWITH_BOOST=/boost_$(MYSQL_BOOST_VERSION) \
-DWITH_SSL=system
endif

MYSQL_CXX_FLAGS=

ifeq ($(shell test -x $(TARGET_CC); echo $$?),0)
ifeq ($(shell test $(shell $(TARGET_CC) -dumpversion | cut -d '.' -f 1) -gt 4; echo $$?),0)
MYSQL_CXX_FLAGS += -std=c++11
endif
endif

#MYSQL_LDFLAGS="-Wl,-rpath,$(TARGET_PREFIX)/lib/mysql"

#
# MYSQL_BUILD_DIR is the directory in which the build is done.
# MYSQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MYSQL_IPK_DIR is the directory in which the ipk is built.
# MYSQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MYSQL_SOURCE_DIR=$(SOURCE_DIR)/mysql
MYSQL_BUILD_DIR=$(BUILD_DIR)/mysql
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
MYSQL_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/mysql
else
MYSQL_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/mysql_old
endif

MYSQL_IPK_DIR=$(BUILD_DIR)/mysql-$(MYSQL_VERSION)-ipk
MYSQL_IPK=$(BUILD_DIR)/mysql_$(MYSQL_VERSION)-$(MYSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYSQL_SOURCE):
	$(WGET) -P $(@D) $(MYSQL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(MYSQL_BOOST_VERSION),$(BOOST_VERSION))
$(DL_DIR)/$(MYSQL_BOOST_SOURCE):
	$(WGET) -P $(@D) $(BOOST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mysql-source: $(DL_DIR)/$(MYSQL_SOURCE) $(DL_DIR)/$(MYSQL_BOOST_SOURCE) $(MYSQL_PATCHES)

$(MYSQL_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(MYSQL_SOURCE) $(DL_DIR)/$(MYSQL_BOOST_SOURCE) #make/mysql.mk
	rm -rf $(HOST_BUILD_DIR)/$(MYSQL_DIR) $(@D)
	$(MYSQL_UNZIP) $(DL_DIR)/$(MYSQL_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(MYSQL_PATCHES)" ; \
		then cat $(MYSQL_PATCHES) | \
		$(PATCH) -bd $(HOST_BUILD_DIR)/$(MYSQL_DIR) -p1 ; \
	fi
	mv $(HOST_BUILD_DIR)/$(MYSQL_DIR) $(@D)
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
	$(BOOST_UNZIP) $(DL_DIR)/$(MYSQL_BOOST_SOURCE) | tar -C $(@D) -xf - boost_$(MYSQL_BOOST_VERSION)/boost
endif
	cd $(@D)/BUILD; \
		cmake $(@D) -DWITH_BOOST=$(@D)/boost_$(MYSQL_BOOST_VERSION) -DWITH_UNIT_TESTS=OFF
	$(MAKE) -C $(@D)/BUILD
	touch $@

mysql-hostbuild: $(MYSQL_HOST_BUILD_DIR)/.built

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
$(MYSQL_BUILD_DIR)/.configured: $(MYSQL_HOST_BUILD_DIR)/.built \
 $(DL_DIR)/$(MYSQL_SOURCE) $(DL_DIR)/$(MYSQL_BOOST_SOURCE) $(MYSQL_PATCHES) make/mysql.mk
	$(MAKE) ncurses-stage zlib-stage libevent-stage
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
	$(MAKE) openssl-stage
endif
	rm -rf $(BUILD_DIR)/$(MYSQL_DIR) $(@D)
	$(MYSQL_UNZIP) $(DL_DIR)/$(MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYSQL_PATCHES)" ; \
		then cat $(MYSQL_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(MYSQL_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MYSQL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MYSQL_DIR) $(@D) ; \
	fi
	(cd $(@D)/BUILD; \
		cmake $(@D) \
		$(CMAKE_CONFIGURE_OPTS) \
		$(MYSQL_CONFIGURE_ARGS) \
		-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(MYSQL_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) $(MYSQL_CXX_FLAGS) $(MYSQL_CPPFLAGS)" \
		-DCMAKE_C_LINK_FLAGS="$(MYSQL_LDFLAGS) $(STAGING_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS="$(MYSQL_LDFLAGS) $(STAGING_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS="$(MYSQL_LDFLAGS) $(STAGING_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS="$(MYSQL_LDFLAGS) $(STAGING_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS="$(MYSQL_LDFLAGS) $(STAGING_LDFLAGS)" \
		-DCOMPILATION_COMMENT="Optware-ng distribution $(MYSQL_VERSION)-$(MYSQL_IPK_VERSION)" \
		-DZLIB_INCLUDE_DIR=$(STAGING_INCLUDE_DIR) \
		-DZLIB_LIBRARY=$(STAGING_LIB_DIR)/libz.so \
		-DWITH_LIBEVENT=system \
		-DWITH_ZLIB=system \
		-DINSTALL_PLUGINDIR=lib/mysql/plugin \
		-DINSTALL_MYSQLSHAREDIR=share/mysql \
		-DINSTALL_SUPPORTFILESDIR=share/mysql/support-files \
		-DINSTALL_INCLUDEDIR=include/mysql \
		-DINSTALL_MANDIR=share/man \
		-DINSTALL_SCRIPTDIR=bin \
		-DINSTALL_SQLBENCHDIR= \
		-DSTACK_DIRECTION=1 \
		-DHAVE_LLVM_LIBCPP_EXITCODE=1 \
		-DHAVE_FALLOC_PUNCH_HOLE_AND_KEEP_SIZE_EXITCODE=1 \
		-DWITH_UNIT_TESTS=OFF \
		-DWITH_EMBEDDED_SERVER=TRUE \
		-DDEFAULT_CHARSET=utf8 \
		-DDEFAULT_COLLATION=utf8_general_ci \
	)
	mkdir -p $(@D)/host_binaries
	cd $(MYSQL_HOST_BUILD_DIR)/BUILD; \
		cp -f extra/comp_err scripts/comp_sql sql/gen_lex_{token,hash} $(@D)/host_binaries
	cp -f $(MYSQL_HOST_BUILD_DIR)/BUILD/scripts/comp_sql $(@D)/scripts
	cp -f $(MYSQL_HOST_BUILD_DIR)/BUILD/sql/gen_lex_{token,hash} $(@D)/sql
	cp -f $(MYSQL_HOST_BUILD_DIR)/BUILD/sql/gen_lex_{token,hash} $(@D)/libmysqld
	touch $@

mysql-unpack: $(MYSQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYSQL_BUILD_DIR)/.built: $(MYSQL_BUILD_DIR)/.configured
	rm -f $@
	PATH=$$PATH:$(@D)/host_binaries; \
		$(MAKE) -C $(@D)/BUILD
	touch $@

#
# This is the build convenience target.
#
mysql: $(MYSQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MYSQL_BUILD_DIR)/.staged: $(MYSQL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/BUILD DESTDIR=$(STAGING_DIR) install
	-sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/mysqlclient.pc
	touch $@

mysql-stage: $(MYSQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysql
#
$(MYSQL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MYSQL_PRIORITY)" >>$@
	@echo "Section: $(MYSQL_SECTION)" >>$@
	@echo "Version: $(MYSQL_VERSION)-$(MYSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MYSQL_MAINTAINER)" >>$@
	@echo "Source: $(MYSQL_SITE)/$(MYSQL_SOURCE)" >>$@
	@echo "Description: $(MYSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(MYSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(MYSQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/mysql/...
# Documentation files should be installed in $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/doc/mysql/...
# Daemon startup scripts should be installed in $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mysql
#
# You may need to patch your application to make it use these locations.
#
$(MYSQL_IPK): $(MYSQL_BUILD_DIR)/.built
	rm -rf $(MYSQL_IPK_DIR) $(BUILD_DIR)/mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MYSQL_BUILD_DIR)/BUILD DESTDIR=$(MYSQL_IPK_DIR) install
	rm -rf 	$(MYSQL_IPK_DIR)$(TARGET_PREFIX)/docs $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/lib/*.a \
		$(MYSQL_IPK_DIR)$(TARGET_PREFIX)/{COPYING,INSTALL-BINARY,README}
	-$(STRIP_COMMAND) $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/{bin/*,lib/*.so,lib/mysql/plugin/*.so} 2>/dev/null
	$(INSTALL) -d $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/var/lib/mysql
	$(INSTALL) -d $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/var/log
	$(INSTALL) -d $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 644 $(MYSQL_SOURCE_DIR)/my.cnf $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/my.cnf
	$(INSTALL) -d $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	( cd $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d ; \
		ln -s ../../share/mysql/support-files/mysql.server S70mysqld ; \
		ln -s ../../share/mysql/support-files/mysql.server K70mysqld ; \
	)
	$(MAKE) $(MYSQL_IPK_DIR)/CONTROL/control
ifneq ($(OPTWARE_TARGET), $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)))
	$(INSTALL) -m 755 $(MYSQL_SOURCE_DIR)/postinst $(MYSQL_IPK_DIR)/CONTROL/postinst
else
	$(INSTALL) -m 755 $(MYSQL_SOURCE_DIR)/postinst.old $(MYSQL_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!.*perl/s|.*|#!$(TARGET_PREFIX)/bin/perl|' $(MYSQL_IPK_DIR)$(TARGET_PREFIX)/bin/mysql_install_db
endif
	$(INSTALL) -m 755 $(MYSQL_SOURCE_DIR)/prerm $(MYSQL_IPK_DIR)/CONTROL/prerm
	echo $(MYSQL_CONFFILES) | sed -e 's/ /\n/g' > $(MYSQL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYSQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mysql-ipk: $(MYSQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mysql-clean:
	-$(MAKE) -C $(MYSQL_BUILD_DIR) clean
	-$(MAKE) -C $(MYSQL_HOST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mysql-dirclean:
	rm -rf $(BUILD_DIR)/$(MYSQL_DIR) $(MYSQL_BUILD_DIR) $(MYSQL_IPK_DIR) $(MYSQL_IPK)
	rm -rf $(MYSQL_HOST_BUILD_DIR)

#
# Some sanity check for the package.
#
mysql-check: $(MYSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
