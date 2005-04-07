###########################################################
#
# siproxd
#
###########################################################

# You must replace "siproxd" and "SIPROXD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SIPROXD_VERSION, SIPROXD_SITE and SIPROXD_SOURCE define
# the upstream location of the source code for the package.
# SIPROXD_DIR is the directory which is created when the source
# archive is unpacked.
# SIPROXD_UNZIP is the command used to unzip the source.
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
SIPROXD_SITE=http://switch.dl.sourceforge.net/sourceforge/siproxd
SIPROXD_VERSION=0.5.10
SIPROXD_SOURCE=siproxd-$(SIPROXD_VERSION).tar.gz
SIPROXD_DIR=siproxd-$(SIPROXD_VERSION)
SIPROXD_UNZIP=zcat
SIPROXD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SIPROXD_DESCRIPTION=Siproxd is a proxy/masquerading daemon for the SIP protocol
SIPROXD_SECTION=net
SIPROXD_PRIORITY=optional
SIPROXD_DEPENDS=libosip2
SIPROXD_CONFLICTS=

#
# SIPROXD_IPK_VERSION should be incremented when the ipk changes.
#
SIPROXD_IPK_VERSION=1

#
# SIPROXD_CONFFILES should be a list of user-editable files
SIPROXD_CONFFILES=/opt/etc/init.d/S98siproxd

#
# SIPROXD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SIPROXD_PATCHES=$(SIPROXD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SIPROXD_CPPFLAGS=
SIPROXD_LDFLAGS=

#
# SIPROXD_BUILD_DIR is the directory in which the build is done.
# SIPROXD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SIPROXD_IPK_DIR is the directory in which the ipk is built.
# SIPROXD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SIPROXD_BUILD_DIR=$(BUILD_DIR)/siproxd
SIPROXD_SOURCE_DIR=$(SOURCE_DIR)/siproxd
SIPROXD_IPK_DIR=$(BUILD_DIR)/siproxd-$(SIPROXD_VERSION)-ipk
SIPROXD_IPK=$(BUILD_DIR)/siproxd_$(SIPROXD_VERSION)-$(SIPROXD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SIPROXD_SOURCE):
	$(WGET) -P $(DL_DIR) $(SIPROXD_SITE)/$(SIPROXD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
siproxd-source: $(DL_DIR)/$(SIPROXD_SOURCE) $(SIPROXD_PATCHES)

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
$(SIPROXD_BUILD_DIR)/.configured: $(DL_DIR)/$(SIPROXD_SOURCE) $(SIPROXD_PATCHES)
	$(MAKE) libosip2-stage
	rm -rf $(BUILD_DIR)/$(SIPROXD_DIR) $(SIPROXD_BUILD_DIR)
	$(SIPROXD_UNZIP) $(DL_DIR)/$(SIPROXD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#       cat $(SIPROXD_PATCHES) | patch -d $(BUILD_DIR)/$(SIPROXD_DIR) -p1
	mv $(BUILD_DIR)/$(SIPROXD_DIR) $(SIPROXD_BUILD_DIR)
	(cd $(SIPROXD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SIPROXD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SIPROXD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(SIPROXD_BUILD_DIR)/.configured

siproxd-unpack: $(SIPROXD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SIPROXD_BUILD_DIR)/.built: $(SIPROXD_BUILD_DIR)/.configured
	rm -f $(SIPROXD_BUILD_DIR)/.built
	$(MAKE) -C $(SIPROXD_BUILD_DIR)
	touch $(SIPROXD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
siproxd: $(SIPROXD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SIPROXD_BUILD_DIR)/.staged: $(SIPROXD_BUILD_DIR)/.built
	rm -f $(SIPROXD_BUILD_DIR)/.staged
	$(MAKE) -C $(SIPROXD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SIPROXD_BUILD_DIR)/.staged

siproxd-stage: $(SIPROXD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/siproxd
#
$(SIPROXD_IPK_DIR)/CONTROL/control:
	@install -d $(SIPROXD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: siproxd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SIPROXD_PRIORITY)" >>$@
	@echo "Section: $(SIPROXD_SECTION)" >>$@
	@echo "Version: $(SIPROXD_VERSION)-$(SIPROXD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SIPROXD_MAINTAINER)" >>$@
	@echo "Source: $(SIPROXD_SITE)/$(SIPROXD_SOURCE)" >>$@
	@echo "Description: $(SIPROXD_DESCRIPTION)" >>$@
	@echo "Depends: $(SIPROXD_DEPENDS)" >>$@
	@echo "Conflicts: $(SIPROXD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SIPROXD_IPK_DIR)/opt/sbin or $(SIPROXD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SIPROXD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SIPROXD_IPK_DIR)/opt/etc/siproxd/...
# Documentation files should be installed in $(SIPROXD_IPK_DIR)/opt/doc/siproxd/...
# Daemon startup scripts should be installed in $(SIPROXD_IPK_DIR)/opt/etc/init.d/S??siproxd
#
# You may need to patch your application to make it use these locations.
#
$(SIPROXD_IPK): $(SIPROXD_BUILD_DIR)/.built
	rm -rf $(SIPROXD_IPK_DIR) $(BUILD_DIR)/siproxd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SIPROXD_BUILD_DIR) DESTDIR=$(SIPROXD_IPK_DIR) install
	$(STRIP_COMMAND) $(SIPROXD_IPK_DIR)/opt/sbin/siproxd
#	install -d $(SIPROXD_IPK_DIR)/opt/etc/
#	install -m 644 $(SIPROXD_SOURCE_DIR)/siproxd.conf $(SIPROXD_IPK_DIR)/opt/etc/siproxd.conf
	install -d $(SIPROXD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SIPROXD_SOURCE_DIR)/rc.siproxd $(SIPROXD_IPK_DIR)/opt/etc/init.d/S98siproxd
	$(MAKE) $(SIPROXD_IPK_DIR)/CONTROL/control
	install -m 755 $(SIPROXD_SOURCE_DIR)/postinst $(SIPROXD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SIPROXD_SOURCE_DIR)/prerm $(SIPROXD_IPK_DIR)/CONTROL/prerm
	echo $(SIPROXD_CONFFILES) | sed -e 's/ /\n/g' > $(SIPROXD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SIPROXD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
siproxd-ipk: $(SIPROXD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
siproxd-clean:
	-$(MAKE) -C $(SIPROXD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
siproxd-dirclean:
	rm -rf $(BUILD_DIR)/$(SIPROXD_DIR) $(SIPROXD_BUILD_DIR) $(SIPROXD_IPK_DIR) $(SIPROXD_IPK)
