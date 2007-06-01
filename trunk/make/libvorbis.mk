###########################################################
#
# libvorbis
#
###########################################################

# You must replace "libvorbis" and "LIBVORBIS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBVORBIS_VERSION, LIBVORBIS_SITE and LIBVORBIS_SOURCE define
# the upstream location of the source code for the package.
# LIBVORBIS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBVORBIS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBVORBIS_SITE=http://downloads.xiph.org/releases/vorbis
LIBVORBIS_VERSION=1.1.2
LIBVORBIS_SOURCE=libvorbis-$(LIBVORBIS_VERSION).tar.gz
LIBVORBIS_DIR=libvorbis-$(LIBVORBIS_VERSION)
LIBVORBIS_UNZIP=zcat
LIBVORBIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBVORBIS_DESCRIPTION=Ogg Vorbis compressed audio format.
LIBVORBIS_SECTION=lib
LIBVORBIS_PRIORITY=optional
LIBVORBIS_DEPENDS=libogg
LIBVORBIS_SUGGESTS=
LIBVORBIS_CONFLICTS=

#
# LIBVORBIS_IPK_VERSION should be incremented when the ipk changes.
#
LIBVORBIS_IPK_VERSION=5

#
# LIBVORBIS_CONFFILES should be a list of user-editable files
#LIBVORBIS_CONFFILES=/opt/etc/libvorbis.conf /opt/etc/init.d/SXXlibvorbis

#
# LIBVORBIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBVORBIS_PATCHES=$(LIBVORBIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBVORBIS_CPPFLAGS=-D__USE_EXTERN_INLINES 
ifdef NO_BUILTIN_MATH
LIBVORBIS_CPPFLAGS+= -fno-builtin-cos -fno-builtin-acos -fno-builtin-rint -fno-builtin-lrint -fno-builtin-sin
endif
LIBVORBIS_LDFLAGS=

#
# LIBVORBIS_BUILD_DIR is the directory in which the build is done.
# LIBVORBIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBVORBIS_IPK_DIR is the directory in which the ipk is built.
# LIBVORBIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBVORBIS_BUILD_DIR=$(BUILD_DIR)/libvorbis
LIBVORBIS_SOURCE_DIR=$(SOURCE_DIR)/libvorbis
LIBVORBIS_IPK_DIR=$(BUILD_DIR)/libvorbis-$(LIBVORBIS_VERSION)-ipk
LIBVORBIS_IPK=$(BUILD_DIR)/libvorbis_$(LIBVORBIS_VERSION)-$(LIBVORBIS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBVORBIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libvorbis-source: $(DL_DIR)/$(LIBVORBIS_SOURCE) $(LIBVORBIS_PATCHES)

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
$(LIBVORBIS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBVORBIS_SOURCE) $(LIBVORBIS_PATCHES)
	$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR)
	$(LIBVORBIS_UNZIP) $(DL_DIR)/$(LIBVORBIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBVORBIS_PATCHES)" ; \
		then cat $(LIBVORBIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBVORBIS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBVORBIS_DIR)" != "$(LIBVORBIS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR) ; \
	fi
	(cd $(LIBVORBIS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBVORBIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBIS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ogg=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBVORBIS_BUILD_DIR)/libtool
	sed -i -e 's/examples//g' $(LIBVORBIS_BUILD_DIR)/Makefile
	touch $(LIBVORBIS_BUILD_DIR)/.configured

libvorbis-unpack: $(LIBVORBIS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBVORBIS_BUILD_DIR)/.built: $(LIBVORBIS_BUILD_DIR)/.configured
	rm -f $(LIBVORBIS_BUILD_DIR)/.built
	CFLAGS="$(STAGING_CPPFLAGS) $(LIBVORBIS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBIS_LDFLAGS)" \
	$(MAKE) -C $(LIBVORBIS_BUILD_DIR)
	touch $(LIBVORBIS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libvorbis: $(LIBVORBIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBVORBIS_BUILD_DIR)/.staged: $(LIBVORBIS_BUILD_DIR)/.built
	rm -f $(LIBVORBIS_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBVORBIS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|prefix=/opt|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/vorbisenc.pc \
		$(STAGING_LIB_DIR)/pkgconfig/vorbisfile.pc \
		$(STAGING_LIB_DIR)/pkgconfig/vorbis.pc
	rm -f $(STAGING_LIB_DIR)/libvorbisenc.la
	rm -f $(STAGING_LIB_DIR)/libvorbisfile.la
	rm -f $(STAGING_LIB_DIR)/libvorbis.la
	touch $(LIBVORBIS_BUILD_DIR)/.staged

libvorbis-stage: $(LIBVORBIS_BUILD_DIR)/.staged


$(LIBVORBIS_IPK_DIR)/CONTROL/control:
	@install -d $(LIBVORBIS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libvorbis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBVORBIS_PRIORITY)" >>$@
	@echo "Section: $(LIBVORBIS_SECTION)" >>$@
	@echo "Version: $(LIBVORBIS_VERSION)-$(LIBVORBIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBVORBIS_MAINTAINER)" >>$@
	@echo "Source: $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)" >>$@
	@echo "Description: $(LIBVORBIS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBVORBIS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBVORBIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBVORBIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBVORBIS_IPK_DIR)/opt/sbin or $(LIBVORBIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBVORBIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBVORBIS_IPK_DIR)/opt/etc/libvorbis/...
# Documentation files should be installed in $(LIBVORBIS_IPK_DIR)/opt/doc/libvorbis/...
# Daemon startup scripts should be installed in $(LIBVORBIS_IPK_DIR)/opt/etc/init.d/S??libvorbis
#
# You may need to patch your application to make it use these locations.
#
$(LIBVORBIS_IPK): $(LIBVORBIS_BUILD_DIR)/.built
	rm -rf $(LIBVORBIS_IPK_DIR) $(BUILD_DIR)/libvorbis_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBVORBIS_BUILD_DIR) DESTDIR=$(LIBVORBIS_IPK_DIR) install-strip
	rm $(LIBVORBIS_IPK_DIR)/opt/lib/libvorbis*.la
	$(MAKE) $(LIBVORBIS_IPK_DIR)/CONTROL/control
	echo $(LIBVORBIS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBVORBIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBVORBIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libvorbis-ipk: $(LIBVORBIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libvorbis-clean:
	-$(MAKE) -C $(LIBVORBIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libvorbis-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBVORBIS_DIR) $(LIBVORBIS_BUILD_DIR) $(LIBVORBIS_IPK_DIR) $(LIBVORBIS_IPK)
#
# Some sanity check for the package.
#
libvorbis-check: $(LIBVORBIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBVORBIS_IPK)
