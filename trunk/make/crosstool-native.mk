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
CROSSTOOL-NATIVE_VERSION=0.28-rc35
CROSSTOOL-NATIVE_SOURCE=crosstool-$(CROSSTOOL-NATIVE_VERSION).tar.gz
CROSSTOOL-NATIVE_DIR=crosstool-$(CROSSTOOL-NATIVE_VERSION)
CROSSTOOL-NATIVE_UNZIP=zcat

#
# CROSSTOOL-NATIVE_IPK_VERSION should be incremented when the ipk changes.
#
CROSSTOOL-NATIVE_IPK_VERSION=2

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

CROSSTOOL-NATIVE_PREFIX=/opt/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)

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
CROSSTOOL-NATIVE_IPK=$(BUILD_DIR)/crosstool-native_$(CROSSTOOL-NATIVE_VERSION)-$(CROSSTOOL-NATIVE_IPK_VERSION)_armeb.ipk

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
	cp $(CROSSTOOL-NATIVE_SOURCE_DIR)/demo-nslu2.sh $(CROSSTOOL-NATIVE_BUILD_DIR)/demo-nslu2.sh
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
	$(SUDO)	mkdir -p /opt/$(GNU_TARGET_NAME)
	$(SUDO) ln -s $(CROSSTOOL-NATIVE_BUILD_DIR)$(CROSSTOOL-NATIVE_PREFIX) \
		$(CROSSTOOL-NATIVE_PREFIX)
	( cd $(CROSSTOOL-NATIVE_BUILD_DIR) ; \
		export RESULT_TOP=/opt ; \
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
		sh demo-nslu2.sh \
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
	rm -rf $(CROSSTOOL-NATIVE_IPK_DIR) $(BUILD_DIR)/crosstool-native_*_armeb.ipk
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)
	( cd $(CROSSTOOL-NATIVE_PREFIX) ; tar cf - . ) | \
		( cd $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX) ; tar xvf - )
# For some reason, syslimits.h is missing
	touch $(CROSSTOOL-NATIVE_IPK_DIR)/opt/lib/gcc-lib/$(GNU_TARGET_NAME)/3.3.4/include/syslimits.h
	chmod 644 $(CROSSTOOL-NATIVE_IPK_DIR)/opt/lib/gcc-lib/$(GNU_TARGET_NAME)/3.3.4/include/syslimits.h
# /lib/cpp is usually required
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)/lib
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-cpp /lib/cpp
# Install symlinks for common toolchain programs
	install -d $(CROSSTOOL-NATIVE_IPK_DIR)/opt/bin
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-ar /opt/bin/ar
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-as /opt/bin/as
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-c++ /opt/bin/c++
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-cpp /opt/bin/cpp
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-g++ /opt/bin/g++
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-gcc /opt/bin/gcc
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-ld /opt/bin/ld
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-nm /opt/bin/nm
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-ranlib /opt/bin/ranlib
	ln -s $(CROSSTOOL-NATIVE_IPK_DIR)$(CROSSTOOL-NATIVE_PREFIX)/bin/$(GNU_TARGET_NAME)-strip /opt/bin/strip
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
	rm -rf $(BUILD_DIR)/$(CROSSTOOL-NATIVE_DIR) $(CROSSTOOL-NATIVE_BUILD_DIR) $(CROSSTOOL-NATIVE_IPK_DIR) $(CROSSTOOL-NATIVE_IPK)
