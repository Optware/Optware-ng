###########################################################
#
# splix
#
###########################################################
#
# SPLIX_VERSION, SPLIX_SITE and SPLIX_SOURCE define
# the upstream location of the source code for the package.
# SPLIX_DIR is the directory which is created when the source
# archive is unpacked.
# SPLIX_UNZIP is the command used to unzip the source.
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
SPLIX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/splix
SPLIX_VERSION=2.0.0
SPLIX_SOURCE=splix-$(SPLIX_VERSION).tar.bz2
SPLIX_DIR=splix-$(SPLIX_VERSION)
SPLIX_UNZIP=bzcat
SPLIX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPLIX_DESCRIPTION=Splix is a driver for printers that speak SPL (Samsung Printer Language). This includes printers made by Samsung, Dell, and Xerox.
SPLIX_SECTION=print
SPLIX_PRIORITY=optional
SPLIX_DEPENDS=cups
SPLIX_SUGGESTS=
SPLIX_CONFLICTS=

#
# SPLIX_IPK_VERSION should be incremented when the ipk changes.
#
SPLIX_IPK_VERSION=1

#
# SPLIX_CONFFILES should be a list of user-editable files
#SPLIX_CONFFILES=/opt/etc/splix.conf /opt/etc/init.d/SXXsplix

#
# SPLIX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPLIX_PATCHES=$(SPLIX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPLIX_CPPFLAGS=
SPLIX_LDFLAGS=-lpng -ltiff

#
# SPLIX_BUILD_DIR is the directory in which the build is done.
# SPLIX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPLIX_IPK_DIR is the directory in which the ipk is built.
# SPLIX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPLIX_BUILD_DIR=$(BUILD_DIR)/splix
SPLIX_SOURCE_DIR=$(SOURCE_DIR)/splix
SPLIX_IPK_DIR=$(BUILD_DIR)/splix-$(SPLIX_VERSION)-ipk
SPLIX_IPK=$(BUILD_DIR)/splix_$(SPLIX_VERSION)-$(SPLIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: splix-source splix-unpack splix splix-stage splix-ipk splix-clean splix-dirclean splix-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPLIX_SOURCE):
	$(WGET) -P $(@D) $(SPLIX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
splix-source: $(DL_DIR)/$(SPLIX_SOURCE) $(SPLIX_PATCHES)

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
$(SPLIX_BUILD_DIR)/.configured: $(DL_DIR)/$(SPLIX_SOURCE) $(SPLIX_PATCHES) make/splix.mk
	$(MAKE) cups-stage
	rm -rf $(BUILD_DIR)/$(SPLIX_DIR) $(@D)
	$(SPLIX_UNZIP) $(DL_DIR)/$(SPLIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPLIX_PATCHES)" ; \
		then cat $(SPLIX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPLIX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPLIX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SPLIX_DIR) $(@D) ; \
	fi
	sed -i \
		-e 's|$$(Q)g++|$$(Q)$(TARGET_CXX) $$(LDFLAGS)|' \
		-e '/install/s|-s ||' \
		$(@D)/rules.mk
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPLIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPLIX_LDFLAGS)" \
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

splix-unpack: $(SPLIX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPLIX_BUILD_DIR)/.built: $(SPLIX_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(@D) \
		V=1 \
		DISABLE_JBIG=1 \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPLIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPLIX_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
splix: $(SPLIX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPLIX_BUILD_DIR)/.staged: $(SPLIX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

splix-stage: $(SPLIX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/splix
#
$(SPLIX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: splix" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPLIX_PRIORITY)" >>$@
	@echo "Section: $(SPLIX_SECTION)" >>$@
	@echo "Version: $(SPLIX_VERSION)-$(SPLIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPLIX_MAINTAINER)" >>$@
	@echo "Source: $(SPLIX_SITE)/$(SPLIX_SOURCE)" >>$@
	@echo "Description: $(SPLIX_DESCRIPTION)" >>$@
	@echo "Depends: $(SPLIX_DEPENDS)" >>$@
	@echo "Suggests: $(SPLIX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPLIX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPLIX_IPK_DIR)/opt/sbin or $(SPLIX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPLIX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPLIX_IPK_DIR)/opt/etc/splix/...
# Documentation files should be installed in $(SPLIX_IPK_DIR)/opt/doc/splix/...
# Daemon startup scripts should be installed in $(SPLIX_IPK_DIR)/opt/etc/init.d/S??splix
#
# You may need to patch your application to make it use these locations.
#
$(SPLIX_IPK): $(SPLIX_BUILD_DIR)/.built
	rm -rf $(SPLIX_IPK_DIR) $(BUILD_DIR)/splix_*_$(TARGET_ARCH).ipk
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(SPLIX_BUILD_DIR) DESTDIR=$(SPLIX_IPK_DIR) install
	$(STRIP_COMMAND) $(SPLIX_IPK_DIR)/opt/lib/cups/filter/*
#	install -d $(SPLIX_IPK_DIR)/opt/etc/
#	install -m 644 $(SPLIX_SOURCE_DIR)/splix.conf $(SPLIX_IPK_DIR)/opt/etc/splix.conf
#	install -d $(SPLIX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SPLIX_SOURCE_DIR)/rc.splix $(SPLIX_IPK_DIR)/opt/etc/init.d/SXXsplix
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPLIX_IPK_DIR)/opt/etc/init.d/SXXsplix
	$(MAKE) $(SPLIX_IPK_DIR)/CONTROL/control
#	install -m 755 $(SPLIX_SOURCE_DIR)/postinst $(SPLIX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPLIX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SPLIX_SOURCE_DIR)/prerm $(SPLIX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPLIX_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SPLIX_IPK_DIR)/CONTROL/postinst $(SPLIX_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SPLIX_CONFFILES) | sed -e 's/ /\n/g' > $(SPLIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPLIX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
splix-ipk: $(SPLIX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
splix-clean:
	rm -f $(SPLIX_BUILD_DIR)/.built
	-$(MAKE) -C $(SPLIX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
splix-dirclean:
	rm -rf $(BUILD_DIR)/$(SPLIX_DIR) $(SPLIX_BUILD_DIR) $(SPLIX_IPK_DIR) $(SPLIX_IPK)
#
#
# Some sanity check for the package.
#
splix-check: $(SPLIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
