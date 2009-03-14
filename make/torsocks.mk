###########################################################
#
# torsocks
#
###########################################################

#
# TORSOCKS_VERSION, TORSOCKS_SITE and TORSOCKS_SOURCE define
# the upstream location of the source code for the package.
# TORSOCKS_DIR is the directory which is created when the source
# archive is unpacked.
# TORSOCKS_UNZIP is the command used to unzip the source.
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
TORSOCKS_SITE=http://torsocks.googlecode.com/files
TORSOCKS_VERSION=1.0-gamma
TORSOCKS_SOURCE=torsocks-$(TORSOCKS_VERSION).tar.gz
TORSOCKS_DIR=torsocks-$(TORSOCKS_VERSION)
TORSOCKS_UNZIP=zcat
TORSOCKS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TORSOCKS_DESCRIPTION=A transparent SOCKS proxy for use with tor
TORSOCKS_SECTION=net
TORSOCKS_PRIORITY=optional
TORSOCKS_DEPENDS=
TORSOCKS_SUGGESTS=
TORSOCKS_CONFLICTS=

#
# TORSOCKS_IPK_VERSION should be incremented when the ipk changes.
#
TORSOCKS_IPK_VERSION=1

#
# TORSOCKS_CONFFILES should be a list of user-editable files
#TORSOCKS_CONFFILES=/opt/etc/torsocks.conf

#
# TORSOCKS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TORSOCKS_PATCHES=$(TORSOCKS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TORSOCKS_CPPFLAGS=
TORSOCKS_LDFLAGS=

#
# TORSOCKS_BUILD_DIR is the directory in which the build is done.
# TORSOCKS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TORSOCKS_IPK_DIR is the directory in which the ipk is built.
# TORSOCKS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TORSOCKS_BUILD_DIR=$(BUILD_DIR)/torsocks
TORSOCKS_SOURCE_DIR=$(SOURCE_DIR)/torsocks
TORSOCKS_IPK_DIR=$(BUILD_DIR)/torsocks-$(TORSOCKS_VERSION)-ipk
TORSOCKS_IPK=$(BUILD_DIR)/torsocks_$(TORSOCKS_VERSION)-$(TORSOCKS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: torsocks-source torsocks-unpack torsocks torsocks-stage torsocks-ipk torsocks-clean torsocks-dirclean torsocks-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TORSOCKS_SOURCE):
	$(WGET) -P $(DL_DIR) $(TORSOCKS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
torsocks-source: $(DL_DIR)/$(TORSOCKS_SOURCE) $(TORSOCKS_PATCHES)

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
$(TORSOCKS_BUILD_DIR)/.configured: $(DL_DIR)/$(TORSOCKS_SOURCE) $(TORSOCKS_PATCHES) make/torsocks.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TORSOCKS_DIR) $(TORSOCKS_BUILD_DIR)
	$(TORSOCKS_UNZIP) $(DL_DIR)/$(TORSOCKS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TORSOCKS_PATCHES)" ; \
		then cat $(TORSOCKS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TORSOCKS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TORSOCKS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TORSOCKS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TORSOCKS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TORSOCKS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-conf=/opt/etc/torsocks.conf \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

torsocks-unpack: $(TORSOCKS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TORSOCKS_BUILD_DIR)/.built: $(TORSOCKS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
torsocks: $(TORSOCKS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(TORSOCKS_BUILD_DIR)/.staged: $(TORSOCKS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#torsocks-stage: $(TORSOCKS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/torsocks
#
$(TORSOCKS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: torsocks" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TORSOCKS_PRIORITY)" >>$@
	@echo "Section: $(TORSOCKS_SECTION)" >>$@
	@echo "Version: $(TORSOCKS_VERSION)-$(TORSOCKS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TORSOCKS_MAINTAINER)" >>$@
	@echo "Source: $(TORSOCKS_SITE)/$(TORSOCKS_SOURCE)" >>$@
	@echo "Description: $(TORSOCKS_DESCRIPTION)" >>$@
	@echo "Depends: $(TORSOCKS_DEPENDS)" >>$@
	@echo "Suggests: $(TORSOCKS_SUGGESTS)" >>$@
	@echo "Conflicts: $(TORSOCKS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TORSOCKS_IPK_DIR)/opt/sbin or $(TORSOCKS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TORSOCKS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TORSOCKS_IPK_DIR)/opt/etc/torsocks/...
# Documentation files should be installed in $(TORSOCKS_IPK_DIR)/opt/doc/torsocks/...
# Daemon startup scripts should be installed in $(TORSOCKS_IPK_DIR)/opt/etc/init.d/S??torsocks
#
# You may need to patch your application to make it use these locations.
#
$(TORSOCKS_IPK): $(TORSOCKS_BUILD_DIR)/.built
	rm -rf $(TORSOCKS_IPK_DIR) $(BUILD_DIR)/torsocks_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TORSOCKS_BUILD_DIR) DESTDIR=$(TORSOCKS_IPK_DIR) install
	sed -i -e 's:/usr/:/opt/:g' $(TORSOCKS_IPK_DIR)/opt/bin/torsocks
	rm -f $(TORSOCKS_IPK_DIR)/opt/lib/torsocks/libtorsocks*.a
	$(STRIP_COMMAND) $(TORSOCKS_IPK_DIR)/opt/lib/torsocks/libtorsocks.so.[0-9].[0-9].[0-9]
#	install -d $(TORSOCKS_IPK_DIR)/opt/etc/
#	mv $(TORSOCKS_IPK_DIR)/lib $(TORSOCKS_IPK_DIR)/opt/
#	$(STRIP_COMMAND) $(TORSOCKS_IPK_DIR)/opt/lib/libtorsocks.so.1.8
	#install -m 644 $(TORSOCKS_SOURCE_DIR)/torsocks.conf $(TORSOCKS_IPK_DIR)/opt/etc/torsocks.conf
	$(MAKE) $(TORSOCKS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TORSOCKS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
torsocks-ipk: $(TORSOCKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
torsocks-clean:
	-$(MAKE) -C $(TORSOCKS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
torsocks-dirclean:
	rm -rf $(BUILD_DIR)/$(TORSOCKS_DIR) $(TORSOCKS_BUILD_DIR) $(TORSOCKS_IPK_DIR) $(TORSOCKS_IPK)
#
#
# Some sanity check for the package.
#
torsocks-check: $(TORSOCKS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
