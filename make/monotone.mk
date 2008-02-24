###########################################################
#
# monotone
#
###########################################################

#
# MONOTONE_VERSION, MONOTONE_SITE and MONOTONE_SOURCE define
# the upstream location of the source code for the package.
# MONOTONE_DIR is the directory which is created when the source
# archive is unpacked.
# MONOTONE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
MONOTONE_SITE=http://venge.net/monotone/downloads/$(MONOTONE_XVERSION)/
MONOTONE_XVERSION=0.25
MONOTONE_VERSION=0.25.2
MONOTONE_SOURCE=monotone-$(MONOTONE_VERSION).tar.gz
MONOTONE_DIR=monotone-$(MONOTONE_VERSION)
MONOTONE_UNZIP=zcat
MONOTONE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MONOTONE_DESCRIPTION=monotone is a free distributed version control system.
MONOTONE_SECTION=misc
MONOTONE_PRIORITY=optional
MONOTONE_DEPENDS=zlib
MONOTONE_SUGGESTS=
MONOTONE_CONFLICTS=

#
# MONOTONE_IPK_VERSION should be incremented when the ipk changes.
#
MONOTONE_IPK_VERSION=1

#
# MONOTONE_CONFFILES should be a list of user-editable files
#MONOTONE_CONFFILES=/opt/etc/monotone.conf /opt/etc/init.d/SXXmonotone

#
# MONOTONE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MONOTONE_PATCHES=$(MONOTONE_SOURCE_DIR)/monotone-0.25-try-run.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET),nslu2)
MONOTONE_CPPFLAGS=-D__BIG_ENDIAN__
else
MONOTONE_CPPFLAGS=
endif
MONOTONE_LDFLAGS=

#
# MONOTONE_BUILD_DIR is the directory in which the build is done.
# MONOTONE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MONOTONE_IPK_DIR is the directory in which the ipk is built.
# MONOTONE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MONOTONE_BUILD_DIR=$(BUILD_DIR)/monotone
MONOTONE_SOURCE_DIR=$(SOURCE_DIR)/monotone
MONOTONE_IPK_DIR=$(BUILD_DIR)/monotone-$(MONOTONE_VERSION)-ipk
MONOTONE_IPK=$(BUILD_DIR)/monotone_$(MONOTONE_VERSION)-$(MONOTONE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MONOTONE_SOURCE):
	$(WGET) -P $(DL_DIR) $(MONOTONE_SITE)/$(MONOTONE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
monotone-source: $(DL_DIR)/$(MONOTONE_SOURCE) $(MONOTONE_PATCHES)

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
$(MONOTONE_BUILD_DIR)/.configured: $(DL_DIR)/$(MONOTONE_SOURCE) $(MONOTONE_PATCHES)
	$(MAKE) libboost-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(MONOTONE_DIR) $(MONOTONE_BUILD_DIR)
	$(MONOTONE_UNZIP) $(DL_DIR)/$(MONOTONE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MONOTONE_PATCHES) | patch -d $(BUILD_DIR)/$(MONOTONE_DIR) -p1
	mv $(BUILD_DIR)/$(MONOTONE_DIR) $(MONOTONE_BUILD_DIR)
	AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 \
		autoreconf --verbose $(MONOTONE_BUILD_DIR)
	(cd $(MONOTONE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(MONOTONE_CPPFLAGS) -fno-strict-aliasing" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MONOTONE_LDFLAGS)" \
		ac_cv_locale_works=yes \
		ac_cv_func_stat_empty_string_bug=no \
		ac_cv_func_lstat_dereferences_slashed_symlink=yes \
		ac_cv_version_boost=yes \
		ac_fix_boost=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-ipv6=no \
		--with-bundled-lua \
		--with-bundled-sqlite \
	)
	touch $(MONOTONE_BUILD_DIR)/.configured

monotone-unpack: $(MONOTONE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MONOTONE_BUILD_DIR)/.built: $(MONOTONE_BUILD_DIR)/.configured
	rm -f $(MONOTONE_BUILD_DIR)/.built
	$(MAKE) -C $(MONOTONE_BUILD_DIR) CXX=g++ txt2c
	$(MAKE) -C $(MONOTONE_BUILD_DIR)
	touch $(MONOTONE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
monotone: $(MONOTONE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MONOTONE_BUILD_DIR)/.staged: $(MONOTONE_BUILD_DIR)/.built
	rm -f $(MONOTONE_BUILD_DIR)/.staged
	$(MAKE) -C $(MONOTONE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MONOTONE_BUILD_DIR)/.staged

monotone-stage: $(MONOTONE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/monotone
#
$(MONOTONE_IPK_DIR)/CONTROL/control:
	@install -d $(MONOTONE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: monotone" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MONOTONE_PRIORITY)" >>$@
	@echo "Section: $(MONOTONE_SECTION)" >>$@
	@echo "Version: $(MONOTONE_VERSION)-$(MONOTONE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MONOTONE_MAINTAINER)" >>$@
	@echo "Source: $(MONOTONE_SITE)/$(MONOTONE_SOURCE)" >>$@
	@echo "Description: $(MONOTONE_DESCRIPTION)" >>$@
	@echo "Depends: $(MONOTONE_DEPENDS)" >>$@
	@echo "Suggests: $(MONOTONE_SUGGESTS)" >>$@
	@echo "Conflicts: $(MONOTONE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MONOTONE_IPK_DIR)/opt/sbin or $(MONOTONE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MONOTONE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MONOTONE_IPK_DIR)/opt/etc/monotone/...
# Documentation files should be installed in $(MONOTONE_IPK_DIR)/opt/doc/monotone/...
# Daemon startup scripts should be installed in $(MONOTONE_IPK_DIR)/opt/etc/init.d/S??monotone
#
# You may need to patch your application to make it use these locations.
#
$(MONOTONE_IPK): $(MONOTONE_BUILD_DIR)/.built
	rm -rf $(MONOTONE_IPK_DIR) $(BUILD_DIR)/monotone_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MONOTONE_BUILD_DIR) DESTDIR=$(MONOTONE_IPK_DIR) install
	$(STRIP_COMMAND) $(MONOTONE_IPK_DIR)/opt/bin/monotone
	$(MAKE) $(MONOTONE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MONOTONE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
monotone-ipk: $(MONOTONE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
monotone-clean:
	-$(MAKE) -C $(MONOTONE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
monotone-dirclean:
	rm -rf $(BUILD_DIR)/$(MONOTONE_DIR) $(MONOTONE_BUILD_DIR) $(MONOTONE_IPK_DIR) $(MONOTONE_IPK)
