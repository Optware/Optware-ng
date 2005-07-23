###########################################################
#
# crosstool-native
#
###########################################################

# CROSSTOOL-NATIVE_VERSION, CROSSTOOL-NATIVE_SITE and CROSSTOOL-NATIVE_SOURCE define
# the upstream location of the source code for the package.
# CROSSTOOL-NATIVE_DIR is the directory which is created when the source
# archive is unpacked.
# CROSSTOOL-NATIVE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CROSSTOOL-NATIVE_SITE=http://kegel.com/crosstool
CROSSTOOL-NATIVE_VERSION=0.28-rc37
CROSSTOOL-NATIVE_SOURCE=crosstool-$(CROSSTOOL-NATIVE_VERSION).tar.gz
CROSSTOOL-NATIVE_DIR=crosstool-$(CROSSTOOL-NATIVE_VERSION)
CROSSTOOL-NATIVE_UNZIP=zcat

CROSSTOOL-NATIVE_SCRIPT=nslu2-native335.sh
CROSSTOOL-NATIVE_DAT=gcc-3.3.5-glibc-2.2.5.dat

#
# CROSSTOOL-NATIVE_IPK_VERSION should be incremented when the ipk changes.
#
CROSSTOOL-NATIVE_IPK_VERSION=5

#
# CROSSTOOL-NATIVE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CROSSTOOL-NATIVE_PATCHES=$(CROSSTOOL-NATIVE_SOURCE_DIR)/all.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CROSSTOOL-NATIVE_CPPFLAGS=
CROSSTOOL-NATIVE_LDFLAGS=

CROSSTOOL-NATIVE_PREFIX=/opt/$(TARGET_ARCH)

#
# CROSSTOOL-NATIVE_BUILD_DIR is the directory in which the build is done.
# CROSSTOOL-NATIVE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CROSSTOOL-NATIVE_IPK_DIR is the directory in which the ipk is built.
# CROSSTOOL-NATIVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CROSSTOOL-NATIVE_BUILD_DIR=$(BUILD_DIR)/crosstool-native
CROSSTOOL-NATIVE_SOURCE_DIR=$(SOURCE_DIR)/crosstool-native
CROSSTOOL-NATIVE_IPK_DIR=$(BUILD_DIR)/crosstool-native-$(CROSSTOOL-NATIVE_VERSION)-ipk
CROSSTOOL-NATIVE_IPK=$(BUILD_DIR)/crosstool-native_$(CROSSTOOL-NATIVE_VERSION)-$(CROSSTOOL-NATIVE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
# $(DL_DIR)/$(CROSSTOOL-NATIVE_SOURCE):
# 	$(WGET) -P $(DL_DIR) $(CROSSTOOL-NATIVE_SITE)/$(CROSSTOOL-NATIVE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
crosstool-native-source: $(DL_DIR)/$(CROSSTOOL-NATIVE_SOURCE) $(CROSSTOOL-NATIVE_PATCHES)

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
$(CROSSTOOL-NATIVE_BUILD_DIR)/.configured: $(DL_DIR)/$(CROSSTOOL-NATIVE_SOURCE) $(CROSSTOOL-NATIVE_PATCHES)
	rm -rf $(BUILD_DIR)/$(CROSSTOOL-NATIVE_DIR) $(CROSSTOOL-NATIVE_BUILD_DIR)
	$(CROSSTOOL-NATIVE_UNZIP) $(DL_DIR)/$(CROSSTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CROSSTOOL-NATIVE_PATCHES) | patch -d $(BUILD_DIR)/$(CROSSTOOL-NATIVE_DIR) -p1
	mv $(BUILD_DIR)/$(CROSSTOOL-NATIVE_DIR) $(CROSSTOOL-NATIVE_BUILD_DIR)
	cp $(CROSSTOOL-NATIVE_SOURCE_DIR)/$(CROSSTOOL-NATIVE_SCRIPT) $(CROSSTOOL-NATIVE_BUILD_DIR)/$(CROSSTOOL-NATIVE_SCRIPT)
	cp $(CROSSTOOL-NATIVE_SOURCE_DIR)/*.dat    $(CROSSTOOL-NATIVE_BUILD_DIR)/$(CROSSTOOL-NATIVE_DAT)
	mkdir $(CROSSTOOL-NATIVE_BUILD_DIR)/patches/gcc-3.3.5
	cp $(CROSSTOOL-NATIVE_BUILD_DIR)/patches/gcc-3.3.4/gcc-3.3.4-arm-bigendian.patch $(CROSSTOOL-NATIVE_BUILD_DIR)/patches/gcc-3.3.5
	touch $(CROSSTOOL-NATIVE_BUILD_DIR)/.configured

crosstool-native-unpack: $(CROSSTOOL-NATIVE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CROSSTOOL-NATIVE_BUILD_DIR)/.built: $(CROSSTOOL-NATIVE_BUILD_DIR)/.configured
	rm -f $(CROSSTOOL-NATIVE_BUILD_DIR)/.built
	rm -rf $(CROSSTOOL-NATIVE_BUILD_DIR)$(CROSSTOOL-NATIVE_PREFIX)
	mkdir -p $(CROSSTOOL-NATIVE_BUILD_DIR)$(CROSSTOOL-NATIVE_PREFIX)
	$(SUDO) rm -rf $(CROSSTOOL-NATIVE_PREFIX)
	$(SUDO) mkdir -p `dirname $(CROSSTOOL-NATIVE_PREFIX)`
	$(SUDO) ln -s $(CROSSTOOL-NATIVE_BUILD_DIR)$(CROSSTOOL-NATIVE_PREFIX) \
		$(CROSSTOOL-NATIVE_PREFIX)
	( cd $(CROSSTOOL-NATIVE_BUILD_DIR) ; \
		export RESULT_TOP=/opt ; \
		export PREFIX=$(CROSSTOOL-NATIVE_PREFIX) ; \
		export PATH=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin:$(PATH) ; \
		export GCC_HOST=$(GNU_TARGET_NAME) ; \
                export AR=$(TARGET_CROSS)ar ; \
		export AS=$(TARGET_CROSS)as ; \
		export LD=$(TARGET_CROSS)ld ; \
		export NM=$(TARGET_CROSS)nm ; \
		export CC=$(TARGET_CROSS)gcc ; \
		export GCC=$(TARGET_CROSS)gcc ; \
		export CXX=$(TARGET_CROSS)g++ ; \
		export GPROF=$(TARGET_CROSS)gprof ; \
		export RANLIB=$(TARGET_CROSS)ranlib ; \
		sh $(CROSSTOOL-NATIVE_SCRIPT) \
	)
	touch $(CROSSTOOL-NATIVE_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
crosstool-native: $(CROSSTOOL-NATIVE_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(CROSSTOOL-NATIVE_IPK_DIR)/opt/sbin or $(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CROSSTOOL-NATIVE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CROSSTOOL-NATIVE_IPK_DIR)/opt/etc/crosstool-native/...
# Documentation files should be installed in $(CROSSTOOL-NATIVE_IPK_DIR)/opt/doc/crosstool-native/...
# Daemon startup scripts should be installed in $(CROSSTOOL-NATIVE_IPK_DIR)/opt/etc/init.d/S??crosstool-native
#
# You may need to patch your application to make it use these locations.
#
$(CROSSTOOL-NATIVE_IPK): $(CROSSTOOL-NATIVE_BUILD_DIR)/.built
	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)* $(BUILD_DIR)/crosstool-native*_$(TARGET_ARCH).ipk
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)
	( cd $(CROSSTOOL-NATIVE_PREFIX) ; tar cf - . ) | \
		( cd $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX) ; tar xvf - )
# For some reason, syslimits.h is missing; copy it from the toolchain
	install -m 644 $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/lib/gcc-lib/$(GNU_TARGET_NAME)/3.3.5/include/syslimits.h $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/lib/gcc-lib\/$(GNU_TARGET_NAME)/3.3.5/include/syslimits.h
# Install symlinks for common toolchain programs
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin
	for f in ar as c++ g++ gcc ld nm ranlib strip ; do \
	  rm -f $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-$$f ; \
	  ln -s $(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/bin/$$f \
		$(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-$$f ; \
	  ln -s $(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-$$f $(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin/$$f ; \
	done
	ln -s $(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-cpp  \
		$(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin/cpp
	ln -s $(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-size \
		$(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin/size
	rm -f $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/bin/g++
	ln -s ./c++ $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/bin/g++
# Package into bite-sized chunks
	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-bin
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-bin$(CROSSTOOL-NATIVE_PREFIX)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin $(CROSSTOOL-NATIVE_IPK_DIR)-bin$(CROSSTOOL-NATIVE_PREFIX)/bin
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-bin/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-bin $(CROSSTOOL-NATIVE_IPK_DIR)-bin/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-bin

	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-lib
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-lib$(CROSSTOOL-NATIVE_PREFIX)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/lib $(CROSSTOOL-NATIVE_IPK_DIR)-lib$(CROSSTOOL-NATIVE_PREFIX)/lib
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/libexec $(CROSSTOOL-NATIVE_IPK_DIR)-lib$(CROSSTOOL-NATIVE_PREFIX)/libexec
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-lib/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-lib $(CROSSTOOL-NATIVE_IPK_DIR)-lib/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-lib

	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-inc
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-inc$(CROSSTOOL-NATIVE_PREFIX)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/include $(CROSSTOOL-NATIVE_IPK_DIR)-inc$(CROSSTOOL-NATIVE_PREFIX)/include
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/info $(CROSSTOOL-NATIVE_IPK_DIR)-inc$(CROSSTOOL-NATIVE_PREFIX)/info
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/man $(CROSSTOOL-NATIVE_IPK_DIR)-inc$(CROSSTOOL-NATIVE_PREFIX)/man
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/tmp $(CROSSTOOL-NATIVE_IPK_DIR)-inc$(CROSSTOOL-NATIVE_PREFIX)/tmp
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-inc/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-inc $(CROSSTOOL-NATIVE_IPK_DIR)-inc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-inc

	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/bin $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/bin
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/sbin $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/sbin
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-arch-bin $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-arch-bin

	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/lib $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/lib
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/libexec $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/libexec
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-arch-lib $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-arch-lib

	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/include $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/include
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/sys-include $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/sys-include
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/etc $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/etc
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/info $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/info
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/share $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/share
	mv $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/usr $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc$(CROSSTOOL-NATIVE_PREFIX)/$(GNU_TARGET_NAME)/usr
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control-arch-inc $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)-arch-inc
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)/CONTROL
	install -m 644 $(CROSSTOOL-NATIVE_SOURCE_DIR)/control $(CROSSTOOL-NATIVE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CROSSTOOL-NATIVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
crosstool-native-ipk: $(CROSSTOOL-NATIVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
crosstool-native-clean:
	-$(MAKE) -C $(CROSSTOOL-NATIVE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
crosstool-native-dirclean:
	rm -rf $(BUILD_DIR)/$(CROSSTOOL-NATIVE_DIR) $(CROSSTOOL-NATIVE_BUILD_DIR) $(CROSSTOOL-NATIVE_IPK_DIR)* $(CROSSTOOL-NATIVE_IPK)
