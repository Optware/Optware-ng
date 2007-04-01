###########################################################
#
# py-pastescript
#
###########################################################

#
# PY-PASTESCRIPT_VERSION, PY-PASTESCRIPT_SITE and PY-PASTESCRIPT_SOURCE define
# the upstream location of the source code for the package.
# PY-PASTESCRIPT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PASTESCRIPT_UNZIP is the command used to unzip the source.
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
# PY-PASTESCRIPT_IPK_VERSION should be incremented when the ipk changes.
#
PY-PASTESCRIPT_SITE=http://cheeseshop.python.org/packages/source/P/PasteScript
PY-PASTESCRIPT_VERSION=1.3.1
#PY-PASTESCRIPT_SVN_REV=
PY-PASTESCRIPT_IPK_VERSION=1
#ifneq ($(PY-PASTESCRIPT_SVN_REV),)
#PY-PASTESCRIPT_SVN=http://svn.pythonpaste.org/Paste/Script/trunk
#PY-PASTESCRIPT_xxx_VERSION:=$(PY-PASTESCRIPT_VERSION)dev_r$(PY-PASTESCRIPT_SVN_REV)
#else
PY-PASTESCRIPT_SOURCE=PasteScript-$(PY-PASTESCRIPT_VERSION).tar.gz
#endif
PY-PASTESCRIPT_DIR=PasteScript-$(PY-PASTESCRIPT_VERSION)
PY-PASTESCRIPT_UNZIP=zcat
PY-PASTESCRIPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PASTESCRIPT_DESCRIPTION=A pluggable command-line frontend, including commands to setup package file layouts.
PY-PASTESCRIPT_SECTION=misc
PY-PASTESCRIPT_PRIORITY=optional
PY24-PASTESCRIPT_DEPENDS=python24, py-cheetah, py-paste, py-pastedeploy
PY25-PASTESCRIPT_DEPENDS=python25, py25-cheetah, py25-paste, py25-pastedeploy
PY-PASTESCRIPT_SUGGESTS=
PY-PASTESCRIPT_CONFLICTS=

#
# PY-PASTESCRIPT_CONFFILES should be a list of user-editable files
#PY-PASTESCRIPT_CONFFILES=/opt/etc/py-pastescript.conf /opt/etc/init.d/SXXpy-pastescript

#
# PY-PASTESCRIPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PASTESCRIPT_PATCHES=$(PY-PASTESCRIPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PASTESCRIPT_CPPFLAGS=
PY-PASTESCRIPT_LDFLAGS=

#
# PY-PASTESCRIPT_BUILD_DIR is the directory in which the build is done.
# PY-PASTESCRIPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PASTESCRIPT_IPK_DIR is the directory in which the ipk is built.
# PY-PASTESCRIPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PASTESCRIPT_BUILD_DIR=$(BUILD_DIR)/py-pastescript
PY-PASTESCRIPT_SOURCE_DIR=$(SOURCE_DIR)/py-pastescript

PY24-PASTESCRIPT_IPK_DIR=$(BUILD_DIR)/py-pastescript-$(PY-PASTESCRIPT_VERSION)-ipk
PY24-PASTESCRIPT_IPK=$(BUILD_DIR)/py-pastescript_$(PY-PASTESCRIPT_VERSION)-$(PY-PASTESCRIPT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PASTESCRIPT_IPK_DIR=$(BUILD_DIR)/py25-pastescript-$(PY-PASTESCRIPT_VERSION)-ipk
PY25-PASTESCRIPT_IPK=$(BUILD_DIR)/py25-pastescript_$(PY-PASTESCRIPT_VERSION)-$(PY-PASTESCRIPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pastescript-source py-pastescript-unpack py-pastescript py-pastescript-stage py-pastescript-ipk py-pastescript-clean py-pastescript-dirclean py-pastescript-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-PASTESCRIPT_SVN_REV),)
$(DL_DIR)/$(PY-PASTESCRIPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PASTESCRIPT_SITE)/$(PY-PASTESCRIPT_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pastescript-source: $(DL_DIR)/$(PY-PASTESCRIPT_SOURCE) $(PY-PASTESCRIPT_PATCHES)

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
$(PY-PASTESCRIPT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PASTESCRIPT_SOURCE) $(PY-PASTESCRIPT_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PASTESCRIPT_BUILD_DIR)
	mkdir -p $(PY-PASTESCRIPT_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR)
ifeq ($(PY-PASTESCRIPT_SVN_REV),)
	$(PY-PASTESCRIPT_UNZIP) $(DL_DIR)/$(PY-PASTESCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTESCRIPT_SVN_REV) $(PY-PASTESCRIPT_SVN) $(PY-PASTESCRIPT_DIR); \
	)
endif
	if test -n "$(PY-PASTESCRIPT_PATCHES)" ; then \
	    cat $(PY-PASTESCRIPT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR) $(PY-PASTESCRIPT_BUILD_DIR)/2.4
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR)
ifeq ($(PY-PASTESCRIPT_SVN_REV),)
	$(PY-PASTESCRIPT_UNZIP) $(DL_DIR)/$(PY-PASTESCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTESCRIPT_SVN_REV) $(PY-PASTESCRIPT_SVN) $(PY-PASTESCRIPT_DIR); \
	)
endif
	if test -n "$(PY-PASTESCRIPT_PATCHES)" ; then \
	    cat $(PY-PASTESCRIPT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR) $(PY-PASTESCRIPT_BUILD_DIR)/2.5
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-PASTESCRIPT_BUILD_DIR)/.configured

py-pastescript-unpack: $(PY-PASTESCRIPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PASTESCRIPT_BUILD_DIR)/.built: $(PY-PASTESCRIPT_BUILD_DIR)/.configured
	rm -f $(PY-PASTESCRIPT_BUILD_DIR)/.built
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-PASTESCRIPT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-pastescript: $(PY-PASTESCRIPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PASTESCRIPT_BUILD_DIR)/.staged: $(PY-PASTESCRIPT_BUILD_DIR)/.built
	rm -f $(PY-PASTESCRIPT_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-PASTESCRIPT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-PASTESCRIPT_BUILD_DIR)/.staged

py-pastescript-stage: $(PY-PASTESCRIPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pastescript
#
$(PY24-PASTESCRIPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-pastescript" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTESCRIPT_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTESCRIPT_SECTION)" >>$@
	@echo "Version: $(PY-PASTESCRIPT_VERSION)-$(PY-PASTESCRIPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTESCRIPT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTESCRIPT_SITE)/$(PY-PASTESCRIPT_SOURCE)" >>$@
	@echo "Description: $(PY-PASTESCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PASTESCRIPT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTESCRIPT_CONFLICTS)" >>$@

$(PY25-PASTESCRIPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pastescript" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTESCRIPT_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTESCRIPT_SECTION)" >>$@
	@echo "Version: $(PY-PASTESCRIPT_VERSION)-$(PY-PASTESCRIPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTESCRIPT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTESCRIPT_SITE)/$(PY-PASTESCRIPT_SOURCE)" >>$@
	@echo "Description: $(PY-PASTESCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PASTESCRIPT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTESCRIPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PASTESCRIPT_IPK_DIR)/opt/sbin or $(PY-PASTESCRIPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PASTESCRIPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PASTESCRIPT_IPK_DIR)/opt/etc/py-pastescript/...
# Documentation files should be installed in $(PY-PASTESCRIPT_IPK_DIR)/opt/doc/py-pastescript/...
# Daemon startup scripts should be installed in $(PY-PASTESCRIPT_IPK_DIR)/opt/etc/init.d/S??py-pastescript
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PASTESCRIPT_IPK): $(PY-PASTESCRIPT_BUILD_DIR)/.built
	rm -rf $(PY24-PASTESCRIPT_IPK_DIR) $(BUILD_DIR)/py-pastescript_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-PASTESCRIPT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PASTESCRIPT_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTESCRIPT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PASTESCRIPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PASTESCRIPT_IPK_DIR)

$(PY25-PASTESCRIPT_IPK): $(PY-PASTESCRIPT_BUILD_DIR)/.built
	rm -rf $(PY25-PASTESCRIPT_IPK_DIR) $(BUILD_DIR)/py25-pastescript_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTESCRIPT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-PASTESCRIPT_IPK_DIR) --prefix=/opt)
	for f in $(PY25-PASTESCRIPT_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-PASTESCRIPT_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTESCRIPT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PASTESCRIPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PASTESCRIPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pastescript-ipk: $(PY24-PASTESCRIPT_IPK) $(PY25-PASTESCRIPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pastescript-clean:
	-$(MAKE) -C $(PY-PASTESCRIPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pastescript-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PASTESCRIPT_DIR) $(PY-PASTESCRIPT_BUILD_DIR)
	rm -rf $(PY24-PASTESCRIPT_IPK_DIR) $(PY24-PASTESCRIPT_IPK)
	rm -rf $(PY25-PASTESCRIPT_IPK_DIR) $(PY25-PASTESCRIPT_IPK)

#
# Some sanity check for the package.
#
py-pastescript-check: $(PY24-PASTESCRIPT_IPK) $(PY25-PASTESCRIPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PASTESCRIPT_IPK) $(PY25-PASTESCRIPT_IPK)
