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
MYSQL_CONNECTOR_ODBC_SITE=ftp://ftp.orst.edu/pub/mysql/Downloads/MyODBC3
MYSQL_CONNECTOR_ODBC_VERSION=3.51.12
MYSQL_CONNECTOR_ODBC_SOURCE=mysql-connector-odbc-$(MYSQL_CONNECTOR_ODBC_VERSION).tar.gz
MYSQL_CONNECTOR_ODBC_DIR=mysql-connector-odbc-$(MYSQL_CONNECTOR_ODBC_VERSION)
MYSQL_CONNECTOR_ODBC_UNZIP=zcat
MYSQL_CONNECTOR_ODBC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MYSQL_CONNECTOR_ODBC_DESCRIPTION=Describe mysql-connector-odbc here.
MYSQL_CONNECTOR_ODBC_SECTION=util
MYSQL_CONNECTOR_ODBC_PRIORITY=optional
MYSQL_CONNECTOR_ODBC_DEPENDS=libtool,unixodbc,mysql
MYSQL_CONNECTOR_ODBC_SUGGESTS=
MYSQL_CONNECTOR_ODBC_CONFLICTS=

#
# MYSQL_CONNECTOR_ODBC_IPK_VERSION should be incremented when the ipk changes.
#
MYSQL_CONNECTOR_ODBC_IPK_VERSION=1

#
# MYSQL_CONNECTOR_ODBC_CONFFILES should be a list of user-editable files
#MYSQL_CONNECTOR_ODBC_CONFFILES=/opt/etc/mysql-connector-odbc.conf /opt/etc/init.d/SXXmysql-connector-odbc

#
# MYSQL_CONNECTOR_ODBC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MYSQL_CONNECTOR_ODBC_PATCHES=$(MYSQL_CONNECTOR_ODBC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MYSQL_CONNECTOR_ODBC_CPPFLAGS=
MYSQL_CONNECTOR_ODBC_LDFLAGS=

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
	$(WGET) -P $(DL_DIR) $(MYSQL_CONNECTOR_ODBC_SITE)/$(MYSQL_CONNECTOR_ODBC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MYSQL_CONNECTOR_ODBC_SOURCE)

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
	rm -rf $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)
	$(MYSQL_CONNECTOR_ODBC_UNZIP) $(DL_DIR)/$(MYSQL_CONNECTOR_ODBC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MYSQL_CONNECTOR_ODBC_PATCHES)" ; \
		then cat $(MYSQL_CONNECTOR_ODBC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR)" != "$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MYSQL_CONNECTOR_ODBC_DIR) $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) ; \
	fi
	(cd $(MYSQL_CONNECTOR_ODBC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MYSQL_CONNECTOR_ODBC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MYSQL_CONNECTOR_ODBC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-mysql-path=$(STAGING_DIR)/opt \
		--with-unixODBC=$(STAGING_DIR)/opt \
		--with-unixODBC-includes=$(STAGING_DIR)/opt/include \
		--with-unixODBC-libs=$(STAGING_DIR)/opt/lib \
		--enable-thread-safe \
		--enable-gui=no \
	)
	$(PATCH_LIBTOOL) $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/libtool
	touch $@

mysql-connector-odbc-unpack: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)
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
	$(MAKE) -C $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mysql-connector-odbc-stage: $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mysql-connector-odbc
#
$(MYSQL_CONNECTOR_ODBC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
# Binaries should be installed into $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/sbin or $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/etc/mysql-connector-odbc/...
# Documentation files should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/doc/mysql-connector-odbc/...
# Daemon startup scripts should be installed in $(MYSQL_CONNECTOR_ODBC_IPK_DIR)/opt/etc/init.d/S??mysql-connector-odbc
#
# You may need to patch your application to make it use these locations.
#
$(MYSQL_CONNECTOR_ODBC_IPK): $(MYSQL_CONNECTOR_ODBC_BUILD_DIR)/.built
	rm -rf $(MYSQL_CONNECTOR_ODBC_IPK_DIR) $(BUILD_DIR)/mysql-connector-odbc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MYSQL_CONNECTOR_ODBC_BUILD_DIR) DESTDIR=$(MYSQL_CONNECTOR_ODBC_IPK_DIR) install-strip
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MYSQL_CONNECTOR_ODBC_IPK)
