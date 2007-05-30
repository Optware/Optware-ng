###########################################################
#
# strace
#
###########################################################

# You must replace "strace" and "STRACE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# STRACE_VERSION, STRACE_SITE and STRACE_SOURCE define
# the upstream location of the source code for the package.
# STRACE_DIR is the directory which is created when the source
# archive is unpacked.
# STRACE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
STRACE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/strace/
STRACE_VERSION=4.5.14
STRACE_SOURCE=strace-$(STRACE_VERSION).tar.bz2
STRACE_DIR=strace-$(STRACE_VERSION)
STRACE_UNZIP=bzcat

#
# STRACE_IPK_VERSION should be incremented when the ipk changes.
#
STRACE_IPK_VERSION=5

#
# STRACE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#
ifeq ($(TARGET_ARCH), armeb)
#http://www.fluff.org/ben/patches/strace/strace-fix-arm-bad-syscall.patch
STRACE_PATCHES=$(STRACE_SOURCE_DIR)/strace-fix-arm-bad-syscall.patch
else
STRACE_PATCHES=
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STRACE_CPPFLAGS=
STRACE_LDFLAGS=

#
# STRACE_BUILD_DIR is the directory in which the build is done.
# STRACE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STRACE_IPK_DIR is the directory in which the ipk is built.
# STRACE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STRACE_BUILD_DIR=$(BUILD_DIR)/strace
STRACE_SOURCE_DIR=$(SOURCE_DIR)/strace
STRACE_IPK_DIR=$(BUILD_DIR)/strace-$(STRACE_VERSION)-ipk
STRACE_IPK=$(BUILD_DIR)/strace_$(STRACE_VERSION)-$(STRACE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STRACE_SOURCE):
	$(WGET) -P $(DL_DIR) $(STRACE_SITE)/$(STRACE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
strace-source: $(DL_DIR)/$(STRACE_SOURCE) $(STRACE_PATCHES)

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
$(STRACE_BUILD_DIR)/.configured: $(DL_DIR)/$(STRACE_SOURCE) $(STRACE_PATCHES)
	rm -rf $(BUILD_DIR)/$(STRACE_DIR) $(STRACE_BUILD_DIR)
	$(STRACE_UNZIP) $(DL_DIR)/$(STRACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(STRACE_PATCHES)" ; \
                then cat $(STRACE_PATCHES) | \
                patch -d $(BUILD_DIR)/$(STRACE_DIR) -p1 ; \
        fi
	mv $(BUILD_DIR)/$(STRACE_DIR) $(STRACE_BUILD_DIR)
ifeq ($(OPTWARE_TARGET), $(filter gumstix1151 slugosbe, $(OPTWARE_TARGET)))
	sed -i -e '/CTL_PROC/d' $(STRACE_BUILD_DIR)/system.c
endif
	(cd $(STRACE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STRACE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STRACE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(STRACE_BUILD_DIR)/.configured

strace-unpack: $(STRACE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(STRACE_BUILD_DIR)/strace: $(STRACE_BUILD_DIR)/.configured
	$(MAKE) -C $(STRACE_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
strace: $(STRACE_BUILD_DIR)/strace

#
# If you are building a library, then you need to stage it too.
#


#
# This builds the IPK file.
#
# Binaries should be installed into $(STRACE_IPK_DIR)/opt/sbin or $(STRACE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STRACE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STRACE_IPK_DIR)/opt/etc/strace/...
# Documentation files should be installed in $(STRACE_IPK_DIR)/opt/doc/strace/...
# Daemon startup scripts should be installed in $(STRACE_IPK_DIR)/opt/etc/init.d/S??strace
#
# You may need to patch your application to make it use these locations.
#
$(STRACE_IPK): $(STRACE_BUILD_DIR)/strace
	rm -rf $(STRACE_IPK_DIR) $(STRACE_IPK)
	install -d $(STRACE_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(STRACE_BUILD_DIR)/strace -o $(STRACE_IPK_DIR)/opt/bin/strace
	install -d $(STRACE_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(STRACE_VERSION)/" \
		-e "s/@RELEASE@/$(STRACE_IPK_VERSION)/"	$(STRACE_SOURCE_DIR)/control > $(STRACE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STRACE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
strace-ipk: $(STRACE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
strace-clean:
	-$(MAKE) -C $(STRACE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
strace-dirclean:
	rm -rf $(BUILD_DIR)/$(STRACE_DIR) $(STRACE_BUILD_DIR) $(STRACE_IPK_DIR) $(STRACE_IPK)

#
# Some sanity check for the package.
#
strace-check: $(STRACE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(STRACE_IPK)
