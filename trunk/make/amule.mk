###########################################################
#
# amule
#
###########################################################
#
# AMULE_VERSION, AMULE_SITE and AMULE_SOURCE define
# the upstream location of the source code for the package.
# AMULE_DIR is the directory which is created when the source
# archive is unpacked.
# AMULE_UNZIP is the command used to unzip the source.
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
# http://developer.berlios.de/projects/amule/

#AMULE_SITE=http://download.berlios.de/amule
AMULE_VERSION=2.3.1rc1
#AMULE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/amule
AMULE_SITE=http://$(SOURCEFORGE_MIRROR)/project/amule/aMule/$(AMULE_VERSION)
AMULE_SOURCE=aMule-$(AMULE_VERSION).tar.bz2
AMULE_DIR=aMule-$(AMULE_VERSION)
AMULE_UNZIP=bzcat
AMULE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AMULE_DESCRIPTION=non-gui part of aMule ed2k client (amuled,amulweb,amulecmd) 
AMULE_SECTION=net
AMULE_PRIORITY=optional
AMULE_DEPENDS=libstdc++, wxbase, zlib, libcurl, libpng, libgd, libupnp, readline, ncurses
AMULE_SUGGESTS=
AMULE_CONFLICTS=

#
# AMULE_IPK_VERSION should be incremented when the ipk changes.
#
AMULE_IPK_VERSION=2

#
# AMULE_CONFFILES should be a list of user-editable files
## AMULE_CONFFILES=/opt/etc/amule.conf /opt/etc/init.d/SXXamule

#
# AMULE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
AMULE_PATCHES=#$(AMULE_SOURCE_DIR)/uintptr_t.patch \
#$(AMULE_SOURCE_DIR)/libupnp-cross.patch

ifeq ($(LIBC_STYLE), uclibc)
AMULE_PATCHES+=$(AMULE_SOURCE_DIR)/amule-1gb-uclibc-mipsel.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AMULE_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), ts101)
AMULE_CPPFLAGS+= -fno-builtin-log -fno-builtin-exp
endif
AMULE_LDFLAGS=
AMULE_CONFIGURE_OPTS = ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
AMULE_CONFIGURE_OPTS += CXX=$(TARGET_GXX)
endif
endif

AMULE_CONFIGURE_ARGS = \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-debug \
		--enable-optimize \
		--enable-alcc \
		--enable-amule-daemon \
		--enable-webserver \
		--enable-amulecmd \
		--enable-upnp \
		--disable-monolithic \
		--disable-alc \
		--disable-amulecmdgui \
		--disable-cas \
		--disable-wxcas \
		--disable-systray \
		--with-curl-config=$(STAGING_DIR)/bin/curl-config \
		--with-gdlib-prefix=$(STAGING_PREFIX) \
		--with-libpng-prefix=$(STAGING_PREFIX) \
		--with-libupnp-prefix=$(STAGING_PREFIX) \
		--with-wxbase-config=$(STAGING_DIR)/opt/bin/wx-config \
		--with-wx-config=$(STAGING_DIR)/opt/bin/wx-config \
		--with-wx-prefix=$(STAGING_PREFIX) \
		--with-crypto-prefix=$(STAGING_PREFIX) \
		--with-zlib=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static

#
# AMULE_BUILD_DIR is the directory in which the build is done.
# AMULE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AMULE_IPK_DIR is the directory in which the ipk is built.
# AMULE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AMULE_BUILD_DIR=$(BUILD_DIR)/amule
AMULE_SOURCE_DIR=$(SOURCE_DIR)/amule
AMULE_IPK_DIR=$(BUILD_DIR)/amule-$(AMULE_VERSION)-ipk
AMULE_IPK=$(BUILD_DIR)/amule_$(AMULE_VERSION)-$(AMULE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: amule-source amule-unpack amule amule-stage amule-ipk amule-clean amule-dirclean amule-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AMULE_SOURCE):
	$(WGET) -P $(@D) $(AMULE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
amule-source: $(DL_DIR)/$(AMULE_SOURCE) $(AMULE_PATCHES)

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
#
$(AMULE_BUILD_DIR)/.configured: $(DL_DIR)/$(AMULE_SOURCE) $(AMULE_PATCHES)
	$(MAKE) libstdc++-stage crypto++-stage ncurses-stage
	$(MAKE) wxbase-stage libcurl-stage zlib-stage libpng-stage libgd-stage libupnp-stage readline-stage
	rm -rf $(BUILD_DIR)/$(AMULE_DIR) $(@D)
	$(AMULE_UNZIP) $(DL_DIR)/$(AMULE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AMULE_PATCHES)" ; \
		then cat $(AMULE_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(AMULE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(AMULE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AMULE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AMULE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AMULE_LDFLAGS)" \
		$(AMULE_CONFIGURE_OPTS) \
		./configure \
		$(AMULE_CONFIGURE_ARGS) \
	)
##	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


amule-unpack: $(AMULE_BUILD_DIR)/.configured


#
# This builds the actual binary.
#
$(AMULE_BUILD_DIR)/.built: $(AMULE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) HOSTCC=$(HOSTCC)
	touch $@

#
# This is the build convenience target.
#
amule: $(AMULE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AMULE_BUILD_DIR)/.staged: $(AMULE_BUILD_DIR)/.built
	rm -f $(AMULE_BUILD_DIR)/.staged
	$(MAKE) -C $(AMULE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(AMULE_BUILD_DIR)/.staged

# amule-stage: $(AMULE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/amule
#
$(AMULE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: amule" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AMULE_PRIORITY)" >>$@
	@echo "Section: $(AMULE_SECTION)" >>$@
	@echo "Version: $(AMULE_VERSION)-$(AMULE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AMULE_MAINTAINER)" >>$@
	@echo "Source: $(AMULE_SITE)/$(AMULE_SOURCE)" >>$@
	@echo "Description: $(AMULE_DESCRIPTION)" >>$@
	@echo "Depends: $(AMULE_DEPENDS)" >>$@
	@echo "Suggests: $(AMULE_SUGGESTS)" >>$@
	@echo "Conflicts: $(AMULE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AMULE_IPK_DIR)/opt/sbin or $(AMULE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AMULE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AMULE_IPK_DIR)/opt/etc/amule/...
# Documentation files should be installed in $(AMULE_IPK_DIR)/opt/doc/amule/...
# Daemon startup scripts should be installed in $(AMULE_IPK_DIR)/opt/etc/init.d/S??amule
#
# You may need to patch your application to make it use these locations.
#
$(AMULE_IPK): $(AMULE_BUILD_DIR)/.built
	rm -rf $(AMULE_IPK_DIR) $(BUILD_DIR)/amule_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AMULE_BUILD_DIR) DESTDIR=$(AMULE_IPK_DIR) program_transform_name=s/^$(GNU_TARGET_NAME)-// install-strip
#	install -d $(AMULE_IPK_DIR)/opt/etc/
#	install -m 644 $(AMULE_SOURCE_DIR)/amule.conf $(AMULE_IPK_DIR)/opt/etc/amule.conf
	install -d $(AMULE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(AMULE_SOURCE_DIR)/rc.amuled $(AMULE_IPK_DIR)/opt/etc/init.d/S57amuled
	$(MAKE) $(AMULE_IPK_DIR)/CONTROL/control
#	install -m 755 $(AMULE_SOURCE_DIR)/postinst $(AMULE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(AMULE_SOURCE_DIR)/prerm $(AMULE_IPK_DIR)/CONTROL/prerm
	echo $(AMULE_CONFFILES) | sed -e 's/ /\n/g' > $(AMULE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AMULE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(AMULE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
amule-ipk: $(AMULE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
amule-clean:
	rm -f $(AMULE_BUILD_DIR)/.built
	-$(MAKE) -C $(AMULE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
amule-dirclean:
	rm -rf $(BUILD_DIR)/$(AMULE_DIR) $(AMULE_BUILD_DIR)
	rm -rf $(AMULE_IPK_DIR) $(AMULE_IPK)
#
#
# Some sanity check for the package.
#
amule-check: $(AMULE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
