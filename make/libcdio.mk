###########################################################
#
# libcdio
#
###########################################################
#
# LIBCDIO_VERSION, LIBCDIO_SITE and LIBCDIO_SOURCE define
# the upstream location of the source code for the package.
# LIBCDIO_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCDIO_UNZIP is the command used to unzip the source.
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
LIBCDIO_SITE=http://ftp.gnu.org/gnu/libcdio
LIBCDIO_VERSION=0.78.2
LIBCDIO_SOURCE=libcdio-$(LIBCDIO_VERSION).tar.gz
LIBCDIO_DIR=libcdio-$(LIBCDIO_VERSION)
LIBCDIO_UNZIP=zcat
LIBCDIO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCDIO_DESCRIPTION=The Compact Disc Input and Control library (libcdio) contains a library for CD-ROM and CD image access.
LIBCDIO_SECTION=lib
LIBCDIO_PRIORITY=optional
LIBCDIO_DEPENDS=
LIBCDIO_SUGGESTS=
LIBCDIO_CONFLICTS=

#
# LIBCDIO_IPK_VERSION should be incremented when the ipk changes.
#
LIBCDIO_IPK_VERSION=1

#
# LIBCDIO_CONFFILES should be a list of user-editable files
#LIBCDIO_CONFFILES=/opt/etc/libcdio.conf /opt/etc/init.d/SXXlibcdio

#
# LIBCDIO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
LIBCDIO_PATCHES=$(LIBCDIO_SOURCE_DIR)/configure.ac.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCDIO_CPPFLAGS=
ifdef NO_BUILTIN_MATH
LIBCDIO_CPPFLAGS+=-fno-builtin-cos -fno-builtin-sin
endif
LIBCDIO_LDFLAGS=

#
# LIBCDIO_BUILD_DIR is the directory in which the build is done.
# LIBCDIO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCDIO_IPK_DIR is the directory in which the ipk is built.
# LIBCDIO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCDIO_BUILD_DIR=$(BUILD_DIR)/libcdio
LIBCDIO_SOURCE_DIR=$(SOURCE_DIR)/libcdio
LIBCDIO_IPK_DIR=$(BUILD_DIR)/libcdio-$(LIBCDIO_VERSION)-ipk
LIBCDIO_IPK=$(BUILD_DIR)/libcdio_$(LIBCDIO_VERSION)-$(LIBCDIO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libcdio-source libcdio-unpack libcdio libcdio-stage libcdio-ipk libcdio-clean libcdio-dirclean libcdio-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCDIO_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBCDIO_SITE)/$(LIBCDIO_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBCDIO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcdio-source: $(DL_DIR)/$(LIBCDIO_SOURCE) $(LIBCDIO_PATCHES)

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
$(LIBCDIO_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCDIO_SOURCE) $(LIBCDIO_PATCHES) make/libcdio.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBCDIO_DIR) $(LIBCDIO_BUILD_DIR)
	$(LIBCDIO_UNZIP) $(DL_DIR)/$(LIBCDIO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBCDIO_PATCHES)" ; \
		then cat $(LIBCDIO_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(LIBCDIO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBCDIO_DIR)" != "$(LIBCDIO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBCDIO_DIR) $(LIBCDIO_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	cd $(LIBCDIO_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif
endif
	(cd $(LIBCDIO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCDIO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCDIO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBCDIO_BUILD_DIR)/libtool
	touch $@

libcdio-unpack: $(LIBCDIO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBCDIO_BUILD_DIR)/.built: $(LIBCDIO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBCDIO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libcdio: $(LIBCDIO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCDIO_BUILD_DIR)/.staged: $(LIBCDIO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBCDIO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/libcdio*.pc \
		$(STAGING_LIB_DIR)/pkgconfig/libiso9660.pc
	touch $@

libcdio-stage: $(LIBCDIO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libcdio
#
$(LIBCDIO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libcdio" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCDIO_PRIORITY)" >>$@
	@echo "Section: $(LIBCDIO_SECTION)" >>$@
	@echo "Version: $(LIBCDIO_VERSION)-$(LIBCDIO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCDIO_MAINTAINER)" >>$@
	@echo "Source: $(LIBCDIO_SITE)/$(LIBCDIO_SOURCE)" >>$@
	@echo "Description: $(LIBCDIO_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCDIO_DEPENDS)" >>$@
	@echo "Suggests: $(LIBCDIO_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBCDIO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCDIO_IPK_DIR)/opt/sbin or $(LIBCDIO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCDIO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBCDIO_IPK_DIR)/opt/etc/libcdio/...
# Documentation files should be installed in $(LIBCDIO_IPK_DIR)/opt/doc/libcdio/...
# Daemon startup scripts should be installed in $(LIBCDIO_IPK_DIR)/opt/etc/init.d/S??libcdio
#
# You may need to patch your application to make it use these locations.
#
$(LIBCDIO_IPK): $(LIBCDIO_BUILD_DIR)/.built
	rm -rf $(LIBCDIO_IPK_DIR) $(BUILD_DIR)/libcdio_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBCDIO_BUILD_DIR) DESTDIR=$(LIBCDIO_IPK_DIR) install-strip
#	install -d $(LIBCDIO_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBCDIO_SOURCE_DIR)/libcdio.conf $(LIBCDIO_IPK_DIR)/opt/etc/libcdio.conf
#	install -d $(LIBCDIO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBCDIO_SOURCE_DIR)/rc.libcdio $(LIBCDIO_IPK_DIR)/opt/etc/init.d/SXXlibcdio
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCDIO_IPK_DIR)/opt/etc/init.d/SXXlibcdio
	$(MAKE) $(LIBCDIO_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBCDIO_SOURCE_DIR)/postinst $(LIBCDIO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCDIO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBCDIO_SOURCE_DIR)/prerm $(LIBCDIO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBCDIO_IPK_DIR)/CONTROL/prerm
	echo $(LIBCDIO_CONFFILES) | sed -e 's/ /\n/g' > $(LIBCDIO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCDIO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcdio-ipk: $(LIBCDIO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcdio-clean:
	rm -f $(LIBCDIO_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBCDIO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcdio-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCDIO_DIR) $(LIBCDIO_BUILD_DIR) $(LIBCDIO_IPK_DIR) $(LIBCDIO_IPK)
#
#
# Some sanity check for the package.
#
libcdio-check: $(LIBCDIO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBCDIO_IPK)
