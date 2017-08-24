###########################################################
#
# deluge-develop
#
###########################################################

#
# DELUGE_DEVELOP_VERSION, DELUGE_DEVELOP_SITE and DELUGE_DEVELOP_SOURCE define
# the upstream location of the source code for the package.
# DELUGE_DEVELOP_DIR is the directory which is created when the source
# archive is unpacked.
# DELUGE_DEVELOP_UNZIP is the command used to unzip the source.
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
DELUGE_DEVELOP_REPOSITORY=https://github.com/deluge-torrent/deluge.git
DELUGE_DEVELOP_VERSION=20170705
DELUGE_DEVELOP_TREEISH=`git rev-list -b develop --max-count=1 --until=2017-07-05 HEAD`
DELUGE_DEVELOP_SOURCE=deluge-develop-$(DELUGE_DEVELOP_VERSION).tar.bz2
#DELUGE_DEVELOP_DIR=deluge-develop-$(DELUGE_DEVELOP_VERSION)
DELUGE_DEVELOP_UNZIP=bzcat
DELUGE_DEVELOP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DELUGE_DEVELOP_DESCRIPTION=Deluge BitTorrent client: development version (without GTK+ client).
DELUGE_DEVELOP_GTK_DESCRIPTION=Deluge GTK+ client: development version
DELUGE_DEVELOP_SECTION=misc
DELUGE_DEVELOP_PRIORITY=optional
DELUGE_DEVELOP_DEPENDS=python27, py27-twisted, py27-xdg, py27-chardet, py27-mako, py27-setuptools, py27-libtorrent-rasterbar-binding, py27-geoip
DELUGE_DEVELOP_GTK_DEPENDS=deluge-develop, py27-gtk, librsvg, xdg-utils, gnome-icon-theme
DELUGE_DEVELOP_CONFLICTS=deluge

#
# DELUGE_DEVELOP_IPK_VERSION should be incremented when the ipk changes.
#
DELUGE_DEVELOP_IPK_VERSION=2

#
# DELUGE_DEVELOP_CONFFILES should be a list of user-editable files
DELUGE_DEVELOP_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S80deluged $(TARGET_PREFIX)/etc/init.d/S80deluge-web

#
# DELUGE_DEVELOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DELUGE_DEVELOP_PATCHES=\
$(DELUGE_DEVELOP_SOURCE_DIR)/skip_forced_minify.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DELUGE_DEVELOP_CPPFLAGS=
DELUGE_DEVELOP_LDFLAGS=

#
# DELUGE_DEVELOP_BUILD_DIR is the directory in which the build is done.
# DELUGE_DEVELOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DELUGE_DEVELOP_IPK_DIR is the directory in which the ipk is built.
# DELUGE_DEVELOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DELUGE_DEVELOP_SOURCE_DIR=$(SOURCE_DIR)/deluge-develop
DELUGE_DEVELOP_BUILD_DIR=$(BUILD_DIR)/deluge-develop

DELUGE_DEVELOP_IPK_DIR=$(BUILD_DIR)/deluge-develop-$(DELUGE_DEVELOP_VERSION)-ipk
DELUGE_DEVELOP_IPK=$(BUILD_DIR)/deluge-develop_$(DELUGE_DEVELOP_VERSION)-$(DELUGE_DEVELOP_IPK_VERSION)_$(TARGET_ARCH).ipk

DELUGE_DEVELOP_GTK_IPK_DIR=$(BUILD_DIR)/deluge-develop-gtk-$(DELUGE_DEVELOP_VERSION)-ipk
DELUGE_DEVELOP_GTK_IPK=$(BUILD_DIR)/deluge-develop-gtk_$(DELUGE_DEVELOP_VERSION)-$(DELUGE_DEVELOP_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq (py-gtk, $(filter py-gtk, $(PACKAGES)))
DELUGE_DEVELOP_IPKS=$(DELUGE_DEVELOP_IPK) $(DELUGE_DEVELOP_GTK_IPK)
else
DELUGE_DEVELOP_IPKS=$(DELUGE_DEVELOP_IPK)
endif

.PHONY: deluge-develop-source deluge-develop-unpack deluge-develop deluge-develop-ipk deluge-develop-clean deluge-develop-dirclean deluge-develop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DELUGE_DEVELOP_SOURCE):
	$(MAKE) python27-host-stage py-slimit-host-stage
	(cd $(BUILD_DIR) ; \
		rm -rf deluge-develop && \
		git clone $(DELUGE_DEVELOP_REPOSITORY) deluge-develop && \
		(cd deluge-develop && \
		git checkout develop && \
		git checkout $(DELUGE_DEVELOP_TREEISH) && \
		$(HOST_STAGING_PREFIX)/bin/python2.7 minify_web_js.py deluge/ui/web/js/deluge-all && \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py sdist --formats=tar && \
		bzip2 -ck dist/deluge-*.tar > $@) && \
		rm -rf deluge-develop ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
deluge-develop-source: $(DL_DIR)/$(DELUGE_DEVELOP_SOURCE) $(DELUGE_DEVELOP_PATCHES)

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
$(DELUGE_DEVELOP_BUILD_DIR)/.configured: $(DL_DIR)/$(DELUGE_DEVELOP_SOURCE) $(DELUGE_DEVELOP_PATCHES) make/deluge-develop.mk
	$(MAKE) python27-host-stage py-setuptools-host-stage
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	$(DELUGE_DEVELOP_UNZIP) $(DL_DIR)/$(DELUGE_DEVELOP_SOURCE) | tar -C $(@D) -xvf - --strip-components=1
	if test -n "$(DELUGE_DEVELOP_PATCHES)" ; \
		then cat $(DELUGE_DEVELOP_PATCHES) | \
		$(PATCH) -d $(@D) -p1; \
	fi
	(cd $(@D); \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
	### set default deluge config dir to $(TARGET_PREFIX)/etc
	sed  -i -e 's|return os\.path\.join(save_config_path("deluge"), filename)|return os.path.join("$(TARGET_PREFIX)/etc/deluge", filename)|' \
		-e 's|return save_config_path("deluge")|return "$(TARGET_PREFIX)/etc/deluge"|' \
									$(@D)/deluge/common.py
	### usr $(TARGET_PREFIX)/share instead of /usr/share
	find $(@D)/deluge -type f -name *.py -exec sed -i -e 's|/usr/share|$(TARGET_PREFIX)/share|g' {} \;
	### change 'dev[0-9]*' suffix in version string to $(DELUGE_DEVELOP_VERSION)
	sed -i -e 's/dev[0-9]*/$(DELUGE_DEVELOP_VERSION)/' $(@D)/RELEASE-VERSION
	touch $@

deluge-develop-unpack: $(DELUGE_DEVELOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DELUGE_DEVELOP_BUILD_DIR)/.built: $(DELUGE_DEVELOP_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
deluge-develop: $(DELUGE_DEVELOP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/deluge-develop
#
$(DELUGE_DEVELOP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: deluge-develop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DELUGE_DEVELOP_PRIORITY)" >>$@
	@echo "Section: $(DELUGE_DEVELOP_SECTION)" >>$@
	@echo "Version: $(DELUGE_DEVELOP_VERSION)-$(DELUGE_DEVELOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DELUGE_DEVELOP_MAINTAINER)" >>$@
	@echo "Source: $(DELUGE_DEVELOP_REPOSITORY)" >>$@
	@echo "Description: $(DELUGE_DEVELOP_DESCRIPTION)" >>$@
	@echo "Depends: $(DELUGE_DEVELOP_DEPENDS)" >>$@
	@echo "Conflicts: $(DELUGE_DEVELOP_CONFLICTS)" >>$@

$(DELUGE_DEVELOP_GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: deluge-develop-gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DELUGE_DEVELOP_PRIORITY)" >>$@
	@echo "Section: $(DELUGE_DEVELOP_SECTION)" >>$@
	@echo "Version: $(DELUGE_DEVELOP_VERSION)-$(DELUGE_DEVELOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DELUGE_DEVELOP_MAINTAINER)" >>$@
	@echo "Source: $(DELUGE_DEVELOP_REPOSITORY)" >>$@
	@echo "Description: $(DELUGE_DEVELOP_GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(DELUGE_DEVELOP_GTK_DEPENDS)" >>$@
	@echo "Conflicts: $(DELUGE_DEVELOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/etc/deluge-develop/...
# Documentation files should be installed in $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/doc/deluge-develop/...
# Daemon startup scripts should be installed in $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??deluge-develop
#
# You may need to patch your application to make it use these locations.
#
$(DELUGE_DEVELOP_IPKS): $(DELUGE_DEVELOP_BUILD_DIR)/.built
	rm -rf $(DELUGE_DEVELOP_IPK_DIR) $(BUILD_DIR)/deluge-develop_*_$(TARGET_ARCH).ipk \
		$(DELUGE_DEVELOP_GTK_IPK_DIR) $(BUILD_DIR)/deluge-develop-gtk_*_$(TARGET_ARCH).ipk
	(cd $(DELUGE_DEVELOP_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(DELUGE_DEVELOP_IPK_DIR) --prefix=$(TARGET_PREFIX))
ifeq (py-gtk, $(filter py-gtk, $(PACKAGES)))
	$(INSTALL) -d $(DELUGE_DEVELOP_GTK_IPK_DIR)$(TARGET_PREFIX)/bin $(DELUGE_DEVELOP_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	mv -f $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/bin/deluge-gtk $(DELUGE_DEVELOP_GTK_IPK_DIR)$(TARGET_PREFIX)/bin
	mv -f $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/deluge-gtk.1 $(DELUGE_DEVELOP_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	mv -f $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/applications $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/icons $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/pixmaps \
		$(DELUGE_DEVELOP_GTK_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(DELUGE_DEVELOP_GTK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DELUGE_DEVELOP_GTK_IPK_DIR)
else
	rm -f $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/bin/deluge-gtk $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/deluge-gtk.1
	rm -rf $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/applications $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/icons $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/share/pixmaps
endif
	### init scripts
	$(INSTALL) -d $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_DEVELOP_SOURCE_DIR)/S80deluged $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_DEVELOP_SOURCE_DIR)/S80deluge-web $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DELUGE_DEVELOP_SOURCE_DIR)/deluge-web-reset_password $(DELUGE_DEVELOP_IPK_DIR)$(TARGET_PREFIX)/bin
	$(MAKE) $(DELUGE_DEVELOP_IPK_DIR)/CONTROL/control
	### post-install: change default deluge ui to console
	$(INSTALL) -m 755 $(DELUGE_DEVELOP_SOURCE_DIR)/postinst $(DELUGE_DEVELOP_IPK_DIR)/CONTROL/postinst
	echo $(DELUGE_DEVELOP_CONFFILES) | sed -e 's/ /\n/g' > $(DELUGE_DEVELOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DELUGE_DEVELOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
deluge-develop-ipk: $(DELUGE_DEVELOP_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
deluge-develop-clean:
	-$(MAKE) -C $(DELUGE_DEVELOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
deluge-develop-dirclean:
	rm -rf $(DELUGE_DEVELOP_BUILD_DIR) \
	$(DELUGE_DEVELOP_IPK_DIR) $(DELUGE_DEVELOP_IPK) \

#
# Some sanity check for the package.
#
deluge-develop-check: $(DELUGE_DEVELOP_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
