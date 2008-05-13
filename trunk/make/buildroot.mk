##########################################################
#
# buildroot
#
###########################################################
#
# Provides  toolchain, native toolchain as buildroot.ipk or uclibc-opt.ipk
#
# PATH for target cross toolchain is:
# $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC-OPT_VERSION)/bin/
#
# TARGET_CROSS = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC-OPT_VERSION)/\
#			bin/$(TARGET_ARCH)-$(TARGET_OS)-
# TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/\
#		gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC-OPT_VERSION)/lib
#
# Some variables for higher level Makefile:
# Note that GNU_TARGET_NAME is not $(TARGET_ARCH)-$(TARGET_OS) but
# GNU_TARGET_NAME = $(TARGET_ARCH)-linux
#
# BUILDROOT_GCC = $(CROSS_CONFIGURATION_GCC_VERSION)
# CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
# 
# UCLIBC-OPT_VERSION = $(CROSS_CONFIGURATION_UCLIBC_VERSION)
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
#
ifeq ($(OPTWARE_TARGET), ts101)
BUILDROOT_GCC = 3.4.3
BUILDROOT_BINUTILS = 2.15.91.0.2
BUILDROOT_VERSION = $(BUILDROOT_GCC)
BUILDROOT_SOURCE = buildroot-0.9.27-3.tar.gz
BUILDROOT_SITE = http://mirror.kynisk.com/ts/br
else
BUILDROOT_GCC ?= 4.1.1
BUILDROOT_BINUTILS ?= 2.17.50.0.8

BUILDROOT_VERSION=$(BUILDROOT_GCC)
BUILDROOT_SVN=svn://uclibc.org/trunk/buildroot
BUILDROOT_SVN_REV=17310
BUILDROOT_SOURCE=buildroot-svn-$(BUILDROOT_SVN_REV).tar.gz
endif
BUILDROOT_DIR=buildroot
BUILDROOT_UNZIP=zcat
BUILDROOT_MAINTAINER=Leon Kos <oleo@email.si>
BUILDROOT_DESCRIPTION=uClibc compilation toolchain
BUILDROOT_SECTION=devel
BUILDROOT_PRIORITY=optional
BUILDROOT_DEPENDS=uclibc-opt (= $(UCLIBC-OPT_VERSION)-$(UCLIBC-OPT_IPK_VERSION))
BUILDROOT_SUGGESTS=
BUILDROOT_CONFLICTS=

#
# BUILDROOT_IPK_VERSION should be incremented when the ipk changes.
#
BUILDROOT_IPK_VERSION=13

# Custom linux headers
# Headers should contain $(HEADERS_*_UNPACK_DIR)/Makefile and 
# $(HEADERS_*_UNPACK_DIR)/include directory
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

# Whiterussian RC6 headers - also for X-Wrt - same as ddwrt 
HEADERS_XWRT_SITE=http://www.kernel.org/pub/linux/kernel/v2.4
HEADERS_XWRT_SOURCE=linux-libc-headers-XWRT.tar.bz2
HEADERS_XWRT_UNPACK_DIR=linux
HEADERS_XWRT=LINUX_HEADERS_SOURCE=$(HEADERS_XWRT_SOURCE) \
 LINUX_HEADERS_UNPACK_DIR=$(BUILDROOT_HEADERS_DIR)/$(HEADERS_XWRT_UNPACK_DIR)
$(DL_DIR)/$(HEADERS_XWRT_SOURCE):
	$(WGET) -P $(DL_DIR) $(HEADERS_XWRT_SITE)/$(HEADERS_XWRT_SOURCE)


ifeq ($(OPTWARE_TARGET), ts101)
BUILDROOT_HEADERS=
else
BUILDROOT_HEADERS=$(DL_DIR)/$(HEADERS_OLEG_SOURCE) \
		$(DL_DIR)/$(HEADERS_DDWRT_SOURCE)
endif

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
ifeq ($(OPTWARE_TARGET), ts101)
BUILDROOT_PATCHES=
else
BUILDROOT_PATCHES=$(BUILDROOT_SOURCE_DIR)/uclibc.mk.patch \
		$(BUILDROOT_SOURCE_DIR)/gcc-uclibc-3.x.mk.patch
endif

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

.PHONY: buildroot-source \
buildroot-unpack buildroot buildroot-stage buildroot-toolchain \
uclibc-unpack uclibc-opt uclibc-opt-stage \
buildroot-ipk buildroot-clean buildroot-dirclean buildroot-check


BUILDROOT_TOOLS_MK= $(BUILDROOT_BUILD_DIR)/toolchain/binutils/binutils.mk 

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BUILDROOT_SOURCE):
ifeq ($(OPTWARE_TARGET), ts101)
	$(WGET) -P $(@D) $(BUILDROOT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(BUILDROOT_DIR) && \
		svn co -r $(BUILDROOT_SVN_REV) $(BUILDROOT_SVN) && \
		tar -czf $@ $(BUILDROOT_DIR) && \
		rm -rf $(BUILDROOT_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
buildroot-source uclibc-opt-source: $(DL_DIR)/$(BUILDROOT_SOURCE) $(BUILDROOT_PATCHES)

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
ifeq ($(OPTWARE_TARGET), ts101)
BUILDROOT_CONFIG_FILE=buildroot.ts101
UCLIBC_CONFIG_FILE=uclibc.ts101
else
BUILDROOT_CONFIG_FILE=buildroot.config
UCLIBC_CONFIG_FILE=uClibc-$(UCLIBC-OPT_VERSION).config
endif

$(BUILDROOT_BUILD_DIR)/.configured: $(DL_DIR)/$(BUILDROOT_SOURCE) \
			$(BUILDROOT_PATCHES) $(BUILDROOT_HEADERS) \
			$(BUILDROOT_SOURCE_DIR)/$(BUILDROOT_CONFIG_FILE) \
			$(BUILDROOT_SOURCE_DIR)/$(UCLIBC_CONFIG_FILE)
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR)
	$(BUILDROOT_UNZIP) $(DL_DIR)/$(BUILDROOT_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	if test -n "$(BUILDROOT_PATCHES)" ; \
		then cat $(BUILDROOT_PATCHES) | \
		patch -d $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) -p1 ; \
	fi
	if test "$(TOOL_BUILD_DIR)/$(BUILDROOT_DIR)" != "$(BUILDROOT_BUILD_DIR)" ; \
		then mv $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) ; \
	fi
	cp $(BUILDROOT_SOURCE_DIR)/$(BUILDROOT_CONFIG_FILE) $(BUILDROOT_BUILD_DIR)/.config
ifneq ($(OPTWARE_TARGET), ts101)
	sed  -i -e 's|^# BR2_PACKAGE_GDB is not set|BR2_PACKAGE_GDB=yes|' $(BUILDROOT_BUILD_DIR)/.config
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
endif
#	change toolchain staging dir
	sed -i -e 's|^BR2_STAGING_DIR=*|BR2_STAGING_DIR="$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC-OPT_VERSION)"|' $(BUILDROOT_BUILD_DIR)/.config
	(cd $(BUILDROOT_BUILD_DIR); \
		make oldconfig \
	)
ifneq ($(OPTWARE_TARGET), ts101)
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/gcc/$(BUILDROOT_GCC)/100-uclibc-conf.patch
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/100-uclibc-conf.patch
#	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/110-uclibc-libtool-conf.patch
	sed -i.orig.0 -e 's|(TARGET_DIR)/lib|(TARGET_DIR)/opt/lib|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.1 -e 's|(TARGET_DIR)/usr|(TARGET_DIR)/opt|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.2 -e 's|=/usr|=/opt|g;s|=\\"/lib|=\\"/opt/lib|g;s|=\\"/usr|=\\"/opt|g' $(BUILDROOT_TOOLS_MK)
	cp $(BUILDROOT_SOURCE_DIR)/400-ld-native-search-path.patch \
	  $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/
	cp $(BUILDROOT_SOURCE_DIR)/410-bfd-elfxx-mips-opt.patch \
	  $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/
	cp $(BUILDROOT_SOURCE_DIR)/410-bfd-elfxx-mips-opt.patch \
	  $(BUILDROOT_BUILD_DIR)/toolchain/gdb/6.5/
	cp $(BUILDROOT_SOURCE_DIR)/900-gcc-$(BUILDROOT_GCC)-opt.patch \
	  $(BUILDROOT_BUILD_DIR)/toolchain/gcc/$(BUILDROOT_GCC)/
else
	sed -i.orig -e '/^GCC_SITE/s|=.*|=http://ftp.gnu.org/gnu/gcc/gcc-$$(GCC_VERSION)|' $(@D)/toolchain/gcc/gcc-uclibc-3.x.mk
endif
	touch $(BUILDROOT_BUILD_DIR)/.configured

buildroot-unpack uclibc-unpack: $(BUILDROOT_BUILD_DIR)/.configured


#
# This builds the actual binary.
#
$(BUILDROOT_BUILD_DIR)/.built: $(BUILDROOT_BUILD_DIR)/.configured
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	rm -rf $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/gcc-$(BUILDROOT_GCC)-uclibc-$(UCLIBC-OPT_VERSION)
	$(MAKE) -C $(BUILDROOT_BUILD_DIR) $(BUILDROOT_CUSTOM_HEADERS) \
	UCLIBC_CONFIG_FILE=$(BUILDROOT_SOURCE_DIR)/$(UCLIBC_CONFIG_FILE)
	touch $(BUILDROOT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
buildroot uclibc-opt: $(BUILDROOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BUILDROOT_BUILD_DIR)/.staged: $(BUILDROOT_BUILD_DIR)/.built
	rm -f $(BUILDROOT_BUILD_DIR)/.staged
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BUILDROOT_BUILD_DIR)/.staged

buildroot-stage uclibc-opt-stage buildroot-toolchain: $(BUILDROOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(BUILDROOT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
#	tar -xv -C $(BUILDROOT_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar ./opt
	cp -fa $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/opt/ $(BUILDROOT_IPK_DIR)
#	Remove files provided by uclibc-opt
	rm -f $(patsubst %, $(BUILDROOT_IPK_DIR)/opt/lib/%*so*, $(UCLIBC-OPT_LIBS))
	rm -f $(BUILDROOT_IPK_DIR)/opt/sbin/ldconfig
#	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/usr/bin/ccache $(BUILDROOT_IPK_DIR)/opt/bin
	install -m 755 $(BUILDROOT_BUILD_DIR)/build_$(TARGET_ARCH)/root/usr/bin/gdb $(BUILDROOT_IPK_DIR)/opt/bin
	$(MAKE) $(BUILDROOT_IPK_DIR)/CONTROL/control
	install -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(BUILDROOT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(BUILDROOT_IPK_DIR)/CONTROL/prerm
#	echo $(BUILDROOT_CONFFILES) | sed -e 's/ /\n/g' > $(BUILDROOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILDROOT_IPK_DIR)


#
# This is called from the top level makefile to create the IPK file.
#
buildroot-ipk: $(BUILDROOT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
buildroot-clean uclibc-opt-clean:
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	-$(MAKE) -C $(BUILDROOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
buildroot-dirclean:
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) $(BUILDROOT_IPK_DIR) $(BUILDROOT_IPK)


#
#
# Some sanity check for the package.
#
buildroot-check: $(BUILDROOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BUILDROOT_IPK)

# Notes:
#
# Reconfiguring buildroot
# cd buildroot ; make menuconfig
# cp .config ../../sources/buildroot.config
# Warning! UCLIBC_CONFIG_FILE is appended to buildroot .config when doing
# make buildroot-unpack
# After reconfuguring buildroot and .config copy buildroot will unpack again
# Always issue make buildroot to run make with appropriate headers
# and uClibc*.config
# make query-BUILDROOT_CUSTOM_HEADERS
# make  query-UCLIBC_CONFIG_FILE
#
# Create patches:
# diff -u buildroot-r16948/toolchain/uClibc/uclibc.mk \
#  buildroot/toolchain/uClibc/uclibc.mk > ../sources/buildroot/uclibc.mk.patch
# diff -u buildroot-r16948/toolchain/gcc/gcc-uclibc-3.x.mk \
#   buildroot/toolchain/gcc/gcc-uclibc-3.x.mk \
#   > ../sources/buildroot/gcc-uclibc-3.x.mk.patch 
#
# Rebuilding uClibc by hand:
# cd toolchain/buildroot
# make uclibc-dirclean
# make uclibc-unpacked
# make uclibc-configured 
# make uclibc
# make uclibc_target
# make
# 
# Creating uClibc.config
# In case of inexistent custom uClibc.config copy the most similar
# and then reconfigure
# cd toolchain/buildroot
# make uclibc-dirclean
# make uclibc-configured
# To revise uClibc setings do
# cd buildroot/toolchain_build_mipsel/uClibc-0.9.28
# make menuconfig
# cp .config ../../../../sources/buildroot/uClibc-0.9.28.config
# Optionally clear .config paths to:
#  KERNEL_SOURCE="" and CROSS_COMPILER_PREFIX=""
#
# notes:
# gcc 4.2 needs -fpermissive
# for missing math see http://busybox.net/bugs/view.php?id=144
# http://www.gnu.org/software/binutils
# http://developer.apple.com/releasenotes/DeveloperTools/GCC40PortingReleaseNotes/Articles/PortingToGCC.html
