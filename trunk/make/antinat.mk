###########################################################
#
# antinat
#
###########################################################

# You must replace "antinat" and "ANTINAT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ANTINAT_VERSION, ANTINAT_SITE and ANTINAT_SOURCE define
# the upstream location of the source code for the package.
# ANTINAT_DIR is the directory which is created when the source
# archive is unpacked.
# ANTINAT_UNZIP is the command used to unzip the source.
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
ANTINAT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/antinat
ANTINAT_VERSION=0.90
ANTINAT_SOURCE=antinat-$(ANTINAT_VERSION).tar.bz2
ANTINAT_DIR=antinat-$(ANTINAT_VERSION)
ANTINAT_UNZIP=bzcat
ANTINAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ANTINAT_DESCRIPTION=Antinat is a flexible SOCKS server and client library for writing proxy-based applications.
ANTINAT_SECTION=net
ANTINAT_PRIORITY=optional
ANTINAT_DEPENDS=expat
ANTINAT_SUGGESTS=
ANTINAT_CONFLICTS=

#
# ANTINAT_IPK_VERSION should be incremented when the ipk changes.
#
ANTINAT_IPK_VERSION=4

#
# ANTINAT_CONFFILES should be a list of user-editable files
ANTINAT_CONFFILES=/opt/etc/antinat.xml

#
# ANTINAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ANTINAT_PATCHES=$(ANTINAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ANTINAT_CPPFLAGS=
ANTINAT_LDFLAGS=

#
# ANTINAT_BUILD_DIR is the directory in which the build is done.
# ANTINAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ANTINAT_IPK_DIR is the directory in which the ipk is built.
# ANTINAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ANTINAT_BUILD_DIR=$(BUILD_DIR)/antinat
ANTINAT_SOURCE_DIR=$(SOURCE_DIR)/antinat
ANTINAT_IPK_DIR=$(BUILD_DIR)/antinat-$(ANTINAT_VERSION)-ipk
ANTINAT_IPK=$(BUILD_DIR)/antinat_$(ANTINAT_VERSION)-$(ANTINAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: antinat-source antinat-unpack antinat antinat-stage antinat-ipk antinat-clean antinat-dirclean antinat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ANTINAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(ANTINAT_SITE)/$(ANTINAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
antinat-source: $(DL_DIR)/$(ANTINAT_SOURCE) $(ANTINAT_PATCHES)

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
$(ANTINAT_BUILD_DIR)/.configured: $(DL_DIR)/$(ANTINAT_SOURCE) $(ANTINAT_PATCHES)
	$(MAKE) expat-stage
	rm -rf $(BUILD_DIR)/$(ANTINAT_DIR) $(ANTINAT_BUILD_DIR)
	$(ANTINAT_UNZIP) $(DL_DIR)/$(ANTINAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ANTINAT_DIR) $(ANTINAT_BUILD_DIR)
	(cd $(ANTINAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ANTINAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ANTINAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	sed -ie 's|-I$$includedir|-I$(STAGING_INCLUDE_DIR)|' $(ANTINAT_BUILD_DIR)/client/antinat-config
	$(PATCH_LIBTOOL) $(ANTINAT_BUILD_DIR)/libtool
	touch $(ANTINAT_BUILD_DIR)/.configured

antinat-unpack: $(ANTINAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ANTINAT_BUILD_DIR)/.built: $(ANTINAT_BUILD_DIR)/.configured
	rm -f $(ANTINAT_BUILD_DIR)/.built
	$(MAKE) -C $(ANTINAT_BUILD_DIR)
	touch $(ANTINAT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
antinat: $(ANTINAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ANTINAT_BUILD_DIR)/.staged: $(ANTINAT_BUILD_DIR)/.built
	rm -f $(ANTINAT_BUILD_DIR)/.staged
	$(MAKE) -C $(ANTINAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ANTINAT_BUILD_DIR)/.staged

antinat-stage: $(ANTINAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/antinat
#
$(ANTINAT_IPK_DIR)/CONTROL/control:
	@install -d $(ANTINAT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: antinat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ANTINAT_PRIORITY)" >>$@
	@echo "Section: $(ANTINAT_SECTION)" >>$@
	@echo "Version: $(ANTINAT_VERSION)-$(ANTINAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ANTINAT_MAINTAINER)" >>$@
	@echo "Source: $(ANTINAT_SITE)/$(ANTINAT_SOURCE)" >>$@
	@echo "Description: $(ANTINAT_DESCRIPTION)" >>$@
	@echo "Depends: $(ANTINAT_DEPENDS)" >>$@
	@echo "Suggests: $(ANTINAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(ANTINAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ANTINAT_IPK_DIR)/opt/sbin or $(ANTINAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ANTINAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ANTINAT_IPK_DIR)/opt/etc/antinat/...
# Documentation files should be installed in $(ANTINAT_IPK_DIR)/opt/doc/antinat/...
# Daemon startup scripts should be installed in $(ANTINAT_IPK_DIR)/opt/etc/init.d/S??antinat
#
# You may need to patch your application to make it use these locations.
#
$(ANTINAT_IPK): $(ANTINAT_BUILD_DIR)/.built
	rm -rf $(ANTINAT_IPK_DIR) $(BUILD_DIR)/antinat_*_$(TARGET_ARCH).ipk
	( cd $(ANTINAT_BUILD_DIR) ; make install prefix=$(ANTINAT_IPK_DIR)/opt )
	rm -f $(ANTINAT_IPK_DIR)/opt/lib/libantinat.a
	$(STRIP_COMMAND) $(ANTINAT_IPK_DIR)/opt/lib/libantinat.so.0.0.0
	$(STRIP_COMMAND) $(ANTINAT_IPK_DIR)/opt/bin/antinat
	$(MAKE) $(ANTINAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(ANTINAT_SOURCE_DIR)/postinst $(ANTINAT_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ANTINAT_SOURCE_DIR)/prerm $(ANTINAT_IPK_DIR)/CONTROL/prerm
	echo $(ANTINAT_CONFFILES) | sed -e 's/ /\n/g' > $(ANTINAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ANTINAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
antinat-ipk: $(ANTINAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
antinat-clean:
	-$(MAKE) -C $(ANTINAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
antinat-dirclean:
	rm -rf $(BUILD_DIR)/$(ANTINAT_DIR) $(ANTINAT_BUILD_DIR) $(ANTINAT_IPK_DIR) $(ANTINAT_IPK)

#
# Some sanity check for the package.
#
antinat-check: $(ANTINAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ANTINAT_IPK)
