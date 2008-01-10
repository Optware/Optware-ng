###########################################################
#
# vpnc
#
###########################################################
#
# VPNC_VERSION, VPNC_SITE and VPNC_SOURCE define
# the upstream location of the source code for the package.
# VPNC_DIR is the directory which is created when the source
# archive is unpacked.
# VPNC_UNZIP is the command used to unzip the source.
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
VPNC_SITE=http://www.unix-ag.uni-kl.de/~massar/vpnc
VPNC_VERSION=0.5.1
VPNC_SOURCE=vpnc-$(VPNC_VERSION).tar.gz
VPNC_DIR=vpnc-$(VPNC_VERSION)
VPNC_UNZIP=zcat
VPNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VPNC_DESCRIPTION=Client for Cisco VPN concentrator
VPNC_SECTION=net
VPNC_PRIORITY=optional
VPNC_DEPENDS=libgcrypt kernel-module-tun
VPNC_SUGGESTS=
VPNC_CONFLICTS=

#
# VPNC_IPK_VERSION should be incremented when the ipk changes.
#
VPNC_IPK_VERSION=1

#
# VPNC_CONFFILES should be a list of user-editable files
VPNC_CONFFILES=/opt/etc/vpnc/default.conf /opt/etc/vpnc/vpnc-script

#
# VPNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VPNC_PATCHES= \
	     $(VPNC_SOURCE_DIR)/Makefile.patch \
	     $(VPNC_SOURCE_DIR)/config.c.patch \
	     $(VPNC_SOURCE_DIR)/vpnc-script.patch \
	     $(VPNC_SOURCE_DIR)/vpnc-disconnect.patch \
	     $(VPNC_SOURCE_DIR)/vpnc.conf.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VPNC_CPPFLAGS=$(shell $(STAGING_DIR)/opt/bin/libgcrypt-config --cflags)
VPNC_LDFLAGS=$(shell $(STAGING_DIR)/opt/bin/libgcrypt-config --libs)

#
# VPNC_BUILD_DIR is the directory in which the build is done.
# VPNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VPNC_IPK_DIR is the directory in which the ipk is built.
# VPNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VPNC_BUILD_DIR=$(BUILD_DIR)/vpnc
VPNC_SOURCE_DIR=$(SOURCE_DIR)/vpnc
VPNC_IPK_DIR=$(BUILD_DIR)/vpnc-$(VPNC_VERSION)-ipk
VPNC_IPK=$(BUILD_DIR)/vpnc_$(VPNC_VERSION)-$(VPNC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vpnc-source vpnc-unpack vpnc vpnc-stage vpnc-ipk vpnc-clean vpnc-dirclean vpnc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VPNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(VPNC_SITE)/$(VPNC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(VPNC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vpnc-source: $(DL_DIR)/$(VPNC_SOURCE) $(VPNC_PATCHES)

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
$(VPNC_BUILD_DIR)/.configured: $(DL_DIR)/$(VPNC_SOURCE) $(VPNC_PATCHES) make/vpnc.mk
	$(MAKE) libgcrypt-stage
	rm -rf $(BUILD_DIR)/$(VPNC_DIR) $(@D)
	$(VPNC_UNZIP) $(DL_DIR)/$(VPNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VPNC_PATCHES)" ; \
		then cat $(VPNC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VPNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VPNC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(VPNC_DIR) $(@D) ; \
	fi
	touch $@

vpnc-unpack: $(VPNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VPNC_BUILD_DIR)/.built: $(VPNC_BUILD_DIR)/.configured
	rm -f $@
	(cd $(VPNC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VPNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VPNC_LDFLAGS)" \
		$(MAKE) \
	)
	touch $@

#
# This is the build convenience target.
#
vpnc: $(VPNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VPNC_BUILD_DIR)/.staged: $(VPNC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

vpnc-stage: $(VPNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vpnc
#
$(VPNC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vpnc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VPNC_PRIORITY)" >>$@
	@echo "Section: $(VPNC_SECTION)" >>$@
	@echo "Version: $(VPNC_VERSION)-$(VPNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VPNC_MAINTAINER)" >>$@
	@echo "Source: $(VPNC_SITE)/$(VPNC_SOURCE)" >>$@
	@echo "Description: $(VPNC_DESCRIPTION)" >>$@
	@echo "Depends: $(VPNC_DEPENDS)" >>$@
	@echo "Suggests: $(VPNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(VPNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VPNC_IPK_DIR)/opt/sbin or $(VPNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VPNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VPNC_IPK_DIR)/opt/etc/vpnc/...
# Documentation files should be installed in $(VPNC_IPK_DIR)/opt/doc/vpnc/...
# Daemon startup scripts should be installed in $(VPNC_IPK_DIR)/opt/etc/init.d/S??vpnc
#
# You may need to patch your application to make it use these locations.
#
$(VPNC_IPK): $(VPNC_BUILD_DIR)/.built
	rm -rf $(VPNC_IPK_DIR) $(BUILD_DIR)/vpnc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VPNC_BUILD_DIR) DESTDIR=$(VPNC_IPK_DIR) install
	$(STRIP_COMMAND) $(VPNC_IPK_DIR)/opt/sbin/vpnc
	$(STRIP_COMMAND) $(VPNC_IPK_DIR)/opt/bin/cisco-decrypt
	install -d $(VPNC_IPK_DIR)/opt/man/man8
	install -m 644 $(VPNC_SOURCE_DIR)/vpnc.8 $(VPNC_IPK_DIR)/opt/man/man8
#	install -d $(VPNC_IPK_DIR)/opt/etc/
#	install -m 644 $(VPNC_SOURCE_DIR)/vpnc.conf $(VPNC_IPK_DIR)/opt/etc/vpnc.conf
#	install -d $(VPNC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(VPNC_SOURCE_DIR)/rc.vpnc $(VPNC_IPK_DIR)/opt/etc/init.d/SXXvpnc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VPNC_IPK_DIR)/opt/etc/init.d/SXXvpnc
	$(MAKE) $(VPNC_IPK_DIR)/CONTROL/control
#	install -m 755 $(VPNC_SOURCE_DIR)/postinst $(VPNC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VPNC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(VPNC_SOURCE_DIR)/prerm $(VPNC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VPNC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(VPNC_IPK_DIR)/CONTROL/postinst $(VPNC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(VPNC_CONFFILES) | sed -e 's/ /\n/g' > $(VPNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VPNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vpnc-ipk: $(VPNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vpnc-clean:
	rm -f $(VPNC_BUILD_DIR)/.built
	-$(MAKE) -C $(VPNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vpnc-dirclean:
	rm -rf $(BUILD_DIR)/$(VPNC_DIR) $(VPNC_BUILD_DIR) $(VPNC_IPK_DIR) $(VPNC_IPK)
#
#
# Some sanity check for the package.
#
vpnc-check: $(VPNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VPNC_IPK)
