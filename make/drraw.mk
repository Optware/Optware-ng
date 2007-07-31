###########################################################
#
# drraw
#
###########################################################

DRRAW_SITE=http://web.taranis.org/drraw/dist
DRRAW_VERSION=2.2a4
DRRAW_SOURCE=drraw-$(DRRAW_VERSION).tar.gz
DRRAW_DIR=drraw-$(DRRAW_VERSION)
DRRAW_UNZIP=zcat
DRRAW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DRRAW_DESCRIPTION=Simple web based presentation front-end for RRDtool.
DRRAW_SECTION=utils
DRRAW_PRIORITY=optional
DRRAW_DEPENDS=
DRRAW_SUGGESTS=
DRRAW_CONFLICTS=

#
# DRRAW_IPK_VERSION should be incremented when the ipk changes.
#
DRRAW_IPK_VERSION=1

#
# DRRAW_CONFFILES should be a list of user-editable files
DRRAW_CONFFILES=/opt/etc/drraw.conf

#
# DRRAW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DRRAW_PATCHES=$(DRRAW_SOURCE_DIR)/config-location.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DRRAW_CPPFLAGS=
DRRAW_LDFLAGS=

#
# DRRAW_BUILD_DIR is the directory in which the build is done.
# DRRAW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DRRAW_IPK_DIR is the directory in which the ipk is built.
# DRRAW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DRRAW_BUILD_DIR=$(BUILD_DIR)/drraw
DRRAW_SOURCE_DIR=$(SOURCE_DIR)/drraw
DRRAW_IPK_DIR=$(BUILD_DIR)/drraw-$(DRRAW_VERSION)-ipk
DRRAW_IPK=$(BUILD_DIR)/drraw_$(DRRAW_VERSION)-$(DRRAW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: drraw-source drraw-unpack drraw drraw-stage drraw-ipk drraw-clean drraw-dirclean drraw-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DRRAW_SOURCE):
	$(WGET) -P $(DL_DIR) $(DRRAW_SITE)/$(DRRAW_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DRRAW_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
drraw-source: $(DL_DIR)/$(DRRAW_SOURCE) $(DRRAW_PATCHES)

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
$(DRRAW_BUILD_DIR)/.configured: $(DL_DIR)/$(DRRAW_SOURCE) $(DRRAW_PATCHES) make/drraw.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DRRAW_DIR) $(DRRAW_BUILD_DIR)
	$(DRRAW_UNZIP) $(DL_DIR)/$(DRRAW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DRRAW_PATCHES)" ; \
		then cat $(DRRAW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DRRAW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DRRAW_DIR)" != "$(DRRAW_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DRRAW_DIR) $(DRRAW_BUILD_DIR) ; \
	fi
	touch $@

drraw-unpack: $(DRRAW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DRRAW_BUILD_DIR)/.built: $(DRRAW_BUILD_DIR)/.configured
	touch $@

#
# This is the build convenience target.
#
drraw: $(DRRAW_BUILD_DIR)/.built

drraw-stage:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/drraw
#
$(DRRAW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: drraw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DRRAW_PRIORITY)" >>$@
	@echo "Section: $(DRRAW_SECTION)" >>$@
	@echo "Version: $(DRRAW_VERSION)-$(DRRAW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DRRAW_MAINTAINER)" >>$@
	@echo "Source: $(DRRAW_SITE)/$(DRRAW_SOURCE)" >>$@
	@echo "Description: $(DRRAW_DESCRIPTION)" >>$@
	@echo "Depends: $(DRRAW_DEPENDS)" >>$@
	@echo "Suggests: $(DRRAW_SUGGESTS)" >>$@
	@echo "Conflicts: $(DRRAW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DRRAW_IPK_DIR)/opt/sbin or $(DRRAW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DRRAW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DRRAW_IPK_DIR)/opt/etc/drraw/...
# Documentation files should be installed in $(DRRAW_IPK_DIR)/opt/doc/drraw/...
# Daemon startup scripts should be installed in $(DRRAW_IPK_DIR)/opt/etc/init.d/S??drraw
#
# You may need to patch your application to make it use these locations.
#
$(DRRAW_IPK): $(DRRAW_BUILD_DIR)/.built
	rm -rf $(DRRAW_IPK_DIR) $(BUILD_DIR)/drraw_*_$(TARGET_ARCH).ipk
	install -d $(DRRAW_IPK_DIR)/opt/share/www/cgi-bin
	install -m 644 $(DRRAW_BUILD_DIR)/drraw.cgi $(DRRAW_IPK_DIR)/opt/share/www/cgi-bin/drraw.cgi
ifeq ($(OPTWARE_TARGET), fsg3v4)
	install -d $(DRRAW_IPK_DIR)/var/www/cgi-bin
	ln -s /opt/share/www/cgi-bin/drraw.cgi $(DRRAW_IPK_DIR)/var/www/cgi-bin/drraw.cgi
endif
	install -d $(DRRAW_IPK_DIR)/opt/etc/
	install -m 644 $(DRRAW_SOURCE_DIR)/drraw.conf $(DRRAW_IPK_DIR)/opt/etc/drraw.conf
	$(MAKE) $(DRRAW_IPK_DIR)/CONTROL/control
	install -m 755 $(DRRAW_SOURCE_DIR)/postinst $(DRRAW_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DRRAW_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DRRAW_SOURCE_DIR)/prerm $(DRRAW_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DRRAW_IPK_DIR)/CONTROL/prerm
	echo $(DRRAW_CONFFILES) | sed -e 's/ /\n/g' > $(DRRAW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DRRAW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
drraw-ipk: $(DRRAW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
drraw-clean:
	rm -f $(DRRAW_BUILD_DIR)/.built
	-$(MAKE) -C $(DRRAW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
drraw-dirclean:
	rm -rf $(BUILD_DIR)/$(DRRAW_DIR) $(DRRAW_BUILD_DIR) $(DRRAW_IPK_DIR) $(DRRAW_IPK)
#
#
# Some sanity check for the package.
#
drraw-check: $(DRRAW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DRRAW_IPK)
