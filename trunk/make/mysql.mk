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
MYSQL_SITE=http://downloads.mysql.com/archives/mysql-4.1
MYSQL_VERSION=4.1.22
MYSQL_SOURCE=mysql-$(MYSQL_VERSION).tar.gz
MYSQL_DIR=mysql-$(MYSQL_VERSION)
MYSQL_UNZIP=zcat
MYSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MYSQL_DESCRIPTION=Popular free SQL database system
MYSQL_SECTION=misc
MYSQL_PRIORITY=optional
MYSQL_DEPENDS=zlib, ncurses, openssl, readline
ifneq (, $(filter libstdc++, $(PACKAGES)))
MYSQL_DEPENDS +=, libstdc++
endif
MYSQL_CONFLICTS=

#
# MYSQL_IPK_VERSION should be incremented when the ipk changes.
#
MYSQL_IPK_VERSION=3

#
# MYSQL_CONFFILES should be a list of user-editable files
MYSQL_CONFFILES=/opt/etc/my.cnf

#
# MYSQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MYSQL_PATCHES=\
$(MYSQL_SOURCE_DIR)/configure.patch \
$(MYSQL_SOURCE_DIR)/lex_hash.patch \
$(MYSQL_SOURCE_DIR)/comp_err.patch\
$(MYSQL_SOURCE_DIR)/m_string.h.patch

ifeq ($(OPTWARE_TARGET), dns323)
# SIGILL if -O3 is used, so replace -O3 with -Os; it will supercede the TARGET_OPTIMIZATION
# in toolchain-dns323 because it is later on the command line.
MYSQL_PATCHES+=$(MYSQL_SOURCE_DIR)/configure_dns323_optimization.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSQL_CPPFLAGS=
MYSQL_LDFLAGS="-Wl,-rpath,/opt/lib/mysql"
MYSQL_CONFIG_ENV=ac_cv_sys_restartable_syscalls=yes
MYSQL_CONFIG_ENV += $(strip \
$(if $(filter arm armeb, $(TARGET_ARCH)), ac_cv_c_stack_direction=1, \
))

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
MYSQL_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/mysql

MYSQL_IPK_DIR=$(BUILD_DIR)/mysql-$(MYSQL_VERSION)-ipk
MYSQL_IPK=$(BUILD_DIR)/mysql_$(MYSQL_VERSION)-$(MYSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYSQL_SOURCE):
	$(WGET) -P $(@D) $(MYSQL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mysql-source: $(DL_DIR)/$(MYSQL_SOURCE) $(MYSQL_PATCHES)

$(MYSQL_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(MYSQL_SOURCE) make/mysql.mk
	rm -rf $(HOST_BUILD_DIR)/$(MYSQL_DIR) $(@D)
	$(MYSQL_UNZIP) $(DL_DIR)/$(MYSQL_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(MYSQL_DIR) $(@D)
	cd $(@D); ./configure --prefix=/opt
	$(MAKE) -C $(@D)
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
$(MYSQL_BUILD_DIR)/.configured: $(MYSQL_PATCHES) $(MYSQL_HOST_BUILD_DIR)/.built \
 $(DL_DIR)/$(MYSQL_SOURCE) make/mysql.mk
	$(MAKE) openssl-stage
	$(MAKE) ncurses-stage
	$(MAKE) zlib-stage
	$(MAKE) readline-stage
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(MYSQL_DIR) $(@D)
	$(MYSQL_UNZIP) $(DL_DIR)/$(MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MYSQL_PATCHES) | patch -bd $(BUILD_DIR)/$(MYSQL_DIR) -p1
	mv $(BUILD_DIR)/$(MYSQL_DIR) $(MYSQL_BUILD_DIR)
	autoreconf --install --force -v $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MYSQL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MYSQL_LDFLAGS)" \
		$(MYSQL_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--program-prefix="" \
		--disable-static \
		--with-openssl=$(STAGING_DIR)/opt \
		--with-zlib-dir=$(STAGING_DIR)/opt \
		--without-readline \
		--enable-thread-safe-client \
		--with-comment="optware distribution $(MYSQL_VERSION)-$(MYSQL_IPK_VERSION)" \
		--without-debug \
		--without-extra-tools \
		--without-docs \
		--without-bench \
		--without-isam \
		--without-innodb \
		--with-geometry \
		--with-low-memory \
		--enable-assembler \
	)
#		--with-named-thread-libs=-lpthread \

	sed -i -e 's!"/etc!"/opt/etc!g' $(@D)/*/default.c $(@D)/scripts/*.sh
	$(PATCH_LIBTOOL) $(@D)/libtool
ifeq ($(CROSS_CONFIGURATION_UCLIBC_VERSION), 0.9.29)
	sed -i -e 's!.*HAVE_INDEX.*!#define HAVE_INDEX 1!' $(@D)/config.h
endif
	touch $@

mysql-unpack: $(MYSQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYSQL_BUILD_DIR)/.built: $(MYSQL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		GEN_LEX_HASH=$(MYSQL_HOST_BUILD_DIR)/sql/gen_lex_hash \
		COMP_ERR=$(MYSQL_HOST_BUILD_DIR)/extra/comp_err \
		;
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
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-strip
	rm -f $(STAGING_PREFIX)/lib/mysql/*.la
	touch $@

mysql-stage: $(MYSQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysql
#
$(MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
# Binaries should be installed into $(MYSQL_IPK_DIR)/opt/sbin or $(MYSQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MYSQL_IPK_DIR)/opt/etc/mysql/...
# Documentation files should be installed in $(MYSQL_IPK_DIR)/opt/doc/mysql/...
# Daemon startup scripts should be installed in $(MYSQL_IPK_DIR)/opt/etc/init.d/S??mysql
#
# You may need to patch your application to make it use these locations.
#
$(MYSQL_IPK): $(MYSQL_BUILD_DIR)/.built
	rm -rf $(MYSQL_IPK_DIR) $(BUILD_DIR)/mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MYSQL_BUILD_DIR) DESTDIR=$(MYSQL_IPK_DIR) install-strip
	rm -rf $(MYSQL_IPK_DIR)/opt/mysql-test
	install -d $(MYSQL_IPK_DIR)/opt/var/lib/mysql
	install -d $(MYSQL_IPK_DIR)/opt/var/log
	install -d $(MYSQL_IPK_DIR)/opt/etc/
	install -m 644 $(MYSQL_SOURCE_DIR)/my.cnf $(MYSQL_IPK_DIR)/opt/etc/my.cnf
	install -d $(MYSQL_IPK_DIR)/opt/etc/init.d
	( cd $(MYSQL_IPK_DIR)/opt/etc/init.d ; \
		ln -s ../../share/mysql/mysql.server S70mysqld ; \
		ln -s ../../share/mysql/mysql.server K70mysqld ; \
	)
	$(MAKE) $(MYSQL_IPK_DIR)/CONTROL/control
	install -m 755 $(MYSQL_SOURCE_DIR)/postinst $(MYSQL_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MYSQL_SOURCE_DIR)/prerm $(MYSQL_IPK_DIR)/CONTROL/prerm
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
