###########################################################
#
# dspam
#
###########################################################

# DSPAM_VERSION, DSPAM_SITE and DSPAM_SOURCE define
# the upstream location of the source code for the package.
# DSPAM_DIR is the directory which is created when the source
# archive is unpacked.
# DSPAM_UNZIP is the command used to unzip the source.
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
DSPAM_SITE=http://dspam.nuclearelephant.com/sources
DSPAM_VERSION=3.6.8
DSPAM_SOURCE=dspam-$(DSPAM_VERSION).tar.gz
DSPAM_DIR=dspam-$(DSPAM_VERSION)
DSPAM_UNZIP=zcat
DSPAM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DSPAM_DESCRIPTION=DSPAM is a scalable and open-source content-based spam filter designed for multi-user enterprise systems. 
DSPAM_SECTION=util
DSPAM_PRIORITY=optional
DSPAM_DEPENDS=
DSPAM_SUGGESTS=dspam-pgsql, dspam-mysql
DSPAM_CONFLICTS=

#
# DSPAM_IPK_VERSION should be incremented when the ipk changes.
#
DSPAM_IPK_VERSION=2

#
# DSPAM_CONFFILES should be a list of user-editable files
DSPAM_CONFFILES=/opt/etc/dspam.conf /opt/etc/init.d/SXXdspam

#
# DSPAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DSPAM_PATCHES=$(DSPAM_SOURCE_DIR)/dspam-configure-cross.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DSPAM_CPPFLAGS=
DSPAM_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
DSPAM_LDFLAGS += -lpthread
endif

#
# DSPAM_BUILD_DIR is the directory in which the build is done.
# DSPAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DSPAM_IPK_DIR is the directory in which the ipk is built.
# DSPAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DSPAM_BUILD_DIR=$(BUILD_DIR)/dspam
DSPAM_SOURCE_DIR=$(SOURCE_DIR)/dspam
DSPAM_IPK_DIR=$(BUILD_DIR)/dspam-$(DSPAM_VERSION)-ipk
DSPAM_IPK=$(BUILD_DIR)/dspam_$(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)_$(TARGET_ARCH).ipk
DSPAM_PGSQL_IPK_DIR=$(BUILD_DIR)/dspam-$(DSPAM_VERSION)-ipk-pgsql
DSPAM_PGSQL_IPK=$(BUILD_DIR)/dspam-pgsql_$(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)_$(TARGET_ARCH).ipk
DSPAM_MYSQL_IPK_DIR=$(BUILD_DIR)/dspam-$(DSPAM_VERSION)-ipk-mysql
DSPAM_MYSQL_IPK=$(BUILD_DIR)/dspam-mysql_$(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DSPAM_SOURCE):
	$(WGET) -P $(DL_DIR) $(DSPAM_SITE)/$(DSPAM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dspam-source: $(DL_DIR)/$(DSPAM_SOURCE) $(DSPAM_PATCHES)

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
$(DSPAM_BUILD_DIR)/.configured: $(DL_DIR)/$(DSPAM_SOURCE) $(DSPAM_PATCHES) make/dspam.mk
	$(MAKE) mysql-stage postgresql-stage zlib-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(DSPAM_DIR) $(DSPAM_BUILD_DIR)
	$(DSPAM_UNZIP) $(DL_DIR)/$(DSPAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DSPAM_PATCHES)" ; \
		then cat $(DSPAM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DSPAM_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DSPAM_DIR)" != "$(DSPAM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DSPAM_DIR) $(DSPAM_BUILD_DIR) ; \
	fi
	(cd $(DSPAM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DSPAM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DSPAM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	  	--with-storage-driver=hash_drv,mysql_drv,pgsql_drv \
		--with-mysql-includes=$(STAGING_INCLUDE_DIR)/mysql \
		--with-mysql-libraries=$(STAGING_LIB_DIR)/mysql \
		--with-pgsql-includes=$(STAGING_INCLUDE_DIR) \
		--with-pgsql-libraries=$(STAGING_LIB_DIR) \
		--enable-daemon \
		--enable-clamav \
	)
	$(PATCH_LIBTOOL) $(DSPAM_BUILD_DIR)/libtool
	touch $(DSPAM_BUILD_DIR)/.configured

dspam-unpack: $(DSPAM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DSPAM_BUILD_DIR)/.built: $(DSPAM_BUILD_DIR)/.configured
	rm -f $(DSPAM_BUILD_DIR)/.built
	$(MAKE) -C $(DSPAM_BUILD_DIR)
	touch $(DSPAM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dspam: $(DSPAM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DSPAM_BUILD_DIR)/.staged: $(DSPAM_BUILD_DIR)/.built
	rm -f $(DSPAM_BUILD_DIR)/.staged
	$(MAKE) -C $(DSPAM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DSPAM_BUILD_DIR)/.staged

dspam-stage: $(DSPAM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dspam
#
$(DSPAM_IPK_DIR)/CONTROL/control:
	@install -d $(DSPAM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dspam" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DSPAM_PRIORITY)" >>$@
	@echo "Section: $(DSPAM_SECTION)" >>$@
	@echo "Version: $(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DSPAM_MAINTAINER)" >>$@
	@echo "Source: $(DSPAM_SITE)/$(DSPAM_SOURCE)" >>$@
	@echo "Description: $(DSPAM_DESCRIPTION)" >>$@
	@echo "Depends: $(DSPAM_DEPENDS)" >>$@
	@echo "Suggests: $(DSPAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(DSPAM_CONFLICTS)" >>$@

$(DSPAM_PGSQL_IPK_DIR)/CONTROL/control:
	@install -d $(DSPAM_PGSQL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dspam-pgsql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DSPAM_PRIORITY)" >>$@
	@echo "Section: $(DSPAM_SECTION)" >>$@
	@echo "Version: $(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DSPAM_MAINTAINER)" >>$@
	@echo "Source: $(DSPAM_SITE)/$(DSPAM_SOURCE)" >>$@
	@echo "Description: $(DSPAM_DESCRIPTION)" >>$@
	@echo "Depends: dspam, postgresql" >>$@
	@echo "Suggests: $(DSPAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(DSPAM_CONFLICTS)" >>$@

$(DSPAM_MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(DSPAM_MYSQL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dspam-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DSPAM_PRIORITY)" >>$@
	@echo "Section: $(DSPAM_SECTION)" >>$@
	@echo "Version: $(DSPAM_VERSION)-$(DSPAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DSPAM_MAINTAINER)" >>$@
	@echo "Source: $(DSPAM_SITE)/$(DSPAM_SOURCE)" >>$@
	@echo "Description: $(DSPAM_DESCRIPTION)" >>$@
	@echo "Depends: dspam, mysql" >>$@
	@echo "Suggests: $(DSPAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(DSPAM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DSPAM_IPK_DIR)/opt/sbin or $(DSPAM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DSPAM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DSPAM_IPK_DIR)/opt/etc/dspam/...
# Documentation files should be installed in $(DSPAM_IPK_DIR)/opt/doc/dspam/...
# Daemon startup scripts should be installed in $(DSPAM_IPK_DIR)/opt/etc/init.d/S??dspam
#
# You may need to patch your application to make it use these locations.
#
$(DSPAM_IPK): $(DSPAM_BUILD_DIR)/.built
	rm -rf $(DSPAM_IPK_DIR) $(BUILD_DIR)/dspam_*_$(TARGET_ARCH).ipk
	rm -rf $(DSPAM_PGSQL_IPK_DIR) $(BUILD_DIR)/dspam-pgsql_*_$(TARGET_ARCH).ipk
	rm -rf $(DSPAM_MYSQL_IPK_DIR) $(BUILD_DIR)/dspam-mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DSPAM_BUILD_DIR) DESTDIR=$(DSPAM_IPK_DIR) install-strip
#	install -d $(DSPAM_IPK_DIR)/opt/etc/
#	install -m 644 $(DSPAM_SOURCE_DIR)/dspam.conf $(DSPAM_IPK_DIR)/opt/etc/dspam.conf
#	install -d $(DSPAM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DSPAM_SOURCE_DIR)/rc.dspam $(DSPAM_IPK_DIR)/opt/etc/init.d/SXXdspam

	# Split into the different packages
	install -d $(DSPAM_PGSQL_IPK_DIR)/opt/lib
	mv $(DSPAM_IPK_DIR)/opt/lib/libpgsql* $(DSPAM_PGSQL_IPK_DIR)/opt/lib
	$(MAKE) $(DSPAM_PGSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DSPAM_PGSQL_IPK_DIR)
	install -d $(DSPAM_MYSQL_IPK_DIR)/opt/lib
	mv $(DSPAM_IPK_DIR)/opt/lib/libmysql* $(DSPAM_MYSQL_IPK_DIR)/opt/lib
	$(MAKE) $(DSPAM_MYSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DSPAM_MYSQL_IPK_DIR)

	$(MAKE) $(DSPAM_IPK_DIR)/CONTROL/control
#	install -m 755 $(DSPAM_SOURCE_DIR)/postinst $(DSPAM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DSPAM_SOURCE_DIR)/prerm $(DSPAM_IPK_DIR)/CONTROL/prerm
#	echo $(DSPAM_CONFFILES) | sed -e 's/ /\n/g' > $(DSPAM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DSPAM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dspam-ipk: $(DSPAM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dspam-clean:
	rm -f $(DSPAM_BUILD_DIR)/.built
	-$(MAKE) -C $(DSPAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dspam-dirclean:
	rm -rf $(BUILD_DIR)/$(DSPAM_DIR) $(DSPAM_BUILD_DIR) $(DSPAM_IPK_DIR) $(DSPAM_IPK)
	rm -rf $(DSPAM_PGSQL_IPK_DIR) $(DSPAM_PGSQL_IPK)
	rm -rf $(DSPAM_MYSQL_IPK_DIR) $(DSPAM_MYSQL_IPK)
