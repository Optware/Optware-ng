###########################################################
#
# lua
#
###########################################################

# You must replace "lua" and "LUA" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LUA_VERSION, LUA_SITE and LUA_SOURCE define
# the upstream location of the source code for the package.
# LUA_DIR is the directory which is created when the source
# archive is unpacked.
# LUA_UNZIP is the command used to unzip the source.
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
LUA_SITE=http://www.lua.org/ftp
LUA_VERSION=5.1.3
LUA_SOURCE=lua-$(LUA_VERSION).tar.gz
LUA_DIR=lua-$(LUA_VERSION)
LUA_UNZIP=zcat
LUA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LUA_DESCRIPTION=Lua is a powerful light-weight programming language designed for extending applications.
LUA_SECTION=misc
LUA_PRIORITY=optional
LUA_DEPENDS=readline, ncurses

#
# LUA_IPK_VERSION should be incremented when the ipk changes.
#
LUA_IPK_VERSION=1

#
# LUA_CONFFILES should be a list of user-editable files
# LUA_CONFFILES=/opt/etc/lua.conf /opt/etc/init.d/SXXlua

#
# LUA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LUA_PATCHES=$(LUA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LUA_CPPFLAGS=-DLUA_USE_LINUX
LUA_LDFLAGS=

#
# LUA_BUILD_DIR is the directory in which the build is done.
# LUA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LUA_IPK_DIR is the directory in which the ipk is built.
# LUA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LUA_BUILD_DIR=$(BUILD_DIR)/lua
LUA_SOURCE_DIR=$(SOURCE_DIR)/lua
LUA_IPK_DIR=$(BUILD_DIR)/lua-$(LUA_VERSION)-ipk
LUA_IPK=$(BUILD_DIR)/lua_$(LUA_VERSION)-$(LUA_IPK_VERSION)_$(TARGET_ARCH).ipk
LUA_HOST_BUILD_DIR=$(BUILD_DIR)/lua-host

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LUA_SOURCE):
	$(WGET) -P $(DL_DIR) $(LUA_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lua-source: $(DL_DIR)/$(LUA_SOURCE) $(LUA_PATCHES)

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
$(LUA_BUILD_DIR)/.configured: $(DL_DIR)/$(LUA_SOURCE) $(LUA_PATCHES)
	make readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(LUA_DIR) $(LUA_HOST_BUILD_DIR) $(LUA_BUILD_DIR)
	$(LUA_UNZIP) $(DL_DIR)/$(LUA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LUA_DIR) $(LUA_HOST_BUILD_DIR)
	$(LUA_UNZIP) $(DL_DIR)/$(LUA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LUA_DIR) $(LUA_BUILD_DIR)
	touch $@

lua-unpack: $(LUA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LUA_BUILD_DIR)/.built: $(LUA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LUA_HOST_BUILD_DIR)/src \
		MYCFLAGS="-DLUA_ANSI" \
		MYLDFLAGS="$(LUA_LDFLAGS)" \
		MYLIBS="-Wl,-E -ldl" \
		all
	$(MAKE) -C $(LUA_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		AR="$(TARGET_AR) rcu" \
		MYCFLAGS="$(STAGING_CPPFLAGS) $(LUA_CPPFLAGS)" \
		MYLDFLAGS="$(STAGING_LDFLAGS) $(LUA_LDFLAGS)" \
		MYLIBS="-Wl,-E -ldl -lreadline -lhistory -lncurses" \
		all
	touch $@

#
# This is the build convenience target.
#
lua: $(LUA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LUA_BUILD_DIR)/.staged: $(LUA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LUA_HOST_BUILD_DIR) INSTALL_TOP=$(LUA_HOST_BUILD_DIR)/opt install
	$(MAKE) -C $(@D) INSTALL_TOP=$(STAGING_PREFIX) install
	mkdir -p $(STAGING_LIB_DIR)/pkgconfig
	sed -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(@D)/etc/lua.pc > $(STAGING_LIB_DIR)/pkgconfig/lua.pc
	touch $@

lua-stage: $(LUA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lua
#
$(LUA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lua" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LUA_PRIORITY)" >>$@
	@echo "Section: $(LUA_SECTION)" >>$@
	@echo "Version: $(LUA_VERSION)-$(LUA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LUA_MAINTAINER)" >>$@
	@echo "Source: $(LUA_SITE)/$(LUA_SOURCE)" >>$@
	@echo "Description: $(LUA_DESCRIPTION)" >>$@
	@echo "Depends: $(LUA_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LUA_IPK_DIR)/opt/sbin or $(LUA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LUA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LUA_IPK_DIR)/opt/etc/lua/...
# Documentation files should be installed in $(LUA_IPK_DIR)/opt/doc/lua/...
# Daemon startup scripts should be installed in $(LUA_IPK_DIR)/opt/etc/init.d/S??lua
#
# You may need to patch your application to make it use these locations.
#
$(LUA_IPK): $(LUA_BUILD_DIR)/.built
	rm -rf $(LUA_IPK_DIR) $(BUILD_DIR)/lua_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LUA_BUILD_DIR) INSTALL_TOP=$(LUA_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(LUA_IPK_DIR)/opt/bin/*
	install -d $(LUA_IPK_DIR)/opt/lib/pkgconfig
	sed -e 's|^prefix=.*|prefix=/opt|' $(LUA_BUILD_DIR)/etc/lua.pc > $(LUA_IPK_DIR)/opt/lib/pkgconfig/lua.pc
	$(MAKE) $(LUA_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LUA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lua-ipk: $(LUA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lua-clean:
	-$(MAKE) -C $(LUA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lua-dirclean:
	rm -rf $(BUILD_DIR)/$(LUA_DIR) $(LUA_BUILD_DIR) $(LUA_HOST_BUILD_DIR) $(LUA_IPK_DIR) $(LUA_IPK)

#
# Some sanity check for the package.
#
lua-check: $(LUA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LUA_IPK)
