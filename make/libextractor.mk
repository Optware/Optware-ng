###########################################################
#
# libextractor
#
###########################################################

# You must replace "libextractor" and "LIBEXTRACTOR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBEXTRACTOR_VERSION, LIBEXTRACTOR_SITE and LIBEXTRACTOR_SOURCE define
# the upstream location of the source code for the package.
# LIBEXTRACTOR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBEXTRACTOR_UNZIP is the command used to unzip the source.
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
LIBEXTRACTOR_SITE=http://gnunet.org/libextractor/download
LIBEXTRACTOR_VERSION=0.5.17
LIBEXTRACTOR_SOURCE=libextractor-$(LIBEXTRACTOR_VERSION).tar.gz
LIBEXTRACTOR_DIR=libextractor-$(LIBEXTRACTOR_VERSION)
LIBEXTRACTOR_UNZIP=zcat
LIBEXTRACTOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBEXTRACTOR_DESCRIPTION=Library to extract meta-data from files of arbitrary type.
LIBEXTRACTOR_SECTION=lib
LIBEXTRACTOR_PRIORITY=optional
LIBEXTRACTOR_DEPENDS=libtool, zlib, bzip2
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBEXTRACTOR_DEPENDS+=, libiconv
endif
LIBEXTRACTOR_SUGGESTS=
LIBEXTRACTOR_CONFLICTS=

#
# LIBEXTRACTOR_IPK_VERSION should be incremented when the ipk changes.
#
LIBEXTRACTOR_IPK_VERSION=1

#
# LIBEXTRACTOR_CONFFILES should be a list of user-editable files
#LIBEXTRACTOR_CONFFILES=/opt/etc/libextractor.conf /opt/etc/init.d/SXXlibextractor

#
# LIBEXTRACTOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBEXTRACTOR_PATCHES=$(LIBEXTRACTOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBEXTRACTOR_CPPFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBEXTRACTOR_LDFLAGS=-liconv
else
LIBEXTRACTOR_LDFLAGS=
endif

ifeq ($(LIBC_STYLE), uclibc)
LIBEXTRACTOR_CONFIG_OPTS=--disable-exiv2
else
LIBEXTRACTOR_CONFIG_OPTS=--enable-exiv2
endif

#
# LIBEXTRACTOR_BUILD_DIR is the directory in which the build is done.
# LIBEXTRACTOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBEXTRACTOR_IPK_DIR is the directory in which the ipk is built.
# LIBEXTRACTOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBEXTRACTOR_SOURCE_DIR=$(SOURCE_DIR)/libextractor

LIBEXTRACTOR_BUILD_DIR=$(BUILD_DIR)/libextractor
LIBEXTRACTOR_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/libextractor

LIBEXTRACTOR_IPK_DIR=$(BUILD_DIR)/libextractor-$(LIBEXTRACTOR_VERSION)-ipk
LIBEXTRACTOR_IPK=$(BUILD_DIR)/libextractor_$(LIBEXTRACTOR_VERSION)-$(LIBEXTRACTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libextractor-source libextractor-unpack libextractor libextractor-stage libextractor-ipk libextractor-clean libextractor-dirclean libextractor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBEXTRACTOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBEXTRACTOR_SITE)/$(LIBEXTRACTOR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libextractor-source: $(DL_DIR)/$(LIBEXTRACTOR_SOURCE) $(LIBEXTRACTOR_PATCHES)

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(LIBEXTRACTOR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEXTRACTOR_SOURCE) $(LIBEXTRACTOR_PATCHES) make/libextractor.mk
else
$(LIBEXTRACTOR_BUILD_DIR)/.configured: $(LIBEXTRACTOR_HOST_BUILD_DIR)/.built
endif
	$(MAKE) libtool-stage zlib-stage bzip2-stage
	$(MAKE) libvorbis-stage libexif-stage
	$(MAKE) libmpeg2-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBEXTRACTOR_DIR) $(LIBEXTRACTOR_BUILD_DIR)
	$(LIBEXTRACTOR_UNZIP) $(DL_DIR)/$(LIBEXTRACTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBEXTRACTOR_PATCHES)" ; \
		then cat $(LIBEXTRACTOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBEXTRACTOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBEXTRACTOR_DIR)" != "$(LIBEXTRACTOR_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBEXTRACTOR_DIR) $(LIBEXTRACTOR_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e 's|./dictionary-builder |$(LIBEXTRACTOR_HOST_BUILD_DIR)/src/plugins/printable/dictionary-builder |g' \
		$(LIBEXTRACTOR_BUILD_DIR)/src/plugins/printable/Makefile.in
endif
	sed -i -e '/$$(MAKE) .* install-exec-am install-data-am/s/^/#/'  $(LIBEXTRACTOR_BUILD_DIR)/libltdl/Makefile.in
	(cd $(LIBEXTRACTOR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBEXTRACTOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBEXTRACTOR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-ltdl-install \
		$(LIBEXTRACTOR_CONFIG_OPTS) \
		--disable-glib \
		--disable-gnome \
		--disable-gsf \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^#define error_t int/d' $(LIBEXTRACTOR_BUILD_DIR)/src/include/config.h
	$(PATCH_LIBTOOL) $(LIBEXTRACTOR_BUILD_DIR)/libtool $(LIBEXTRACTOR_BUILD_DIR)/libltdl/libtool
	touch $@

libextractor-unpack: $(LIBEXTRACTOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBEXTRACTOR_BUILD_DIR)/.built: $(LIBEXTRACTOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBEXTRACTOR_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libextractor: $(LIBEXTRACTOR_BUILD_DIR)/.built

$(LIBEXTRACTOR_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(LIBEXTRACTOR_SOURCE) $(LIBEXTRACTOR_PATCHES) make/libextractor.mk
	rm -f $@
	rm -rf $(HOST_BUILD_DIR)/$(LIBEXTRACTOR_DIR) $(LIBEXTRACTOR_HOST_BUILD_DIR)
	$(LIBEXTRACTOR_UNZIP) $(DL_DIR)/$(LIBEXTRACTOR_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(LIBEXTRACTOR_DIR) $(LIBEXTRACTOR_HOST_BUILD_DIR)
	(cd $(LIBEXTRACTOR_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--enable-ltdl-install \
		--disable-glib \
		--disable-exiv2 \
		--disable-gnome \
		--disable-gsf \
		--disable-nls \
		--disable-static \
	)
	cd $(LIBEXTRACTOR_HOST_BUILD_DIR)/src/plugins/printable; \
	    $(HOSTCC) -o dictionary-builder -I../../include dictionary-builder.c
	touch $@

#
# If you are building a library, then you need to stage it too.
#
$(LIBEXTRACTOR_BUILD_DIR)/.staged: $(LIBEXTRACTOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBEXTRACTOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libextractor.la $(STAGING_LIB_DIR)/libextractor/*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libextractor.pc
	touch $@

libextractor-stage: $(LIBEXTRACTOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libextractor
#
$(LIBEXTRACTOR_IPK_DIR)/CONTROL/control:
	@install -d $(LIBEXTRACTOR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libextractor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBEXTRACTOR_PRIORITY)" >>$@
	@echo "Section: $(LIBEXTRACTOR_SECTION)" >>$@
	@echo "Version: $(LIBEXTRACTOR_VERSION)-$(LIBEXTRACTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBEXTRACTOR_MAINTAINER)" >>$@
	@echo "Source: $(LIBEXTRACTOR_SITE)/$(LIBEXTRACTOR_SOURCE)" >>$@
	@echo "Description: $(LIBEXTRACTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBEXTRACTOR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBEXTRACTOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBEXTRACTOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBEXTRACTOR_IPK_DIR)/opt/sbin or $(LIBEXTRACTOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBEXTRACTOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBEXTRACTOR_IPK_DIR)/opt/etc/libextractor/...
# Documentation files should be installed in $(LIBEXTRACTOR_IPK_DIR)/opt/doc/libextractor/...
# Daemon startup scripts should be installed in $(LIBEXTRACTOR_IPK_DIR)/opt/etc/init.d/S??libextractor
#
# You may need to patch your application to make it use these locations.
#
$(LIBEXTRACTOR_IPK): $(LIBEXTRACTOR_BUILD_DIR)/.built
	rm -rf $(LIBEXTRACTOR_IPK_DIR) $(BUILD_DIR)/libextractor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBEXTRACTOR_BUILD_DIR) DESTDIR=$(LIBEXTRACTOR_IPK_DIR) install-strip
	rm -f $(LIBEXTRACTOR_IPK_DIR)/opt/lib/libextractor.la $(LIBEXTRACTOR_IPK_DIR)/opt/lib/libextractor/*.la
#	install -d $(LIBEXTRACTOR_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBEXTRACTOR_SOURCE_DIR)/libextractor.conf $(LIBEXTRACTOR_IPK_DIR)/opt/etc/libextractor.conf
#	install -d $(LIBEXTRACTOR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBEXTRACTOR_SOURCE_DIR)/rc.libextractor $(LIBEXTRACTOR_IPK_DIR)/opt/etc/init.d/SXXlibextractor
	$(MAKE) $(LIBEXTRACTOR_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBEXTRACTOR_SOURCE_DIR)/postinst $(LIBEXTRACTOR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBEXTRACTOR_SOURCE_DIR)/prerm $(LIBEXTRACTOR_IPK_DIR)/CONTROL/prerm
	echo $(LIBEXTRACTOR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBEXTRACTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEXTRACTOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libextractor-ipk: $(LIBEXTRACTOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libextractor-clean:
	rm -f $(LIBEXTRACTOR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBEXTRACTOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libextractor-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEXTRACTOR_DIR) $(LIBEXTRACTOR_BUILD_DIR) $(LIBEXTRACTOR_IPK_DIR) $(LIBEXTRACTOR_IPK)

#
# Some sanity check for the package.
#
libextractor-check: $(LIBEXTRACTOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBEXTRACTOR_IPK)
