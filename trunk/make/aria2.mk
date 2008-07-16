###########################################################
#
# aria2
#
###########################################################
#
# ARIA2_VERSION, ARIA2_SITE and ARIA2_SOURCE define
# the upstream location of the source code for the package.
# ARIA2_DIR is the directory which is created when the source
# archive is unpacked.
# ARIA2_UNZIP is the command used to unzip the source.
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
ARIA2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/aria2
ARIA2_VERSION=0.14.0+1
ARIA2_SOURCE=aria2c-$(ARIA2_VERSION).tar.bz2
ARIA2_DIR=aria2c-$(ARIA2_VERSION)
ARIA2_UNZIP=bzcat
ARIA2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ARIA2_DESCRIPTION=A utility for downloading files. The supported protocols are HTTP(S), FTP, BitTorrent  (DHT, PEX, MSE/PE), and Metalink.
ARIA2_SECTION=net
ARIA2_PRIORITY=optional
ARIA2_DEPENDS=c-ares, libstdc++, libxml2, openssl
ifneq (, $(filter libiconv, $(PACKAGES)))
ARIA2_DEPENDS += , libiconv
endif
ARIA2_SUGGESTS=
ARIA2_CONFLICTS=

#
# ARIA2_IPK_VERSION should be incremented when the ipk changes.
#
ARIA2_IPK_VERSION=2

#
# ARIA2_CONFFILES should be a list of user-editable files
#ARIA2_CONFFILES=/opt/etc/aria2.conf /opt/etc/init.d/SXXaria2

#
# ARIA2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ARIA2_PATCHES=$(ARIA2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ARIA2_CPPFLAGS=
ARIA2_LDFLAGS=

ifeq ($(HOSTCC), $(TARGET_CC))
ARIA2_CONFIGURE_ENVS=
else
ARIA2_CONFIGURE_ENVS=ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
endif

ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
ARIA2_CONFIGURE_ENVS += CXX=$(TARGET_GXX)
endif
endif

#
# ARIA2_BUILD_DIR is the directory in which the build is done.
# ARIA2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ARIA2_IPK_DIR is the directory in which the ipk is built.
# ARIA2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ARIA2_BUILD_DIR=$(BUILD_DIR)/aria2
ARIA2_SOURCE_DIR=$(SOURCE_DIR)/aria2
ARIA2_IPK_DIR=$(BUILD_DIR)/aria2-$(ARIA2_VERSION)-ipk
ARIA2_IPK=$(BUILD_DIR)/aria2_$(ARIA2_VERSION)-$(ARIA2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: aria2-source aria2-unpack aria2 aria2-stage aria2-ipk aria2-clean aria2-dirclean aria2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ARIA2_SOURCE):
	$(WGET) -P $(@D) $(ARIA2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
aria2-source: $(DL_DIR)/$(ARIA2_SOURCE) $(ARIA2_PATCHES)

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
$(ARIA2_BUILD_DIR)/.configured: $(DL_DIR)/$(ARIA2_SOURCE) $(ARIA2_PATCHES) make/aria2.mk
	$(MAKE) c-ares-stage libstdc++-stage libxml2-stage openssl-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(ARIA2_DIR) $(@D)
	$(ARIA2_UNZIP) $(DL_DIR)/$(ARIA2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ARIA2_PATCHES)" ; \
		then cat $(ARIA2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ARIA2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ARIA2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ARIA2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		$(ARIA2_CONFIGURE_ENVS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ARIA2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ARIA2_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-gnutls \
		--without-expat \
		--with-openssl \
		--with-openssl-prefix=$(STAGING_PREFIX) \
		--with-libxml2 \
		--with-libxml2-prefix=$(STAGING_PREFIX) \
		--with-libcares \
		--with-libcares-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

aria2-unpack: $(ARIA2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ARIA2_BUILD_DIR)/.built: $(ARIA2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
aria2: $(ARIA2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ARIA2_BUILD_DIR)/.staged: $(ARIA2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

aria2-stage: $(ARIA2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/aria2
#
$(ARIA2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: aria2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ARIA2_PRIORITY)" >>$@
	@echo "Section: $(ARIA2_SECTION)" >>$@
	@echo "Version: $(ARIA2_VERSION)-$(ARIA2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ARIA2_MAINTAINER)" >>$@
	@echo "Source: $(ARIA2_SITE)/$(ARIA2_SOURCE)" >>$@
	@echo "Description: $(ARIA2_DESCRIPTION)" >>$@
	@echo "Depends: $(ARIA2_DEPENDS)" >>$@
	@echo "Suggests: $(ARIA2_SUGGESTS)" >>$@
	@echo "Conflicts: $(ARIA2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ARIA2_IPK_DIR)/opt/sbin or $(ARIA2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ARIA2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ARIA2_IPK_DIR)/opt/etc/aria2/...
# Documentation files should be installed in $(ARIA2_IPK_DIR)/opt/doc/aria2/...
# Daemon startup scripts should be installed in $(ARIA2_IPK_DIR)/opt/etc/init.d/S??aria2
#
# You may need to patch your application to make it use these locations.
#
$(ARIA2_IPK): $(ARIA2_BUILD_DIR)/.built
	rm -rf $(ARIA2_IPK_DIR) $(BUILD_DIR)/aria2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ARIA2_BUILD_DIR) DESTDIR=$(ARIA2_IPK_DIR) transform='' install-strip
#	install -d $(ARIA2_IPK_DIR)/opt/etc/
#	install -m 644 $(ARIA2_SOURCE_DIR)/aria2.conf $(ARIA2_IPK_DIR)/opt/etc/aria2.conf
#	install -d $(ARIA2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ARIA2_SOURCE_DIR)/rc.aria2 $(ARIA2_IPK_DIR)/opt/etc/init.d/SXXaria2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ARIA2_IPK_DIR)/opt/etc/init.d/SXXaria2
	$(MAKE) $(ARIA2_IPK_DIR)/CONTROL/control
#	install -m 755 $(ARIA2_SOURCE_DIR)/postinst $(ARIA2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ARIA2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ARIA2_SOURCE_DIR)/prerm $(ARIA2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ARIA2_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ARIA2_IPK_DIR)/CONTROL/postinst $(ARIA2_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ARIA2_CONFFILES) | sed -e 's/ /\n/g' > $(ARIA2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ARIA2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
aria2-ipk: $(ARIA2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
aria2-clean:
	rm -f $(ARIA2_BUILD_DIR)/.built
	-$(MAKE) -C $(ARIA2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
aria2-dirclean:
	rm -rf $(BUILD_DIR)/$(ARIA2_DIR) $(ARIA2_BUILD_DIR) $(ARIA2_IPK_DIR) $(ARIA2_IPK)
#
#
# Some sanity check for the package.
#
aria2-check: $(ARIA2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ARIA2_IPK)
