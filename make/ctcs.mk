###########################################################
#
# ctcs
#
###########################################################

# CTCS_VERSION, CTCS_SITE and CTCS_SOURCE define
# the upstream location of the source code for the package.
# CTCS_DIR is the directory which is created when the source
# archive is unpacked.
# CTCS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
CTCS_SITE=http://www.rahul.net/dholmes/ctorrent
CTCS_VERSION=1.4
CTCS_SOURCE=ctcs-$(CTCS_VERSION).tar.gz
CTCS_DIR=ctcs-$(CTCS_VERSION)
CTCS_UNZIP=zcat
CTCS_MAINTAINER=Fernando Carolo <carolo@gmail.com>
CTCS_DESCRIPTION=CTorrent Control Server (CTCS) is an interface for monitoring and managing Enhanced CTorrent clients
CTCS_SECTION=net
CTCS_PRIORITY=optional
CTCS_DEPENDS=perl
CTCS_SUGGESTS=
CTCS_CONFLICTS=

#
# CTCS_IPK_VERSION should be incremented when the ipk changes.
#
CTCS_IPK_VERSION=9

#
# CTCS_CONFFILES should be a list of user-editable files
#
# currently, there is a init.d script that starts the server and
# a configuration file with startup options
CTCS_CONFFILES=/opt/etc/ctcs.conf /opt/etc/init.d/S90ctcs

#
# CTCS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CTCS_PATCHES=$(CTCS_SOURCE_DIR)/socket.patch \
	$(CTCS_SOURCE_DIR)/perl.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CTCS_CPPFLAGS=
CTCS_LDFLAGS=

#
# CTCS_BUILD_DIR is the directory in which the build is done.
# CTCS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CTCS_IPK_DIR is the directory in which the ipk is built.
# CTCS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CTCS_BUILD_DIR=$(BUILD_DIR)/ctcs
CTCS_SOURCE_DIR=$(SOURCE_DIR)/ctcs
CTCS_IPK_DIR=$(BUILD_DIR)/ctcs-$(CTCS_VERSION)-ipk
CTCS_IPK=$(BUILD_DIR)/ctcs_$(CTCS_VERSION)-$(CTCS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CTCS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CTCS_SITE)/$(CTCS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ctcs-source: $(DL_DIR)/$(CTCS_SOURCE) $(CTCS_PATCHES)

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
# CTCS is actually a perl script, so there is no need to
# compile anything, just apply the patches
$(CTCS_BUILD_DIR)/.configured: $(DL_DIR)/$(CTCS_SOURCE) $(CTCS_PATCHES) make/ctcs.mk
	rm -rf $(BUILD_DIR)/$(CTCS_DIR) $(CTCS_BUILD_DIR)
	$(CTCS_UNZIP) $(DL_DIR)/$(CTCS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CTCS_PATCHES)" ; \
		then cat $(CTCS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CTCS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CTCS_DIR)" != "$(CTCS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CTCS_DIR) $(CTCS_BUILD_DIR) ; \
	fi
	touch $(CTCS_BUILD_DIR)/.configured

ctcs-unpack: $(CTCS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# There is no actual binary to build. Unpacking the source and
# applying the patches is all that is necessary.
#
$(CTCS_BUILD_DIR)/.built: $(CTCS_BUILD_DIR)/.configured
	touch $(CTCS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ctcs: $(CTCS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ctcs
#
$(CTCS_IPK_DIR)/CONTROL/control:
	@install -d $(CTCS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ctcs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CTCS_PRIORITY)" >>$@
	@echo "Section: $(CTCS_SECTION)" >>$@
	@echo "Version: $(CTCS_VERSION)-$(CTCS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CTCS_MAINTAINER)" >>$@
	@echo "Source: $(CTCS_SITE)/$(CTCS_SOURCE)" >>$@
	@echo "Description: $(CTCS_DESCRIPTION)" >>$@
	@echo "Depends: $(CTCS_DEPENDS)" >>$@
	@echo "Suggests: $(CTCS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CTCS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CTCS_IPK_DIR)/opt/sbin or $(CTCS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CTCS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CTCS_IPK_DIR)/opt/etc/ctcs/...
# Documentation files should be installed in $(CTCS_IPK_DIR)/opt/doc/ctcs/...
# Daemon startup scripts should be installed in $(CTCS_IPK_DIR)/opt/etc/init.d/S??ctcs
#
# You may need to patch your application to make it use these locations.
#
$(CTCS_IPK): $(CTCS_BUILD_DIR)/.built
	rm -rf $(CTCS_IPK_DIR) $(BUILD_DIR)/ctcs_*_$(TARGET_ARCH).ipk
	install -d $(CTCS_IPK_DIR)/opt/bin
	install -m 755 $(CTCS_BUILD_DIR)/ctcs $(CTCS_IPK_DIR)/opt/bin/ctcs
	install -d $(CTCS_IPK_DIR)/opt/doc/ctcs
	install -m 755 $(CTCS_SOURCE_DIR)/README.nslu2 $(CTCS_IPK_DIR)/opt/doc/ctcs/README.nslu2
	install -m 755 $(CTCS_SOURCE_DIR)/readme.txt $(CTCS_IPK_DIR)/opt/doc/ctcs/readme.txt
	install -d $(CTCS_IPK_DIR)/opt/etc
	install -m 755 $(CTCS_SOURCE_DIR)/ctcs.conf $(CTCS_IPK_DIR)/opt/etc/ctcs.conf
	install -d $(CTCS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CTCS_SOURCE_DIR)/rc.ctcs $(CTCS_IPK_DIR)/opt/etc/init.d/S90ctcs
	$(MAKE) $(CTCS_IPK_DIR)/CONTROL/control
	install -m 755 $(CTCS_SOURCE_DIR)/postinst $(CTCS_IPK_DIR)/CONTROL/postinst
	install -m 755 $(CTCS_SOURCE_DIR)/prerm $(CTCS_IPK_DIR)/CONTROL/prerm
	echo $(CTCS_CONFFILES) | sed -e 's/ /\n/g' > $(CTCS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CTCS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ctcs-ipk: $(CTCS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ctcs-clean:
	rm -f $(CTCS_BUILD_DIR)/.built
	-$(MAKE) -C $(CTCS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ctcs-dirclean:
	rm -rf $(BUILD_DIR)/$(CTCS_DIR) $(CTCS_BUILD_DIR) $(CTCS_IPK_DIR) $(CTCS_IPK)

#
#
# Some sanity check for the package.
#
ctcs-check: $(CTCS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CTCS_IPK)
