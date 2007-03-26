###########################################################
#
# libmpeg2
#
###########################################################
#
# LIBMPEG2_VERSION, LIBMPEG2_SITE and LIBMPEG2_SOURCE define
# the upstream location of the source code for the package.
# LIBMPEG2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMPEG2_UNZIP is the command used to unzip the source.
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
LIBMPEG2_SITE=http://libmpeg2.sourceforge.net/files
LIBMPEG2_VERSION=0.4.1
LIBMPEG2_SOURCE=mpeg2dec-$(LIBMPEG2_VERSION).tar.gz
LIBMPEG2_DIR=mpeg2dec-$(LIBMPEG2_VERSION)
LIBMPEG2_UNZIP=zcat
LIBMPEG2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMPEG2_DESCRIPTION=A free library for decoding MPEG-2 and MPEG-1 video streams.
MPEG2DEC_DESCRIPTION=A simple decoder and demultiplexer for MPEG-1 and MPEG-2 streams to test libmpeg2.
LIBMPEG2_SECTION=video
LIBMPEG2_PRIORITY=optional
LIBMPEG2_DEPENDS=
MPEG2DEC_DEPENDS=libmpeg2
LIBMPEG2_SUGGESTS=
LIBMPEG2_CONFLICTS=

#
# LIBMPEG2_IPK_VERSION should be incremented when the ipk changes.
#
LIBMPEG2_IPK_VERSION=2

#
# LIBMPEG2_CONFFILES should be a list of user-editable files
#LIBMPEG2_CONFFILES=/opt/etc/libmpeg2.conf /opt/etc/init.d/SXXlibmpeg2

#
# LIBMPEG2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMPEG2_PATCHES=$(LIBMPEG2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMPEG2_CPPFLAGS=
LIBMPEG2_LDFLAGS=

#
# LIBMPEG2_BUILD_DIR is the directory in which the build is done.
# LIBMPEG2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMPEG2_IPK_DIR is the directory in which the ipk is built.
# LIBMPEG2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMPEG2_BUILD_DIR=$(BUILD_DIR)/libmpeg2
LIBMPEG2_SOURCE_DIR=$(SOURCE_DIR)/libmpeg2

LIBMPEG2_IPK_DIR=$(BUILD_DIR)/libmpeg2-$(LIBMPEG2_VERSION)-ipk
LIBMPEG2_IPK=$(BUILD_DIR)/libmpeg2_$(LIBMPEG2_VERSION)-$(LIBMPEG2_IPK_VERSION)_$(TARGET_ARCH).ipk

MPEG2DEC_IPK_DIR=$(BUILD_DIR)/mpeg2dec-$(LIBMPEG2_VERSION)-ipk
MPEG2DEC_IPK=$(BUILD_DIR)/mpeg2dec_$(LIBMPEG2_VERSION)-$(LIBMPEG2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmpeg2-source libmpeg2-unpack libmpeg2 libmpeg2-stage libmpeg2-ipk libmpeg2-clean libmpeg2-dirclean libmpeg2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMPEG2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMPEG2_SITE)/$(LIBMPEG2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmpeg2-source: $(DL_DIR)/$(LIBMPEG2_SOURCE) $(LIBMPEG2_PATCHES)

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
$(LIBMPEG2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMPEG2_SOURCE) $(LIBMPEG2_PATCHES) make/libmpeg2.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMPEG2_DIR) $(LIBMPEG2_BUILD_DIR)
	$(LIBMPEG2_UNZIP) $(DL_DIR)/$(LIBMPEG2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMPEG2_PATCHES)" ; \
		then cat $(LIBMPEG2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMPEG2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMPEG2_DIR)" != "$(LIBMPEG2_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMPEG2_DIR) $(LIBMPEG2_BUILD_DIR) ; \
	fi
	(cd $(LIBMPEG2_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMPEG2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMPEG2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-sdl \
		--enable-shared \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMPEG2_BUILD_DIR)/libtool
	touch $@

libmpeg2-unpack: $(LIBMPEG2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMPEG2_BUILD_DIR)/.built: $(LIBMPEG2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBMPEG2_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libmpeg2: $(LIBMPEG2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMPEG2_BUILD_DIR)/.staged: $(LIBMPEG2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBMPEG2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmpeg2*.pc
	touch $@

libmpeg2-stage: $(LIBMPEG2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmpeg2
#
$(LIBMPEG2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmpeg2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPEG2_PRIORITY)" >>$@
	@echo "Section: $(LIBMPEG2_SECTION)" >>$@
	@echo "Version: $(LIBMPEG2_VERSION)-$(LIBMPEG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPEG2_MAINTAINER)" >>$@
	@echo "Source: $(LIBMPEG2_SITE)/$(LIBMPEG2_SOURCE)" >>$@
	@echo "Description: $(LIBMPEG2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMPEG2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPEG2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPEG2_CONFLICTS)" >>$@

$(MPEG2DEC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpeg2dec" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPEG2_PRIORITY)" >>$@
	@echo "Section: $(LIBMPEG2_SECTION)" >>$@
	@echo "Version: $(LIBMPEG2_VERSION)-$(LIBMPEG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPEG2_MAINTAINER)" >>$@
	@echo "Source: $(LIBMPEG2_SITE)/$(LIBMPEG2_SOURCE)" >>$@
	@echo "Description: $(MPEG2DEC_DESCRIPTION)" >>$@
	@echo "Depends: $(MPEG2DEC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPEG2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPEG2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMPEG2_IPK_DIR)/opt/sbin or $(LIBMPEG2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMPEG2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMPEG2_IPK_DIR)/opt/etc/libmpeg2/...
# Documentation files should be installed in $(LIBMPEG2_IPK_DIR)/opt/doc/libmpeg2/...
# Daemon startup scripts should be installed in $(LIBMPEG2_IPK_DIR)/opt/etc/init.d/S??libmpeg2
#
# You may need to patch your application to make it use these locations.
#
$(LIBMPEG2_IPK): $(LIBMPEG2_BUILD_DIR)/.built
	rm -rf $(LIBMPEG2_IPK_DIR) $(BUILD_DIR)/libmpeg2_*_$(TARGET_ARCH).ipk
	rm -rf $(MPEG2DEC_IPK_DIR) $(BUILD_DIR)/mpeg2dec_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMPEG2_BUILD_DIR) DESTDIR=$(LIBMPEG2_IPK_DIR) install-strip
	install -d $(MPEG2DEC_IPK_DIR)/opt/share
	mv $(LIBMPEG2_IPK_DIR)/opt/bin $(MPEG2DEC_IPK_DIR)/opt/
	mv $(LIBMPEG2_IPK_DIR)/opt/man $(MPEG2DEC_IPK_DIR)/opt/share/
	$(MAKE) $(LIBMPEG2_IPK_DIR)/CONTROL/control
	$(MAKE) $(MPEG2DEC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMPEG2_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPEG2DEC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmpeg2-ipk: $(LIBMPEG2_IPK) $(MPEG2DEC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmpeg2-clean:
	rm -f $(LIBMPEG2_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMPEG2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmpeg2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMPEG2_DIR) $(LIBMPEG2_BUILD_DIR)
	rm -rf $(LIBMPEG2_IPK_DIR) $(LIBMPEG2_IPK)
	rm -rf $(MPEG2DEC_IPK_DIR) $(MPEG2DEC_IPK)
#
#
# Some sanity check for the package.
#
libmpeg2-check: $(LIBMPEG2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBMPEG2_IPK) $(MPEG2DEC_IPK)
