###########################################################
#
# nmap
#
###########################################################
#
# $Header$
#
NMAP_SITE=http://download.insecure.org/nmap/dist
NMAP_VERSION=4.68
NMAP_SOURCE=nmap-$(NMAP_VERSION).tar.bz2
NMAP_DIR=nmap-$(NMAP_VERSION)
NMAP_UNZIP=bzcat
NMAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NMAP_DESCRIPTION=Nmap is a feature-rich portscanner
NMAP_SECTION=net
NMAP_PRIORITY=optional
NMAP_DEPENDS=openssl, pcre, libstdc++
NMAP_SUGGESTS=
NMAP_CONFLICTS=

#
# NMAP_IPK_VERSION should be incremented when the ipk changes.
#
NMAP_IPK_VERSION=1

#
# NMAP_CONFFILES should be a list of user-editable files
# NMAP_CONFFILES=/opt/etc/nmap.conf /opt/etc/init.d/SXXnmap

#
# NMAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NMAP_PATCHES=$(NMAP_SOURCE_DIR)/libdnet-configure.patch $(NMAP_SOURCE_DIR)/configure.patch
ifneq (, $(filter libuclibc++, $(PACKAGES)))
NMAP_PATCHES+=$(NMAP_SOURCE_DIR)/uclibc++-ctime.patch $(NMAP_SOURCE_DIR)/uclibc++-output.cc.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NMAP_CPPFLAGS=
NMAP_LDFLAGS=
ifeq (uclibc, $(LIBC_STYLE))
NMAP_LDFLAGS+=-lm
endif

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

.PHONY: nmap-source nmap-unpack nmap nmap-stage nmap-ipk nmap-clean nmap-dirclean nmap-check

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(NMAP_BUILD_DIR)/.configured: $(DL_DIR)/$(NMAP_SOURCE) $(NMAP_PATCHES) make/nmap.mk
	$(MAKE) openssl-stage pcre-stage libstdc++-stage lua-stage
	rm -rf $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR)
	$(NMAP_UNZIP) $(DL_DIR)/$(NMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NMAP_PATCHES)" ; \
		then cat $(NMAP_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(NMAP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(NMAP_DIR)" != "$(NMAP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NMAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NMAP_LDFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(NMAP_CPPFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-openssl=$(STAGING_DIR)/opt \
		--with-pcap=linux \
		--with-nmapfe=no \
		--without-zenmap \
		ac_cv_prog_CXXPROG=$(TARGET_CXX) \
		ac_cv_linux_vers=2.4.22 \
		; \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nmap-unpack: $(NMAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NMAP_BUILD_DIR)/.built: $(NMAP_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(NMAP_BUILD_DIR)/libpcre dftables CC=$(HOSTCC)
	$(MAKE) -C $(@D)
 
	touch $@

#
# This is the build convenience target.
#
nmap: $(NMAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NMAP_BUILD_DIR)/.staged: $(NMAP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nmap-stage: $(NMAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nmap
#
$(NMAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nmap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NMAP_PRIORITY)" >>$@
	@echo "Section: $(NMAP_SECTION)" >>$@
	@echo "Version: $(NMAP_VERSION)-$(NMAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NMAP_MAINTAINER)" >>$@
	@echo "Source: $(NMAP_SITE)/$(NMAP_SOURCE)" >>$@
	@echo "Description: $(NMAP_DESCRIPTION)" >>$@
	@echo "Depends: $(NMAP_DEPENDS)" >>$@
	@echo "Suggests: $(NMAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NMAP_CONFLICTS)" >>$@

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
	$(MAKE) -C $(NMAP_BUILD_DIR) DESTDIR=$(NMAP_IPK_DIR) install
	$(STRIP_COMMAND) $(NMAP_IPK_DIR)/opt/bin/nmap
	$(MAKE) $(NMAP_IPK_DIR)/CONTROL/control
	echo $(NMAP_CONFFILES) | sed -e 's/ /\n/g' > $(NMAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NMAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nmap-ipk: $(NMAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nmap-clean:
	rm -f $(NMAP_BUILD_DIR)/.built
	-$(MAKE) -C $(NMAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nmap-dirclean:
	rm -rf $(BUILD_DIR)/$(NMAP_DIR) $(NMAP_BUILD_DIR) $(NMAP_IPK_DIR) $(NMAP_IPK)

#
# Some sanity check for the package.
#
nmap-check: $(NMAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NMAP_IPK)
