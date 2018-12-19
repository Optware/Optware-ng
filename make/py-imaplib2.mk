###########################################################
#
# py-imaplib2
#
###########################################################

#
# PY-IMAPLIB2_VERSION, PY-IMAPLIB2_SITE and PY-IMAPLIB2_SOURCE define
# the upstream location of the source code for the package.
# PY-IMAPLIB2_DIR is the directory which is created when the source
# archive is unpacked.
# PY-IMAPLIB2_UNZIP is the command used to unzip the source.
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
PY-IMAPLIB2_VERSION=2.45.0
PY-IMAPLIB2_SITE=https://pypi.python.org/packages/source/i/imaplib2
PY-IMAPLIB2_SOURCE=imaplib2-$(PY-IMAPLIB2_VERSION).tar.gz
PY-IMAPLIB2_DIR=imaplib2-$(PY-IMAPLIB2_VERSION)
PY-IMAPLIB2_UNZIP=zcat
PY-IMAPLIB2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-IMAPLIB2_DESCRIPTION=A threaded Python IMAP4 client.
PY-IMAPLIB2_SECTION=misc
PY-IMAPLIB2_PRIORITY=optional
PY27-IMAPLIB2_DEPENDS=python27
PY3-IMAPLIB2_DEPENDS=python3
PY-IMAPLIB2_CONFLICTS=

#
# PY-IMAPLIB2_IPK_VERSION should be incremented when the ipk changes.
#
PY-IMAPLIB2_IPK_VERSION=4

#
# PY-IMAPLIB2_CONFFILES should be a list of user-editable files
#PY-IMAPLIB2_CONFFILES=$(TARGET_PREFIX)/etc/py-imaplib2.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-imaplib2

#
# PY-IMAPLIB2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-IMAPLIB2_PATCHES=$(PY-IMAPLIB2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-IMAPLIB2_CPPFLAGS=
PY-IMAPLIB2_LDFLAGS=

#
# PY-IMAPLIB2_BUILD_DIR is the directory in which the build is done.
# PY-IMAPLIB2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-IMAPLIB2_IPK_DIR is the directory in which the ipk is built.
# PY-IMAPLIB2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-IMAPLIB2_BUILD_DIR=$(BUILD_DIR)/py-imaplib2
PY-IMAPLIB2_SOURCE_DIR=$(SOURCE_DIR)/py-imaplib2

PY27-IMAPLIB2_IPK_DIR=$(BUILD_DIR)/py27-imaplib2-$(PY-IMAPLIB2_VERSION)-ipk
PY27-IMAPLIB2_IPK=$(BUILD_DIR)/py27-imaplib2_$(PY-IMAPLIB2_VERSION)-$(PY-IMAPLIB2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-IMAPLIB2_IPK_DIR=$(BUILD_DIR)/py3-imaplib2-$(PY-IMAPLIB2_VERSION)-ipk
PY3-IMAPLIB2_IPK=$(BUILD_DIR)/py3-imaplib2_$(PY-IMAPLIB2_VERSION)-$(PY-IMAPLIB2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-imaplib2-source py-imaplib2-unpack py-imaplib2 py-imaplib2-stage py-imaplib2-ipk py-imaplib2-clean py-imaplib2-dirclean py-imaplib2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-IMAPLIB2_SOURCE):
	$(WGET) -P $(@D) $(PY-IMAPLIB2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-imaplib2-source: $(DL_DIR)/$(PY-IMAPLIB2_SOURCE) $(PY-IMAPLIB2_PATCHES)

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
$(PY-IMAPLIB2_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-IMAPLIB2_SOURCE) $(PY-IMAPLIB2_PATCHES) make/py-imaplib2.mk
	$(MAKE) python27-host-stage python3-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) $(@D)
	mkdir -p $(PY-IMAPLIB2_BUILD_DIR)
	$(PY-IMAPLIB2_UNZIP) $(DL_DIR)/$(PY-IMAPLIB2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IMAPLIB2_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-IMAPLIB2_UNZIP) $(DL_DIR)/$(PY-IMAPLIB2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IMAPLIB2_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-imaplib2-unpack: $(PY-IMAPLIB2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-IMAPLIB2_BUILD_DIR)/.built: $(PY-IMAPLIB2_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-imaplib2: $(PY-IMAPLIB2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-IMAPLIB2_BUILD_DIR)/.staged: $(PY-IMAPLIB2_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-IMAPLIB2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-imaplib2-stage: $(PY-IMAPLIB2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-imaplib2
#
$(PY27-IMAPLIB2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-imaplib2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IMAPLIB2_PRIORITY)" >>$@
	@echo "Section: $(PY-IMAPLIB2_SECTION)" >>$@
	@echo "Version: $(PY-IMAPLIB2_VERSION)-$(PY-IMAPLIB2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IMAPLIB2_MAINTAINER)" >>$@
	@echo "Source: $(PY-IMAPLIB2_SITE)/$(PY-IMAPLIB2_SOURCE)" >>$@
	@echo "Description: $(PY-IMAPLIB2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-IMAPLIB2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IMAPLIB2_CONFLICTS)" >>$@

$(PY3-IMAPLIB2_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-imaplib2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IMAPLIB2_PRIORITY)" >>$@
	@echo "Section: $(PY-IMAPLIB2_SECTION)" >>$@
	@echo "Version: $(PY-IMAPLIB2_VERSION)-$(PY-IMAPLIB2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IMAPLIB2_MAINTAINER)" >>$@
	@echo "Source: $(PY-IMAPLIB2_SITE)/$(PY-IMAPLIB2_SOURCE)" >>$@
	@echo "Description: $(PY-IMAPLIB2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-IMAPLIB2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IMAPLIB2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/etc/py-imaplib2/...
# Documentation files should be installed in $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/doc/py-imaplib2/...
# Daemon startup scripts should be installed in $(PY-IMAPLIB2_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-imaplib2
#
# You may need to patch your application to make it use these locations.
#
$(PY27-IMAPLIB2_IPK): $(PY-IMAPLIB2_BUILD_DIR)/.built
	rm -rf $(PY27-IMAPLIB2_IPK_DIR) $(BUILD_DIR)/py27-imaplib2_*_$(TARGET_ARCH).ipk
	(cd $(PY-IMAPLIB2_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-IMAPLIB2_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-IMAPLIB2_IPK_DIR)/CONTROL/control
	echo $(PY-IMAPLIB2_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-IMAPLIB2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-IMAPLIB2_IPK_DIR)

$(PY3-IMAPLIB2_IPK): $(PY-IMAPLIB2_BUILD_DIR)/.built
	rm -rf $(PY3-IMAPLIB2_IPK_DIR) $(BUILD_DIR)/py3-imaplib2_*_$(TARGET_ARCH).ipk
	(cd $(PY-IMAPLIB2_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-IMAPLIB2_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-IMAPLIB2_IPK_DIR)/CONTROL/control
	echo $(PY-IMAPLIB2_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-IMAPLIB2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-IMAPLIB2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-imaplib2-ipk: $(PY27-IMAPLIB2_IPK) $(PY3-IMAPLIB2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-imaplib2-clean:
	-$(MAKE) -C $(PY-IMAPLIB2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-imaplib2-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-IMAPLIB2_DIR) $(PY-IMAPLIB2_BUILD_DIR) \
	$(PY27-IMAPLIB2_IPK_DIR) $(PY27-IMAPLIB2_IPK) \
	$(PY3-IMAPLIB2_IPK_DIR) $(PY3-IMAPLIB2_IPK) \

#
# Some sanity check for the package.
#
py-imaplib2-check: $(PY27-IMAPLIB2_IPK) $(PY3-IMAPLIB2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
