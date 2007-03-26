###########################################################
#
# freetds
#
###########################################################

#
# FREETDS_VERSION, FREETDS_SITE and FREETDS_SOURCE define
# the upstream location of the source code for the package.
# FREETDS_DIR is the directory which is created when the source
# archive is unpacked.
# FREETDS_UNZIP is the command used to unzip the source.
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
FREETDS_SITE=ftp://ftp.ibiblio.org/pub/Linux/ALPHA/freetds/stable
FREETDS_VERSION=0.64
FREETDS_SOURCE=freetds-$(FREETDS_VERSION).tar.gz
FREETDS_DIR=freetds-$(FREETDS_VERSION)
FREETDS_UNZIP=zcat
FREETDS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
FREETDS_DESCRIPTION=A free re-implementation of the Tabular Data Stream protocol for Sybase or MS SQL Server.
FREETDS_SECTION=misc
FREETDS_PRIORITY=optional
FREETDS_DEPENDS=
FREETDS_SUGGESTS=
FREETDS_CONFLICTS=

#
# FREETDS_IPK_VERSION should be incremented when the ipk changes.
#
FREETDS_IPK_VERSION=3

#
# FREETDS_CONFFILES should be a list of user-editable files
FREETDS_CONFFILES=/opt/etc/freetds/freetds.conf /opt/etc/freetds/locales.conf /opt/etc/freetds/pool.conf

#
# FREETDS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FREETDS_PATCHES=$(FREETDS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FREETDS_CPPFLAGS=
FREETDS_LDFLAGS=

#
# FREETDS_BUILD_DIR is the directory in which the build is done.
# FREETDS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FREETDS_IPK_DIR is the directory in which the ipk is built.
# FREETDS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FREETDS_BUILD_DIR=$(BUILD_DIR)/freetds
FREETDS_SOURCE_DIR=$(SOURCE_DIR)/freetds
FREETDS_IPK_DIR=$(BUILD_DIR)/freetds-$(FREETDS_VERSION)-ipk
FREETDS_IPK=$(BUILD_DIR)/freetds_$(FREETDS_VERSION)-$(FREETDS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FREETDS_SOURCE):
	$(WGET) -P $(DL_DIR) $(FREETDS_SITE)/$(FREETDS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
freetds-source: $(DL_DIR)/$(FREETDS_SOURCE) $(FREETDS_PATCHES)

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
$(FREETDS_BUILD_DIR)/.configured: $(DL_DIR)/$(FREETDS_SOURCE) $(FREETDS_PATCHES)
	$(MAKE) unixodbc-stage
	rm -rf $(BUILD_DIR)/$(FREETDS_DIR) $(FREETDS_BUILD_DIR)
	$(FREETDS_UNZIP) $(DL_DIR)/$(FREETDS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(FREETDS_PATCHES) | patch -d $(BUILD_DIR)/$(FREETDS_DIR) -p1
	mv $(BUILD_DIR)/$(FREETDS_DIR) $(FREETDS_BUILD_DIR)
	(cd $(FREETDS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FREETDS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FREETDS_LDFLAGS)" \
		ac_cv_func_which_getpwuid_r=five \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc/freetds \
		--enable-msdblib \
		--enable-odbc \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(FREETDS_BUILD_DIR)/libtool
	touch $(FREETDS_BUILD_DIR)/.configured

freetds-unpack: $(FREETDS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FREETDS_BUILD_DIR)/.built: $(FREETDS_BUILD_DIR)/.configured
	rm -f $(FREETDS_BUILD_DIR)/.built
	$(MAKE) -C $(FREETDS_BUILD_DIR)
	touch $(FREETDS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
freetds: $(FREETDS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FREETDS_BUILD_DIR)/.staged: $(FREETDS_BUILD_DIR)/.built
	rm -f $(FREETDS_BUILD_DIR)/.staged
	$(MAKE) -C $(FREETDS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libct.la
	rm -f $(STAGING_LIB_DIR)/libsybdb.la
	rm -f $(STAGING_LIB_DIR)/libtds.la
	rm -f $(STAGING_LIB_DIR)/libtdssrv.la
	touch $(FREETDS_BUILD_DIR)/.staged

freetds-stage: $(FREETDS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/freetds
#
$(FREETDS_IPK_DIR)/CONTROL/control:
	@install -d $(FREETDS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: freetds" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FREETDS_PRIORITY)" >>$@
	@echo "Section: $(FREETDS_SECTION)" >>$@
	@echo "Version: $(FREETDS_VERSION)-$(FREETDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FREETDS_MAINTAINER)" >>$@
	@echo "Source: $(FREETDS_SITE)/$(FREETDS_SOURCE)" >>$@
	@echo "Description: $(FREETDS_DESCRIPTION)" >>$@
	@echo "Depends: $(FREETDS_DEPENDS)" >>$@
	@echo "Suggests: $(FREETDS_SUGGESTS)" >>$@
	@echo "Conflicts: $(FREETDS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FREETDS_IPK_DIR)/opt/sbin or $(FREETDS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FREETDS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FREETDS_IPK_DIR)/opt/etc/freetds/...
# Documentation files should be installed in $(FREETDS_IPK_DIR)/opt/doc/freetds/...
# Daemon startup scripts should be installed in $(FREETDS_IPK_DIR)/opt/etc/init.d/S??freetds
#
# You may need to patch your application to make it use these locations.
#
$(FREETDS_IPK): $(FREETDS_BUILD_DIR)/.built
	rm -rf $(FREETDS_IPK_DIR) $(BUILD_DIR)/freetds_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FREETDS_BUILD_DIR) DESTDIR=$(FREETDS_IPK_DIR) install-strip
	rm -f $(FREETDS_IPK_DIR)/opt/lib/*.la
#	install -d $(FREETDS_IPK_DIR)/opt/etc/
#	install -m 644 $(FREETDS_SOURCE_DIR)/freetds.conf $(FREETDS_IPK_DIR)/opt/etc/freetds.conf
#	install -d $(FREETDS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FREETDS_SOURCE_DIR)/rc.freetds $(FREETDS_IPK_DIR)/opt/etc/init.d/SXXfreetds
	$(MAKE) $(FREETDS_IPK_DIR)/CONTROL/control
#	install -m 755 $(FREETDS_SOURCE_DIR)/postinst $(FREETDS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FREETDS_SOURCE_DIR)/prerm $(FREETDS_IPK_DIR)/CONTROL/prerm
	echo $(FREETDS_CONFFILES) | sed -e 's/ /\n/g' > $(FREETDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREETDS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
freetds-ipk: $(FREETDS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
freetds-clean:
	rm -f $(FREETDS_BUILD_DIR)/.built
	-$(MAKE) -C $(FREETDS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
freetds-dirclean:
	rm -rf $(BUILD_DIR)/$(FREETDS_DIR) $(FREETDS_BUILD_DIR) $(FREETDS_IPK_DIR) $(FREETDS_IPK)
