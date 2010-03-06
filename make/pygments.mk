###########################################################
#
# pygments
#
###########################################################

#
# PYGMENTS_VERSION, PYGMENTS_SITE and PYGMENTS_SOURCE define
# the upstream location of the source code for the package.
# PYGMENTS_DIR is the directory which is created when the source
# archive is unpacked.
# PYGMENTS_UNZIP is the command used to unzip the source.
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
PYGMENTS_VERSION=1.3.1
PYGMENTS_SITE=http://pypi.python.org/packages/source/P/Pygments
PYGMENTS_SOURCE=Pygments-$(PYGMENTS_VERSION).tar.gz
PYGMENTS_DIR=Pygments-$(PYGMENTS_VERSION)
PYGMENTS_UNZIP=zcat
PYGMENTS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYGMENTS_DESCRIPTION=Pygments is a syntax highlighting package written in Python.
PYGMENTS_SECTION=utils
PYGMENTS_PRIORITY=optional
PY25-PYGMENTS_DEPENDS=python25
PY26-PYGMENTS_DEPENDS=python26
PYGMENTS_CONFLICTS=

#
# PYGMENTS_IPK_VERSION should be incremented when the ipk changes.
#
PYGMENTS_IPK_VERSION=1

#
# PYGMENTS_CONFFILES should be a list of user-editable files
#PYGMENTS_CONFFILES=/opt/etc/pygments.conf /opt/etc/init.d/SXXpygments

#
# PYGMENTS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PYGMENTS_PATCHES=$(PYGMENTS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYGMENTS_CPPFLAGS=
PYGMENTS_LDFLAGS=

#
# PYGMENTS_BUILD_DIR is the directory in which the build is done.
# PYGMENTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYGMENTS_IPK_DIR is the directory in which the ipk is built.
# PYGMENTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYGMENTS_BUILD_DIR=$(BUILD_DIR)/pygments
PYGMENTS_SOURCE_DIR=$(SOURCE_DIR)/pygments

PY25-PYGMENTS_IPK_DIR=$(BUILD_DIR)/py25-pygments-$(PYGMENTS_VERSION)-ipk
PY25-PYGMENTS_IPK=$(BUILD_DIR)/py25-pygments_$(PYGMENTS_VERSION)-$(PYGMENTS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PYGMENTS_IPK_DIR=$(BUILD_DIR)/py26-pygments-$(PYGMENTS_VERSION)-ipk
PY26-PYGMENTS_IPK=$(BUILD_DIR)/py26-pygments_$(PYGMENTS_VERSION)-$(PYGMENTS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pygments-source pygments-unpack pygments pygments-stage pygments-ipk pygments-clean pygments-dirclean pygments-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYGMENTS_SOURCE):
	$(WGET) -P $(@D) $(PYGMENTS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pygments-source: $(DL_DIR)/$(PYGMENTS_SOURCE) $(PYGMENTS_PATCHES)

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
$(PYGMENTS_BUILD_DIR)/.configured: $(DL_DIR)/$(PYGMENTS_SOURCE) $(PYGMENTS_PATCHES) make/pygments.mk
	$(MAKE) python-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PYGMENTS_DIR)
	$(PYGMENTS_UNZIP) $(DL_DIR)/$(PYGMENTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PYGMENTS_PATCHES) | patch -d $(BUILD_DIR)/$(PYGMENTS_DIR) -p1
	mv $(BUILD_DIR)/$(PYGMENTS_DIR) $(@D)/2.5
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
	# 2.6
	rm -rf $(BUILD_DIR)/$(PYGMENTS_DIR)
	$(PYGMENTS_UNZIP) $(DL_DIR)/$(PYGMENTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PYGMENTS_PATCHES) | patch -d $(BUILD_DIR)/$(PYGMENTS_DIR) -p1
	mv $(BUILD_DIR)/$(PYGMENTS_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

pygments-unpack: $(PYGMENTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYGMENTS_BUILD_DIR)/.built: $(PYGMENTS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
pygments: $(PYGMENTS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYGMENTS_BUILD_DIR)/.staged: $(PYGMENTS_BUILD_DIR)/.built
#	rm -f $@
	#$(MAKE) -C $(PYGMENTS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

pygments-stage: $(PYGMENTS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pygments
#
$(PY25-PYGMENTS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pygments" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYGMENTS_PRIORITY)" >>$@
	@echo "Section: $(PYGMENTS_SECTION)" >>$@
	@echo "Version: $(PYGMENTS_VERSION)-$(PYGMENTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYGMENTS_MAINTAINER)" >>$@
	@echo "Source: $(PYGMENTS_SITE)/$(PYGMENTS_SOURCE)" >>$@
	@echo "Description: $(PYGMENTS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PYGMENTS_DEPENDS)" >>$@
	@echo "Conflicts: $(PYGMENTS_CONFLICTS)" >>$@

$(PY26-PYGMENTS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-pygments" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYGMENTS_PRIORITY)" >>$@
	@echo "Section: $(PYGMENTS_SECTION)" >>$@
	@echo "Version: $(PYGMENTS_VERSION)-$(PYGMENTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYGMENTS_MAINTAINER)" >>$@
	@echo "Source: $(PYGMENTS_SITE)/$(PYGMENTS_SOURCE)" >>$@
	@echo "Description: $(PYGMENTS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PYGMENTS_DEPENDS)" >>$@
	@echo "Conflicts: $(PYGMENTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYGMENTS_IPK_DIR)/opt/sbin or $(PYGMENTS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYGMENTS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYGMENTS_IPK_DIR)/opt/etc/pygments/...
# Documentation files should be installed in $(PYGMENTS_IPK_DIR)/opt/doc/pygments/...
# Daemon startup scripts should be installed in $(PYGMENTS_IPK_DIR)/opt/etc/init.d/S??pygments
#
# You may need to patch your application to make it use these locations.
#
$(PY25-PYGMENTS_IPK): $(PYGMENTS_BUILD_DIR)/.built
	rm -rf $(PY25-PYGMENTS_IPK_DIR) $(BUILD_DIR)/py25-pygments_*_$(TARGET_ARCH).ipk
	(cd $(PYGMENTS_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-PYGMENTS_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-PYGMENTS_IPK_DIR)/opt/lib/python2.5/site-packages/pygmentslib/*.so
	$(MAKE) $(PY25-PYGMENTS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PYGMENTS_IPK_DIR)

$(PY26-PYGMENTS_IPK): $(PYGMENTS_BUILD_DIR)/.built
	rm -rf $(PY26-PYGMENTS_IPK_DIR) $(BUILD_DIR)/py26-pygments_*_$(TARGET_ARCH).ipk
	(cd $(PYGMENTS_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-PYGMENTS_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-PYGMENTS_IPK_DIR)/opt/lib/python2.6/site-packages/pygmentslib/*.so
	for f in $(PY26-PYGMENTS_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	rm -rf $(PY26-PYGMENTS_IPK_DIR)/opt/man
	$(MAKE) $(PY26-PYGMENTS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PYGMENTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pygments-ipk: $(PY25-PYGMENTS_IPK) $(PY26-PYGMENTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pygments-clean:
	-$(MAKE) -C $(PYGMENTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pygments-dirclean:
	rm -rf $(BUILD_DIR)/$(PYGMENTS_DIR) $(PYGMENTS_BUILD_DIR)
	rm -rf $(PY25-PYGMENTS_IPK_DIR) $(PY25-PYGMENTS_IPK)
	rm -rf $(PY26-PYGMENTS_IPK_DIR) $(PY26-PYGMENTS_IPK)

#
# Some sanity check for the package.
#
pygments-check: $(PY25-PYGMENTS_IPK) $(PY26-PYGMENTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
