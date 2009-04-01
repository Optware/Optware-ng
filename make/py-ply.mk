###########################################################
#
# py-ply
#
###########################################################

#
# PY-PLY_VERSION, PY-PLY_SITE and PY-PLY_SOURCE define
# the upstream location of the source code for the package.
# PY-PLY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PLY_UNZIP is the command used to unzip the source.
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
PY-PLY_SITE=http://www.dabeaz.com/ply
PY-PLY_VERSION=3.2
PY-PLY_SOURCE=ply-$(PY-PLY_VERSION).tar.gz
PY-PLY_DIR=ply-$(PY-PLY_VERSION)
PY-PLY_UNZIP=zcat
PY-PLY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PLY_DESCRIPTION=A pure-Python implementation of lex and yacc.
PY-PLY_SECTION=misc
PY-PLY_PRIORITY=optional
PY25-PLY_DEPENDS=python25
PY26-PLY_DEPENDS=python26
PY-PLY_CONFLICTS=

#
# PY-PLY_IPK_VERSION should be incremented when the ipk changes.
#
PY-PLY_IPK_VERSION=1

#
# PY-PLY_CONFFILES should be a list of user-editable files
#PY-PLY_CONFFILES=/opt/etc/py-ply.conf /opt/etc/init.d/SXXpy-ply

#
# PY-PLY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PLY_PATCHES=$(PY-PLY_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PLY_CPPFLAGS=
PY-PLY_LDFLAGS=

#
# PY-PLY_BUILD_DIR is the directory in which the build is done.
# PY-PLY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PLY_IPK_DIR is the directory in which the ipk is built.
# PY-PLY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PLY_BUILD_DIR=$(BUILD_DIR)/py-ply
PY-PLY_SOURCE_DIR=$(SOURCE_DIR)/py-ply

PY25-PLY_IPK_DIR=$(BUILD_DIR)/py25-ply-$(PY-PLY_VERSION)-ipk
PY25-PLY_IPK=$(BUILD_DIR)/py25-ply_$(PY-PLY_VERSION)-$(PY-PLY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PLY_IPK_DIR=$(BUILD_DIR)/py26-ply-$(PY-PLY_VERSION)-ipk
PY26-PLY_IPK=$(BUILD_DIR)/py26-ply_$(PY-PLY_VERSION)-$(PY-PLY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PLY_SOURCE):
	$(WGET) -P $(@D) $(PY-PLY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-ply-source: $(DL_DIR)/$(PY-PLY_SOURCE) $(PY-PLY_PATCHES)

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
$(PY-PLY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PLY_SOURCE) $(PY-PLY_PATCHES) make/py-ply.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PLY_DIR)
	$(PY-PLY_UNZIP) $(DL_DIR)/$(PY-PLY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PLY_PATCHES)"; then \
	    cat $(PY-PLY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PLY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PLY_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-PLY_DIR)
	$(PY-PLY_UNZIP) $(DL_DIR)/$(PY-PLY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PLY_PATCHES)"; then \
	    cat $(PY-PLY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PLY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PLY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-ply-unpack: $(PY-PLY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PLY_BUILD_DIR)/.built: $(PY-PLY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-ply: $(PY-PLY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PLY_BUILD_DIR)/.staged: $(PY-PLY_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-ply-stage: $(PY-PLY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-ply
#
$(PY25-PLY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-ply" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PLY_PRIORITY)" >>$@
	@echo "Section: $(PY-PLY_SECTION)" >>$@
	@echo "Version: $(PY-PLY_VERSION)-$(PY-PLY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PLY_MAINTAINER)" >>$@
	@echo "Source: $(PY-PLY_SITE)/$(PY-PLY_SOURCE)" >>$@
	@echo "Description: $(PY-PLY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PLY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PLY_CONFLICTS)" >>$@

$(PY26-PLY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-ply" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PLY_PRIORITY)" >>$@
	@echo "Section: $(PY-PLY_SECTION)" >>$@
	@echo "Version: $(PY-PLY_VERSION)-$(PY-PLY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PLY_MAINTAINER)" >>$@
	@echo "Source: $(PY-PLY_SITE)/$(PY-PLY_SOURCE)" >>$@
	@echo "Description: $(PY-PLY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PLY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PLY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PLY_IPK_DIR)/opt/sbin or $(PY-PLY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PLY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PLY_IPK_DIR)/opt/etc/py-ply/...
# Documentation files should be installed in $(PY-PLY_IPK_DIR)/opt/doc/py-ply/...
# Daemon startup scripts should be installed in $(PY-PLY_IPK_DIR)/opt/etc/init.d/S??py-ply
#
# You may need to patch your application to make it use these locations.
#
$(PY25-PLY_IPK): $(PY-PLY_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-ply_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-PLY_IPK_DIR) $(BUILD_DIR)/py25-ply_*_$(TARGET_ARCH).ipk
	(cd $(PY-PLY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install --root=$(PY25-PLY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PLY_IPK_DIR)/CONTROL/control
#	echo $(PY-PLY_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PLY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PLY_IPK_DIR)

$(PY26-PLY_IPK): $(PY-PLY_BUILD_DIR)/.built
	rm -rf $(PY26-PLY_IPK_DIR) $(BUILD_DIR)/py26-ply_*_$(TARGET_ARCH).ipk
	(cd $(PY-PLY_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install --root=$(PY26-PLY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-PLY_IPK_DIR)/CONTROL/control
#	echo $(PY-PLY_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-PLY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PLY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-ply-ipk: $(PY25-PLY_IPK) $(PY26-PLY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-ply-clean:
	-$(MAKE) -C $(PY-PLY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-ply-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PLY_DIR) $(PY-PLY_BUILD_DIR)
	rm -rf $(PY25-PLY_IPK_DIR) $(PY25-PLY_IPK)
	rm -rf $(PY26-PLY_IPK_DIR) $(PY26-PLY_IPK)
