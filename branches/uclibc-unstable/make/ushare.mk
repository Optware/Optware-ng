###########################################################
#
# ushare
#
###########################################################

USHARE_SITE=http://ushare.geexbox.org/releases
USHARE_VERSION=0.9.8
USHARE_SOURCE=ushare-$(USHARE_VERSION).tar.bz2
USHARE_DIR=ushare-$(USHARE_VERSION)
USHARE_UNZIP=bzcat
USHARE_MAINTAINER=Peter Enzerink <nslu2-ushare@enzerink.net>
USHARE_DESCRIPTION= A free UPnP A/V Media Server for Linux.
USHARE_SECTION=net
USHARE_PRIORITY=optional
USHARE_DEPENDS=libupnp
USHARE_SUGGESTS=
USHARE_CONFLICTS=

#
# USHARE_IPK_VERSION should be incremented when the ipk changes.
#
USHARE_IPK_VERSION=2

#
# USHARE_CONFFILES should be a list of user-editable files
USHARE_CONFFILES=/opt/etc/ushare.conf

#
# USHARE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
USHARE_PATCHES=$(USHARE_SOURCE_DIR)/ushare.conf.patch $(USHARE_SOURCE_DIR)/cfgparser.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
USHARE_CPPFLAGS=
USHARE_LDFLAGS=

#
# USHARE_BUILD_DIR is the directory in which the build is done.
# USHARE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# USHARE_IPK_DIR is the directory in which the ipk is built.
# USHARE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
USHARE_BUILD_DIR=$(BUILD_DIR)/ushare
USHARE_SOURCE_DIR=$(SOURCE_DIR)/ushare
USHARE_IPK_DIR=$(BUILD_DIR)/ushare-$(USHARE_VERSION)-ipk
USHARE_IPK=$(BUILD_DIR)/ushare_$(USHARE_VERSION)-$(USHARE_IPK_VERSION)_$(TARGET_ARCH).ipk


.PHONY: ushare-source ushare-unpack ushare ushare-stage ushare-ipk ushare-clean ushare-dirclean ushare-check


#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(USHARE_SOURCE):
	$(WGET) -P $(DL_DIR) $(USHARE_SITE)/$(USHARE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ushare-source: $(DL_DIR)/$(USHARE_SOURCE) $(USHARE_PATCHES)

# Note forced define of autoconf variables prior to configure.
# For explanation see:
# http://wiki.buici.com/wiki/Autoconf_and_RPL_MALLOC

$(USHARE_BUILD_DIR)/.configured: $(DL_DIR)/$(USHARE_SOURCE) $(USHARE_PATCHES) make/ushare.mk
	$(MAKE) libupnp-stage
	rm -rf $(BUILD_DIR)/$(USHARE_DIR) $(USHARE_BUILD_DIR)
	$(USHARE_UNZIP) $(DL_DIR)/$(USHARE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(USHARE_PATCHES)" ; \
		then cat $(USHARE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(USHARE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(USHARE_DIR)" != "$(USHARE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(USHARE_DIR) $(USHARE_BUILD_DIR) ; \
	fi
	(cd $(USHARE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(USHARE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(USHARE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(USHARE_BUILD_DIR)/libtool
	touch $(USHARE_BUILD_DIR)/.configured

ushare-unpack: $(USHARE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(USHARE_BUILD_DIR)/.built: $(USHARE_BUILD_DIR)/.configured
	rm -f $(USHARE_BUILD_DIR)/.built
	$(MAKE) -C $(USHARE_BUILD_DIR)
	touch $(USHARE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ushare: $(USHARE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(USHARE_BUILD_DIR)/.staged: $(USHARE_BUILD_DIR)/.built
	rm -f $(USHARE_BUILD_DIR)/.staged
	$(MAKE) -C $(USHARE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(USHARE_BUILD_DIR)/.staged

ushare-stage: $(USHARE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ushare
#
$(USHARE_IPK_DIR)/CONTROL/control:
	@install -d $(USHARE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ushare" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(USHARE_PRIORITY)" >>$@
	@echo "Section: $(USHARE_SECTION)" >>$@
	@echo "Version: $(USHARE_VERSION)-$(USHARE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(USHARE_MAINTAINER)" >>$@
	@echo "Source: $(USHARE_SITE)/$(USHARE_SOURCE)" >>$@
	@echo "Description: $(USHARE_DESCRIPTION)" >>$@
	@echo "Depends: $(USHARE_DEPENDS)" >>$@
	@echo "Suggests: $(USHARE_SUGGESTS)" >>$@
	@echo "Conflicts: $(USHARE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(USHARE_IPK_DIR)/opt/sbin or $(USHARE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(USHARE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(USHARE_IPK_DIR)/opt/etc/ushare/...
# Documentation files should be installed in $(USHARE_IPK_DIR)/opt/doc/ushare/...
# Daemon startup scripts should be installed in $(USHARE_IPK_DIR)/opt/etc/init.d/S??ushare
#
# You may need to patch your application to make it use these locations.
#
$(USHARE_IPK): $(USHARE_BUILD_DIR)/.built
	rm -rf $(USHARE_IPK_DIR) $(BUILD_DIR)/ushare_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(USHARE_BUILD_DIR) DESTDIR=$(USHARE_IPK_DIR) install-strip
	install -d $(USHARE_IPK_DIR)/opt/etc/
	install -m 644 $(USHARE_BUILD_DIR)/scripts/ushare.conf $(USHARE_IPK_DIR)/opt/etc/ushare.conf
	install -d $(USHARE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(USHARE_SOURCE_DIR)/ushare $(USHARE_IPK_DIR)/opt/etc/init.d/S99ushare
	$(MAKE) $(USHARE_IPK_DIR)/CONTROL/control
	install -m 755 $(USHARE_SOURCE_DIR)/postinst $(USHARE_IPK_DIR)/CONTROL/postinst
	install -m 755 $(USHARE_SOURCE_DIR)/prerm $(USHARE_IPK_DIR)/CONTROL/prerm
	echo $(USHARE_CONFFILES) | sed -e 's/ /\n/g' > $(USHARE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(USHARE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ushare-ipk: $(USHARE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ushare-clean:
	rm -f $(USHARE_BUILD_DIR)/.built
	-$(MAKE) -C $(USHARE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ushare-dirclean:
	rm -rf $(BUILD_DIR)/$(USHARE_DIR) $(USHARE_BUILD_DIR) $(USHARE_IPK_DIR) $(USHARE_IPK)
#
#
# Some sanity check for the package.
#
ushare-check: $(USHARE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(USHARE_IPK)
