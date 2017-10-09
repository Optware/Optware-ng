###########################################################
#
# libtorrent
#
###########################################################

# LIBTORRENT_VERSION, LIBTORRENT_SITE and LIBTORRENT_SOURCE define
# the upstream location of the source code for the package.
# LIBTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTORRENT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
LIBTORRENT_SITE=https://github.com/rakshasa/libtorrent/archive
LIBTORRENT_VERSION=0.13.6
LIBTORRENT_SVN=svn://rakshasa.no/libtorrent/trunk/libtorrent
#LIBTORRENT_SVN_REV=1037
ifdef LIBTORRENT_SVN_REV
LIBTORRENT_SOURCE=libtorrent-svn-$(LIBTORRENT_SVN_REV).tar.gz
else
LIBTORRENT_SOURCE=libtorrent-$(LIBTORRENT_VERSION).tar.gz
endif
LIBTORRENT_DIR=libtorrent-$(LIBTORRENT_VERSION)
LIBTORRENT_UNZIP=zcat
LIBTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTORRENT_DESCRIPTION=libtorrent is a BitTorrent library with a focus on high performance and good code. 
LIBTORRENT_SECTION=libs
LIBTORRENT_PRIORITY=optional
LIBTORRENT_DEPENDS=openssl, libsigc++, cppunit
LIBTORRENT_SUGGESTS=
LIBTORRENT_CONFLICTS=

#
# LIBTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
LIBTORRENT_IPK_VERSION=3

#
# LIBTORRENT_CONFFILES should be a list of user-editable files
#LIBTORRENT_CONFFILES=

#
# LIBTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBTORRENT_PATCHES=

ifeq ($(TARGET_ARCH), armeb)
ifeq ($(LIBC_STYLE), glibc)
# http://tech.groups.yahoo.com/group/nslu2-developers/message/1503
LIBTORRENT_PATCHES+=$(LIBTORRENT_SOURCE_DIR)/src-data-socket_file.cc.patch
endif
endif
ifeq ($(OPTWARE_TARGET), openwrt-ixp4xx)
LIBTORRENT_PATCHES+=$(LIBTORRENT_SOURCE_DIR)/ceilf.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTORRENT_CPPFLAGS=
LIBTORRENT_LDFLAGS=-lgcc
LIBTORRENT_CONFIGURE=

ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
LIBTORRENT_CONFIGURE += CXX=$(TARGET_GXX)
endif
LIBTORRENT_CONFIG_ARGS=
else
LIBTORRENT_CONFIG_ARGS=--with-posix-fallocate
endif


ifneq ($(HOSTCC), $(TARGET_CC))
ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm armeb))
LIBTORRENT_CONFIG_ARGS+=--enable-aligned=yes
else
LIBTORRENT_CONFIG_ARGS+=--enable-aligned=no
endif
endif
ifeq ($(OPTWARE_TARGET), $(filter cs05q3armel mssii, $(OPTWARE_TARGET)))
LIBTORRENT_CONFIG_ARGS+=--without-epoll
endif
ifeq ($(OPTWARE_TARGET), $(filter buildroot-mipsel buildroot-mipsel-ng buildroot-armv5eabi-ng buildroot-ppc-603e ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
LIBTORRENT_CONFIG_ARGS+=--disable-instrumentation
endif

#
# LIBTORRENT_BUILD_DIR is the directory in which the build is done.
# LIBTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTORRENT_IPK_DIR is the directory in which the ipk is built.
# LIBTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTORRENT_BUILD_DIR=$(BUILD_DIR)/libtorrent
LIBTORRENT_SOURCE_DIR=$(SOURCE_DIR)/libtorrent
LIBTORRENT_IPK_DIR=$(BUILD_DIR)/libtorrent-$(LIBTORRENT_VERSION)-ipk
ifdef LIBTORRENT_SVN_REV
LIBTORRENT_IPK=$(BUILD_DIR)/libtorrent_$(LIBTORRENT_VERSION)+r$(LIBTORRENT_SVN_REV)-$(LIBTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk
else
LIBTORRENT_IPK=$(BUILD_DIR)/libtorrent_$(LIBTORRENT_VERSION)-$(LIBTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

.PHONY: libtorrent-source libtorrent-unpack libtorrent libtorrent-stage libtorrent-ipk libtorrent-clean libtorrent-dirclean libtorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTORRENT_SOURCE):
ifdef LIBTORRENT_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(LIBTORRENT_DIR) && \
		svn co -r $(LIBTORRENT_SVN_REV) $(LIBTORRENT_SVN) \
			$(LIBTORRENT_DIR) && \
		tar -czf $@ $(LIBTORRENT_DIR) && \
		rm -rf $(LIBTORRENT_DIR) \
		)
else
	$(WGET) -O $@ $(LIBTORRENT_SITE)/$(LIBTORRENT_VERSION).tar.gz || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtorrent-source: $(DL_DIR)/$(LIBTORRENT_SOURCE) $(LIBTORRENT_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(LIBTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTORRENT_SOURCE) $(LIBTORRENT_PATCHES) make/libtorrent.mk
	$(MAKE) openssl-stage libsigc++-stage cppunit-stage
	rm -rf $(BUILD_DIR)/$(LIBTORRENT_DIR) $(@D)
	$(LIBTORRENT_UNZIP) $(DL_DIR)/$(LIBTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTORRENT_PATCHES)" ; \
		then cat $(LIBTORRENT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBTORRENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTORRENT_DIR)" != "$(LIBTORRENT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBTORRENT_DIR) $(LIBTORRENT_BUILD_DIR) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
# fix for newer gcc error: ‘NULL’ was not declared in this scope
	sed -i -e '/^#define LIBTORRENT_COMMON_H/s/$$/\n\n#include <cstddef>/' \
		$(@D)/src/torrent/common.h
	sed -i -e 's/as_fn_error \$$? "cannot run/echo "cannot run/' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTORRENT_LDFLAGS)" \
		OPENSSL_CFLAGS="$(STAGING_CPPFLAGS)" \
		OPENSSL_LIBS="$(STAGING_LDFLAGS) -lcrypto" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig/" \
		$(LIBTORRENT_CONFIGURE) \
		PATH="$(PATH):$(STAGING_PREFIX)/bin" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		$(LIBTORRENT_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
		--enable-openssl \
	)
ifneq (, $(filter gumstix1151 mbwe-bluering, $(OPTWARE_TARGET)))
	sed -i -e '/USE_MADVISE/s|.*|/* #undef USE_MADVISE */|' $(@D)/config.h
endif
	find $(@D) -name Makefile -exec sed -i -e 's;-I/usr/include$$\|-I/usr/include[ \t]\|-I/usr/include/[^ \t]*;;g' {} \;
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtorrent-unpack: $(LIBTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTORRENT_BUILD_DIR)/.built: $(LIBTORRENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libtorrent: $(LIBTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTORRENT_BUILD_DIR)/.staged: $(LIBTORRENT_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_LIB_DIR)/libtorrent.so*
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libtorrent.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libtorrent.pc
	touch $@

libtorrent-stage: $(LIBTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtorrent
#
$(LIBTORRENT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libtorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT_SECTION)" >>$@
ifdef LIBTORRENT_SVN_REV
	@echo "Version: $(LIBTORRENT_VERSION)+r$(LIBTORRENT_SVN_REV)-$(LIBTORRENT_IPK_VERSION)" >>$@
else
	@echo "Version: $(LIBTORRENT_VERSION)-$(LIBTORRENT_IPK_VERSION)" >>$@
endif
	@echo "Maintainer: $(LIBTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT_SITE)/$(LIBTORRENT_VERSION).tar.gz" >>$@
	@echo "Description: $(LIBTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/libtorrent/...
# Documentation files should be installed in $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/doc/libtorrent/...
# Daemon startup scripts should be installed in $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libtorrent
#
# You may need to patch your application to make it use these locations.
#
$(LIBTORRENT_IPK): $(LIBTORRENT_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT_IPK_DIR) $(BUILD_DIR)/libtorrent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTORRENT_BUILD_DIR) DESTDIR=$(LIBTORRENT_IPK_DIR) install-strip
	rm -rf $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/include
	rm -rf $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	rm -rf $(LIBTORRENT_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	$(MAKE) $(LIBTORRENT_IPK_DIR)/CONTROL/control
	echo $(LIBTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtorrent-ipk: $(LIBTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtorrent-clean:
	rm -f $(LIBTORRENT_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTORRENT_DIR) $(LIBTORRENT_BUILD_DIR) $(LIBTORRENT_IPK_DIR) $(LIBTORRENT_IPK)

#
# Some sanity check for the package.
#
libtorrent-check: $(LIBTORRENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
