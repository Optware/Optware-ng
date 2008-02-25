###########################################################
#
# libgphoto2
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
LIBGPHOTO2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gphoto
LIBGPHOTO2_VERSION=2.4.0
LIBGPHOTO2_SOURCE=libgphoto2-$(LIBGPHOTO2_VERSION).tar.bz2
LIBGPHOTO2_DIR=libgphoto2-$(LIBGPHOTO2_VERSION)
LIBGPHOTO2_UNZIP=bzcat
LIBGPHOTO2_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
LIBGPHOTO2_DESCRIPTION=digital camera software libraries
LIBGPHOTO2_SECTION=libs
LIBGPHOTO2_PRIORITY=optional
LIBGPHOTO2_DEPENDS=libtool, popt, libusb
LIBGPHOTO2_SUGGESTS=gphoto2
LIBGPHOTO2_CONFLICTS=

#
# LIBGPHOTO2_IPK_VERSION should be incremented when the ipk changes.
#
LIBGPHOTO2_IPK_VERSION=1

#
# LIBGPHOTO2_CONFFILES should be a list of user-editable files
# LIBGPHOTO2_CONFFILES=/opt/etc/libgphoto2.conf /opt/etc/init.d/SXXlibgphoto2

#
# LIBGPHOTO2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBGPHOTO2_PATCHES=
#
# Version 2.3.1
#
#LIBGPHOTO2_PATCHES=$(LIBGPHOTO2_SOURCE_DIR)/Makefile_am_in.patch \
#	$(LIBGPHOTO2_SOURCE_DIR)/packaging-generic.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGPHOTO2_CPPFLAGS=
LIBGPHOTO2_LDFLAGS=

#
# LIBGPHOTO2_BUILD_DIR is the directory in which the build is done.
# LIBGPHOTO2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGPHOTO2_IPK_DIR is the directory in which the ipk is built.
# LIBGPHOTO2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGPHOTO2_BUILD_DIR=$(BUILD_DIR)/libgphoto2
LIBGPHOTO2_SOURCE_DIR=$(SOURCE_DIR)/libgphoto2
LIBGPHOTO2_IPK_DIR=$(BUILD_DIR)/libgphoto2-$(LIBGPHOTO2_VERSION)-ipk
LIBGPHOTO2_IPK=$(BUILD_DIR)/libgphoto2_$(LIBGPHOTO2_VERSION)-$(LIBGPHOTO2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgphoto2-source libgphoto2-unpack libgphoto2 libgphoto2-stage libgphoto2-ipk libgphoto2-clean libgphoto2-dirclean libgphoto2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGPHOTO2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGPHOTO2_SITE)/$(LIBGPHOTO2_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBGPHOTO2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libgphoto2-source: $(DL_DIR)/$(LIBGPHOTO2_SOURCE) $(LIBGPHOTO2_PATCHES)

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
$(LIBGPHOTO2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGPHOTO2_SOURCE) $(LIBGPHOTO2_PATCHES) make/libgphoto2.mk
	$(MAKE) libusb-stage popt-stage libtool-stage
	rm -rf $(BUILD_DIR)/$(LIBGPHOTO2_DIR) $(LIBGPHOTO2_BUILD_DIR)
	$(LIBGPHOTO2_UNZIP) $(DL_DIR)/$(LIBGPHOTO2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBGPHOTO2_PATCHES)" ; \
		then cat $(LIBGPHOTO2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBGPHOTO2_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBGPHOTO2_DIR)" != "$(LIBGPHOTO2_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBGPHOTO2_DIR) $(LIBGPHOTO2_BUILD_DIR) ; \
	fi
	(cd $(LIBGPHOTO2_BUILD_DIR); 					\
		PATH=$(STAGING_DIR)/opt/bin:$${PATH}			\
		$(TARGET_CONFIGURE_OPTS)				\
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBGPHOTO2_CPPFLAGS)"	\
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGPHOTO2_LDFLAGS)" 	\
		PKG_CONFIG="$(STAGING_DIR)/opt/bin"			\
		PKG_CONFIG_PATH="$(STAGING_DIR)/opt/lib/pkgconfig"	\
		LIBUSB_CFLAGS=-I$(STAGING_INCLUDE_DIR) \
		LIBUSB_LIBS="-L$(STAGING_LIB_DIR) -lusb" \
		./configure						\
		--build=$(GNU_HOST_NAME)				\
		--host=$(GNU_TARGET_NAME)				\
		--target=$(GNU_TARGET_NAME)				\
		--prefix=/opt						\
		--disable-nls						\
		--disable-static					\
	)
	$(PATCH_LIBTOOL) $(LIBGPHOTO2_BUILD_DIR)/libtool
	touch $(LIBGPHOTO2_BUILD_DIR)/.configured

libgphoto2-unpack: $(LIBGPHOTO2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGPHOTO2_BUILD_DIR)/.built: $(LIBGPHOTO2_BUILD_DIR)/.configured
	rm -f $(LIBGPHOTO2_BUILD_DIR)/.built
	$(MAKE) -C $(LIBGPHOTO2_BUILD_DIR)
	touch $(LIBGPHOTO2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libgphoto2: $(LIBGPHOTO2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGPHOTO2_BUILD_DIR)/.staged: $(LIBGPHOTO2_BUILD_DIR)/.built
	rm -f $(LIBGPHOTO2_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBGPHOTO2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBGPHOTO2_BUILD_DIR)/.staged

$(STAGING_DIR)/opt/lib/libgphoto2.so: $(LIBGPHOTO2_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -d $(STAGING_DIR)/opt/bin
	install -d $(STAGING_DIR)/opt/man/man1
	$(MAKE) -C $(LIBGPHOTO2_BUILD_DIR) prefix=$(STAGING_DIR)/opt install
	rm -f $(STAGING_DIR)/opt/lib/libgphoto2.la $(STAGING_DIR)/opt/lib/libgphoto2_port.la

libgphoto2-stage: $(STAGING_DIR)/opt/lib/libgphoto2.so
#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libgphoto2
#
$(LIBGPHOTO2_IPK_DIR)/CONTROL/control:
	@install -d $(LIBGPHOTO2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libgphoto2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGPHOTO2_PRIORITY)" >>$@
	@echo "Section: $(LIBGPHOTO2_SECTION)" >>$@
	@echo "Version: $(LIBGPHOTO2_VERSION)-$(LIBGPHOTO2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGPHOTO2_MAINTAINER)" >>$@
	@echo "Source: $(LIBGPHOTO2_SITE)/$(LIBGPHOTO2_SOURCE)" >>$@
	@echo "Description: $(LIBGPHOTO2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGPHOTO2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGPHOTO2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGPHOTO2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGPHOTO2_IPK_DIR)/opt/sbin or $(LIBGPHOTO2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGPHOTO2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGPHOTO2_IPK_DIR)/opt/etc/libgphoto2/...
# Documentation files should be installed in $(LIBGPHOTO2_IPK_DIR)/opt/doc/libgphoto2/...
# Daemon startup scripts should be installed in $(LIBGPHOTO2_IPK_DIR)/opt/etc/init.d/S??libgphoto2
#
# You may need to patch your application to make it use these locations.
#
$(LIBGPHOTO2_IPK): $(LIBGPHOTO2_BUILD_DIR)/.built
	rm -rf $(LIBGPHOTO2_IPK_DIR) $(BUILD_DIR)/libgphoto2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBGPHOTO2_BUILD_DIR) DESTDIR=$(LIBGPHOTO2_IPK_DIR) install-strip
#	install -d $(LIBGPHOTO2_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBGPHOTO2_SOURCE_DIR)/libgphoto2.conf $(LIBGPHOTO2_IPK_DIR)/opt/etc/libgphoto2.conf
#	install -d $(LIBGPHOTO2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBGPHOTO2_SOURCE_DIR)/rc.libgphoto2 $(LIBGPHOTO2_IPK_DIR)/opt/etc/init.d/SXXlibgphoto2
	$(MAKE) $(LIBGPHOTO2_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBGPHOTO2_SOURCE_DIR)/postinst $(LIBGPHOTO2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBGPHOTO2_SOURCE_DIR)/prerm $(LIBGPHOTO2_IPK_DIR)/CONTROL/prerm
	echo $(LIBGPHOTO2_CONFFILES) | sed -e 's/ /\n/g' > $(LIBGPHOTO2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGPHOTO2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libgphoto2-ipk: $(LIBGPHOTO2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libgphoto2-clean:
	rm -f $(LIBGPHOTO2_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBGPHOTO2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libgphoto2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGPHOTO2_DIR) $(LIBGPHOTO2_BUILD_DIR) $(LIBGPHOTO2_IPK_DIR) $(LIBGPHOTO2_IPK)
#
#
# Some sanity check for the package.
#
libgphoto2-check: $(LIBGPHOTO2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBGPHOTO2_IPK)
