###########################################################
#
# py-nose
#
###########################################################

#
# PY-NOSE_VERSION, PY-NOSE_SITE and PY-NOSE_SOURCE define
# the upstream location of the source code for the package.
# PY-NOSE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-NOSE_UNZIP is the command used to unzip the source.
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
PY-NOSE_SITE=http://somethingaboutorange.com/mrl/projects/nose
PY-NOSE_VERSION=0.10.0
PY-NOSE_SOURCE=nose-$(PY-NOSE_VERSION).tar.gz
PY-NOSE_DIR=nose-$(PY-NOSE_VERSION)
PY-NOSE_UNZIP=zcat
PY-NOSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-NOSE_DESCRIPTION=A discovery-based python unittest extension.
PY-NOSE_SECTION=misc
PY-NOSE_PRIORITY=optional
PY24-NOSE_DEPENDS=python24
PY25-NOSE_DEPENDS=python25
PY-NOSE_CONFLICTS=

#
# PY-NOSE_IPK_VERSION should be incremented when the ipk changes.
#
PY-NOSE_IPK_VERSION=1

#
# PY-NOSE_CONFFILES should be a list of user-editable files
#PY-NOSE_CONFFILES=/opt/etc/py-nose.conf /opt/etc/init.d/SXXpy-nose

#
# PY-NOSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-NOSE_PATCHES=$(PY-NOSE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-NOSE_CPPFLAGS=
PY-NOSE_LDFLAGS=

#
# PY-NOSE_BUILD_DIR is the directory in which the build is done.
# PY-NOSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-NOSE_IPK_DIR is the directory in which the ipk is built.
# PY-NOSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-NOSE_BUILD_DIR=$(BUILD_DIR)/py-nose
PY-NOSE_SOURCE_DIR=$(SOURCE_DIR)/py-nose

PY24-NOSE_IPK_DIR=$(BUILD_DIR)/py-nose-$(PY-NOSE_VERSION)-ipk
PY24-NOSE_IPK=$(BUILD_DIR)/py-nose_$(PY-NOSE_VERSION)-$(PY-NOSE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-NOSE_IPK_DIR=$(BUILD_DIR)/py25-nose-$(PY-NOSE_VERSION)-ipk
PY25-NOSE_IPK=$(BUILD_DIR)/py25-nose_$(PY-NOSE_VERSION)-$(PY-NOSE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-NOSE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-NOSE_SITE)/$(PY-NOSE_SOURCE)

.PHONY: py-nose-source py-nose-unpack py-nose py-nose-stage py-nose-ipk py-nose-clean py-nose-dirclean py-nose-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-nose-source: $(DL_DIR)/$(PY-NOSE_SOURCE) $(PY-NOSE_PATCHES)

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
$(PY-NOSE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-NOSE_SOURCE) $(PY-NOSE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-NOSE_BUILD_DIR)
	mkdir -p $(PY-NOSE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-NOSE_DIR)
	$(PY-NOSE_UNZIP) $(DL_DIR)/$(PY-NOSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-NOSE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-NOSE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-NOSE_DIR) $(PY-NOSE_BUILD_DIR)/2.4
	(cd $(PY-NOSE_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-NOSE_DIR)
	$(PY-NOSE_UNZIP) $(DL_DIR)/$(PY-NOSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-NOSE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-NOSE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-NOSE_DIR) $(PY-NOSE_BUILD_DIR)/2.5
	(cd $(PY-NOSE_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-NOSE_BUILD_DIR)/.configured

py-nose-unpack: $(PY-NOSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-NOSE_BUILD_DIR)/.built: $(PY-NOSE_BUILD_DIR)/.configured
	rm -f $(PY-NOSE_BUILD_DIR)/.built
	(cd $(PY-NOSE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-NOSE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
#	$(MAKE) -C $(PY-NOSE_BUILD_DIR)
	touch $(PY-NOSE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-nose: $(PY-NOSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-NOSE_BUILD_DIR)/.staged: $(PY-NOSE_BUILD_DIR)/.built
	rm -f $(PY-NOSE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-NOSE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-NOSE_BUILD_DIR)/.staged

py-nose-stage: $(PY-NOSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-nose
#
$(PY24-NOSE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-nose" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-NOSE_PRIORITY)" >>$@
	@echo "Section: $(PY-NOSE_SECTION)" >>$@
	@echo "Version: $(PY-NOSE_VERSION)-$(PY-NOSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-NOSE_MAINTAINER)" >>$@
	@echo "Source: $(PY-NOSE_SITE)/$(PY-NOSE_SOURCE)" >>$@
	@echo "Description: $(PY-NOSE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-NOSE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-NOSE_CONFLICTS)" >>$@

$(PY25-NOSE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-nose" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-NOSE_PRIORITY)" >>$@
	@echo "Section: $(PY-NOSE_SECTION)" >>$@
	@echo "Version: $(PY-NOSE_VERSION)-$(PY-NOSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-NOSE_MAINTAINER)" >>$@
	@echo "Source: $(PY-NOSE_SITE)/$(PY-NOSE_SOURCE)" >>$@
	@echo "Description: $(PY-NOSE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-NOSE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-NOSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-NOSE_IPK_DIR)/opt/sbin or $(PY-NOSE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-NOSE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-NOSE_IPK_DIR)/opt/etc/py-nose/...
# Documentation files should be installed in $(PY-NOSE_IPK_DIR)/opt/doc/py-nose/...
# Daemon startup scripts should be installed in $(PY-NOSE_IPK_DIR)/opt/etc/init.d/S??py-nose
#
# You may need to patch your application to make it use these locations.
#
$(PY24-NOSE_IPK): $(PY-NOSE_BUILD_DIR)/.built
	rm -rf $(PY24-NOSE_IPK_DIR) $(BUILD_DIR)/py-nose_*_$(TARGET_ARCH).ipk
	(cd $(PY-NOSE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-NOSE_IPK_DIR) --prefix=/opt)
	rm -rf $(PY24-NOSE_IPK_DIR)/opt/man/
	for f in $(PY24-NOSE_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-NOSE_IPK_DIR)/CONTROL/control
#	echo $(PY-NOSE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-NOSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-NOSE_IPK_DIR)

$(PY25-NOSE_IPK): $(PY-NOSE_BUILD_DIR)/.built
	rm -rf $(PY25-NOSE_IPK_DIR) $(BUILD_DIR)/py25-nose_*_$(TARGET_ARCH).ipk
	(cd $(PY-NOSE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-NOSE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-NOSE_IPK_DIR)/CONTROL/control
#	echo $(PY-NOSE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-NOSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-NOSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-nose-ipk: $(PY24-NOSE_IPK) $(PY25-NOSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-nose-clean:
	-$(MAKE) -C $(PY-NOSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-nose-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-NOSE_DIR) $(PY-NOSE_BUILD_DIR)
	rm -rf $(PY24-NOSE_IPK_DIR) $(PY24-NOSE_IPK)
	rm -rf $(PY25-NOSE_IPK_DIR) $(PY25-NOSE_IPK)

#
# Some sanity check for the package.
#
py-nose-check: $(PY24-NOSE_IPK) $(PY25-NOSE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-NOSE_IPK) $(PY25-NOSE_IPK)
