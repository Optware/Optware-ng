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
LIBTORRENT_SITE=http://libtorrent.rakshasa.no/downloads/
LIBTORRENT_VERSION=0.11.6
LIBTORRENT_SOURCE=libtorrent-$(LIBTORRENT_VERSION).tar.gz
LIBTORRENT_DIR=libtorrent-$(LIBTORRENT_VERSION)
LIBTORRENT_UNZIP=zcat
LIBTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTORRENT_DESCRIPTION=libtorrent is a BitTorrent library with a focus on high performance and good code. 
LIBTORRENT_SECTION=libs
LIBTORRENT_PRIORITY=optional
LIBTORRENT_DEPENDS=openssl, libsigc++
LIBTORRENT_SUGGESTS=
LIBTORRENT_CONFLICTS=

#
# LIBTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
LIBTORRENT_IPK_VERSION=1

#
# LIBTORRENT_CONFFILES should be a list of user-editable files
#LIBTORRENT_CONFFILES=

#
# LIBTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
LIBTORRENT_PATCHES=$(LIBTORRENT_SOURCE_DIR)/configure.patch
else
LIBTORRENT_PATCHES=
endif
ifeq ($(TARGET_ARCH), armeb)
ifeq ($(LIBC_STYLE), glibc)
# http://tech.groups.yahoo.com/group/nslu2-developers/message/1503
LIBTORRENT_PATCHES+=$(LIBTORRENT_SOURCE_DIR)/src-data-socket_file.cc.patch
endif
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTORRENT_CPPFLAGS=
LIBTORRENT_LDFLAGS=
LIBTORRENT_CONFIGURE=
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
LIBTORRENT_CONFIGURE += CXX=$(TARGET_GXX)
endif
endif

#ifeq ($(OPTWARE_TARGET), $(filter ds101g ddwrt oleg, $(OPTWARE_TARGET)))
#LIBTORRENT_CONFIG_ARGS=
#else
#endif

ifneq ($(HOSTCC), $(TARGET_CC))
ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm armeb))
LIBTORRENT_CONFIG_ARGS=--enable-aligned=yes
endif
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
LIBTORRENT_IPK=$(BUILD_DIR)/libtorrent_$(LIBTORRENT_VERSION)-$(LIBTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtorrent-source libtorrent-unpack libtorrent libtorrent-stage libtorrent-ipk libtorrent-clean libtorrent-dirclean libtorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTORRENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBTORRENT_SITE)/$(LIBTORRENT_SOURCE)

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
	$(MAKE) openssl-stage libsigc++-stage
	rm -rf $(BUILD_DIR)/$(LIBTORRENT_DIR) $(LIBTORRENT_BUILD_DIR)
	$(LIBTORRENT_UNZIP) $(DL_DIR)/$(LIBTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTORRENT_PATCHES)" ; \
		then cat $(LIBTORRENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBTORRENT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTORRENT_DIR)" != "$(LIBTORRENT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBTORRENT_DIR) $(LIBTORRENT_BUILD_DIR) ; \
	fi
	(cd $(LIBTORRENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTORRENT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_DIR)/opt/lib/pkgconfig/" \
		$(LIBTORRENT_CONFIGURE) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(LIBTORRENT_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
		--with-openssl=$(STAGING_PREFIX) \
	)
	$(PATCH_LIBTOOL) $(LIBTORRENT_BUILD_DIR)/libtool
	touch $(LIBTORRENT_BUILD_DIR)/.configured

libtorrent-unpack: $(LIBTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTORRENT_BUILD_DIR)/.built: $(LIBTORRENT_BUILD_DIR)/.configured
	rm -f $(LIBTORRENT_BUILD_DIR)/.built
	$(MAKE) -C $(LIBTORRENT_BUILD_DIR)
	touch $(LIBTORRENT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libtorrent: $(LIBTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTORRENT_BUILD_DIR)/.staged: $(LIBTORRENT_BUILD_DIR)/.built
	rm -f $(LIBTORRENT_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBTORRENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libtorrent.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libtorrent.pc
	touch $(LIBTORRENT_BUILD_DIR)/.staged

libtorrent-stage: $(LIBTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtorrent
#
$(LIBTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(LIBTORRENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libtorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT_VERSION)-$(LIBTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT_SITE)/$(LIBTORRENT_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTORRENT_IPK_DIR)/opt/sbin or $(LIBTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBTORRENT_IPK_DIR)/opt/etc/libtorrent/...
# Documentation files should be installed in $(LIBTORRENT_IPK_DIR)/opt/doc/libtorrent/...
# Daemon startup scripts should be installed in $(LIBTORRENT_IPK_DIR)/opt/etc/init.d/S??libtorrent
#
# You may need to patch your application to make it use these locations.
#
$(LIBTORRENT_IPK): $(LIBTORRENT_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT_IPK_DIR) $(BUILD_DIR)/libtorrent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTORRENT_BUILD_DIR) DESTDIR=$(LIBTORRENT_IPK_DIR) install-strip
	rm -rf $(LIBTORRENT_IPK_DIR)/opt/include
	rm -rf $(LIBTORRENT_IPK_DIR)/opt/lib/*.la
	rm -rf $(LIBTORRENT_IPK_DIR)/opt/lib/pkgconfig
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBTORRENT_IPK)
