###########################################################
#
# sabnzbdplus
#
###########################################################
#
# SABNZBDPLUS_VERSION, SABNZBDPLUS_SITE and SABNZBDPLUS_SOURCE define
# the upstream location of the source code for the package.
# SABNZBDPLUS_DIR is the directory which is created when the source
# archive is unpacked.
# SABNZBDPLUS_UNZIP is the command used to unzip the source.
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
SABNZBDPLUS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/sabnzbdplus
SABNZBDPLUS_VERSION=0.4.3
SABNZBDPLUS_SOURCE=SABnzbd-$(SABNZBDPLUS_VERSION)-src.tar.gz
SABNZBDPLUS_DIR=SABnzbd-$(SABNZBDPLUS_VERSION)
SABNZBDPLUS_UNZIP=zcat
SABNZBDPLUS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SABNZBDPLUS_DESCRIPTION=A web-interface based binary newsgrabber written in python, with nzb file support.
SABNZBDPLUS_SECTION=net
SABNZBDPLUS_PRIORITY=optional
SABNZBDPLUS_DEPENDS=py25-cheetah, py25-cherrypy, py25-yenc, par2cmdline
SABNZBDPLUS_SUGGESTS=unrar, unzip, py25-feedparser, py25-openssl
SABNZBDPLUS_CONFLICTS=py24-sabnzbd, py25-sabnzbd

#
# SABNZBDPLUS_IPK_VERSION should be incremented when the ipk changes.
#
SABNZBDPLUS_IPK_VERSION=1

#
# SABNZBDPLUS_CONFFILES should be a list of user-editable files
SABNZBDPLUS_CONFFILES=/opt/etc/SABnzbd.ini /opt/etc/init.d/S70sabnzbdplus

#
# SABNZBDPLUS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SABNZBDPLUS_PATCHES=$(SABNZBDPLUS_SOURCE_DIR)/fix_diskfree.patch \
                $(SABNZBDPLUS_SOURCE_DIR)/pause_download_during_assemble_and_postprocessing.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SABNZBDPLUS_CPPFLAGS=
SABNZBDPLUS_LDFLAGS=

#
# SABNZBDPLUS_BUILD_DIR is the directory in which the build is done.
# SABNZBDPLUS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SABNZBDPLUS_IPK_DIR is the directory in which the ipk is built.
# SABNZBDPLUS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SABNZBDPLUS_BUILD_DIR=$(BUILD_DIR)/sabnzbdplus
SABNZBDPLUS_SOURCE_DIR=$(SOURCE_DIR)/sabnzbdplus

SABNZBDPLUS_IPK_DIR=$(BUILD_DIR)/sabnzbdplus-$(SABNZBDPLUS_VERSION)-ipk
SABNZBDPLUS_IPK=$(BUILD_DIR)/sabnzbdplus_$(SABNZBDPLUS_VERSION)-$(SABNZBDPLUS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sabnzbdplus-source sabnzbdplus-unpack sabnzbdplus sabnzbdplus-stage sabnzbdplus-ipk sabnzbdplus-clean sabnzbdplus-dirclean sabnzbdplus-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SABNZBDPLUS_SOURCE):
	$(WGET) -P $(@D) $(SABNZBDPLUS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sabnzbdplus-source: $(DL_DIR)/$(SABNZBDPLUS_SOURCE) $(SABNZBDPLUS_PATCHES)

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
$(SABNZBDPLUS_BUILD_DIR)/.configured: $(DL_DIR)/$(SABNZBDPLUS_SOURCE) $(SABNZBDPLUS_PATCHES) make/sabnzbdplus.mk
#	$(MAKE) py-setuptools-stage py-elementtree-stage py-cherrypy-stage
	rm -rf $(BUILD_DIR)/$(SABNZBDPLUS_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(SABNZBDPLUS_UNZIP) $(DL_DIR)/$(SABNZBDPLUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SABNZBDPLUS_PATCHES)"; then \
		cat $(SABNZBDPLUS_PATCHES) | patch -d $(BUILD_DIR)/$(SABNZBDPLUS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(SABNZBDPLUS_DIR) $(@D)/2.5
#	(cd $(@D)/2.5; \
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
	sed -i -e 's|/usr/bin/python|/opt/bin/python2.5|g' $(@D)/2.5/SABnzbd.py
	touch $@

sabnzbdplus-unpack: $(SABNZBDPLUS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SABNZBDPLUS_BUILD_DIR)/.built: $(SABNZBDPLUS_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
sabnzbdplus: $(SABNZBDPLUS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SABNZBDPLUS_BUILD_DIR)/.staged: $(SABNZBDPLUS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(SABNZBDPLUS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#sabnzbdplus-stage: $(SABNZBDPLUS_BUILD_DIR)/.staged
#
#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sabnzbdplus
#
$(SABNZBDPLUS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sabnzbdplus" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SABNZBDPLUS_PRIORITY)" >>$@
	@echo "Section: $(SABNZBDPLUS_SECTION)" >>$@
	@echo "Version: $(SABNZBDPLUS_VERSION)-$(SABNZBDPLUS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SABNZBDPLUS_MAINTAINER)" >>$@
	@echo "Source: $(SABNZBDPLUS_SITE)/$(SABNZBDPLUS_SOURCE)" >>$@
	@echo "Description: $(SABNZBDPLUS_DESCRIPTION)" >>$@
	@echo "Depends: $(SABNZBDPLUS_DEPENDS)" >>$@
	@echo "Conflicts: $(SABNZBDPLUS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SABNZBDPLUS_IPK_DIR)/opt/sbin or $(SABNZBDPLUS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SABNZBDPLUS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SABNZBDPLUS_IPK_DIR)/opt/etc/sabnzbdplus/...
# Documentation files should be installed in $(SABNZBDPLUS_IPK_DIR)/opt/doc/sabnzbdplus/...
# Daemon startup scripts should be installed in $(SABNZBDPLUS_IPK_DIR)/opt/etc/init.d/S70sabnzbdplus
#
# You may need to patch your application to make it use these locations.
#

$(SABNZBDPLUS_IPK): $(SABNZBDPLUS_BUILD_DIR)/.built
	rm -rf $(SABNZBDPLUS_IPK_DIR) $(BUILD_DIR)/sabnzbdplus_*_$(TARGET_ARCH).ipk
#	cd $(SABNZBDPLUS_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(SABNZBDPLUS_IPK_DIR) --prefix=/opt
	install -d $(SABNZBDPLUS_IPK_DIR)/opt/share/SABnzbd
	cp -rp $(SABNZBDPLUS_BUILD_DIR)/2.5/* $(SABNZBDPLUS_IPK_DIR)/opt/share/SABnzbd
	#
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/etc
#	install -m 644 $(SABNZBDPLUS_SOURCE_DIR)/SABnzbd.ini $(SABNZBDPLUS_IPK_DIR)/opt/etc/SABnzbd.ini
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SABNZBDPLUS_SOURCE_DIR)/rc.sabnzbdplus $(SABNZBDPLUS_IPK_DIR)/opt/etc/init.d/S70sabnzbdplus
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/tmp/downloads
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/tmp/SABnzbd/cache
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/tmp/SABnzbd/tmp
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/tmp/SABnzbd/nzb
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/tmp/SABnzbd/nzb/backup
#	install -d $(SABNZBDPLUS_IPK_DIR)/opt/var/log
	$(MAKE) $(SABNZBDPLUS_IPK_DIR)/CONTROL/control
#	install -m 644 $(SABNZBDPLUS_SOURCE_DIR)/postinst $(SABNZBDPLUS_IPK_DIR)/CONTROL/postinst
#	echo $(SABNZBDPLUS_CONFFILES) | sed -e 's/ /\n/g' > $(SABNZBDPLUS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SABNZBDPLUS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sabnzbdplus-ipk: $(SABNZBDPLUS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sabnzbdplus-clean:
	rm -f $(SABNZBDPLUS_BUILD_DIR)/.built
	-$(MAKE) -C $(SABNZBDPLUS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sabnzbdplus-dirclean:
	rm -rf $(BUILD_DIR)/$(SABNZBDPLUS_DIR) $(SABNZBDPLUS_BUILD_DIR) $(SABNZBDPLUS_IPK_DIR) $(SABNZBDPLUS_IPK)
#
#
# Some sanity check for the package.
#
sabnzbdplus-check: $(SABNZBDPLUS_PY24_IPK) $(SABNZBDPLUS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SABNZBDPLUS_IPK)
