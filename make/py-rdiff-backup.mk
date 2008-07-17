###########################################################
#
# py-rdiff-backup
#
###########################################################

#
# PY-RDIFF-BACKUP_VERSION, PY-RDIFF-BACKUP_SITE and PY-RDIFF-BACKUP_SOURCE define
# the upstream location of the source code for the package.
# PY-RDIFF-BACKUP_DIR is the directory which is created when the source
# archive is unpacked.
# PY-RDIFF-BACKUP_UNZIP is the command used to unzip the source.
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
PY-RDIFF-BACKUP_VERSION=1.1.17
PY-RDIFF-BACKUP_SITE=http://savannah.nongnu.org/download/rdiff-backup
PY-RDIFF-BACKUP_SOURCE=rdiff-backup-$(PY-RDIFF-BACKUP_VERSION).tar.gz
PY-RDIFF-BACKUP_DIR=rdiff-backup-$(PY-RDIFF-BACKUP_VERSION)
PY-RDIFF-BACKUP_UNZIP=zcat
PY-RDIFF-BACKUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-RDIFF-BACKUP_DESCRIPTION=rdiff-backup backs up one directory to another, possibly over a network.
PY-RDIFF-BACKUP_SECTION=misc
PY-RDIFF-BACKUP_PRIORITY=optional
PY24-RDIFF-BACKUP_DEPENDS=python24, librsync
PY25-RDIFF-BACKUP_DEPENDS=python25, librsync
PY-RDIFF-BACKUP_CONFLICTS=

#
# PY-RDIFF-BACKUP_IPK_VERSION should be incremented when the ipk changes.
#
PY-RDIFF-BACKUP_IPK_VERSION=1

#
# PY-RDIFF-BACKUP_CONFFILES should be a list of user-editable files
#PY-RDIFF-BACKUP_CONFFILES=/opt/etc/py-rdiff-backup.conf /opt/etc/init.d/SXXpy-rdiff-backup

#
# PY-RDIFF-BACKUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-RDIFF-BACKUP_PATCHES=$(PY-RDIFF-BACKUP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-RDIFF-BACKUP_CPPFLAGS=
PY-RDIFF-BACKUP_LDFLAGS=

#
# PY-RDIFF-BACKUP_BUILD_DIR is the directory in which the build is done.
# PY-RDIFF-BACKUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-RDIFF-BACKUP_IPK_DIR is the directory in which the ipk is built.
# PY-RDIFF-BACKUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-RDIFF-BACKUP_BUILD_DIR=$(BUILD_DIR)/py-rdiff-backup
PY-RDIFF-BACKUP_SOURCE_DIR=$(SOURCE_DIR)/py-rdiff-backup

PY24-RDIFF-BACKUP_IPK_DIR=$(BUILD_DIR)/py24-rdiff-backup-$(PY-RDIFF-BACKUP_VERSION)-ipk
PY24-RDIFF-BACKUP_IPK=$(BUILD_DIR)/py24-rdiff-backup_$(PY-RDIFF-BACKUP_VERSION)-$(PY-RDIFF-BACKUP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-RDIFF-BACKUP_IPK_DIR=$(BUILD_DIR)/py25-rdiff-backup-$(PY-RDIFF-BACKUP_VERSION)-ipk
PY25-RDIFF-BACKUP_IPK=$(BUILD_DIR)/py25-rdiff-backup_$(PY-RDIFF-BACKUP_VERSION)-$(PY-RDIFF-BACKUP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-rdiff-backup-source py-rdiff-backup-unpack py-rdiff-backup py-rdiff-backup-stage py-rdiff-backup-ipk py-rdiff-backup-clean py-rdiff-backup-dirclean py-rdiff-backup-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-RDIFF-BACKUP_SOURCE):
	$(WGET) -P $(@D) $(PY-RDIFF-BACKUP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-rdiff-backup-source: $(DL_DIR)/$(PY-RDIFF-BACKUP_SOURCE) $(PY-RDIFF-BACKUP_PATCHES)

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
$(PY-RDIFF-BACKUP_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-RDIFF-BACKUP_SOURCE) $(PY-RDIFF-BACKUP_PATCHES)
	$(MAKE) python-stage librsync-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR)
	$(PY-RDIFF-BACKUP_UNZIP) $(DL_DIR)/$(PY-RDIFF-BACKUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-RDIFF-BACKUP_PATCHES) | patch -d $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR)
	$(PY-RDIFF-BACKUP_UNZIP) $(DL_DIR)/$(PY-RDIFF-BACKUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-RDIFF-BACKUP_PATCHES) | patch -d $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-rdiff-backup-unpack: $(PY-RDIFF-BACKUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-RDIFF-BACKUP_BUILD_DIR)/.built: $(PY-RDIFF-BACKUP_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-rdiff-backup: $(PY-RDIFF-BACKUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-RDIFF-BACKUP_BUILD_DIR)/.staged: $(PY-RDIFF-BACKUP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-rdiff-backup-stage: $(PY-RDIFF-BACKUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-rdiff-backup
#
$(PY24-RDIFF-BACKUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-rdiff-backup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-RDIFF-BACKUP_PRIORITY)" >>$@
	@echo "Section: $(PY-RDIFF-BACKUP_SECTION)" >>$@
	@echo "Version: $(PY-RDIFF-BACKUP_VERSION)-$(PY-RDIFF-BACKUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-RDIFF-BACKUP_MAINTAINER)" >>$@
	@echo "Source: $(PY-RDIFF-BACKUP_SITE)/$(PY-RDIFF-BACKUP_SOURCE)" >>$@
	@echo "Description: $(PY-RDIFF-BACKUP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-RDIFF-BACKUP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-RDIFF-BACKUP_CONFLICTS)" >>$@

$(PY25-RDIFF-BACKUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-rdiff-backup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-RDIFF-BACKUP_PRIORITY)" >>$@
	@echo "Section: $(PY-RDIFF-BACKUP_SECTION)" >>$@
	@echo "Version: $(PY-RDIFF-BACKUP_VERSION)-$(PY-RDIFF-BACKUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-RDIFF-BACKUP_MAINTAINER)" >>$@
	@echo "Source: $(PY-RDIFF-BACKUP_SITE)/$(PY-RDIFF-BACKUP_SOURCE)" >>$@
	@echo "Description: $(PY-RDIFF-BACKUP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-RDIFF-BACKUP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-RDIFF-BACKUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-RDIFF-BACKUP_IPK_DIR)/opt/sbin or $(PY-RDIFF-BACKUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-RDIFF-BACKUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-RDIFF-BACKUP_IPK_DIR)/opt/etc/py-rdiff-backup/...
# Documentation files should be installed in $(PY-RDIFF-BACKUP_IPK_DIR)/opt/doc/py-rdiff-backup/...
# Daemon startup scripts should be installed in $(PY-RDIFF-BACKUP_IPK_DIR)/opt/etc/init.d/S??py-rdiff-backup
#
# You may need to patch your application to make it use these locations.
#
$(PY24-RDIFF-BACKUP_IPK): $(PY-RDIFF-BACKUP_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-rdiff-backup_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-RDIFF-BACKUP_IPK_DIR) $(BUILD_DIR)/py24-rdiff-backup_*_$(TARGET_ARCH).ipk
	(cd $(PY-RDIFF-BACKUP_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-RDIFF-BACKUP_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY24-RDIFF-BACKUP_IPK_DIR)/opt/lib/python2.4/site-packages/*/*.so
	rm -rf $(PY24-RDIFF-BACKUP_IPK_DIR)/opt/share
	for f in $(PY24-RDIFF-BACKUP_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-RDIFF-BACKUP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-RDIFF-BACKUP_IPK_DIR)

$(PY25-RDIFF-BACKUP_IPK): $(PY-RDIFF-BACKUP_BUILD_DIR)/.built
	rm -rf $(PY25-RDIFF-BACKUP_IPK_DIR) $(BUILD_DIR)/py25-rdiff-backup_*_$(TARGET_ARCH).ipk
	(cd $(PY-RDIFF-BACKUP_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-RDIFF-BACKUP_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-RDIFF-BACKUP_IPK_DIR)/opt/lib/python2.5/site-packages/*/*.so
	$(MAKE) $(PY25-RDIFF-BACKUP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-RDIFF-BACKUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-rdiff-backup-ipk: $(PY24-RDIFF-BACKUP_IPK) $(PY25-RDIFF-BACKUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-rdiff-backup-clean:
	-$(MAKE) -C $(PY-RDIFF-BACKUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-rdiff-backup-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-RDIFF-BACKUP_DIR) $(PY-RDIFF-BACKUP_BUILD_DIR)
	rm -rf $(PY24-RDIFF-BACKUP_IPK_DIR) $(PY24-RDIFF-BACKUP_IPK)
	rm -rf $(PY25-RDIFF-BACKUP_IPK_DIR) $(PY25-RDIFF-BACKUP_IPK)

#
# Some sanity check for the package.
#
py-rdiff-backup-check: $(PY24-RDIFF-BACKUP_IPK) $(PY25-RDIFF-BACKUP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-RDIFF-BACKUP_IPK) $(PY25-RDIFF-BACKUP_IPK)
