###########################################################
#
# libuclibc++
#
###########################################################
#
# LIBUCLIBC++_VERSION, LIBUCLIBC++_SITE and LIBUCLIBC++_SOURCE define
# the upstream location of the source code for the package.
# LIBUCLIBC++_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUCLIBC++_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
# Primary use of this library is to replace libstdc++ on
# systems with uclibc library - On wl500g libstdc++ is
# wrapped with this library.
#
# make libuclibc++-stage will install g++ wrapper in toolchain
#
# Currently configured for mipsel architecture only
# TODO: wrapper patch cleanup for ccache
#
ifeq ($(OPTWARE_TARGET), wl500g)
LIBUCLIBC++_VERSION=0.1.12
LIBUCLIBC++_SITE=http://cxx.uclibc.org/src
LIBUCLIBC++_SOURCE=uClibc++-$(LIBUCLIBC++_VERSION).tbz2
else
LIBUCLIBC++_VERSION=0.2.2
LIBUCLIBC++_SVN=svn://uclibc.org/trunk/uClibc++
LIBUCLIBC++_SVN_REV=18737
LIBUCLIBC++_SOURCE=uClibc++-$(LIBUCLIBC++_VERSION)+r$(LIBUCLIBC++_SVN_REV).tbz2
endif
LIBUCLIBC++_DIR=uClibc++
LIBUCLIBC++_UNZIP=bzcat
LIBUCLIBC++_MAINTAINER=Leon Kos <oleo@email.si>
LIBUCLIBC++_DESCRIPTION=C++ standard library designed for use in embedded systems
LIBUCLIBC++_SECTION=libs
LIBUCLIBC++_PRIORITY=required
LIBUCLIBC++_DEPENDS=
LIBUCLIBC++_SUGGESTS=
LIBUCLIBC++_CONFLICTS=

#
# LIBUCLIBC++_IPK_VERSION should be incremented when the ipk changes.
#
LIBUCLIBC++_IPK_VERSION=6

#
# LIBUCLIBC++_CONFFILES should be a list of user-editable files
#LIBUCLIBC++_CONFFILES=/opt/etc/libuclibc++.conf /opt/etc/init.d/SXXlibuclibc++

#
# LIBUCLIBC++_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUCLIBC++_PATCHES= $(LIBUCLIBC++_SOURCE_DIR)/bin-Makefile.patch 

ifeq ($(OPTWARE_TARGET), wl500g)
LIBUCLIBC++_PATCHES +=	$(LIBUCLIBC++_SOURCE_DIR)/abi.cpp.patch \
	$(LIBUCLIBC++_SOURCE_DIR)/math.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUCLIBC++_CPPFLAGS=
LIBUCLIBC++_LDFLAGS=

#
# LIBUCLIBC++_BUILD_DIR is the directory in which the build is done.
# LIBUCLIBC++_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUCLIBC++_IPK_DIR is the directory in which the ipk is built.
# LIBUCLIBC++_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUCLIBC++_BUILD_DIR=$(BUILD_DIR)/libuclibc++
LIBUCLIBC++_SOURCE_DIR=$(SOURCE_DIR)/libuclibc++
LIBUCLIBC++_IPK_DIR=$(BUILD_DIR)/libuclibc++-$(LIBUCLIBC++_VERSION)-ipk
LIBUCLIBC++_IPK=$(BUILD_DIR)/libuclibc++_$(LIBUCLIBC++_VERSION)-$(LIBUCLIBC++_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libuclibc++-source libuclibc++-unpack libuclibc++ libuclibc++-stage libuclibc++-ipk libuclibc++-clean libuclibc++-dirclean libuclibc++-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.

ifeq ($(OPTWARE_TARGET), wl500g)
$(DL_DIR)/$(LIBUCLIBC++_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBUCLIBC++_SITE)/$(LIBUCLIBC++_SOURCE)
else
$(DL_DIR)/$(LIBUCLIBC++_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(LIBUCLIBC++_DIR) && \
		svn co -r $(LIBUCLIBC++_SVN_REV) $(LIBUCLIBC++_SVN) && \
		tar -cjf $@ $(LIBUCLIBC++_DIR) && \
		rm -rf $(LIBUCLIBC++_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libuclibc++-source: $(DL_DIR)/$(LIBUCLIBC++_SOURCE) $(DL_DIR)/$(LIBUCLIBC++_SOURCE_WL500G) $(LIBUCLIBC++_PATCHES)

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
$(LIBUCLIBC++_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUCLIBC++_SOURCE) $(LIBUCLIBC++_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUCLIBC++_DIR) $(LIBUCLIBC++_BUILD_DIR)
	$(LIBUCLIBC++_UNZIP) $(DL_DIR)/$(LIBUCLIBC++_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUCLIBC++_PATCHES)" ; \
		then cat $(LIBUCLIBC++_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBUCLIBC++_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUCLIBC++_DIR)" != "$(LIBUCLIBC++_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBUCLIBC++_DIR) $(LIBUCLIBC++_BUILD_DIR) ; \
	fi
	cp $(LIBUCLIBC++_SOURCE_DIR)/.config $(LIBUCLIBC++_BUILD_DIR)
ifneq ($(OPTWARE_TARGET),wl500g)
	sed -i -e 's|mipsel-uclibc|$(TARGET_ARCH)-$(TARGET_OS)|g' \
		$(LIBUCLIBC++_BUILD_DIR)/bin/Makefile
	sed -i -e 's|^# IMPORT_LIBSUP is not set|IMPORT_LIBSUP=y|' \
		$(LIBUCLIBC++_BUILD_DIR)/.config
endif
	make -C $(LIBUCLIBC++_BUILD_DIR) oldconfig
	touch $(LIBUCLIBC++_BUILD_DIR)/.configured

libuclibc++-unpack: $(LIBUCLIBC++_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUCLIBC++_BUILD_DIR)/.built: $(LIBUCLIBC++_BUILD_DIR)/.configured
	rm -f $(LIBUCLIBC++_BUILD_DIR)/.built
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) CROSS=$(TARGET_CROSS)
	touch $(LIBUCLIBC++_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libuclibc++: $(LIBUCLIBC++_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
LIBUCLIBC++_INSTALL_DIR=$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)
ifeq ($(OPTWARE_TARGET), openwrt-brcm24)
$(LIBUCLIBC++_BUILD_DIR)/.staged: $(LIBUCLIBC++_BUILD_DIR)/.built \
  $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/.staged
else
$(LIBUCLIBC++_BUILD_DIR)/.staged: $(LIBUCLIBC++_BUILD_DIR)/.built \
	$(BUILDROOT_BUILD_DIR)/.staged
endif
	rm -f $(LIBUCLIBC++_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) \
		DESTDIR=$(LIBUCLIBC++_INSTALL_DIR)/uClibc++ install
	if test ! -d $(LIBUCLIBC++_INSTALL_DIR)/nowrap ; then \
		install -d $(LIBUCLIBC++_INSTALL_DIR)/nowrap ; \
		mv $(TARGET_CXX) $(LIBUCLIBC++_INSTALL_DIR)/nowrap/ ; \
	fi
	sed -i -e 's|/bin/bash|/bin/sh|;s/==/=/g' \
	  -e 's|^WRAPPER_INCLUDEDIR=.*|WRAPPER_INCLUDEDIR=-I$(LIBUCLIBC++_INSTALL_DIR)/uClibc++/include|' \
	  -e 's|^WRAPPER_LIBDIR=.*|WRAPPER_LIBDIR=-L$(LIBUCLIBC++_INSTALL_DIR)/uClibc++/lib|' \
	  -e 's|$(CROSS_CONFIGURATION)/bin|$(CROSS_CONFIGURATION)/nowrap|' \
	   $(LIBUCLIBC++_INSTALL_DIR)/uClibc++/bin/g++-uc
	mv $(LIBUCLIBC++_INSTALL_DIR)/uClibc++/bin/g++-uc $(TARGET_CXX)
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR)/src DESTDIR=$(STAGING_PREFIX) install
	touch $(LIBUCLIBC++_BUILD_DIR)/.staged

libuclibc++-stage: $(LIBUCLIBC++_BUILD_DIR)/.staged
#
# toolchain requires staged lib
# 
libuclibc++-toolchain: $(LIBUCLIBC++_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libuclibc++
#
$(LIBUCLIBC++_IPK_DIR)/CONTROL/control:
	@install -d $(LIBUCLIBC++_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libuclibc++" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUCLIBC++_PRIORITY)" >>$@
	@echo "Section: $(LIBUCLIBC++_SECTION)" >>$@
	@echo "Version: $(LIBUCLIBC++_VERSION)-$(LIBUCLIBC++_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUCLIBC++_MAINTAINER)" >>$@
	@echo "Source: $(LIBUCLIBC++_SITE)/$(LIBUCLIBC++_SOURCE)" >>$@
	@echo "Description: $(LIBUCLIBC++_DESCRIPTION)" >>$@
	@echo "Provides: libstdc++" >>$@
	@echo "Depends: $(LIBUCLIBC++_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUCLIBC++_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUCLIBC++_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUCLIBC++_IPK_DIR)/opt/sbin or $(LIBUCLIBC++_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUCLIBC++_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBUCLIBC++_IPK_DIR)/opt/etc/libuclibc++/...
# Documentation files should be installed in $(LIBUCLIBC++_IPK_DIR)/opt/doc/libuclibc++/...
# Daemon startup scripts should be installed in $(LIBUCLIBC++_IPK_DIR)/opt/etc/init.d/S??libuclibc++
#
# You may need to patch your application to make it use these locations.
#
$(LIBUCLIBC++_IPK): $(LIBUCLIBC++_BUILD_DIR)/.built
	rm -rf $(LIBUCLIBC++_IPK_DIR) $(BUILD_DIR)/libuclibc++_*_$(TARGET_ARCH).ipk
	install -d $(LIBUCLIBC++_IPK_DIR)/opt
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR)/src DESTDIR=$(LIBUCLIBC++_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(LIBUCLIBC++_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(LIBUCLIBC++_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBUCLIBC++_SOURCE_DIR)/postinst $(LIBUCLIBC++_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBUCLIBC++_SOURCE_DIR)/prerm $(LIBUCLIBC++_IPK_DIR)/CONTROL/prerm
#	echo $(LIBUCLIBC++_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUCLIBC++_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUCLIBC++_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libuclibc++-ipk: $(LIBUCLIBC++_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libuclibc++-clean:
	rm -f $(LIBUCLIBC++_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libuclibc++-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUCLIBC++_DIR) $(LIBUCLIBC++_BUILD_DIR) $(LIBUCLIBC++_IPK_DIR) $(LIBUCLIBC++_IPK)
#
#
# Toolchain instalation and deinstalation for wl500g only
#
libuclibc++-install:
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) DESTDIR=/opt/brcm/$(CROSS_CONFIGURATION) install	

libuclibc++-deinstall:
	ln -sf mipsel-uclibc-gcc $(TARGET_CROSS)g++
#
#
# Some sanity check for the package.
#
libuclibc++-check: $(LIBUCLIBC++_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBUCLIBC++_IPK)
