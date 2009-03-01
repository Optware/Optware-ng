###########################################################
#
# hdparm
#
###########################################################

#
# HDPARM_VERSION, HDPARM_SITE and HDPARM_SOURCE define
# the upstream location of the source code for the package.
# HDPARM_DIR is the directory which is created when the source
# archive is unpacked.
# HDPARM_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
HDPARM_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/hdparm
HDPARM_VERSION=9.12
HDPARM_SOURCE=hdparm-$(HDPARM_VERSION).tar.gz
HDPARM_DIR=hdparm-$(HDPARM_VERSION)
HDPARM_UNZIP=zcat
HDPARM_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
HDPARM_DESCRIPTION=Linux hard drive parameter utility
HDPARM_SECTION=util
HDPARM_PRIORITY=optional
HDPARM_DEPENDS=

#
# HDPARM_IPK_VERSION should be incremented when the ipk changes.
#
HDPARM_IPK_VERSION=1

#
# HDPARM_LOCALES defines which locales get installed
#
HDPARM_LOCALES=

#
# HDPARM_CONFFILES should be a list of user-editable files
#HDPARM_CONFFILES=/opt/etc/hdparm.conf /opt/etc/init.d/SXXhdparm

#
# HDPARM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HDPARM_PATCHES=$(strip \
$(if $(or \
	$(filter modutils, $(PACKAGES)), \
	$(filter fsg3v4, $(OPTWARE_TARGET))), \
$(HDPARM_SOURCE_DIR)/linux2.4-u64.patch,))

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HDPARM_CPPFLAGS=
HDPARM_LDFLAGS=

#
# HDPARM_BUILD_DIR is the directory in which the build is done.
# HDPARM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HDPARM_IPK_DIR is the directory in which the ipk is built.
# HDPARM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HDPARM_BUILD_DIR=$(BUILD_DIR)/hdparm
HDPARM_SOURCE_DIR=$(SOURCE_DIR)/hdparm
HDPARM_IPK_DIR=$(BUILD_DIR)/hdparm-$(HDPARM_VERSION)-ipk
HDPARM_IPK=$(BUILD_DIR)/hdparm_$(HDPARM_VERSION)-$(HDPARM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(HDPARM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hdparm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HDPARM_PRIORITY)" >>$@
	@echo "Section: $(HDPARM_SECTION)" >>$@
	@echo "Version: $(HDPARM_VERSION)-$(HDPARM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HDPARM_MAINTAINER)" >>$@
	@echo "Source: $(HDPARM_SITE)/$(HDPARM_SOURCE)" >>$@
	@echo "Description: $(HDPARM_DESCRIPTION)" >>$@
	@echo "Depends: $(HDPARM_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HDPARM_SOURCE):
	$(WGET) -P $(@D) $(HDPARM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hdparm-source: $(DL_DIR)/$(HDPARM_SOURCE) $(HDPARM_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(HDPARM_BUILD_DIR)/.configured: make/hdparm.mk $(DL_DIR)/$(HDPARM_SOURCE) $(HDPARM_PATCHES)
	rm -rf $(BUILD_DIR)/$(HDPARM_DIR) $(@D)
	$(HDPARM_UNZIP) $(DL_DIR)/$(HDPARM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HDPARM_PATCHES)" ; \
		then cat $(HDPARM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HDPARM_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(HDPARM_DIR) $(@D)
	sed -i -e '/^	strip/d' $(@D)/Makefile
	touch $@

hdparm-unpack: $(HDPARM_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(HDPARM_BUILD_DIR)/.built: $(HDPARM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		binprefix=/opt manprefix=/opt \
		CC=$(TARGET_CC) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
		STRIP=$(TARGET_STRIP)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
hdparm: $(HDPARM_BUILD_DIR)/.built
#
# This builds the IPK file.
#
# Binaries should be installed into $(HDPARM_IPK_DIR)/opt/sbin or $(HDPARM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HDPARM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HDPARM_IPK_DIR)/opt/etc/hdparm/...
# Documentation files should be installed in $(HDPARM_IPK_DIR)/opt/doc/hdparm/...
# Daemon startup scripts should be installed in $(HDPARM_IPK_DIR)/opt/etc/init.d/S??hdparm
#
# You may need to patch your application to make it use these locations.
#
$(HDPARM_IPK): $(HDPARM_BUILD_DIR)/.built
	rm -rf $(HDPARM_IPK_DIR) $(BUILD_DIR)/hdparm_*_$(TARGET_ARCH).ipk
	install -d $(HDPARM_IPK_DIR)/opt/sbin
	$(MAKE) -C $(HDPARM_BUILD_DIR) DESTDIR=$(HDPARM_IPK_DIR) install \
		binprefix=/opt manprefix=/opt \
		CC=$(TARGET_CC) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(STRIP_COMMAND) $(HDPARM_IPK_DIR)/opt/sbin/hdparm
	mv $(HDPARM_IPK_DIR)/opt/sbin/hdparm $(HDPARM_IPK_DIR)/opt/sbin/hdparm-hdparm
	$(MAKE) $(HDPARM_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh" ; \
	 echo "update-alternatives --install /opt/sbin/hdparm hdparm /opt/sbin/hdparm-hdparm 50" ; \
	) > $(HDPARM_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh" ; \
	 echo "update-alternatives --remove hdparm /opt/sbin/hdparm-hdparm" ; \
	) > $(HDPARM_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HDPARM_IPK_DIR)/CONTROL/postinst $(HDPARM_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HDPARM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hdparm-ipk: $(HDPARM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hdparm-clean:
	-$(MAKE) -C $(HDPARM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hdparm-dirclean:
	rm -rf $(BUILD_DIR)/$(HDPARM_DIR) $(HDPARM_BUILD_DIR) $(HDPARM_IPK_DIR) $(HDPARM_IPK)

#
# Some sanity check for the package.
#
hdparm-check: $(HDPARM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
