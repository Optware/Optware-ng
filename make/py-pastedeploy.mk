###########################################################
#
# py-pastedeploy
#
###########################################################

#
# PY-PASTEDEPLOY_VERSION, PY-PASTEDEPLOY_SITE and PY-PASTEDEPLOY_SOURCE define
# the upstream location of the source code for the package.
# PY-PASTEDEPLOY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PASTEDEPLOY_UNZIP is the command used to unzip the source.
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
# PY-PASTEDEPLOY_IPK_VERSION should be incremented when the ipk changes.
#
PY-PASTEDEPLOY_SITE=http://cheeseshop.python.org/packages/source/P/PasteDeploy
PY-PASTEDEPLOY_VERSION=1.3.1
#PY-PASTEDEPLOY_SVN_REV=
PY-PASTEDEPLOY_IPK_VERSION=2
#ifneq ($(PY-PASTEDEPLOY_SVN_REV),)
#PY-PASTEDEPLOY_SVN=http://svn.pythonpaste.org/Paste/Script/trunk
#PY-PASTEDEPLOY_xxx_VERSION:=$(PY-PASTEDEPLOY_VERSION)dev_r$(PY-PASTEDEPLOY_SVN_REV)
#else
PY-PASTEDEPLOY_SOURCE=PasteDeploy-$(PY-PASTEDEPLOY_VERSION).tar.gz
#endif
PY-PASTEDEPLOY_DIR=PasteDeploy-$(PY-PASTEDEPLOY_VERSION)
PY-PASTEDEPLOY_UNZIP=zcat
PY-PASTEDEPLOY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PASTEDEPLOY_DESCRIPTION=Load, configure, and compose WSGI applications and servers.
PY-PASTEDEPLOY_SECTION=misc
PY-PASTEDEPLOY_PRIORITY=optional
PY24-PASTEDEPLOY_DEPENDS=python24
PY25-PASTEDEPLOY_DEPENDS=python25
PY-PASTEDEPLOY_SUGGESTS=
PY-PASTEDEPLOY_CONFLICTS=


#
# PY-PASTEDEPLOY_CONFFILES should be a list of user-editable files
#PY-PASTEDEPLOY_CONFFILES=/opt/etc/py-pastedeploy.conf /opt/etc/init.d/SXXpy-pastedeploy

#
# PY-PASTEDEPLOY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PASTEDEPLOY_PATCHES=$(PY-PASTEDEPLOY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PASTEDEPLOY_CPPFLAGS=
PY-PASTEDEPLOY_LDFLAGS=

#
# PY-PASTEDEPLOY_BUILD_DIR is the directory in which the build is done.
# PY-PASTEDEPLOY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PASTEDEPLOY_IPK_DIR is the directory in which the ipk is built.
# PY-PASTEDEPLOY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PASTEDEPLOY_BUILD_DIR=$(BUILD_DIR)/py-pastedeploy
PY-PASTEDEPLOY_SOURCE_DIR=$(SOURCE_DIR)/py-pastedeploy

PY24-PASTEDEPLOY_IPK_DIR=$(BUILD_DIR)/py24-pastedeploy-$(PY-PASTEDEPLOY_VERSION)-ipk
PY24-PASTEDEPLOY_IPK=$(BUILD_DIR)/py24-pastedeploy_$(PY-PASTEDEPLOY_VERSION)-$(PY-PASTEDEPLOY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PASTEDEPLOY_IPK_DIR=$(BUILD_DIR)/py25-pastedeploy-$(PY-PASTEDEPLOY_VERSION)-ipk
PY25-PASTEDEPLOY_IPK=$(BUILD_DIR)/py25-pastedeploy_$(PY-PASTEDEPLOY_VERSION)-$(PY-PASTEDEPLOY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pastedeploy-source py-pastedeploy-unpack py-pastedeploy py-pastedeploy-stage py-pastedeploy-ipk py-pastedeploy-clean py-pastedeploy-dirclean py-pastedeploy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-PASTEDEPLOY_SVN_REV),)
$(DL_DIR)/$(PY-PASTEDEPLOY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PASTEDEPLOY_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pastedeploy-source: $(DL_DIR)/$(PY-PASTEDEPLOY_SOURCE) $(PY-PASTEDEPLOY_PATCHES)

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
$(PY-PASTEDEPLOY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PASTEDEPLOY_SOURCE) $(PY-PASTEDEPLOY_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PASTEDEPLOY_BUILD_DIR)
	mkdir -p $(PY-PASTEDEPLOY_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR)
ifeq ($(PY-PASTEDEPLOY_SVN_REV),)
	$(PY-PASTEDEPLOY_UNZIP) $(DL_DIR)/$(PY-PASTEDEPLOY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTEDEPLOY_SVN_REV) $(PY-PASTEDEPLOY_SVN) $(PY-PASTEDEPLOY_DIR); \
	)
endif
	if test -n "$(PY-PASTEDEPLOY_PATCHES)" ; then \
	    cat $(PY-PASTEDEPLOY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR) $(PY-PASTEDEPLOY_BUILD_DIR)/2.4
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR)
ifeq ($(PY-PASTEDEPLOY_SVN_REV),)
	$(PY-PASTEDEPLOY_UNZIP) $(DL_DIR)/$(PY-PASTEDEPLOY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTEDEPLOY_SVN_REV) $(PY-PASTEDEPLOY_SVN) $(PY-PASTEDEPLOY_DIR); \
	)
endif
	if test -n "$(PY-PASTEDEPLOY_PATCHES)" ; then \
	    cat $(PY-PASTEDEPLOY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR) $(PY-PASTEDEPLOY_BUILD_DIR)/2.5
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-pastedeploy-unpack: $(PY-PASTEDEPLOY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PASTEDEPLOY_BUILD_DIR)/.built: $(PY-PASTEDEPLOY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-pastedeploy: $(PY-PASTEDEPLOY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PASTEDEPLOY_BUILD_DIR)/.staged: $(PY-PASTEDEPLOY_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-PASTEDEPLOY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-pastedeploy-stage: $(PY-PASTEDEPLOY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pastedeploy
#
$(PY24-PASTEDEPLOY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-pastedeploy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTEDEPLOY_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTEDEPLOY_SECTION)" >>$@
	@echo "Version: $(PY-PASTEDEPLOY_VERSION)-$(PY-PASTEDEPLOY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTEDEPLOY_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTEDEPLOY_SITE)/$(PY-PASTEDEPLOY_SOURCE)" >>$@
	@echo "Description: $(PY-PASTEDEPLOY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PASTEDEPLOY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTEDEPLOY_CONFLICTS)" >>$@

$(PY25-PASTEDEPLOY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pastedeploy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTEDEPLOY_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTEDEPLOY_SECTION)" >>$@
	@echo "Version: $(PY-PASTEDEPLOY_VERSION)-$(PY-PASTEDEPLOY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTEDEPLOY_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTEDEPLOY_SITE)/$(PY-PASTEDEPLOY_SOURCE)" >>$@
	@echo "Description: $(PY-PASTEDEPLOY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PASTEDEPLOY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTEDEPLOY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PASTEDEPLOY_IPK_DIR)/opt/sbin or $(PY-PASTEDEPLOY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PASTEDEPLOY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PASTEDEPLOY_IPK_DIR)/opt/etc/py-pastedeploy/...
# Documentation files should be installed in $(PY-PASTEDEPLOY_IPK_DIR)/opt/doc/py-pastedeploy/...
# Daemon startup scripts should be installed in $(PY-PASTEDEPLOY_IPK_DIR)/opt/etc/init.d/S??py-pastedeploy
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PASTEDEPLOY_IPK): $(PY-PASTEDEPLOY_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-pastedeploy_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-PASTEDEPLOY_IPK_DIR) $(BUILD_DIR)/py24-pastedeploy_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install\
		--root=$(PY24-PASTEDEPLOY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PASTEDEPLOY_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTEDEPLOY_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PASTEDEPLOY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PASTEDEPLOY_IPK_DIR)

$(PY25-PASTEDEPLOY_IPK): $(PY-PASTEDEPLOY_BUILD_DIR)/.built
	rm -rf $(PY25-PASTEDEPLOY_IPK_DIR) $(BUILD_DIR)/py25-pastedeploy_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTEDEPLOY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install\
		--root=$(PY25-PASTEDEPLOY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PASTEDEPLOY_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTEDEPLOY_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PASTEDEPLOY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PASTEDEPLOY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pastedeploy-ipk: $(PY24-PASTEDEPLOY_IPK) $(PY25-PASTEDEPLOY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pastedeploy-clean:
	-$(MAKE) -C $(PY-PASTEDEPLOY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pastedeploy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PASTEDEPLOY_DIR) $(PY-PASTEDEPLOY_BUILD_DIR)
	rm -rf $(PY24-PASTEDEPLOY_IPK_DIR) $(PY24-PASTEDEPLOY_IPK)
	rm -rf $(PY25-PASTEDEPLOY_IPK_DIR) $(PY25-PASTEDEPLOY_IPK)

#
# Some sanity check for the package.
#
py-pastedeploy-check: $(PY24-PASTEDEPLOY_IPK) $(PY25-PASTEDEPLOY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PASTEDEPLOY_IPK) $(PY25-PASTEDEPLOY_IPK)
