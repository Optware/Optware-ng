###########################################################
#
# asterisk14-gui
#
###########################################################
#
# ASTERISK14_GUI_VERSION, ASTERISK14_GUI_SITE and ASTERISK14_GUI_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK14_GUI_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK14_GUI_UNZIP is the command used to unzip the source.
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
ASTERISK14_GUI_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/asterisk14-gui
ASTERISK14_GUI_SVN=http://svn.digium.com/svn/asterisk-gui/trunk
ASTERISK14_GUI_SVN_REV=395
ASTERISK14_GUI_VERSION=0.0.0svn-r$(ASTERISK14_GUI_SVN_REV)
ASTERISK14_GUI_SOURCE=asterisk14-gui-$(ASTERISK14_GUI_VERSION).tar.gz
ASTERISK14_GUI_DIR=asterisk14-gui
ASTERISK14_GUI_UNZIP=zcat
ASTERISK14_GUI_MAINTAINER=Ovidiu Sas <sip.nslu@gmail.com>
ASTERISK14_GUI_DESCRIPTION=Asterisk-GUI is a framework for the \
creation of graphical interfaces for configuring Asterisk.
ASTERISK14_GUI_SECTION=util
ASTERISK14_GUI_PRIORITY=optional
ASTERISK14_GUI_DEPENDS=asterisk14,procps,coreutils,grep,tar
ASTERISK14_GUI_SUGGESTS=
ASTERISK14_GUI_CONFLICTS=asterisk,asterisk-sounds

#
# ASTERISK14_GUI_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14_GUI_IPK_VERSION=3

#
# ASTERISK14_GUI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK14_GUI_PATCHES=$(ASTERISK14_GUI_SOURCE_DIR)/gui_sysinfo.patch $(ASTERISK14_GUI_SOURCE_DIR)/sysinfo.html.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK14_GUI_CPPFLAGS=
ASTERISK14_GUI_LDFLAGS=

#
# ASTERISK14_GUI_BUILD_DIR is the directory in which the build is done.
# ASTERISK14_GUI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK14_GUI_IPK_DIR is the directory in which the ipk is built.
# ASTERISK14_GUI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK14_GUI_BUILD_DIR=$(BUILD_DIR)/asterisk14-gui
ASTERISK14_GUI_SOURCE_DIR=$(SOURCE_DIR)/asterisk14-gui
ASTERISK14_GUI_IPK_DIR=$(BUILD_DIR)/asterisk14-gui-$(ASTERISK14_GUI_VERSION)-ipk
ASTERISK14_GUI_IPK=$(BUILD_DIR)/asterisk14-gui_$(ASTERISK14_GUI_VERSION)-$(ASTERISK14_GUI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk14-gui-source asterisk14-gui-unpack asterisk14-gui asterisk14-gui-stage asterisk14-gui-ipk asterisk14-gui-clean asterisk14-gui-dirclean asterisk14-gui-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK14_GUI_SOURCE):
	#$(WGET) -P $(DL_DIR) $(ASTERISK14_GUI_SITE)/$(ASTERISK14_GUI_SOURCE)
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK14_GUI_DIR) && \
		svn co -r $(ASTERISK14_GUI_SVN_REV) $(ASTERISK14_GUI_SVN) \
			$(ASTERISK14_GUI_DIR) && \
		tar -czf $@ $(ASTERISK14_GUI_DIR) && \
		rm -rf $(ASTERISK14_GUI_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk14-gui-source: $(DL_DIR)/$(ASTERISK14_GUI_SOURCE) $(ASTERISK14_GUI_PATCHES)

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
$(ASTERISK14_GUI_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK14_GUI_SOURCE) $(ASTERISK14_GUI_PATCHES) make/asterisk14-gui.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14_GUI_DIR) $(ASTERISK14_GUI_BUILD_DIR)
	$(ASTERISK14_GUI_UNZIP) $(DL_DIR)/$(ASTERISK14_GUI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK14_GUI_PATCHES)" ; \
		then cat $(ASTERISK14_GUI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK14_GUI_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14_GUI_DIR)" != "$(ASTERISK14_GUI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14_GUI_DIR) $(ASTERISK14_GUI_BUILD_DIR) ; \
	fi
	(cd $(ASTERISK14_GUI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK14_GUI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK14_GUI_LDFLAGS)" \
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
	touch $(ASTERISK14_GUI_BUILD_DIR)/.configured

asterisk14-gui-unpack: $(ASTERISK14_GUI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14_GUI_BUILD_DIR)/.built: $(ASTERISK14_GUI_BUILD_DIR)/.configured
	rm -f $(ASTERISK14_GUI_BUILD_DIR)/.built
	$(MAKE) -C $(ASTERISK14_GUI_BUILD_DIR)
	touch $(ASTERISK14_GUI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk14-gui: $(ASTERISK14_GUI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK14_GUI_BUILD_DIR)/.staged: $(ASTERISK14_GUI_BUILD_DIR)/.built
	rm -f $(ASTERISK14_GUI_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK14_GUI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ASTERISK14_GUI_BUILD_DIR)/.staged

asterisk14-gui-stage: $(ASTERISK14_GUI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14-gui
#
$(ASTERISK14_GUI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk14-gui" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK14_GUI_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK14_GUI_SECTION)" >>$@
	@echo "Version: $(ASTERISK14_GUI_VERSION)-$(ASTERISK14_GUI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK14_GUI_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK14_GUI_SITE)/$(ASTERISK14_GUI_SOURCE)" >>$@
	@echo "Description: $(ASTERISK14_GUI_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK14_GUI_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK14_GUI_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK14_GUI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK14_GUI_IPK_DIR)/opt/sbin or $(ASTERISK14_GUI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14_GUI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk14-gui/...
# Documentation files should be installed in $(ASTERISK14_GUI_IPK_DIR)/opt/doc/asterisk14-gui/...
# Daemon startup scripts should be installed in $(ASTERISK14_GUI_IPK_DIR)/opt/etc/init.d/S??asterisk14-gui
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14_GUI_IPK): $(ASTERISK14_GUI_BUILD_DIR)/.built
	rm -rf $(ASTERISK14_GUI_IPK_DIR) $(BUILD_DIR)/asterisk14-gui_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK14_GUI_BUILD_DIR) DESTDIR=$(ASTERISK14_GUI_IPK_DIR) install

	# FIX gui_sysinfo
	sed -i -e 's#`uname -a`#`/opt/bin/uname -a`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`uptime`#`/opt/bin/uptime`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`/usr/sbin/asterisk -V`#`/opt/sbin/asterisk -V`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`date`#`/opt/bin/date`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`hostname -f`#`/bin/hostname -f`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`ifconfig`#`/sbin/ifconfig`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`df -h`#`/opt/bin/df -h`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`free`#`/opt/bin/free`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`/bin/date +%b`#`/opt/bin/date +%b`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`/bin/date +%d`#`/opt/bin/date +%d`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#`/bin/date +%_d`#`/opt/bin/date +%_d`#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo
	sed -i -e 's#/bin/grep /var/log/asterisk/messages#/opt/bin/grep /var/log/asterisk/messages#g' $(ASTERISK14_GUI_IPK_DIR)/opt/etc/asterisk/gui_sysinfo

	# FIX asterisk config directory location
	sed -i -e 's#/etc/asterisk/#/opt/etc/asterisk/#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX rm
	sed -i -e 's#/bin/rm#/opt/bin/rm#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX tar
	sed -i -e 's#/bin/tar#/opt/bin/tar#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX grep
	sed -i -e 's#/bin/grep#/opt/bin/grep#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX touch
	sed -i -e 's#/bin/touch#/opt/bin/touch#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX reboot
	sed -i -e 's#/bin/reboot#/sbin/reboot#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html
	# FIX reset_config
	# sed -i -e 's#/bin/reset_config#/sbin/reset_config#g' $(ASTERISK14_GUI_IPK_DIR)/opt/var/lib/asterisk/static-http/config/*.html

	$(MAKE) $(ASTERISK14_GUI_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK14_GUI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk14-gui-ipk: $(ASTERISK14_GUI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk14-gui-clean:
	rm -f $(ASTERISK14_GUI_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK14_GUI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk14-gui-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK14_GUI_DIR) $(ASTERISK14_GUI_BUILD_DIR) $(ASTERISK14_GUI_IPK_DIR) $(ASTERISK14_GUI_IPK)
#
#
# Some sanity check for the package.
#
asterisk14-gui-check: $(ASTERISK14_GUI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK14_GUI_IPK)
