###########################################################
#
# py-sqlalchemy
#
###########################################################

#
# PY-SQLALCHEMY_VERSION, PY-SQLALCHEMY_SITE and PY-SQLALCHEMY_SOURCE define
# the upstream location of the source code for the package.
# PY-SQLALCHEMY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SQLALCHEMY_UNZIP is the command used to unzip the source.
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
PY-SQLALCHEMY_VERSION=0.3.9
PY-SQLALCHEMY_IPK_VERSION=1

PY-SQLALCHEMY_SVN_REV=
PY-SQLALCHEMY_SVN_TAG=
PY-SQLALCHEMY_SVN=http://svn.sqlalchemy.org/sqlalchemy

ifneq ($(PY-SQLALCHEMY_SVN_REV),)
PY-SQLALCHEMY_VERSION:=$(PY-SQLALCHEMY_VERSION)dev_r$(PY-SQLALCHEMY_SVN_REV)
PY-SQLALCHEMY_SVN:=$(PY-SQLALCHEMY_SVN)/trunk
else
  ifneq ($(PY-SQLALCHEMY_SVN_TAG),)
PY-SQLALCHEMY_SVN:=$(PY-SQLALCHEMY_SVN)/tags/$(PY-SQLALCHEMY_SVN_TAG)
  else
PY-SQLALCHEMY_SVN=
PY-SQLALCHEMY_SITE=http://cheeseshop.python.org/packages/source/S/SQLAlchemy
PY-SQLALCHEMY_SOURCE=SQLAlchemy-$(PY-SQLALCHEMY_VERSION).tar.gz
  endif
endif

PY-SQLALCHEMY_DIR=SQLAlchemy-$(PY-SQLALCHEMY_VERSION)
PY-SQLALCHEMY_UNZIP=zcat
PY-SQLALCHEMY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SQLALCHEMY_DESCRIPTION=Python SQL toolkit and Object Relational Mapper
PY-SQLALCHEMY_SECTION=misc
PY-SQLALCHEMY_PRIORITY=optional
PY-SQLALCHEMY_DEPENDS=python24
PY-SQLALCHEMY_DEPENDS=python25
PY-SQLALCHEMY_CONFLICTS=

#
# PY-SQLALCHEMY_CONFFILES should be a list of user-editable files
#PY-SQLALCHEMY_CONFFILES=/opt/etc/py-sqlalchemy.conf /opt/etc/init.d/SXXpy-sqlalchemy

#
# PY-SQLALCHEMY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SQLALCHEMY_PATCHES=$(PY-SQLALCHEMY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SQLALCHEMY_CPPFLAGS=
PY-SQLALCHEMY_LDFLAGS=

#
# PY-SQLALCHEMY_BUILD_DIR is the directory in which the build is done.
# PY-SQLALCHEMY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SQLALCHEMY_IPK_DIR is the directory in which the ipk is built.
# PY-SQLALCHEMY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SQLALCHEMY_BUILD_DIR=$(BUILD_DIR)/py-sqlalchemy
PY-SQLALCHEMY_SOURCE_DIR=$(SOURCE_DIR)/py-sqlalchemy

PY24-SQLALCHEMY_IPK_DIR=$(BUILD_DIR)/py-sqlalchemy-$(PY-SQLALCHEMY_VERSION)-ipk
PY24-SQLALCHEMY_IPK=$(BUILD_DIR)/py-sqlalchemy_$(PY-SQLALCHEMY_VERSION)-$(PY-SQLALCHEMY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-SQLALCHEMY_IPK_DIR=$(BUILD_DIR)/py25-sqlalchemy-$(PY-SQLALCHEMY_VERSION)-ipk
PY25-SQLALCHEMY_IPK=$(BUILD_DIR)/py25-sqlalchemy_$(PY-SQLALCHEMY_VERSION)-$(PY-SQLALCHEMY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-sqlalchemy-source py-sqlalchemy-unpack py-sqlalchemy py-sqlalchemy-stage py-sqlalchemy-ipk py-sqlalchemy-clean py-sqlalchemy-dirclean py-sqlalchemy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-SQLALCHEMY_SVN),)
$(DL_DIR)/$(PY-SQLALCHEMY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SQLALCHEMY_SITE)/$(PY-SQLALCHEMY_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-sqlalchemy-source: $(DL_DIR)/$(PY-SQLALCHEMY_SOURCE) $(PY-SQLALCHEMY_PATCHES)

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
ifeq ($(PY-SQLALCHEMY_SVN),)
$(PY-SQLALCHEMY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SQLALCHEMY_SOURCE) $(PY-SQLALCHEMY_PATCHES)
else
$(PY-SQLALCHEMY_BUILD_DIR)/.configured: $(PY-SQLALCHEMY_PATCHES)
endif
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-SQLALCHEMY_BUILD_DIR)
	mkdir -p $(PY-SQLALCHEMY_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR)
ifeq ($(PY-SQLALCHEMY_SVN),)
	$(PY-SQLALCHEMY_UNZIP) $(DL_DIR)/$(PY-SQLALCHEMY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    if test -n "$(PY-SQLALCHEMY_SVN_TAG)"; then \
		svn co --ignore-externals $(PY-SQLALCHEMY_SVN) $(PY-SQLALCHEMY_DIR); \
	    else \
		svn co -r $(PY-SQLALCHEMY_SVN_REV) $(PY-SQLALCHEMY_SVN) $(PY-SQLALCHEMY_DIR); \
	    fi \
	)
endif
	if test -n "$(PY-SQLALCHEMY_PATCHES)"; then \
	    cat $(PY-SQLALCHEMY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR) $(PY-SQLALCHEMY_BUILD_DIR)/2.4
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.4; \
	    ( \
	    echo "[install]"; \
	    echo "install_scripts = /opt/bin"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    ) >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR)
ifeq ($(PY-SQLALCHEMY_SVN),)
	$(PY-SQLALCHEMY_UNZIP) $(DL_DIR)/$(PY-SQLALCHEMY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    if test -n "$(PY-SQLALCHEMY_SVN_TAG)"; then \
		svn co --ignore-externals $(PY-SQLALCHEMY_SVN) $(PY-SQLALCHEMY_DIR); \
	    else \
		svn co -r $(PY-SQLALCHEMY_SVN_REV) $(PY-SQLALCHEMY_SVN) $(PY-SQLALCHEMY_DIR); \
	    fi \
	)
endif
	if test -n "$(PY-SQLALCHEMY_PATCHES)"; then \
	    cat $(PY-SQLALCHEMY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR) $(PY-SQLALCHEMY_BUILD_DIR)/2.5
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.5; \
	    ( \
	    echo "[install]"; \
	    echo "install_scripts = /opt/bin"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    ) >> setup.cfg \
	)
	touch $(PY-SQLALCHEMY_BUILD_DIR)/.configured

py-sqlalchemy-unpack: $(PY-SQLALCHEMY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SQLALCHEMY_BUILD_DIR)/.built: $(PY-SQLALCHEMY_BUILD_DIR)/.configured
	rm -f $(PY-SQLALCHEMY_BUILD_DIR)/.built
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-SQLALCHEMY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-sqlalchemy: $(PY-SQLALCHEMY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SQLALCHEMY_BUILD_DIR)/.staged: $(PY-SQLALCHEMY_BUILD_DIR)/.built
	rm -f $(PY-SQLALCHEMY_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-SQLALCHEMY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SQLALCHEMY_BUILD_DIR)/.staged

py-sqlalchemy-stage: $(PY-SQLALCHEMY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-sqlalchemy
#
$(PY24-SQLALCHEMY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-sqlalchemy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLALCHEMY_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLALCHEMY_SECTION)" >>$@
	@echo "Version: $(PY-SQLALCHEMY_VERSION)-$(PY-SQLALCHEMY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLALCHEMY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLALCHEMY_SITE)/$(PY-SQLALCHEMY_SOURCE)" >>$@
	@echo "Description: $(PY-SQLALCHEMY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SQLALCHEMY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SQLALCHEMY_CONFLICTS)" >>$@

$(PY25-SQLALCHEMY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-sqlalchemy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLALCHEMY_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLALCHEMY_SECTION)" >>$@
	@echo "Version: $(PY-SQLALCHEMY_VERSION)-$(PY-SQLALCHEMY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLALCHEMY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLALCHEMY_SITE)/$(PY-SQLALCHEMY_SOURCE)" >>$@
	@echo "Description: $(PY-SQLALCHEMY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SQLALCHEMY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SQLALCHEMY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SQLALCHEMY_IPK_DIR)/opt/sbin or $(PY-SQLALCHEMY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SQLALCHEMY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SQLALCHEMY_IPK_DIR)/opt/etc/py-sqlalchemy/...
# Documentation files should be installed in $(PY-SQLALCHEMY_IPK_DIR)/opt/doc/py-sqlalchemy/...
# Daemon startup scripts should be installed in $(PY-SQLALCHEMY_IPK_DIR)/opt/etc/init.d/S??py-sqlalchemy
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SQLALCHEMY_IPK): $(PY-SQLALCHEMY_BUILD_DIR)/.built
	rm -rf $(PY24-SQLALCHEMY_IPK_DIR) $(BUILD_DIR)/py-sqlalchemy_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-SQLALCHEMY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-SQLALCHEMY_IPK_DIR)/CONTROL/control
	echo $(PY-SQLALCHEMY_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SQLALCHEMY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SQLALCHEMY_IPK_DIR)

$(PY25-SQLALCHEMY_IPK): $(PY-SQLALCHEMY_BUILD_DIR)/.built
	rm -rf $(PY25-SQLALCHEMY_IPK_DIR) $(BUILD_DIR)/py25-sqlalchemy_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLALCHEMY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-SQLALCHEMY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-SQLALCHEMY_IPK_DIR)/CONTROL/control
	echo $(PY-SQLALCHEMY_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SQLALCHEMY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SQLALCHEMY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-sqlalchemy-ipk: $(PY24-SQLALCHEMY_IPK) $(PY25-SQLALCHEMY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-sqlalchemy-clean:
	-$(MAKE) -C $(PY-SQLALCHEMY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-sqlalchemy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SQLALCHEMY_DIR) $(PY-SQLALCHEMY_BUILD_DIR)
	rm -rf $(PY24-SQLALCHEMY_IPK_DIR) $(PY24-SQLALCHEMY_IPK)
	rm -rf $(PY25-SQLALCHEMY_IPK_DIR) $(PY25-SQLALCHEMY_IPK)

#
# Some sanity check for the package.
#
py-sqlalchemy-check: $(PY24-SQLALCHEMY_IPK) $(PY25-SQLALCHEMY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-SQLALCHEMY_IPK) $(PY25-SQLALCHEMY_IPK)
