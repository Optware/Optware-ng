###########################################################
#
# libksba
#
###########################################################
#
# LIBKSBA_VERSION, LIBKSBA_SITE and LIBKSBA_SOURCE define
# the upstream location of the source code for the package.
# LIBKSBA_DIR is the directory which is created when the source
# archive is unpacked.
# LIBKSBA_UNZIP is the command used to unzip the source.
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
LIBKSBA_SITE=ftp://ftp.gnupg.org/gcrypt/libksba
LIBKSBA_VERSION=1.0.3
LIBKSBA_SOURCE=libksba-$(LIBKSBA_VERSION).tar.bz2
LIBKSBA_DIR=libksba-$(LIBKSBA_VERSION)
LIBKSBA_UNZIP=bzcat
LIBKSBA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBKSBA_DESCRIPTION=Libksba is a CMS and X.509 access library.
LIBKSBA_SECTION=lib
LIBKSBA_PRIORITY=optional
LIBKSBA_DEPENDS=libgpg-error
LIBKSBA_SUGGESTS=
LIBKSBA_CONFLICTS=

#
# LIBKSBA_IPK_VERSION should be incremented when the ipk changes.
#
LIBKSBA_IPK_VERSION=1

#
# LIBKSBA_CONFFILES should be a list of user-editable files
#LIBKSBA_CONFFILES=/opt/etc/libksba.conf /opt/etc/init.d/SXXlibksba

#
# LIBKSBA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBKSBA_PATCHES=$(LIBKSBA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBKSBA_CPPFLAGS=
LIBKSBA_LDFLAGS=

#
# LIBKSBA_BUILD_DIR is the directory in which the build is done.
# LIBKSBA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBKSBA_IPK_DIR is the directory in which the ipk is built.
# LIBKSBA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBKSBA_BUILD_DIR=$(BUILD_DIR)/libksba
LIBKSBA_SOURCE_DIR=$(SOURCE_DIR)/libksba
LIBKSBA_IPK_DIR=$(BUILD_DIR)/libksba-$(LIBKSBA_VERSION)-ipk
LIBKSBA_IPK=$(BUILD_DIR)/libksba_$(LIBKSBA_VERSION)-$(LIBKSBA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libksba-source libksba-unpack libksba libksba-stage libksba-ipk libksba-clean libksba-dirclean libksba-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBKSBA_SOURCE):
	$(WGET) -P $(@D) $(LIBKSBA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libksba-source: $(DL_DIR)/$(LIBKSBA_SOURCE) $(LIBKSBA_PATCHES)

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
$(LIBKSBA_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBKSBA_SOURCE) $(LIBKSBA_PATCHES) make/libksba.mk
	$(MAKE) libgpg-error-stage
	rm -rf $(BUILD_DIR)/$(LIBKSBA_DIR) $(@D)
	$(LIBKSBA_UNZIP) $(DL_DIR)/$(LIBKSBA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBKSBA_PATCHES)" ; \
		then cat $(LIBKSBA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBKSBA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBKSBA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBKSBA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBKSBA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBKSBA_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-gpg-error-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libksba-unpack: $(LIBKSBA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBKSBA_BUILD_DIR)/.built: $(LIBKSBA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libksba: $(LIBKSBA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBKSBA_BUILD_DIR)/.staged: $(LIBKSBA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libksba.la
	sed -i -e 's|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|g' $(STAGING_PREFIX)/bin/ksba-config
	touch $@

libksba-stage: $(LIBKSBA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libksba
#
$(LIBKSBA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libksba" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBKSBA_PRIORITY)" >>$@
	@echo "Section: $(LIBKSBA_SECTION)" >>$@
	@echo "Version: $(LIBKSBA_VERSION)-$(LIBKSBA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBKSBA_MAINTAINER)" >>$@
	@echo "Source: $(LIBKSBA_SITE)/$(LIBKSBA_SOURCE)" >>$@
	@echo "Description: $(LIBKSBA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBKSBA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBKSBA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBKSBA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBKSBA_IPK_DIR)/opt/sbin or $(LIBKSBA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBKSBA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBKSBA_IPK_DIR)/opt/etc/libksba/...
# Documentation files should be installed in $(LIBKSBA_IPK_DIR)/opt/doc/libksba/...
# Daemon startup scripts should be installed in $(LIBKSBA_IPK_DIR)/opt/etc/init.d/S??libksba
#
# You may need to patch your application to make it use these locations.
#
$(LIBKSBA_IPK): $(LIBKSBA_BUILD_DIR)/.built
	rm -rf $(LIBKSBA_IPK_DIR) $(BUILD_DIR)/libksba_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBKSBA_BUILD_DIR) DESTDIR=$(LIBKSBA_IPK_DIR) install-strip
#	install -d $(LIBKSBA_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBKSBA_SOURCE_DIR)/libksba.conf $(LIBKSBA_IPK_DIR)/opt/etc/libksba.conf
#	install -d $(LIBKSBA_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBKSBA_SOURCE_DIR)/rc.libksba $(LIBKSBA_IPK_DIR)/opt/etc/init.d/SXXlibksba
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBKSBA_IPK_DIR)/opt/etc/init.d/SXXlibksba
	$(MAKE) $(LIBKSBA_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBKSBA_SOURCE_DIR)/postinst $(LIBKSBA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBKSBA_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBKSBA_SOURCE_DIR)/prerm $(LIBKSBA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBKSBA_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBKSBA_IPK_DIR)/CONTROL/postinst $(LIBKSBA_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBKSBA_CONFFILES) | sed -e 's/ /\n/g' > $(LIBKSBA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBKSBA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libksba-ipk: $(LIBKSBA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libksba-clean:
	rm -f $(LIBKSBA_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBKSBA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libksba-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBKSBA_DIR) $(LIBKSBA_BUILD_DIR) $(LIBKSBA_IPK_DIR) $(LIBKSBA_IPK)
#
#
# Some sanity check for the package.
#
libksba-check: $(LIBKSBA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBKSBA_IPK)
