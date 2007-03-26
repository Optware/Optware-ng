###########################################################
#
# logrotate
#
###########################################################

#
# LOGROTATE_VERSION, LOGROTATE_SITE and LOGROTATE_SOURCE define
# the upstream location of the source code for the package.
# LOGROTATE_DIR is the directory which is created when the source
# archive is unpacked.
# LOGROTATE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LOGROTATE_SITE=http://ftp.debian.org/debian/pool/main/l/logrotate
LOGROTATE_VERSION=3.7.1
LOGROTATE_SOURCE=logrotate_$(LOGROTATE_VERSION).orig.tar.gz
LOGROTATE_DIR=logrotate-$(LOGROTATE_VERSION)
LOGROTATE_UNZIP=zcat
LOGROTATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LOGROTATE_DESCRIPTION=Rotates, compresses, removes and mails system log files.
LOGROTATE_SECTION=base
LOGROTATE_PRIORITY=optional
LOGROTATE_DEPENDS=popt

#
# LOGROTATE_IPK_VERSION should be incremented when the ipk changes.
#
LOGROTATE_IPK_VERSION=4

#
# LOGROTATE_CONFFILES should be a list of user-editable files
LOGROTATE_CONFFILES=/opt/etc/logrotate.conf

#
# LOGROTATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LOGROTATE_PATCHES=$(LOGROTATE_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LOGROTATE_CPPFLAGS=
LOGROTATE_LDFLAGS=

#
# LOGROTATE_BUILD_DIR is the directory in which the build is done.
# LOGROTATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LOGROTATE_IPK_DIR is the directory in which the ipk is built.
# LOGROTATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LOGROTATE_BUILD_DIR=$(BUILD_DIR)/logrotate
LOGROTATE_SOURCE_DIR=$(SOURCE_DIR)/logrotate
LOGROTATE_IPK_DIR=$(BUILD_DIR)/logrotate-$(LOGROTATE_VERSION)-ipk
LOGROTATE_IPK=$(BUILD_DIR)/logrotate_$(LOGROTATE_VERSION)-$(LOGROTATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: logrotate-source logrotate-unpack logrotate logrotate-stage logrotate-ipk logrotate-clean logrotate-dirclean logrotate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LOGROTATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(LOGROTATE_SITE)/$(LOGROTATE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
logrotate-source: $(DL_DIR)/$(LOGROTATE_SOURCE) $(LOGROTATE_PATCHES)

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
$(LOGROTATE_BUILD_DIR)/.configured: $(DL_DIR)/$(LOGROTATE_SOURCE) $(LOGROTATE_PATCHES)
	$(MAKE) popt-stage
	rm -rf $(BUILD_DIR)/$(LOGROTATE_DIR) $(LOGROTATE_BUILD_DIR)
	$(LOGROTATE_UNZIP) $(DL_DIR)/$(LOGROTATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(LOGROTATE_PATCHES) | patch -d $(BUILD_DIR)/$(LOGROTATE_DIR) -p1
	mv $(BUILD_DIR)/$(LOGROTATE_DIR) $(LOGROTATE_BUILD_DIR)
	touch $(LOGROTATE_BUILD_DIR)/.configured

logrotate-unpack: $(LOGROTATE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LOGROTATE_BUILD_DIR)/.built: $(LOGROTATE_BUILD_DIR)/.configured
	rm -f $(LOGROTATE_BUILD_DIR)/.built
	$(MAKE) -C $(LOGROTATE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LFS="$(STAGING_CPPFLAGS) $(LOGROTATE_CPPFLAGS)" \
		LOADLIBES="$(STAGING_LDFLAGS) $(LOGROTATE_LDFLAGS) -lpopt"
	touch $(LOGROTATE_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
logrotate: $(LOGROTATE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/logrotate
#
$(LOGROTATE_IPK_DIR)/CONTROL/control:
	@install -d $(LOGROTATE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: logrotate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LOGROTATE_PRIORITY)" >>$@
	@echo "Section: $(LOGROTATE_SECTION)" >>$@
	@echo "Version: $(LOGROTATE_VERSION)-$(LOGROTATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LOGROTATE_MAINTAINER)" >>$@
	@echo "Source: $(LOGROTATE_SITE)/$(LOGROTATE_SOURCE)" >>$@
	@echo "Description: $(LOGROTATE_DESCRIPTION)" >>$@
	@echo "Depends: $(LOGROTATE_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LOGROTATE_IPK_DIR)/opt/sbin or $(LOGROTATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LOGROTATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LOGROTATE_IPK_DIR)/opt/etc/logrotate/...
# Documentation files should be installed in $(LOGROTATE_IPK_DIR)/opt/doc/logrotate/...
# Daemon startup scripts should be installed in $(LOGROTATE_IPK_DIR)/opt/etc/init.d/S??logrotate
#
# You may need to patch your application to make it use these locations.
#
$(LOGROTATE_IPK): $(LOGROTATE_BUILD_DIR)/.built
	rm -rf $(LOGROTATE_IPK_DIR) $(BUILD_DIR)/logrotate_*_$(TARGET_ARCH).ipk
	install -d $(LOGROTATE_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(LOGROTATE_BUILD_DIR)/logrotate -o $(LOGROTATE_IPK_DIR)/opt/sbin/logrotate
	install -d $(LOGROTATE_IPK_DIR)/opt/etc
	install -m 644 $(LOGROTATE_SOURCE_DIR)/logrotate.conf $(LOGROTATE_IPK_DIR)/opt/etc/logrotate.conf
	install -d $(LOGROTATE_IPK_DIR)/opt/man/man8
	install -m 644 $(LOGROTATE_BUILD_DIR)/logrotate.8 $(LOGROTATE_IPK_DIR)/opt/man/man8
	$(MAKE) $(LOGROTATE_IPK_DIR)/CONTROL/control
	install -m 644 $(LOGROTATE_SOURCE_DIR)/postinst $(LOGROTATE_IPK_DIR)/CONTROL/postinst
	install -m 644 $(LOGROTATE_SOURCE_DIR)/prerm $(LOGROTATE_IPK_DIR)/CONTROL/prerm
	echo $(LOGROTATE_CONFFILES) | sed -e 's/ /\n/g' > $(LOGROTATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LOGROTATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
logrotate-ipk: $(LOGROTATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
logrotate-clean:
	-$(MAKE) -C $(LOGROTATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
logrotate-dirclean:
	rm -rf $(BUILD_DIR)/$(LOGROTATE_DIR) $(LOGROTATE_BUILD_DIR) $(LOGROTATE_IPK_DIR) $(LOGROTATE_IPK)
#
#
# Some sanity check for the package.
#
logrotate-check: $(LOGROTATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LOGROTATE_IPK)
