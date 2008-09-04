###########################################################
#
# libinklevel
#
###########################################################
#
# LIBINKLEVEL_VERSION, LIBINKLEVEL_SITE and LIBINKLEVEL_SOURCE define
# the upstream location of the source code for the package.
# LIBINKLEVEL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBINKLEVEL_UNZIP is the command used to unzip the source.
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
LIBINKLEVEL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libinklevel
LIBINKLEVEL_VERSION=0.7.3
LIBINKLEVEL_SOURCE=libinklevel-$(LIBINKLEVEL_VERSION).tar.gz
LIBINKLEVEL_DIR=libinklevel-$(LIBINKLEVEL_VERSION)
LIBINKLEVEL_UNZIP=zcat
LIBINKLEVEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBINKLEVEL_DESCRIPTION=A library for checking the ink level of your printer.
LIBINKLEVEL_SECTION=print
LIBINKLEVEL_PRIORITY=optional
LIBINKLEVEL_DEPENDS=libieee1284
LIBINKLEVEL_SUGGESTS=
LIBINKLEVEL_CONFLICTS=

#
# LIBINKLEVEL_IPK_VERSION should be incremented when the ipk changes.
#
LIBINKLEVEL_IPK_VERSION=1

#
# LIBINKLEVEL_CONFFILES should be a list of user-editable files
#LIBINKLEVEL_CONFFILES=/opt/etc/libinklevel.conf /opt/etc/init.d/SXXlibinklevel

#
# LIBINKLEVEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBINKLEVEL_PATCHES=$(LIBINKLEVEL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBINKLEVEL_CPPFLAGS=
LIBINKLEVEL_LDFLAGS=

#
# LIBINKLEVEL_BUILD_DIR is the directory in which the build is done.
# LIBINKLEVEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBINKLEVEL_IPK_DIR is the directory in which the ipk is built.
# LIBINKLEVEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBINKLEVEL_BUILD_DIR=$(BUILD_DIR)/libinklevel
LIBINKLEVEL_SOURCE_DIR=$(SOURCE_DIR)/libinklevel
LIBINKLEVEL_IPK_DIR=$(BUILD_DIR)/libinklevel-$(LIBINKLEVEL_VERSION)-ipk
LIBINKLEVEL_IPK=$(BUILD_DIR)/libinklevel_$(LIBINKLEVEL_VERSION)-$(LIBINKLEVEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libinklevel-source libinklevel-unpack libinklevel libinklevel-stage libinklevel-ipk libinklevel-clean libinklevel-dirclean libinklevel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBINKLEVEL_SOURCE):
	$(WGET) -P $(@D) $(LIBINKLEVEL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libinklevel-source: $(DL_DIR)/$(LIBINKLEVEL_SOURCE) $(LIBINKLEVEL_PATCHES)

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
$(LIBINKLEVEL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBINKLEVEL_SOURCE) $(LIBINKLEVEL_PATCHES) make/libinklevel.mk
	$(MAKE) libieee1284-stage
	rm -rf $(BUILD_DIR)/$(LIBINKLEVEL_DIR) $(@D)
	$(LIBINKLEVEL_UNZIP) $(DL_DIR)/$(LIBINKLEVEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBINKLEVEL_PATCHES)" ; \
		then cat $(LIBINKLEVEL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBINKLEVEL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBINKLEVEL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBINKLEVEL_DIR) $(@D) ; \
	fi
	sed -i -e 's| -shared|& $$(LDFLAGS)|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBINKLEVEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBINKLEVEL_LDFLAGS)" \
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

libinklevel-unpack: $(LIBINKLEVEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBINKLEVEL_BUILD_DIR)/.built: $(LIBINKLEVEL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBINKLEVEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBINKLEVEL_LDFLAGS)" \
		PREFIX=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
libinklevel: $(LIBINKLEVEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBINKLEVEL_BUILD_DIR)/.staged: $(LIBINKLEVEL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install \
		DESTDIR=$(STAGING_DIR) PREFIX=/opt
	touch $@

libinklevel-stage: $(LIBINKLEVEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libinklevel
#
$(LIBINKLEVEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libinklevel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBINKLEVEL_PRIORITY)" >>$@
	@echo "Section: $(LIBINKLEVEL_SECTION)" >>$@
	@echo "Version: $(LIBINKLEVEL_VERSION)-$(LIBINKLEVEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBINKLEVEL_MAINTAINER)" >>$@
	@echo "Source: $(LIBINKLEVEL_SITE)/$(LIBINKLEVEL_SOURCE)" >>$@
	@echo "Description: $(LIBINKLEVEL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBINKLEVEL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBINKLEVEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBINKLEVEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBINKLEVEL_IPK_DIR)/opt/sbin or $(LIBINKLEVEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBINKLEVEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBINKLEVEL_IPK_DIR)/opt/etc/libinklevel/...
# Documentation files should be installed in $(LIBINKLEVEL_IPK_DIR)/opt/doc/libinklevel/...
# Daemon startup scripts should be installed in $(LIBINKLEVEL_IPK_DIR)/opt/etc/init.d/S??libinklevel
#
# You may need to patch your application to make it use these locations.
#
$(LIBINKLEVEL_IPK): $(LIBINKLEVEL_BUILD_DIR)/.built
	rm -rf $(LIBINKLEVEL_IPK_DIR) $(BUILD_DIR)/libinklevel_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBINKLEVEL_BUILD_DIR) install \
		DESTDIR=$(LIBINKLEVEL_IPK_DIR) PREFIX=/opt
	$(STRIP_COMMAND) $(LIBINKLEVEL_IPK_DIR)/opt/lib/libinklevel.so
#	install -d $(LIBINKLEVEL_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBINKLEVEL_SOURCE_DIR)/libinklevel.conf $(LIBINKLEVEL_IPK_DIR)/opt/etc/libinklevel.conf
#	install -d $(LIBINKLEVEL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBINKLEVEL_SOURCE_DIR)/rc.libinklevel $(LIBINKLEVEL_IPK_DIR)/opt/etc/init.d/SXXlibinklevel
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBINKLEVEL_IPK_DIR)/opt/etc/init.d/SXXlibinklevel
	$(MAKE) $(LIBINKLEVEL_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBINKLEVEL_SOURCE_DIR)/postinst $(LIBINKLEVEL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBINKLEVEL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBINKLEVEL_SOURCE_DIR)/prerm $(LIBINKLEVEL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBINKLEVEL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBINKLEVEL_IPK_DIR)/CONTROL/postinst $(LIBINKLEVEL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBINKLEVEL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBINKLEVEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBINKLEVEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libinklevel-ipk: $(LIBINKLEVEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libinklevel-clean:
	rm -f $(LIBINKLEVEL_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBINKLEVEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libinklevel-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBINKLEVEL_DIR) $(LIBINKLEVEL_BUILD_DIR) $(LIBINKLEVEL_IPK_DIR) $(LIBINKLEVEL_IPK)
#
#
# Some sanity check for the package.
#
libinklevel-check: $(LIBINKLEVEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBINKLEVEL_IPK)
