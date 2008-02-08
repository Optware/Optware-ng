###########################################################
#
# vtun
#
###########################################################
#
# VTUN_VERSION, VTUN_SITE and VTUN_SOURCE define
# the upstream location of the source code for the package.
# VTUN_DIR is the directory which is created when the source
# archive is unpacked.
# VTUN_UNZIP is the command used to unzip the source.
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
VTUN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/vtun
VTUN_VERSION=3.0.2
VTUN_SOURCE=vtun-$(VTUN_VERSION).tar.gz
VTUN_DIR=vtun-$(VTUN_VERSION)
VTUN_UNZIP=zcat
VTUN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VTUN_DESCRIPTION=Virtual Tunnels over TCP/IP networks with traffic shaping, compression, and encryption.
VTUN_SECTION=net
VTUN_PRIORITY=optional
VTUN_DEPENDS=lzo, openssl, zlib
VTUN_SUGGESTS=
VTUN_CONFLICTS=

#
# VTUN_IPK_VERSION should be incremented when the ipk changes.
#
VTUN_IPK_VERSION=1

#
# VTUN_CONFFILES should be a list of user-editable files
VTUN_CONFFILES=/opt/etc/vtund.conf

#
# VTUN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (wl500g, $(OPTWARE_TARGET))
VTUN_PATCHES=$(VTUN_SOURCE_DIR)/htonl.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VTUN_CPPFLAGS=
VTUN_LDFLAGS=-lcrypto -llzo -lz

#
# VTUN_BUILD_DIR is the directory in which the build is done.
# VTUN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VTUN_IPK_DIR is the directory in which the ipk is built.
# VTUN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VTUN_BUILD_DIR=$(BUILD_DIR)/vtun
VTUN_SOURCE_DIR=$(SOURCE_DIR)/vtun
VTUN_IPK_DIR=$(BUILD_DIR)/vtun-$(VTUN_VERSION)-ipk
VTUN_IPK=$(BUILD_DIR)/vtun_$(VTUN_VERSION)-$(VTUN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vtun-source vtun-unpack vtun vtun-stage vtun-ipk vtun-clean vtun-dirclean vtun-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VTUN_SOURCE):
	$(WGET) -P $(DL_DIR) $(VTUN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vtun-source: $(DL_DIR)/$(VTUN_SOURCE) $(VTUN_PATCHES)

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
$(VTUN_BUILD_DIR)/.configured: $(DL_DIR)/$(VTUN_SOURCE) $(VTUN_PATCHES) make/vtun.mk
	$(MAKE) lzo-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(VTUN_DIR) $(VTUN_BUILD_DIR)
	$(VTUN_UNZIP) $(DL_DIR)/$(VTUN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VTUN_PATCHES)" ; \
		then cat $(VTUN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VTUN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VTUN_DIR)" != "$(VTUN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(VTUN_DIR) $(VTUN_BUILD_DIR) ; \
	fi
	cp $(SOURCE_DIR)/common/config.* $(VTUN_BUILD_DIR)
	(cd $(VTUN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VTUN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VTUN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ssl-headers=$(STAGING_INCLUDE_DIR)/openssl \
		--with-blowfish-headers=$(STAGING_INCLUDE_DIR)/openssl \
		--with-ssl-lib=$(STAGING_LIB_DIR) \
		--with-lzo-headers=$(STAGING_INCLUDE_DIR) \
		--with-lzo-lib=$(STAGING_LIB_DIR) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(VTUN_BUILD_DIR)/libtool
	touch $@

vtun-unpack: $(VTUN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VTUN_BUILD_DIR)/.built: $(VTUN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(VTUN_BUILD_DIR) \
		LDFLAGS="$(STAGING_LDFLAGS) $(VTUN_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
vtun: $(VTUN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VTUN_BUILD_DIR)/.staged: $(VTUN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(VTUN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

vtun-stage: $(VTUN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vtun
#
$(VTUN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vtun" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VTUN_PRIORITY)" >>$@
	@echo "Section: $(VTUN_SECTION)" >>$@
	@echo "Version: $(VTUN_VERSION)-$(VTUN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VTUN_MAINTAINER)" >>$@
	@echo "Source: $(VTUN_SITE)/$(VTUN_SOURCE)" >>$@
	@echo "Description: $(VTUN_DESCRIPTION)" >>$@
	@echo "Depends: $(VTUN_DEPENDS)" >>$@
	@echo "Suggests: $(VTUN_SUGGESTS)" >>$@
	@echo "Conflicts: $(VTUN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VTUN_IPK_DIR)/opt/sbin or $(VTUN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VTUN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VTUN_IPK_DIR)/opt/etc/vtun/...
# Documentation files should be installed in $(VTUN_IPK_DIR)/opt/doc/vtun/...
# Daemon startup scripts should be installed in $(VTUN_IPK_DIR)/opt/etc/init.d/S??vtun
#
# You may need to patch your application to make it use these locations.
#
$(VTUN_IPK): $(VTUN_BUILD_DIR)/.built
	rm -rf $(VTUN_IPK_DIR) $(BUILD_DIR)/vtun_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VTUN_BUILD_DIR) DESTDIR=$(VTUN_IPK_DIR) INSTALL_OWNER="" install
	$(STRIP_COMMAND) $(VTUN_IPK_DIR)/opt/sbin/vtund
#	install -d $(VTUN_IPK_DIR)/opt/etc/
#	install -m 644 $(VTUN_SOURCE_DIR)/vtun.conf $(VTUN_IPK_DIR)/opt/etc/vtun.conf
#	install -d $(VTUN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(VTUN_SOURCE_DIR)/rc.vtun $(VTUN_IPK_DIR)/opt/etc/init.d/SXXvtun
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VTUN_IPK_DIR)/opt/etc/init.d/SXXvtun
	$(MAKE) $(VTUN_IPK_DIR)/CONTROL/control
#	install -m 755 $(VTUN_SOURCE_DIR)/postinst $(VTUN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VTUN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(VTUN_SOURCE_DIR)/prerm $(VTUN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VTUN_IPK_DIR)/CONTROL/prerm
	echo $(VTUN_CONFFILES) | sed -e 's/ /\n/g' > $(VTUN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VTUN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vtun-ipk: $(VTUN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vtun-clean:
	rm -f $(VTUN_BUILD_DIR)/.built
	-$(MAKE) -C $(VTUN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vtun-dirclean:
	rm -rf $(BUILD_DIR)/$(VTUN_DIR) $(VTUN_BUILD_DIR) $(VTUN_IPK_DIR) $(VTUN_IPK)
#
#
# Some sanity check for the package.
#
vtun-check: $(VTUN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VTUN_IPK)
