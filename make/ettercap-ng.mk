###########################################################
#
# ettercap-ng
#
###########################################################

# You must replace "ettercap-ng" and "ETTERCAP-NG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ETTERCAP-NG_VERSION, ETTERCAP-NG_SITE and ETTERCAP-NG_SOURCE define
# the upstream location of the source code for the package.
# ETTERCAP-NG_DIR is the directory which is created when the source
# archive is unpacked.
# ETTERCAP-NG_UNZIP is the command used to unzip the source.
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
ETTERCAP-NG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ettercap
ETTERCAP-NG_VERSION=0.7.3
ETTERCAP-NG_SOURCE=ettercap-NG-$(ETTERCAP-NG_VERSION).tar.gz
ETTERCAP-NG_DIR=ettercap-NG-$(ETTERCAP-NG_VERSION)
ETTERCAP-NG_UNZIP=zcat
ETTERCAP-NG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ETTERCAP-NG_DESCRIPTION=Ettercap is a suite for man in the middle attacks on LAN. It features sniffing of live connections, content filtering on the fly and many other interesting tricks.
ETTERCAP-NG_SECTION=net
ETTERCAP-NG_PRIORITY=optional
ETTERCAP-NG_DEPENDS=libtool, libpcap, ncurses
#ETTERCAP-NG_SUGGESTS=
#ETTERCAP-NG_CONFLICTS=

#
# ETTERCAP-NG_IPK_VERSION should be incremented when the ipk changes.
#
ETTERCAP-NG_IPK_VERSION=2

#
# ETTERCAP-NG_CONFFILES should be a list of user-editable files
#ETTERCAP-NG_CONFFILES=/opt/etc/ettercap-ng.conf /opt/etc/init.d/SXXettercap-ng

#
# ETTERCAP-NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ETTERCAP-NG_PATCHES=$(ETTERCAP-NG_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ETTERCAP-NG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
ETTERCAP-NG_LDFLAGS=

#
# ETTERCAP-NG_BUILD_DIR is the directory in which the build is done.
# ETTERCAP-NG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ETTERCAP-NG_IPK_DIR is the directory in which the ipk is built.
# ETTERCAP-NG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ETTERCAP-NG_BUILD_DIR=$(BUILD_DIR)/ettercap-ng
ETTERCAP-NG_SOURCE_DIR=$(SOURCE_DIR)/ettercap-ng
ETTERCAP-NG_IPK_DIR=$(BUILD_DIR)/ettercap-ng-$(ETTERCAP-NG_VERSION)-ipk
ETTERCAP-NG_IPK=$(BUILD_DIR)/ettercap-ng_$(ETTERCAP-NG_VERSION)-$(ETTERCAP-NG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ettercap-ng-source ettercap-ng-unpack ettercap-ng ettercap-ng-stage ettercap-ng-ipk ettercap-ng-clean ettercap-ng-dirclean ettercap-ng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ETTERCAP-NG_SOURCE):
	$(WGET) -P $(@D) $(ETTERCAP-NG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ettercap-ng-source: $(DL_DIR)/$(ETTERCAP-NG_SOURCE) $(ETTERCAP-NG_PATCHES)

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
$(ETTERCAP-NG_BUILD_DIR)/.configured: $(DL_DIR)/$(ETTERCAP-NG_SOURCE) $(ETTERCAP-NG_PATCHES) make/ettercap-ng.mk
	$(MAKE) libnet11-stage libpcap-stage openssl-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(ETTERCAP-NG_DIR) $(@D)
	$(ETTERCAP-NG_UNZIP) $(DL_DIR)/$(ETTERCAP-NG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ETTERCAP-NG_PATCHES)" ; \
		then cat $(ETTERCAP-NG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ETTERCAP-NG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ETTERCAP-NG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ETTERCAP-NG_DIR) $(@D) ; \
	fi
	cp -f $(SOURCE_DIR)/common/config.* $(@D)/
#	autoreconf -vi $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ETTERCAP-NG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ETTERCAP-NG_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--includedir=$(STAGING_INCLUDE_DIR) \
		--without-openssl \
		--with-libtool \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-gtk \
		COPTS="$(STAGING_CPPFLAGS) $(ETTERCAP-NG_CPPFLAGS)" \
		LOPTS="$(STAGING_LDFLAGS) $(ETTERCAP-NG_LDFLAGS)" \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ettercap-ng-unpack: $(ETTERCAP-NG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ETTERCAP-NG_BUILD_DIR)/.built: $(ETTERCAP-NG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ettercap-ng: $(ETTERCAP-NG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ETTERCAP-NG_BUILD_DIR)/.staged: $(ETTERCAP-NG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ettercap-ng-stage: $(ETTERCAP-NG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ettercap-ng
#
$(ETTERCAP-NG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ettercap-ng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ETTERCAP-NG_PRIORITY)" >>$@
	@echo "Section: $(ETTERCAP-NG_SECTION)" >>$@
	@echo "Version: $(ETTERCAP-NG_VERSION)-$(ETTERCAP-NG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ETTERCAP-NG_MAINTAINER)" >>$@
	@echo "Source: $(ETTERCAP-NG_SITE)/$(ETTERCAP-NG_SOURCE)" >>$@
	@echo "Description: $(ETTERCAP-NG_DESCRIPTION)" >>$@
	@echo "Depends: $(ETTERCAP-NG_DEPENDS)" >>$@
	@echo "Suggests: $(ETTERCAP-NG_SUGGESTS)" >>$@
	@echo "Conflicts: $(ETTERCAP-NG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ETTERCAP-NG_IPK_DIR)/opt/sbin or $(ETTERCAP-NG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ETTERCAP-NG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ETTERCAP-NG_IPK_DIR)/opt/etc/ettercap-ng/...
# Documentation files should be installed in $(ETTERCAP-NG_IPK_DIR)/opt/doc/ettercap-ng/...
# Daemon startup scripts should be installed in $(ETTERCAP-NG_IPK_DIR)/opt/etc/init.d/S??ettercap-ng
#
# You may need to patch your application to make it use these locations.
#
$(ETTERCAP-NG_IPK): $(ETTERCAP-NG_BUILD_DIR)/.built
	rm -rf $(ETTERCAP-NG_IPK_DIR) $(BUILD_DIR)/ettercap-ng_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ETTERCAP-NG_BUILD_DIR) DESTDIR=$(ETTERCAP-NG_IPK_DIR) install
	$(STRIP_COMMAND) $(ETTERCAP-NG_IPK_DIR)/opt/bin/ettercap
	$(MAKE) $(ETTERCAP-NG_IPK_DIR)/CONTROL/control
	echo $(ETTERCAP-NG_CONFFILES) | sed -e 's/ /\n/g' > $(ETTERCAP-NG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ETTERCAP-NG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ettercap-ng-ipk: $(ETTERCAP-NG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ettercap-ng-clean:
	rm -f $(ETTERCAP-NG_BUILD_DIR)/.built
	-$(MAKE) -C $(ETTERCAP-NG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ettercap-ng-dirclean:
	rm -rf $(BUILD_DIR)/$(ETTERCAP-NG_DIR) $(ETTERCAP-NG_BUILD_DIR) $(ETTERCAP-NG_IPK_DIR) $(ETTERCAP-NG_IPK)
#
#
# Some sanity check for the package.
#
ettercap-ng-check: $(ETTERCAP-NG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
