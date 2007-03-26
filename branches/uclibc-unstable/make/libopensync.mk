###########################################################
#
# libopensync
#
###########################################################
#
# LIBOPENSYNC_VERSION, LIBOPENSYNC_SITE and LIBOPENSYNC_SOURCE define
# the upstream location of the source code for the package.
# LIBOPENSYNC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBOPENSYNC_UNZIP is the command used to unzip the source.
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
LIBOPENSYNC_SITE=http://www.opensync.org/attachment/wiki/download
LIBOPENSYNC_VERSION=0.21
LIBOPENSYNC_SOURCE=libopensync-$(LIBOPENSYNC_VERSION).tar.bz2
LIBOPENSYNC_DIR=libopensync-$(LIBOPENSYNC_VERSION)
LIBOPENSYNC_UNZIP=bzcat
LIBOPENSYNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBOPENSYNC_DESCRIPTION=A synchronization engine.
LIBOPENSYNC_SECTION=misc
LIBOPENSYNC_PRIORITY=optional
LIBOPENSYNC_DEPENDS=glib, libxml2, sqlite
LIBOPENSYNC_SUGGESTS=
LIBOPENSYNC_CONFLICTS=

#
# LIBOPENSYNC_IPK_VERSION should be incremented when the ipk changes.
#
LIBOPENSYNC_IPK_VERSION=1

#
# LIBOPENSYNC_CONFFILES should be a list of user-editable files
#LIBOPENSYNC_CONFFILES=/opt/etc/libopensync.conf /opt/etc/init.d/SXXlibopensync

#
# LIBOPENSYNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBOPENSYNC_PATCHES=$(LIBOPENSYNC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBOPENSYNC_CPPFLAGS=
LIBOPENSYNC_LDFLAGS=

#
# LIBOPENSYNC_BUILD_DIR is the directory in which the build is done.
# LIBOPENSYNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBOPENSYNC_IPK_DIR is the directory in which the ipk is built.
# LIBOPENSYNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBOPENSYNC_BUILD_DIR=$(BUILD_DIR)/libopensync
LIBOPENSYNC_SOURCE_DIR=$(SOURCE_DIR)/libopensync
LIBOPENSYNC_IPK_DIR=$(BUILD_DIR)/libopensync-$(LIBOPENSYNC_VERSION)-ipk
LIBOPENSYNC_IPK=$(BUILD_DIR)/libopensync_$(LIBOPENSYNC_VERSION)-$(LIBOPENSYNC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libopensync-source libopensync-unpack libopensync libopensync-stage libopensync-ipk libopensync-clean libopensync-dirclean libopensync-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBOPENSYNC_SOURCE):
	$(WGET) -O $(DL_DIR)/$(LIBOPENSYNC_SOURCE) "$(LIBOPENSYNC_SITE)/$(LIBOPENSYNC_SOURCE)?rev=&format=raw" || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBOPENSYNC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libopensync-source: $(DL_DIR)/$(LIBOPENSYNC_SOURCE) $(LIBOPENSYNC_PATCHES)

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
$(LIBOPENSYNC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBOPENSYNC_SOURCE) $(LIBOPENSYNC_PATCHES) make/libopensync.mk
	$(MAKE) glib-stage
	$(MAKE) libxml2-stage
	$(MAKE) sqlite-stage
	rm -rf $(BUILD_DIR)/$(LIBOPENSYNC_DIR) $(LIBOPENSYNC_BUILD_DIR)
	$(LIBOPENSYNC_UNZIP) $(DL_DIR)/$(LIBOPENSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBOPENSYNC_PATCHES)" ; \
		then cat $(LIBOPENSYNC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBOPENSYNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBOPENSYNC_DIR)" != "$(LIBOPENSYNC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBOPENSYNC_DIR) $(LIBOPENSYNC_BUILD_DIR) ; \
	fi
	(cd $(LIBOPENSYNC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBOPENSYNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBOPENSYNC_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-python \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBOPENSYNC_BUILD_DIR)/libtool
	touch $@

libopensync-unpack: $(LIBOPENSYNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBOPENSYNC_BUILD_DIR)/.built: $(LIBOPENSYNC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBOPENSYNC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libopensync: $(LIBOPENSYNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBOPENSYNC_BUILD_DIR)/.staged: $(LIBOPENSYNC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBOPENSYNC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libopensync.la $(STAGING_LIB_DIR)/libosengine.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/opensync-*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/osengine-*.pc
	touch $@

libopensync-stage: $(LIBOPENSYNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libopensync
#
$(LIBOPENSYNC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libopensync" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBOPENSYNC_PRIORITY)" >>$@
	@echo "Section: $(LIBOPENSYNC_SECTION)" >>$@
	@echo "Version: $(LIBOPENSYNC_VERSION)-$(LIBOPENSYNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBOPENSYNC_MAINTAINER)" >>$@
	@echo "Source: $(LIBOPENSYNC_SITE)/$(LIBOPENSYNC_SOURCE)" >>$@
	@echo "Description: $(LIBOPENSYNC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBOPENSYNC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBOPENSYNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBOPENSYNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBOPENSYNC_IPK_DIR)/opt/sbin or $(LIBOPENSYNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBOPENSYNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBOPENSYNC_IPK_DIR)/opt/etc/libopensync/...
# Documentation files should be installed in $(LIBOPENSYNC_IPK_DIR)/opt/doc/libopensync/...
# Daemon startup scripts should be installed in $(LIBOPENSYNC_IPK_DIR)/opt/etc/init.d/S??libopensync
#
# You may need to patch your application to make it use these locations.
#
$(LIBOPENSYNC_IPK): $(LIBOPENSYNC_BUILD_DIR)/.built
	rm -rf $(LIBOPENSYNC_IPK_DIR) $(BUILD_DIR)/libopensync_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBOPENSYNC_BUILD_DIR) DESTDIR=$(LIBOPENSYNC_IPK_DIR) install-strip
	rm -f $(LIBOPENSYNC_IPK_DIR)/opt/lib/*.la
#	install -d $(LIBOPENSYNC_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBOPENSYNC_SOURCE_DIR)/libopensync.conf $(LIBOPENSYNC_IPK_DIR)/opt/etc/libopensync.conf
#	install -d $(LIBOPENSYNC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBOPENSYNC_SOURCE_DIR)/rc.libopensync $(LIBOPENSYNC_IPK_DIR)/opt/etc/init.d/SXXlibopensync
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENSYNC_IPK_DIR)/opt/etc/init.d/SXXlibopensync
	$(MAKE) $(LIBOPENSYNC_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBOPENSYNC_SOURCE_DIR)/postinst $(LIBOPENSYNC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENSYNC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBOPENSYNC_SOURCE_DIR)/prerm $(LIBOPENSYNC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBOPENSYNC_IPK_DIR)/CONTROL/prerm
	echo $(LIBOPENSYNC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBOPENSYNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBOPENSYNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libopensync-ipk: $(LIBOPENSYNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libopensync-clean:
	rm -f $(LIBOPENSYNC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBOPENSYNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libopensync-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBOPENSYNC_DIR) $(LIBOPENSYNC_BUILD_DIR) $(LIBOPENSYNC_IPK_DIR) $(LIBOPENSYNC_IPK)
#
#
# Some sanity check for the package.
#
libopensync-check: $(LIBOPENSYNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBOPENSYNC_IPK)
