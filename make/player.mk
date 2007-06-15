###########################################################
#
# player
#
###########################################################
#
# PLAYER_VERSION, PLAYER_SITE and PLAYER_SOURCE define
# the upstream location of the source code for the package.
# PLAYER_DIR is the directory which is created when the source
# archive is unpacked.
# PLAYER_UNZIP is the command used to unzip the source.
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
PLAYER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/playerstage
PLAYER_VERSION=2.0.4
PLAYER_SOURCE=player-$(PLAYER_VERSION).tar.bz2
PLAYER_DIR=player-$(PLAYER_VERSION)
PLAYER_UNZIP=bzcat
PLAYER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PLAYER_DESCRIPTION=Player provides a network interface to a variety of robot and sensor hardware. \
Player''s client/server model allows robot control programs to be written in any programming language and to run on any computer with a network connection to the robot. Player supports multiple concurrent client connections to devices, creating new possibilities for distributed and collaborative sensing and control.
PLAYER_SECTION=misc
PLAYER_PRIORITY=optional
PLAYER_DEPENDS=libjpeg, openssl
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PLAYER_DEPENDS+=, libstdc++
endif
PLAYER_SUGGESTS=
PLAYER_CONFLICTS=

#
# PLAYER_IPK_VERSION should be incremented when the ipk changes.
#
PLAYER_IPK_VERSION=1

#
# PLAYER_CONFFILES should be a list of user-editable files
#PLAYER_CONFFILES=/opt/etc/player.conf /opt/etc/init.d/SXXplayer

#
# PLAYER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PLAYER_PATCHES=$(PLAYER_SOURCE_DIR)/server-Makefile.in.patch
PLAYER_PATCHES+=$(PLAYER_SOURCE_DIR)/uint.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PLAYER_CPPFLAGS=
PLAYER_LDFLAGS=

#
# PLAYER_BUILD_DIR is the directory in which the build is done.
# PLAYER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PLAYER_IPK_DIR is the directory in which the ipk is built.
# PLAYER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PLAYER_BUILD_DIR=$(BUILD_DIR)/player
PLAYER_SOURCE_DIR=$(SOURCE_DIR)/player
PLAYER_IPK_DIR=$(BUILD_DIR)/player-$(PLAYER_VERSION)-ipk
PLAYER_IPK=$(BUILD_DIR)/player_$(PLAYER_VERSION)-$(PLAYER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: player-source player-unpack player player-stage player-ipk player-clean player-dirclean player-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PLAYER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PLAYER_SITE)/$(PLAYER_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PLAYER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
player-source: $(DL_DIR)/$(PLAYER_SOURCE) $(PLAYER_PATCHES)

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
$(PLAYER_BUILD_DIR)/.configured: $(DL_DIR)/$(PLAYER_SOURCE) $(PLAYER_PATCHES) # make/player.mk
	$(MAKE) libjpeg-stage
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(PLAYER_DIR) $(PLAYER_BUILD_DIR)
	$(PLAYER_UNZIP) $(DL_DIR)/$(PLAYER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PLAYER_PATCHES)" ; \
		then cat $(PLAYER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PLAYER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PLAYER_DIR)" != "$(PLAYER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PLAYER_DIR) $(PLAYER_BUILD_DIR) ; \
	fi
	sed -i -e '/^ *have_pkg_config=no/s/=no/=yes/' $(PLAYER_BUILD_DIR)/configure
	(cd $(PLAYER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PLAYER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PLAYER_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-jplayer \
		--disable-nls \
		--disable-static \
		--program-transform-name='' \
	)
	$(PATCH_LIBTOOL) $(PLAYER_BUILD_DIR)/libtool
	touch $@

player-unpack: $(PLAYER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PLAYER_BUILD_DIR)/.built: $(PLAYER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PLAYER_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
player: $(PLAYER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PLAYER_BUILD_DIR)/.staged: $(PLAYER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PLAYER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

player-stage: $(PLAYER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/player
#
$(PLAYER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: player" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PLAYER_PRIORITY)" >>$@
	@echo "Section: $(PLAYER_SECTION)" >>$@
	@echo "Version: $(PLAYER_VERSION)-$(PLAYER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PLAYER_MAINTAINER)" >>$@
	@echo "Source: $(PLAYER_SITE)/$(PLAYER_SOURCE)" >>$@
	@echo "Description: $(PLAYER_DESCRIPTION)" >>$@
	@echo "Depends: $(PLAYER_DEPENDS)" >>$@
	@echo "Suggests: $(PLAYER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PLAYER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PLAYER_IPK_DIR)/opt/sbin or $(PLAYER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PLAYER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PLAYER_IPK_DIR)/opt/etc/player/...
# Documentation files should be installed in $(PLAYER_IPK_DIR)/opt/doc/player/...
# Daemon startup scripts should be installed in $(PLAYER_IPK_DIR)/opt/etc/init.d/S??player
#
# You may need to patch your application to make it use these locations.
#
$(PLAYER_IPK): $(PLAYER_BUILD_DIR)/.built
	rm -rf $(PLAYER_IPK_DIR) $(BUILD_DIR)/player_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PLAYER_BUILD_DIR) DESTDIR=$(PLAYER_IPK_DIR) install-strip
	rm -f $(PLAYER_IPK_DIR)/opt/lib/libplayer*.la
#	install -d $(PLAYER_IPK_DIR)/opt/etc/
#	install -m 644 $(PLAYER_SOURCE_DIR)/player.conf $(PLAYER_IPK_DIR)/opt/etc/player.conf
#	install -d $(PLAYER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PLAYER_SOURCE_DIR)/rc.player $(PLAYER_IPK_DIR)/opt/etc/init.d/SXXplayer
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PLAYER_IPK_DIR)/opt/etc/init.d/SXXplayer
	$(MAKE) $(PLAYER_IPK_DIR)/CONTROL/control
#	install -m 755 $(PLAYER_SOURCE_DIR)/postinst $(PLAYER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PLAYER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PLAYER_SOURCE_DIR)/prerm $(PLAYER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PLAYER_IPK_DIR)/CONTROL/prerm
	echo $(PLAYER_CONFFILES) | sed -e 's/ /\n/g' > $(PLAYER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PLAYER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
player-ipk: $(PLAYER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
player-clean:
	rm -f $(PLAYER_BUILD_DIR)/.built
	-$(MAKE) -C $(PLAYER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
player-dirclean:
	rm -rf $(BUILD_DIR)/$(PLAYER_DIR) $(PLAYER_BUILD_DIR) $(PLAYER_IPK_DIR) $(PLAYER_IPK)
#
#
# Some sanity check for the package.
#
player-check: $(PLAYER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PLAYER_IPK)
