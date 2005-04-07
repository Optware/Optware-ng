###########################################################
#
# libosip2
#
###########################################################

# You must replace "libosip2" and "LIBOSIP2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBOSIP2_VERSION, LIBOSIP2_SITE and LIBOSIP2_SOURCE define
# the upstream location of the source code for the package.
# LIBOSIP2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOSIP2_UNZIP is the command used to unzip the source.
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
LIBOSIP2_SITE=http://ftp.gnu.org/gnu/osip
LIBOSIP2_VERSION=2.0.9
LIBOSIP2_SOURCE=libosip2-$(LIBOSIP2_VERSION).tar.gz
LIBOSIP2_DIR=libosip2-$(LIBOSIP2_VERSION)
LIBOSIP2_UNZIP=zcat
LIBOSIP2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOSIP2_DESCRIPTION=oSIP library is an implementation of SIP - rfc3261
LIBOSIP2_SECTION=lib
LIBOSIP2_PRIORITY=optional
LIBOSIP2_DEPENDS=
LIBOSIP2_CONFLICTS=

#
# LIBOSIP2_IPK_VERSION should be incremented when the ipk changes.
#
LIBOSIP2_IPK_VERSION=1

#
# LIBOSIP2_CONFFILES should be a list of user-editable files
#LIBOSIP2_CONFFILES=/opt/etc/libosip2.conf /opt/etc/init.d/SXXlibosip2

#
# LIBOSIP2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBOSIP2_PATCHES=$(LIBOSIP2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOSIP2_CPPFLAGS=
LIBOSIP2_LDFLAGS=

#
# LIBOSIP2_BUILD_DIR is the directory in which the build is done.
# LIBOSIP2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOSIP2_IPK_DIR is the directory in which the ipk is built.
# LIBOSIP2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOSIP2_BUILD_DIR=$(BUILD_DIR)/libosip2
LIBOSIP2_SOURCE_DIR=$(SOURCE_DIR)/libosip2
LIBOSIP2_IPK_DIR=$(BUILD_DIR)/libosip2-$(LIBOSIP2_VERSION)-ipk
LIBOSIP2_IPK=$(BUILD_DIR)/libosip2_$(LIBOSIP2_VERSION)-$(LIBOSIP2_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBOSIP2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBOSIP2_SITE)/$(LIBOSIP2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libosip2-source: $(DL_DIR)/$(LIBOSIP2_SOURCE) $(LIBOSIP2_PATCHES)

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
$(LIBOSIP2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOSIP2_SOURCE) $(LIBOSIP2_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBOSIP2_DIR) $(LIBOSIP2_BUILD_DIR)
	$(LIBOSIP2_UNZIP) $(DL_DIR)/$(LIBOSIP2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBOSIP2_PATCHES) | patch -d $(BUILD_DIR)/$(LIBOSIP2_DIR) -p1
	mv $(BUILD_DIR)/$(LIBOSIP2_DIR) $(LIBOSIP2_BUILD_DIR)
	(cd $(LIBOSIP2_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOSIP2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOSIP2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(LIBOSIP2_BUILD_DIR)/.configured

libosip2-unpack: $(LIBOSIP2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOSIP2_BUILD_DIR)/.built: $(LIBOSIP2_BUILD_DIR)/.configured
	rm -f $(LIBOSIP2_BUILD_DIR)/.built
	$(MAKE) -C $(LIBOSIP2_BUILD_DIR)
	touch $(LIBOSIP2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libosip2: $(LIBOSIP2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOSIP2_BUILD_DIR)/.staged: $(LIBOSIP2_BUILD_DIR)/.built
	rm -f $(LIBOSIP2_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBOSIP2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBOSIP2_BUILD_DIR)/.staged

libosip2-stage: $(LIBOSIP2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libosip2
#
$(LIBOSIP2_IPK_DIR)/CONTROL/control:
	@install -d $(LIBOSIP2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libosip2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOSIP2_PRIORITY)" >>$@
	@echo "Section: $(LIBOSIP2_SECTION)" >>$@
	@echo "Version: $(LIBOSIP2_VERSION)-$(LIBOSIP2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOSIP2_MAINTAINER)" >>$@
	@echo "Source: $(LIBOSIP2_SITE)/$(LIBOSIP2_SOURCE)" >>$@
	@echo "Description: $(LIBOSIP2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOSIP2_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBOSIP2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOSIP2_IPK_DIR)/opt/sbin or $(LIBOSIP2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOSIP2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBOSIP2_IPK_DIR)/opt/etc/libosip2/...
# Documentation files should be installed in $(LIBOSIP2_IPK_DIR)/opt/doc/libosip2/...
# Daemon startup scripts should be installed in $(LIBOSIP2_IPK_DIR)/opt/etc/init.d/S??libosip2
#
# You may need to patch your application to make it use these locations.
#
$(LIBOSIP2_IPK): $(LIBOSIP2_BUILD_DIR)/.built
	rm -rf $(LIBOSIP2_IPK_DIR) $(BUILD_DIR)/libosip2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOSIP2_BUILD_DIR) DESTDIR=$(LIBOSIP2_IPK_DIR) install
#	install -d $(LIBOSIP2_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBOSIP2_SOURCE_DIR)/libosip2.conf $(LIBOSIP2_IPK_DIR)/opt/etc/libosip2.conf
#	install -d $(LIBOSIP2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBOSIP2_SOURCE_DIR)/rc.libosip2 $(LIBOSIP2_IPK_DIR)/opt/etc/init.d/SXXlibosip2
	$(MAKE) $(LIBOSIP2_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBOSIP2_SOURCE_DIR)/postinst $(LIBOSIP2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBOSIP2_SOURCE_DIR)/prerm $(LIBOSIP2_IPK_DIR)/CONTROL/prerm
#	echo $(LIBOSIP2_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOSIP2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOSIP2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libosip2-ipk: $(LIBOSIP2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libosip2-clean:
	-$(MAKE) -C $(LIBOSIP2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libosip2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOSIP2_DIR) $(LIBOSIP2_BUILD_DIR) $(LIBOSIP2_IPK_DIR) $(LIBOSIP2_IPK)
