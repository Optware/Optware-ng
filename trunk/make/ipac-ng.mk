###########################################################
#
# ipac-ng
#
###########################################################

IPAC-NG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ipac-ng
IPAC-NG_VERSION=1.31
IPAC-NG_SOURCE=ipac-ng-$(IPAC-NG_VERSION).tar.gz
IPAC-NG_DIR=ipac-ng-$(IPAC-NG_VERSION)
IPAC-NG_UNZIP=zcat
IPAC-NG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPAC-NG_DESCRIPTION=iptables/ipchains based IP accounting package for Linux.
IPAC-NG_SECTION=net
IPAC-NG_PRIORITY=optional
IPAC-NG_DEPENDS=gdbm, sqlite2, iptables
IPAC-NG_SUGGESTS=rrdtool, drraw
IPAC-NG_CONFLICTS=

#
# IPAC-NG_IPK_VERSION should be incremented when the ipk changes.
#
IPAC-NG_IPK_VERSION=1

#
# IPAC-NG_CONFFILES should be a list of user-editable files
IPAC-NG_CONFFILES= \
	/opt/etc/ipac-ng/ipac.conf \
	/opt/etc/ipac-ng/rules.conf

#
# IPAC-NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPAC-NG_PATCHES= \
	$(IPAC-NG_SOURCE_DIR)/subst-hostcc.patch \
	$(IPAC-NG_SOURCE_DIR)/ipt-lib-dir.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPAC-NG_CPPFLAGS=
IPAC-NG_LDFLAGS=

#
# IPAC-NG_BUILD_DIR is the directory in which the build is done.
# IPAC-NG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPAC-NG_IPK_DIR is the directory in which the ipk is built.
# IPAC-NG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPAC-NG_BUILD_DIR=$(BUILD_DIR)/ipac-ng
IPAC-NG_SOURCE_DIR=$(SOURCE_DIR)/ipac-ng
IPAC-NG_IPK_DIR=$(BUILD_DIR)/ipac-ng-$(IPAC-NG_VERSION)-ipk
IPAC-NG_IPK=$(BUILD_DIR)/ipac-ng_$(IPAC-NG_VERSION)-$(IPAC-NG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipac-ng-source ipac-ng-unpack ipac-ng ipac-ng-stage ipac-ng-ipk ipac-ng-clean ipac-ng-dirclean ipac-ng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPAC-NG_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPAC-NG_SITE)/$(IPAC-NG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(IPAC-NG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipac-ng-source: $(DL_DIR)/$(IPAC-NG_SOURCE) $(IPAC-NG_PATCHES)

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
$(IPAC-NG_BUILD_DIR)/.configured: $(DL_DIR)/$(IPAC-NG_SOURCE) $(IPAC-NG_PATCHES) make/ipac-ng.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(IPAC-NG_DIR) $(IPAC-NG_BUILD_DIR)
	$(IPAC-NG_UNZIP) $(DL_DIR)/$(IPAC-NG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IPAC-NG_PATCHES)" ; \
		then cat $(IPAC-NG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IPAC-NG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IPAC-NG_DIR)" != "$(IPAC-NG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IPAC-NG_DIR) $(IPAC-NG_BUILD_DIR) ; \
	fi
	(cd $(IPAC-NG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPAC-NG_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(IPAC-NG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPAC-NG_LDFLAGS)" \
		ipac_datadir=/opt/var/lib/ipac \
		RUNFILE=/opt/var/run/ipac.rules \
		PIDFILE=/opt/var/run/ipac.pid \
		RECONFLAG=/opt/var/lib/ipac/flag \
		STATUSFILE=/opt/var/run/ipac.status \
		LOCKFILE=/opt/var/lock/ipac.lck \
		IPTABLES=/opt/sbin/iptables \
		PERL=/opt/sbin/perl \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-confdir=/opt/etc/ipac-ng \
		--enable-default-storage=gdbm \
		--enable-default-agent=iptables \
		--disable-nls \
		--disable-static \
	)
	touch $@

ipac-ng-unpack: $(IPAC-NG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPAC-NG_BUILD_DIR)/.built: $(IPAC-NG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(IPAC-NG_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $@

#
# This is the build convenience target.
#
ipac-ng: $(IPAC-NG_BUILD_DIR)/.built

ipac-ng-stage:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipac-ng
#
$(IPAC-NG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ipac-ng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPAC-NG_PRIORITY)" >>$@
	@echo "Section: $(IPAC-NG_SECTION)" >>$@
	@echo "Version: $(IPAC-NG_VERSION)-$(IPAC-NG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPAC-NG_MAINTAINER)" >>$@
	@echo "Source: $(IPAC-NG_SITE)/$(IPAC-NG_SOURCE)" >>$@
	@echo "Description: $(IPAC-NG_DESCRIPTION)" >>$@
	@echo "Depends: $(IPAC-NG_DEPENDS)" >>$@
	@echo "Suggests: $(IPAC-NG_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPAC-NG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPAC-NG_IPK_DIR)/opt/sbin or $(IPAC-NG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPAC-NG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPAC-NG_IPK_DIR)/opt/etc/ipac-ng/...
# Documentation files should be installed in $(IPAC-NG_IPK_DIR)/opt/doc/ipac-ng/...
# Daemon startup scripts should be installed in $(IPAC-NG_IPK_DIR)/opt/etc/init.d/S??ipac-ng
#
# You may need to patch your application to make it use these locations.
#
$(IPAC-NG_IPK): $(IPAC-NG_BUILD_DIR)/.built
	rm -rf $(IPAC-NG_IPK_DIR) $(BUILD_DIR)/ipac-ng_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IPAC-NG_BUILD_DIR) DESTDIR=$(IPAC-NG_IPK_DIR) doinstall
	sed -i -e 's|^#!/usr/bin/perl|#!/opt/bin/perl|' $(IPAC-NG_IPK_DIR)/opt/sbin/ipacsum
	install -d $(IPAC-NG_IPK_DIR)/opt/etc/ipac-ng
	install -m 644 $(IPAC-NG_SOURCE_DIR)/ipac.conf $(IPAC-NG_IPK_DIR)/opt/etc/ipac-ng/
	install -m 644 $(IPAC-NG_SOURCE_DIR)/rules.conf $(IPAC-NG_IPK_DIR)/opt/etc/ipac-ng/
	$(MAKE) $(IPAC-NG_IPK_DIR)/CONTROL/control
	install -m 755 $(IPAC-NG_SOURCE_DIR)/postinst $(IPAC-NG_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IPAC-NG_IPK_DIR)/CONTROL/postinst
	echo $(IPAC-NG_CONFFILES) | sed -e 's/ /\n/g' > $(IPAC-NG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPAC-NG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipac-ng-ipk: $(IPAC-NG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipac-ng-clean:
	rm -f $(IPAC-NG_BUILD_DIR)/.built
	-$(MAKE) -C $(IPAC-NG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipac-ng-dirclean:
	rm -rf $(BUILD_DIR)/$(IPAC-NG_DIR) $(IPAC-NG_BUILD_DIR) $(IPAC-NG_IPK_DIR) $(IPAC-NG_IPK)
#
#
# Some sanity check for the package.
#
ipac-ng-check: $(IPAC-NG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPAC-NG_IPK)
