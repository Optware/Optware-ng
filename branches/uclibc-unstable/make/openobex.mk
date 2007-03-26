###########################################################
#
# openobex
#
###########################################################
#
# OPENOBEX_VERSION, OPENOBEX_SITE and OPENOBEX_SOURCE define
# the upstream location of the source code for the package.
# OPENOBEX_DIR is the directory which is created when the source
# archive is unpacked.
# OPENOBEX_UNZIP is the command used to unzip the source.
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
OPENOBEX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/openobex
OPENOBEX_VERSION=1.3
OPENOBEX_SOURCE=openobex-$(OPENOBEX_VERSION).tar.gz
OPENOBEX_DIR=openobex-$(OPENOBEX_VERSION)
OPENOBEX_UNZIP=zcat
OPENOBEX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENOBEX_DESCRIPTION=Free open source implementation of the Object Exchange (OBEX) protocol.
OPENOBEX_SECTION=net
OPENOBEX_PRIORITY=optional
OPENOBEX_DEPENDS=
OPENOBEX_SUGGESTS=
OPENOBEX_CONFLICTS=

#
# OPENOBEX_IPK_VERSION should be incremented when the ipk changes.
#
OPENOBEX_IPK_VERSION=1

#
# OPENOBEX_CONFFILES should be a list of user-editable files
#OPENOBEX_CONFFILES=/opt/etc/openobex.conf /opt/etc/init.d/SXXopenobex

#
# OPENOBEX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENOBEX_PATCHES=$(OPENOBEX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENOBEX_CPPFLAGS=
OPENOBEX_LDFLAGS=

#
# OPENOBEX_BUILD_DIR is the directory in which the build is done.
# OPENOBEX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENOBEX_IPK_DIR is the directory in which the ipk is built.
# OPENOBEX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENOBEX_BUILD_DIR=$(BUILD_DIR)/openobex
OPENOBEX_SOURCE_DIR=$(SOURCE_DIR)/openobex
OPENOBEX_IPK_DIR=$(BUILD_DIR)/openobex-$(OPENOBEX_VERSION)-ipk
OPENOBEX_IPK=$(BUILD_DIR)/openobex_$(OPENOBEX_VERSION)-$(OPENOBEX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openobex-source openobex-unpack openobex openobex-stage openobex-ipk openobex-clean openobex-dirclean openobex-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENOBEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(OPENOBEX_SITE)/$(OPENOBEX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OPENOBEX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openobex-source: $(DL_DIR)/$(OPENOBEX_SOURCE) $(OPENOBEX_PATCHES)

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
$(OPENOBEX_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENOBEX_SOURCE) $(OPENOBEX_PATCHES) make/openobex.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(OPENOBEX_DIR) $(OPENOBEX_BUILD_DIR)
	$(OPENOBEX_UNZIP) $(DL_DIR)/$(OPENOBEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENOBEX_PATCHES)" ; \
		then cat $(OPENOBEX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENOBEX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENOBEX_DIR)" != "$(OPENOBEX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OPENOBEX_DIR) $(OPENOBEX_BUILD_DIR) ; \
	fi
	cp $(SOURCE_DIR)/common/config.sub $(SOURCE_DIR)/common/config.guess $(OPENOBEX_BUILD_DIR)
	(cd $(OPENOBEX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENOBEX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENOBEX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(OPENOBEX_BUILD_DIR)/libtool
	touch $@

openobex-unpack: $(OPENOBEX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENOBEX_BUILD_DIR)/.built: $(OPENOBEX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(OPENOBEX_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
openobex: $(OPENOBEX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENOBEX_BUILD_DIR)/.staged: $(OPENOBEX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(OPENOBEX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/openobex.pc
	rm -f $(STAGING_LIB_DIR)/libopenobex.la
	touch $@

openobex-stage: $(OPENOBEX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openobex
#
$(OPENOBEX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: openobex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENOBEX_PRIORITY)" >>$@
	@echo "Section: $(OPENOBEX_SECTION)" >>$@
	@echo "Version: $(OPENOBEX_VERSION)-$(OPENOBEX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENOBEX_MAINTAINER)" >>$@
	@echo "Source: $(OPENOBEX_SITE)/$(OPENOBEX_SOURCE)" >>$@
	@echo "Description: $(OPENOBEX_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENOBEX_DEPENDS)" >>$@
	@echo "Suggests: $(OPENOBEX_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENOBEX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENOBEX_IPK_DIR)/opt/sbin or $(OPENOBEX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENOBEX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENOBEX_IPK_DIR)/opt/etc/openobex/...
# Documentation files should be installed in $(OPENOBEX_IPK_DIR)/opt/doc/openobex/...
# Daemon startup scripts should be installed in $(OPENOBEX_IPK_DIR)/opt/etc/init.d/S??openobex
#
# You may need to patch your application to make it use these locations.
#
$(OPENOBEX_IPK): $(OPENOBEX_BUILD_DIR)/.built
	rm -rf $(OPENOBEX_IPK_DIR) $(BUILD_DIR)/openobex_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OPENOBEX_BUILD_DIR) DESTDIR=$(OPENOBEX_IPK_DIR) install-strip
	rm -f $(OPENOBEX_IPK_DIR)/opt/lib/libopenobex.la
#	install -d $(OPENOBEX_IPK_DIR)/opt/etc/
#	install -m 644 $(OPENOBEX_SOURCE_DIR)/openobex.conf $(OPENOBEX_IPK_DIR)/opt/etc/openobex.conf
#	install -d $(OPENOBEX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OPENOBEX_SOURCE_DIR)/rc.openobex $(OPENOBEX_IPK_DIR)/opt/etc/init.d/SXXopenobex
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENOBEX_IPK_DIR)/opt/etc/init.d/SXXopenobex
	$(MAKE) $(OPENOBEX_IPK_DIR)/CONTROL/control
#	install -m 755 $(OPENOBEX_SOURCE_DIR)/postinst $(OPENOBEX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENOBEX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OPENOBEX_SOURCE_DIR)/prerm $(OPENOBEX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENOBEX_IPK_DIR)/CONTROL/prerm
	echo $(OPENOBEX_CONFFILES) | sed -e 's/ /\n/g' > $(OPENOBEX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENOBEX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openobex-ipk: $(OPENOBEX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openobex-clean:
	rm -f $(OPENOBEX_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENOBEX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openobex-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENOBEX_DIR) $(OPENOBEX_BUILD_DIR) $(OPENOBEX_IPK_DIR) $(OPENOBEX_IPK)
#
#
# Some sanity check for the package.
#
openobex-check: $(OPENOBEX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENOBEX_IPK)
