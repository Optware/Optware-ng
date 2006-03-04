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
LIBUCLIBC++_SITE=http://cxx.uclibc.org/src
LIBUCLIBC++_VERSION=0.1.12
LIBUCLIBC++_SOURCE=uClibc++-$(LIBUCLIBC++_VERSION).tbz2
LIBUCLIBC++_DIR=uClibc++
LIBUCLIBC++_UNZIP=bzcat
LIBUCLIBC++_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUCLIBC++_DESCRIPTION=C++ standard library designed for use in embedded systems
LIBUCLIBC++_SECTION=libs
LIBUCLIBC++_PRIORITY=required
LIBUCLIBC++_DEPENDS=
LIBUCLIBC++_SUGGESTS=
LIBUCLIBC++_CONFLICTS=

#
# LIBUCLIBC++_IPK_VERSION should be incremented when the ipk changes.
#
LIBUCLIBC++_IPK_VERSION=3

#
# LIBUCLIBC++_CONFFILES should be a list of user-editable files
#LIBUCLIBC++_CONFFILES=/opt/etc/libuclibc++.conf /opt/etc/init.d/SXXlibuclibc++

#
# LIBUCLIBC++_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUCLIBC++_PATCHES=$(LIBUCLIBC++_SOURCE_DIR)/math.patch \
			$(LIBUCLIBC++_SOURCE_DIR)/wrapper.patch \
			$(LIBUCLIBC++_SOURCE_DIR)/abi.cpp.patch

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

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUCLIBC++_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBUCLIBC++_SITE)/$(LIBUCLIBC++_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libuclibc++-source: $(DL_DIR)/$(LIBUCLIBC++_SOURCE) $(LIBUCLIBC++_PATCHES)

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
$(LIBUCLIBC++_BUILD_DIR)/.staged: $(LIBUCLIBC++_BUILD_DIR)/.built
	rm -f $(LIBUCLIBC++_BUILD_DIR)/.staged
#	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) DESTDIR=/opt/brcm/$(CROSS_CONFIGURATION) install
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
#	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) DESTDIR=$(LIBUCLIBC++_IPK_DIR) install-strip
	install -d $(LIBUCLIBC++_IPK_DIR)/opt/lib
	install -m 755 $(LIBUCLIBC++_BUILD_DIR)/src/libuClibc++-0.1.12.so \
		$(LIBUCLIBC++_IPK_DIR)/opt/lib
	cp -fa $(LIBUCLIBC++_BUILD_DIR)/src/libuClibc++.so.0 \
		$(LIBUCLIBC++_BUILD_DIR)/src/libuClibc++.so \
		$(LIBUCLIBC++_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(LIBUCLIBC++_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(LIBUCLIBC++_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBUCLIBC++_SOURCE_DIR)/postinst $(LIBUCLIBC++_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBUCLIBC++_SOURCE_DIR)/prerm $(LIBUCLIBC++_IPK_DIR)/CONTROL/prerm
#	echo $(LIBUCLIBC++_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUCLIBC++_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUCLIBC++_IPK_DIR)

#        install -d $(LIBSTDC++_IPK_DIR)/opt/lib
#        install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_IPK_DIR)/opt/lib
#	(cd $(LIBSTDC++_IPK_DIR)/opt/lib; \
#	ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
#	$(LIBSTDC++_LIBNAME); \
#	ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
#		$(LIBSTDC++_LIBNAME).5 \
#	)
#	$(STRIP_COMMAND) $(LIBSTDC++_IPK_DIR)/opt/lib/*.so
#	$(MAKE) $(LIBSTDC++_IPK_DIR)/CONTROL/control
#	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSTDC++_IPK_DIR)

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
# Toolchain instalation and deinstalation
#
libuclibc++-install:
	$(MAKE) -C $(LIBUCLIBC++_BUILD_DIR) DESTDIR=/opt/brcm/$(CROSS_CONFIGURATION) install	

libuclibc++-deinstall:
	ln -sf mipsel-uclibc-gcc $(TARGET_CROSS)g++
