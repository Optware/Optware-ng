###########################################################
#
# putmail
#
###########################################################

#
# PUTMAIL_VERSION, PUTMAIL_SITE and PUTMAIL_SOURCE define
# the upstream location of the source code for the package.
# PUTMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# PUTMAIL_UNZIP is the command used to unzip the source.
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
PUTMAIL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/putmail
PUTMAIL_VERSION=1.4
PUTMAIL_SOURCE=putmail.py-$(PUTMAIL_VERSION).tar.bz2
PUTMAIL_DIR=putmail.py-$(PUTMAIL_VERSION)
PUTMAIL_UNZIP=bzcat
PUTMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PUTMAIL_DESCRIPTION=Putmail is a very lightweight MTA or SMTP client that may replace the sendmail command when used by MUAs that lack SMTP support.
PUTMAIL_SECTION=mail
PUTMAIL_PRIORITY=optional
PUTMAIL_DEPENDS=python
PUTMAIL_SUGGESTS=
PUTMAIL_CONFLICTS=

#
# PUTMAIL_IPK_VERSION should be incremented when the ipk changes.
#
PUTMAIL_IPK_VERSION=1

#
# PUTMAIL_CONFFILES should be a list of user-editable files
#PUTMAIL_CONFFILES=/opt/etc/putmail.conf /opt/etc/init.d/SXXputmail

#
# PUTMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PUTMAIL_PATCHES=$(PUTMAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PUTMAIL_CPPFLAGS=
PUTMAIL_LDFLAGS=

#
# PUTMAIL_BUILD_DIR is the directory in which the build is done.
# PUTMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PUTMAIL_IPK_DIR is the directory in which the ipk is built.
# PUTMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PUTMAIL_BUILD_DIR=$(BUILD_DIR)/putmail
PUTMAIL_SOURCE_DIR=$(SOURCE_DIR)/putmail

#PUTMAIL-COMMON_IPK_DIR=$(BUILD_DIR)/py-putmail-common-$(PUTMAIL_VERSION)-ipk
#PUTMAIL-COMMON_IPK=$(BUILD_DIR)/py-putmail-common_$(PUTMAIL_VERSION)-$(PUTMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

PUTMAIL_IPK_DIR=$(BUILD_DIR)/putmail-$(PUTMAIL_VERSION)-ipk
PUTMAIL_IPK=$(BUILD_DIR)/putmail_$(PUTMAIL_VERSION)-$(PUTMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: putmail-source putmail-unpack putmail putmail-stage putmail-ipk putmail-clean putmail-dirclean putmail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PUTMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PUTMAIL_SITE)/$(PUTMAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
putmail-source: $(DL_DIR)/$(PUTMAIL_SOURCE) $(PUTMAIL_PATCHES)

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
$(PUTMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(PUTMAIL_SOURCE) $(PUTMAIL_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PUTMAIL_BUILD_DIR)
	rm -rf $(BUILD_DIR)/$(PUTMAIL_DIR)
	$(PUTMAIL_UNZIP) $(DL_DIR)/$(PUTMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PUTMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(PUTMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(PUTMAIL_DIR) $(PUTMAIL_BUILD_DIR)
	touch $@

putmail-unpack: $(PUTMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PUTMAIL_BUILD_DIR)/.built: $(PUTMAIL_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
putmail: $(PUTMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PUTMAIL_BUILD_DIR)/.staged: $(PUTMAIL_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PUTMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

putmail-stage: $(PUTMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/putmail
#
$(PUTMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: putmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PUTMAIL_PRIORITY)" >>$@
	@echo "Section: $(PUTMAIL_SECTION)" >>$@
	@echo "Version: $(PUTMAIL_VERSION)-$(PUTMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PUTMAIL_MAINTAINER)" >>$@
	@echo "Source: $(PUTMAIL_SITE)/$(PUTMAIL_SOURCE)" >>$@
	@echo "Description: $(PUTMAIL_DESCRIPTION)" >>$@
	@echo "Depends: py-putmail-common $(PUTMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(PUTMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PUTMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PUTMAIL_IPK_DIR)/opt/sbin or $(PUTMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PUTMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PUTMAIL_IPK_DIR)/opt/etc/putmail/...
# Documentation files should be installed in $(PUTMAIL_IPK_DIR)/opt/doc/putmail/...
# Daemon startup scripts should be installed in $(PUTMAIL_IPK_DIR)/opt/etc/init.d/S??putmail
#
# You may need to patch your application to make it use these locations.
#
$(PUTMAIL_IPK): $(PUTMAIL_BUILD_DIR)/.built
	rm -rf $(PUTMAIL_IPK_DIR) $(BUILD_DIR)/putmail_*_$(TARGET_ARCH).ipk
	rm -rf $(PUTMAIL-COMMON_IPK_DIR) $(BUILD_DIR)/py-putmail-common_*_$(TARGET_ARCH).ipk
	(cd $(PUTMAIL_BUILD_DIR); \
		DESTDIR=$(PUTMAIL_IPK_DIR) PREFIX=/opt ./install.sh; \
	)
	sed -i -e '1s|^#!.*|#!/opt/bin/python|' $(PUTMAIL_IPK_DIR)/opt/bin/putmail.py
	$(MAKE) $(PUTMAIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PUTMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
putmail-ipk: $(PUTMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
putmail-clean:
	-$(MAKE) -C $(PUTMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
putmail-dirclean:
	rm -rf $(BUILD_DIR)/$(PUTMAIL_DIR) $(PUTMAIL_BUILD_DIR)
	rm -rf $(PUTMAIL_IPK_DIR) $(PUTMAIL_IPK)

#
# Some sanity check for the package.
#
putmail-check: $(PUTMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PUTMAIL_IPK)
