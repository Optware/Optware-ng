###########################################################
#
# xupnpd
#
###########################################################
#
# XUPNPD_VERSION, XUPNPD_SITE and XUPNPD_SOURCE define
# the upstream location of the source code for the package.
# XUPNPD_DIR is the directory which is created when the source
# archive is unpacked.
# XUPNPD_UNZIP is the command used to unzip the source.
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
XUPNPD_SVN=http://tsdemuxer.googlecode.com/svn/trunk/xupnpd
XUPNPD_SVN_REV=405
XUPNPD_VERSION=svn-$(XUPNPD_SVN_REV)
XUPNPD_SOURCE=xupnpd-$(XUPNPD_VERSION).tar.bz2
XUPNPD_DIR=xupnpd-$(XUPNPD_VERSION)
XUPNPD_UNZIP=bzcat
XUPNPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XUPNPD_DESCRIPTION=eXtensible UPnP agent.
XUPNPD_SECTION=multimedia
XUPNPD_PRIORITY=optional
XUPNPD_DEPENDS=lua, libstdc++
XUPNPD_SUGGESTS=
XUPNPD_CONFLICTS=

#
# XUPNPD_IPK_VERSION should be incremented when the ipk changes.
#
XUPNPD_IPK_VERSION=4

#
# XUPNPD_CONFFILES should be a list of user-editable files
XUPNPD_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S94xupnpd \
$(TARGET_PREFIX)/share/xupnpd/xupnpd.lua \
$(TARGET_PREFIX)/share/xupnpd/playlists/bf.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/example/service.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/example/butovocom_iptv.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/example/example.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/example/iskra.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/example/mozhay.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/ivi_new.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/bf3epic.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/gametrailers_ps3.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/ag_videos.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/vimeo_channel_hd.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/giantbomb_all.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/youtube_channel_top_rated.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/vimeo_channel_mtb.m3u \
$(TARGET_PREFIX)/share/xupnpd/playlists/vimeo_channel_hdxs.m3u

#
# XUPNPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XUPNPD_PATCHES=$(XUPNPD_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XUPNPD_CPPFLAGS=-fno-exceptions -fno-rtti -DWITH_URANDOM
XUPNPD_LDFLAGS=-llua -lm -ldl

#
# XUPNPD_BUILD_DIR is the directory in which the build is done.
# XUPNPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XUPNPD_IPK_DIR is the directory in which the ipk is built.
# XUPNPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XUPNPD_BUILD_DIR=$(BUILD_DIR)/xupnpd
XUPNPD_SOURCE_DIR=$(SOURCE_DIR)/xupnpd
XUPNPD_IPK_DIR=$(BUILD_DIR)/xupnpd-$(XUPNPD_VERSION)-ipk
XUPNPD_IPK=$(BUILD_DIR)/xupnpd_$(XUPNPD_VERSION)-$(XUPNPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xupnpd-source xupnpd-unpack xupnpd xupnpd-stage xupnpd-ipk xupnpd-clean xupnpd-dirclean xupnpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched using subversion.
#
$(DL_DIR)/$(XUPNPD_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(XUPNPD_DIR) && \
		svn co -r $(XUPNPD_SVN_REV) $(XUPNPD_SVN) \
			$(XUPNPD_DIR) && \
		rm -rf $(XUPNPD_DIR)/.svn && \
		tar -cjf $@ $(XUPNPD_DIR) && \
		rm -rf $(XUPNPD_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xupnpd-source: $(DL_DIR)/$(XUPNPD_SOURCE) $(XUPNPD_PATCHES)

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
$(XUPNPD_BUILD_DIR)/.configured: $(DL_DIR)/$(XUPNPD_SOURCE) $(XUPNPD_PATCHES) \
			$(XUPNPD_SOURCE_DIR)/xupnpd_youtube.lua make/xupnpd.mk
	$(MAKE) lua-stage libstdc++-stage
	rm -rf $(BUILD_DIR)/$(XUPNPD_DIR) $(@D)
	$(XUPNPD_UNZIP) $(DL_DIR)/$(XUPNPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XUPNPD_PATCHES)" ; \
		then cat $(XUPNPD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XUPNPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XUPNPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XUPNPD_DIR) $(@D) ; \
	fi
	mv -f $(@D)/src/* $(@D)
	sed -i -e 's|/usr/share|$(TARGET_PREFIX)/share|g' $(@D)/main.cpp
	cp -f $(XUPNPD_SOURCE_DIR)/xupnpd_youtube.lua $(@D)/plugins
	touch $@

xupnpd-unpack: $(XUPNPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XUPNPD_BUILD_DIR)/.built: $(XUPNPD_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/luaxcore.o $(@D)/luaxcore.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/luaxlib.o $(@D)/luaxlib.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/main.o $(@D)/main.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/mem.o $(@D)/mem.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/soap.o $(@D)/soap.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/mcast.o $(@D)/mcast.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/md5c.o $(@D)/md5c.c
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/luajson.o $(@D)/luajson.cpp
	$(TARGET_CC) -c -I$(@D) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/luajson_parser.o $(@D)/luajson_parser.cpp
	$(TARGET_CC) $(STAGING_CPPFLAGS) $(XUPNPD_CPPFLAGS) -o $(@D)/xupnpd $(STAGING_LDFLAGS) \
		$(@D)/main.o $(@D)/soap.o $(@D)/luaxcore.o \
		$(@D)/mem.o $(@D)/luaxlib.o $(@D)/mcast.o \
		$(@D)/md5c.o $(@D)/luajson.o $(@D)/luajson_parser.o $(XUPNPD_LDFLAGS)
	touch $@

#
# This is the build convenience target.
#
xupnpd: $(XUPNPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XUPNPD_BUILD_DIR)/.staged: $(XUPNPD_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

xupnpd-stage: $(XUPNPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xupnpd
#
$(XUPNPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xupnpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XUPNPD_PRIORITY)" >>$@
	@echo "Section: $(XUPNPD_SECTION)" >>$@
	@echo "Version: $(XUPNPD_VERSION)-$(XUPNPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XUPNPD_MAINTAINER)" >>$@
	@echo "Source: $(XUPNPD_SVN)" >>$@
	@echo "Description: $(XUPNPD_DESCRIPTION)" >>$@
	@echo "Depends: $(XUPNPD_DEPENDS)" >>$@
	@echo "Suggests: $(XUPNPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(XUPNPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/xupnpd/...
# Documentation files should be installed in $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/doc/xupnpd/...
# Daemon startup scripts should be installed in $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xupnpd
#
# You may need to patch your application to make it use these locations.
#
$(XUPNPD_IPK): $(XUPNPD_BUILD_DIR)/.built
	rm -rf $(XUPNPD_IPK_DIR) $(BUILD_DIR)/xupnpd_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(XUPNPD_BUILD_DIR) DESTDIR=$(XUPNPD_IPK_DIR) install-strip
	$(INSTALL) -d $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/bin $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d \
		$(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/ui $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/www \
		$(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/plugins $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/playlists \
		$(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/profiles $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/localmedia \
		$(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/config
	$(INSTALL) -m 755 $(XUPNPD_BUILD_DIR)/xupnpd $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/bin/xupnpd
	$(INSTALL) -m 755 $(XUPNPD_SOURCE_DIR)/rc.xupnpd $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S94xupnpd
	cp -f $(XUPNPD_BUILD_DIR)/*.lua $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd
	cp -rf $(XUPNPD_BUILD_DIR)/ui/* $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/ui
	cp -rf $(XUPNPD_BUILD_DIR)/www/* $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/www
	cp -rf $(XUPNPD_BUILD_DIR)/plugins/* $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/plugins
	cp -rf $(XUPNPD_BUILD_DIR)/playlists/* $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/playlists
	cp -rf $(XUPNPD_BUILD_DIR)/profiles/* $(XUPNPD_IPK_DIR)$(TARGET_PREFIX)/share/xupnpd/profiles
	$(MAKE) $(XUPNPD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(XUPNPD_SOURCE_DIR)/postinst $(XUPNPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XUPNPD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(XUPNPD_SOURCE_DIR)/prerm $(XUPNPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XUPNPD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XUPNPD_IPK_DIR)/CONTROL/postinst $(XUPNPD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XUPNPD_CONFFILES) | sed -e 's/ /\n/g' > $(XUPNPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XUPNPD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XUPNPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xupnpd-ipk: $(XUPNPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xupnpd-clean:
	rm -f $(XUPNPD_BUILD_DIR)/.built
	-$(MAKE) -C $(XUPNPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xupnpd-dirclean:
	rm -rf $(BUILD_DIR)/$(XUPNPD_DIR) $(XUPNPD_BUILD_DIR) $(XUPNPD_IPK_DIR) $(XUPNPD_IPK)
#
#
# Some sanity check for the package.
#
xupnpd-check: $(XUPNPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
