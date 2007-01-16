###########################################################
#
# coreutils
#
###########################################################

# You must replace "coreutils" and "COREUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# COREUTILS_VERSION, COREUTILS_SITE and COREUTILS_SOURCE define
# the upstream location of the source code for the package.
# COREUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# COREUTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
COREUTILS_SITE=http://ftp.gnu.org/pub/gnu/coreutils
COREUTILS_VERSION=6.7
COREUTILS_SOURCE=coreutils-$(COREUTILS_VERSION).tar.gz
COREUTILS_DIR=coreutils-$(COREUTILS_VERSION)
COREUTILS_UNZIP=zcat
COREUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COREUTILS_DESCRIPTION=Bunch of heavyweight *nix core utilities
COREUTILS_SECTION=core
COREUTILS_PRIORITY=optional
COREUTILS_DEPENDS=
COREUTILS_CONFLICTS=busybox-links

#
# COREUTILS_IPK_VERSION should be incremented when the ipk changes.
#
COREUTILS_IPK_VERSION=1

#
# COREUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
COREUTILS_PATCHES=$(COREUTILS_SOURCE_DIR)/mountlist.patch
# Assume that all uclibc systems are the same
ifeq ($(LIBC_STYLE), uclibc)
COREUTILS_AC_CACHE=$(COREUTILS_SOURCE_DIR)/config-uclibc.cache
else
COREUTILS_AC_CACHE=$(COREUTILS_SOURCE_DIR)/config.cache
endif
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET),wl500g)
  COREUTILS_CPPFLAGS=-DMB_CUR_MAX=1
  COREUTILS_LDFLAGS=-lm
else
  COREUTILS_CPPFLAGS=
  COREUTILS_LDFLAGS=
endif

#
# COREUTILS_BUILD_DIR is the directory in which the build is done.
# COREUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COREUTILS_IPK_DIR is the directory in which the ipk is built.
# COREUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COREUTILS_BUILD_DIR=$(BUILD_DIR)/coreutils
COREUTILS_SOURCE_DIR=$(SOURCE_DIR)/coreutils
COREUTILS_IPK_DIR=$(BUILD_DIR)/coreutils-$(COREUTILS_VERSION)-ipk
COREUTILS_IPK=$(BUILD_DIR)/coreutils_$(COREUTILS_VERSION)-$(COREUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: coreutils-source coreutils-unpack coreutils coreutils-stage coreutils-ipk coreutils-clean coreutils-dirclean coreutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COREUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(COREUTILS_SITE)/$(COREUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
coreutils-source: $(DL_DIR)/$(COREUTILS_SOURCE) $(COREUTILS_PATCHES)

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
$(COREUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(COREUTILS_SOURCE) $(COREUTILS_PATCHES) $(COREUTILS_AC_CACHE)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(COREUTILS_DIR) $(COREUTILS_BUILD_DIR)
	$(COREUTILS_UNZIP) $(DL_DIR)/$(COREUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(COREUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(COREUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(COREUTILS_DIR) $(COREUTILS_BUILD_DIR)
	cp $(COREUTILS_AC_CACHE) $(COREUTILS_BUILD_DIR)/config.cache
	(cd $(COREUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(COREUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(COREUTILS_LDFLAGS)" \
		./configure \
		--cache-file=config.cache \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--datarootdir=/opt \
	)
	touch $(COREUTILS_BUILD_DIR)/.configured

coreutils-unpack: $(COREUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(COREUTILS_BUILD_DIR)/.built: $(COREUTILS_BUILD_DIR)/.configured
	rm -f $(COREUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(COREUTILS_BUILD_DIR)
	touch $(COREUTILS_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
coreutils: $(COREUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(STAGING_DIR)/opt/lib/libcoreutils.so.$(COREUTILS_VERSION): $(COREUTILS_BUILD_DIR)/.built
#	install -d $(STAGING_DIR)/opt/include
#	install -m 644 $(COREUTILS_BUILD_DIR)/coreutils.h $(STAGING_DIR)/opt/include
#	install -d $(STAGING_DIR)/opt/lib
#	install -m 644 $(COREUTILS_BUILD_DIR)/libcoreutils.a $(STAGING_DIR)/opt/lib
#	install -m 644 $(COREUTILS_BUILD_DIR)/libcoreutils.so.$(COREUTILS_VERSION) $(STAGING_DIR)/opt/lib
#	cd $(STAGING_DIR)/opt/lib && ln -fs libcoreutils.so.$(COREUTILS_VERSION) libcoreutils.so.1
#	cd $(STAGING_DIR)/opt/lib && ln -fs libcoreutils.so.$(COREUTILS_VERSION) libcoreutils.so
#
#coreutils-stage: $(STAGING_DIR)/opt/lib/libcoreutils.so.$(COREUTILS_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/coreutils
#
$(COREUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(COREUTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: coreutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COREUTILS_PRIORITY)" >>$@
	@echo "Section: $(COREUTILS_SECTION)" >>$@
	@echo "Version: $(COREUTILS_VERSION)-$(COREUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COREUTILS_MAINTAINER)" >>$@
	@echo "Source: $(COREUTILS_SITE)/$(COREUTILS_SOURCE)" >>$@
	@echo "Description: $(COREUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(COREUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(COREUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COREUTILS_IPK_DIR)/opt/sbin or $(COREUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COREUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(COREUTILS_IPK_DIR)/opt/etc/coreutils/...
# Documentation files should be installed in $(COREUTILS_IPK_DIR)/opt/doc/coreutils/...
# Daemon startup scripts should be installed in $(COREUTILS_IPK_DIR)/opt/etc/init.d/S??coreutils
#
# You may need to patch your application to make it use these locations.
#
$(COREUTILS_IPK): $(COREUTILS_BUILD_DIR)/.built
	rm -rf $(COREUTILS_IPK_DIR) $(BUILD_DIR)/coreutils_*_$(TARGET_ARCH).ipk
	# Install binaries
	install -d $(COREUTILS_IPK_DIR)/opt/bin
	$(MAKE) -C $(COREUTILS_BUILD_DIR) DESTDIR=$(COREUTILS_IPK_DIR) install-exec
	# copy su - can't install it as install only works for root
	cp -p $(COREUTILS_BUILD_DIR)/src/su $(COREUTILS_IPK_DIR)/opt/bin/su
	# Install makefiles
	install -d $(COREUTILS_IPK_DIR)/opt/man/man1	
	$(MAKE) -C $(COREUTILS_BUILD_DIR)/man DESTDIR=$(COREUTILS_IPK_DIR) install
	# Temporarily Remove /opt/bin/groups (it is a script so doesn't strip)
	rm $(COREUTILS_IPK_DIR)/opt/bin/groups
	# Remove /opt/bin/hostname (conflicts with net-tools)
	rm $(COREUTILS_IPK_DIR)/opt/bin/hostname
	rm $(COREUTILS_IPK_DIR)/opt/man/man1/hostname.1
	$(STRIP_COMMAND) $(COREUTILS_IPK_DIR)/opt/bin/*
	cp $(COREUTILS_BUILD_DIR)/src/groups $(COREUTILS_IPK_DIR)/opt/bin
	mv $(COREUTILS_IPK_DIR)/opt/bin/kill $(COREUTILS_IPK_DIR)/opt/bin/coreutils-kill
	mv $(COREUTILS_IPK_DIR)/opt/bin/uptime $(COREUTILS_IPK_DIR)/opt/bin/coreutils-uptime
	mv $(COREUTILS_IPK_DIR)/opt/bin/su $(COREUTILS_IPK_DIR)/opt/bin/coreutils-su
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	install -d $(COREUTILS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(COREUTILS_SOURCE_DIR)/rc.coreutils $(COREUTILS_IPK_DIR)/opt/etc/init.d/S05coreutils
	install -d $(COREUTILS_IPK_DIR)/usr/bin
	ln -s /opt/bin/env $(COREUTILS_IPK_DIR)/usr/bin/env
endif
	$(MAKE) $(COREUTILS_IPK_DIR)/CONTROL/control
	install -m 644 $(COREUTILS_SOURCE_DIR)/postinst $(COREUTILS_IPK_DIR)/CONTROL/postinst
	install -m 644 $(COREUTILS_SOURCE_DIR)/prerm $(COREUTILS_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COREUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
coreutils-ipk: $(COREUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
coreutils-clean:
	-$(MAKE) -C $(COREUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
coreutils-dirclean:
	rm -rf $(BUILD_DIR)/$(COREUTILS_DIR) $(COREUTILS_BUILD_DIR) $(COREUTILS_IPK_DIR) $(COREUTILS_IPK)

#
# Some sanity check for the package.
#
coreutils-check: $(COREUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(COREUTILS_IPK)
