###########################################################
#
# nmap
#
###########################################################

# You must replace "nmap" and "NMAP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NMAP_VERSION, NMAP_SITE and NMAP_SOURCE define
# the upstream location of the source code for the package.
# NMAP_DIR is the directory which is created when the source
# archive is unpacked.
# NMAP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NMAP_SITE=http://download.insecure.org/nmap/dist
NMAP_VERSION=3.75
NMAP_SOURCE=nmap-$(NMAP_VERSION).tar.bz2
NMAP_DIR=nmap-$(NMAP_VERSION)
NMAP_UNZIP=bzcat

#
# NMAP_IPK_VERSION should be incremented when the ipk changes.
#
NMAP_IPK_VERSION=1

#
# NMAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NMAP_PATCHES=$(NMAP_SOURCE_DIR)/chartables.c.patch \
		$(NMAP_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NMAP_CPPFLAGS=
NMAP_LDFLAGS=

#
# NMAP_BUILD_DIR is the directory in which the build is done.
# NMAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NMAP_IPK_DIR is the directory in which the ipk is built.
# NMAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NMAP_BUILD_DIR=$(BUILD_DIR)/nmap
NMAP_SOURCE_DIR=$(SOURCE_DIR)/nmap
NMAP_IPK_DIR=$(BUILD_DIR)/nmap-$(NMAP_VERSION)-ipk
NMAP_IPK=$(BUILD_DIR)/nmap_$(NMAP_VERSION)-$(NMAP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NMAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NMAP_SITE)/$(NMAP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nmap-source: $(DL_DIR)/$(NMAP_SOURCE) $(NMAP_PATCHES)

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
$(NMAP_BUILD_DIR)/.configured: $(DL_DIR)/$(NMAP_SOURCE) $(NMAP_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR)
	$(NMAP_UNZIP) $(DL_DIR)/$(NMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(NMAP_PATCHES) | patch -d $(BUILD_DIR)/$(NMAP_DIR) -p1
	mv $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR)
	(cd $(NMAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NMAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NMAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-openssl=$(STAGING_DIR)/opt \
		--with-pcap=linux \
		--with-nmapfe=no \
		ac_cv_prog_CXXPROG=$(TARGET_CXX) \
		ac_cv_linux_vers=2.4.22 \
	)
	touch $(NMAP_BUILD_DIR)/.configured

nmap-unpack: $(NMAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NMAP_BUILD_DIR)/.built: $(NMAP_BUILD_DIR)/.configured
	rm -f $(NMAP_BUILD_DIR)/.built
	$(MAKE) -C $(NMAP_BUILD_DIR)
	touch $(NMAP_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
nmap: $(NMAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libnmap.so.$(NMAP_VERSION): $(NMAP_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(NMAP_BUILD_DIR)/nmap.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(NMAP_BUILD_DIR)/libnmap.a $(STAGING_DIR)/opt/lib
	install -m 644 $(NMAP_BUILD_DIR)/libnmap.so.$(NMAP_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libnmap.so.$(NMAP_VERSION) libnmap.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libnmap.so.$(NMAP_VERSION) libnmap.so

nmap-stage: $(STAGING_DIR)/opt/lib/libnmap.so.$(NMAP_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(NMAP_IPK_DIR)/opt/sbin or $(NMAP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NMAP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NMAP_IPK_DIR)/opt/etc/nmap/...
# Documentation files should be installed in $(NMAP_IPK_DIR)/opt/doc/nmap/...
# Daemon startup scripts should be installed in $(NMAP_IPK_DIR)/opt/etc/init.d/S??nmap
#
# You may need to patch your application to make it use these locations.
#
$(NMAP_IPK): $(NMAP_BUILD_DIR)/.built
	rm -rf $(NMAP_IPK_DIR) $(BUILD_DIR)/nmap_*_$(TARGET_ARCH).ipk
	install -d $(NMAP_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(NMAP_BUILD_DIR)/nmap -o $(NMAP_IPK_DIR)/opt/bin/nmap
	install -d $(NMAP_IPK_DIR)/opt/share/nmap
	install -m 644 $(NMAP_BUILD_DIR)/nmap-services $(NMAP_IPK_DIR)/opt/share/nmap/nmap-services
	install -m 644 $(NMAP_BUILD_DIR)/nmap-rpc $(NMAP_IPK_DIR)/opt/share/nmap/nmap-rpc
	install -m 644 $(NMAP_BUILD_DIR)/nmap-os-fingerprints $(NMAP_IPK_DIR)/opt/share/nmap/nmap-os-fingerprints
	install -m 644 $(NMAP_BUILD_DIR)/nmap-service-probes $(NMAP_IPK_DIR)/opt/share/nmap/nmap-service-probes
	install -m 644 $(NMAP_BUILD_DIR)/nmap-protocols $(NMAP_IPK_DIR)/opt/share/nmap/nmap-protocols
	install -m 644 $(NMAP_BUILD_DIR)/nmap-mac-prefixes $(NMAP_IPK_DIR)/opt/share/nmap/nmap-mac-prefixes
	install -d $(NMAP_IPK_DIR)/CONTROL
	install -m 644 $(NMAP_SOURCE_DIR)/control $(NMAP_IPK_DIR)/CONTROL/control
#	install -m 644 $(NMAP_SOURCE_DIR)/postinst $(NMAP_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(NMAP_SOURCE_DIR)/prerm $(NMAP_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NMAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nmap-ipk: $(NMAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nmap-clean:
	-$(MAKE) -C $(NMAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nmap-dirclean:
	rm -rf $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR) $(NMAP_IPK_DIR) $(NMAP_IPK)
