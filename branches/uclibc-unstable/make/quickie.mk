###########################################################
#
# quickie
#
###########################################################
#
# QUICKIE_VERSION, QUICKIE_SITE and QUICKIE_SOURCE define
# the upstream location of the source code for the package.
# QUICKIE_DIR is the directory which is created when the source
# archive is unpacked.
# QUICKIE_UNZIP is the command used to unzip the source.
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
QUICKIE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/quickie
QUICKIE_VERSION=1.1
QUICKIE_SOURCE=quickie-$(QUICKIE_VERSION).tar.gz
QUICKIE_DIR=quickie-$(QUICKIE_VERSION)
QUICKIE_UNZIP=zcat
QUICKIE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QUICKIE_DESCRIPTION=A small footprint, fast C++ Wiki engine.
QUICKIE_SECTION=web
QUICKIE_PRIORITY=optional
QUICKIE_DEPENDS=libstdc++, openssl, zlib
QUICKIE_SUGGESTS=
QUICKIE_CONFLICTS=

#
# QUICKIE_IPK_VERSION should be incremented when the ipk changes.
#
QUICKIE_IPK_VERSION=2

#
# QUICKIE_CONFFILES should be a list of user-editable files
#QUICKIE_CONFFILES=/opt/etc/quickie.conf /opt/etc/init.d/SXXquickie

#
# QUICKIE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
QUICKIE_PATCHES=$(QUICKIE_SOURCE_DIR)/gcc4.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QUICKIE_CPPFLAGS=
QUICKIE_LDFLAGS=

#
# QUICKIE_BUILD_DIR is the directory in which the build is done.
# QUICKIE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QUICKIE_IPK_DIR is the directory in which the ipk is built.
# QUICKIE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QUICKIE_SOURCE_DIR=$(SOURCE_DIR)/quickie
QUICKIE_BUILD_DIR=$(BUILD_DIR)/quickie
QUICKIE_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/quickie

QUICKIE_IPK_DIR=$(BUILD_DIR)/quickie-$(QUICKIE_VERSION)-ipk
QUICKIE_IPK=$(BUILD_DIR)/quickie_$(QUICKIE_VERSION)-$(QUICKIE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: quickie-source quickie-unpack quickie quickie-stage quickie-ipk quickie-clean quickie-dirclean quickie-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QUICKIE_SOURCE):
	$(WGET) -P $(DL_DIR) $(QUICKIE_SITE)/$(QUICKIE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
quickie-source: $(DL_DIR)/$(QUICKIE_SOURCE) $(QUICKIE_PATCHES)

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
$(QUICKIE_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(QUICKIE_SOURCE) make/quickie.mk
	rm -f $(QUICKIE_HOST_BUILD_DIR)/.built
	rm -rf $(HOST_BUILD_DIR)/$(QUICKIE_DIR) $(QUICKIE_HOST_BUILD_DIR)
	$(QUICKIE_UNZIP) $(DL_DIR)/$(QUICKIE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(QUICKIE_DIR) $(QUICKIE_HOST_BUILD_DIR)
	(cd $(QUICKIE_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(QUICKIE_HOST_BUILD_DIR) bin-all
	touch $(QUICKIE_HOST_BUILD_DIR)/.built

ifeq ($(HOSTCC), $(TARGET_CC))
$(QUICKIE_BUILD_DIR)/.configured: $(DL_DIR)/$(QUICKIE_SOURCE) $(QUICKIE_PATCHES) make/quickie.mk
else
$(QUICKIE_BUILD_DIR)/.configured: $(QUICKIE_PATCHES) $(QUICKIE_HOST_BUILD_DIR)/.built
endif
	$(MAKE) openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(QUICKIE_DIR) $(QUICKIE_BUILD_DIR)
	$(QUICKIE_UNZIP) $(DL_DIR)/$(QUICKIE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QUICKIE_PATCHES)" ; \
		then cat $(QUICKIE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(QUICKIE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(QUICKIE_DIR)" != "$(QUICKIE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(QUICKIE_DIR) $(QUICKIE_BUILD_DIR) ; \
	fi
	(cd $(QUICKIE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QUICKIE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QUICKIE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e 's|^	bin/|	$(QUICKIE_HOST_BUILD_DIR)/bin/|' $(QUICKIE_BUILD_DIR)/Makefile
endif
#	$(PATCH_LIBTOOL) $(QUICKIE_BUILD_DIR)/libtool
	touch $(QUICKIE_BUILD_DIR)/.configured

quickie-unpack: $(QUICKIE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QUICKIE_BUILD_DIR)/.built: $(QUICKIE_BUILD_DIR)/.configured
	rm -f $(QUICKIE_BUILD_DIR)/.built
	$(MAKE) -C $(QUICKIE_BUILD_DIR)
	touch $(QUICKIE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
quickie: $(QUICKIE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QUICKIE_BUILD_DIR)/.staged: $(QUICKIE_BUILD_DIR)/.built
	rm -f $(QUICKIE_BUILD_DIR)/.staged
	$(MAKE) -C $(QUICKIE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(QUICKIE_BUILD_DIR)/.staged

quickie-stage: $(QUICKIE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/quickie
#
$(QUICKIE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: quickie" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QUICKIE_PRIORITY)" >>$@
	@echo "Section: $(QUICKIE_SECTION)" >>$@
	@echo "Version: $(QUICKIE_VERSION)-$(QUICKIE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QUICKIE_MAINTAINER)" >>$@
	@echo "Source: $(QUICKIE_SITE)/$(QUICKIE_SOURCE)" >>$@
	@echo "Description: $(QUICKIE_DESCRIPTION)" >>$@
	@echo "Depends: $(QUICKIE_DEPENDS)" >>$@
	@echo "Suggests: $(QUICKIE_SUGGESTS)" >>$@
	@echo "Conflicts: $(QUICKIE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QUICKIE_IPK_DIR)/opt/sbin or $(QUICKIE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QUICKIE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(QUICKIE_IPK_DIR)/opt/etc/quickie/...
# Documentation files should be installed in $(QUICKIE_IPK_DIR)/opt/doc/quickie/...
# Daemon startup scripts should be installed in $(QUICKIE_IPK_DIR)/opt/etc/init.d/S??quickie
#
# You may need to patch your application to make it use these locations.
#
$(QUICKIE_IPK): $(QUICKIE_BUILD_DIR)/.built
	rm -rf $(QUICKIE_IPK_DIR) $(BUILD_DIR)/quickie_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(QUICKIE_BUILD_DIR) RPM_BUILD_ROOT=$(QUICKIE_IPK_DIR) install
	$(STRIP_COMMAND) $(QUICKIE_IPK_DIR)/opt/bin/*
#	install -d $(QUICKIE_IPK_DIR)/opt/etc/
#	install -m 644 $(QUICKIE_SOURCE_DIR)/quickie.conf $(QUICKIE_IPK_DIR)/opt/etc/quickie.conf
#	install -d $(QUICKIE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(QUICKIE_SOURCE_DIR)/rc.quickie $(QUICKIE_IPK_DIR)/opt/etc/init.d/SXXquickie
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXquickie
	$(MAKE) $(QUICKIE_IPK_DIR)/CONTROL/control
#	install -m 755 $(QUICKIE_SOURCE_DIR)/postinst $(QUICKIE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(QUICKIE_SOURCE_DIR)/prerm $(QUICKIE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(QUICKIE_CONFFILES) | sed -e 's/ /\n/g' > $(QUICKIE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QUICKIE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
quickie-ipk: $(QUICKIE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
quickie-clean:
	rm -f $(QUICKIE_BUILD_DIR)/.built
	-$(MAKE) -C $(QUICKIE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
quickie-dirclean:
	rm -rf $(BUILD_DIR)/$(QUICKIE_DIR) $(QUICKIE_BUILD_DIR) $(QUICKIE_IPK_DIR) $(QUICKIE_IPK)
#
#
# Some sanity check for the package.
#
quickie-check: $(QUICKIE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(QUICKIE_IPK)
