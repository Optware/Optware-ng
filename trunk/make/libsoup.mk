###########################################################
#
# libsoup
#
###########################################################
#
# LIBSOUP_VERSION, LIBSOUP_SITE and LIBSOUP_SOURCE define
# the upstream location of the source code for the package.
# LIBSOUP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSOUP_UNZIP is the command used to unzip the source.
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
LIBSOUP_SITE=http://ftp.gnome.org/pub/gnome/sources/libsoup/2.2
LIBSOUP_VERSION=2.2.96
LIBSOUP_SOURCE=libsoup-$(LIBSOUP_VERSION).tar.bz2
LIBSOUP_DIR=libsoup-$(LIBSOUP_VERSION)
LIBSOUP_UNZIP=bzcat
LIBSOUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSOUP_DESCRIPTION=The libsoup package contains an HTTP library implementation in C.
LIBSOUP_SECTION=lib
LIBSOUP_PRIORITY=optional
LIBSOUP_DEPENDS=glib, gnutls, libxml2
LIBSOUP_SUGGESTS=
LIBSOUP_CONFLICTS=

#
# LIBSOUP_IPK_VERSION should be incremented when the ipk changes.
#
LIBSOUP_IPK_VERSION=1

#
# LIBSOUP_CONFFILES should be a list of user-editable files
#LIBSOUP_CONFFILES=/opt/etc/libsoup.conf /opt/etc/init.d/SXXlibsoup

#
# LIBSOUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSOUP_PATCHES=$(LIBSOUP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSOUP_CPPFLAGS=
LIBSOUP_LDFLAGS=

#
# LIBSOUP_BUILD_DIR is the directory in which the build is done.
# LIBSOUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSOUP_IPK_DIR is the directory in which the ipk is built.
# LIBSOUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSOUP_BUILD_DIR=$(BUILD_DIR)/libsoup
LIBSOUP_SOURCE_DIR=$(SOURCE_DIR)/libsoup
LIBSOUP_IPK_DIR=$(BUILD_DIR)/libsoup-$(LIBSOUP_VERSION)-ipk
LIBSOUP_IPK=$(BUILD_DIR)/libsoup_$(LIBSOUP_VERSION)-$(LIBSOUP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libsoup-source libsoup-unpack libsoup libsoup-stage libsoup-ipk libsoup-clean libsoup-dirclean libsoup-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBSOUP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBSOUP_SITE)/$(LIBSOUP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBSOUP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsoup-source: $(DL_DIR)/$(LIBSOUP_SOURCE) $(LIBSOUP_PATCHES)

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
$(LIBSOUP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSOUP_SOURCE) $(LIBSOUP_PATCHES) make/libsoup.mk
	$(MAKE) glib-stage gnutls-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(LIBSOUP_DIR) $(LIBSOUP_BUILD_DIR)
	$(LIBSOUP_UNZIP) $(DL_DIR)/$(LIBSOUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSOUP_PATCHES)" ; \
		then cat $(LIBSOUP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBSOUP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSOUP_DIR)" != "$(LIBSOUP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBSOUP_DIR) $(LIBSOUP_BUILD_DIR) ; \
	fi
	(cd $(LIBSOUP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSOUP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSOUP_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libgnutls-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBSOUP_BUILD_DIR)/libtool
	touch $@

libsoup-unpack: $(LIBSOUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSOUP_BUILD_DIR)/.built: $(LIBSOUP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBSOUP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libsoup: $(LIBSOUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSOUP_BUILD_DIR)/.staged: $(LIBSOUP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBSOUP_BUILD_DIR) install SUBDIRS=libsoup DESTDIR=$(STAGING_DIR)
	rm -f $(STAGING_LIB_DIR)/libsoup.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libsoup-2.2.pc
	touch $@

libsoup-stage: $(LIBSOUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsoup
#
$(LIBSOUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libsoup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSOUP_PRIORITY)" >>$@
	@echo "Section: $(LIBSOUP_SECTION)" >>$@
	@echo "Version: $(LIBSOUP_VERSION)-$(LIBSOUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSOUP_MAINTAINER)" >>$@
	@echo "Source: $(LIBSOUP_SITE)/$(LIBSOUP_SOURCE)" >>$@
	@echo "Description: $(LIBSOUP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSOUP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSOUP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSOUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSOUP_IPK_DIR)/opt/sbin or $(LIBSOUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSOUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSOUP_IPK_DIR)/opt/etc/libsoup/...
# Documentation files should be installed in $(LIBSOUP_IPK_DIR)/opt/doc/libsoup/...
# Daemon startup scripts should be installed in $(LIBSOUP_IPK_DIR)/opt/etc/init.d/S??libsoup
#
# You may need to patch your application to make it use these locations.
#
$(LIBSOUP_IPK): $(LIBSOUP_BUILD_DIR)/.built
	rm -rf $(LIBSOUP_IPK_DIR) $(BUILD_DIR)/libsoup_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSOUP_BUILD_DIR) DESTDIR=$(LIBSOUP_IPK_DIR) SUBDIRS=libsoup install-strip
	rm -f $(LIBSOUP_IPK_DIR)/opt/lib/libsoup-2.2.la
	$(MAKE) $(LIBSOUP_IPK_DIR)/CONTROL/control
	echo $(LIBSOUP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSOUP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSOUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsoup-ipk: $(LIBSOUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsoup-clean:
	rm -f $(LIBSOUP_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSOUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsoup-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSOUP_DIR) $(LIBSOUP_BUILD_DIR) $(LIBSOUP_IPK_DIR) $(LIBSOUP_IPK)
#
#
# Some sanity check for the package.
#
libsoup-check: $(LIBSOUP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBSOUP_IPK)
