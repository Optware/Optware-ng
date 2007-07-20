###########################################################
#
# nttcp
#
###########################################################
#
# NTTCP_VERSION, NTTCP_SITE and NTTCP_SOURCE define
# the upstream location of the source code for the package.
# NTTCP_DIR is the directory which is created when the source
# archive is unpacked.
# NTTCP_UNZIP is the command used to unzip the source.
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
NTTCP_SITE=http://freeware.sgi.com/source/nttcp
NTTCP_VERSION=1.47
NTTCP_SOURCE=nttcp-$(NTTCP_VERSION).tar.gz
NTTCP_DIR=nttcp-$(NTTCP_VERSION)
NTTCP_UNZIP=zcat
NTTCP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NTTCP_DESCRIPTION=Network performance testing tool
NTTCP_SECTION=net
NTTCP_PRIORITY=optional
NTTCP_DEPENDS=
NTTCP_SUGGESTS=
NTTCP_CONFLICTS=

#
# NTTCP_IPK_VERSION should be incremented when the ipk changes.
#
NTTCP_IPK_VERSION=1

#
# NTTCP_CONFFILES should be a list of user-editable files
NTTCP_CONFFILES=

#
# NTTCP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NTTCP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NTTCP_CPPFLAGS=
NTTCP_LDFLAGS=-Wl,-rpath,/opt/lib

#
# NTTCP_BUILD_DIR is the directory in which the build is done.
# NTTCP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NTTCP_IPK_DIR is the directory in which the ipk is built.
# NTTCP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NTTCP_BUILD_DIR=$(BUILD_DIR)/nttcp
NTTCP_SOURCE_DIR=$(SOURCE_DIR)/nttcp
NTTCP_IPK_DIR=$(BUILD_DIR)/nttcp-$(NTTCP_VERSION)-ipk
NTTCP_IPK=$(BUILD_DIR)/nttcp_$(NTTCP_VERSION)-$(NTTCP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nttcp-source nttcp-unpack nttcp nttcp-stage nttcp-ipk nttcp-clean nttcp-dirclean nttcp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NTTCP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTTCP_SITE)/$(NTTCP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NTTCP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nttcp-source: $(DL_DIR)/$(NTTCP_SOURCE) $(NTTCP_PATCHES)

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
$(NTTCP_BUILD_DIR)/.configured: $(DL_DIR)/$(NTTCP_SOURCE) $(NTTCP_PATCHES) make/nttcp.mk
	rm -rf $(BUILD_DIR)/$(NTTCP_DIR) $(NTTCP_BUILD_DIR)
	$(NTTCP_UNZIP) $(DL_DIR)/$(NTTCP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NTTCP_PATCHES)" ; \
		then cat $(NTTCP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NTTCP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NTTCP_DIR)" != "$(NTTCP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NTTCP_DIR) $(NTTCP_BUILD_DIR) ; \
	fi
	touch $@

nttcp-unpack: $(NTTCP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NTTCP_BUILD_DIR)/.built: $(NTTCP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NTTCP_BUILD_DIR) ARCH= CC=$(TARGET_CC) LDFLAGS=$(NTTCP_LDFLAGS)
	touch $@

#
# This is the build convenience target.
#
nttcp: $(NTTCP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NTTCP_BUILD_DIR)/.staged: $(NTTCP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NTTCP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

nttcp-stage: $(NTTCP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nttcp
#
$(NTTCP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nttcp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTTCP_PRIORITY)" >>$@
	@echo "Section: $(NTTCP_SECTION)" >>$@
	@echo "Version: $(NTTCP_VERSION)-$(NTTCP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTTCP_MAINTAINER)" >>$@
	@echo "Source: $(NTTCP_SITE)/$(NTTCP_SOURCE)" >>$@
	@echo "Description: $(NTTCP_DESCRIPTION)" >>$@
	@echo "Depends: $(NTTCP_DEPENDS)" >>$@
	@echo "Suggests: $(NTTCP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NTTCP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NTTCP_IPK_DIR)/opt/sbin or $(NTTCP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NTTCP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NTTCP_IPK_DIR)/opt/etc/nttcp/...
# Documentation files should be installed in $(NTTCP_IPK_DIR)/opt/doc/nttcp/...
# Daemon startup scripts should be installed in $(NTTCP_IPK_DIR)/opt/etc/init.d/S??nttcp
#
# You may need to patch your application to make it use these locations.
#
$(NTTCP_IPK): $(NTTCP_BUILD_DIR)/.built
	rm -rf $(NTTCP_IPK_DIR) $(BUILD_DIR)/nttcp_*_$(TARGET_ARCH).ipk
	install -d $(NTTCP_IPK_DIR)/opt/bin
	install $(NTTCP_BUILD_DIR)/nttcp $(NTTCP_IPK_DIR)/opt/bin/nttcp
	$(TARGET_STRIP) $(NTTCP_IPK_DIR)/opt/bin/nttcp
	install -d $(NTTCP_IPK_DIR)/opt/man/man1
	install -m 644 $(NTTCP_BUILD_DIR)/nttcp.1 $(NTTCP_IPK_DIR)/opt/man/man1/nttcp.1
	$(MAKE) $(NTTCP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTTCP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nttcp-ipk: $(NTTCP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nttcp-clean:
	rm -f $(NTTCP_BUILD_DIR)/.built
	-$(MAKE) -C $(NTTCP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nttcp-dirclean:
	rm -rf $(BUILD_DIR)/$(NTTCP_DIR) $(NTTCP_BUILD_DIR) $(NTTCP_IPK_DIR) $(NTTCP_IPK)
#
#
# Some sanity check for the package.
#
nttcp-check: $(NTTCP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NTTCP_IPK)
