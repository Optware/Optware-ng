###########################################################
#
# libieee1284
#
###########################################################
#
# LIBIEEE1284_VERSION, LIBIEEE1284_SITE and LIBIEEE1284_SOURCE define
# the upstream location of the source code for the package.
# LIBIEEE1284_DIR is the directory which is created when the source
# archive is unpacked.
# LIBIEEE1284_UNZIP is the command used to unzip the source.
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
LIBIEEE1284_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libieee1284
LIBIEEE1284_VERSION=0.2.11
LIBIEEE1284_SOURCE=libieee1284-$(LIBIEEE1284_VERSION).tar.bz2
LIBIEEE1284_DIR=libieee1284-$(LIBIEEE1284_VERSION)
LIBIEEE1284_UNZIP=bzcat
LIBIEEE1284_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBIEEE1284_DESCRIPTION=libieee1284 is a cross-platform library for parallel port access.
LIBIEEE1284_SECTION=lib
LIBIEEE1284_PRIORITY=optional
LIBIEEE1284_DEPENDS=
LIBIEEE1284_SUGGESTS=
LIBIEEE1284_CONFLICTS=

#
# LIBIEEE1284_IPK_VERSION should be incremented when the ipk changes.
#
LIBIEEE1284_IPK_VERSION=1

#
# LIBIEEE1284_CONFFILES should be a list of user-editable files
#LIBIEEE1284_CONFFILES=/opt/etc/libieee1284.conf /opt/etc/init.d/SXXlibieee1284

#
# LIBIEEE1284_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBIEEE1284_PATCHES=$(LIBIEEE1284_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBIEEE1284_CPPFLAGS=
LIBIEEE1284_LDFLAGS=

#
# LIBIEEE1284_BUILD_DIR is the directory in which the build is done.
# LIBIEEE1284_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBIEEE1284_IPK_DIR is the directory in which the ipk is built.
# LIBIEEE1284_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBIEEE1284_BUILD_DIR=$(BUILD_DIR)/libieee1284
LIBIEEE1284_SOURCE_DIR=$(SOURCE_DIR)/libieee1284
LIBIEEE1284_IPK_DIR=$(BUILD_DIR)/libieee1284-$(LIBIEEE1284_VERSION)-ipk
LIBIEEE1284_IPK=$(BUILD_DIR)/libieee1284_$(LIBIEEE1284_VERSION)-$(LIBIEEE1284_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libieee1284-source libieee1284-unpack libieee1284 libieee1284-stage libieee1284-ipk libieee1284-clean libieee1284-dirclean libieee1284-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBIEEE1284_SOURCE):
	$(WGET) -P $(@D) $(LIBIEEE1284_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libieee1284-source: $(DL_DIR)/$(LIBIEEE1284_SOURCE) $(LIBIEEE1284_PATCHES)

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
$(LIBIEEE1284_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBIEEE1284_SOURCE) $(LIBIEEE1284_PATCHES) make/libieee1284.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBIEEE1284_DIR) $(@D)
	$(LIBIEEE1284_UNZIP) $(DL_DIR)/$(LIBIEEE1284_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBIEEE1284_PATCHES)" ; \
		then cat $(LIBIEEE1284_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBIEEE1284_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBIEEE1284_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBIEEE1284_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBIEEE1284_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBIEEE1284_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-python \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libieee1284-unpack: $(LIBIEEE1284_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBIEEE1284_BUILD_DIR)/.built: $(LIBIEEE1284_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libieee1284: $(LIBIEEE1284_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBIEEE1284_BUILD_DIR)/.staged: $(LIBIEEE1284_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libieee1284.la
	touch $@

libieee1284-stage: $(LIBIEEE1284_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libieee1284
#
$(LIBIEEE1284_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libieee1284" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBIEEE1284_PRIORITY)" >>$@
	@echo "Section: $(LIBIEEE1284_SECTION)" >>$@
	@echo "Version: $(LIBIEEE1284_VERSION)-$(LIBIEEE1284_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBIEEE1284_MAINTAINER)" >>$@
	@echo "Source: $(LIBIEEE1284_SITE)/$(LIBIEEE1284_SOURCE)" >>$@
	@echo "Description: $(LIBIEEE1284_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBIEEE1284_DEPENDS)" >>$@
	@echo "Suggests: $(LIBIEEE1284_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBIEEE1284_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBIEEE1284_IPK_DIR)/opt/sbin or $(LIBIEEE1284_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBIEEE1284_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBIEEE1284_IPK_DIR)/opt/etc/libieee1284/...
# Documentation files should be installed in $(LIBIEEE1284_IPK_DIR)/opt/doc/libieee1284/...
# Daemon startup scripts should be installed in $(LIBIEEE1284_IPK_DIR)/opt/etc/init.d/S??libieee1284
#
# You may need to patch your application to make it use these locations.
#
$(LIBIEEE1284_IPK): $(LIBIEEE1284_BUILD_DIR)/.built
	rm -rf $(LIBIEEE1284_IPK_DIR) $(BUILD_DIR)/libieee1284_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBIEEE1284_BUILD_DIR) DESTDIR=$(LIBIEEE1284_IPK_DIR) install-strip
#	install -d $(LIBIEEE1284_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBIEEE1284_SOURCE_DIR)/libieee1284.conf $(LIBIEEE1284_IPK_DIR)/opt/etc/libieee1284.conf
#	install -d $(LIBIEEE1284_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBIEEE1284_SOURCE_DIR)/rc.libieee1284 $(LIBIEEE1284_IPK_DIR)/opt/etc/init.d/SXXlibieee1284
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBIEEE1284_IPK_DIR)/opt/etc/init.d/SXXlibieee1284
	$(MAKE) $(LIBIEEE1284_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBIEEE1284_SOURCE_DIR)/postinst $(LIBIEEE1284_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBIEEE1284_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBIEEE1284_SOURCE_DIR)/prerm $(LIBIEEE1284_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBIEEE1284_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBIEEE1284_IPK_DIR)/CONTROL/postinst $(LIBIEEE1284_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBIEEE1284_CONFFILES) | sed -e 's/ /\n/g' > $(LIBIEEE1284_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBIEEE1284_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libieee1284-ipk: $(LIBIEEE1284_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libieee1284-clean:
	rm -f $(LIBIEEE1284_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBIEEE1284_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libieee1284-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBIEEE1284_DIR) $(LIBIEEE1284_BUILD_DIR) $(LIBIEEE1284_IPK_DIR) $(LIBIEEE1284_IPK)
#
#
# Some sanity check for the package.
#
libieee1284-check: $(LIBIEEE1284_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBIEEE1284_IPK)
