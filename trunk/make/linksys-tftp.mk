###########################################################
#
# linksys-tftp
#
###########################################################

#
# LINKSYS-TFTP_VERSION, LINKSYS-TFTP_SITE and LINKSYS-TFTP_SOURCE define
# the upstream location of the source code for the package.
# LINKSYS-TFTP_DIR is the directory which is created when the source
# archive is unpacked.
# LINKSYS-TFTP_UNZIP is the command used to unzip the source.
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
LINKSYS-TFTP_SITE=http://redsand.net/projects/linksys-tftp/pub
LINKSYS-TFTP_VERSION=1.2.1
LINKSYS-TFTP_SOURCE=linksys-tftp-$(LINKSYS-TFTP_VERSION).tar.gz
LINKSYS-TFTP_DIR=linksys-tftp-$(LINKSYS-TFTP_VERSION)
LINKSYS-TFTP_UNZIP=zcat
LINKSYS-TFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LINKSYS-TFTP_DESCRIPTION=TFTP Client customized for a non-standard tftp authentication process.
LINKSYS-TFTP_SECTION=net
LINKSYS-TFTP_PRIORITY=optional
LINKSYS-TFTP_DEPENDS=
LINKSYS-TFTP_SUGGESTS=
LINKSYS-TFTP_CONFLICTS=

#
# LINKSYS-TFTP_IPK_VERSION should be incremented when the ipk changes.
#
LINKSYS-TFTP_IPK_VERSION=1

#
# LINKSYS-TFTP_BUILD_DIR is the directory in which the build is done.
# LINKSYS-TFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LINKSYS-TFTP_IPK_DIR is the directory in which the ipk is built.
# LINKSYS-TFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LINKSYS-TFTP_BUILD_DIR=$(BUILD_DIR)/linksys-tftp
LINKSYS-TFTP_SOURCE_DIR=$(SOURCE_DIR)/linksys-tftp
LINKSYS-TFTP_IPK_DIR=$(BUILD_DIR)/linksys-tftp-$(LINKSYS-TFTP_VERSION)-ipk
LINKSYS-TFTP_IPK=$(BUILD_DIR)/linksys-tftp_$(LINKSYS-TFTP_VERSION)-$(LINKSYS-TFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: linksys-tftp-source linksys-tftp-unpack linksys-tftp linksys-tftp-ipk linksys-tftp-clean linksys-tftp-dirclean linksys-tftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LINKSYS-TFTP_SOURCE):
	$(WGET) -P $(@D) $(LINKSYS-TFTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
linksys-tftp-source: $(DL_DIR)/$(LINKSYS-TFTP_SOURCE) $(LINKSYS-TFTP_PATCHES)

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
$(LINKSYS-TFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(LINKSYS-TFTP_SOURCE) $(LINKSYS-TFTP_PATCHES) make/linksys-tftp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LINKSYS-TFTP_DIR) $(@D)
	$(LINKSYS-TFTP_UNZIP) $(DL_DIR)/$(LINKSYS-TFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LINKSYS-TFTP_PATCHES)" ; \
		then cat $(LINKSYS-TFTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LINKSYS-TFTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LINKSYS-TFTP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LINKSYS-TFTP_DIR) $(@D) ; \
	fi
	touch $@

linksys-tftp-unpack: $(LINKSYS-TFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LINKSYS-TFTP_BUILD_DIR)/.built: $(LINKSYS-TFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS)
	touch $@

#
# This is the build convenience target.
#
linksys-tftp: $(LINKSYS-TFTP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/linksys-tftp
#
$(LINKSYS-TFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: linksys-tftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LINKSYS-TFTP_PRIORITY)" >>$@
	@echo "Section: $(LINKSYS-TFTP_SECTION)" >>$@
	@echo "Version: $(LINKSYS-TFTP_VERSION)-$(LINKSYS-TFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LINKSYS-TFTP_MAINTAINER)" >>$@
	@echo "Source: $(LINKSYS-TFTP_SITE)/$(LINKSYS-TFTP_SOURCE)" >>$@
	@echo "Description: $(LINKSYS-TFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(LINKSYS-TFTP_DEPENDS)" >>$@
	@echo "Suggests: $(LINKSYS-TFTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LINKSYS-TFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LINKSYS-TFTP_IPK_DIR)/opt/sbin or $(LINKSYS-TFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LINKSYS-TFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LINKSYS-TFTP_IPK_DIR)/opt/etc/linksys-tftp/...
# Documentation files should be installed in $(LINKSYS-TFTP_IPK_DIR)/opt/doc/linksys-tftp/...
# Daemon startup scripts should be installed in $(LINKSYS-TFTP_IPK_DIR)/opt/etc/init.d/S??linksys-tftp
#
# You may need to patch your application to make it use these locations.
#
$(LINKSYS-TFTP_IPK): $(LINKSYS-TFTP_BUILD_DIR)/.built
	rm -rf $(LINKSYS-TFTP_IPK_DIR) $(BUILD_DIR)/linksys-tftp_*_$(TARGET_ARCH).ipk
	install -d $(LINKSYS-TFTP_IPK_DIR)/opt/bin/
	install -m 755 $(LINKSYS-TFTP_BUILD_DIR)/linksys-tftp $(LINKSYS-TFTP_IPK_DIR)/opt/bin/linksys-tftp
	$(MAKE) $(LINKSYS-TFTP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LINKSYS-TFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
linksys-tftp-ipk: $(LINKSYS-TFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
linksys-tftp-clean:
	rm -f $(LINKSYS-TFTP_BUILD_DIR)/.built
	-$(MAKE) -C $(LINKSYS-TFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
linksys-tftp-dirclean:
	rm -rf $(BUILD_DIR)/$(LINKSYS-TFTP_DIR) $(LINKSYS-TFTP_BUILD_DIR) $(LINKSYS-TFTP_IPK_DIR) $(LINKSYS-TFTP_IPK)
#
#
# Some sanity check for the package.
#
linksys-tftp-check: $(LINKSYS-TFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LINKSYS-TFTP_IPK)
