###########################################################
#
# ncmpc
#
###########################################################
#
# NCMPC_VERSION, NCMPC_SITE and NCMPC_SOURCE define
# the upstream location of the source code for the package.
# NCMPC_DIR is the directory which is created when the source
# archive is unpacked.
# NCMPC_UNZIP is the command used to unzip the source.
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
NCMPC_VERSION=0.14
NCMPC_SITE=http://downloads.sourceforge.net/musicpd
NCMPC_SOURCE=ncmpc-$(NCMPC_VERSION).tar.bz2
NCMPC_DIR=ncmpc-$(NCMPC_VERSION)
NCMPC_UNZIP=bzcat
NCMPC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NCMPC_DESCRIPTION=A curses client for the Music Player Daemon (MPD).
NCMPC_SECTION=multimedia
NCMPC_PRIORITY=optional
NCMPC_DEPENDS=ncurses, glib
NCMPC_SUGGESTS=
NCMPC_CONFLICTS=

#
# NCMPC_IPK_VERSION should be incremented when the ipk changes.
#
NCMPC_IPK_VERSION=1

#
# NCMPC_CONFFILES should be a list of user-editable files
#NCMPC_CONFFILES=/opt/etc/ncmpc.conf /opt/etc/init.d/SXXncmpc

#
# NCMPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NCMPC_PATCHES=$(NCMPC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NCMPC_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
NCMPC_LDFLAGS=

#
# NCMPC_BUILD_DIR is the directory in which the build is done.
# NCMPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NCMPC_IPK_DIR is the directory in which the ipk is built.
# NCMPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NCMPC_BUILD_DIR=$(BUILD_DIR)/ncmpc
NCMPC_SOURCE_DIR=$(SOURCE_DIR)/ncmpc
NCMPC_IPK_DIR=$(BUILD_DIR)/ncmpc-$(NCMPC_VERSION)-ipk
NCMPC_IPK=$(BUILD_DIR)/ncmpc_$(NCMPC_VERSION)-$(NCMPC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ncmpc-source ncmpc-unpack ncmpc ncmpc-stage ncmpc-ipk ncmpc-clean ncmpc-dirclean ncmpc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NCMPC_SOURCE):
	$(WGET) -P $(@D) $(NCMPC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ncmpc-source: $(DL_DIR)/$(NCMPC_SOURCE) $(NCMPC_PATCHES)

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
$(NCMPC_BUILD_DIR)/.configured: $(DL_DIR)/$(NCMPC_SOURCE) $(NCMPC_PATCHES) make/ncmpc.mk
	$(MAKE) glib-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(NCMPC_DIR) $(NCMPC_BUILD_DIR)
	$(NCMPC_UNZIP) $(DL_DIR)/$(NCMPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NCMPC_PATCHES)" ; \
		then cat $(NCMPC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NCMPC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NCMPC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NCMPC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NCMPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NCMPC_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ncmpc-unpack: $(NCMPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NCMPC_BUILD_DIR)/.built: $(NCMPC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ncmpc: $(NCMPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NCMPC_BUILD_DIR)/.staged: $(NCMPC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ncmpc-stage: $(NCMPC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ncmpc
#
$(NCMPC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ncmpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCMPC_PRIORITY)" >>$@
	@echo "Section: $(NCMPC_SECTION)" >>$@
	@echo "Version: $(NCMPC_VERSION)-$(NCMPC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCMPC_MAINTAINER)" >>$@
	@echo "Source: $(NCMPC_SITE)/$(NCMPC_SOURCE)" >>$@
	@echo "Description: $(NCMPC_DESCRIPTION)" >>$@
	@echo "Depends: $(NCMPC_DEPENDS)" >>$@
	@echo "Suggests: $(NCMPC_SUGGESTS)" >>$@
	@echo "Conflicts: $(NCMPC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NCMPC_IPK_DIR)/opt/sbin or $(NCMPC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NCMPC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NCMPC_IPK_DIR)/opt/etc/ncmpc/...
# Documentation files should be installed in $(NCMPC_IPK_DIR)/opt/doc/ncmpc/...
# Daemon startup scripts should be installed in $(NCMPC_IPK_DIR)/opt/etc/init.d/S??ncmpc
#
# You may need to patch your application to make it use these locations.
#
$(NCMPC_IPK): $(NCMPC_BUILD_DIR)/.built
	rm -rf $(NCMPC_IPK_DIR) $(BUILD_DIR)/ncmpc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NCMPC_BUILD_DIR) DESTDIR=$(NCMPC_IPK_DIR) install-strip
#	install -d $(NCMPC_IPK_DIR)/opt/etc/
#	install -m 644 $(NCMPC_SOURCE_DIR)/ncmpc.conf $(NCMPC_IPK_DIR)/opt/etc/ncmpc.conf
#	install -d $(NCMPC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NCMPC_SOURCE_DIR)/rc.ncmpc $(NCMPC_IPK_DIR)/opt/etc/init.d/SXXncmpc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCMPC_IPK_DIR)/opt/etc/init.d/SXXncmpc
	$(MAKE) $(NCMPC_IPK_DIR)/CONTROL/control
#	install -m 755 $(NCMPC_SOURCE_DIR)/postinst $(NCMPC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCMPC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NCMPC_SOURCE_DIR)/prerm $(NCMPC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCMPC_IPK_DIR)/CONTROL/prerm
	echo $(NCMPC_CONFFILES) | sed -e 's/ /\n/g' > $(NCMPC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCMPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ncmpc-ipk: $(NCMPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ncmpc-clean:
	rm -f $(NCMPC_BUILD_DIR)/.built
	-$(MAKE) -C $(NCMPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ncmpc-dirclean:
	rm -rf $(BUILD_DIR)/$(NCMPC_DIR) $(NCMPC_BUILD_DIR) $(NCMPC_IPK_DIR) $(NCMPC_IPK)
#
#
# Some sanity check for the package.
#
ncmpc-check: $(NCMPC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
