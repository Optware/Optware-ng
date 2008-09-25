###########################################################
#
# gnutls
#
###########################################################

# You must replace "gnutls" and "GNUTLS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GNUTLS_VERSION, GNUTLS_SITE and GNUTLS_SOURCE define
# the upstream location of the source code for the package.
# GNUTLS_DIR is the directory which is created when the source
# archive is unpacked.
# GNUTLS_UNZIP is the command used to unzip the source.
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
GNUTLS_SITE=http://ftp.gnu.org/pub/gnu/gnutls
GNUTLS_VERSION=2.4.2
GNUTLS_SOURCE=gnutls-$(GNUTLS_VERSION).tar.bz2
GNUTLS_DIR=gnutls-$(GNUTLS_VERSION)
GNUTLS_UNZIP=bzcat
GNUTLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNUTLS_DESCRIPTION=GNU Transport Layer Security Library.
GNUTLS_SECTION=libs
GNUTLS_PRIORITY=optional
GNUTLS_DEPENDS=libtasn1, libgcrypt, libgpg-error, zlib
GNUTLS_SUGGESTS=
GNUTLS_CONFLICTS=

#
# GNUTLS_IPK_VERSION should be incremented when the ipk changes.
#
GNUTLS_IPK_VERSION=2

#
# GNUTLS_CONFFILES should be a list of user-editable files
GNUTLS_CONFFILES=#/opt/etc/gnutls.conf /opt/etc/init.d/SXXgnutls

#
# GNUTLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GNUTLS_PATCHES=$(GNUTLS_SOURCE_DIR)/gnutls.h.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNUTLS_CPPFLAGS=
GNUTLS_LDFLAGS=

#
# GNUTLS_BUILD_DIR is the directory in which the build is done.
# GNUTLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNUTLS_IPK_DIR is the directory in which the ipk is built.
# GNUTLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNUTLS_BUILD_DIR=$(BUILD_DIR)/gnutls
GNUTLS_SOURCE_DIR=$(SOURCE_DIR)/gnutls

GNUTLS_IPK_DIR=$(BUILD_DIR)/gnutls-$(GNUTLS_VERSION)-ipk
GNUTLS_IPK=$(BUILD_DIR)/gnutls_$(GNUTLS_VERSION)-$(GNUTLS_IPK_VERSION)_$(TARGET_ARCH).ipk
GNUTLS-DEV_IPK_DIR=$(BUILD_DIR)/gnutls-dev-$(GNUTLS_VERSION)-ipk
GNUTLS-DEV_IPK=$(BUILD_DIR)/gnutls-dev_$(GNUTLS_VERSION)-$(GNUTLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnutls-source gnutls-unpack gnutls gnutls-stage gnutls-ipk gnutls-clean gnutls-dirclean gnutls-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNUTLS_SOURCE):
	$(WGET) -P $(@D) $(GNUTLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnutls-source: $(DL_DIR)/$(GNUTLS_SOURCE) $(GNUTLS_PATCHES)

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
$(GNUTLS_BUILD_DIR)/.configured: $(DL_DIR)/$(GNUTLS_SOURCE) $(GNUTLS_PATCHES) make/gnutls.mk
	$(MAKE) libgcrypt-stage libtasn1-stage
	rm -rf $(BUILD_DIR)/$(GNUTLS_DIR) $(GNUTLS_BUILD_DIR)
	$(GNUTLS_UNZIP) $(DL_DIR)/$(GNUTLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNUTLS_PATCHES)"; \
		then cat $(GNUTLS_PATCHES) | patch -d $(BUILD_DIR)/$(GNUTLS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(GNUTLS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNUTLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNUTLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libgcrypt-prefix=$(STAGING_DIR)/opt \
		--with-libtasn1-prefix=$(STAGING_DIR)/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gnutls-unpack: $(GNUTLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNUTLS_BUILD_DIR)/.built: $(GNUTLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gnutls: $(GNUTLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNUTLS_BUILD_DIR)/.staged: $(GNUTLS_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_PREFIX)/bin/*gnutls*
	$(MAKE) -C $(@D) install \
		DESTDIR=$(STAGING_DIR) program_transform_name=""
	sed -i -e 's|echo $$includes $$.*_cflags|echo "-I$(STAGING_INCLUDE_DIR)"|' $(STAGING_PREFIX)/bin/*gnutls-config
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gnutls*.pc
	rm -f $(STAGING_LIB_DIR)/libgnutls*.la
	touch $@

gnutls-stage: $(GNUTLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnutls
#
$(GNUTLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnutls" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUTLS_PRIORITY)" >>$@
	@echo "Section: $(GNUTLS_SECTION)" >>$@
	@echo "Version: $(GNUTLS_VERSION)-$(GNUTLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUTLS_MAINTAINER)" >>$@
	@echo "Source: $(GNUTLS_SITE)/$(GNUTLS_SOURCE)" >>$@
	@echo "Description: $(GNUTLS_DESCRIPTION)" >>$@
	@echo "Depends: $(GNUTLS_DEPENDS)" >>$@
	@echo "Suggests: $(GNUTLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNUTLS_CONFLICTS)" >>$@

$(GNUTLS-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnutls-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUTLS_PRIORITY)" >>$@
	@echo "Section: $(GNUTLS_SECTION)" >>$@
	@echo "Version: $(GNUTLS_VERSION)-$(GNUTLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUTLS_MAINTAINER)" >>$@
	@echo "Source: $(GNUTLS_SITE)/$(GNUTLS_SOURCE)" >>$@
	@echo "Description: Development files for GNUTLS" >>$@
	@echo "Depends: gnutls" >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNUTLS_IPK_DIR)/opt/sbin or $(GNUTLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNUTLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNUTLS_IPK_DIR)/opt/etc/gnutls/...
# Documentation files should be installed in $(GNUTLS_IPK_DIR)/opt/doc/gnutls/...
# Daemon startup scripts should be installed in $(GNUTLS_IPK_DIR)/opt/etc/init.d/S??gnutls
#
# You may need to patch your application to make it use these locations.
#
$(GNUTLS_IPK) $(GNUTLS-DEV_IPK): $(GNUTLS_BUILD_DIR)/.built
	rm -rf $(GNUTLS_IPK_DIR) $(BUILD_DIR)/gnutls_*_$(TARGET_ARCH).ipk
	rm -rf $(GNUTLS-DEV_IPK_DIR) $(BUILD_DIR)/gnutls-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNUTLS_BUILD_DIR) DESTDIR=$(GNUTLS_IPK_DIR) program_transform_name="" install-strip
	install -d $(GNUTLS-DEV_IPK_DIR)/opt
	mv $(GNUTLS_IPK_DIR)/opt/include $(GNUTLS-DEV_IPK_DIR)/opt/
	install -d $(GNUTLS-DEV_IPK_DIR)/opt/share/man
	mv $(GNUTLS_IPK_DIR)/opt/share/man/man3 $(GNUTLS-DEV_IPK_DIR)/opt/share/man/
	mv $(GNUTLS_IPK_DIR)/opt/share/info $(GNUTLS-DEV_IPK_DIR)/opt/share/
	mv $(GNUTLS_IPK_DIR)/opt/share/aclocal $(GNUTLS-DEV_IPK_DIR)/opt/share/
	install -d $(GNUTLS-DEV_IPK_DIR)/opt/bin $(GNUTLS-DEV_IPK_DIR)/opt/lib
	mv $(GNUTLS_IPK_DIR)/opt/bin/libgnutls*-config $(GNUTLS-DEV_IPK_DIR)/opt/bin/
	mv $(GNUTLS_IPK_DIR)/opt/lib/pkgconfig $(GNUTLS-DEV_IPK_DIR)/opt/lib/
#	install -m 644 $(GNUTLS_SOURCE_DIR)/gnutls.conf $(GNUTLS_IPK_DIR)/opt/etc/gnutls.conf
#	install -d $(GNUTLS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNUTLS_SOURCE_DIR)/rc.gnutls $(GNUTLS_IPK_DIR)/opt/etc/init.d/SXXgnutls
	$(MAKE) $(GNUTLS_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNUTLS_SOURCE_DIR)/postinst $(GNUTLS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNUTLS_SOURCE_DIR)/prerm $(GNUTLS_IPK_DIR)/CONTROL/prerm
	echo $(GNUTLS_CONFFILES) | sed -e 's/ /\n/g' > $(GNUTLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUTLS_IPK_DIR)
	$(MAKE) $(GNUTLS-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUTLS-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnutls-ipk: $(GNUTLS_IPK) $(GNUTLS-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnutls-clean:
	-$(MAKE) -C $(GNUTLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnutls-dirclean:
	rm -rf $(BUILD_DIR)/$(GNUTLS_DIR) $(GNUTLS_BUILD_DIR)
	rm -rf $(GNUTLS_IPK_DIR) $(GNUTLS_IPK)
	rm -rf $(GNUTLS-DEV_IPK_DIR) $(GNUTLS-DEV_IPK)

#
# Some sanity check for the package.
#
gnutls-check: $(GNUTLS_IPK) $(GNUTLS-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNUTLS_IPK)
