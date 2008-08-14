###########################################################
#
# torrentflux
#
###########################################################

#
# TORRENTFLUX_VERSION, TORRENTFLUX_SITE and TORRENTFLUX_SOURCE define
# the upstream location of the source code for the package.
# TORRENTFLUX_DIR is the directory which is created when the source
# archive is unpacked.
# TORRENTFLUX_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
TORRENTFLUX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/torrentflux
TORRENTFLUX_VERSION=2.4
TORRENTFLUX_SOURCE=torrentflux_$(TORRENTFLUX_VERSION).tar.gz
TORRENTFLUX_DIR=torrentflux_$(TORRENTFLUX_VERSION)
TORRENTFLUX_UNZIP=zcat
TORRENTFLUX_MAINTAINER=Fernando Carolo <carolo@gmail.com>
TORRENTFLUX_DESCRIPTION=TorrentFlux is an web-based system for managing bit torrent file transfers.
TORRENTFLUX_SECTION=net
TORRENTFLUX_PRIORITY=optional
TORRENTFLUX_DEPENDS=php, php-fcgi, python, py-crypto, sqlite2
TORRENTFLUX_SUGGESTS=
TORRENTFLUX_CONFLICTS=

TORRENTFLUX_INSTALL_DIR=/opt/share/www/torrentflux

#
# TORRENTFLUX_IPK_VERSION should be incremented when the ipk changes.
#
TORRENTFLUX_IPK_VERSION=3

#
# TORRENTFLUX_CONFFILES should be a list of user-editable files
TORRENTFLUX_CONFFILES=

#
# TORRENTFLUX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TORRENTFLUX_PATCHES= \
	$(TORRENTFLUX_SOURCE_DIR)/config.patch \
	$(TORRENTFLUX_SOURCE_DIR)/functions.patch \
	$(TORRENTFLUX_SOURCE_DIR)/isohunt.patch \
	$(TORRENTFLUX_SOURCE_DIR)/profile.patch \
	$(TORRENTFLUX_SOURCE_DIR)/torrentbox.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TORRENTFLUX_CPPFLAGS=
TORRENTFLUX_LDFLAGS=

#
# TORRENTFLUX_BUILD_DIR is the directory in which the build is done.
# TORRENTFLUX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TORRENTFLUX_IPK_DIR is the directory in which the ipk is built.
# TORRENTFLUX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TORRENTFLUX_BUILD_DIR=$(BUILD_DIR)/torrentflux
TORRENTFLUX_SOURCE_DIR=$(SOURCE_DIR)/torrentflux
TORRENTFLUX_IPK_DIR=$(BUILD_DIR)/torrentflux-$(TORRENTFLUX_VERSION)-ipk
TORRENTFLUX_IPK=$(BUILD_DIR)/torrentflux_$(TORRENTFLUX_VERSION)-$(TORRENTFLUX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: torrentflux-source torrentflux-unpack torrentflux torrentflux-stage torrentflux-ipk torrentflux-clean torrentflux-dirclean torrentflux-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TORRENTFLUX_SOURCE):
	$(WGET) -P $(@D) $(TORRENTFLUX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
torrentflux-source: $(DL_DIR)/$(TORRENTFLUX_SOURCE) $(TORRENTFLUX_PATCHES)

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
# Since TorrentFlux is a PHP web application, this target only unpacks
# the source and applies the necessary patches.
#
$(TORRENTFLUX_BUILD_DIR)/.configured: $(DL_DIR)/$(TORRENTFLUX_SOURCE) $(TORRENTFLUX_PATCHES) make/torrentflux.mk
	rm -rf $(BUILD_DIR)/$(TORRENTFLUX_DIR) $(@D)
	$(TORRENTFLUX_UNZIP) $(DL_DIR)/$(TORRENTFLUX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TORRENTFLUX_PATCHES)" ; \
		then cat $(TORRENTFLUX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TORRENTFLUX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TORRENTFLUX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TORRENTFLUX_DIR) $(@D) ; \
	fi
	touch $@

torrentflux-unpack: $(TORRENTFLUX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# There is no actual binary to build. Unpacking the source and
# applying the patches is all that is necessary.
#
$(TORRENTFLUX_BUILD_DIR)/.built: $(TORRENTFLUX_BUILD_DIR)/.configured
	touch $@

#
# This is the build convenience target.
#
torrentflux: $(TORRENTFLUX_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/torrentflux
#
$(TORRENTFLUX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: torrentflux" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TORRENTFLUX_PRIORITY)" >>$@
	@echo "Section: $(TORRENTFLUX_SECTION)" >>$@
	@echo "Version: $(TORRENTFLUX_VERSION)-$(TORRENTFLUX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TORRENTFLUX_MAINTAINER)" >>$@
	@echo "Source: $(TORRENTFLUX_SITE)/$(TORRENTFLUX_SOURCE)" >>$@
	@echo "Description: $(TORRENTFLUX_DESCRIPTION)" >>$@
	@echo "Depends: $(TORRENTFLUX_DEPENDS)" >>$@
	@echo "Suggests: $(TORRENTFLUX_SUGGESTS)" >>$@
	@echo "Conflicts: $(TORRENTFLUX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TORRENTFLUX_IPK_DIR)/opt/sbin or $(TORRENTFLUX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TORRENTFLUX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TORRENTFLUX_IPK_DIR)/opt/etc/torrentflux/...
# Documentation files should be installed in $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux/...
# Daemon startup scripts should be installed in $(TORRENTFLUX_IPK_DIR)/opt/etc/init.d/S??torrentflux
#
# You may need to patch your application to make it use these locations.
#
$(TORRENTFLUX_IPK): $(TORRENTFLUX_BUILD_DIR)/.built
	rm -rf $(TORRENTFLUX_IPK_DIR) $(BUILD_DIR)/torrentflux_*_$(TARGET_ARCH).ipk
	install -d $(TORRENTFLUX_IPK_DIR)$(TORRENTFLUX_INSTALL_DIR)
	cp -a $(TORRENTFLUX_BUILD_DIR)/html/* $(TORRENTFLUX_IPK_DIR)$(TORRENTFLUX_INSTALL_DIR)
	# fixes permissions, leaves execute bits only for .php files
	find $(TORRENTFLUX_IPK_DIR)$(TORRENTFLUX_INSTALL_DIR) -type f ! -name \*php -exec chmod -x {} \;
	install -d $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_BUILD_DIR)/README $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_BUILD_DIR)/COPYING $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_BUILD_DIR)/CHANGELOG $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_BUILD_DIR)/INSTALL $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_SOURCE_DIR)/README.Optware $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -m 755 $(TORRENTFLUX_SOURCE_DIR)/sqlite_torrentflux.sql $(TORRENTFLUX_IPK_DIR)/opt/doc/torrentflux
	install -d $(TORRENTFLUX_IPK_DIR)/opt/var/torrentflux/db
	install -d $(TORRENTFLUX_IPK_DIR)/opt/var/torrentflux/downloads
	install -m 755 $(TORRENTFLUX_BUILD_DIR)/html/downloads/index.html $(TORRENTFLUX_IPK_DIR)/opt/var/torrentflux/downloads
	$(MAKE) $(TORRENTFLUX_IPK_DIR)/CONTROL/control
	install -m 755 $(TORRENTFLUX_SOURCE_DIR)/postinst $(TORRENTFLUX_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TORRENTFLUX_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TORRENTFLUX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
torrentflux-ipk: $(TORRENTFLUX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
torrentflux-clean:
	rm -f $(TORRENTFLUX_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
torrentflux-dirclean:
	rm -rf $(BUILD_DIR)/$(TORRENTFLUX_DIR) $(TORRENTFLUX_BUILD_DIR) $(TORRENTFLUX_IPK_DIR) $(TORRENTFLUX_IPK)
#
#
# Some sanity check for the package.
#
torrentflux-check: $(TORRENTFLUX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TORRENTFLUX_IPK)
