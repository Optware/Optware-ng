###########################################################
#
# sabnzbd
#
###########################################################
#
# SABNZBD_VERSION, SABNZBD_SITE and SABNZBD_SOURCE define
# the upstream location of the source code for the package.
# SABNZBD_DIR is the directory which is created when the source
# archive is unpacked.
# SABNZBD_UNZIP is the command used to unzip the source.
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
SABNZBD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/sabnzbd
SABNZBD_VERSION=0.2.5
SABNZBD_SOURCE=SABnzbd-$(SABNZBD_VERSION).tar.gz
SABNZBD_DIR=SABnzbd-$(SABNZBD_VERSION)
SABNZBD_UNZIP=zcat
SABNZBD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SABNZBD_DESCRIPTION=A web-interface based binary newsgrabber written in python, with nzb file support.
SABNZBD_SECTION=net
SABNZBD_PRIORITY=optional
SABNZBD_PY24_DEPENDS=python24, py24-cherrypy, py24-cheetah, py24-celementtree, py24-yenc
SABNZBD_PY25_DEPENDS=python25, py25-cherrypy, py25-cheetah, py25-celementtree, py25-yenc
SABNZBD_SUGGESTS=par2cmdline, unrar, unzip
SABNZBD_PY24_CONFLICTS=py25-sabnzbd
SABNZBD_PY25_CONFLICTS=py24-sabnzbd

#
# SABNZBD_IPK_VERSION should be incremented when the ipk changes.
#
SABNZBD_IPK_VERSION=2

#
# SABNZBD_CONFFILES should be a list of user-editable files
SABNZBD_CONFFILES=/opt/etc/SABnzbd.ini /opt/etc/init.d/S70sabnzbd

#
# SABNZBD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SABNZBD_PATCHES=$(SABNZBD_SOURCE_DIR)/fix_diskfree.patch \
                $(SABNZBD_SOURCE_DIR)/pause_download_during_assemble_and_postprocessing.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SABNZBD_CPPFLAGS=
SABNZBD_LDFLAGS=

#
# SABNZBD_BUILD_DIR is the directory in which the build is done.
# SABNZBD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SABNZBD_IPK_DIR is the directory in which the ipk is built.
# SABNZBD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SABNZBD_BUILD_DIR=$(BUILD_DIR)/sabnzbd
SABNZBD_SOURCE_DIR=$(SOURCE_DIR)/sabnzbd

SABNZBD_PY24_IPK_DIR=$(BUILD_DIR)/py24-sabnzbd-$(SABNZBD_VERSION)-ipk
SABNZBD_PY24_IPK=$(BUILD_DIR)/py24-sabnzbd_$(SABNZBD_VERSION)-$(SABNZBD_IPK_VERSION)_$(TARGET_ARCH).ipk

SABNZBD_PY25_IPK_DIR=$(BUILD_DIR)/py25-sabnzbd-$(SABNZBD_VERSION)-ipk
SABNZBD_PY25_IPK=$(BUILD_DIR)/py25-sabnzbd_$(SABNZBD_VERSION)-$(SABNZBD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sabnzbd-source sabnzbd-unpack sabnzbd sabnzbd-stage sabnzbd-ipk sabnzbd-clean sabnzbd-dirclean sabnzbd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SABNZBD_SOURCE):
	$(WGET) -P $(DL_DIR) $(SABNZBD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sabnzbd-source: $(DL_DIR)/$(SABNZBD_SOURCE) $(SABNZBD_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(SABNZBD_BUILD_DIR)/.configured: $(DL_DIR)/$(SABNZBD_SOURCE) $(SABNZBD_PATCHES) make/sabnzbd.mk
	$(MAKE) py-setuptools-stage py-elementtree-stage py-cherrypy-stage 
	rm -rf $(BUILD_DIR)/$(SABNZBD_DIR) $(SABNZBD_BUILD_DIR)
	mkdir -p $(SABNZBD_BUILD_DIR)
	# 2.4
	$(SABNZBD_UNZIP) $(DL_DIR)/$(SABNZBD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SABNZBD_PATCHES) | patch -d $(BUILD_DIR)/$(SABNZBD_DIR) -p1
	mv $(BUILD_DIR)/$(SABNZBD_DIR) $(SABNZBD_BUILD_DIR)/2.4
	(cd $(SABNZBD_BUILD_DIR)/2.4; \
	( \
	        echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
	        echo "[build_scripts]"; \
	        echo "executable=/opt/bin/python2.4"; \
	        echo "[install]"; \
	        echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	$(SABNZBD_UNZIP) $(DL_DIR)/$(SABNZBD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SABNZBD_PATCHES) | patch -d $(BUILD_DIR)/$(SABNZBD_DIR) -p1
	mv $(BUILD_DIR)/$(SABNZBD_DIR) $(SABNZBD_BUILD_DIR)/2.5
	(cd $(SABNZBD_BUILD_DIR)/2.5; \
	    ( \
	        echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
	        echo "[build_scripts]"; \
	        echo "executable=/opt/bin/python2.5"; \
	        echo "[install]"; \
	        echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

sabnzbd-unpack: $(SABNZBD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SABNZBD_BUILD_DIR)/.built: $(SABNZBD_BUILD_DIR)/.configured
	rm -f $@
	cd $(SABNZBD_BUILD_DIR)/2.4; \
            PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(SABNZBD_BUILD_DIR)/2.5; \
            PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
sabnzbd: $(SABNZBD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SABNZBD_BUILD_DIR)/.staged: $(SABNZBD_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(SABNZBD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@


sabnzbd-stage: $(SABNZBD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sabnzbd
#
$(SABNZBD_PY24_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-sabnzbd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SABNZBD_PRIORITY)" >>$@
	@echo "Section: $(SABNZBD_SECTION)" >>$@
	@echo "Version: $(SABNZBD_VERSION)-$(SABNZBD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SABNZBD_MAINTAINER)" >>$@
	@echo "Source: $(SABNZBD_SITE)/$(SABNZBD_SOURCE)" >>$@
	@echo "Description: $(SABNZBD_DESCRIPTION)" >>$@
	@echo "Depends: $(SABNZBD_PY24_DEPENDS)" >>$@
	@echo "Conflicts: $(SABNZBD_PY24_CONFLICTS)" >>$@

$(SABNZBD_PY25_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-sabnzbd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SABNZBD_PRIORITY)" >>$@
	@echo "Section: $(SABNZBD_SECTION)" >>$@
	@echo "Version: $(SABNZBD_VERSION)-$(SABNZBD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SABNZBD_MAINTAINER)" >>$@
	@echo "Source: $(SABNZBD_SITE)/$(SABNZBD_SOURCE)" >>$@
	@echo "Description: $(SABNZBD_DESCRIPTION)" >>$@
	@echo "Depends: $(SABNZBD_PY25_DEPENDS)" >>$@
	@echo "Conflicts: $(SABNZBD_PY25_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SABNZBD_IPK_DIR)/opt/sbin or $(SABNZBD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SABNZBD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SABNZBD_IPK_DIR)/opt/etc/sabnzbd/...
# Documentation files should be installed in $(SABNZBD_IPK_DIR)/opt/doc/sabnzbd/...
# Daemon startup scripts should be installed in $(SABNZBD_IPK_DIR)/opt/etc/init.d/S70sabnzbd
#
# You may need to patch your application to make it use these locations.
#

$(SABNZBD_PY24_IPK): $(SABNZBD_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-sabnzbd_*_$(TARGET_ARCH).ipk
	rm -rf $(SABNZBD_PY24_IPK_DIR) $(BUILD_DIR)/py24-sabnzbd_*_$(TARGET_ARCH).ipk
	cd $(SABNZBD_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(SABNZBD_PY24_IPK_DIR) --prefix=/opt
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/etc
	install -m 644 $(SABNZBD_SOURCE_DIR)/SABnzbd.ini $(SABNZBD_PY24_IPK_DIR)/opt/etc/SABnzbd.ini
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SABNZBD_SOURCE_DIR)/rc.sabnzbd $(SABNZBD_PY24_IPK_DIR)/opt/etc/init.d/S70sabnzbd
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/tmp/downloads
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/tmp/SABnzbd/cache
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/tmp/SABnzbd/tmp
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/tmp/SABnzbd/nzb
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/tmp/SABnzbd/nzb/backup
	install -d $(SABNZBD_PY24_IPK_DIR)/opt/var/log
	$(MAKE) $(SABNZBD_PY24_IPK_DIR)/CONTROL/control
	install -m 644 $(SABNZBD_SOURCE_DIR)/postinst $(SABNZBD_PY24_IPK_DIR)/CONTROL/postinst
	echo $(SABNZBD_CONFFILES) | sed -e 's/ /\n/g' > $(SABNZBD_PY24_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SABNZBD_PY24_IPK_DIR)

$(SABNZBD_PY25_IPK): $(SABNZBD_BUILD_DIR)/.built
	rm -rf $(SABNZBD_PY25_IPK_DIR) $(BUILD_DIR)/py25-sabnzbd_*_$(TARGET_ARCH).ipk
	cd $(SABNZBD_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(SABNZBD_PY25_IPK_DIR) --prefix=/opt
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/etc
	install -m 644 $(SABNZBD_SOURCE_DIR)/SABnzbd.ini $(SABNZBD_PY25_IPK_DIR)/opt/etc/SABnzbd.ini
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SABNZBD_SOURCE_DIR)/rc.sabnzbd $(SABNZBD_PY25_IPK_DIR)/opt/etc/init.d/S70sabnzbd
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/tmp/downloads
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/tmp/SABnzbd/cache
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/tmp/SABnzbd/tmp
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/tmp/SABnzbd/nzb
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/tmp/SABnzbd/nzb/backup
	install -d $(SABNZBD_PY25_IPK_DIR)/opt/var/log
	$(MAKE) $(SABNZBD_PY25_IPK_DIR)/CONTROL/control
	install -m 644 $(SABNZBD_SOURCE_DIR)/postinst $(SABNZBD_PY25_IPK_DIR)/CONTROL/postinst
	echo $(SABNZBD_CONFFILES) | sed -e 's/ /\n/g' > $(SABNZBD_PY25_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SABNZBD_PY25_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sabnzbd-ipk: $(SABNZBD_PY24_IPK) $(SABNZBD_PY25_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sabnzbd-clean:
	rm -f $(SABNZBD_BUILD_DIR)/.built
	-$(MAKE) -C $(SABNZBD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sabnzbd-dirclean:
	rm -rf $(BUILD_DIR)/$(SABNZBD_DIR) $(SABNZBD_BUILD_DIR) $(SABNZBD_IPK_DIR) $(SABNZBD_PY24_IPK) $(SABNZBD_PY25_IPK)
#
#
# Some sanity check for the package.
#
sabnzbd-check: $(SABNZBD_PY24_IPK) $(SABNZBD_PY25_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SABNZBD_PY24_IPK) $(SABNZBD_PY25_IPK)
