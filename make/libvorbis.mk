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
LIBVORBIS_VERSION=1.3.5
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
LIBVORBIS_IPK_VERSION=2

#
# LIBVORBIS_CONFFILES should be a list of user-editable files
#LIBVORBIS_CONFFILES=$(TARGET_PREFIX)/etc/libvorbis.conf $(TARGET_PREFIX)/etc/init.d/SXXlibvorbis

#
# LIBVORBIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBVORBIS_PATCHES=$(LIBVORBIS_SOURCE_DIR)/libtool.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifneq (, $(filter syno-x07, $(OPTWARE_TARGET)))
LIBVORBIS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR) -D__USE_EXTERN_INLINES
else
LIBVORBIS_CPPFLAGS=$(STAGING_CPPFLAGS) -D__USE_EXTERN_INLINES
endif
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
	$(WGET) -P $(@D) $(LIBVORBIS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(LIBVORBIS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBVORBIS_SOURCE) $(LIBVORBIS_PATCHES) make/libvorbis.mk
	$(MAKE) libogg-stage
	rm -rf $(BUILD_DIR)/$(LIBVORBIS_DIR) $(@D)
	$(LIBVORBIS_UNZIP) $(DL_DIR)/$(LIBVORBIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBVORBIS_PATCHES)" ; \
		then cat $(LIBVORBIS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBVORBIS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBVORBIS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBVORBIS_DIR) $(@D) ; \
	fi
	if test `$(TARGET_CC) -dumpversion | cut -c1` = "3"; then \
		sed -i -e 's/ -Wextra//g' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(LIBVORBIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBIS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e 's/examples//g' $(@D)/Makefile
ifneq (, $(filter syno-x07, $(OPTWARE_TARGET)))
	sed -i -e 's/ -O20//g' -e 's/ -O2//g' $(@D)/lib/Makefile
endif
	touch $@

libvorbis-unpack: $(LIBVORBIS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBVORBIS_BUILD_DIR)/.built: $(LIBVORBIS_BUILD_DIR)/.configured
	rm -f $@
	CFLAGS="$(LIBVORBIS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(LIBVORBIS_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libvorbis: $(LIBVORBIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBVORBIS_BUILD_DIR)/.staged: $(LIBVORBIS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|prefix=$(TARGET_PREFIX)|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/vorbisenc.pc \
		$(STAGING_LIB_DIR)/pkgconfig/vorbisfile.pc \
		$(STAGING_LIB_DIR)/pkgconfig/vorbis.pc
	rm -f $(STAGING_LIB_DIR)/libvorbisenc.la
	rm -f $(STAGING_LIB_DIR)/libvorbisfile.la
	rm -f $(STAGING_LIB_DIR)/libvorbis.la
	touch $@

libvorbis-stage: $(LIBVORBIS_BUILD_DIR)/.staged


$(LIBVORBIS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
# Binaries should be installed into $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/etc/libvorbis/...
# Documentation files should be installed in $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/doc/libvorbis/...
# Daemon startup scripts should be installed in $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libvorbis
#
# You may need to patch your application to make it use these locations.
#
$(LIBVORBIS_IPK): $(LIBVORBIS_BUILD_DIR)/.built
	rm -rf $(LIBVORBIS_IPK_DIR) $(BUILD_DIR)/libvorbis_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBVORBIS_BUILD_DIR) DESTDIR=$(LIBVORBIS_IPK_DIR) install-strip
	rm $(LIBVORBIS_IPK_DIR)$(TARGET_PREFIX)/lib/libvorbis*.la
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
