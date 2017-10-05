###########################################################
#
# mysql-connector-odbc
#
###########################################################
#
# MYSQL_CONNECTOR_ODBC_VERSION, MYSQL_CONNECTOR_ODBC_SITE and MYSQL_CONNECTOR_ODBC_SOURCE define
# the upstream location of the source code for the package.
# MYSQL_CONNECTOR_ODBC_DIR is the directory which is created when the source
# archive is unpacked.
# MYSQL_CONNECTOR_ODBC_UNZIP is the command used to unzip the source.
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
MYSQL_CONNECTOR_ODBC_SITE=https://dev.mysql.com/get/Downloads/Connector-ODBC/5.3
MYSQL_CONNECTOR_ODBC_VERSION=5.3.4
MYSQL_CONNECTOR_ODBC_SOURCE=mysql-connector-odbc-$(MYSQL_CONNECTOR_ODBC_VERSION)-src.tar.gz
MYSQL_CONNECTOR_ODBC_DIR=mysql-connector-odbc-$(MYSQL_CONNECTOR_ODBC_VERSION)-src
MYSQL_CONNECTOR_ODBC_UNZIP=zcat
MYSQL_CONNECTOR_ODBC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MYSQL_CONNECTOR_ODBC_DESCRIPTION=MySQL connector ODBC
MYSQL_CONNECTOR_ODBC_SECTION=util
MYSQL_CONNECTOR_ODBC_PRIORITY=optional
MYSQL_CONNECTOR_ODBC_DEPENDS=libtool,unixodbc,mysql
MYSQL_CONNECTOR_ODBC_SUGGESTS=
MYSQL_CONNECTOR_ODBC_CONFLICTS=

#
# MYSQL_CONNECTOR_ODBC_IPK_VERSION should be incremented when the ipk changes.
#
MYSQL_CONNECTOR_ODBC_IPK_VERSION=3

#
# MYSQL_CONNECTOR_ODBC_CONFFILES should be a list of user-editable files
#MYSQL_CONNECTOR_ODBC_CONFFILES=$(TARGET_PREFIX)/etc/mysql-connector-odbc.conf $(TARGET_PREFIX)/etc/init.d/SXXmysql-connector-odbc

#
# MYSQL_CONNECTOR_ODBC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MYSQL_CONNECTOR_ODBC_PATCHES_NEW=\
$(MYSQL_CONNECTOR_ODBC_SOURCE_DIR)/mysql.5.7.current.api.patch
MYSQL_CONNECTOR_ODBC_PATCHES_OLD=\
$(MYSQL_CONNECTOR_ODBC_SOURCE_DIR)/mysql.5.7.4.api.patch

MYSQL_CONNECTOR_ODBC_PATCHES=$(strip \
	$(if $(filter $(MYSQL_OLD_TARGETS), $(OPTWARE_TARGET)), $(MYSQL_CONNECTOR_ODBC_PATCHES_OLD), \
	$(MYSQL_CONNECTOR_ODBC_PATCHES_NEW))) \
$(MYSQL_CONNECTOR_ODBC_SOURCE_DIR)/driver.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSQL_CONNECTOR_ODBC_CPPFLAGS=-include$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/odbc_const.h -I$(STAGING_INCLUDE_DIR)/mysql
MYSQL_CONNECTOR_ODBC_LDFLAGS=-lodbc -lmysqlclient $(MYSQL_BUILD_DIR)/BUILD/mysys/libmysys.a $(MYSQL_BUILD_DIR)/BUILD/strings/libstrings.a

#
# MYSQL_CONNECTOR_ODBC_BUILD_DIR is the directory in which the build is done.
# MYSQL_CONNECTOR_ODBC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MYSQL_CONNECTOR_ODBC_IPK_DIR is the directory in which the ipk is built.
# MYSQL_CONNECTOR_ODBC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MYSQL_CONNECTOR_ODBC_BUILD_DIR=$(BUILD_DIR)/mysql-connector-odbc
MYSQL_CONNECTOR_ODBC_SOURCE_DIR=$(SOURCE_DIR)/mysql-connector-odbc
MYSQL_CONNECTOR_ODBC_IPK_DIR=$(BUILD_DIR)/mysql-connector-odbc-$(MYSQL_CONNECTOR_ODBC_VERSION)-ipk
MYSQL_CONNECTOR_ODBC_IPK=$(BUILD_DIR)/mysql-connector-odbc_$(MYSQL_CONNECTOR_ODBC_VERSION)-$(MYSQL_CONNECTOR_ODBC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mysql-connector-odbc-source mysql-connector-odbc-unpack mysql-connector-odbc mysql-connector-odbc-stage mysql-connector-odbc-ipk mysql-connector-odbc-clean mysql-connector-odbc-dirclean mysql-connector-odbc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MYSQL_CONNECTOR_ODBC_SOURCE):
	$(WGET) -P $(@D) $(MYSQL_CONNECTOR_ODBC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mysql-connector-odbc-source: $(DL_DIR)/$(MYSQL_CONNECTOR_ODBC_SOURCE) $(MYSQL_CONNECTOR_ODBC_PATCHES)

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
$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.configured: $(DL_DIR)/$(MYSQL_CONNECTOR_ODBC_SOURCE) $(MYSQL_CONNECTOR_ODBC_PATCHES) make/mysql-connector-odbc.mk
	$(MAKE) mysql-stage libtool-stage unixodbc-stage
	rm -rf $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) $(@D)
	$(MYSQL_CONNECTOR_ODBC_UNZIP) $(DL_DIR)/$(MYSQL_CONNECTOR_ODBC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYSQL_CONNECTOR_ODBC_PATCHES)" ; \
		then cat $(MYSQL_CONNECTOR_ODBC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(MYSQL_CONNECTOR_ODBC_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(MYSQL_CONNECTOR_ODBC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		cmake -G "Unix Makefiles" \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(MYSQL_CONNECTOR_ODBC_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(MYSQL_CONNECTOR_ODBC_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS))" \
		-DDL_LIBS=$(shell find $(TARGET_CROSS_TOP) -name 'libdl.so' | head -1) \
		-DMYSQLCLIENT_LIB_NAME=libmysqlclient.so \
		-DWITH_UNIXODBC=1 \
		-DDISABLE_GUI=1 \
		-DMYSQL_INCLUDE_DIR=$(STAGING_INCLUDE_DIR) \
		-DMYSQL_LIB_DIR=$(STAGING_LIB_DIR) \
		-DMYSQL_DIR=$(STAGING_PREFIX) \
		-DODBC_INCLUDES=$(STAGING_INCLUDE_DIR) \
		-DODBC_LIB_DIR=$(STAGING_LIB_DIR) \
		-DMYSQL_CONFIG_EXECUTABLE=$(TARGET_PREFIX)/bin/mysql_config \
		-DMYSQL_LINK_FLAGS="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		-DMYSQL_CXXFLAGS="$(MYSQL_CONNECTOR_ODBC_CPPFLAGS) $(STAGING_CPPFLAGS)" \
	)
	touch $@

mysql-connector-odbc-unpack: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mysql-connector-odbc: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.staged: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mysql-connector-odbc-stage: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysql-connector-odbc
#
$(MYSQL_CONNECTOR_ODBC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mysql-connector-odbc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MYSQL_CONNECTOR_ODBC_PRIORITY)" >>$@
	@echo "Section: $(MYSQL_CONNECTOR_ODBC_SECTION)" >>$@
	@echo "Version: $(MYSQL_CONNECTOR_ODBC_VERSION)-$(MYSQL_CONNECTOR_ODBC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MYSQL_CONNECTOR_ODBC_MAINTAINER)" >>$@
	@echo "Source: $(MYSQL_CONNECTOR_ODBC_SITE)/$(MYSQL_CONNECTOR_ODBC_SOURCE)" >>$@
	@echo "Description: $(MYSQL_CONNECTOR_ODBC_DESCRIPTION)" >>$@
	@echo "Depends: $(MYSQL_CONNECTOR_ODBC_DEPENDS)" >>$@
	@echo "Suggests: $(MYSQL_CONNECTOR_ODBC_SUGGESTS)" >>$@
	@echo "Conflicts: $(MYSQL_CONNECTOR_ODBC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/etc/mysql-connector-odbc/...
# Documentation files should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/doc/mysql-connector-odbc/...
# Daemon startup scripts should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mysql-connector-odbc
#
# You may need to patch your application to make it use these locations.
#
$(MYSQL_CONNECTOR_ODBC_IPK): $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built
	rm -rf $(MYSQL_CONNECTOR_ODBC_IPK_DIR) $(BUILD_DIR)/mysql-connector-odbc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) DESTDIR=$(MYSQL_CONNECTOR_ODBC_IPK_DIR) install
	rm -rf $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/{test,ChangeLog,COPYING,INSTALL,Licenses_for_Third-Party_Components.txt,README,README.debug}
	$(STRIP_COMMAND) $(MYSQL_CONNECTOR_ODBC_IPK_DIR)$(TARGET_PREFIX)/{lib/*.so,bin/*}
	$(MAKE) $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/CONTROL/control
	#echo $(MYSQL_CONNECTOR_ODBC_CONFFILES) | sed -e 's/ /\n/g' > $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MYSQL_CONNECTOR_ODBC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mysql-connector-odbc-ipk: $(MYSQL_CONNECTOR_ODBC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mysql-connector-odbc-clean:
	rm -f $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built
	-$(MAKE) -C $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mysql-connector-odbc-dirclean:
	rm -rf $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) $(MYSQL_CONNECTOR_ODBC_IPK_DIR) $(MYSQL_CONNECTOR_ODBC_IPK)
#
#
# Some sanity check for the package.
#
mysql-connector-odbc-check: $(MYSQL_CONNECTOR_ODBC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
