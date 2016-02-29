###########################################################
#
# offlineimap
#
###########################################################

#
# OFFLINEIMAP_VERSION, OFFLINEIMAP_URL defines
# the upstream location of the source code for the package.
# OFFLINEIMAP_DIR is the directory which is created when the source
# archive is unpacked.
# OFFLINEIMAP_UNZIP is the command used to unzip the source.
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
OFFLINEIMAP_VERSION=6.6.0
OFFLINEIMAP_URL=https://github.com/OfflineIMAP/offlineimap/archive/v$(OFFLINEIMAP_VERSION).tar.gz
OFFLINEIMAP_SOURCE=offlineimap-$(OFFLINEIMAP_VERSION).tar.gz
OFFLINEIMAP_DIR=offlineimap-$(OFFLINEIMAP_VERSION)
OFFLINEIMAP_UNZIP=zcat
OFFLINEIMAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OFFLINEIMAP_DESCRIPTION=Software to dispose your e-mail mailbox(es) as a local Maildir. OfflineIMAP will synchronize both sides via IMAP.
OFFLINEIMAP_SECTION=misc
OFFLINEIMAP_PRIORITY=optional
OFFLINEIMAP_DEPENDS=python27, py27-imaplib2
OFFLINEIMAP_CONFLICTS=

#
# OFFLINEIMAP_IPK_VERSION should be incremented when the ipk changes.
#
OFFLINEIMAP_IPK_VERSION=1

#
# OFFLINEIMAP_CONFFILES should be a list of user-editable files
#OFFLINEIMAP_CONFFILES=$(TARGET_PREFIX)/etc/offlineimap.conf $(TARGET_PREFIX)/etc/init.d/SXXofflineimap

#
# OFFLINEIMAP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OFFLINEIMAP_PATCHES=$(OFFLINEIMAP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OFFLINEIMAP_CPPFLAGS=
OFFLINEIMAP_LDFLAGS=

#
# OFFLINEIMAP_BUILD_DIR is the directory in which the build is done.
# OFFLINEIMAP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OFFLINEIMAP_IPK_DIR is the directory in which the ipk is built.
# OFFLINEIMAP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OFFLINEIMAP_BUILD_DIR=$(BUILD_DIR)/offlineimap
OFFLINEIMAP_SOURCE_DIR=$(SOURCE_DIR)/offlineimap

OFFLINEIMAP_IPK_DIR=$(BUILD_DIR)/offlineimap-$(OFFLINEIMAP_VERSION)-ipk
OFFLINEIMAP_IPK=$(BUILD_DIR)/offlineimap_$(OFFLINEIMAP_VERSION)-$(OFFLINEIMAP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: offlineimap-source offlineimap-unpack offlineimap offlineimap-stage offlineimap-ipk offlineimap-clean offlineimap-dirclean offlineimap-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OFFLINEIMAP_SOURCE):
	$(WGET) -O $@ $(OFFLINEIMAP_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
offlineimap-source: $(DL_DIR)/$(OFFLINEIMAP_SOURCE) $(OFFLINEIMAP_PATCHES)

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
$(OFFLINEIMAP_BUILD_DIR)/.configured: $(DL_DIR)/$(OFFLINEIMAP_SOURCE) $(OFFLINEIMAP_PATCHES) make/offlineimap.mk
	$(MAKE) python27-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(OFFLINEIMAP_DIR) $(BUILD_DIR)/$(OFFLINEIMAP_DIR) $(@D)
	mkdir -p $(OFFLINEIMAP_BUILD_DIR)
	$(OFFLINEIMAP_UNZIP) $(DL_DIR)/$(OFFLINEIMAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(OFFLINEIMAP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(OFFLINEIMAP_DIR) -p1
	mv $(BUILD_DIR)/$(OFFLINEIMAP_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

offlineimap-unpack: $(OFFLINEIMAP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OFFLINEIMAP_BUILD_DIR)/.built: $(OFFLINEIMAP_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
offlineimap: $(OFFLINEIMAP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(OFFLINEIMAP_BUILD_DIR)/.staged: $(OFFLINEIMAP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(OFFLINEIMAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#offlineimap-stage: $(OFFLINEIMAP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/offlineimap
#
$(OFFLINEIMAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: offlineimap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OFFLINEIMAP_PRIORITY)" >>$@
	@echo "Section: $(OFFLINEIMAP_SECTION)" >>$@
	@echo "Version: $(OFFLINEIMAP_VERSION)-$(OFFLINEIMAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OFFLINEIMAP_MAINTAINER)" >>$@
	@echo "Source: $(OFFLINEIMAP_URL)" >>$@
	@echo "Description: $(OFFLINEIMAP_DESCRIPTION)" >>$@
	@echo "Depends: $(OFFLINEIMAP_DEPENDS)" >>$@
	@echo "Conflicts: $(OFFLINEIMAP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/etc/offlineimap/...
# Documentation files should be installed in $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/doc/offlineimap/...
# Daemon startup scripts should be installed in $(OFFLINEIMAP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??offlineimap
#
# You may need to patch your application to make it use these locations.
#
$(OFFLINEIMAP_IPK): $(OFFLINEIMAP_BUILD_DIR)/.built
	rm -rf $(OFFLINEIMAP_IPK_DIR) $(BUILD_DIR)/offlineimap_*_$(TARGET_ARCH).ipk
	(cd $(OFFLINEIMAP_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(OFFLINEIMAP_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(OFFLINEIMAP_IPK_DIR)/CONTROL/control
	echo $(OFFLINEIMAP_CONFFILES) | sed -e 's/ /\n/g' > $(OFFLINEIMAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OFFLINEIMAP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
offlineimap-ipk: $(OFFLINEIMAP_IPK) $(PY3-OFFLINEIMAP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
offlineimap-clean:
	-$(MAKE) -C $(OFFLINEIMAP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
offlineimap-dirclean:
	rm -rf $(BUILD_DIR)/$(OFFLINEIMAP_DIR) $(OFFLINEIMAP_BUILD_DIR) \
	$(OFFLINEIMAP_IPK_DIR) $(OFFLINEIMAP_IPK) \

#
# Some sanity check for the package.
#
offlineimap-check: $(OFFLINEIMAP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
