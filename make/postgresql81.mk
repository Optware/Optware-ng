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
# POSTGRESQL81_VERSION, POSTGRESQL81_SITE and POSTGRESQL81_SOURCE define
# the upstream location of the source code for the package.
# POSTGRESQL81_DIR is the directory which is created when the source
# archive is unpacked.
# POSTGRESQL81_UNZIP is the command used to unzip the source.
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
POSTGRESQL81_VERSION=8.1.4
POSTGRESQL81_SITE=ftp://ftp.postgresql.org/pub/source/v$(POSTGRESQL81_VERSION)
POSTGRESQL81_SOURCE=postgresql-base-$(POSTGRESQL81_VERSION).tar.bz2
POSTGRESQL81_DIR=postgresql-$(POSTGRESQL81_VERSION)
POSTGRESQL81_UNZIP=bzcat
POSTGRESQL81_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
POSTGRESQL81_DESCRIPTION=PostgreSQL is a highly-scalable, SQL compliant, open source object-relational database management system
POSTGRESQL81_SECTION=misc
POSTGRESQL81_PRIORITY=optional
POSTGRESQL81_DEPENDS=readline
POSTGRESQL81_CONFLICTS=postgresql

#
# POSTGRESQL81_IPK_VERSION should be incremented when the ipk changes.
#
POSTGRESQL81_IPK_VERSION=1

#
# POSTGRESQL81_CONFFILES should be a list of user-editable files
#POSTGRESQL81_CONFFILES=/opt/etc/postgresql.conf /opt/etc/init.d/SXXpostgresql

#
# POSTGRESQL81_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
POSTGRESQL81_PATCHES=$(POSTGRESQL81_SOURCE_DIR)/src-timezone-Makefile.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POSTGRESQL81_CPPFLAGS=
POSTGRESQL81_LDFLAGS=

#
# POSTGRESQL81_BUILD_DIR is the directory in which the build is done.
# POSTGRESQL81_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POSTGRESQL81_IPK_DIR is the directory in which the ipk is built.
# POSTGRESQL81_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POSTGRESQL81_BUILD_DIR=$(BUILD_DIR)/postgresql81
POSTGRESQL81_SOURCE_DIR=$(SOURCE_DIR)/postgresql81
POSTGRESQL81_IPK_DIR=$(BUILD_DIR)/postgresql81-$(POSTGRESQL81_VERSION)-ipk
POSTGRESQL81_IPK=$(BUILD_DIR)/postgresql81_$(POSTGRESQL81_VERSION)-$(POSTGRESQL81_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POSTGRESQL81_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTGRESQL81_SITE)/$(POSTGRESQL81_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
postgresql81-source: $(DL_DIR)/$(POSTGRESQL81_SOURCE) $(POSTGRESQL81_PATCHES)

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
$(POSTGRESQL81_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTGRESQL81_SOURCE) $(POSTGRESQL81_PATCHES)
	$(MAKE) readline-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(POSTGRESQL81_DIR) $(POSTGRESQL81_BUILD_DIR)
	$(POSTGRESQL81_UNZIP) $(DL_DIR)/$(POSTGRESQL81_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POSTGRESQL81_PATCHES)" ; then \
		cat $(POSTGRESQL81_PATCHES) | patch -d $(BUILD_DIR)/$(POSTGRESQL81_DIR) -p1 ; \
        fi
	mv $(BUILD_DIR)/$(POSTGRESQL81_DIR) $(POSTGRESQL81_BUILD_DIR)
	(cd $(POSTGRESQL81_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POSTGRESQL81_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POSTGRESQL81_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-includes=$(STAGING_INCLUDE_DIR) \
		--with-libs=$(STAGING_LIB_DIR) \
	)
	touch $(POSTGRESQL81_BUILD_DIR)/.configured

postgresql81-unpack: $(POSTGRESQL81_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POSTGRESQL81_BUILD_DIR)/.built: $(POSTGRESQL81_BUILD_DIR)/.configured
	rm -f $(POSTGRESQL81_BUILD_DIR)/.built
	$(MAKE) -C $(POSTGRESQL81_BUILD_DIR)
	touch $(POSTGRESQL81_BUILD_DIR)/.built

#
# This is the build convenience target.
#
postgresql81: $(POSTGRESQL81_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POSTGRESQL81_BUILD_DIR)/.staged: $(POSTGRESQL81_BUILD_DIR)/.built
	rm -f $(POSTGRESQL81_BUILD_DIR)/.staged
	$(MAKE) -C $(POSTGRESQL81_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-strip
	touch $(POSTGRESQL81_BUILD_DIR)/.staged

postgresql81-stage: $(POSTGRESQL81_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/postgresql
#
$(POSTGRESQL81_IPK_DIR)/CONTROL/control:
	@install -d $(POSTGRESQL81_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: postgresql81" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POSTGRESQL81_PRIORITY)" >>$@
	@echo "Section: $(POSTGRESQL81_SECTION)" >>$@
	@echo "Version: $(POSTGRESQL81_VERSION)-$(POSTGRESQL81_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POSTGRESQL81_MAINTAINER)" >>$@
	@echo "Source: $(POSTGRESQL81_SITE)/$(POSTGRESQL81_SOURCE)" >>$@
	@echo "Description: $(POSTGRESQL81_DESCRIPTION)" >>$@
	@echo "Depends: $(POSTGRESQL81_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POSTGRESQL81_IPK_DIR)/opt/sbin or $(POSTGRESQL81_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POSTGRESQL81_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POSTGRESQL81_IPK_DIR)/opt/etc/postgresql/...
# Documentation files should be installed in $(POSTGRESQL81_IPK_DIR)/opt/doc/postgresql/...
# Daemon startup scripts should be installed in $(POSTGRESQL81_IPK_DIR)/opt/etc/init.d/S??postgresql
#
# You may need to patch your application to make it use these locations.
#
$(POSTGRESQL81_IPK): $(POSTGRESQL81_BUILD_DIR)/.built
	rm -rf $(POSTGRESQL81_IPK_DIR) $(BUILD_DIR)/postgresql81_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POSTGRESQL81_BUILD_DIR) DESTDIR=$(POSTGRESQL81_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(POSTGRESQL81_IPK_DIR)/opt/bin/pg_config
#	install -d $(POSTGRESQL81_IPK_DIR)/opt/etc/
#	install -m 644 $(POSTGRESQL81_SOURCE_DIR)/postgresql.conf $(POSTGRESQL81_IPK_DIR)/opt/etc/postgresql.conf
	install -d $(POSTGRESQL81_IPK_DIR)/opt/etc/init.d
	install -m 755 $(POSTGRESQL81_SOURCE_DIR)/rc.postgresql $(POSTGRESQL81_IPK_DIR)/opt/etc/init.d/S98postgresql81
	$(MAKE) $(POSTGRESQL81_IPK_DIR)/CONTROL/control
	install -m 755 $(POSTGRESQL81_SOURCE_DIR)/postinst $(POSTGRESQL81_IPK_DIR)/CONTROL/postinst
	install -m 755 $(POSTGRESQL81_SOURCE_DIR)/prerm $(POSTGRESQL81_IPK_DIR)/CONTROL/prerm
	echo $(POSTGRESQL81_CONFFILES) | sed -e 's/ /\n/g' > $(POSTGRESQL81_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTGRESQL81_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
postgresql81-ipk: $(POSTGRESQL81_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
postgresql81-clean:
	-$(MAKE) -C $(POSTGRESQL81_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
postgresql81-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTGRESQL81_DIR) $(POSTGRESQL81_BUILD_DIR) $(POSTGRESQL81_IPK_DIR) $(POSTGRESQL81_IPK)
