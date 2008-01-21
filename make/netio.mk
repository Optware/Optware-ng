###########################################################
#
# netio
#
###########################################################
#
# $Id$
#
# Warning: This package doesn't compile native!!!!
#          The source is distributed in zip 2 format and busybox unzip
#          will not work.
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
NETIO_SITE=http://hobbes.nmsu.edu/pub/os2/util/network
NETIO_VERSION=123
NETIO_SOURCE=netio$(NETIO_VERSION).zip
NETIO_DIR=netio
NETIO_UNZIP=unzip
NETIO_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
NETIO_DESCRIPTION=A program to test network throughput
NETIO_SECTION=net
NETIO_PRIORITY=optional
NETIO_DEPENDS=
NETIO_SUGGESTS=
NETIO_CONFLICTS=

#
# NETIO_IPK_VERSION should be incremented when the ipk changes.
#
NETIO_IPK_VERSION=3

#
# NETIO_CONFFILES should be a list of user-editable files
NETIO_CONFFILES=""

#
# NETIO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NETIO_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETIO_CPPFLAGS=
NETIO_LDFLAGS=

#
# NETIO_BUILD_DIR is the directory in which the build is done.
# NETIO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETIO_IPK_DIR is the directory in which the ipk is built.
# NETIO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETIO_BUILD_DIR=$(BUILD_DIR)/netio
NETIO_SOURCE_DIR=$(SOURCE_DIR)/netio
NETIO_IPK_DIR=$(BUILD_DIR)/netio-$(NETIO_VERSION)-ipk
NETIO_IPK=$(BUILD_DIR)/netio_$(NETIO_VERSION)-$(NETIO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETIO_SOURCE):
	$(WGET) -P $(DL_DIR) $(NETIO_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netio-source: $(DL_DIR)/$(NETIO_SOURCE) $(NETIO_PATCHES)

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
$(NETIO_BUILD_DIR)/.configured: $(DL_DIR)/$(NETIO_SOURCE) $(NETIO_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(NETIO_BUILD_DIR)
	mkdir -p $(NETIO_BUILD_DIR)
	cd $(NETIO_BUILD_DIR);unzip $(DL_DIR)/$(NETIO_SOURCE)
#	cat $(NETIO_PATCHES) | patch -d $(BUILD_DIR)/$(NETIO_DIR) -p1
	touch $(NETIO_BUILD_DIR)/.configured

netio-unpack: $(NETIO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETIO_BUILD_DIR)/.built: $(NETIO_BUILD_DIR)/.configured
	rm -f $(NETIO_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETIO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETIO_LDFLAGS)" \
		$(MAKE) -C $(NETIO_BUILD_DIR) O=.o X= CFLAGS="-DUNIX" LFLAGS="" LIBS="-lpthread" OUT=-o all
	touch $(NETIO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
netio: $(NETIO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETIO_BUILD_DIR)/.staged: $(NETIO_BUILD_DIR)/.built
	rm -f $(NETIO_BUILD_DIR)/.staged
	$(MAKE) -C $(NETIO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NETIO_BUILD_DIR)/.staged

netio-stage: $(NETIO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netio
#
$(NETIO_IPK_DIR)/CONTROL/control:
	@install -d $(NETIO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: netio" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETIO_PRIORITY)" >>$@
	@echo "Section: $(NETIO_SECTION)" >>$@
	@echo "Version: $(NETIO_VERSION)-$(NETIO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETIO_MAINTAINER)" >>$@
	@echo "Source: $(NETIO_SITE)/$(NETIO_SOURCE)" >>$@
	@echo "Description: $(NETIO_DESCRIPTION)" >>$@
	@echo "Depends: $(NETIO_DEPENDS)" >>$@
	@echo "Suggests: $(NETIO_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETIO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETIO_IPK_DIR)/opt/sbin or $(NETIO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETIO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETIO_IPK_DIR)/opt/etc/netio/...
# Documentation files should be installed in $(NETIO_IPK_DIR)/opt/doc/netio/...
# Daemon startup scripts should be installed in $(NETIO_IPK_DIR)/opt/etc/init.d/S??netio
#
# You may need to patch your application to make it use these locations.
#
$(NETIO_IPK): $(NETIO_BUILD_DIR)/.built
	rm -rf $(NETIO_IPK_DIR) $(BUILD_DIR)/netio_*_$(TARGET_ARCH).ipk
	install -d $(NETIO_IPK_DIR)/opt/bin
	install -m 755 $(NETIO_BUILD_DIR)/netio $(NETIO_IPK_DIR)/opt/bin/netio
	$(MAKE) $(NETIO_IPK_DIR)/CONTROL/control
	$(STRIP_COMMAND) $(NETIO_IPK_DIR)/opt/bin/netio
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETIO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netio-ipk: $(NETIO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netio-clean:
	-$(MAKE) -C $(NETIO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netio-dirclean:
	rm -rf $(BUILD_DIR)/$(NETIO_DIR) $(NETIO_BUILD_DIR) $(NETIO_IPK_DIR) $(NETIO_IPK)
