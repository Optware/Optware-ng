###########################################################
#
# crosstool
#
###########################################################

# CROSSTOOL_VERSION, CROSSTOOL_SITE and CROSSTOOL_SOURCE define
# the upstream location of the source code for the package.
# CROSSTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# CROSSTOOL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CROSSTOOL_SITE=http://kegel.com/crosstool
CROSSTOOL_VERSION=0.38
CROSSTOOL_SOURCE=crosstool-$(CROSSTOOL_VERSION).tar.gz
CROSSTOOL_DIR=crosstool-$(CROSSTOOL_VERSION)
CROSSTOOL_UNZIP=zcat

ifeq ($(OPTWARE_TARGET),fsg3)
CROSSTOOL_SCRIPT = fsg3-cross332.sh
else
ifeq ($(OPTWARE_TARGET),ds101)
CROSSTOOL_SCRIPT = ds101-cross344.sh
else
ifeq ($(OPTWARE_TARGET),ds101g)
CROSSTOOL_SCRIPT = ds101g-cross334.sh
else
CROSSTOOL_SCRIPT = nslu2-cross335.sh
endif
endif
endif

#
# CROSSTOOL_IPK_VERSION should be incremented when the ipk changes.
#
CROSSTOOL_IPK_VERSION=1

#
# CROSSTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# CROSSTOOL_PATCHES=$(CROSSTOOL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CROSSTOOL_CPPFLAGS=
CROSSTOOL_LDFLAGS=

#
# CROSSTOOL_BUILD_DIR is the directory in which the build is done.
# CROSSTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CROSSTOOL_IPK_DIR is the directory in which the ipk is built.
# CROSSTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CROSSTOOL_BUILD_DIR=$(TOOL_BUILD_DIR)/crosstool
CROSSTOOL_SOURCE_DIR=$(SOURCE_DIR)/crosstool
CROSSTOOL_IPK_DIR=$(BUILD_DIR)/crosstool-$(CROSSTOOL_VERSION)-ipk
CROSSTOOL_IPK=$(BUILD_DIR)/crosstool_$(CROSSTOOL_VERSION)-$(CROSSTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CROSSTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(CROSSTOOL_SITE)/$(CROSSTOOL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
crosstool-source: $(DL_DIR)/$(CROSSTOOL_SOURCE) $(CROSSTOOL_PATCHES)

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
$(CROSSTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(CROSSTOOL_SOURCE) $(CROSSTOOL_PATCHES)
	rm -rf $(TOOL_BUILD_DIR)/$(CROSSTOOL_DIR) $(CROSSTOOL_BUILD_DIR)
	$(CROSSTOOL_UNZIP) $(DL_DIR)/$(CROSSTOOL_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
#	cat $(CROSSTOOL_PATCHES) | patch -d $(TOOL_BUILD_DIR)/$(CROSSTOOL_DIR) -p1
	mv $(TOOL_BUILD_DIR)/$(CROSSTOOL_DIR) $(CROSSTOOL_BUILD_DIR)
	cp $(CROSSTOOL_SOURCE_DIR)/$(CROSSTOOL_SCRIPT) $(CROSSTOOL_BUILD_DIR)/$(CROSSTOOL_SCRIPT)
	cp $(CROSSTOOL_SOURCE_DIR)/*.dat $(CROSSTOOL_BUILD_DIR)
	cp $(CROSSTOOL_SOURCE_DIR)/powerpc-603e.config $(CROSSTOOL_BUILD_DIR)
	mkdir -p $(CROSSTOOL_BUILD_DIR)/patches/$(CROSS_CONFIGURATION_GCC)
	# gcc 4.1.1 patch: https://trac.nslu2-linux.org/optware/ticket/1
	sed -i '/+/s/4.0\*/4.0\*\|4.1\*/' $(CROSSTOOL_BUILD_DIR)/patches/glibc-2.2.5/glibc-2.2.5-allow-gcc-4.0-configure.patch
	# these patches are required for gcc-3.3.5 to work with optware/unslung
	cp $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.4.3/fix-fixincl.patch $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.3.5
	cp $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.4.3/fix-fixincl.patch $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.3.4
	cp $(CROSSTOOL_BUILD_DIR)/patches/glibc-2.3.2/glibc-2.3.2-arm-fix-strlen.patch $(CROSSTOOL_BUILD_DIR)/patches/glibc-2.2.5
	cp $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.3.4/gcc-3.3.4-arm-bigendian.patch $(CROSSTOOL_BUILD_DIR)/patches/gcc-3.3.5
	touch $(CROSSTOOL_BUILD_DIR)/.configured

crosstool-unpack: $(CROSSTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CROSSTOOL_BUILD_DIR)/.built: $(CROSSTOOL_BUILD_DIR)/.configured
	rm -f $(CROSSTOOL_BUILD_DIR)/.built
	( cd $(CROSSTOOL_BUILD_DIR) ; \
		export RESULT_TOP=$(TOOL_BUILD_DIR) ; \
		export PREFIX=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION) ; \
		sh $(CROSSTOOL_SCRIPT) \
	)
	rm -f $(TARGET_LIBDIR)/*.la
	touch $(CROSSTOOL_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
crosstool: $(CROSSTOOL_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all of the built files.
#
crosstool-clean:
	-$(MAKE) -C $(CROSSTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
crosstool-dirclean:
	rm -rf $(TOOL_BUILD_DIR)/$(CROSSTOOL_DIR) $(CROSSTOOL_BUILD_DIR) $(CROSSTOOL_IPK_DIR) $(CROSSTOOL_IPK)
