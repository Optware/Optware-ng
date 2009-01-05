###########################################################
#
# py-decorator
#
###########################################################

#
# PY-DECORATOR_VERSION, PY-DECORATOR_SITE and PY-DECORATOR_SOURCE define
# the upstream location of the source code for the package.
# PY-DECORATOR_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DECORATOR_UNZIP is the command used to unzip the source.
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
# PY-DECORATOR_IPK_VERSION should be incremented when the ipk changes.
#
PY-DECORATOR_SITE=http://www.phyast.pitt.edu/~micheles/python
PY-DECORATOR_VERSION=2.3.0
PY-DECORATOR_IPK_VERSION=2
PY-DECORATOR_SOURCE=decorator-$(PY-DECORATOR_VERSION).zip
PY-DECORATOR_DIR=decorator-$(PY-DECORATOR_VERSION)
PY-DECORATOR_UNZIP=unzip
PY-DECORATOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DECORATOR_DESCRIPTION=A library of helper functions intended to make writing templates in web applications easier.
PY-DECORATOR_SECTION=misc
PY-DECORATOR_PRIORITY=optional
PY24-DECORATOR_DEPENDS=python24
PY25-DECORATOR_DEPENDS=python25
PY26-DECORATOR_DEPENDS=python26
PY-DECORATOR_SUGGESTS=
PY-DECORATOR_CONFLICTS=


#
# PY-DECORATOR_CONFFILES should be a list of user-editable files
#PY-DECORATOR_CONFFILES=/opt/etc/py-decorator.conf /opt/etc/init.d/SXXpy-decorator

#
# PY-DECORATOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DECORATOR_PATCHES=$(PY-DECORATOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DECORATOR_CPPFLAGS=
PY-DECORATOR_LDFLAGS=

#
# PY-DECORATOR_BUILD_DIR is the directory in which the build is done.
# PY-DECORATOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DECORATOR_IPK_DIR is the directory in which the ipk is built.
# PY-DECORATOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DECORATOR_BUILD_DIR=$(BUILD_DIR)/py-decorator
PY-DECORATOR_SOURCE_DIR=$(SOURCE_DIR)/py-decorator

PY24-DECORATOR_IPK_DIR=$(BUILD_DIR)/py24-decorator-$(PY-DECORATOR_VERSION)-ipk
PY24-DECORATOR_IPK=$(BUILD_DIR)/py24-decorator_$(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-DECORATOR_IPK_DIR=$(BUILD_DIR)/py25-decorator-$(PY-DECORATOR_VERSION)-ipk
PY25-DECORATOR_IPK=$(BUILD_DIR)/py25-decorator_$(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-DECORATOR_IPK_DIR=$(BUILD_DIR)/py26-decorator-$(PY-DECORATOR_VERSION)-ipk
PY26-DECORATOR_IPK=$(BUILD_DIR)/py26-decorator_$(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-decorator-source py-decorator-unpack py-decorator py-decorator-stage py-decorator-ipk py-decorator-clean py-decorator-dirclean py-decorator-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DECORATOR_SOURCE):
	$(WGET) -P $(@D) $(PY-DECORATOR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-decorator-source: $(DL_DIR)/$(PY-DECORATOR_SOURCE) $(PY-DECORATOR_PATCHES)

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
$(PY-DECORATOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DECORATOR_SOURCE) $(PY-DECORATOR_PATCHES) make/py-decorator.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	mkdir -p $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	cd $(BUILD_DIR)/$(PY-DECORATOR_DIR) && $(PY-DECORATOR_UNZIP) $(DL_DIR)/$(PY-DECORATOR_SOURCE)
	if test -n "$(PY-DECORATOR_PATCHES)" ; then \
	    cat $(PY-DECORATOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DECORATOR_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-DECORATOR_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	mkdir -p $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	cd $(BUILD_DIR)/$(PY-DECORATOR_DIR) && $(PY-DECORATOR_UNZIP) $(DL_DIR)/$(PY-DECORATOR_SOURCE)
	if test -n "$(PY-DECORATOR_PATCHES)" ; then \
	    cat $(PY-DECORATOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DECORATOR_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-DECORATOR_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	mkdir -p $(BUILD_DIR)/$(PY-DECORATOR_DIR)
	cd $(BUILD_DIR)/$(PY-DECORATOR_DIR) && $(PY-DECORATOR_UNZIP) $(DL_DIR)/$(PY-DECORATOR_SOURCE)
	if test -n "$(PY-DECORATOR_PATCHES)" ; then \
	    cat $(PY-DECORATOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DECORATOR_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-DECORATOR_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.6") >> setup.cfg \
	)
	touch $@

py-decorator-unpack: $(PY-DECORATOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DECORATOR_BUILD_DIR)/.built: $(PY-DECORATOR_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
py-decorator: $(PY-DECORATOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-DECORATOR_BUILD_DIR)/.staged: $(PY-DECORATOR_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

py-decorator-stage: $(PY-DECORATOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-decorator
#
$(PY24-DECORATOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-decorator" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DECORATOR_PRIORITY)" >>$@
	@echo "Section: $(PY-DECORATOR_SECTION)" >>$@
	@echo "Version: $(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DECORATOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-DECORATOR_SITE)/$(PY-DECORATOR_SOURCE)" >>$@
	@echo "Description: $(PY-DECORATOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-DECORATOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DECORATOR_CONFLICTS)" >>$@

$(PY25-DECORATOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-decorator" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DECORATOR_PRIORITY)" >>$@
	@echo "Section: $(PY-DECORATOR_SECTION)" >>$@
	@echo "Version: $(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DECORATOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-DECORATOR_SITE)/$(PY-DECORATOR_SOURCE)" >>$@
	@echo "Description: $(PY-DECORATOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DECORATOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DECORATOR_CONFLICTS)" >>$@

$(PY26-DECORATOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-decorator" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DECORATOR_PRIORITY)" >>$@
	@echo "Section: $(PY-DECORATOR_SECTION)" >>$@
	@echo "Version: $(PY-DECORATOR_VERSION)-$(PY-DECORATOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DECORATOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-DECORATOR_SITE)/$(PY-DECORATOR_SOURCE)" >>$@
	@echo "Description: $(PY-DECORATOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-DECORATOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DECORATOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DECORATOR_IPK_DIR)/opt/sbin or $(PY-DECORATOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DECORATOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-DECORATOR_IPK_DIR)/opt/etc/py-decorator/...
# Documentation files should be installed in $(PY-DECORATOR_IPK_DIR)/opt/doc/py-decorator/...
# Daemon startup scripts should be installed in $(PY-DECORATOR_IPK_DIR)/opt/etc/init.d/S??py-decorator
#
# You may need to patch your application to make it use these locations.
#
$(PY24-DECORATOR_IPK): $(PY-DECORATOR_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-decorator_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-DECORATOR_IPK_DIR) $(BUILD_DIR)/py24-decorator_*_$(TARGET_ARCH).ipk
	(cd $(PY-DECORATOR_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-DECORATOR_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-DECORATOR_IPK_DIR)/CONTROL/control
#	echo $(PY-DECORATOR_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-DECORATOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-DECORATOR_IPK_DIR)

$(PY25-DECORATOR_IPK): $(PY-DECORATOR_BUILD_DIR)/.built
	rm -rf $(PY25-DECORATOR_IPK_DIR) $(BUILD_DIR)/py25-decorator_*_$(TARGET_ARCH).ipk
	(cd $(PY-DECORATOR_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-DECORATOR_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-DECORATOR_IPK_DIR)/CONTROL/control
#	echo $(PY-DECORATOR_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-DECORATOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DECORATOR_IPK_DIR)

$(PY26-DECORATOR_IPK): $(PY-DECORATOR_BUILD_DIR)/.built
	rm -rf $(PY26-DECORATOR_IPK_DIR) $(BUILD_DIR)/py26-decorator_*_$(TARGET_ARCH).ipk
	(cd $(PY-DECORATOR_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-DECORATOR_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-DECORATOR_IPK_DIR)/CONTROL/control
#	echo $(PY-DECORATOR_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-DECORATOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-DECORATOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-decorator-ipk: $(PY24-DECORATOR_IPK) $(PY25-DECORATOR_IPK) $(PY26-DECORATOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-decorator-clean:
	-$(MAKE) -C $(PY-DECORATOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-decorator-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DECORATOR_DIR) $(PY-DECORATOR_BUILD_DIR)
	rm -rf $(PY24-DECORATOR_IPK_DIR) $(PY24-DECORATOR_IPK)
	rm -rf $(PY25-DECORATOR_IPK_DIR) $(PY25-DECORATOR_IPK)
	rm -rf $(PY26-DECORATOR_IPK_DIR) $(PY26-DECORATOR_IPK)

#
# Some sanity check for the package.
#
py-decorator-check: $(PY24-DECORATOR_IPK) $(PY25-DECORATOR_IPK) $(PY26-DECORATOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
