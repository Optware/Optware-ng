###########################################################
#
# deluge
#
###########################################################

#
# DELUGE_VERSION, DELUGE_SITE and DELUGE_SOURCE define
# the upstream location of the source code for the package.
# DELUGE_DIR is the directory which is created when the source
# archive is unpacked.
# DELUGE_UNZIP is the command used to unzip the source.
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
DELUGE_SITE=http://download.deluge-torrent.org/source
DELUGE_VERSION=1.3.15
DELUGE_SOURCE=deluge-$(DELUGE_VERSION).tar.bz2
DELUGE_DIR=deluge-$(DELUGE_VERSION)
DELUGE_UNZIP=bzcat
DELUGE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DELUGE_DESCRIPTION=Deluge BitTorrent client (without GTK+ client).
DELUGE_GTK_DESCRIPTION=Deluge GTK+ client
DELUGE_SECTION=misc
DELUGE_PRIORITY=optional
DELUGE_DEPENDS=python27, py27-twisted, py27-xdg, py27-chardet, py27-mako, py27-setuptools, py27-libtorrent-rasterbar-binding, py27-geoip
DELUGE_GTK_DEPENDS=deluge, py27-gtk, librsvg, xdg-utils, gnome-icon-theme
DELUGE_CONFLICTS=deluge-develop

#
# DELUGE_IPK_VERSION should be incremented when the ipk changes.
#
DELUGE_IPK_VERSION=1

#
# DELUGE_CONFFILES should be a list of user-editable files
DELUGE_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S80deluged $(TARGET_PREFIX)/etc/init.d/S80deluge-web

#
# DELUGE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DELUGE_PATCHES=$(DELUGE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DELUGE_CPPFLAGS=
DELUGE_LDFLAGS=

#
# DELUGE_BUILD_DIR is the directory in which the build is done.
# DELUGE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DELUGE_IPK_DIR is the directory in which the ipk is built.
# DELUGE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DELUGE_SOURCE_DIR=$(SOURCE_DIR)/deluge
DELUGE_BUILD_DIR=$(BUILD_DIR)/deluge

DELUGE_IPK_DIR=$(BUILD_DIR)/deluge-$(DELUGE_VERSION)-ipk
DELUGE_IPK=$(BUILD_DIR)/deluge_$(DELUGE_VERSION)-$(DELUGE_IPK_VERSION)_$(TARGET_ARCH).ipk

DELUGE_GTK_IPK_DIR=$(BUILD_DIR)/deluge-gtk-$(DELUGE_VERSION)-ipk
DELUGE_GTK_IPK=$(BUILD_DIR)/deluge-gtk_$(DELUGE_VERSION)-$(DELUGE_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq (py-gtk, $(filter py-gtk, $(PACKAGES)))
DELUGE_IPKS=$(DELUGE_IPK) $(DELUGE_GTK_IPK)
else
DELUGE_IPKS=$(DELUGE_IPK)
endif

.PHONY: deluge-source deluge-unpack deluge deluge-stage deluge-ipk deluge-clean deluge-dirclean deluge-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DELUGE_SOURCE):
	$(WGET) -P $(@D) $(DELUGE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
deluge-source: $(DL_DIR)/$(DELUGE_SOURCE) $(DELUGE_PATCHES)

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
$(DELUGE_BUILD_DIR)/.configured: $(DL_DIR)/$(DELUGE_SOURCE) $(DELUGE_PATCHES) make/deluge.mk
	$(MAKE) python27-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(DELUGE_DIR) $(@D)
#	cd $(BUILD_DIR); $(DELUGE_UNZIP) $(DL_DIR)/$(DELUGE_SOURCE)
	$(DELUGE_UNZIP) $(DL_DIR)/$(DELUGE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(DELUGE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(DELUGE_DIR) -p1
	mv $(BUILD_DIR)/$(DELUGE_DIR) $(@D)
	(cd $(@D); \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
	### don't build rasterbar libtorrent
	sed -i -e 's/build_libtorrent = True/build_libtorrent = False/' $(@D)/setup.py
	### set default deluge config dir to $(TARGET_PREFIX)/etc
	sed -i -e '/from xdg\.BaseDirectory import save_config_path/s/^/#/' \
		-e 's|return os\.path\.join(save_config_path("deluge"), filename)|return os.path.join("$(TARGET_PREFIX)/etc/deluge", filename)|' \
		-e 's|return save_config_path("deluge")|return "$(TARGET_PREFIX)/etc/deluge"|' \
									$(@D)/deluge/common.py
	### usr $(TARGET_PREFIX)/share instead of /usr/share
	find $(@D)/deluge -type f -name *.py -exec sed -i -e 's|/usr/share|$(TARGET_PREFIX)/share|g' {} \;
	touch $@

deluge-unpack: $(DELUGE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DELUGE_BUILD_DIR)/.built: $(DELUGE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
deluge: $(DELUGE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DELUGE_BUILD_DIR)/.staged: $(DELUGE_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/deluge*
	(cd $(@D); \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

deluge-stage: $(DELUGE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/deluge
#
$(DELUGE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: deluge" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DELUGE_PRIORITY)" >>$@
	@echo "Section: $(DELUGE_SECTION)" >>$@
	@echo "Version: $(DELUGE_VERSION)-$(DELUGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DELUGE_MAINTAINER)" >>$@
	@echo "Source: $(DELUGE_SITE)/$(DELUGE_SOURCE)" >>$@
	@echo "Description: $(DELUGE_DESCRIPTION)" >>$@
	@echo "Depends: $(DELUGE_DEPENDS)" >>$@
	@echo "Conflicts: $(DELUGE_CONFLICTS)" >>$@

$(DELUGE_GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: deluge-gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DELUGE_PRIORITY)" >>$@
	@echo "Section: $(DELUGE_SECTION)" >>$@
	@echo "Version: $(DELUGE_VERSION)-$(DELUGE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DELUGE_MAINTAINER)" >>$@
	@echo "Source: $(DELUGE_SITE)/$(DELUGE_SOURCE)" >>$@
	@echo "Description: $(DELUGE_GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(DELUGE_GTK_DEPENDS)" >>$@
	@echo "Conflicts: $(DELUGE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/etc/deluge/...
# Documentation files should be installed in $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/doc/deluge/...
# Daemon startup scripts should be installed in $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??deluge
#
# You may need to patch your application to make it use these locations.
#
$(DELUGE_IPKS): $(DELUGE_BUILD_DIR)/.built
	$(MAKE) deluge-stage
	rm -rf $(DELUGE_IPK_DIR) $(BUILD_DIR)/deluge_*_$(TARGET_ARCH).ipk \
		$(DELUGE_GTK_IPK_DIR) $(BUILD_DIR)/deluge-gtk_*_$(TARGET_ARCH).ipk
	(cd $(DELUGE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(DELUGE_IPK_DIR) --prefix=$(TARGET_PREFIX))
ifeq (py-gtk, $(filter py-gtk, $(PACKAGES)))
	$(INSTALL) -d $(DELUGE_GTK_IPK_DIR)$(TARGET_PREFIX)/bin $(DELUGE_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	mv -f $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/bin/deluge-gtk $(DELUGE_GTK_IPK_DIR)$(TARGET_PREFIX)/bin
	mv -f $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/deluge-gtk.1 $(DELUGE_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	mv -f $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/applications $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/icons $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/pixmaps \
		$(DELUGE_GTK_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(DELUGE_GTK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DELUGE_GTK_IPK_DIR)
else
	rm -f $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/bin/deluge-gtk $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/deluge-gtk.1
	rm -rf $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/applications $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/icons $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/share/pixmaps
endif
	### init scripts
	$(INSTALL) -d $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_SOURCE_DIR)/S80deluged $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_SOURCE_DIR)/S80deluge-web $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_SOURCE_DIR)/deluge-web-reset_password $(DELUGE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) $(DELUGE_IPK_DIR)/CONTROL/control
	### post-install: change default deluge ui to console
	$(INSTALL) -m 755 $(DELUGE_SOURCE_DIR)/postinst $(DELUGE_IPK_DIR)/CONTROL/postinst
	echo $(DELUGE_CONFFILES) | sed -e 's/ /\n/g' > $(DELUGE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DELUGE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
deluge-ipk: $(DELUGE_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
deluge-clean:
	-$(MAKE) -C $(DELUGE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
deluge-dirclean:
	rm -rf $(BUILD_DIR)/$(DELUGE_DIR) $(DELUGE_BUILD_DIR) \
	$(DELUGE_IPK_DIR) $(DELUGE_IPK) \

#
# Some sanity check for the package.
#
deluge-check: $(DELUGE_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
