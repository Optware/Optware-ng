###########################################################
#
# py-btpd-webui
#
###########################################################

#
# PY-BTPD-WEBUI_VERSION, PY-BTPD-WEBUI_SITE and PY-BTPD-WEBUI_SOURCE define
# the upstream location of the source code for the package.
# PY-BTPD-WEBUI_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BTPD-WEBUI_UNZIP is the command used to unzip the source.
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
PY-BTPD-WEBUI_VERSION=0.2
PY-BTPD-WEBUI_SVN_REV=16
PY-BTPD-WEBUI_SVN=http://btpd-webui.googlecode.com/svn/trunk
PY-BTPD-WEBUI_SOURCE=py-btpd-webui-svn-$(PY-BTPD-WEBUI_SVN_REV).tar.bz2
PY-BTPD-WEBUI_DIR=py-btpd-webui-$(PY-BTPD-WEBUI_VERSION)
PY-BTPD-WEBUI_UNZIP=bzcat
PY-BTPD-WEBUI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BTPD-WEBUI_DESCRIPTION=BitTorrent Protocol Daemon (btpd) Web UI based on the twitsted-web framework.
PY-BTPD-WEBUI_SECTION=net
PY-BTPD-WEBUI_PRIORITY=optional
PY-BTPD-WEBUI_DEPENDS=btpd, py25-twisted
PY-BTPD-WEBUI_CONFLICTS=

#
# PY-BTPD-WEBUI_IPK_VERSION should be incremented when the ipk changes.
#
PY-BTPD-WEBUI_IPK_VERSION=1

#
# PY-BTPD-WEBUI_CONFFILES should be a list of user-editable files
#PY-BTPD-WEBUI_CONFFILES=/opt/etc/py-btpd-webui.conf /opt/etc/init.d/SXXpy-btpd-webui

#
# PY-BTPD-WEBUI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BTPD-WEBUI_PATCHES=$(PY-BTPD-WEBUI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BTPD-WEBUI_CPPFLAGS=
PY-BTPD-WEBUI_LDFLAGS=

#
# PY-BTPD-WEBUI_BUILD_DIR is the directory in which the build is done.
# PY-BTPD-WEBUI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BTPD-WEBUI_IPK_DIR is the directory in which the ipk is built.
# PY-BTPD-WEBUI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BTPD-WEBUI_BUILD_DIR=$(BUILD_DIR)/py-btpd-webui
PY-BTPD-WEBUI_SOURCE_DIR=$(SOURCE_DIR)/py-btpd-webui

PY-BTPD-WEBUI_IPK_DIR=$(BUILD_DIR)/py-btpd-webui-$(PY-BTPD-WEBUI_VERSION)-ipk
PY-BTPD-WEBUI_IPK=$(BUILD_DIR)/py-btpd-webui_$(PY-BTPD-WEBUI_VERSION)+r$(PY-BTPD-WEBUI_SVN_REV)-$(PY-BTPD-WEBUI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-btpd-webui-source py-btpd-webui-unpack py-btpd-webui py-btpd-webui-stage py-btpd-webui-ipk py-btpd-webui-clean py-btpd-webui-dirclean py-btpd-webui-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BTPD-WEBUI_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(PY-BTPD-WEBUI_DIR) && \
		svn co -r $(PY-BTPD-WEBUI_SVN_REV) $(PY-BTPD-WEBUI_SVN) \
			$(PY-BTPD-WEBUI_DIR) && \
		tar -cjf $@ $(PY-BTPD-WEBUI_DIR) && \
		rm -rf $(PY-BTPD-WEBUI_DIR) \
	) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-btpd-webui-source: $(DL_DIR)/$(PY-BTPD-WEBUI_SOURCE) $(PY-BTPD-WEBUI_PATCHES)

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
$(PY-BTPD-WEBUI_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BTPD-WEBUI_SOURCE) $(PY-BTPD-WEBUI_PATCHES) make/py-btpd-webui.mk
	$(MAKE) python25-stage
	rm -rf $(BUILD_DIR)/$(PY-BTPD-WEBUI_DIR) $(@D)
	$(PY-BTPD-WEBUI_UNZIP) $(DL_DIR)/$(PY-BTPD-WEBUI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(PY-BTPD-WEBUI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PY-BTPD-WEBUI_DIR) $(@D) ; \
	fi
	sed -i -e "s|^TWISTD=.*|TWISTD=/opt/bin/twistd|" -e "s|^BTPDWEBUI=.*|BTPDWEBUI=/opt/bin/btpd-webui-server|" $(@D)/scripts/btpd-webui
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-btpd-webui-unpack: $(PY-BTPD-WEBUI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BTPD-WEBUI_BUILD_DIR)/.built: $(PY-BTPD-WEBUI_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/btpdwebui $(STAGING_LIB_DIR)/python2.5/site-packages/btpd_webui-$(PY-BTPD-WEBUI_VERSION)-py2.5.egg-info
	(cd $(@D); \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.5/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "execfile('setup.py')" build)
	touch $@

#
# This is the build convenience target.
#
py-btpd-webui: $(PY-BTPD-WEBUI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BTPD-WEBUI_BUILD_DIR)/.staged: $(PY-BTPD-WEBUI_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D); \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	touch $@

py-btpd-webui-stage: $(PY-BTPD-WEBUI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-btpd-webui
#
$(PY-BTPD-WEBUI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-btpd-webui" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BTPD-WEBUI_PRIORITY)" >>$@
	@echo "Section: $(PY-BTPD-WEBUI_SECTION)" >>$@
	@echo "Version: $(PY-BTPD-WEBUI_VERSION)+r$(PY-BTPD-WEBUI_SVN_REV)-$(PY-BTPD-WEBUI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BTPD-WEBUI_MAINTAINER)" >>$@
	@echo "Source: $(PY-BTPD-WEBUI_SITE)/$(PY-BTPD-WEBUI_SOURCE)" >>$@
	@echo "Description: $(PY-BTPD-WEBUI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-BTPD-WEBUI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BTPD-WEBUI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BTPD-WEBUI_IPK_DIR)/opt/sbin or $(PY-BTPD-WEBUI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BTPD-WEBUI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BTPD-WEBUI_IPK_DIR)/opt/etc/py-btpd-webui/...
# Documentation files should be installed in $(PY-BTPD-WEBUI_IPK_DIR)/opt/doc/py-btpd-webui/...
# Daemon startup scripts should be installed in $(PY-BTPD-WEBUI_IPK_DIR)/opt/etc/init.d/S??py-btpd-webui
#
# You may need to patch your application to make it use these locations.
#
$(PY-BTPD-WEBUI_IPK): $(PY-BTPD-WEBUI_BUILD_DIR)/.built
	rm -rf $(PY-BTPD-WEBUI_IPK_DIR) $(BUILD_DIR)/py-btpd-webui_*_$(TARGET_ARCH).ipk
	(cd $(PY-BTPD-WEBUI_BUILD_DIR); \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY-BTPD-WEBUI_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-BTPD-WEBUI_IPK_DIR)/CONTROL/control
	echo $(PY-BTPD-WEBUI_CONFFILES) | sed -e 's/ /\n/g' > $(PY-BTPD-WEBUI_IPK_DIR)/CONTROL/conffiles
	mkdir -p $(PY-BTPD-WEBUI_IPK_DIR)/opt/doc/py-btpd-webui
	cp -f $(PY-BTPD-WEBUI_BUILD_DIR)/README $(PY-BTPD-WEBUI_IPK_DIR)/opt/doc/py-btpd-webui/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-BTPD-WEBUI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-btpd-webui-ipk: $(PY-BTPD-WEBUI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-btpd-webui-clean:
	-$(MAKE) -C $(PY-BTPD-WEBUI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-btpd-webui-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BTPD-WEBUI_DIR) $(PY-BTPD-WEBUI_BUILD_DIR) $(PY-BTPD-WEBUI_IPK_DIR) $(PY-BTPD-WEBUI_IPK)

#
# Some sanity check for the package.
#
py-btpd-webui-check: $(PY-BTPD-WEBUI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-BTPD-WEBUI_IPK)
