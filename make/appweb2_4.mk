###########################################################
#
# appweb2_4
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
# TODO:
# 	Debug the installation!!!
#
APPWEB2_4_SITE=http://www.appwebserver.org/software
APPWEB2_4_VERSION=2.4.2
APPWEB2_4_VERSION_EXTRA=2
APPWEB2_4_SOURCE=appweb-src-$(APPWEB2_4_VERSION)-$(APPWEB2_4_VERSION_EXTRA).tar.gz
APPWEB2_4_DIR=appweb-src-$(APPWEB2_4_VERSION)
APPWEB2_4_UNZIP=zcat
APPWEB2_4_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
APPWEB2_4_DESCRIPTION=AppWeb is the leading web server technology for embedding in devices and applications. Supports embedded javascript, CGI, Virtual Sites, SSL, user passwords, virtual directories - all with minimal memory footprint.
APPWEB2_4_SECTION=net
APPWEB2_4_PRIORITY=optional
APPWEB2_4_DEPENDS=openssl, php-embed
APPWEB2_4_SUGGESTS=
APPWEB2_4_CONFLICTS=appweb

#
# APPWEB2_4_IPK_VERSION should be incremented when the ipk changes.
#
APPWEB2_4_IPK_VERSION=1

#
# APPWEB2_4_CONFFILES should be a list of user-editable files
#APPWEB2_4_CONFFILES=/opt/etc/appweb2_4.conf /opt/etc/init.d/SXXappweb2_4

#
# APPWEB2_4_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# APPWEB2_4_PATCHES=$(APPWEB2_4_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APPWEB2_4_CPPFLAGS=
APPWEB2_4_LDFLAGS=

ifeq ($(OPTWARE_TARGET),nslu2)
#
# NOTE: -mcpu=armv5b doens't work with gcc!
# 
APPWEB2_4_TARGET_NAME=xscale-nslu2-linux
else
APPWEB2_4_TARGET_NAME=$(GNU_TARGET_NAME)
endif

#
# APPWEB2_4_BUILD_DIR is the directory in which the build is done.
# APPWEB2_4_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APPWEB2_4_IPK_DIR is the directory in which the ipk is built.
# APPWEB2_4_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APPWEB2_4_BUILD_DIR=$(BUILD_DIR)/appweb2_4
APPWEB2_4_SOURCE_DIR=$(SOURCE_DIR)/appweb2_4
APPWEB2_4_IPK_DIR=$(BUILD_DIR)/appweb2_4-$(APPWEB2_4_VERSION)-ipk
APPWEB2_4_IPK=$(BUILD_DIR)/appweb2_4_$(APPWEB2_4_VERSION)-$(APPWEB2_4_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: appweb2_4-source appweb2_4-unpack appweb2_4 appweb2_4-stage appweb2_4-ipk appweb2_4-clean appweb2_4-dirclean appweb2_4-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(APPWEB2_4_SOURCE):
	$(WGET) -P $(DL_DIR) $(APPWEB2_4_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
appweb2_4-source: $(DL_DIR)/$(APPWEB2_4_SOURCE) $(APPWEB2_4_PATCHES)

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
$(APPWEB2_4_BUILD_DIR)/.configured: $(DL_DIR)/$(APPWEB2_4_SOURCE) $(APPWEB2_4_PATCHES) make/appweb2_4.mk
	$(MAKE) openssl-stage php-stage
	rm -rf $(BUILD_DIR)/$(APPWEB2_4_DIR) $(@D)
	$(APPWEB2_4_UNZIP) $(DL_DIR)/$(APPWEB2_4_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(APPWEB2_4_PATCHES)" ; \
		then cat $(APPWEB2_4_PATCHES) | \
		patch -d $(BUILD_DIR)/$(APPWEB2_4_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(APPWEB2_4_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(APPWEB2_4_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APPWEB2_4_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APPWEB2_4_LDFLAGS)" \
		./configure \
			--prefix=/opt \
			--sbinDir=/opt/sbin \
			--host=$(APPWEB2_4_TARGET_NAME) \
			--buildNumber=$(APPWEB2_4_IPK_VERSION) \
	)
	touch $@

appweb2_4-unpack: $(APPWEB2_4_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(APPWEB2_4_BUILD_DIR)/.built: $(APPWEB2_4_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
appweb2_4: $(APPWEB2_4_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(APPWEB2_4_BUILD_DIR)/.staged: $(APPWEB2_4_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

appweb2_4-stage: $(APPWEB2_4_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/appweb2_4
#
$(APPWEB2_4_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: appweb2_4" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APPWEB2_4_PRIORITY)" >>$@
	@echo "Section: $(APPWEB2_4_SECTION)" >>$@
	@echo "Version: $(APPWEB2_4_VERSION)-$(APPWEB2_4_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APPWEB2_4_MAINTAINER)" >>$@
	@echo "Source: $(APPWEB2_4_SITE)/$(APPWEB2_4_SOURCE)" >>$@
	@echo "Description: $(APPWEB2_4_DESCRIPTION)" >>$@
	@echo "Depends: $(APPWEB2_4_DEPENDS)" >>$@
	@echo "Suggests: $(APPWEB2_4_SUGGESTS)" >>$@
	@echo "Conflicts: $(APPWEB2_4_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(APPWEB2_4_IPK_DIR)/opt/sbin or $(APPWEB2_4_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APPWEB2_4_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APPWEB2_4_IPK_DIR)/opt/etc/appweb2_4/...
# Documentation files should be installed in $(APPWEB2_4_IPK_DIR)/opt/doc/appweb2_4/...
# Daemon startup scripts should be installed in $(APPWEB2_4_IPK_DIR)/opt/etc/init.d/S??appweb2_4
#
# You may need to patch your application to make it use these locations.
#
$(APPWEB2_4_IPK): $(APPWEB2_4_BUILD_DIR)/.built
	rm -rf $(APPWEB2_4_IPK_DIR) $(BUILD_DIR)/appweb2_4_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(APPWEB2_4_BUILD_DIR) DESTDIR=$(APPWEB2_4_IPK_DIR) install-package
#	install -d $(APPWEB2_4_IPK_DIR)/opt/etc/
#	install -m 644 $(APPWEB2_4_SOURCE_DIR)/appweb2_4.conf $(APPWEB2_4_IPK_DIR)/opt/etc/appweb2_4.conf
#	install -d $(APPWEB2_4_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(APPWEB2_4_SOURCE_DIR)/rc.appweb2_4 $(APPWEB2_4_IPK_DIR)/opt/etc/init.d/SXXappweb2_4
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APPWEB2_4_IPK_DIR)/opt/etc/init.d/SXXappweb2_4
	$(MAKE) $(APPWEB2_4_IPK_DIR)/CONTROL/control
#	install -m 755 $(APPWEB2_4_SOURCE_DIR)/postinst $(APPWEB2_4_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APPWEB2_4_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(APPWEB2_4_SOURCE_DIR)/prerm $(APPWEB2_4_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(APPWEB2_4_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(APPWEB2_4_IPK_DIR)/CONTROL/postinst $(APPWEB2_4_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(APPWEB2_4_CONFFILES) | sed -e 's/ /\n/g' > $(APPWEB2_4_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APPWEB2_4_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
appweb2_4-ipk: $(APPWEB2_4_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
appweb2_4-clean:
	rm -f $(APPWEB2_4_BUILD_DIR)/.built
	-$(MAKE) -C $(APPWEB2_4_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
appweb2_4-dirclean:
	rm -rf $(BUILD_DIR)/$(APPWEB2_4_DIR) $(APPWEB2_4_BUILD_DIR) $(APPWEB2_4_IPK_DIR) $(APPWEB2_4_IPK)
#
#
# Some sanity check for the package.
#
appweb2_4-check: $(APPWEB2_4_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(APPWEB2_4_IPK)
