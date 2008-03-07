###########################################################
#
# nload
#
###########################################################

# You must replace "nload" and "NLOAD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NLOAD_VERSION, NLOAD_SITE and NLOAD_SOURCE define
# the upstream location of the source code for the package.
# NLOAD_DIR is the directory which is created when the source
# archive is unpacked.
# NLOAD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NLOAD_SITE=http://www.roland-riegel.de/nload
NLOAD_VERSION=0.7.1
NLOAD_SOURCE=nload-$(NLOAD_VERSION).tar.gz
NLOAD_DIR=nload-$(NLOAD_VERSION)
NLOAD_UNZIP=zcat
NLOAD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NLOAD_DESCRIPTION=Nload is a console application which monitors network traffic and bandwidth usage in real time
NLOAD_SECTION=net
NLOAD_PRIORITY=optional
NLOAD_DEPENDS=ncurses, libstdc++
NLOAD_SUGGESTS=
NLOAD_CONFLICTS=

#
# NLOAD_IPK_VERSION should be incremented when the ipk changes.
#
NLOAD_IPK_VERSION=3

#
# NLOAD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NLOAD_PATCHES=$(NLOAD_SOURCE_DIR)/uclibc-device-stream.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NLOAD_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
NLOAD_LDFLAGS=

ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
NLOAD_CONFIGURE_OPTS = CXX=$(TARGET_GXX)
endif
endif

#
# NLOAD_BUILD_DIR is the directory in which the build is done.
# NLOAD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NLOAD_IPK_DIR is the directory in which the ipk is built.
# NLOAD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NLOAD_BUILD_DIR=$(BUILD_DIR)/nload
NLOAD_SOURCE_DIR=$(SOURCE_DIR)/nload
NLOAD_IPK_DIR=$(BUILD_DIR)/nload-$(NLOAD_VERSION)-ipk
NLOAD_IPK=$(BUILD_DIR)/nload_$(NLOAD_VERSION)-$(NLOAD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NLOAD_SOURCE):
	$(WGET) -P $(DL_DIR) $(NLOAD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nload-source: $(DL_DIR)/$(NLOAD_SOURCE) $(NLOAD_PATCHES)

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
$(NLOAD_BUILD_DIR)/.configured: $(DL_DIR)/$(NLOAD_SOURCE) $(NLOAD_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NLOAD_DIR) $(NLOAD_BUILD_DIR)
	$(NLOAD_UNZIP) $(DL_DIR)/$(NLOAD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NLOAD_PATCHES)"; then \
		cat $(NLOAD_PATCHES) | patch -d $(BUILD_DIR)/$(NLOAD_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(NLOAD_DIR) $(NLOAD_BUILD_DIR)
	AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 \
                autoreconf --verbose $(NLOAD_BUILD_DIR)
	(cd $(NLOAD_BUILD_DIR); \
		sed -i -e 's|/etc/nload.conf|/opt/etc/nload.conf|' \
			docs/nload.1.in src/main.cpp ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NLOAD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NLOAD_LDFLAGS)" \
		$(NLOAD_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-dependency-tracking \
	)
	touch $@

nload-unpack: $(NLOAD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NLOAD_BUILD_DIR)/.built: $(NLOAD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NLOAD_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
nload: $(NLOAD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libnload.so.$(NLOAD_VERSION): $(NLOAD_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(NLOAD_BUILD_DIR)/nload.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(NLOAD_BUILD_DIR)/libnload.a $(STAGING_DIR)/opt/lib
	install -m 644 $(NLOAD_BUILD_DIR)/libnload.so.$(NLOAD_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libnload.so.$(NLOAD_VERSION) libnload.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libnload.so.$(NLOAD_VERSION) libnload.so

nload-stage: $(STAGING_DIR)/opt/lib/libnload.so.$(NLOAD_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nload
#
$(NLOAD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nload" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NLOAD_PRIORITY)" >>$@
	@echo "Section: $(NLOAD_SECTION)" >>$@
	@echo "Version: $(NLOAD_VERSION)-$(NLOAD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NLOAD_MAINTAINER)" >>$@
	@echo "Source: $(NLOAD_SITE)/$(NLOAD_SOURCE)" >>$@
	@echo "Description: $(NLOAD_DESCRIPTION)" >>$@
	@echo "Depends: $(NLOAD_DEPENDS)" >>$@
	@echo "Suggests: $(NLOAD_SUGGESTS)" >>$@
	@echo "Conflicts: $(NLOAD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NLOAD_IPK_DIR)/opt/sbin or $(NLOAD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NLOAD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NLOAD_IPK_DIR)/opt/etc/nload/...
# Documentation files should be installed in $(NLOAD_IPK_DIR)/opt/doc/nload/...
# Daemon startup scripts should be installed in $(NLOAD_IPK_DIR)/opt/etc/init.d/S??nload
#
# You may need to patch your application to make it use these locations.
#
$(NLOAD_IPK): $(NLOAD_BUILD_DIR)/.built
	rm -rf $(NLOAD_IPK_DIR) $(BUILD_DIR)/nload_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NLOAD_BUILD_DIR) DESTDIR=$(NLOAD_IPK_DIR) install-strip
	$(MAKE) $(NLOAD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NLOAD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nload-ipk: $(NLOAD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nload-clean:
	-$(MAKE) -C $(NLOAD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nload-dirclean:
	rm -rf $(BUILD_DIR)/$(NLOAD_DIR) $(NLOAD_BUILD_DIR) $(NLOAD_IPK_DIR) $(NLOAD_IPK)

#
# Some sanity check for the package.
#
nload-check: $(NLOAD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NLOAD_IPK)
