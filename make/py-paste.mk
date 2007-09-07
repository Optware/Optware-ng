###########################################################
#
# py-paste
#
###########################################################

#
# PY-PASTE_VERSION, PY-PASTE_SITE and PY-PASTE_SOURCE define
# the upstream location of the source code for the package.
# PY-PASTE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PASTE_UNZIP is the command used to unzip the source.
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
# PY-PASTE_IPK_VERSION should be incremented when the ipk changes.
#
#PY-PASTE_SVN=http://svn.pythonpaste.org/Paste/trunk
#PY-PASTE_SVN_REV=4745
#ifneq ($(PY-PASTE_SVN_REV),)
#PY-PASTE____VERSION=0.5dev_r4745
#else
PY-PASTE_VERSION=1.4.2
PY-PASTE_SITE=http://cheeseshop.python.org/packages/source/P/Paste
PY-PASTE_SOURCE=Paste-$(PY-PASTE_VERSION).tar.gz
#endif
PY-PASTE_DIR=Paste-$(PY-PASTE_VERSION)
PY-PASTE_UNZIP=zcat
PY-PASTE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PASTE_DESCRIPTION=Tools for using a Web Server Gateway Interface stack.
PY-PASTE_SECTION=misc
PY-PASTE_PRIORITY=optional
PY24-PASTE_DEPENDS=python24
PY25-PASTE_DEPENDS=python25
PY-PASTE_SUGGESTS=
PY-PASTE_CONFLICTS=

PY-PASTE_IPK_VERSION=1

#
# PY-PASTE_CONFFILES should be a list of user-editable files
#PY-PASTE_CONFFILES=/opt/etc/py-paste.conf /opt/etc/init.d/SXXpy-paste

#
# PY-PASTE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PASTE_PATCHES=$(PY-PASTE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PASTE_CPPFLAGS=
PY-PASTE_LDFLAGS=

#
# PY-PASTE_BUILD_DIR is the directory in which the build is done.
# PY-PASTE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PASTE_IPK_DIR is the directory in which the ipk is built.
# PY-PASTE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PASTE_BUILD_DIR=$(BUILD_DIR)/py-paste
PY-PASTE_SOURCE_DIR=$(SOURCE_DIR)/py-paste

PY24-PASTE_IPK_DIR=$(BUILD_DIR)/py-paste-$(PY-PASTE_VERSION)-ipk
PY24-PASTE_IPK=$(BUILD_DIR)/py-paste_$(PY-PASTE_VERSION)-$(PY-PASTE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PASTE_IPK_DIR=$(BUILD_DIR)/py25-paste-$(PY-PASTE_VERSION)-ipk
PY25-PASTE_IPK=$(BUILD_DIR)/py25-paste_$(PY-PASTE_VERSION)-$(PY-PASTE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-paste-source py-paste-unpack py-paste py-paste-stage py-paste-ipk py-paste-clean py-paste-dirclean py-paste-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-PASTE_SVN_REV),)
$(DL_DIR)/$(PY-PASTE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PASTE_SITE)/$(PY-PASTE_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-paste-source: $(DL_DIR)/$(PY-PASTE_SOURCE) $(PY-PASTE_PATCHES)

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
$(PY-PASTE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PASTE_SOURCE) $(PY-PASTE_PATCHES) make/py-paste.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PASTE_BUILD_DIR)
	mkdir -p $(PY-PASTE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PASTE_DIR)
ifeq ($(PY-PASTE_SVN_REV),)
	$(PY-PASTE_UNZIP) $(DL_DIR)/$(PY-PASTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTE_SVN_REV) $(PY-PASTE_SVN) $(PY-PASTE_DIR); \
	)
endif
	if test -n "$(PY-PASTE_PATCHES)" ; then \
	    cat $(PY-PASTE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTE_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTE_DIR) $(PY-PASTE_BUILD_DIR)/2.4
	(cd $(PY-PASTE_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PASTE_DIR)
ifeq ($(PY-PASTE_SVN_REV),)
	$(PY-PASTE_UNZIP) $(DL_DIR)/$(PY-PASTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-PASTE_SVN_REV) $(PY-PASTE_SVN) $(PY-PASTE_DIR); \
	)
endif
	if test -n "$(PY-PASTE_PATCHES)" ; then \
	    cat $(PY-PASTE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTE_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PASTE_DIR) $(PY-PASTE_BUILD_DIR)/2.5
	(cd $(PY-PASTE_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $(PY-PASTE_BUILD_DIR)/.configured

py-paste-unpack: $(PY-PASTE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PASTE_BUILD_DIR)/.built: $(PY-PASTE_BUILD_DIR)/.configured
	rm -f $(PY-PASTE_BUILD_DIR)/.built
	(cd $(PY-PASTE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-PASTE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-PASTE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-paste: $(PY-PASTE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PASTE_BUILD_DIR)/.staged: $(PY-PASTE_BUILD_DIR)/.built
	rm -f $(PY-PASTE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-PASTE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-PASTE_BUILD_DIR)/.staged

py-paste-stage: $(PY-PASTE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-paste
#
$(PY24-PASTE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-paste" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTE_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTE_SECTION)" >>$@
	@echo "Version: $(PY-PASTE_VERSION)-$(PY-PASTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTE_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTE_SITE)/$(PY-PASTE_SOURCE)" >>$@
	@echo "Description: $(PY-PASTE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PASTE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTE_CONFLICTS)" >>$@

$(PY25-PASTE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-paste" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTE_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTE_SECTION)" >>$@
	@echo "Version: $(PY-PASTE_VERSION)-$(PY-PASTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTE_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTE_SITE)/$(PY-PASTE_SOURCE)" >>$@
	@echo "Description: $(PY-PASTE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PASTE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PASTE_IPK_DIR)/opt/sbin or $(PY-PASTE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PASTE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PASTE_IPK_DIR)/opt/etc/py-paste/...
# Documentation files should be installed in $(PY-PASTE_IPK_DIR)/opt/doc/py-paste/...
# Daemon startup scripts should be installed in $(PY-PASTE_IPK_DIR)/opt/etc/init.d/S??py-paste
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PASTE_IPK): $(PY-PASTE_BUILD_DIR)/.built
	rm -rf $(PY24-PASTE_IPK_DIR) $(BUILD_DIR)/py-paste_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-PASTE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PASTE_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PASTE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PASTE_IPK_DIR)

$(PY25-PASTE_IPK): $(PY-PASTE_BUILD_DIR)/.built
	rm -rf $(PY25-PASTE_IPK_DIR) $(BUILD_DIR)/py25-paste_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-PASTE_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PASTE_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PASTE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PASTE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-paste-ipk: $(PY24-PASTE_IPK) $(PY25-PASTE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-paste-clean:
	-$(MAKE) -C $(PY-PASTE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-paste-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PASTE_DIR) $(PY-PASTE_BUILD_DIR)
	rm -rf $(PY24-PASTE_IPK_DIR) $(PY24-PASTE_IPK)
	rm -rf $(PY25-PASTE_IPK_DIR) $(PY25-PASTE_IPK)

#
# Some sanity check for the package.
#
py-paste-check: $(PY24-PASTE_IPK) $(PY25-PASTE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PASTE_IPK) $(PY25-PASTE_IPK)
