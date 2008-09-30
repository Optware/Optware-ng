###########################################################
#
# trickle
#
###########################################################

TRICKLE_SITE=http://monkey.org/~marius/trickle
TRICKLE_VERSION=1.06
TRICKLE_SOURCE=trickle-$(TRICKLE_VERSION).tar.gz
TRICKLE_DIR=trickle-$(TRICKLE_VERSION)
TRICKLE_UNZIP=zcat

TRICKLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TRICKLE_DESCRIPTION=Trickle is a portable lightweight userspace bandwidth shaper.
TRICKLE_SECTION=net
TRICKLE_PRIORITY=optional
TRICKLE_DEPENDS=libevent (>=1.4)
TRICKLE_SUGGESTS=
TRICKLE_CONFLICTS=

#
# TRICKLE_IPK_VERSION should be incremented when the ipk changes.
#
TRICKLE_IPK_VERSION=2

#
# TRICKLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TRICKLE_PATCHES=$(TRICKLE_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRICKLE_CPPFLAGS=
TRICKLE_LDFLAGS=

#
# TRICKLE_BUILD_DIR is the directory in which the build is done.
# TRICKLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRICKLE_IPK_DIR is the directory in which the ipk is built.
# TRICKLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRICKLE_BUILD_DIR=$(BUILD_DIR)/trickle
TRICKLE_SOURCE_DIR=$(SOURCE_DIR)/trickle
TRICKLE_IPK_DIR=$(BUILD_DIR)/trickle-$(TRICKLE_VERSION)-ipk
TRICKLE_IPK=$(BUILD_DIR)/trickle_$(TRICKLE_VERSION)-$(TRICKLE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TRICKLE_SOURCE):
	$(WGET) -P $(@D) $(TRICKLE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
trickle-source: $(DL_DIR)/$(TRICKLE_SOURCE) $(TRICKLE_PATCHES)

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
$(TRICKLE_BUILD_DIR)/.configured: $(DL_DIR)/$(TRICKLE_SOURCE) $(TRICKLE_PATCHES)
	$(MAKE) libevent-stage
	rm -rf $(BUILD_DIR)/$(TRICKLE_DIR) $(TRICKLE_BUILD_DIR)
	$(TRICKLE_UNZIP) $(DL_DIR)/$(TRICKLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TRICKLE_PATCHES) | patch -bd $(BUILD_DIR)/$(TRICKLE_DIR) -p0
	mv $(BUILD_DIR)/$(TRICKLE_DIR) $(@D)
	sed -i -e '/^AM_CFLAGS/s/+=/=/' $(@D)/Makefile.am
	cd $(@D); ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRICKLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRICKLE_LDFLAGS)" \
		ac_cv_type_in_addr_t=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-libevent=$(STAGING_PREFIX) \
		--with-gnu-ld \
		--prefix=/opt \
		--disable-nls \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

trickle-unpack: $(TRICKLE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(TRICKLE_BUILD_DIR)/.built: $(TRICKLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) all
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
trickle: $(TRICKLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libtrickle.so.$(TRICKLE_VERSION): $(TRICKLE_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(TRICKLE_BUILD_DIR)/trickle.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(TRICKLE_BUILD_DIR)/libtrickle.a $(STAGING_DIR)/opt/lib
	install -m 644 $(TRICKLE_BUILD_DIR)/libtrickle.so.$(TRICKLE_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libtrickle.so.$(TRICKLE_VERSION) libtrickle.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libtrickle.so.$(TRICKLE_VERSION) libtrickle.so

trickle-stage: $(STAGING_DIR)/opt/lib/libtrickle.so.$(TRICKLE_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(TRICKLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: trickle" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRICKLE_PRIORITY)" >>$@
	@echo "Section: $(TRICKLE_SECTION)" >>$@
	@echo "Version: $(TRICKLE_VERSION)-$(TRICKLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TRICKLE_MAINTAINER)" >>$@
	@echo "Source: $(TRICKLE_SITE)/$(TRICKLE_SOURCE)" >>$@
	@echo "Description: $(TRICKLE_DESCRIPTION)" >>$@
	@echo "Depends: $(TRICKLE_DEPENDS)" >>$@
	@echo "Suggests: $(TRICKLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRICKLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRICKLE_IPK_DIR)/opt/sbin or $(TRICKLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRICKLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRICKLE_IPK_DIR)/opt/etc/trickle/...
# Documentation files should be installed in $(TRICKLE_IPK_DIR)/opt/doc/trickle/...
# Daemon startup scripts should be installed in $(TRICKLE_IPK_DIR)/opt/etc/init.d/S??trickle
#
# You may need to patch your application to make it use these locations.
#
$(TRICKLE_IPK): $(TRICKLE_BUILD_DIR)/.built
	rm -rf $(TRICKLE_IPK_DIR) $(BUILD_DIR)/trickle_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TRICKLE_BUILD_DIR) DESTDIR=$(TRICKLE_IPK_DIR) transform='' \
		install-binPROGRAMS install-trickleoverloadDATA install-man
#	install -d $(TRICKLE_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TRICKLE_IPK_DIR)/opt/bin/trickle* $(TRICKLE_IPK_DIR)/opt/lib/trickle/*
#	install -d $(TRICKLE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TRICKLE_SOURCE_DIR)/rc.trickle $(TRICKLE_IPK_DIR)/opt/etc/init.d/SXXtrickle
	$(MAKE) $(TRICKLE_IPK_DIR)/CONTROL/control
#	install -m 644 $(TRICKLE_SOURCE_DIR)/postinst $(TRICKLE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(TRICKLE_SOURCE_DIR)/prerm $(TRICKLE_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRICKLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
trickle-ipk: $(TRICKLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
trickle-clean:
	-$(MAKE) -C $(TRICKLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
trickle-dirclean:
	rm -rf $(BUILD_DIR)/$(TRICKLE_DIR) $(TRICKLE_BUILD_DIR) $(TRICKLE_IPK_DIR) $(TRICKLE_IPK)

#
# Some sanity check for the package.
#
trickle-check: $(TRICKLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRICKLE_IPK)
