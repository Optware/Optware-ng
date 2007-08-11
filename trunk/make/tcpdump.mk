###########################################################
#
# tcpdump
#
###########################################################

# You must replace "tcpdump" and "TCPDUMP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TCPDUMP_VERSION, TCPDUMP_SITE and TCPDUMP_SOURCE define
# the upstream location of the source code for the package.
# TCPDUMP_DIR is the directory which is created when the source
# archive is unpacked.
# TCPDUMP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TCPDUMP_SITE=http://www.tcpdump.org/release
TCPDUMP_VERSION=3.9.7
TCPDUMP_SOURCE=tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_DIR=tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_UNZIP=zcat

#
# TCPDUMP_IPK_VERSION should be incremented when the ipk changes.
#
TCPDUMP_IPK_VERSION=1

#
# TCPDUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TCPDUMP_PATCHES=$(TCPDUMP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TCPDUMP_CPPFLAGS=
TCPDUMP_LDFLAGS=

#
# TCPDUMP_BUILD_DIR is the directory in which the build is done.
# TCPDUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TCPDUMP_IPK_DIR is the directory in which the ipk is built.
# TCPDUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TCPDUMP_BUILD_DIR=$(BUILD_DIR)/tcpdump
TCPDUMP_SOURCE_DIR=$(SOURCE_DIR)/tcpdump
TCPDUMP_IPK_DIR=$(BUILD_DIR)/tcpdump-$(TCPDUMP_VERSION)-ipk
TCPDUMP_IPK=$(BUILD_DIR)/tcpdump_$(TCPDUMP_VERSION)-$(TCPDUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TCPDUMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCPDUMP_SITE)/$(TCPDUMP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tcpdump-source: $(DL_DIR)/$(TCPDUMP_SOURCE) $(TCPDUMP_PATCHES)

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
$(TCPDUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(TCPDUMP_SOURCE) $(TCPDUMP_PATCHES)
	$(MAKE) libpcap-stage libpcap-stage
	rm -rf $(BUILD_DIR)/$(TCPDUMP_DIR) $(TCPDUMP_BUILD_DIR)
	$(TCPDUMP_UNZIP) $(DL_DIR)/$(TCPDUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(TCPDUMP_PATCHES) | patch -d $(BUILD_DIR)/$(TCPDUMP_DIR) -p1
	mv $(BUILD_DIR)/$(TCPDUMP_DIR) $(TCPDUMP_BUILD_DIR)
	(cd $(TCPDUMP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TCPDUMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TCPDUMP_LDFLAGS)" \
		ac_cv_linux_vers=2 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-smb \
		--without-crypto \
	)
	touch $(TCPDUMP_BUILD_DIR)/.configured

tcpdump-unpack: $(TCPDUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(TCPDUMP_BUILD_DIR)/tcpdump: $(TCPDUMP_BUILD_DIR)/.configured
	$(MAKE) -C $(TCPDUMP_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
tcpdump: $(TCPDUMP_BUILD_DIR)/tcpdump

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libtcpdump.so.$(TCPDUMP_VERSION): $(TCPDUMP_BUILD_DIR)/libtcpdump.so.$(TCPDUMP_VERSION)
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(TCPDUMP_BUILD_DIR)/tcpdump.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(TCPDUMP_BUILD_DIR)/libtcpdump.a $(STAGING_DIR)/opt/lib
	install -m 644 $(TCPDUMP_BUILD_DIR)/libtcpdump.so.$(TCPDUMP_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libtcpdump.so.$(TCPDUMP_VERSION) libtcpdump.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libtcpdump.so.$(TCPDUMP_VERSION) libtcpdump.so

tcpdump-stage: $(STAGING_DIR)/opt/lib/libtcpdump.so.$(TCPDUMP_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(TCPDUMP_IPK_DIR)/opt/sbin or $(TCPDUMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TCPDUMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TCPDUMP_IPK_DIR)/opt/etc/tcpdump/...
# Documentation files should be installed in $(TCPDUMP_IPK_DIR)/opt/doc/tcpdump/...
# Daemon startup scripts should be installed in $(TCPDUMP_IPK_DIR)/opt/etc/init.d/S??tcpdump
#
# You may need to patch your application to make it use these locations.
#
$(TCPDUMP_IPK): $(TCPDUMP_BUILD_DIR)/tcpdump
	rm -rf $(TCPDUMP_IPK_DIR) $(TCPDUMP_IPK)
	install -d $(TCPDUMP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TCPDUMP_BUILD_DIR)/tcpdump -o $(TCPDUMP_IPK_DIR)/opt/bin/tcpdump
	install -d $(TCPDUMP_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(TCPDUMP_VERSION)/" \
		-e "s/@RELEASE@/$(TCPDUMP_IPK_VERSION)/" $(TCPDUMP_SOURCE_DIR)/control > $(TCPDUMP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCPDUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tcpdump-ipk: $(TCPDUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tcpdump-dirclean:
	rm -rf $(BUILD_DIR)/$(TCPDUMP_DIR) $(TCPDUMP_BUILD_DIR) $(TCPDUMP_IPK_DIR) $(TCPDUMP_IPK)

#
# Some sanity check for the package.
#
tcpdump-check: $(TCPDUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TCPDUMP_IPK)
