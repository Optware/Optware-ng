###########################################################
#
# libassuan
#
###########################################################
#
# LIBASSUAN_VERSION, LIBASSUAN_SITE and LIBASSUAN_SOURCE define
# the upstream location of the source code for the package.
# LIBASSUAN_DIR is the directory which is created when the source
# archive is unpacked.
# LIBASSUAN_UNZIP is the command used to unzip the source.
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
LIBASSUAN_SITE=ftp://ftp.gnupg.org/gcrypt/libassuan
LIBASSUAN_VERSION=1.0.5
LIBASSUAN_SOURCE=libassuan-$(LIBASSUAN_VERSION).tar.bz2
LIBASSUAN_DIR=libassuan-$(LIBASSUAN_VERSION)
LIBASSUAN_UNZIP=bzcat
LIBASSUAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBASSUAN_DESCRIPTION=Libassuan is the IPC library used by some GnuPG related software.
LIBASSUAN_SECTION=lib
LIBASSUAN_PRIORITY=optional
LIBASSUAN_DEPENDS=
LIBASSUAN_SUGGESTS=
LIBASSUAN_CONFLICTS=

#
# LIBASSUAN_IPK_VERSION should be incremented when the ipk changes.
#
LIBASSUAN_IPK_VERSION=1

#
# LIBASSUAN_CONFFILES should be a list of user-editable files
#LIBASSUAN_CONFFILES=/opt/etc/libassuan.conf /opt/etc/init.d/SXXlibassuan

#
# LIBASSUAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBASSUAN_PATCHES=$(LIBASSUAN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBASSUAN_CPPFLAGS=
LIBASSUAN_LDFLAGS=

#
# LIBASSUAN_BUILD_DIR is the directory in which the build is done.
# LIBASSUAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBASSUAN_IPK_DIR is the directory in which the ipk is built.
# LIBASSUAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBASSUAN_BUILD_DIR=$(BUILD_DIR)/libassuan
LIBASSUAN_SOURCE_DIR=$(SOURCE_DIR)/libassuan
LIBASSUAN_IPK_DIR=$(BUILD_DIR)/libassuan-$(LIBASSUAN_VERSION)-ipk
LIBASSUAN_IPK=$(BUILD_DIR)/libassuan_$(LIBASSUAN_VERSION)-$(LIBASSUAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libassuan-source libassuan-unpack libassuan libassuan-stage libassuan-ipk libassuan-clean libassuan-dirclean libassuan-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBASSUAN_SOURCE):
	$(WGET) -P $(@D) $(LIBASSUAN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libassuan-source: $(DL_DIR)/$(LIBASSUAN_SOURCE) $(LIBASSUAN_PATCHES)

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
$(LIBASSUAN_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBASSUAN_SOURCE) $(LIBASSUAN_PATCHES) make/libassuan.mk
	$(MAKE) libpth-stage
	rm -rf $(BUILD_DIR)/$(LIBASSUAN_DIR) $(@D)
	$(LIBASSUAN_UNZIP) $(DL_DIR)/$(LIBASSUAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBASSUAN_PATCHES)" ; \
		then cat $(LIBASSUAN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBASSUAN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBASSUAN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBASSUAN_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBASSUAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBASSUAN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-pth-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libassuan-unpack: $(LIBASSUAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBASSUAN_BUILD_DIR)/.built: $(LIBASSUAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libassuan: $(LIBASSUAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBASSUAN_BUILD_DIR)/.staged: $(LIBASSUAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|g' $(STAGING_PREFIX)/bin/libassuan-config
	touch $@

libassuan-stage: $(LIBASSUAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libassuan
#
$(LIBASSUAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libassuan" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBASSUAN_PRIORITY)" >>$@
	@echo "Section: $(LIBASSUAN_SECTION)" >>$@
	@echo "Version: $(LIBASSUAN_VERSION)-$(LIBASSUAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBASSUAN_MAINTAINER)" >>$@
	@echo "Source: $(LIBASSUAN_SITE)/$(LIBASSUAN_SOURCE)" >>$@
	@echo "Description: $(LIBASSUAN_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBASSUAN_DEPENDS)" >>$@
	@echo "Suggests: $(LIBASSUAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBASSUAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBASSUAN_IPK_DIR)/opt/sbin or $(LIBASSUAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBASSUAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBASSUAN_IPK_DIR)/opt/etc/libassuan/...
# Documentation files should be installed in $(LIBASSUAN_IPK_DIR)/opt/doc/libassuan/...
# Daemon startup scripts should be installed in $(LIBASSUAN_IPK_DIR)/opt/etc/init.d/S??libassuan
#
# You may need to patch your application to make it use these locations.
#
$(LIBASSUAN_IPK): $(LIBASSUAN_BUILD_DIR)/.built
	rm -rf $(LIBASSUAN_IPK_DIR) $(BUILD_DIR)/libassuan_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBASSUAN_BUILD_DIR) DESTDIR=$(LIBASSUAN_IPK_DIR) install-strip
#	install -d $(LIBASSUAN_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBASSUAN_SOURCE_DIR)/libassuan.conf $(LIBASSUAN_IPK_DIR)/opt/etc/libassuan.conf
#	install -d $(LIBASSUAN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBASSUAN_SOURCE_DIR)/rc.libassuan $(LIBASSUAN_IPK_DIR)/opt/etc/init.d/SXXlibassuan
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASSUAN_IPK_DIR)/opt/etc/init.d/SXXlibassuan
	$(MAKE) $(LIBASSUAN_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBASSUAN_SOURCE_DIR)/postinst $(LIBASSUAN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASSUAN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBASSUAN_SOURCE_DIR)/prerm $(LIBASSUAN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBASSUAN_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBASSUAN_IPK_DIR)/CONTROL/postinst $(LIBASSUAN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBASSUAN_CONFFILES) | sed -e 's/ /\n/g' > $(LIBASSUAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBASSUAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libassuan-ipk: $(LIBASSUAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libassuan-clean:
	rm -f $(LIBASSUAN_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBASSUAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libassuan-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBASSUAN_DIR) $(LIBASSUAN_BUILD_DIR) $(LIBASSUAN_IPK_DIR) $(LIBASSUAN_IPK)
#
#
# Some sanity check for the package.
#
libassuan-check: $(LIBASSUAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBASSUAN_IPK)
