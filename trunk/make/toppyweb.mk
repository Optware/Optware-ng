###########################################################
#
# toppyweb
#
###########################################################

TOPPYWEB_SITE=http://www.qmtech.com/topfield/
TOPPYWEB_VERSION=3.3.3
TOPPYWEB_SOURCE=toppyweb.v$(TOPPYWEB_VERSION).zip
TOPPYWEB_DIR=toppyweb-$(TOPPYWEB_VERSION)
TOPPYWEB_UNZIP=unzip -a
TOPPYWEB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TOPPYWEB_DESCRIPTION=Manage your Topfield PVR Timers and Recordings over the Internet
TOPPYWEB_SECTION=util
TOPPYWEB_PRIORITY=optional
TOPPYWEB_DEPENDS=lighttpd, php, php-fcgi, perltgd
TOPPYWEB_SUGGESTS=
TOPPYWEB_CONFLICTS=

#
# TOPPYWEB_IPK_VERSION should be incremented when the ipk changes.
#
TOPPYWEB_IPK_VERSION=2

#
# TOPPYWEB_CONFFILES should be a list of user-editable files
TOPPYWEB_CONFFILES=/opt/etc/toppyweb/config.ini

#
# TOPPYWEB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# TOPPYWEB_PATCHES=$(TOPPYWEB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TOPPYWEB_CPPFLAGS=
TOPPYWEB_LDFLAGS=

#
# TOPPYWEB_BUILD_DIR is the directory in which the build is done.
# TOPPYWEB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TOPPYWEB_IPK_DIR is the directory in which the ipk is built.
# TOPPYWEB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TOPPYWEB_BUILD_DIR=$(BUILD_DIR)/toppyweb
TOPPYWEB_SOURCE_DIR=$(SOURCE_DIR)/toppyweb
TOPPYWEB_IPK_DIR=$(BUILD_DIR)/toppyweb-$(TOPPYWEB_VERSION)-ipk
TOPPYWEB_IPK=$(BUILD_DIR)/toppyweb_$(TOPPYWEB_VERSION)-$(TOPPYWEB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: toppyweb-source toppyweb-unpack toppyweb toppyweb-stage toppyweb-ipk toppyweb-clean toppyweb-dirclean toppyweb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TOPPYWEB_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOPPYWEB_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
toppyweb-source: $(DL_DIR)/$(TOPPYWEB_SOURCE) $(TOPPYWEB_PATCHES)

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
$(TOPPYWEB_BUILD_DIR)/.configured: $(DL_DIR)/$(TOPPYWEB_SOURCE) $(TOPPYWEB_PATCHES) make/toppyweb.mk
	rm -rf $(BUILD_DIR)/$(TOPPYWEB_DIR) $(@D)
	mkdir $(BUILD_DIR)/$(TOPPYWEB_DIR) ; \
	cd $(BUILD_DIR)/$(TOPPYWEB_DIR) ; $(TOPPYWEB_UNZIP) $(DL_DIR)/$(TOPPYWEB_SOURCE)
	if test -n "$(TOPPYWEB_PATCHES)" ; \
		then cat $(TOPPYWEB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TOPPYWEB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TOPPYWEB_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TOPPYWEB_DIR) $(@D) ; \
	fi
	touch $@

toppyweb-unpack: $(TOPPYWEB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TOPPYWEB_BUILD_DIR)/.built: $(TOPPYWEB_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
toppyweb: $(TOPPYWEB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TOPPYWEB_BUILD_DIR)/.staged: $(TOPPYWEB_BUILD_DIR)/.built
	rm -f $@
	touch $@

toppyweb-stage: $(TOPPYWEB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/toppyweb
#
$(TOPPYWEB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: toppyweb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TOPPYWEB_PRIORITY)" >>$@
	@echo "Section: $(TOPPYWEB_SECTION)" >>$@
	@echo "Version: $(TOPPYWEB_VERSION)-$(TOPPYWEB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TOPPYWEB_MAINTAINER)" >>$@
	@echo "Source: $(TOPPYWEB_SITE)/$(TOPPYWEB_SOURCE)" >>$@
	@echo "Description: $(TOPPYWEB_DESCRIPTION)" >>$@
	@echo "Depends: $(TOPPYWEB_DEPENDS)" >>$@
	@echo "Suggests: $(TOPPYWEB_SUGGESTS)" >>$@
	@echo "Conflicts: $(TOPPYWEB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TOPPYWEB_IPK_DIR)/opt/sbin or $(TOPPYWEB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TOPPYWEB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TOPPYWEB_IPK_DIR)/opt/etc/toppyweb/...
# Documentation files should be installed in $(TOPPYWEB_IPK_DIR)/opt/doc/toppyweb/...
# Daemon startup scripts should be installed in $(TOPPYWEB_IPK_DIR)/opt/etc/init.d/S??toppyweb
#
# You may need to patch your application to make it use these locations.
#
$(TOPPYWEB_IPK): $(TOPPYWEB_BUILD_DIR)/.built
	rm -rf $(TOPPYWEB_IPK_DIR) $(BUILD_DIR)/toppyweb_*_$(TARGET_ARCH).ipk
	install -d $(TOPPYWEB_IPK_DIR)/opt/share/www/toppyweb
	cp -r $(TOPPYWEB_BUILD_DIR)/* $(TOPPYWEB_IPK_DIR)/opt/share/www/toppyweb/
	rm -f $(TOPPYWEB_IPK_DIR)/opt/share/www/toppyweb/config*.ini
	install -d $(TOPPYWEB_IPK_DIR)/opt/etc/toppyweb/
	echo "[General]" > $(TOPPYWEB_IPK_DIR)/opt/share/www/toppyweb/config.ini
	echo "ConfigFolder=/opt/etc/toppyweb" >> $(TOPPYWEB_IPK_DIR)/opt/share/www/toppyweb/config.ini
	install -m 644 $(TOPPYWEB_SOURCE_DIR)/config.ini $(TOPPYWEB_IPK_DIR)/opt/etc/toppyweb/config.ini
	install -d $(TOPPYWEB_IPK_DIR)/opt/var/toppyweb/
	$(MAKE) $(TOPPYWEB_IPK_DIR)/CONTROL/control
#	install -m 755 $(TOPPYWEB_SOURCE_DIR)/postinst $(TOPPYWEB_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TOPPYWEB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TOPPYWEB_SOURCE_DIR)/prerm $(TOPPYWEB_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TOPPYWEB_IPK_DIR)/CONTROL/prerm
	echo $(TOPPYWEB_CONFFILES) | sed -e 's/ /\n/g' > $(TOPPYWEB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TOPPYWEB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
toppyweb-ipk: $(TOPPYWEB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
toppyweb-clean:
	rm -f $(TOPPYWEB_BUILD_DIR)/.built
	-$(MAKE) -C $(TOPPYWEB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
toppyweb-dirclean:
	rm -rf $(BUILD_DIR)/$(TOPPYWEB_DIR) $(TOPPYWEB_BUILD_DIR) $(TOPPYWEB_IPK_DIR) $(TOPPYWEB_IPK)
#
#
# Some sanity check for the package.
#
toppyweb-check: $(TOPPYWEB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TOPPYWEB_IPK)
