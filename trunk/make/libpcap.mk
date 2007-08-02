###########################################################
#
# libpcap
#
###########################################################

# You must replace "libpcap" and "LIBPCAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPCAP_VERSION, LIBPCAP_SITE and LIBPCAP_SOURCE define
# the upstream location of the source code for the package.
# LIBPCAP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPCAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBPCAP_SITE=http://www.tcpdump.org/release
LIBPCAP_VERSION=0.9.6
LIBPCAP_SOURCE=libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_DIR=libpcap-$(LIBPCAP_VERSION)
LIBPCAP_UNZIP=zcat

#
# LIBPCAP_IPK_VERSION should be incremented when the ipk changes.
#
LIBPCAP_IPK_VERSION=1

#
# LIBPCAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBPCAP_PATCHES=$(LIBPCAP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPCAP_CPPFLAGS=
LIBPCAP_LDFLAGS=

#
# LIBPCAP_BUILD_DIR is the directory in which the build is done.
# LIBPCAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPCAP_IPK_DIR is the directory in which the ipk is built.
# LIBPCAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPCAP_BUILD_DIR=$(BUILD_DIR)/libpcap
LIBPCAP_SOURCE_DIR=$(SOURCE_DIR)/libpcap
LIBPCAP_IPK_DIR=$(BUILD_DIR)/libpcap-$(LIBPCAP_VERSION)-ipk
LIBPCAP_IPK=$(BUILD_DIR)/libpcap_$(LIBPCAP_VERSION)-$(LIBPCAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPCAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBPCAP_SITE)/$(LIBPCAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpcap-source: $(DL_DIR)/$(LIBPCAP_SOURCE) $(LIBPCAP_PATCHES)

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
$(LIBPCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPCAP_SOURCE) $(LIBPCAP_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBPCAP_DIR) $(LIBPCAP_BUILD_DIR)
	$(LIBPCAP_UNZIP) $(DL_DIR)/$(LIBPCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBPCAP_PATCHES) | patch -d $(BUILD_DIR)/$(LIBPCAP_DIR) -p1
	mv $(BUILD_DIR)/$(LIBPCAP_DIR) $(LIBPCAP_BUILD_DIR)
	(cd $(LIBPCAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPCAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-pcap=linux \
		--prefix=/opt \
		ac_cv_linux_vers=2.4.22 \
	)
	touch $(LIBPCAP_BUILD_DIR)/.configured

libpcap-unpack: $(LIBPCAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBPCAP_BUILD_DIR)/libpcap.a: $(LIBPCAP_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBPCAP_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libpcap: $(LIBPCAP_BUILD_DIR)/libpcap.a

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libpcap.a: $(LIBPCAP_BUILD_DIR)/libpcap.a
	$(MAKE) -C $(LIBPCAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install

libpcap-stage: $(STAGING_DIR)/opt/lib/libpcap.a

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPCAP_IPK_DIR)/opt/sbin or $(LIBPCAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPCAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBPCAP_IPK_DIR)/opt/etc/libpcap/...
# Documentation files should be installed in $(LIBPCAP_IPK_DIR)/opt/doc/libpcap/...
# Daemon startup scripts should be installed in $(LIBPCAP_IPK_DIR)/opt/etc/init.d/S??libpcap
#
# You may need to patch your application to make it use these locations.
#
$(LIBPCAP_IPK): $(LIBPCAP_BUILD_DIR)/libpcap.a

#
# This is called from the top level makefile to create the IPK file.
#
libpcap-ipk: $(LIBPCAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpcap-clean:
	-$(MAKE) -C $(LIBPCAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpcap-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPCAP_DIR) $(LIBPCAP_BUILD_DIR) $(LIBPCAP_IPK_DIR) $(LIBPCAP_IPK)
