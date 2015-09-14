###########################################################
#
# libmnl
#
###########################################################
#
# LIBMNL_VERSION, LIBMNL_SITE and LIBMNL_SOURCE define
# the upstream location of the source code for the package.
# LIBMNL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMNL_UNZIP is the command used to unzip the source.
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
LIBMNL_SITE=ftp://ftp.netfilter.org/pub/libmnl
LIBMNL_VERSION=1.0.3
LIBMNL_SOURCE=libmnl-$(LIBMNL_VERSION).tar.bz2
LIBMNL_DIR=libmnl-$(LIBMNL_VERSION)
LIBMNL_UNZIP=bzcat
LIBMNL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMNL_DESCRIPTION=Minimalistic Netlink communication library.
LIBMNL_SECTION=kernel
LIBMNL_PRIORITY=optional
LIBMNL_DEPENDS=
LIBMNL_SUGGESTS=
LIBMNL_CONFLICTS=

#
# LIBMNL_IPK_VERSION should be incremented when the ipk changes.
#
LIBMNL_IPK_VERSION=1

#
# LIBMNL_CONFFILES should be a list of user-editable files
#LIBMNL_CONFFILES=/opt/etc/libmnl.conf /opt/etc/init.d/SXXlibmnl

#
# LIBMNL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMNL_PATCHES=$(LIBMNL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMNL_CPPFLAGS=
LIBMNL_LDFLAGS=

#
# LIBMNL_BUILD_DIR is the directory in which the build is done.
# LIBMNL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMNL_IPK_DIR is the directory in which the ipk is built.
# LIBMNL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMNL_BUILD_DIR=$(BUILD_DIR)/libmnl
LIBMNL_SOURCE_DIR=$(SOURCE_DIR)/libmnl
LIBMNL_IPK_DIR=$(BUILD_DIR)/libmnl-$(LIBMNL_VERSION)-ipk
LIBMNL_IPK=$(BUILD_DIR)/libmnl_$(LIBMNL_VERSION)-$(LIBMNL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmnl-source libmnl-unpack libmnl libmnl-stage libmnl-ipk libmnl-clean libmnl-dirclean libmnl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMNL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMNL_SITE)/$(LIBMNL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBMNL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmnl-source: $(DL_DIR)/$(LIBMNL_SOURCE) $(LIBMNL_PATCHES)

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
$(LIBMNL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMNL_SOURCE) $(LIBMNL_PATCHES) make/libmnl.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMNL_DIR) $(LIBMNL_BUILD_DIR)
	$(LIBMNL_UNZIP) $(DL_DIR)/$(LIBMNL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMNL_PATCHES)" ; \
		then cat $(LIBMNL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMNL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMNL_DIR)" != "$(LIBMNL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMNL_DIR) $(LIBMNL_BUILD_DIR) ; \
	fi
	(cd $(LIBMNL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMNL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMNL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMNL_BUILD_DIR)/libtool
	touch $@

libmnl-unpack: $(LIBMNL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMNL_BUILD_DIR)/.built: $(LIBMNL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBMNL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libmnl: $(LIBMNL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMNL_BUILD_DIR)/.staged: $(LIBMNL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBMNL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmnl.pc
	rm -f $(STAGING_LIB_DIR)/libmnl.la
	touch $@

libmnl-stage: $(LIBMNL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmnl
#
$(LIBMNL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmnl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMNL_PRIORITY)" >>$@
	@echo "Section: $(LIBMNL_SECTION)" >>$@
	@echo "Version: $(LIBMNL_VERSION)-$(LIBMNL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMNL_MAINTAINER)" >>$@
	@echo "Source: $(LIBMNL_SITE)/$(LIBMNL_SOURCE)" >>$@
	@echo "Description: $(LIBMNL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMNL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMNL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMNL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMNL_IPK_DIR)/opt/sbin or $(LIBMNL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMNL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMNL_IPK_DIR)/opt/etc/libmnl/...
# Documentation files should be installed in $(LIBMNL_IPK_DIR)/opt/doc/libmnl/...
# Daemon startup scripts should be installed in $(LIBMNL_IPK_DIR)/opt/etc/init.d/S??libmnl
#
# You may need to patch your application to make it use these locations.
#
$(LIBMNL_IPK): $(LIBMNL_BUILD_DIR)/.built
	rm -rf $(LIBMNL_IPK_DIR) $(BUILD_DIR)/libmnl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMNL_BUILD_DIR) DESTDIR=$(LIBMNL_IPK_DIR) install-strip
	rm -rf $(LIBMNL_IPK_DIR)/opt/include
#	install -d $(LIBMNL_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBMNL_SOURCE_DIR)/libmnl.conf $(LIBMNL_IPK_DIR)/opt/etc/libmnl.conf
#	install -d $(LIBMNL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBMNL_SOURCE_DIR)/rc.libmnl $(LIBMNL_IPK_DIR)/opt/etc/init.d/SXXlibmnl
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMNL_IPK_DIR)/opt/etc/init.d/SXXlibmnl
	$(MAKE) $(LIBMNL_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBMNL_SOURCE_DIR)/postinst $(LIBMNL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMNL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBMNL_SOURCE_DIR)/prerm $(LIBMNL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMNL_IPK_DIR)/CONTROL/prerm
#	echo $(LIBMNL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMNL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMNL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmnl-ipk: $(LIBMNL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmnl-clean:
	rm -f $(LIBMNL_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMNL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmnl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMNL_DIR) $(LIBMNL_BUILD_DIR) $(LIBMNL_IPK_DIR) $(LIBMNL_IPK)
#
#
# Some sanity check for the package.
#
libmnl-check: $(LIBMNL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBMNL_IPK)
