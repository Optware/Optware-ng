###########################################################
#
# apcupsd
#
###########################################################
#
# APCUPSD_VERSION, APCUPSD_SITE and APCUPSD_SOURCE define
# the upstream location of the source code for the package.
# APCUPSD_DIR is the directory which is created when the source
# archive is unpacked.
# APCUPSD_UNZIP is the command used to unzip the source.
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
APCUPSD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/apcupsd
APCUPSD_VERSION=3.14.2
APCUPSD_SOURCE=apcupsd-$(APCUPSD_VERSION).tar.gz
APCUPSD_DIR=apcupsd-$(APCUPSD_VERSION)
APCUPSD_UNZIP=zcat
APCUPSD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
APCUPSD_DESCRIPTION=A daemon for controlling APC UPSes.
APCUPSD_SECTION=sysadmin
APCUPSD_PRIORITY=optional
APCUPSD_DEPENDS=
APCUPSD_SUGGESTS=
APCUPSD_CONFLICTS=

#
# APCUPSD_IPK_VERSION should be incremented when the ipk changes.
#
APCUPSD_IPK_VERSION=2

#
# APCUPSD_CONFFILES should be a list of user-editable files
APCUPSD_CONFFILES=/opt/etc/apcupsd/apcupsd.conf
#/opt/etc/init.d/SXXapcupsd

#
# APCUPSD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#APCUPSD_PATCHES=$(APCUPSD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APCUPSD_CPPFLAGS=
APCUPSD_LDFLAGS=

#
# APCUPSD_BUILD_DIR is the directory in which the build is done.
# APCUPSD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APCUPSD_IPK_DIR is the directory in which the ipk is built.
# APCUPSD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APCUPSD_BUILD_DIR=$(BUILD_DIR)/apcupsd
APCUPSD_SOURCE_DIR=$(SOURCE_DIR)/apcupsd
APCUPSD_IPK_DIR=$(BUILD_DIR)/apcupsd-$(APCUPSD_VERSION)-ipk
APCUPSD_IPK=$(BUILD_DIR)/apcupsd_$(APCUPSD_VERSION)-$(APCUPSD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: apcupsd-source apcupsd-unpack apcupsd apcupsd-stage apcupsd-ipk apcupsd-clean apcupsd-dirclean apcupsd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(APCUPSD_SOURCE):
	$(WGET) -P $(DL_DIR) $(APCUPSD_SITE)/$(APCUPSD_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(APCUPSD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
apcupsd-source: $(DL_DIR)/$(APCUPSD_SOURCE) $(APCUPSD_PATCHES)

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
$(APCUPSD_BUILD_DIR)/.configured: $(DL_DIR)/$(APCUPSD_SOURCE) $(APCUPSD_PATCHES) make/apcupsd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(APCUPSD_DIR) $(@D)
	$(APCUPSD_UNZIP) $(DL_DIR)/$(APCUPSD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(APCUPSD_PATCHES)" ; \
		then cat $(APCUPSD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(APCUPSD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(APCUPSD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(APCUPSD_DIR) $(@D) ; \
	fi
	sed -i -e 's|prefix=NONE|prefix=/opt|' $(@D)/configure
	cp -f $(SOURCE_DIR)/common/config.* $(@D)/autoconf/
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APCUPSD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APCUPSD_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-distname=unknown \
		--prefix=/opt \
		--sbindir=/opt/sbin \
		--sysconfdir=/opt/etc/apcupsd \
		--mandir=/opt/share/man \
		--with-nologin=/opt/etc/apcupsd \
		--with-pid-dir=/opt/var/run \
		--with-log-dir=/opt/var/log \
		--with-lock-dir=/opt/var/lock \
		--enable-usb \
		--disable-nls \
		--disable-static \
	)
	touch $@

apcupsd-unpack: $(APCUPSD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(APCUPSD_BUILD_DIR)/.built: $(APCUPSD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
apcupsd: $(APCUPSD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(APCUPSD_BUILD_DIR)/.staged: $(APCUPSD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

apcupsd-stage: $(APCUPSD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/apcupsd
#
$(APCUPSD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: apcupsd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APCUPSD_PRIORITY)" >>$@
	@echo "Section: $(APCUPSD_SECTION)" >>$@
	@echo "Version: $(APCUPSD_VERSION)-$(APCUPSD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APCUPSD_MAINTAINER)" >>$@
	@echo "Source: $(APCUPSD_SITE)/$(APCUPSD_SOURCE)" >>$@
	@echo "Description: $(APCUPSD_DESCRIPTION)" >>$@
	@echo "Depends: $(APCUPSD_DEPENDS)" >>$@
	@echo "Suggests: $(APCUPSD_SUGGESTS)" >>$@
	@echo "Conflicts: $(APCUPSD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(APCUPSD_IPK_DIR)/opt/sbin or $(APCUPSD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APCUPSD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APCUPSD_IPK_DIR)/opt/etc/apcupsd/...
# Documentation files should be installed in $(APCUPSD_IPK_DIR)/opt/doc/apcupsd/...
# Daemon startup scripts should be installed in $(APCUPSD_IPK_DIR)/opt/etc/init.d/S??apcupsd
#
# You may need to patch your application to make it use these locations.
#
$(APCUPSD_IPK): $(APCUPSD_BUILD_DIR)/.built
	rm -rf $(APCUPSD_IPK_DIR) $(BUILD_DIR)/apcupsd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(APCUPSD_BUILD_DIR) DESTDIR=$(APCUPSD_IPK_DIR) install
	$(STRIP_COMMAND) $(APCUPSD_IPK_DIR)/opt/sbin/*
#	install -d $(APCUPSD_IPK_DIR)/opt/etc/
#	install -m 644 $(APCUPSD_SOURCE_DIR)/apcupsd.conf $(APCUPSD_IPK_DIR)/opt/etc/apcupsd.conf
#	install -d $(APCUPSD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(APCUPSD_SOURCE_DIR)/rc.apcupsd $(APCUPSD_IPK_DIR)/opt/etc/init.d/SXXapcupsd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APCUPSD_IPK_DIR)/opt/etc/init.d/SXXapcupsd
	$(MAKE) $(APCUPSD_IPK_DIR)/CONTROL/control
#	install -m 755 $(APCUPSD_SOURCE_DIR)/postinst $(APCUPSD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APCUPSD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(APCUPSD_SOURCE_DIR)/prerm $(APCUPSD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APCUPSD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(APCUPSD_IPK_DIR)/CONTROL/postinst $(APCUPSD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(APCUPSD_CONFFILES) | sed -e 's/ /\n/g' > $(APCUPSD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APCUPSD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
apcupsd-ipk: $(APCUPSD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
apcupsd-clean:
	rm -f $(APCUPSD_BUILD_DIR)/.built
	-$(MAKE) -C $(APCUPSD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
apcupsd-dirclean:
	rm -rf $(BUILD_DIR)/$(APCUPSD_DIR) $(APCUPSD_BUILD_DIR) $(APCUPSD_IPK_DIR) $(APCUPSD_IPK)
#
#
# Some sanity check for the package.
#
apcupsd-check: $(APCUPSD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(APCUPSD_IPK)
