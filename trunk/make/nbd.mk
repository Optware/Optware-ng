###########################################################
#
# nbd
#
###########################################################
#
# NBD_VERSION, NBD_SITE and NBD_SOURCE define
# the upstream location of the source code for the package.
# NBD_DIR is the directory which is created when the source
# archive is unpacked.
# NBD_UNZIP is the command used to unzip the source.
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
NBD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nbd
NBD_VERSION=2.9.0
NBD_SOURCE=nbd-$(NBD_VERSION).tar.bz2
NBD_DIR=nbd-$(NBD_VERSION)
NBD_UNZIP=bzcat
NBD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NBD_DESCRIPTION=Network Block Device.
NBD_SECTION=misc
NBD_PRIORITY=optional
NBD_DEPENDS=
NBD_SUGGESTS=
NBD_CONFLICTS=

#
# NBD_IPK_VERSION should be incremented when the ipk changes.
#
NBD_IPK_VERSION=1

#
# NBD_CONFFILES should be a list of user-editable files
#NBD_CONFFILES=/opt/etc/nbd.conf /opt/etc/init.d/SXXnbd

#
# NBD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# NBD_PATCHES=$(NBD_SOURCE_DIR)/configure.ac.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NBD_CPPFLAGS=
NBD_LDFLAGS=

#
# NBD_BUILD_DIR is the directory in which the build is done.
# NBD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NBD_IPK_DIR is the directory in which the ipk is built.
# NBD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NBD_BUILD_DIR=$(BUILD_DIR)/nbd
NBD_SOURCE_DIR=$(SOURCE_DIR)/nbd

NBD_IPK=$(BUILD_DIR)/nbd_$(NBD_VERSION)-$(NBD_IPK_VERSION)_$(TARGET_ARCH).ipk

NBD-CLIENT_IPK_DIR=$(BUILD_DIR)/nbd-client-$(NBD_VERSION)-ipk
NBD-CLIENT_IPK=$(BUILD_DIR)/nbd-client_$(NBD_VERSION)-$(NBD_IPK_VERSION)_$(TARGET_ARCH).ipk
NBD-SERVER_IPK_DIR=$(BUILD_DIR)/nbd-server-$(NBD_VERSION)-ipk
NBD-SERVER_IPK=$(BUILD_DIR)/nbd-server_$(NBD_VERSION)-$(NBD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nbd-source nbd-unpack nbd nbd-stage nbd-ipk nbd-clean nbd-dirclean nbd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NBD_SOURCE):
	$(WGET) -P $(DL_DIR) $(NBD_SITE)/$(NBD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nbd-source: $(DL_DIR)/$(NBD_SOURCE) $(NBD_PATCHES)

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
$(NBD_BUILD_DIR)/.configured: $(DL_DIR)/$(NBD_SOURCE) $(NBD_PATCHES) make/nbd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NBD_DIR) $(NBD_BUILD_DIR)
	$(NBD_UNZIP) $(DL_DIR)/$(NBD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NBD_PATCHES)" ; \
		then cat $(NBD_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(NBD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NBD_DIR)" != "$(NBD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NBD_DIR) $(NBD_BUILD_DIR) ; \
	fi
	(cd $(NBD_BUILD_DIR); \
		cp $(NBD_SOURCE_DIR)/linux-2.6.18-nbd.h nbd.h; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NBD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NBD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(NBD_BUILD_DIR)/libtool
	touch $(NBD_BUILD_DIR)/.configured

nbd-unpack: $(NBD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NBD_BUILD_DIR)/.built: $(NBD_BUILD_DIR)/.configured
	rm -f $(NBD_BUILD_DIR)/.built
	$(MAKE) -C $(NBD_BUILD_DIR)
	touch $(NBD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nbd: $(NBD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NBD_BUILD_DIR)/.staged: $(NBD_BUILD_DIR)/.built
	rm -f $(NBD_BUILD_DIR)/.staged
	$(MAKE) -C $(NBD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NBD_BUILD_DIR)/.staged

nbd-stage: $(NBD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nbd
#
$(NBD-CLIENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nbd-client" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NBD_PRIORITY)" >>$@
	@echo "Section: $(NBD_SECTION)" >>$@
	@echo "Version: $(NBD_VERSION)-$(NBD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NBD_MAINTAINER)" >>$@
	@echo "Source: $(NBD_SITE)/$(NBD_SOURCE)" >>$@
	@echo "Description: $(NBD_DESCRIPTION)" >>$@
	@echo "Depends: $(NBD_DEPENDS)" >>$@
	@echo "Suggests: $(NBD_SUGGESTS)" >>$@
	@echo "Conflicts: $(NBD_CONFLICTS)" >>$@

$(NBD-SERVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nbd-server" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NBD_PRIORITY)" >>$@
	@echo "Section: $(NBD_SECTION)" >>$@
	@echo "Version: $(NBD_VERSION)-$(NBD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NBD_MAINTAINER)" >>$@
	@echo "Source: $(NBD_SITE)/$(NBD_SOURCE)" >>$@
	@echo "Description: $(NBD_DESCRIPTION)" >>$@
	@echo "Depends: $(NBD_DEPENDS)" >>$@
	@echo "Suggests: $(NBD_SUGGESTS)" >>$@
	@echo "Conflicts: $(NBD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NBD_IPK_DIR)/opt/sbin or $(NBD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NBD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NBD_IPK_DIR)/opt/etc/nbd/...
# Documentation files should be installed in $(NBD_IPK_DIR)/opt/doc/nbd/...
# Daemon startup scripts should be installed in $(NBD_IPK_DIR)/opt/etc/init.d/S??nbd
#
# You may need to patch your application to make it use these locations.
#
$(NBD-CLIENT_IPK) $(NBD-SERVER_IPK): $(NBD_BUILD_DIR)/.built
	rm -rf $(NBD-CLIENT_IPK_DIR) $(NBD-SERVER_IPK_DIR) \
		$(BUILD_DIR)/nbd-client_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/nbd-server_*_$(TARGET_ARCH).ipk
	# nbd-client
	$(MAKE) -C $(NBD_BUILD_DIR) DESTDIR=$(NBD-CLIENT_IPK_DIR) install-strip
	rm -rf `find $(NBD-CLIENT_IPK_DIR) -type f -name 'nbd-server*'`
	$(MAKE) $(NBD-CLIENT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NBD-CLIENT_IPK_DIR)
	# nbd-server
	$(MAKE) -C $(NBD_BUILD_DIR) DESTDIR=$(NBD-SERVER_IPK_DIR) install-strip
	rm -rf `find $(NBD-SERVER_IPK_DIR) -type f -name 'nbd-client*'`
	$(MAKE) $(NBD-SERVER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NBD-SERVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nbd-ipk: $(NBD-CLIENT_IPK) $(NBD-SERVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nbd-clean:
	rm -f $(NBD_BUILD_DIR)/.built
	-$(MAKE) -C $(NBD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nbd-dirclean:
	rm -rf $(BUILD_DIR)/$(NBD_DIR) $(NBD_BUILD_DIR) \
	$(NBD-CLIENT_IPK_DIR) $(NBD-CLIENT_IPK) \
	$(NBD-SERVER_IPK_DIR) $(NBD-SERVER_IPK) \

#
#
# Some sanity check for the package.
#
nbd-check: $(NBD-CLIENT_IPK) $(NBD-SERVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NBD-CLIENT_IPK) $(NBD-SERVER_IPK)
