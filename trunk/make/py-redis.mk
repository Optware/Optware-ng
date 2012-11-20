###########################################################
#
# py-redis
#
###########################################################

#
# PY-REDIS_VERSION, PY-REDIS_SITE and PY-REDIS_SOURCE define
# the upstream location of the source code for the package.
# PY-REDIS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-REDIS_UNZIP is the command used to unzip the source.
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
PY-REDIS_SITE=http://cloud.github.com/downloads/andymccurdy/redis-py
PY-REDIS_VERSION=2.7.2
PY-REDIS_SOURCE_UPSTREAM=redis-$(PY-REDIS_VERSION).tar.gz
PY-REDIS_SOURCE=py-redis-$(PY-REDIS_VERSION).tar.gz
PY-REDIS_DIR=redis-$(PY-REDIS_VERSION)
PY-REDIS_UNZIP=zcat
PY-REDIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-REDIS_DESCRIPTION=The Python interface to the Redis key-value store
PY-REDIS_SECTION=misc
PY-REDIS_PRIORITY=optional
PY26-REDIS_DEPENDS=python26
PY27-REDIS_DEPENDS=python27
PY-REDIS_CONFLICTS=

#
# PY-REDIS_IPK_VERSION should be incremented when the ipk changes.
#
PY-REDIS_IPK_VERSION=1

#
# PY-REDIS_CONFFILES should be a list of user-editable files
#PY-REDIS_CONFFILES=/opt/etc/py-redis.conf /opt/etc/init.d/SXXpy-redis

#
# PY-REDIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-REDIS_PATCHES=$(PY-REDIS_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-REDIS_CPPFLAGS=
PY-REDIS_LDFLAGS=

#
# PY-REDIS_BUILD_DIR is the directory in which the build is done.
# PY-REDIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-REDIS_IPK_DIR is the directory in which the ipk is built.
# PY-REDIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-REDIS_BUILD_DIR=$(BUILD_DIR)/py-redis
PY-REDIS_SOURCE_DIR=$(SOURCE_DIR)/py-redis

PY26-REDIS_IPK_DIR=$(BUILD_DIR)/py26-redis-$(PY-REDIS_VERSION)-ipk
PY26-REDIS_IPK=$(BUILD_DIR)/py26-redis_$(PY-REDIS_VERSION)-$(PY-REDIS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-REDIS_IPK_DIR=$(BUILD_DIR)/py27-redis-$(PY-REDIS_VERSION)-ipk
PY27-REDIS_IPK=$(BUILD_DIR)/py27-redis_$(PY-REDIS_VERSION)-$(PY-REDIS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-REDIS_SOURCE):
	($(WGET) -P $(@D)/tmp $(PY-REDIS_SITE)/$(PY-REDIS_SOURCE_UPSTREAM) && \
	 mv $(@D)/tmp/$(PY-REDIS_SOURCE_UPSTREAM) $@ || \
	 $(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$@)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-redis-source: $(DL_DIR)/$(PY-REDIS_SOURCE) $(PY-REDIS_PATCHES)

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
$(PY-REDIS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-REDIS_SOURCE) $(PY-REDIS_PATCHES) make/py-redis.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-REDIS_DIR)
	$(PY-REDIS_UNZIP) $(DL_DIR)/$(PY-REDIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-REDIS_PATCHES)"; then \
	    cat $(PY-REDIS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-REDIS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-REDIS_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-REDIS_DIR)
	$(PY-REDIS_UNZIP) $(DL_DIR)/$(PY-REDIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-REDIS_PATCHES)"; then \
	    cat $(PY-REDIS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-REDIS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-REDIS_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-redis-unpack: $(PY-REDIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-REDIS_BUILD_DIR)/.built: $(PY-REDIS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-redis: $(PY-REDIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-REDIS_BUILD_DIR)/.staged: $(PY-REDIS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-redis-stage: $(PY-REDIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-redis
#
$(PY26-REDIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-redis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REDIS_PRIORITY)" >>$@
	@echo "Section: $(PY-REDIS_SECTION)" >>$@
	@echo "Version: $(PY-REDIS_VERSION)-$(PY-REDIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REDIS_MAINTAINER)" >>$@
	@echo "Source: $(PY-REDIS_SITE)/$(PY-REDIS_SOURCE)" >>$@
	@echo "Description: $(PY-REDIS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-REDIS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REDIS_CONFLICTS)" >>$@

$(PY27-REDIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py27-redis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REDIS_PRIORITY)" >>$@
	@echo "Section: $(PY-REDIS_SECTION)" >>$@
	@echo "Version: $(PY-REDIS_VERSION)-$(PY-REDIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REDIS_MAINTAINER)" >>$@
	@echo "Source: $(PY-REDIS_SITE)/$(PY-REDIS_SOURCE)" >>$@
	@echo "Description: $(PY-REDIS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-REDIS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REDIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-REDIS_IPK_DIR)/opt/sbin or $(PY-REDIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-REDIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-REDIS_IPK_DIR)/opt/etc/py-redis/...
# Documentation files should be installed in $(PY-REDIS_IPK_DIR)/opt/doc/py-redis/...
# Daemon startup scripts should be installed in $(PY-REDIS_IPK_DIR)/opt/etc/init.d/S??py-redis
#
# You may need to patch your application to make it use these locations.
#
$(PY26-REDIS_IPK): $(PY-REDIS_BUILD_DIR)/.built
	rm -rf $(PY26-REDIS_IPK_DIR) $(BUILD_DIR)/py26-redis_*_$(TARGET_ARCH).ipk
	(cd $(PY-REDIS_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-REDIS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-REDIS_IPK_DIR)/CONTROL/control
#	echo $(PY-REDIS_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-REDIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-REDIS_IPK_DIR)

$(PY27-REDIS_IPK): $(PY-REDIS_BUILD_DIR)/.built
	rm -rf $(PY27-REDIS_IPK_DIR) $(BUILD_DIR)/py27-redis_*_$(TARGET_ARCH).ipk
	(cd $(PY-REDIS_BUILD_DIR)/2.7; \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-REDIS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY27-REDIS_IPK_DIR)/CONTROL/control
#	echo $(PY-REDIS_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-REDIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-REDIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-redis-ipk: $(PY26-REDIS_IPK) $(PY27-REDIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-redis-clean:
	-$(MAKE) -C $(PY-REDIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-redis-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-REDIS_DIR) $(PY-REDIS_BUILD_DIR)
	rm -rf $(PY26-REDIS_IPK_DIR) $(PY26-REDIS_IPK)
	rm -rf $(PY27-REDIS_IPK_DIR) $(PY27-REDIS_IPK)
