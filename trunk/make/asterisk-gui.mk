###########################################################
#
# asterisk-gui
#
###########################################################
#
# ASTERISK_GUI_VERSION, ASTERISK_GUI_SITE and ASTERISK_GUI_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK_GUI_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK_GUI_UNZIP is the command used to unzip the source.
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
ASTERISK_GUI_SITE=http://downloads.digium.com/pub/telephony/asterisk
ASTERISK_GUI_SVN=http://svn.digium.com/svn/asterisk-gui/branches/2.0
ASTERISK_GUI_SVN_REV=4045
ASTERISK_GUI_VERSION=2.0svn-r$(ASTERISK_GUI_SVN_REV)
ASTERISK_GUI_SOURCE=asterisk-gui-$(ASTERISK_GUI_VERSION).tar.gz
ASTERISK_GUI_DIR=asterisk-gui
ASTERISK_GUI_UNZIP=zcat
ASTERISK_GUI_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
ASTERISK_GUI_DESCRIPTION=Asterisk-GUI is a framework for the \
creation of graphical interfaces for configuring Asterisk.
ASTERISK_GUI_SECTION=util
ASTERISK_GUI_PRIORITY=optional
ASTERISK_GUI_DEPENDS=procps,coreutils,grep,tar
ASTERISK_GUI_SUGGESTS=
ASTERISK_GUI_CONFLICTS=

#
# ASTERISK_GUI_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK_GUI_IPK_VERSION=1

#
# ASTERISK_GUI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK_GUI_PATCHES=$(ASTERISK_GUI_SOURCE_DIR)/gui_sysinfo.patch $(ASTERISK_GUI_SOURCE_DIR)/sysinfo.html.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK_GUI_CPPFLAGS=
ASTERISK_GUI_LDFLAGS=

#
# ASTERISK_GUI_BUILD_DIR is the directory in which the build is done.
# ASTERISK_GUI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK_GUI_IPK_DIR is the directory in which the ipk is built.
# ASTERISK_GUI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK_GUI_BUILD_DIR=$(BUILD_DIR)/asterisk-gui
ASTERISK_GUI_SOURCE_DIR=$(SOURCE_DIR)/asterisk-gui
ASTERISK_GUI_IPK_DIR=$(BUILD_DIR)/asterisk-gui-$(ASTERISK_GUI_VERSION)-ipk
ASTERISK_GUI_IPK=$(BUILD_DIR)/asterisk-gui_$(ASTERISK_GUI_VERSION)-$(ASTERISK_GUI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk-gui-source asterisk-gui-unpack asterisk-gui asterisk-gui-stage asterisk-gui-ipk asterisk-gui-clean asterisk-gui-dirclean asterisk-gui-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK_GUI_SOURCE):
	#$(WGET) -P $(DL_DIR) $(ASTERISK_GUI_SITE)/$(ASTERISK_GUI_SOURCE)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK_GUI_DIR) && \
		svn co -r $(ASTERISK_GUI_SVN_REV) $(ASTERISK_GUI_SVN) \
			$(ASTERISK_GUI_DIR) && \
		tar -czf $@ $(ASTERISK_GUI_DIR) && \
		rm -rf $(ASTERISK_GUI_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk-gui-source: $(DL_DIR)/$(ASTERISK_GUI_SOURCE) $(ASTERISK_GUI_PATCHES)

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
$(ASTERISK_GUI_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK_GUI_SOURCE) $(ASTERISK_GUI_PATCHES) make/asterisk-gui.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK_GUI_DIR) $(ASTERISK_GUI_BUILD_DIR)
	$(ASTERISK_GUI_UNZIP) $(DL_DIR)/$(ASTERISK_GUI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK_GUI_PATCHES)" ; \
		then cat $(ASTERISK_GUI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK_GUI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK_GUI_DIR)" != "$(ASTERISK_GUI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK_GUI_DIR) $(ASTERISK_GUI_BUILD_DIR) ; \
	fi
	(cd $(ASTERISK_GUI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK_GUI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK_GUI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--localstatedir=/opt/var \
		--sysconfdir=/opt/etc \
	)
	touch $(ASTERISK_GUI_BUILD_DIR)/.configured

asterisk-gui-unpack: $(ASTERISK_GUI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK_GUI_BUILD_DIR)/.built: $(ASTERISK_GUI_BUILD_DIR)/.configured
	rm -f $(ASTERISK_GUI_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK_GUI_BUILD_DIR)
	touch $(ASTERISK_GUI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk-gui: $(ASTERISK_GUI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK_GUI_BUILD_DIR)/.staged: $(ASTERISK_GUI_BUILD_DIR)/.built
	rm -f $(ASTERISK_GUI_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK_GUI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ASTERISK_GUI_BUILD_DIR)/.staged

asterisk-gui-stage: $(ASTERISK_GUI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk-gui
#
$(ASTERISK_GUI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk-gui" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK_GUI_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK_GUI_SECTION)" >>$@
	@echo "Version: $(ASTERISK_GUI_VERSION)-$(ASTERISK_GUI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK_GUI_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK_GUI_SITE)/$(ASTERISK_GUI_SOURCE)" >>$@
	@echo "Description: $(ASTERISK_GUI_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK_GUI_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK_GUI_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK_GUI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK_GUI_IPK_DIR)/opt/sbin or $(ASTERISK_GUI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK_GUI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK_GUI_IPK_DIR)/opt/etc/asterisk-gui/...
# Documentation files should be installed in $(ASTERISK_GUI_IPK_DIR)/opt/doc/asterisk-gui/...
# Daemon startup scripts should be installed in $(ASTERISK_GUI_IPK_DIR)/opt/etc/init.d/S??asterisk-gui
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK_GUI_IPK): $(ASTERISK_GUI_BUILD_DIR)/.built
	rm -rf $(ASTERISK_GUI_IPK_DIR) $(BUILD_DIR)/asterisk-gui_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK_GUI_BUILD_DIR) DESTDIR=$(ASTERISK_GUI_IPK_DIR) install

	# FIX gui_sysinfo
	sed -i -e 's#`uname #`/opt/bin/uname #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`uptime`#`/opt/bin/uptime`#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`/usr/sbin/asterisk #`/opt/sbin/asterisk #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`date`#`/opt/bin/date`#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`hostname #`/bin/hostname #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`ifconfig`#`/sbin/ifconfig`#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`df #`/opt/bin/df #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`free`#`/opt/bin/free`#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#`/bin/date #`/opt/bin/date #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*

	# FIX scripts
	sed -i -e 's#`/bin/bash`#`/bin/sh`#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#/etc/#/opt/etc/#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#/var/#/opt/var/#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*

	sed -i -e 's#/bin/grep /var/log/asterisk/messages#/opt/bin/grep /var/log/asterisk/messages#g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#/bin/mkdir #/opt/bin/mkdir #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#/bin/ls #/opt/bin/ls #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*
	sed -i -e 's#/bin/echo #/opt/bin/echo #g' $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/scripts/*

	# FIX asterisk config directory location
	ASTERISK_GUI_HTML_FILES=`find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.html'`
	ASTERISK_GUI_JS_FILES=`find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.js'`
	ASTERISK_GUI_SVGZ_FILES=`find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.svgz'`
	ASTERISK_GUI_GUI_CONFIG_FILES="$(ASTERISK_GUI_HTML_FILES) $(ASTERISK_GUI_JS_FILES) $(ASTERISK_GUI_SVGZ_FILES)"

	#ASTERISK_GUI_GUI_CONFIG_FILE=`find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config`
	#for f in $(ASTERISK_GUI_HTML_FILES) $(ASTERISK_GUI_JS_FILES) $(ASTERISK_GUI_SVGZ_FILES) ; do
	#for f in `find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.html'`; do \


	for f in `find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.html'; \
		find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.js'; \
		find $(ASTERISK_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config -name '*.svgz'`; do \
		sed -i -e 's#/etc/#/opt/etc/#g' $$f; \
		sed -i -e 's#/var/#/opt/var/#g' $$f; \
		sed -i -e 's#/bin/rm#/opt/bin/rm#g' $$f; \
		sed -i -e 's#/bin/tar#/opt/bin/tar#g' $$f; \
		sed -i -e 's#/bin/grep#/opt/bin/grep#g' $$f; \
		sed -i -e 's#/bin/touch#/opt/bin/touch#g' $$f; \
		sed -i -e 's#/bin/reboot#/sbin/reboot#g' $$f; \
		sed -i -e 's#/bin/reset_config#/sbin/reset_config#g' $$f; \
	done

	$(MAKE) $(ASTERISK_GUI_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK_GUI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk-gui-ipk: $(ASTERISK_GUI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk-gui-clean:
	rm -f $(ASTERISK_GUI_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK_GUI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-gui-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK_GUI_DIR) $(ASTERISK_GUI_BUILD_DIR) $(ASTERISK_GUI_IPK_DIR) $(ASTERISK_GUI_IPK)
#
#
# Some sanity check for the package.
#
asterisk-gui-check: $(ASTERISK_GUI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK_GUI_IPK)
