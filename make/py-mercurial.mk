###########################################################
#
# py-mercurial
#
###########################################################

#
# PY-MERCURIAL_VERSION, PY-MERCURIAL_SITE and PY-MERCURIAL_SOURCE define
# the upstream location of the source code for the package.
# PY-MERCURIAL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MERCURIAL_UNZIP is the command used to unzip the source.
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
PY-MERCURIAL_VERSION=3.7.1
PY-MERCURIAL_VERSION_OLD=1.9
PY-MERCURIAL_SITE=http://mercurial.selenic.com/release
PY-MERCURIAL_SOURCE=mercurial-$(PY-MERCURIAL_VERSION).tar.gz
PY-MERCURIAL_SOURCE_OLD=mercurial-$(PY-MERCURIAL_VERSION_OLD).tar.gz
PY-MERCURIAL_DIR=mercurial-$(PY-MERCURIAL_VERSION)
PY-MERCURIAL_DIR_OLD=mercurial-$(PY-MERCURIAL_VERSION_OLD)
PY-MERCURIAL_UNZIP=zcat
PY-MERCURIAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MERCURIAL_DESCRIPTION=A fast, lightweight Source Control Management system designed for efficient handling of very large distributed projects.
PY-MERCURIAL_SECTION=misc
PY-MERCURIAL_PRIORITY=optional
PY25-MERCURIAL_DEPENDS=python25
PY26-MERCURIAL_DEPENDS=python26
PY27-MERCURIAL_DEPENDS=python27
PY-MERCURIAL_CONFLICTS=

#
# PY-MERCURIAL_IPK_VERSION should be incremented when the ipk changes.
#
PY-MERCURIAL_IPK_VERSION=1

#
# PY-MERCURIAL_CONFFILES should be a list of user-editable files
#PY-MERCURIAL_CONFFILES=$(TARGET_PREFIX)/etc/py-mercurial.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-mercurial

#
# PY-MERCURIAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-MERCURIAL_PATCHES=$(PY-MERCURIAL_SOURCE_DIR)/setup.py.new.patch
PY-MERCURIAL_PATCHES_OLD=$(PY-MERCURIAL_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MERCURIAL_CPPFLAGS=
PY-MERCURIAL_LDFLAGS=
# to be improved:
PY-MERCURIAL_WITH_INOTIFY=$(strip $(if \
$(filter cs08q1armel slugosbe slugosle slugos7be slugos7le, $(OPTWARE_TARGET)), True, False))

#
# PY-MERCURIAL_BUILD_DIR is the directory in which the build is done.
# PY-MERCURIAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MERCURIAL_IPK_DIR is the directory in which the ipk is built.
# PY-MERCURIAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MERCURIAL_BUILD_DIR=$(BUILD_DIR)/py-mercurial
PY-MERCURIAL_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-mercurial
PY-MERCURIAL_SOURCE_DIR=$(SOURCE_DIR)/py-mercurial

PY25-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py25-mercurial-$(PY-MERCURIAL_VERSION_OLD)-ipk
PY25-MERCURIAL_IPK=$(BUILD_DIR)/py25-mercurial_$(PY-MERCURIAL_VERSION_OLD)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py26-mercurial-$(PY-MERCURIAL_VERSION)-ipk
PY26-MERCURIAL_IPK=$(BUILD_DIR)/py26-mercurial_$(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py27-mercurial-$(PY-MERCURIAL_VERSION)-ipk
PY27-MERCURIAL_IPK=$(BUILD_DIR)/py27-mercurial_$(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mercurial-source py-mercurial-unpack py-mercurial py-mercurial-stage py-mercurial-ipk py-mercurial-clean py-mercurial-dirclean py-mercurial-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MERCURIAL_SOURCE):
	$(WGET) -P $(@D) $(PY-MERCURIAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-MERCURIAL_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-MERCURIAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mercurial-source: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(PY-MERCURIAL_PATCHES)

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
$(PY-MERCURIAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(DL_DIR)/$(PY-MERCURIAL_SOURCE_OLD) $(PY-MERCURIAL_PATCHES) make/py-mercurial.mk
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MERCURIAL_PATCHES_OLD)"; then \
		cat $(PY-MERCURIAL_PATCHES_OLD) | $(PATCH) -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR_OLD) -p0; \
	fi
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	sed -i	-e '/linux2/s|if .*|if True:|' \
		-e '/inotify_/s|if .*|if $(PY-MERCURIAL_WITH_INOTIFY):|' $(@D)/2.5/setup.py
	# 2.6
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MERCURIAL_PATCHES)"; then \
		cat $(PY-MERCURIAL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	sed -i	-e '/linux2/s|if .*|if True:|' \
		-e '/inotify_/s|if .*|if $(PY-MERCURIAL_WITH_INOTIFY):|' $(@D)/2.6/setup.py
	# 2.7
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-MERCURIAL_PATCHES)"; then \
		cat $(PY-MERCURIAL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	sed -i	-e '/linux2/s|if .*|if True:|' \
		-e '/inotify_/s|if .*|if $(PY-MERCURIAL_WITH_INOTIFY):|' $(@D)/2.7/setup.py
	touch $@

py-mercurial-unpack: $(PY-MERCURIAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MERCURIAL_BUILD_DIR)/.built: $(PY-MERCURIAL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-mercurial: $(PY-MERCURIAL_BUILD_DIR)/.built

$(PY-MERCURIAL_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(DL_DIR)/$(PY-MERCURIAL_SOURCE_OLD) make/py-mercurial.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR) $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR_OLD) $(@D)
	$(MAKE) python25-host-stage python26-host-stage python27-host-stage py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	cat $(PY-MERCURIAL_SOURCE_DIR)/setup.py.patch | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR_OLD) -p0
	mv $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR_OLD) $(@D)/2.5
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	cat $(PY-MERCURIAL_SOURCE_DIR)/setup.py.new.patch | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR) -p0
	mv $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	cat $(PY-MERCURIAL_SOURCE_DIR)/setup.py.new.patch | $(PATCH) -d $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR) -p0
	mv $(HOST_BUILD_DIR)/$(PY-MERCURIAL_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	mv -f $(HOST_STAGING_PREFIX)/bin/hg{,-py2.5}
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	mv -f $(HOST_STAGING_PREFIX)/bin/hg{,-py2.6}
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	mv -f $(HOST_STAGING_PREFIX)/bin/hg{,-py2.7}
	touch $@

py-mercurial-host-stage: $(PY-MERCURIAL_HOST_BUILD_DIR)/.staged

#
# If you are building a library, then you need to stage it too.
#
#$(PY-MERCURIAL_BUILD_DIR)/.staged: $(PY-MERCURIAL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-mercurial-stage: $(PY-MERCURIAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mercurial
#
$(PY25-MERCURIAL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION_OLD)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

$(PY26-MERCURIAL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

$(PY27-MERCURIAL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/etc/py-mercurial/...
# Documentation files should be installed in $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/doc/py-mercurial/...
# Daemon startup scripts should be installed in $(PY-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-mercurial
#
# You may need to patch your application to make it use these locations.
#
$(PY25-MERCURIAL_IPK) $(PY26-MERCURIAL_IPK) $(PY27-MERCURIAL_IPK): $(PY-MERCURIAL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-mercurial_*_$(TARGET_ARCH).ipk
	# 2.5
	rm -rf $(PY25-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py25-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-MERCURIAL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	(cd $(PY25-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	for f in $(PY25-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.5|'`; done
	$(MAKE) $(PY25-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MERCURIAL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY25-MERCURIAL_IPK_DIR)
	# 2.6
	rm -rf $(PY26-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py26-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-MERCURIAL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	(cd $(PY26-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY26-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-MERCURIAL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY26-MERCURIAL_IPK_DIR)
	# 2.7
	rm -rf $(PY27-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py27-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR)/2.7; \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-MERCURIAL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	(cd $(PY27-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	for f in $(PY27-MERCURIAL_IPK_DIR)$(TARGET_PREFIX)/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.7|'`; done
	$(MAKE) $(PY27-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-MERCURIAL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY27-MERCURIAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mercurial-ipk: $(PY25-MERCURIAL_IPK) $(PY26-MERCURIAL_IPK) $(PY27-MERCURIAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mercurial-clean:
	-$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mercurial-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(PY-MERCURIAL_BUILD_DIR) \
	$(PY25-MERCURIAL_IPK_DIR) $(PY25-MERCURIAL_IPK) \
	$(PY26-MERCURIAL_IPK_DIR) $(PY26-MERCURIAL_IPK) \
	$(PY27-MERCURIAL_IPK_DIR) $(PY27-MERCURIAL_IPK) \

#
# Some sanity check for the package.
#
py-mercurial-check: $(PY25-MERCURIAL_IPK) $(PY26-MERCURIAL_IPK) $(PY27-MERCURIAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
