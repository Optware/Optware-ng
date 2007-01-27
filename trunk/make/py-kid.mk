###########################################################
#
# py-kid
#
###########################################################

#
# PY-KID_VERSION, PY-KID_SITE and PY-KID_SOURCE define
# the upstream location of the source code for the package.
# PY-KID_DIR is the directory which is created when the source
# archive is unpacked.
# PY-KID_UNZIP is the command used to unzip the source.
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
PY-KID_VERSION=0.9.5
PY-KID_SITE=http://www.kid-templating.org/dist/$(PY-KID_VERSION)
PY-KID_SOURCE=kid-$(PY-KID_VERSION).tar.gz
PY-KID_DIR=kid-$(PY-KID_VERSION)
PY-KID_UNZIP=zcat
PY-KID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-KID_DESCRIPTION=Pythonic XML-based Templating
PY-KID_SECTION=misc
PY-KID_PRIORITY=optional
PY24-KID_DEPENDS=python24, py24-elementtree
PY25-KID_DEPENDS=python25, py25-elementtree
PY-KID_CONFLICTS=

#
# PY-KID_IPK_VERSION should be incremented when the ipk changes.
#
PY-KID_IPK_VERSION=1

#
# PY-KID_CONFFILES should be a list of user-editable files
#PY-KID_CONFFILES=/opt/etc/py-kid.conf /opt/etc/init.d/SXXpy-kid

#
# PY-KID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-KID_PATCHES=$(PY-KID_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-KID_CPPFLAGS=
PY-KID_LDFLAGS=

#
# PY-KID_BUILD_DIR is the directory in which the build is done.
# PY-KID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-KID_IPK_DIR is the directory in which the ipk is built.
# PY-KID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-KID_BUILD_DIR=$(BUILD_DIR)/py-kid
PY-KID_SOURCE_DIR=$(SOURCE_DIR)/py-kid

PY24-KID_IPK_DIR=$(BUILD_DIR)/py-kid-$(PY-KID_VERSION)-ipk
PY24-KID_IPK=$(BUILD_DIR)/py-kid_$(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-KID_IPK_DIR=$(BUILD_DIR)/py25-kid-$(PY-KID_VERSION)-ipk
PY25-KID_IPK=$(BUILD_DIR)/py25-kid_$(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-kid-source py-kid-unpack py-kid py-kid-stage py-kid-ipk py-kid-clean py-kid-dirclean py-kid-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-KID_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-KID_SITE)/$(PY-KID_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-kid-source: $(DL_DIR)/$(PY-KID_SOURCE) $(PY-KID_PATCHES)

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
$(PY-KID_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-KID_SOURCE) $(PY-KID_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)
	mkdir $(PY-KID_BUILD_DIR)
	# 2.4
	$(PY-KID_UNZIP) $(DL_DIR)/$(PY-KID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-KID_PATCHES)"; then \
	    cat $(PY-KID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-KID_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)/2.4
	(cd $(PY-KID_BUILD_DIR)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.5
	$(PY-KID_UNZIP) $(DL_DIR)/$(PY-KID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-KID_PATCHES)"; then \
	    cat $(PY-KID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-KID_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)/2.5
	(cd $(PY-KID_BUILD_DIR)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $(PY-KID_BUILD_DIR)/.configured

py-kid-unpack: $(PY-KID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-KID_BUILD_DIR)/.built: $(PY-KID_BUILD_DIR)/.configured
	rm -f $(PY-KID_BUILD_DIR)/.built
	(cd $(PY-KID_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-KID_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-KID_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-kid: $(PY-KID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-KID_BUILD_DIR)/.staged: $(PY-KID_BUILD_DIR)/.built
	rm -f $(PY-KID_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-KID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-KID_BUILD_DIR)/.staged

py-kid-stage: $(PY-KID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-kid
#
$(PY24-KID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-kid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-KID_PRIORITY)" >>$@
	@echo "Section: $(PY-KID_SECTION)" >>$@
	@echo "Version: $(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-KID_MAINTAINER)" >>$@
	@echo "Source: $(PY-KID_SITE)/$(PY-KID_SOURCE)" >>$@
	@echo "Description: $(PY-KID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-KID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-KID_CONFLICTS)" >>$@

$(PY25-KID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-kid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-KID_PRIORITY)" >>$@
	@echo "Section: $(PY-KID_SECTION)" >>$@
	@echo "Version: $(PY-KID_VERSION)-$(PY-KID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-KID_MAINTAINER)" >>$@
	@echo "Source: $(PY-KID_SITE)/$(PY-KID_SOURCE)" >>$@
	@echo "Description: $(PY-KID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-KID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-KID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-KID_IPK_DIR)/opt/sbin or $(PY-KID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-KID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-KID_IPK_DIR)/opt/etc/py-kid/...
# Documentation files should be installed in $(PY-KID_IPK_DIR)/opt/doc/py-kid/...
# Daemon startup scripts should be installed in $(PY-KID_IPK_DIR)/opt/etc/init.d/S??py-kid
#
# You may need to patch your application to make it use these locations.
#
$(PY24-KID_IPK) $(PY25-KID_IPK): $(PY-KID_BUILD_DIR)/.built
	rm -rf $(PY-KID_IPK_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/py-kid_*_$(TARGET_ARCH).ipk
	(cd $(PY-KID_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-KID_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-KID_IPK_DIR)/CONTROL/control
#	echo $(PY-KID_CONFFILES) | sed -e 's/ /\n/g' > $(PY-KID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-KID_IPK_DIR)
	# 2.5
	rm -rf $(BUILD_DIR)/py25-kid_*_$(TARGET_ARCH).ipk
	(cd $(PY-KID_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-KID_IPK_DIR) --prefix=/opt)
	for f in $(PY25-KID_IPK_DIR)/opt/*bin/*; \
            do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-KID_IPK_DIR)/CONTROL/control
#	echo $(PY-KID_CONFFILES) | sed -e 's/ /\n/g' > $(PY-KID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-KID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-kid-ipk: $(PY24-KID_IPK) $(PY25-KID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-kid-clean:
	-$(MAKE) -C $(PY-KID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-kid-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-KID_DIR) $(PY-KID_BUILD_DIR)
	rm -rf $(PY24-KID_IPK_DIR) $(PY24-KID_IPK)
	rm -rf $(PY25-KID_IPK_DIR) $(PY25-KID_IPK)

#
# Some sanity check for the package.
#
py-kid-check: $(PY24-KID_IPK) $(PY25-KID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-KID_IPK) $(PY25-KID_IPK)
