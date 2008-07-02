###########################################################
#
# luarocks
#
###########################################################
#
# LUAROCKS_VERSION, LUAROCKS_SITE and LUAROCKS_SOURCE define
# the upstream location of the source code for the package.
# LUAROCKS_DIR is the directory which is created when the source
# archive is unpacked.
# LUAROCKS_UNZIP is the command used to unzip the source.
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
LUAROCKS_SITE=http://luaforge.net/frs/download.php/3516
LUAROCKS_VERSION=0.6.0.2
LUAROCKS_SOURCE=luarocks-$(LUAROCKS_VERSION).tar.gz
LUAROCKS_DIR=luarocks-$(LUAROCKS_VERSION)
LUAROCKS_UNZIP=zcat
LUAROCKS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LUAROCKS_DESCRIPTION=LuaRocks is a deployment and management system for Lua modules.
LUAROCKS_SECTION=devel
LUAROCKS_PRIORITY=optional
LUAROCKS_DEPENDS=lua, coreutils, wget-ssl
LUAROCKS_SUGGESTS=
LUAROCKS_CONFLICTS=

#
# LUAROCKS_IPK_VERSION should be incremented when the ipk changes.
#
LUAROCKS_IPK_VERSION=1

#
# LUAROCKS_CONFFILES should be a list of user-editable files
LUAROCKS_CONFFILES=/opt/etc/luarocks/config.lua

#
# LUAROCKS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LUAROCKS_PATCHES=$(LUAROCKS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LUAROCKS_CPPFLAGS=
LUAROCKS_LDFLAGS=

#
# LUAROCKS_BUILD_DIR is the directory in which the build is done.
# LUAROCKS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LUAROCKS_IPK_DIR is the directory in which the ipk is built.
# LUAROCKS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LUAROCKS_BUILD_DIR=$(BUILD_DIR)/luarocks
LUAROCKS_SOURCE_DIR=$(SOURCE_DIR)/luarocks
LUAROCKS_IPK_DIR=$(BUILD_DIR)/luarocks-$(LUAROCKS_VERSION)-ipk
LUAROCKS_IPK=$(BUILD_DIR)/luarocks_$(LUAROCKS_VERSION)-$(LUAROCKS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: luarocks-source luarocks-unpack luarocks luarocks-stage luarocks-ipk luarocks-clean luarocks-dirclean luarocks-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LUAROCKS_SOURCE):
	$(WGET) -P $(@D) $(LUAROCKS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
luarocks-source: $(DL_DIR)/$(LUAROCKS_SOURCE) $(LUAROCKS_PATCHES)

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
$(LUAROCKS_BUILD_DIR)/.configured: $(DL_DIR)/$(LUAROCKS_SOURCE) $(LUAROCKS_PATCHES) make/luarocks.mk
	$(MAKE) lua-stage
	rm -rf $(BUILD_DIR)/$(LUAROCKS_DIR) $(@D)
	$(LUAROCKS_UNZIP) $(DL_DIR)/$(LUAROCKS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LUAROCKS_PATCHES)" ; \
		then cat $(LUAROCKS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LUAROCKS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LUAROCKS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LUAROCKS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LUAROCKS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LUAROCKS_LDFLAGS)" \
		./configure \
		--prefix=/opt \
		--rocks-tree=/opt/local/lib/luarocks \
		--scripts-dir=/opt/local/bin \
		--with-lua=$(STAGING_PREFIX) \
		--with-downloader=wget \
		--with-md5-checker=md5sum \
	)
	touch $@

luarocks-unpack: $(LUAROCKS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LUAROCKS_BUILD_DIR)/.built: $(LUAROCKS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LUA_BINDIR=/opt/bin \
		LUA_INCDIR=/opt/include \
		LUA_LIBDIR=/opt/lib \
		LUAROCKS_UNAME_S=Linux \
		LUAROCKS_UNAME_M=$(TARGET_ARCH) \
		;
	sed -i.orig -e 's|/usr/local|/opt|g' $(@D)/src/luarocks/cfg.lua
	touch $@

#
# This is the build convenience target.
#
luarocks: $(LUAROCKS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LUAROCKS_BUILD_DIR)/.staged: $(LUAROCKS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

luarocks-stage: $(LUAROCKS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/luarocks
#
$(LUAROCKS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: luarocks" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LUAROCKS_PRIORITY)" >>$@
	@echo "Section: $(LUAROCKS_SECTION)" >>$@
	@echo "Version: $(LUAROCKS_VERSION)-$(LUAROCKS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LUAROCKS_MAINTAINER)" >>$@
	@echo "Source: $(LUAROCKS_SITE)/$(LUAROCKS_SOURCE)" >>$@
	@echo "Description: $(LUAROCKS_DESCRIPTION)" >>$@
	@echo "Depends: $(LUAROCKS_DEPENDS)" >>$@
	@echo "Suggests: $(LUAROCKS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LUAROCKS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LUAROCKS_IPK_DIR)/opt/sbin or $(LUAROCKS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LUAROCKS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LUAROCKS_IPK_DIR)/opt/etc/luarocks/...
# Documentation files should be installed in $(LUAROCKS_IPK_DIR)/opt/doc/luarocks/...
# Daemon startup scripts should be installed in $(LUAROCKS_IPK_DIR)/opt/etc/init.d/S??luarocks
#
# You may need to patch your application to make it use these locations.
#
$(LUAROCKS_IPK): $(LUAROCKS_BUILD_DIR)/.built
	rm -rf $(LUAROCKS_IPK_DIR) $(BUILD_DIR)/luarocks_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LUAROCKS_BUILD_DIR) DESTDIR=$(LUAROCKS_IPK_DIR) install
	install -d $(LUAROCKS_IPK_DIR)/opt/local/bin $(LUAROCKS_IPK_DIR)/opt/local/lib/luarocks
	$(MAKE) $(LUAROCKS_IPK_DIR)/CONTROL/control
	echo $(LUAROCKS_CONFFILES) | sed -e 's/ /\n/g' > $(LUAROCKS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LUAROCKS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
luarocks-ipk: $(LUAROCKS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
luarocks-clean:
	rm -f $(LUAROCKS_BUILD_DIR)/.built
	-$(MAKE) -C $(LUAROCKS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
luarocks-dirclean:
	rm -rf $(BUILD_DIR)/$(LUAROCKS_DIR) $(LUAROCKS_BUILD_DIR) $(LUAROCKS_IPK_DIR) $(LUAROCKS_IPK)
#
#
# Some sanity check for the package.
#
luarocks-check: $(LUAROCKS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LUAROCKS_IPK)
