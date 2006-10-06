##########################################################
#
# buildroot
#
###########################################################
#
# Provides  toolchain, native toolchain as buildroot.ipk or uclibc.ipk
#
# PATH for target cross toolchain is:
# $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC_VERSION)/bin/
#
# TARGET_CROSS = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC_VERSION)/\
#			bin/$(TARGET_ARCH)-$(TARGET_OS)-
# TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC_VERSION)/lib
#
# Some variables for higher level Makefile:
# Note that GNU_TARGET_NAME is not $(TARGET_ARCH)-$(TARGET_OS) but
# GNU_TARGET_NAME = $(TARGET_ARCH)-linux
#
# BUILDROOT_GCC = $(CROSS_CONFIGURATION_GCC_VERSION)
# CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
# 
# UCLIBC_VERSION = $(CROSS_CONFIGURATION_UCLIBC_VERSION)
# CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
# CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
#
# BUILDROOT_VERSION, BUILDROOT_SITE and BUILDROOT_SOURCE define
# the upstream location of the source code for the package.
# BUILDROOT_DIR is the directory which is created when the source
# archive is unpacked.
# BUILDROOT_UNZIP is the command used to unzip the source.
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
# TODO: cp -fa instead tar copy
#
BUILDROOT_GCC ?= 3.4.6
BUILDROOT_BINUTILS ?= 2.16.1
UCLIBC_VERSION ?= 0.9.28

BUILDROOT_VERSION=$(BUILDROOT_GCC)
BUILDROOT_SVN=svn://uclibc.org/trunk/buildroot
BUILDROOT_SVN_REV=15597
BUILDROOT_SOURCE=buildroot-svn-$(BUILDROOT_SVN_REV).tar.gz
BUILDROOT_DIR=buildroot
BUILDROOT_UNZIP=zcat
BUILDROOT_MAINTAINER=Leon Kos <oleo@email.si>
BUILDROOT_DESCRIPTION=uClibc compilation toolchain
BUILDROOT_SECTION=devel
BUILDROOT_PRIORITY=optional
BUILDROOT_DEPENDS=
BUILDROOT_SUGGESTS=
BUILDROOT_CONFLICTS=uclibc

# uClibc library target provided by buildroot
UCLIBC_DESCRIPTION=micro C library for embedded Linux systems
UCLIBC_SECTION=base
UCLIBC_PRIORITY=required
UCLIBC_DEPENDS=
UCLIBC_SUGGESTS=
UCLIBC_CONFLICTS=buildroot

#
# BUILDROOT_IPK_VERSION should be incremented when the ipk changes.
#
BUILDROOT_IPK_VERSION=2

# Custom linux headers
# Headers should contain $(HEADERS_._UNPACK_DIR)/Makefile and 
# $(HEADERS_._UNPACK_DIR)/include directory
BUILDROOT_HEADERS_DIR=$(TOOL_BUILD_DIR)/buildroot/toolchain_build_$(TARGET_ARCH)

# Oleg firmware for Asus Wireless routers
HEADERS_OLEG_SITE=http://www.wlan-sat.com/boleo/optware
HEADERS_OLEG_SOURCE=linux-libc-headers-oleg.tar.bz2
HEADERS_OLEG_UNPACK_DIR=linux
HEADERS_OLEG=LINUX_HEADERS_SOURCE=$(HEADERS_OLEG_SOURCE) \
 LINUX_HEADERS_UNPACK_DIR=$(BUILDROOT_HEADERS_DIR)/$(HEADERS_OLEG_UNPACK_DIR)
$(DL_DIR)/$(HEADERS_OLEG_SOURCE):
	$(WGET) -P $(DL_DIR) $(HEADERS_OLEG_SITE)/$(HEADERS_OLEG_SOURCE)

# DD-WRT firmware for various Broadcom based routers
HEADERS_DDWRT_SITE=http://www.wlan-sat.com/boleo/optware
HEADERS_DDWRT_SOURCE=linux-libc-headers-DD-WRT-v23.tar.bz2
HEADERS_DDWRT_UNPACK_DIR=linux.v23
HEADERS_DDWRT=LINUX_HEADERS_SOURCE=$(HEADERS_DDWRT_SOURCE) \
 LINUX_HEADERS_UNPACK_DIR=$(BUILDROOT_HEADERS_DIR)/$(HEADERS_DDWRT_UNPACK_DIR) 
$(DL_DIR)/$(HEADERS_DDWRT_SOURCE):
	$(WGET) -P $(DL_DIR) $(HEADERS_DDWRT_SITE)/$(HEADERS_DDWRT_SOURCE)

BUILDROOT_HEADERS=$(DL_DIR)/$(HEADERS_OLEG_SOURCE) \
		$(DL_DIR)/$(HEADERS_DDWRT_SOURCE)

# Select appropriate headers or leave empty for default
BUILDROOT_CUSTOM_HEADERS ?=

buildroot-headers:
	@echo "$(OPTWARE_TARGET): $(BUILDROOT_CUSTOM_HEADERS)"
#
# BUILDROOT_CONFFILES should be a list of user-editable files
# BUILDROOT_CONFFILES=/opt/etc/buildroot.conf /opt/etc/init.d/SXXbuildroot

#
# BUILDROOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BUILDROOT_PATCHES=$(BUILDROOT_SOURCE_DIR)/uclibc.mk.patch \
		$(BUILDROOT_SOURCE_DIR)/gcc-uclibc-3.x.mk.patch \
		$(BUILDROOT_SOURCE_DIR)/uClibc.config-locale.patch
#		$(BUILDROOT_SOURCE_DIR)/uClibc.config.patch 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BUILDROOT_CPPFLAGS=
BUILDROOT_LDFLAGS=

#
# BUILDROOT_BUILD_DIR is the directory in which the build is done.
# BUILDROOT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BUILDROOT_IPK_DIR is the directory in which the ipk is built.
# BUILDROOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BUILDROOT_BUILD_DIR=$(TOOL_BUILD_DIR)/buildroot
BUILDROOT_SOURCE_DIR=$(SOURCE_DIR)/buildroot
BUILDROOT_IPK_DIR=$(BUILD_DIR)/buildroot-$(BUILDROOT_VERSION)-ipk
BUILDROOT_IPK=$(BUILD_DIR)/buildroot_$(BUILDROOT_VERSION)-$(BUILDROOT_IPK_VERSION)_$(TARGET_ARCH).ipk

UCLIBC_IPK_DIR=$(BUILD_DIR)/uclibc-$(UCLIBC_VERSION)-ipk
UCLIBC_IPK=$(BUILD_DIR)/uclibc_$(UCLIBC_VERSION)-$(BUILDROOT_IPK_VERSION)_$(TARGET_ARCH).ipk

BUILDROOT_TOOLS_MK= $(BUILDROOT_BUILD_DIR)/toolchain/binutils/binutils.mk 

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(BUILDROOT_SOURCE):
#	$(WGET) -P $(DL_DIR) $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)

$(DL_DIR)/$(BUILDROOT_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(BUILDROOT_DIR) && \
		svn co -r $(BUILDROOT_SVN_REV) $(BUILDROOT_SVN) && \
		tar -czf $@ $(BUILDROOT_DIR) && \
		rm -rf $(BUILDROOT_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
buildroot-source uclibc-source: $(DL_DIR)/$(BUILDROOT_SOURCE) $(BUILDROOT_PATCHES)

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
$(BUILDROOT_BUILD_DIR)/.configured: $(DL_DIR)/$(BUILDROOT_SOURCE) \
		$(BUILDROOT_PATCHES) $(BUILDROOT_HEADERS) \
		$(BUILDROOT_SOURCE_DIR)/buildroot.config
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR)
	$(BUILDROOT_UNZIP) $(DL_DIR)/$(BUILDROOT_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	if test -n "$(BUILDROOT_PATCHES)" ; \
		then cat $(BUILDROOT_PATCHES) | \
		patch -d $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) -p1 ; \
	fi
	if test "$(TOOL_BUILD_DIR)/$(BUILDROOT_DIR)" != "$(BUILDROOT_BUILD_DIR)" ; \
		then mv $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) ; \
	fi
	cp $(BUILDROOT_SOURCE_DIR)/buildroot.config $(BUILDROOT_BUILD_DIR)/.config
#	change TARGET_ARCH in .config
	sed  -i -e 's|.*\(BR2_[a-z0-9_]\{2,\}\).*|# \1 is not set|' \
	 -e 's|# BR2_$(TARGET_ARCH) is not set|BR2_$(TARGET_ARCH)=y|' \
	 -e 's|^BR2_ARCH=.*|BR2_ARCH="$(TARGET_ARCH)"|' $(BUILDROOT_BUILD_DIR)/.config
#	change BR2_ENDIAN for armeb and mipsel only !
	sed  -i -e 's|BR2_ENDIAN=.*|BR2_ENDIAN="$(TARGET_ARCH)"|' \
	 -e '/BR2_ENDIAN=/s|armeb|BIG|;/BR2_ENDIAN=/s|mipsel|LITTLE|' \
	$(BUILDROOT_BUILD_DIR)/.config
#	change GCC version in .config
	sed  -i -e 's|.*\(BR2_GCC_VERSION_[0-9_]\{1,\}\).*|# \1 is not set|' \
	 -e 's|# BR2_GCC_VERSION_$(BUILDROOT_GCC) is not set|BR2_GCC_VERSION_$(BUILDROOT_GCC)=y|' \
	 -e '/BR2_GCC_VERSION_$(BUILDROOT_GCC)=y/s|\.|_|g' \
	 -e 's|^BR2_GCC_VERSION=.*|BR2_GCC_VERSION="$(BUILDROOT_GCC)"|' $(BUILDROOT_BUILD_DIR)/.config
# 	change binutils version in .config
	sed  -i -e 's|.*\(BR2_BINUTILS_VERSION_[0-9_]\{1,\}\).*|# \1 is not set|' \
	 -e 's|# BR2_BINUTILS_VERSION_$(BUILDROOT_BINUTILS) is not set|BR2_BINUTILS_VERSION_$(BUILDROOT_BINUTILS)=y|' \
	 -e '/BR2_BINUTILS_VERSION_$(BUILDROOT_BINUTILS)=y/s|\.|_|g' \
	 -e 's|^BR2_BINUTILS_VERSION=.*|BR2_BINUTILS_VERSION="$(BUILDROOT_BINUTILS)"|' $(BUILDROOT_BUILD_DIR)/.config
#	change toolchain staging dir
	sed -i -e 's|^BR2_STAGING_DIR=*|BR2_STAGING_DIR="$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC_VERSION)"|' $(BUILDROOT_BUILD_DIR)/.config
	(cd $(BUILDROOT_BUILD_DIR); \
		make oldconfig \
	)
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/gcc/$(BUILDROOT_GCC)/100-uclibc-conf.patch
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/100-uclibc-conf.patch
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/110-uclibc-libtool-conf.patch
	sed -i.orig.0 -e 's|(TARGET_DIR)/lib|(TARGET_DIR)/opt/lib|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.1 -e 's|(TARGET_DIR)/usr|(TARGET_DIR)/opt|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.2 -e 's|=/usr|=/opt|g;s|=\\"/lib|=\\"/opt/lib|g;s|=\\"/usr|=\\"/opt|g' $(BUILDROOT_TOOLS_MK)
	touch $(BUILDROOT_BUILD_DIR)/.configured

buildroot-unpack uclibc-unpack: $(BUILDROOT_BUILD_DIR)/.configured


#
# This builds the actual binary.
#
$(BUILDROOT_BUILD_DIR)/.built: $(BUILDROOT_BUILD_DIR)/.configured
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	$(MAKE) -C $(BUILDROOT_BUILD_DIR) $(BUILDROOT_CUSTOM_HEADERS)
	touch $(BUILDROOT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
buildroot uclibc: $(BUILDROOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BUILDROOT_BUILD_DIR)/.staged: $(BUILDROOT_BUILD_DIR)/.built
	rm -f $(BUILDROOT_BUILD_DIR)/.staged
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BUILDROOT_BUILD_DIR)/.staged

buildroot-stage uclibc-stage buildroot-toolchain: $(BUILDROOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(BUILDROOT_IPK_DIR)/CONTROL/control:
	@install -d $(BUILDROOT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: buildroot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUILDROOT_PRIORITY)" >>$@
	@echo "Section: $(BUILDROOT_SECTION)" >>$@
	@echo "Version: $(BUILDROOT_VERSION)-$(BUILDROOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(BUILDROOT_DESCRIPTION)" >>$@
	@echo "Depends: $(BUILDROOT_DEPENDS)" >>$@
	@echo "Suggests: $(BUILDROOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(BUILDROOT_CONFLICTS)" >>$@

$(UCLIBC_IPK_DIR)/CONTROL/control:
	@install -d $(UCLIBC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: uclibc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UCLIBC_PRIORITY)" >>$@
	@echo "Section: $(UCLIBC_SECTION)" >>$@
	@echo "Version: $(UCLIBC_VERSION)-$(BUILDROOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(UCLIBC_DESCRIPTION)" >>$@
	@echo "Depends: $(UCLIBC_DEPENDS)" >>$@
	@echo "Suggests: $(UCLIBC_SUGGESTS)" >>$@
	@echo "Conflicts: $(UCLIBC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUILDROOT_IPK_DIR)/opt/sbin or $(BUILDROOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUILDROOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BUILDROOT_IPK_DIR)/opt/etc/buildroot/...
# Documentation files should be installed in $(BUILDROOT_IPK_DIR)/opt/doc/buildroot/...
# Daemon startup scripts should be installed in $(BUILDROOT_IPK_DIR)/opt/etc/init.d/S??buildroot
#
# You may need to patch your application to make it use these locations.
#
$(BUILDROOT_IPK): $(BUILDROOT_BUILD_DIR)/.built
	rm -rf $(BUILDROOT_IPK_DIR) $(BUILD_DIR)/buildroot_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(BUILDROOT_IPK_DIR) install-strip
	install -d $(BUILDROOT_IPK_DIR)
	tar -xv -C $(BUILDROOT_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar ./opt
#	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/usr/bin/ccache $(BUILDROOT_IPK_DIR)/opt/bin
	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/usr/bin/gdb $(BUILDROOT_IPK_DIR)/opt/bin
	$(MAKE) $(BUILDROOT_IPK_DIR)/CONTROL/control
	install -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(BUILDROOT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(BUILDROOT_IPK_DIR)/CONTROL/prerm
	echo $(BUILDROOT_CONFFILES) | sed -e 's/ /\n/g' > $(BUILDROOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILDROOT_IPK_DIR)


UCLIBC_LIBS=ld-uClibc libc libdl libgcc_s libm libintl libnsl libpthread \
	libresolv  librt libutil libuClibc
UCLIBC_LIBS_PATTERN=$(patsubst %,\
	$(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/opt/lib/%*so*,$(UCLIBC_LIBS))

$(UCLIBC_IPK): $(BUILDROOT_BUILD_DIR)/.built
	rm -rf $(UCLIBC_IPK_DIR) $(BUILD_DIR)/uclibc_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(UCLIBC_IPK_DIR) install-strip
	install -d $(UCLIBC_IPK_DIR)
#	tar -xv -C $(UCLIBC_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar \
#		--wildcards $(UCLIBC_LIBS_PATTERN) ./opt/sbin/ldconfig
	install -d $(UCLIBC_IPK_DIR)/opt/lib
	cp -d $(UCLIBC_LIBS_PATTERN) $(UCLIBC_IPK_DIR)/opt/lib
	install -d $(UCLIBC_IPK_DIR)/opt/sbin
	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/opt/sbin/ldconfig \
		$(UCLIBC_IPK_DIR)/opt/sbin
	$(MAKE) $(UCLIBC_IPK_DIR)/CONTROL/control
	install -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(UCLIBC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(UCLIBC_IPK_DIR)/CONTROL/prerm
	echo $(UCLIBC_CONFFILES) | sed -e 's/ /\n/g' > $(UCLIBC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UCLIBC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
buildroot-ipk: $(BUILDROOT_IPK)

uclibc-ipk: $(UCLIBC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
buildroot-clean uclibc-clean:
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	-$(MAKE) -C $(BUILDROOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
buildroot-dirclean uclibc-dirclean:
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) $(BUILDROOT_IPK_DIR) $(BUILDROOT_IPK)

# Notes:
#
# Reconfiguring buildroot
# cd buildroot ; make menuconfig
# cp .config ../../sources/buildroot.config
#
# Create patches:
# diff -u buildroot.r15597/toolchain/uClibc/uclibc.mk buildroot/toolchain/uClibc/uclibc.mk > ../sources/buildroot/uclibc.mk.patch
#  diff -u buildroot.r15597/toolchain/gcc/gcc-uclibc-3.x.mk buildroot/toolchain/gcc/gcc-uclibc-3.x.mk > ../sources/buildroot/gcc-uclibc-3.x.mk.patch 
# rebuilding uClibc by hand:
# make uclibc-dirclean
# make uclibc-configured 
# make uclibc
# make uclibc_target
# make
# 
# Creating uClibc.config patch
# make uclibc-dirclean
# make uclibc-configured
# manually add/change missing configs from buildroot/toolchain_build_mipsel/uClibc-0.9.28/.config
# create diff to vanilla uClibc.conf-locale
# diff -u buildroot.r15597/toolchain/uClibc/uClibc.config-locale buildroot/toolchain/uClibc/uClibc.config-locale > ../sources/buildroot/uClibc.config-locale.patch
# diff -u ../builds/buildroot-vanilla/toolchain/uClibc/uClibc.config buildroot/toolchain/uClibc/uClibc.config > ../sources/buildroot/uClibc.config.patch
#
