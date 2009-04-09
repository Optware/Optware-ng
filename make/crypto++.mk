###########################################################
#
# crypto++
#
###########################################################
#
# CRYPTO++_VERSION, CRYPTO++_SITE and CRYPTO++_SOURCE define
# the upstream location of the source code for the package.
# CRYPTO++_DIR is the directory which is created when the source
# archive is unpacked.
# CRYPTO++_UNZIP is the command used to unzip the source.
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
CRYPTO++_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/cryptopp
CRYPTO++_VERSION=5.6.0
CRYPTO++_DIR=cryptopp560
CRYPTO++_SOURCE=$(CRYPTO++_DIR).zip
CRYPTO++_UNZIP=unzip
CRYPTO++_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CRYPTO++_DESCRIPTION=A free C++ class library of cryptographic schemes.
CRYPTO++_SECTION=lib
CRYPTO++_PRIORITY=optional
CRYPTO++_DEPENDS=
CRYPTO++_SUGGESTS=
CRYPTO++_CONFLICTS=

#
# CRYPTO++_IPK_VERSION should be incremented when the ipk changes.
#
#CRYPTO++_IPK_VERSION=1

#
# CRYPTO++_CONFFILES should be a list of user-editable files
#CRYPTO++_CONFFILES=/opt/etc/crypto++.conf /opt/etc/init.d/SXXcrypto++

#
# CRYPTO++_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CRYPTO++_PATCHES=$(CRYPTO++_SOURCE_DIR)/mipsel-endian.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CRYPTO++_CPPFLAGS=
CRYPTO++_LDFLAGS=

ifdef TARGET_GXX
CRYPTO++_CXX_OPTS = CXX=$(TARGET_GXX)
endif

#
# CRYPTO++_BUILD_DIR is the directory in which the build is done.
# CRYPTO++_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CRYPTO++_IPK_DIR is the directory in which the ipk is built.
# CRYPTO++_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CRYPTO++_BUILD_DIR=$(BUILD_DIR)/crypto++
CRYPTO++_SOURCE_DIR=$(SOURCE_DIR)/crypto++
CRYPTO++_IPK_DIR=$(BUILD_DIR)/crypto++-$(CRYPTO++_VERSION)-ipk
CRYPTO++_IPK=$(BUILD_DIR)/crypto++_$(CRYPTO++_VERSION)-$(CRYPTO++_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: crypto++-source crypto++-unpack crypto++ crypto++-stage crypto++-ipk crypto++-clean crypto++-dirclean crypto++-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CRYPTO++_SOURCE):
	$(WGET) -P $(@D) $(CRYPTO++_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
crypto++-source: $(DL_DIR)/$(CRYPTO++_SOURCE) $(CRYPTO++_PATCHES)

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
$(CRYPTO++_BUILD_DIR)/.configured: $(DL_DIR)/$(CRYPTO++_SOURCE) $(CRYPTO++_PATCHES) make/crypto++.mk
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(CRYPTO++_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(CRYPTO++_DIR)
	cd $(BUILD_DIR)/$(CRYPTO++_DIR) && $(CRYPTO++_UNZIP) $(DL_DIR)/$(CRYPTO++_SOURCE)
	if test -n "$(CRYPTO++_PATCHES)" ; \
		then cat $(CRYPTO++_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CRYPTO++_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CRYPTO++_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CRYPTO++_DIR) $(@D) ; \
	fi
ifneq ($(TARGET_ARCH), $(filter i686, $(TARGET_ARCH)))
	sed -i -e '/-mtune/d' $(@D)/GNUmakefile
endif
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CRYPTO++_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CRYPTO++_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

crypto++-unpack: $(CRYPTO++_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CRYPTO++_BUILD_DIR)/.built: $(CRYPTO++_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		$(CRYPTO++_CXX_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CRYPTO++_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CRYPTO++_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
crypto++: $(CRYPTO++_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CRYPTO++_BUILD_DIR)/.staged: $(CRYPTO++_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) PREFIX=$(STAGING_PREFIX) install
	touch $@

crypto++-stage: $(CRYPTO++_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/crypto++
#
$(CRYPTO++_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: crypto++" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CRYPTO++_PRIORITY)" >>$@
	@echo "Section: $(CRYPTO++_SECTION)" >>$@
	@echo "Version: $(CRYPTO++_VERSION)-$(CRYPTO++_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CRYPTO++_MAINTAINER)" >>$@
	@echo "Source: $(CRYPTO++_SITE)/$(CRYPTO++_SOURCE)" >>$@
	@echo "Description: $(CRYPTO++_DESCRIPTION)" >>$@
	@echo "Depends: $(CRYPTO++_DEPENDS)" >>$@
	@echo "Suggests: $(CRYPTO++_SUGGESTS)" >>$@
	@echo "Conflicts: $(CRYPTO++_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CRYPTO++_IPK_DIR)/opt/sbin or $(CRYPTO++_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CRYPTO++_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CRYPTO++_IPK_DIR)/opt/etc/crypto++/...
# Documentation files should be installed in $(CRYPTO++_IPK_DIR)/opt/doc/crypto++/...
# Daemon startup scripts should be installed in $(CRYPTO++_IPK_DIR)/opt/etc/init.d/S??crypto++
#
# You may need to patch your application to make it use these locations.
#
$(CRYPTO++_IPK): $(CRYPTO++_BUILD_DIR)/.built
	rm -rf $(CRYPTO++_IPK_DIR) $(BUILD_DIR)/crypto++_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CRYPTO++_BUILD_DIR) DESTDIR=$(CRYPTO++_IPK_DIR) install-strip
#	install -d $(CRYPTO++_IPK_DIR)/opt/etc/
#	install -m 644 $(CRYPTO++_SOURCE_DIR)/crypto++.conf $(CRYPTO++_IPK_DIR)/opt/etc/crypto++.conf
#	install -d $(CRYPTO++_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CRYPTO++_SOURCE_DIR)/rc.crypto++ $(CRYPTO++_IPK_DIR)/opt/etc/init.d/SXXcrypto++
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CRYPTO++_IPK_DIR)/opt/etc/init.d/SXXcrypto++
	$(MAKE) $(CRYPTO++_IPK_DIR)/CONTROL/control
#	install -m 755 $(CRYPTO++_SOURCE_DIR)/postinst $(CRYPTO++_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CRYPTO++_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CRYPTO++_SOURCE_DIR)/prerm $(CRYPTO++_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CRYPTO++_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CRYPTO++_IPK_DIR)/CONTROL/postinst $(CRYPTO++_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CRYPTO++_CONFFILES) | sed -e 's/ /\n/g' > $(CRYPTO++_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CRYPTO++_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
#crypto++-ipk: $(CRYPTO++_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
crypto++-clean:
	rm -f $(CRYPTO++_BUILD_DIR)/.built
	-$(MAKE) -C $(CRYPTO++_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
crypto++-dirclean:
	rm -rf $(BUILD_DIR)/$(CRYPTO++_DIR) $(CRYPTO++_BUILD_DIR) $(CRYPTO++_IPK_DIR) $(CRYPTO++_IPK)
#
#
# Some sanity check for the package.
#
crypto++-check: $(CRYPTO++_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CRYPTO++_IPK)
