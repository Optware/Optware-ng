###########################################################
#
# torrent
#
###########################################################

#
# TORRENT_VERSION, TORRENT_SITE and TORRENT_SOURCE define
# the upstream location of the source code for the package.
# TORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# TORRENT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TORRENT_SITE=
TORRENT_VERSION=1.4
TORRENT_SOURCE=
TORRENT_DIR=torrent-$(TORRENT_VERSION)
TORRENT_UNZIP=zcat
TORRENT_PRIORITY=optional
TORRENT_DEPENDS=libbt
TORRENT_MAINTAINER=oleo <oleon@users.sourceforge.net>
TORRENT_SECTION=net
TORRENT_DESCRIPTION=a collection of scripts that processes torrent files
TORRENT_SUGGESTS=cron, coreutils

#
# TORRENT_IPK_VERSION should be incremented when the ipk changes.
#
TORRENT_IPK_VERSION=1

# TORRENT_CONFFILES should be a list of user-editable files
TORRENT_CONFFILES=/opt/etc/torrent.conf /opt/etc/init.d/S80busybox_httpd

#
# TORRENT_BUILD_DIR is the directory in which the build is done.
# TORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TORRENT_IPK_DIR is the directory in which the ipk is built.
# TORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TORRENT_BUILD_DIR=$(BUILD_DIR)/torrent
TORRENT_SOURCE_DIR=$(SOURCE_DIR)/torrent
TORRENT_IPK_DIR=$(BUILD_DIR)/torrent-$(TORRENT_VERSION)-ipk
TORRENT_IPK=$(BUILD_DIR)/torrent_$(TORRENT_VERSION)-$(TORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
torrent-source: 

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
$(TORRENT_BUILD_DIR)/.configured:
	rm -rf $(BUILD_DIR)/$(TORRENT_DIR) $(TORRENT_BUILD_DIR)
	mkdir -p $(TORRENT_BUILD_DIR)
	touch $(TORRENT_BUILD_DIR)/.configured

torrent-unpack: $(TORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
torrent: $(TORRENT_BUILD_DIR)/.configured

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/torrent
#
$(TORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(TORRENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: torrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TORRENT_PRIORITY)" >>$@
	@echo "Section: $(TORRENT_SECTION)" >>$@
	@echo "Version: $(TORRENT_VERSION)-$(TORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TORRENT_MAINTAINER)" >>$@
	@echo "Source: $(TORRENT_SITE)/$(TORRENT_SOURCE)" >>$@
	@echo "Description: $(TORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(TORRENT_DEPENDS)" >>$@
	@echo "Conflicts: $(TORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TORRENT_IPK_DIR)/opt/sbin or $(TORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TORRENT_IPK_DIR)/opt/etc/torrent/...
# Documentation files should be installed in $(TORRENT_IPK_DIR)/opt/doc/torrent/...
# Daemon startup scripts should be installed in $(TORRENT_IPK_DIR)/opt/etc/init.d/S??torrent
#
# You may need to patch your application to make it use these locations.
#
$(TORRENT_IPK): $(TORRENT_BUILD_DIR)/.configured
	rm -rf $(TORRENT_IPK_DIR) $(BUILD_DIR)/torrent_*_$(TARGET_ARCH).ipk
	mkdir -p $(TORRENT_IPK_DIR)/CONTROL
	$(MAKE) $(TORRENT_IPK_DIR)/CONTROL/control
	install -m 644 $(SOURCE_DIR)/torrent/postinst $(TORRENT_IPK_DIR)/CONTROL/postinst
	install -d $(TORRENT_IPK_DIR)/opt/bin
	install -d $(TORRENT_IPK_DIR)/opt/sbin
	install -d $(TORRENT_IPK_DIR)/opt/etc/init.d
	install -d $(TORRENT_IPK_DIR)/opt/share/www/cgi-bin
	install -m 700 $(SOURCE_DIR)/torrent/torrent_watchdog $(TORRENT_IPK_DIR)/opt/sbin
	install -m 755 $(SOURCE_DIR)/torrent/torrent_admin $(TORRENT_IPK_DIR)/opt/sbin
	install -m 755 $(SOURCE_DIR)/torrent/btcheck-target $(TORRENT_IPK_DIR)/opt/bin
	install -m 755 $(SOURCE_DIR)/torrent/torrent.cgi $(TORRENT_IPK_DIR)/opt/share/www/cgi-bin
	install -m 644 $(SOURCE_DIR)/torrent/torrent.conf $(TORRENT_IPK_DIR)/opt/etc
	install -m 755 $(SOURCE_DIR)/torrent/S80busybox_httpd $(TORRENT_IPK_DIR)/opt/etc/init.d
	echo $(TORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(TORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
torrent-ipk: $(TORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
torrent-clean:

torrent-distclean:
#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
torrent-dirclean:
	rm -rf $(BUILD_DIR)/$(TORRENT_DIR) $(TORRENT_BUILD_DIR) $(TORRENT_IPK_DIR) $(TORRENT_IPK)
