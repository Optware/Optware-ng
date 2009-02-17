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
LIBPCAP_VERSION=1.0.0
LIBPCAP_SOURCE=libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_DIR=libpcap-$(LIBPCAP_VERSION)
LIBPCAP_UNZIP=zcat
LIBPCAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPCAP_DESCRIPTION=PCAP Library
LIBPCAP_SECTION=lib
LIBPCAP_PRIORITY=optional
LIBPCAP_DEPENDS=
LIBPCAP_SUGGESTS=
LIBPCAP_CONFLICTS=

#
# LIBPCAP_IPK_VERSION should be incremented when the ipk changes.
#
LIBPCAP_IPK_VERSION=1

LIBPCAP_BUILD_DIR=$(BUILD_DIR)/libpcap
LIBPCAP_SOURCE_DIR=$(SOURCE_DIR)/libpcap
LIBPCAP_IPK_DIR=$(BUILD_DIR)/libpcap-$(LIBPCAP_VERSION)-ipk
LIBPCAP_IPK=$(BUILD_DIR)/libpcap_$(LIBPCAP_VERSION)-$(LIBPCAP_IPK_VERSION)_$(TARGET_ARCH).ipk
LIBPCAP-DEV_IPK_DIR=$(BUILD_DIR)/libpcap-dev-$(LIBPCAP_VERSION)-ipk
LIBPCAP-DEV_IPK=$(BUILD_DIR)/libpcap-dev_$(LIBPCAP_VERSION)-$(LIBPCAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpcap-source libpcap-unpack libpcap libpcap-stage libpcap-ipk libpcap-clean libpcap-dirclean libpcap-check

#
# LIBPCAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBPCAP_PATCHES=\
$(LIBPCAP_SOURCE_DIR)/100-shared-lib.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPCAP_CPPFLAGS=
LIBPCAP_LDFLAGS=
ifneq (no, $(IPV6))
LIBPCAP_CONFIGURE_OPTS=--enable-ipv6
endif

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
	$(WGET) -P $(@D) $(LIBPCAP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(LIBPCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPCAP_SOURCE) $(LIBPCAP_PATCHES) make/libpcap.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBPCAP_DIR) $(@D)
	$(LIBPCAP_UNZIP) $(DL_DIR)/$(LIBPCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBPCAP_PATCHES)"; then \
	cat $(LIBPCAP_PATCHES) | patch -d $(BUILD_DIR)/$(LIBPCAP_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(LIBPCAP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPCAP_LDFLAGS)" \
		ac_cv_linux_vers=2 \
		ac_cv_header_bluetooth_bluetooth_h=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--enable-shared \
		--with-pcap=linux \
		--prefix=/opt \
		--with-build-cc="$(HOSTCC)" \
		$(LIBPCAP_CONFIGURE_OPTS) \
	)
	touch $@

libpcap-unpack: $(LIBPCAP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBPCAP_BUILD_DIR)/.built: $(LIBPCAP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPCAP_LDFLAGS)" \
		;
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libpcap: $(LIBPCAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPCAP_BUILD_DIR)/.staged: $(LIBPCAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/opt/lib/libpcap.a
	touch $@

libpcap-stage: $(LIBPCAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpcap
#
$(LIBPCAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libpcap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPCAP_PRIORITY)" >>$@
	@echo "Section: $(LIBPCAP_SECTION)" >>$@
	@echo "Version: $(LIBPCAP_VERSION)-$(LIBPCAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPCAP_MAINTAINER)" >>$@
	@echo "Source: $(LIBPCAP_SITE)/$(LIBPCAP_SOURCE)" >>$@
	@echo "Description: $(LIBPCAP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPCAP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPCAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPCAP_CONFLICTS)" >>$@

$(LIBPCAP-DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libpcap-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPCAP_PRIORITY)" >>$@
	@echo "Section: $(LIBPCAP_SECTION)" >>$@
	@echo "Version: $(LIBPCAP_VERSION)-$(LIBPCAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPCAP_MAINTAINER)" >>$@
	@echo "Source: $(LIBPCAP_SITE)/$(LIBPCAP_SOURCE)" >>$@
	@echo "Description: $(LIBPCAP_DESCRIPTION) header files for development" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

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
$(LIBPCAP_IPK) $(LIBPCAP-DEV_IPK): $(LIBPCAP_BUILD_DIR)/.built
	rm -rf $(LIBPCAP_IPK_DIR) $(BUILD_DIR)/libpcap_*_$(TARGET_ARCH).ipk
	rm -rf $(LIBPCAP-DEV_IPK_DIR) $(BUILD_DIR)/libpcap-dev_*_$(TARGET_ARCH).ipk
	install -d $(LIBPCAP_IPK_DIR)/opt/bin
	$(MAKE) -C $(LIBPCAP_BUILD_DIR) DESTDIR=$(LIBPCAP_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBPCAP_IPK_DIR)/opt/lib/libpcap.so.[0-9]*.[0-9]*.[0-9]*
	rm -f $(LIBPCAP_IPK_DIR)/opt/lib/libpcap.a
	$(MAKE) $(LIBPCAP_IPK_DIR)/CONTROL/control
	$(MAKE) $(LIBPCAP-DEV_IPK_DIR)/CONTROL/control
	install -d $(LIBPCAP-DEV_IPK_DIR)/opt/
	mv $(LIBPCAP_IPK_DIR)/opt/bin $(LIBPCAP-DEV_IPK_DIR)/opt/
	mv $(LIBPCAP_IPK_DIR)/opt/include $(LIBPCAP-DEV_IPK_DIR)/opt/
	mv $(LIBPCAP_IPK_DIR)/opt/share $(LIBPCAP-DEV_IPK_DIR)/opt/
#	echo $(LIBPCAP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBPCAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPCAP_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPCAP-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpcap-ipk: $(LIBPCAP_IPK) $(LIBPCAP-DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpcap-clean:
	rm -f $(LIBPCAP_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBPCAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpcap-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPCAP_DIR) $(LIBPCAP_BUILD_DIR) $(LIBPCAP_IPK_DIR) $(LIBPCAP_IPK)
#
#
# Some sanity check for the package.
#
libpcap-check: $(LIBPCAP_IPK) $(LIBPCAP-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBPCAP_IPK) $(LIBPCAP-DEV_IPK)
