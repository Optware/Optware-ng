###########################################################
#
# postgresql
#
###########################################################

# You must replace "postgresql" and "POSTGRESQL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POSTGRESQL_VERSION, POSTGRESQL_SITE and POSTGRESQL_SOURCE define
# the upstream location of the source code for the package.
# POSTGRESQL_DIR is the directory which is created when the source
# archive is unpacked.
# POSTGRESQL_UNZIP is the command used to unzip the source.
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
POSTGRESQL_VERSION=8.2.2
POSTGRESQL_SITE=ftp://ftp.postgresql.org/pub/source/v$(POSTGRESQL_VERSION)
POSTGRESQL_SOURCE=postgresql-base-$(POSTGRESQL_VERSION).tar.bz2
POSTGRESQL_DIR=postgresql-$(POSTGRESQL_VERSION)
POSTGRESQL_UNZIP=bzcat
POSTGRESQL_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
POSTGRESQL_DESCRIPTION=PostgreSQL is a highly-scalable, SQL compliant, open source object-relational database management system
POSTGRESQL_SECTION=misc
POSTGRESQL_PRIORITY=optional
POSTGRESQL_DEPENDS=readline

#
# POSTGRESQL_IPK_VERSION should be incremented when the ipk changes.
#
POSTGRESQL_IPK_VERSION=1

#
# POSTGRESQL_CONFFILES should be a list of user-editable files
#POSTGRESQL_CONFFILES=/opt/etc/postgresql.conf /opt/etc/init.d/SXXpostgresql

#
# POSTGRESQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
POSTGRESQL_PATCHES=$(POSTGRESQL_SOURCE_DIR)/src-timezone-Makefile.patch $(POSTGRESQL_SOURCE_DIR)/disable-buildtime-test.patch
POSTGRESQL_CONFIG_ENV=pgac_cv_snprintf_long_long_int_format='%lld'
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POSTGRESQL_CPPFLAGS=
POSTGRESQL_LDFLAGS=

#
# POSTGRESQL_BUILD_DIR is the directory in which the build is done.
# POSTGRESQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POSTGRESQL_IPK_DIR is the directory in which the ipk is built.
# POSTGRESQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POSTGRESQL_BUILD_DIR=$(BUILD_DIR)/postgresql
POSTGRESQL_SOURCE_DIR=$(SOURCE_DIR)/postgresql
POSTGRESQL_IPK_DIR=$(BUILD_DIR)/postgresql-$(POSTGRESQL_VERSION)-ipk
POSTGRESQL_IPK=$(BUILD_DIR)/postgresql_$(POSTGRESQL_VERSION)-$(POSTGRESQL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: postgresql-source postgresql-unpack postgresql postgresql-stage postgresql-ipk postgresql-clean postgresql-dirclean postgresql-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POSTGRESQL_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTGRESQL_SITE)/$(POSTGRESQL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
postgresql-source: $(DL_DIR)/$(POSTGRESQL_SOURCE) $(POSTGRESQL_PATCHES)

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
$(POSTGRESQL_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTGRESQL_SOURCE) $(POSTGRESQL_PATCHES)
	$(MAKE) readline-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(POSTGRESQL_DIR) $(POSTGRESQL_BUILD_DIR)
	$(POSTGRESQL_UNZIP) $(DL_DIR)/$(POSTGRESQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POSTGRESQL_PATCHES)" ; then \
		cat $(POSTGRESQL_PATCHES) | patch -d $(BUILD_DIR)/$(POSTGRESQL_DIR) -p1 ; \
        fi
	mv $(BUILD_DIR)/$(POSTGRESQL_DIR) $(POSTGRESQL_BUILD_DIR)
	(cd $(POSTGRESQL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POSTGRESQL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POSTGRESQL_LDFLAGS)" \
		$(POSTGRESQL_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-includes=$(STAGING_INCLUDE_DIR) \
		--with-libs=$(STAGING_LIB_DIR) \
	)
	touch $(POSTGRESQL_BUILD_DIR)/.configured

postgresql-unpack: $(POSTGRESQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POSTGRESQL_BUILD_DIR)/.built: $(POSTGRESQL_BUILD_DIR)/.configured
	rm -f $(POSTGRESQL_BUILD_DIR)/.built
	$(MAKE) -C $(POSTGRESQL_BUILD_DIR)
	touch $(POSTGRESQL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
postgresql: $(POSTGRESQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POSTGRESQL_BUILD_DIR)/.staged: $(POSTGRESQL_BUILD_DIR)/.built
	rm -f $(POSTGRESQL_BUILD_DIR)/.staged
	$(MAKE) -C $(POSTGRESQL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(POSTGRESQL_BUILD_DIR)/.staged

postgresql-stage: $(POSTGRESQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/postgresql
#
$(POSTGRESQL_IPK_DIR)/CONTROL/control:
	@install -d $(POSTGRESQL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: postgresql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POSTGRESQL_PRIORITY)" >>$@
	@echo "Section: $(POSTGRESQL_SECTION)" >>$@
	@echo "Version: $(POSTGRESQL_VERSION)-$(POSTGRESQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POSTGRESQL_MAINTAINER)" >>$@
	@echo "Source: $(POSTGRESQL_SITE)/$(POSTGRESQL_SOURCE)" >>$@
	@echo "Description: $(POSTGRESQL_DESCRIPTION)" >>$@
	@echo "Depends: $(POSTGRESQL_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POSTGRESQL_IPK_DIR)/opt/sbin or $(POSTGRESQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POSTGRESQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POSTGRESQL_IPK_DIR)/opt/etc/postgresql/...
# Documentation files should be installed in $(POSTGRESQL_IPK_DIR)/opt/doc/postgresql/...
# Daemon startup scripts should be installed in $(POSTGRESQL_IPK_DIR)/opt/etc/init.d/S??postgresql
#
# You may need to patch your application to make it use these locations.
#
$(POSTGRESQL_IPK): $(POSTGRESQL_BUILD_DIR)/.built
	rm -rf $(POSTGRESQL_IPK_DIR) $(BUILD_DIR)/postgresql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POSTGRESQL_BUILD_DIR) DESTDIR=$(POSTGRESQL_IPK_DIR) install-strip
	rm -f $(POSTGRESQL_IPK_DIR)/opt/lib/libpq.a $(POSTGRESQL_IPK_DIR)/opt/lib/libecpg*.a $(POSTGRESQL_IPK_DIR)/opt/lib/libpgtypes*.a
	$(STRIP_COMMAND) $(POSTGRESQL_IPK_DIR)/opt/bin/pg_config
#	install -d $(POSTGRESQL_IPK_DIR)/opt/etc/
#	install -m 644 $(POSTGRESQL_SOURCE_DIR)/postgresql.conf $(POSTGRESQL_IPK_DIR)/opt/etc/postgresql.conf
	install -d $(POSTGRESQL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(POSTGRESQL_SOURCE_DIR)/rc.postgresql $(POSTGRESQL_IPK_DIR)/opt/etc/init.d/S98postgresql
	$(MAKE) $(POSTGRESQL_IPK_DIR)/CONTROL/control
	install -m 755 $(POSTGRESQL_SOURCE_DIR)/postinst $(POSTGRESQL_IPK_DIR)/CONTROL/postinst
ifneq ($(OPTWARE_TARGET), nslu2)
	sed -i -e '/cp.*\/share\/hdd/d' $(POSTGRESQL_IPK_DIR)/CONTROL/postinst
endif
	install -m 755 $(POSTGRESQL_SOURCE_DIR)/prerm $(POSTGRESQL_IPK_DIR)/CONTROL/prerm
	echo $(POSTGRESQL_CONFFILES) | sed -e 's/ /\n/g' > $(POSTGRESQL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTGRESQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
postgresql-ipk: $(POSTGRESQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
postgresql-clean:
	-$(MAKE) -C $(POSTGRESQL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
postgresql-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTGRESQL_DIR) $(POSTGRESQL_BUILD_DIR) $(POSTGRESQL_IPK_DIR) $(POSTGRESQL_IPK)

#
# Some sanity check for the package.
#
postgresql-check: $(POSTGRESQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POSTGRESQL_IPK)
