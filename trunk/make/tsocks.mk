###########################################################
#
# tsocks
#
###########################################################

#
# TSOCKS_VERSION, TSOCKS_SITE and TSOCKS_SOURCE define
# the upstream location of the source code for the package.
# TSOCKS_DIR is the directory which is created when the source
# archive is unpacked.
# TSOCKS_UNZIP is the command used to unzip the source.
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
TSOCKS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tsocks
TSOCKS_VERSION=1.8beta5
TSOCKS_SOURCE=tsocks-$(TSOCKS_VERSION).tar.gz
TSOCKS_DIR=tsocks-1.8
TSOCKS_UNZIP=zcat
TSOCKS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TSOCKS_DESCRIPTION=Transparent SOCKS proxying library.
TSOCKS_SECTION=net
TSOCKS_PRIORITY=optional
TSOCKS_DEPENDS=
TSOCKS_SUGGESTS=
TSOCKS_CONFLICTS=

#
# TSOCKS_IPK_VERSION should be incremented when the ipk changes.
#
TSOCKS_IPK_VERSION=4

#
# TSOCKS_CONFFILES should be a list of user-editable files
#TSOCKS_CONFFILES=/opt/etc/tsocks.conf

#
# TSOCKS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TSOCKS_PATCHES=$(TSOCKS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TSOCKS_CPPFLAGS=
TSOCKS_LDFLAGS=

#
# TSOCKS_BUILD_DIR is the directory in which the build is done.
# TSOCKS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TSOCKS_IPK_DIR is the directory in which the ipk is built.
# TSOCKS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TSOCKS_BUILD_DIR=$(BUILD_DIR)/tsocks
TSOCKS_SOURCE_DIR=$(SOURCE_DIR)/tsocks
TSOCKS_IPK_DIR=$(BUILD_DIR)/tsocks-$(TSOCKS_VERSION)-ipk
TSOCKS_IPK=$(BUILD_DIR)/tsocks_$(TSOCKS_VERSION)-$(TSOCKS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tsocks-source tsocks-unpack tsocks tsocks-stage tsocks-ipk tsocks-clean tsocks-dirclean tsocks-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TSOCKS_SOURCE):
	$(WGET) -P $(DL_DIR) $(TSOCKS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tsocks-source: $(DL_DIR)/$(TSOCKS_SOURCE) $(TSOCKS_PATCHES)

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
$(TSOCKS_BUILD_DIR)/.configured: $(DL_DIR)/$(TSOCKS_SOURCE) $(TSOCKS_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TSOCKS_DIR) $(TSOCKS_BUILD_DIR)
	$(TSOCKS_UNZIP) $(DL_DIR)/$(TSOCKS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TSOCKS_PATCHES)" ; \
		then cat $(TSOCKS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TSOCKS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TSOCKS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TSOCKS_DIR) $(@D) ; \
	fi
	(cd $(TSOCKS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TSOCKS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TSOCKS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-conf=/opt/etc/tsocks.conf \
		--disable-nls \
	)
	touch $(@)

tsocks-unpack: $(TSOCKS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TSOCKS_BUILD_DIR)/.built: $(TSOCKS_BUILD_DIR)/.configured
	rm -f $(TSOCKS_BUILD_DIR)/.built
	$(MAKE) -C $(TSOCKS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tsocks: $(TSOCKS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TSOCKS_BUILD_DIR)/.staged: $(TSOCKS_BUILD_DIR)/.built
	rm -f $(TSOCKS_BUILD_DIR)/.staged
	$(MAKE) -C $(TSOCKS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TSOCKS_BUILD_DIR)/.staged

tsocks-stage: $(TSOCKS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tsocks
#
$(TSOCKS_IPK_DIR)/CONTROL/control:
	@install -d $(TSOCKS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tsocks" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TSOCKS_PRIORITY)" >>$@
	@echo "Section: $(TSOCKS_SECTION)" >>$@
	@echo "Version: $(TSOCKS_VERSION)-$(TSOCKS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TSOCKS_MAINTAINER)" >>$@
	@echo "Source: $(TSOCKS_SITE)/$(TSOCKS_SOURCE)" >>$@
	@echo "Description: $(TSOCKS_DESCRIPTION)" >>$@
	@echo "Depends: $(TSOCKS_DEPENDS)" >>$@
	@echo "Suggests: $(TSOCKS_SUGGESTS)" >>$@
	@echo "Conflicts: $(TSOCKS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TSOCKS_IPK_DIR)/opt/sbin or $(TSOCKS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TSOCKS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TSOCKS_IPK_DIR)/opt/etc/tsocks/...
# Documentation files should be installed in $(TSOCKS_IPK_DIR)/opt/doc/tsocks/...
# Daemon startup scripts should be installed in $(TSOCKS_IPK_DIR)/opt/etc/init.d/S??tsocks
#
# You may need to patch your application to make it use these locations.
#
$(TSOCKS_IPK): $(TSOCKS_BUILD_DIR)/.built
	rm -rf $(TSOCKS_IPK_DIR) $(BUILD_DIR)/tsocks_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TSOCKS_BUILD_DIR) DESTDIR=$(TSOCKS_IPK_DIR) install
	sed -i -e 's:/usr/:/opt/:g' $(TSOCKS_IPK_DIR)/opt/bin/tsocks
	install -d $(TSOCKS_IPK_DIR)/opt/etc/
	mv $(TSOCKS_IPK_DIR)/lib $(TSOCKS_IPK_DIR)/opt/
	$(STRIP_COMMAND) $(TSOCKS_IPK_DIR)/opt/lib/libtsocks.so.1.8
	#install -m 644 $(TSOCKS_SOURCE_DIR)/tsocks.conf $(TSOCKS_IPK_DIR)/opt/etc/tsocks.conf
	$(MAKE) $(TSOCKS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TSOCKS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tsocks-ipk: $(TSOCKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tsocks-clean:
	-$(MAKE) -C $(TSOCKS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tsocks-dirclean:
	rm -rf $(BUILD_DIR)/$(TSOCKS_DIR) $(TSOCKS_BUILD_DIR) $(TSOCKS_IPK_DIR) $(TSOCKS_IPK)
#
#
# Some sanity check for the package.
#
tsocks-check: $(TSOCKS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TSOCKS_IPK)
