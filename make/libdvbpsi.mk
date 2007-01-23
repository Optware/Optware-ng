###########################################################
#
# libdvbpsi
#
###########################################################
#
# LIBDVBPSI_VERSION, LIBDVBPSI_SITE and LIBDVBPSI_SOURCE define
# the upstream location of the source code for the package.
# LIBDVBPSI_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDVBPSI_UNZIP is the command used to unzip the source.
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
LIBDVBPSI_SITE=http://download.videolan.org/pub/libdvbpsi/0.1.5
LIBDVBPSI_VERSION=0.1.5
LIBDVBPSI_SOURCE=libdvbpsi4-$(LIBDVBPSI_VERSION).tar.bz2
LIBDVBPSI_DIR=libdvbpsi4-$(LIBDVBPSI_VERSION)
LIBDVBPSI_UNZIP=bzcat
LIBDVBPSI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDVBPSI_DESCRIPTION=A simple library designed for decoding and generation of MPEG TS and DVB PSI tables.
LIBDVBPSI_SECTION=video
LIBDVBPSI_PRIORITY=optional
LIBDVBPSI_DEPENDS=
LIBDVBPSI_SUGGESTS=
LIBDVBPSI_CONFLICTS=

#
# LIBDVBPSI_IPK_VERSION should be incremented when the ipk changes.
#
LIBDVBPSI_IPK_VERSION=1

#
# LIBDVBPSI_CONFFILES should be a list of user-editable files
#LIBDVBPSI_CONFFILES=/opt/etc/libdvbpsi.conf /opt/etc/init.d/SXXlibdvbpsi

#
# LIBDVBPSI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDVBPSI_PATCHES=$(LIBDVBPSI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDVBPSI_CPPFLAGS=
LIBDVBPSI_LDFLAGS=

#
# LIBDVBPSI_BUILD_DIR is the directory in which the build is done.
# LIBDVBPSI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDVBPSI_IPK_DIR is the directory in which the ipk is built.
# LIBDVBPSI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDVBPSI_BUILD_DIR=$(BUILD_DIR)/libdvbpsi
LIBDVBPSI_SOURCE_DIR=$(SOURCE_DIR)/libdvbpsi
LIBDVBPSI_IPK_DIR=$(BUILD_DIR)/libdvbpsi-$(LIBDVBPSI_VERSION)-ipk
LIBDVBPSI_IPK=$(BUILD_DIR)/libdvbpsi_$(LIBDVBPSI_VERSION)-$(LIBDVBPSI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdvbpsi-source libdvbpsi-unpack libdvbpsi libdvbpsi-stage libdvbpsi-ipk libdvbpsi-clean libdvbpsi-dirclean libdvbpsi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDVBPSI_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDVBPSI_SITE)/$(LIBDVBPSI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdvbpsi-source: $(DL_DIR)/$(LIBDVBPSI_SOURCE) $(LIBDVBPSI_PATCHES)

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
$(LIBDVBPSI_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDVBPSI_SOURCE) $(LIBDVBPSI_PATCHES) make/libdvbpsi.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDVBPSI_DIR) $(LIBDVBPSI_BUILD_DIR)
	$(LIBDVBPSI_UNZIP) $(DL_DIR)/$(LIBDVBPSI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDVBPSI_PATCHES)" ; \
		then cat $(LIBDVBPSI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBDVBPSI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDVBPSI_DIR)" != "$(LIBDVBPSI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBDVBPSI_DIR) $(LIBDVBPSI_BUILD_DIR) ; \
	fi
	(cd $(LIBDVBPSI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDVBPSI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDVBPSI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBDVBPSI_BUILD_DIR)/libtool
	touch $@

libdvbpsi-unpack: $(LIBDVBPSI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDVBPSI_BUILD_DIR)/.built: $(LIBDVBPSI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBDVBPSI_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libdvbpsi: $(LIBDVBPSI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDVBPSI_BUILD_DIR)/.staged: $(LIBDVBPSI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBDVBPSI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libdvbpsi-stage: $(LIBDVBPSI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdvbpsi
#
$(LIBDVBPSI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdvbpsi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDVBPSI_PRIORITY)" >>$@
	@echo "Section: $(LIBDVBPSI_SECTION)" >>$@
	@echo "Version: $(LIBDVBPSI_VERSION)-$(LIBDVBPSI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDVBPSI_MAINTAINER)" >>$@
	@echo "Source: $(LIBDVBPSI_SITE)/$(LIBDVBPSI_SOURCE)" >>$@
	@echo "Description: $(LIBDVBPSI_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDVBPSI_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDVBPSI_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDVBPSI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDVBPSI_IPK_DIR)/opt/sbin or $(LIBDVBPSI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDVBPSI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDVBPSI_IPK_DIR)/opt/etc/libdvbpsi/...
# Documentation files should be installed in $(LIBDVBPSI_IPK_DIR)/opt/doc/libdvbpsi/...
# Daemon startup scripts should be installed in $(LIBDVBPSI_IPK_DIR)/opt/etc/init.d/S??libdvbpsi
#
# You may need to patch your application to make it use these locations.
#
$(LIBDVBPSI_IPK): $(LIBDVBPSI_BUILD_DIR)/.built
	rm -rf $(LIBDVBPSI_IPK_DIR) $(BUILD_DIR)/libdvbpsi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDVBPSI_BUILD_DIR) DESTDIR=$(LIBDVBPSI_IPK_DIR) install-strip
#	install -d $(LIBDVBPSI_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBDVBPSI_SOURCE_DIR)/libdvbpsi.conf $(LIBDVBPSI_IPK_DIR)/opt/etc/libdvbpsi.conf
#	install -d $(LIBDVBPSI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBDVBPSI_SOURCE_DIR)/rc.libdvbpsi $(LIBDVBPSI_IPK_DIR)/opt/etc/init.d/SXXlibdvbpsi
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXlibdvbpsi
	$(MAKE) $(LIBDVBPSI_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBDVBPSI_SOURCE_DIR)/postinst $(LIBDVBPSI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBDVBPSI_SOURCE_DIR)/prerm $(LIBDVBPSI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(LIBDVBPSI_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDVBPSI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDVBPSI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdvbpsi-ipk: $(LIBDVBPSI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdvbpsi-clean:
	rm -f $(LIBDVBPSI_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDVBPSI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdvbpsi-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDVBPSI_DIR) $(LIBDVBPSI_BUILD_DIR) $(LIBDVBPSI_IPK_DIR) $(LIBDVBPSI_IPK)
#
#
# Some sanity check for the package.
#
libdvbpsi-check: $(LIBDVBPSI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBDVBPSI_IPK)
