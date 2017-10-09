###########################################################
#
# miniupnpd
#
###########################################################

# You must replace "miniupnpd" and "MINIUPNPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MINIUPNPD_VERSION, MINIUPNPD_SITE and MINIUPNPD_SOURCE define
# the upstream location of the source code for the package.
# MINIUPNPD_DIR is the directory which is created when the source
# archive is unpacked.
# MINIUPNPD_UNZIP is the command used to unzip the source.
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
MINIUPNPD_SITE=http://miniupnp.free.fr/files
MINIUPNPD_VERSION=1.9.20141209
MINIUPNPD_SOURCE=miniupnpd-$(MINIUPNPD_VERSION).tar.gz
MINIUPNPD_DIR=miniupnpd-$(MINIUPNPD_VERSION)
MINIUPNPD_UNZIP=zcat
MINIUPNPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIUPNPD_DESCRIPTION=A lightweight uPNP and NAT-PMP daemon
MINIUPNPD_SECTION=net
MINIUPNPD_PRIORITY=optional
MINIUPNPD_DEPENDS=iptables, openssl, libnfnetlink, start-stop-daemon
MINIUPNPD_CONFLICTS=

#
# MINIUPNPD_IPK_VERSION should be incremented when the ipk changes.
#
MINIUPNPD_IPK_VERSION=4

#
# MINIUPNPD_CONFFILES should be a list of user-editable files
#
MINIUPNPD_CONFFILES=$(TARGET_PREFIX)/etc/miniupnpd/minupnpd.conf $(TARGET_PREFIX)/etc/init.d/miniupnpd

#
# MINIUPNPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIUPNPD_PATCHES=$(MINIUPNPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIUPNPD_CPPFLAGS=-DIPTABLES_143 -DMINIUPNPD_LOG_NOPID
MINIUPNPD_LDFLAGS=

#
# MINIUPNPD_BUILD_DIR is the directory in which the build is done.
# MINIUPNPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIUPNPD_IPK_DIR is the directory in which the ipk is built.
# MINIUPNPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIUPNPD_BUILD_DIR=$(BUILD_DIR)/miniupnpd
MINIUPNPD_SOURCE_DIR=$(SOURCE_DIR)/miniupnpd
MINIUPNPD_IPK_DIR=$(BUILD_DIR)/miniupnpd-$(MINIUPNPD_VERSION)-ipk
MINIUPNPD_IPK=$(BUILD_DIR)/miniupnpd_$(MINIUPNPD_VERSION)-$(MINIUPNPD_IPK_VERSION)_$(TARGET_ARCH).ipk
MINIUPNPD_INST_DIR=$(TARGET_PREFIX)


.PHONY: miniupnpd-source miniupnpd-unpack miniupnpd miniupnpd-stage miniupnpd-ipk miniupnpd-clean miniupnpd-dirclean miniupnpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINIUPNPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MINIUPNPD_SITE)/$(MINIUPNPD_SOURCE) 

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
miniupnpd-source: $(DL_DIR)/$(MINIUPNPD_SOURCE) $(MINIUPNPD_PATCHES)

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
$(MINIUPNPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MINIUPNPD_SOURCE) $(MINIUPNPD_PATCHES) make/miniupnpd.mk
	$(MAKE) iptables-stage openssl-stage libnfnetlink-stage
	rm -rf $(BUILD_DIR)/$(MINIUPNPD_DIR) $(@D)
	$(MINIUPNPD_UNZIP) $(DL_DIR)/$(MINIUPNPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINIUPNPD_PATCHES)" ; \
		then cat $(MINIUPNPD_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(MINIUPNPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MINIUPNPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINIUPNPD_DIR) $(@D) ; \
	fi
ifneq ($(IPV6), yes)
	sed -i -e '/#define ENABLE_IPV6/s|^|//|' $(@D)/config.h.optware
endif
	touch $@

miniupnpd-unpack: $(MINIUPNPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# Miniupnpd does not use gnu automake, so we need to override the default
# search paths for the compile to use the correct cross-compiler
#
$(MINIUPNPD_BUILD_DIR)/.built: $(MINIUPNPD_BUILD_DIR)/.configured
	rm -f $@	
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIUPNPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIUPNPD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		PREFIX=$(TARGET_PREFIX) \
		$(MAKE) -f Makefile.optware all \
	)
	touch $@

#
# This is the build convenience target.
#
miniupnpd: $(MINIUPNPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIUPNPD_BUILD_DIR)/.staged: $(MINIUPNPD_BUILD_DIR)/.built
	rm -f $@
	touch $@

miniupnpd-stage: $(MINIUPNPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/miniupnpd
#
$(MINIUPNPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: miniupnpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIUPNPD_PRIORITY)" >>$@
	@echo "Section: $(MINIUPNPD_SECTION)" >>$@
	@echo "Version: $(MINIUPNPD_VERSION)-$(MINIUPNPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIUPNPD_MAINTAINER)" >>$@
	@echo "Source: $(MINIUPNPD_SITE)/$(MINIUPNPD_SOURCE)" >>$@
	@echo "Description: $(MINIUPNPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIUPNPD_DEPENDS)" >>$@
	@echo "Conflicts: $(MINIUPNPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/MINIUPNPD/...
# Documentation files should be installed in $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/doc/MINIUPNPD/...
# Daemon startup scripts should be installed in $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??MINIUPNPD
#
# You may need to patch your application to make it use these locations.
#
$(MINIUPNPD_IPK): $(MINIUPNPD_BUILD_DIR)/.built
	rm -rf $(MINIUPNPD_IPK_DIR) $(BUILD_DIR)/miniupnpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIUPNPD_BUILD_DIR) -f Makefile.optware STRIP="$(STRIP_COMMAND)" PREFIX=$(TARGET_PREFIX) DESTDIR=$(MINIUPNPD_IPK_DIR) install
	rm -f $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/info/dir $(MINIUPNPD_IPK_DIR)$(TARGET_PREFIX)/info/dir.old
	$(MAKE) $(MINIUPNPD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIUPNPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
miniupnpd-ipk: $(MINIUPNPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
miniupnpd-clean:
	rm -f $(MINIUPNPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIUPNPD_BUILD_DIR) -f Makefile.optware clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
miniupnpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIUPNPD_DIR) $(MINIUPNPD_BUILD_DIR) $(MINIUPNPD_IPK_DIR) $(MINIUPNPD_IPK)

#
#
# Some sanity check for the package.
#
miniupnpd-check: $(MINIUPNPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MINIUPNPD_IPK)
