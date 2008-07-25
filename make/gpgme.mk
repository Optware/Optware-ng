###########################################################
#
# gpgme
#
###########################################################
#
# GPGME_VERSION, GPGME_SITE and GPGME_SOURCE define
# the upstream location of the source code for the package.
# GPGME_DIR is the directory which is created when the source
# archive is unpacked.
# GPGME_UNZIP is the command used to unzip the source.
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
GPGME_SITE=ftp://ftp.gnupg.org/gcrypt/gpgme
GPGME_VERSION=1.1.4
GPGME_SOURCE=gpgme-$(GPGME_VERSION).tar.bz2
GPGME_DIR=gpgme-$(GPGME_VERSION)
GPGME_UNZIP=bzcat
GPGME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GPGME_DESCRIPTION=GnuPG Made Easy.
GPGME_SECTION=misc
GPGME_PRIORITY=optional
GPGME_DEPENDS=gnupg, libpth
GPGME_SUGGESTS=
GPGME_CONFLICTS=

#
# GPGME_IPK_VERSION should be incremented when the ipk changes.
#
GPGME_IPK_VERSION=1

#
# GPGME_CONFFILES should be a list of user-editable files
#GPGME_CONFFILES=/opt/etc/gpgme.conf /opt/etc/init.d/SXXgpgme

#
# GPGME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GPGME_PATCHES=$(GPGME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GPGME_CPPFLAGS=
GPGME_LDFLAGS=

#
# GPGME_BUILD_DIR is the directory in which the build is done.
# GPGME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GPGME_IPK_DIR is the directory in which the ipk is built.
# GPGME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GPGME_BUILD_DIR=$(BUILD_DIR)/gpgme
GPGME_SOURCE_DIR=$(SOURCE_DIR)/gpgme
GPGME_IPK_DIR=$(BUILD_DIR)/gpgme-$(GPGME_VERSION)-ipk
GPGME_IPK=$(BUILD_DIR)/gpgme_$(GPGME_VERSION)-$(GPGME_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gpgme-source gpgme-unpack gpgme gpgme-stage gpgme-ipk gpgme-clean gpgme-dirclean gpgme-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GPGME_SOURCE):
	$(WGET) -P $(@D) $(GPGME_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gpgme-source: $(DL_DIR)/$(GPGME_SOURCE) $(GPGME_PATCHES)

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
$(GPGME_BUILD_DIR)/.configured: $(DL_DIR)/$(GPGME_SOURCE) $(GPGME_PATCHES) make/gpgme.mk
	$(MAKE) libgpg-error-stage libpth-stage
	rm -rf $(BUILD_DIR)/$(GPGME_DIR) $(@D)
	$(GPGME_UNZIP) $(DL_DIR)/$(GPGME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GPGME_PATCHES)" ; \
		then cat $(GPGME_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GPGME_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GPGME_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GPGME_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GPGME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GPGME_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-gpg-error-prefix=$(STAGING_PREFIX) \
		--with-gpg=/opt/bin/gpg \
		--with-gpgsm=/opt/bin/gpgsm \
		--with-pth=$(STAGING_PREFIX) \
		--without-pth-test \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gpgme-unpack: $(GPGME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GPGME_BUILD_DIR)/.built: $(GPGME_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gpgme: $(GPGME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GPGME_BUILD_DIR)/.staged: $(GPGME_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgpgme*.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/gpgme-config
	touch $@

gpgme-stage: $(GPGME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gpgme
#
$(GPGME_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gpgme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GPGME_PRIORITY)" >>$@
	@echo "Section: $(GPGME_SECTION)" >>$@
	@echo "Version: $(GPGME_VERSION)-$(GPGME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GPGME_MAINTAINER)" >>$@
	@echo "Source: $(GPGME_SITE)/$(GPGME_SOURCE)" >>$@
	@echo "Description: $(GPGME_DESCRIPTION)" >>$@
	@echo "Depends: $(GPGME_DEPENDS)" >>$@
	@echo "Suggests: $(GPGME_SUGGESTS)" >>$@
	@echo "Conflicts: $(GPGME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GPGME_IPK_DIR)/opt/sbin or $(GPGME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GPGME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GPGME_IPK_DIR)/opt/etc/gpgme/...
# Documentation files should be installed in $(GPGME_IPK_DIR)/opt/doc/gpgme/...
# Daemon startup scripts should be installed in $(GPGME_IPK_DIR)/opt/etc/init.d/S??gpgme
#
# You may need to patch your application to make it use these locations.
#
$(GPGME_IPK): $(GPGME_BUILD_DIR)/.built
	rm -rf $(GPGME_IPK_DIR) $(BUILD_DIR)/gpgme_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GPGME_BUILD_DIR) DESTDIR=$(GPGME_IPK_DIR) install-strip
#	install -d $(GPGME_IPK_DIR)/opt/etc/
#	install -m 644 $(GPGME_SOURCE_DIR)/gpgme.conf $(GPGME_IPK_DIR)/opt/etc/gpgme.conf
#	install -d $(GPGME_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GPGME_SOURCE_DIR)/rc.gpgme $(GPGME_IPK_DIR)/opt/etc/init.d/SXXgpgme
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GPGME_IPK_DIR)/opt/etc/init.d/SXXgpgme
	$(MAKE) $(GPGME_IPK_DIR)/CONTROL/control
#	install -m 755 $(GPGME_SOURCE_DIR)/postinst $(GPGME_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GPGME_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GPGME_SOURCE_DIR)/prerm $(GPGME_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GPGME_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GPGME_IPK_DIR)/CONTROL/postinst $(GPGME_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GPGME_CONFFILES) | sed -e 's/ /\n/g' > $(GPGME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GPGME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gpgme-ipk: $(GPGME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gpgme-clean:
	rm -f $(GPGME_BUILD_DIR)/.built
	-$(MAKE) -C $(GPGME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gpgme-dirclean:
	rm -rf $(BUILD_DIR)/$(GPGME_DIR) $(GPGME_BUILD_DIR) $(GPGME_IPK_DIR) $(GPGME_IPK)
#
#
# Some sanity check for the package.
#
gpgme-check: $(GPGME_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GPGME_IPK)
