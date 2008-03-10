###########################################################
#
# upx
#
###########################################################
#
# UPX_VERSION, UPX_SITE and UPX_SOURCE define
# the upstream location of the source code for the package.
# UPX_DIR is the directory which is created when the source
# archive is unpacked.
# UPX_UNZIP is the command used to unzip the source.
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
UPX_SITE=http://upx.sourceforge.net/download
UPX_VERSION=3.02
UPX_SOURCE=upx-$(UPX_VERSION)-src.tar.bz2
UPX_DIR=upx-$(UPX_VERSION)-src
UPX_UNZIP=bzcat
UPX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UPX_DESCRIPTION=UPX is a free, portable, extendable, high-performance executable packer for several different executable formats.
UPX_SECTION=util
UPX_PRIORITY=optional
UPX_DEPENDS=ucl, zlib
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
UPX_DEPENDS+=libstdc++
endif
UPX_SUGGESTS=
UPX_CONFLICTS=

#
# UPX_IPK_VERSION should be incremented when the ipk changes.
#
UPX_IPK_VERSION=1

#
# UPX_CONFFILES should be a list of user-editable files
#UPX_CONFFILES=/opt/etc/upx.conf /opt/etc/init.d/SXXupx

#
# UPX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UPX_PATCHES=$(UPX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UPX_CPPFLAGS=
UPX_LDFLAGS=

#
# UPX_BUILD_DIR is the directory in which the build is done.
# UPX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UPX_IPK_DIR is the directory in which the ipk is built.
# UPX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UPX_BUILD_DIR=$(BUILD_DIR)/upx
UPX_SOURCE_DIR=$(SOURCE_DIR)/upx
UPX_IPK_DIR=$(BUILD_DIR)/upx-$(UPX_VERSION)-ipk
UPX_IPK=$(BUILD_DIR)/upx_$(UPX_VERSION)-$(UPX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: upx-source upx-unpack upx upx-stage upx-ipk upx-clean upx-dirclean upx-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UPX_SOURCE):
	$(WGET) -P $(DL_DIR) $(UPX_SITE)/$(UPX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UPX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
upx-source: $(DL_DIR)/$(UPX_SOURCE) $(UPX_PATCHES)

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
$(UPX_BUILD_DIR)/.configured: $(DL_DIR)/$(UPX_SOURCE) $(UPX_PATCHES) make/upx.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) zlib-stage
	$(MAKE) ucl-stage
	rm -rf $(BUILD_DIR)/$(UPX_DIR) $(UPX_BUILD_DIR)
	$(UPX_UNZIP) $(DL_DIR)/$(UPX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UPX_PATCHES)" ; \
		then cat $(UPX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UPX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UPX_DIR)" != "$(UPX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UPX_DIR) $(UPX_BUILD_DIR) ; \
	fi
#	(cd $(UPX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UPX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UPX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) lzma-unpack BUILD_DIR=$(UPX_BUILD_DIR)
	touch $@

upx-unpack: $(UPX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UPX_BUILD_DIR)/.built: $(UPX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UPX_BUILD_DIR) all \
		$(TARGET_CONFIGURE_OPTS) \
		DEFAULT_INCLUDES="$(STAGING_CPPFLAGS) $(UPX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UPX_LDFLAGS)" \
		UPX_UCLDIR=$(STAGING_PREFIX) \
		UPX_LZMADIR=$(UPX_BUILD_DIR)/lzma \
		;
	touch $@

#
# This is the build convenience target.
#
upx: $(UPX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UPX_BUILD_DIR)/.staged: $(UPX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UPX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

upx-stage: $(UPX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/upx
#
$(UPX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: upx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UPX_PRIORITY)" >>$@
	@echo "Section: $(UPX_SECTION)" >>$@
	@echo "Version: $(UPX_VERSION)-$(UPX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UPX_MAINTAINER)" >>$@
	@echo "Source: $(UPX_SITE)/$(UPX_SOURCE)" >>$@
	@echo "Description: $(UPX_DESCRIPTION)" >>$@
	@echo "Depends: $(UPX_DEPENDS)" >>$@
	@echo "Suggests: $(UPX_SUGGESTS)" >>$@
	@echo "Conflicts: $(UPX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UPX_IPK_DIR)/opt/sbin or $(UPX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UPX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UPX_IPK_DIR)/opt/etc/upx/...
# Documentation files should be installed in $(UPX_IPK_DIR)/opt/doc/upx/...
# Daemon startup scripts should be installed in $(UPX_IPK_DIR)/opt/etc/init.d/S??upx
#
# You may need to patch your application to make it use these locations.
#
$(UPX_IPK): $(UPX_BUILD_DIR)/.built
	rm -rf $(UPX_IPK_DIR) $(BUILD_DIR)/upx_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(UPX_BUILD_DIR) DESTDIR=$(UPX_IPK_DIR) install-strip
	install -d $(UPX_IPK_DIR)/opt/bin $(UPX_IPK_DIR)/opt/man/man1
	install $(UPX_BUILD_DIR)/src/upx.out $(UPX_IPK_DIR)/opt/bin/upx
	$(STRIP_COMMAND) $(UPX_IPK_DIR)/opt/bin/upx
	install $(UPX_BUILD_DIR)/doc/upx.1 $(UPX_IPK_DIR)/opt/man/man1
#	install -d $(UPX_IPK_DIR)/opt/etc/
#	install -m 644 $(UPX_SOURCE_DIR)/upx.conf $(UPX_IPK_DIR)/opt/etc/upx.conf
#	install -d $(UPX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UPX_SOURCE_DIR)/rc.upx $(UPX_IPK_DIR)/opt/etc/init.d/SXXupx
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UPX_IPK_DIR)/opt/etc/init.d/SXXupx
	$(MAKE) $(UPX_IPK_DIR)/CONTROL/control
#	install -m 755 $(UPX_SOURCE_DIR)/postinst $(UPX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UPX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UPX_SOURCE_DIR)/prerm $(UPX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UPX_IPK_DIR)/CONTROL/prerm
	echo $(UPX_CONFFILES) | sed -e 's/ /\n/g' > $(UPX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UPX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
upx-ipk: $(UPX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
upx-clean:
	rm -f $(UPX_BUILD_DIR)/.built
	-$(MAKE) -C $(UPX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
upx-dirclean:
	rm -rf $(BUILD_DIR)/$(UPX_DIR) $(UPX_BUILD_DIR) $(UPX_IPK_DIR) $(UPX_IPK)
#
#
# Some sanity check for the package.
#
upx-check: $(UPX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UPX_IPK)
