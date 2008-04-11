###########################################################
#
# libdlna
#
###########################################################
#
# LIBDLNA_VERSION, LIBDLNA_SITE and LIBDLNA_SOURCE define
# the upstream location of the source code for the package.
# LIBDLNA_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDLNA_UNZIP is the command used to unzip the source.
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
LIBDLNA_SITE=http://libdlna.geexbox.org/releases
LIBDLNA_VERSION=0.2.3
LIBDLNA_SOURCE=libdlna-$(LIBDLNA_VERSION).tar.bz2
LIBDLNA_DIR=libdlna-$(LIBDLNA_VERSION)
LIBDLNA_UNZIP=bzcat
LIBDLNA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDLNA_DESCRIPTION=Reference DLNA (Digital Living Network Alliance) open-source implementation for Linux.
LIBDLNA_SECTION=lib
LIBDLNA_PRIORITY=optional
LIBDLNA_DEPENDS=ffmpeg
LIBDLNA_SUGGESTS=
LIBDLNA_CONFLICTS=

#
# LIBDLNA_IPK_VERSION should be incremented when the ipk changes.
#
LIBDLNA_IPK_VERSION=2

#
# LIBDLNA_CONFFILES should be a list of user-editable files
#LIBDLNA_CONFFILES=/opt/etc/libdlna.conf /opt/etc/init.d/SXXlibdlna

#
# LIBDLNA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDLNA_PATCHES=$(LIBDLNA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDLNA_CPPFLAGS=
LIBDLNA_LDFLAGS=

#
# LIBDLNA_BUILD_DIR is the directory in which the build is done.
# LIBDLNA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDLNA_IPK_DIR is the directory in which the ipk is built.
# LIBDLNA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDLNA_BUILD_DIR=$(BUILD_DIR)/libdlna
LIBDLNA_SOURCE_DIR=$(SOURCE_DIR)/libdlna
LIBDLNA_IPK_DIR=$(BUILD_DIR)/libdlna-$(LIBDLNA_VERSION)-ipk
LIBDLNA_IPK=$(BUILD_DIR)/libdlna_$(LIBDLNA_VERSION)-$(LIBDLNA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdlna-source libdlna-unpack libdlna libdlna-stage libdlna-ipk libdlna-clean libdlna-dirclean libdlna-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDLNA_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDLNA_SITE)/$(LIBDLNA_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBDLNA_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdlna-source: $(DL_DIR)/$(LIBDLNA_SOURCE) $(LIBDLNA_PATCHES)

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
$(LIBDLNA_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDLNA_SOURCE) $(LIBDLNA_PATCHES) make/libdlna.mk
	$(MAKE) ffmpeg-stage
	rm -rf $(BUILD_DIR)/$(LIBDLNA_DIR) $(@D)
	rm -f $(STAGING_INCLUDE_DIR)/dlna.h $(STAGING_LIB_DIR)/libdlna*
	$(LIBDLNA_UNZIP) $(DL_DIR)/$(LIBDLNA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDLNA_PATCHES)" ; \
		then cat $(LIBDLNA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDLNA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDLNA_DIR)" != "$(LIBDLNA_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBDLNA_DIR) $(@D) ; \
	fi
#		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
		--disable-static \
		;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDLNA_LDFLAGS)" \
		./configure \
		--cross-compile \
		--prefix=/opt \
		--with-ffmpeg-dir=$(STAGING_INCLUDE_DIR) \
	)
	sed -i -e '/VERSION=/s|=.*|=$(LIBDLNA_VERSION)|' $(@D)/config.mak
#	$(PATCH_LIBTOOL) $(LIBDLNA_BUILD_DIR)/libtool
	touch $@

libdlna-unpack: $(LIBDLNA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDLNA_BUILD_DIR)/.built: $(LIBDLNA_BUILD_DIR)/.configured
	rm -f $@
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDLNA_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libdlna: $(LIBDLNA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDLNA_BUILD_DIR)/.staged: $(LIBDLNA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libdlna.a
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
	       -e 's|^Version:|& $(LIBDLNA_VERSION)|' \
		$(STAGING_LIB_DIR)/pkgconfig/libdlna.pc
	touch $@

libdlna-stage: $(LIBDLNA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdlna
#
$(LIBDLNA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdlna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDLNA_PRIORITY)" >>$@
	@echo "Section: $(LIBDLNA_SECTION)" >>$@
	@echo "Version: $(LIBDLNA_VERSION)-$(LIBDLNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDLNA_MAINTAINER)" >>$@
	@echo "Source: $(LIBDLNA_SITE)/$(LIBDLNA_SOURCE)" >>$@
	@echo "Description: $(LIBDLNA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDLNA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDLNA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDLNA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDLNA_IPK_DIR)/opt/sbin or $(LIBDLNA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDLNA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDLNA_IPK_DIR)/opt/etc/libdlna/...
# Documentation files should be installed in $(LIBDLNA_IPK_DIR)/opt/doc/libdlna/...
# Daemon startup scripts should be installed in $(LIBDLNA_IPK_DIR)/opt/etc/init.d/S??libdlna
#
# You may need to patch your application to make it use these locations.
#
$(LIBDLNA_IPK): $(LIBDLNA_BUILD_DIR)/.built
	rm -rf $(LIBDLNA_IPK_DIR) $(BUILD_DIR)/libdlna_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDLNA_BUILD_DIR) DESTDIR=$(LIBDLNA_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBDLNA_IPK_DIR)/opt/lib/libdlna.so.$(LIBDLNA_VERSION)
	rm -f $(LIBDLNA_IPK_DIR)/opt/lib/libdlna.a
	$(MAKE) $(LIBDLNA_IPK_DIR)/CONTROL/control
	echo $(LIBDLNA_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDLNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDLNA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdlna-ipk: $(LIBDLNA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdlna-clean:
	rm -f $(LIBDLNA_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDLNA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdlna-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDLNA_DIR) $(LIBDLNA_BUILD_DIR) $(LIBDLNA_IPK_DIR) $(LIBDLNA_IPK)
#
#
# Some sanity check for the package.
#
libdlna-check: $(LIBDLNA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBDLNA_IPK)
