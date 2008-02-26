###########################################################
#
# py-turbocheetah
#
###########################################################

#
# PY-TURBOCHEETAH_VERSION, PY-TURBOCHEETAH_SITE and PY-TURBOCHEETAH_SOURCE define
# the upstream location of the source code for the package.
# PY-TURBOCHEETAH_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TURBOCHEETAH_UNZIP is the command used to unzip the source.
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
PY-TURBOCHEETAH_VERSION=1.0
PY-TURBOCHEETAH_SITE=http://pypi.python.org/packages/source/T/TurboCheetah
PY-TURBOCHEETAH_SOURCE=TurboCheetah-$(PY-TURBOCHEETAH_VERSION).tar.gz
#PY-TURBOCHEETAH_SVN_TAG=$(PY-TURBOCHEETAH_VERSION)
#PY-TURBOCHEETAH_REPOSITORY=http://svn.turbogears.org/projects/TurboCheetah/tags/$(PY-TURBOCHEETAH_SVN_TAG)
PY-TURBOCHEETAH_DIR=TurboCheetah-$(PY-TURBOCHEETAH_VERSION)
PY-TURBOCHEETAH_UNZIP=zcat
PY-TURBOCHEETAH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TURBOCHEETAH_DESCRIPTION=Python template plugin that supports use of Cheetah templates.
PY-TURBOCHEETAH_SECTION=misc
PY-TURBOCHEETAH_PRIORITY=optional
PY24-TURBOCHEETAH_DEPENDS=python24, py24-cheetah
PY25-TURBOCHEETAH_DEPENDS=python25, py25-cheetah
PY-TURBOCHEETAH_CONFLICTS=

#
# PY-TURBOCHEETAH_IPK_VERSION should be incremented when the ipk changes.
#
PY-TURBOCHEETAH_IPK_VERSION=2

#
# PY-TURBOCHEETAH_CONFFILES should be a list of user-editable files
#PY-TURBOCHEETAH_CONFFILES=/opt/etc/py-turbocheetah.conf /opt/etc/init.d/SXXpy-turbocheetah

#
# PY-TURBOCHEETAH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TURBOCHEETAH_PATCHES=$(PY-TURBOCHEETAH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TURBOCHEETAH_CPPFLAGS=
PY-TURBOCHEETAH_LDFLAGS=

#
# PY-TURBOCHEETAH_BUILD_DIR is the directory in which the build is done.
# PY-TURBOCHEETAH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TURBOCHEETAH_IPK_DIR is the directory in which the ipk is built.
# PY-TURBOCHEETAH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TURBOCHEETAH_BUILD_DIR=$(BUILD_DIR)/py-turbocheetah
PY-TURBOCHEETAH_SOURCE_DIR=$(SOURCE_DIR)/py-turbocheetah

PY24-TURBOCHEETAH_IPK_DIR=$(BUILD_DIR)/py24-turbocheetah-$(PY-TURBOCHEETAH_VERSION)-ipk
PY24-TURBOCHEETAH_IPK=$(BUILD_DIR)/py24-turbocheetah_$(PY-TURBOCHEETAH_VERSION)-$(PY-TURBOCHEETAH_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TURBOCHEETAH_IPK_DIR=$(BUILD_DIR)/py25-turbocheetah-$(PY-TURBOCHEETAH_VERSION)-ipk
PY25-TURBOCHEETAH_IPK=$(BUILD_DIR)/py25-turbocheetah_$(PY-TURBOCHEETAH_VERSION)-$(PY-TURBOCHEETAH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-turbocheetah-source py-turbocheetah-unpack py-turbocheetah py-turbocheetah-stage py-turbocheetah-ipk py-turbocheetah-clean py-turbocheetah-dirclean py-turbocheetah-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-TURBOCHEETAH_SVN_TAG),)
$(DL_DIR)/$(PY-TURBOCHEETAH_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TURBOCHEETAH_SITE)/$(PY-TURBOCHEETAH_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-turbocheetah-source: $(PY-TURBOCHEETAH_PATCHES)

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
$(PY-TURBOCHEETAH_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TURBOCHEETAH_SOURCE) $(PY-TURBOCHEETAH_PATCHES) make/py-turbocheetah.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-TURBOCHEETAH_BUILD_DIR)
	mkdir -p $(PY-TURBOCHEETAH_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR)
ifeq ($(PY-TURBOCHEETAH_SVN_TAG),)
	$(PY-TURBOCHEETAH_UNZIP) $(DL_DIR)/$(PY-TURBOCHEETAH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q $(PY-TURBOCHEETAH_REPOSITORY) $(PY-TURBOCHEETAH_DIR); \
	)
endif
#	cat $(PY-TURBOCHEETAH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR)
ifeq ($(PY-TURBOCHEETAH_SVN_TAG),)
	$(PY-TURBOCHEETAH_UNZIP) $(DL_DIR)/$(PY-TURBOCHEETAH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q $(PY-TURBOCHEETAH_REPOSITORY) $(PY-TURBOCHEETAH_DIR); \
	)
endif
#	cat $(PY-TURBOCHEETAH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-turbocheetah-unpack: $(PY-TURBOCHEETAH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TURBOCHEETAH_BUILD_DIR)/.built: $(PY-TURBOCHEETAH_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-turbocheetah: $(PY-TURBOCHEETAH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TURBOCHEETAH_BUILD_DIR)/.staged: $(PY-TURBOCHEETAH_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-TURBOCHEETAH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-turbocheetah-stage: $(PY-TURBOCHEETAH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-turbocheetah
#
$(PY24-TURBOCHEETAH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-turbocheetah" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOCHEETAH_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOCHEETAH_SECTION)" >>$@
	@echo "Version: $(PY-TURBOCHEETAH_VERSION)-$(PY-TURBOCHEETAH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOCHEETAH_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOCHEETAH_SITE)/$(PY-TURBOCHEETAH_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOCHEETAH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TURBOCHEETAH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOCHEETAH_CONFLICTS)" >>$@

$(PY25-TURBOCHEETAH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-turbocheetah" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TURBOCHEETAH_PRIORITY)" >>$@
	@echo "Section: $(PY-TURBOCHEETAH_SECTION)" >>$@
	@echo "Version: $(PY-TURBOCHEETAH_VERSION)-$(PY-TURBOCHEETAH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TURBOCHEETAH_MAINTAINER)" >>$@
	@echo "Source: $(PY-TURBOCHEETAH_SITE)/$(PY-TURBOCHEETAH_SOURCE)" >>$@
	@echo "Description: $(PY-TURBOCHEETAH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TURBOCHEETAH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TURBOCHEETAH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TURBOCHEETAH_IPK_DIR)/opt/sbin or $(PY-TURBOCHEETAH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TURBOCHEETAH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TURBOCHEETAH_IPK_DIR)/opt/etc/py-turbocheetah/...
# Documentation files should be installed in $(PY-TURBOCHEETAH_IPK_DIR)/opt/doc/py-turbocheetah/...
# Daemon startup scripts should be installed in $(PY-TURBOCHEETAH_IPK_DIR)/opt/etc/init.d/S??py-turbocheetah
#
# You may need to patch your application to make it use these locations.
#
$(PY24-TURBOCHEETAH_IPK): $(PY-TURBOCHEETAH_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-turbocheetah_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-TURBOCHEETAH_IPK_DIR) $(BUILD_DIR)/py24-turbocheetah_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOCHEETAH_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-TURBOCHEETAH_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-TURBOCHEETAH_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOCHEETAH_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-TURBOCHEETAH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TURBOCHEETAH_IPK_DIR)

$(PY25-TURBOCHEETAH_IPK): $(PY-TURBOCHEETAH_BUILD_DIR)/.built
	rm -rf $(PY25-TURBOCHEETAH_IPK_DIR) $(BUILD_DIR)/py25-turbocheetah_*_$(TARGET_ARCH).ipk
	(cd $(PY-TURBOCHEETAH_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-TURBOCHEETAH_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-TURBOCHEETAH_IPK_DIR)/CONTROL/control
	echo $(PY-TURBOCHEETAH_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-TURBOCHEETAH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TURBOCHEETAH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-turbocheetah-ipk: $(PY24-TURBOCHEETAH_IPK) $(PY25-TURBOCHEETAH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-turbocheetah-clean:
	-$(MAKE) -C $(PY-TURBOCHEETAH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-turbocheetah-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TURBOCHEETAH_DIR) $(PY-TURBOCHEETAH_BUILD_DIR)
	rm -rf $(PY24-TURBOCHEETAH_IPK_DIR) $(PY24-TURBOCHEETAH_IPK)
	rm -rf $(PY25-TURBOCHEETAH_IPK_DIR) $(PY25-TURBOCHEETAH_IPK)

#
# Some sanity check for the package.
#
py-turbocheetah-check: $(PY24-TURBOCHEETAH_IPK) $(PY25-TURBOCHEETAH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-TURBOCHEETAH_IPK) $(PY25-TURBOCHEETAH_IPK)
