###########################################################
#
# ipkg
#
###########################################################

#
# IPKG_VERSION, IPKG_SITE and IPKG_SOURCE define
# the upstream location of the source code for the package.
# IPKG_DIR is the directory which is created when the source
# archive is unpacked.
# IPKG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
IPKG_SITE=http://www.handhelds.org/packages/ipkg
IPKG_VERSION=0.99.148
IPKG_SOURCE=ipkg-$(IPKG_VERSION).tar.gz
IPKG_DIR=ipkg-$(IPKG_VERSION)
IPKG_UNZIP=zcat
IPKG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPKG_DESCRIPTION=ipkg is the Itsy Package Management System, for handling installation and removal of packages on a system
IPKG_SECTION=base
IPKG_PRIORITY=required
IPKG_DEPENDS=
IPKG_CONFLICTS=

#
# IPKG_IPK_VERSION should be incremented when the ipk changes.
#
IPKG_IPK_VERSION=3

#
# IPKG_CONFFILES should be a list of user-editable files
# IPKG_CONFFILES=

#
# IPKG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG_PATCHES=$(IPKG_SOURCE_DIR)/args.h.patch $(IPKG_SOURCE_DIR)/ipkg_conf.c.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG_CPPFLAGS=
IPKG_LDFLAGS=

#
# IPKG_BUILD_DIR is the directory in which the build is done.
# IPKG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPKG_IPK_DIR is the directory in which the ipk is built.
# IPKG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG_BUILD_DIR=$(BUILD_DIR)/ipkg
IPKG_SOURCE_DIR=$(SOURCE_DIR)/ipkg
IPKG_IPK_DIR=$(BUILD_DIR)/ipkg-$(IPKG_VERSION)-ipk
IPKG_IPK=$(BUILD_DIR)/ipkg_$(IPKG_VERSION)-$(IPKG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPKG_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPKG_SITE)/$(IPKG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipkg-source: $(DL_DIR)/$(IPKG_SOURCE) $(IPKG_PATCHES)

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
$(IPKG_BUILD_DIR)/.configured: $(DL_DIR)/$(IPKG_SOURCE) $(IPKG_PATCHES)
	rm -rf $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR)
	$(IPKG_UNZIP) $(DL_DIR)/$(IPKG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(IPKG_PATCHES) | patch -d $(BUILD_DIR)/$(IPKG_DIR) -p1
	mv $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR)
	(cd $(IPKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPKG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPKG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--libdir=/opt/lib \
		--disable-shared \
	)
	touch $(IPKG_BUILD_DIR)/.configured

ipkg-unpack: $(IPKG_BUILD_DIR)/.configured

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipkg
#
$(IPKG_IPK_DIR)/CONTROL/control:
	@install -d $(IPKG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ipkg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG_PRIORITY)" >>$@
	@echo "Section: $(IPKG_SECTION)" >>$@
	@echo "Version: $(IPKG_VERSION)-$(IPKG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG_MAINTAINER)" >>$@
	@echo "Source: $(IPKG_SITE)/$(IPKG_SOURCE)" >>$@
	@echo "Description: $(IPKG_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG_DEPENDS)" >>$@
	@echo "Conflicts: $(IPKG_CONFLICTS)" >>$@

#
#
# This builds the actual binary.
#
$(IPKG_BUILD_DIR)/.built: $(IPKG_BUILD_DIR)/.configured
	rm -f $(IPKG_BUILD_DIR)/.built
	$(MAKE) -C $(IPKG_BUILD_DIR)
	touch $(IPKG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ipkg: $(IPKG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IPKG_BUILD_DIR)/.staged: $(IPKG_BUILD_DIR)/.built
	rm -f $(IPKG_BUILD_DIR)/.staged
	$(MAKE) -C $(IPKG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(IPKG_BUILD_DIR)/.staged

ipkg-stage: $(IPKG_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG_IPK_DIR)/opt/sbin or $(IPKG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG_IPK_DIR)/opt/etc/ipkg/...
# Documentation files should be installed in $(IPKG_IPK_DIR)/opt/doc/ipkg/...
# Daemon startup scripts should be installed in $(IPKG_IPK_DIR)/opt/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#
$(IPKG_IPK): $(IPKG_BUILD_DIR)/.built
	rm -rf $(IPKG_IPK_DIR) $(BUILD_DIR)/ipkg_*_$(TARGET_ARCH).ipk
	install -d $(IPKG_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(IPKG_BUILD_DIR)/ipkg-cl -o $(IPKG_IPK_DIR)/opt/bin/ipkg
	install -m 755 $(IPKG_BUILD_DIR)/update-alternatives $(IPKG_IPK_DIR)/opt/bin/update-alternatives
ifeq ($(UNSLUNG_TARGET),wl500g)
	install -d $(IPKG_IPK_DIR)/opt/etc/init.d
	install -m 755 $(IPKG_SOURCE_DIR)/rc.unslung  $(IPKG_IPK_DIR)/opt/etc/init.d/rc.unslung
endif
	$(MAKE) $(IPKG_IPK_DIR)/CONTROL/control
	echo $(IPKG_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-ipk: $(IPKG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-clean:
	-$(MAKE) -C $(IPKG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG_DIR) $(IPKG_BUILD_DIR) $(IPKG_IPK_DIR) $(IPKG_IPK)
