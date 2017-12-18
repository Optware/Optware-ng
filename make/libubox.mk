###########################################################
#
# libubox
#
###########################################################
#
# LIBUBOX_VERSION, LIBUBOX_SITE and LIBUBOX_SOURCE define
# the upstream location of the source code for the package.
# LIBUBOX_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUBOX_UNZIP is the command used to unzip the source.
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
LIBUBOX_REPOSITORY=https://git.openwrt.org/project/libubox.git
LIBUBOX_VERSION=20170617
LIBUBOX_COMMIT=fd57eea9f37e447814afbf934db626288aac23c4
LIBUBOX_SOURCE=libubox-$(LIBUBOX_VERSION).tar.gz
LIBUBOX_DIR=libubox-$(LIBUBOX_VERSION)
LIBUBOX_UNZIP=zcat
LIBUBOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUBOX_DESCRIPTION=Basic utility library
LIBUBOX_SECTION=libs
LIBUBOX_DEPENDS=
LIBBLOBMSG_JSON_DESCRIPTION=blobmsg <-> json conversion library
LIBBLOBMSG_JSON_SECTION=libs
LIBBLOBMSG_JSON_DEPENDS=libjson-c, libubox
JSHN_DESCRIPTION=JSON SHell Notation
JSHN_SECTION=utils
JSHN_DEPENDS=libjson-c, libubox, libblobmsg-json
LIBJSON_SCRIPT_DESCRIPTION=Minimalistic JSON based scripting engine
LIBJSON_SCRIPT_SECTION=utils
LIBJSON_SCRIPT_DEPENDS=libubox
LIBUBOX_LUA_DESCRIPTION=Lua binding for the OpenWrt Basic utility library
LIBUBOX_LUA_SECTION=libs
LIBUBOX_LUA_DEPENDS=libubox, lua
LIBUBOX_PRIORITY=optional
LIBUBOX_SUGGESTS=
LIBUBOX_CONFLICTS=

#
# LIBUBOX_IPK_VERSION should be incremented when the ipk changes.
#
LIBUBOX_IPK_VERSION=1

#
# LIBUBOX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUBOX_PATCHES=\
$(LIBUBOX_SOURCE_DIR)/json-include.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUBOX_CPPFLAGS=
LIBUBOX_LDFLAGS=

#
# LIBUBOX_BUILD_DIR is the directory in which the build is done.
# LIBUBOX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUBOX_IPK_DIR is the directory in which the ipk is built.
# LIBUBOX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUBOX_BUILD_DIR=$(BUILD_DIR)/libubox
LIBUBOX_SOURCE_DIR=$(SOURCE_DIR)/libubox

LIBUBOX_IPK_DIR=$(BUILD_DIR)/libubox-$(LIBUBOX_VERSION)-ipk
LIBUBOX_IPK=$(BUILD_DIR)/libubox_$(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBBLOBMSG_JSON_IPK_DIR=$(BUILD_DIR)/libblobmsg-json-$(LIBUBOX_VERSION)-ipk
LIBBLOBMSG_JSON_IPK=$(BUILD_DIR)/libblobmsg-json_$(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

JSHN_IPK_DIR=$(BUILD_DIR)/jshn-$(LIBUBOX_VERSION)-ipk
JSHN_IPK=$(BUILD_DIR)/jshn_$(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBJSON_SCRIPT_IPK_DIR=$(BUILD_DIR)/libjson-script-$(LIBUBOX_VERSION)-ipk
LIBJSON_SCRIPT_IPK=$(BUILD_DIR)/libjson-script_$(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBUBOX_LUA_IPK_DIR=$(BUILD_DIR)/libubox-lua-$(LIBUBOX_VERSION)-ipk
LIBUBOX_LUA_IPK=$(BUILD_DIR)/libubox-lua_$(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libubox-source libubox-unpack libubox libubox-stage libubox-ipk libubox-clean libubox-dirclean libubox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBUBOX_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBUBOX_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBUBOX_SOURCE).sha512
#
$(DL_DIR)/$(LIBUBOX_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf libubox && \
		git clone --bare $(LIBUBOX_REPOSITORY) libubox && \
		(cd libubox && \
		git archive --format=tar --prefix=$(LIBUBOX_DIR)/ $(LIBUBOX_COMMIT) | gzip > $@) && \
		rm -rf libubox ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libubox-source: $(DL_DIR)/$(LIBUBOX_SOURCE) $(LIBUBOX_PATCHES)

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
$(LIBUBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUBOX_SOURCE) $(LIBUBOX_PATCHES) make/libubox.mk
	$(MAKE) libjson-c-stage lua-stage
	rm -rf $(BUILD_DIR)/$(LIBUBOX_DIR) $(@D)
	$(LIBUBOX_UNZIP) $(DL_DIR)/$(LIBUBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUBOX_PATCHES)" ; \
		then cat $(LIBUBOX_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBUBOX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUBOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUBOX_DIR) $(@D) ; \
	fi
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(LIBUBOX_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(LIBUBOX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(LIBUBOX_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(LIBUBOX_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(LIBUBOX_LDFLAGS)" \
		-DLUAPATH=$(TARGET_PREFIX)/lib/lua
	touch $@

libubox-unpack: $(LIBUBOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUBOX_BUILD_DIR)/.built: $(LIBUBOX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libubox: $(LIBUBOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUBOX_BUILD_DIR)/.staged: $(LIBUBOX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libubox-stage: $(LIBUBOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libubox
#
$(LIBUBOX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libubox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUBOX_PRIORITY)" >>$@
	@echo "Section: $(LIBUBOX_SECTION)" >>$@
	@echo "Version: $(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUBOX_MAINTAINER)" >>$@
	@echo "Source: $(LIBUBOX_REPOSITORY)" >>$@
	@echo "Description: $(LIBUBOX_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUBOX_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUBOX_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUBOX_CONFLICTS)" >>$@

$(LIBBLOBMSG_JSON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libblobmsg-json" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUBOX_PRIORITY)" >>$@
	@echo "Section: $(LIBBLOBMSG_JSON_SECTION)" >>$@
	@echo "Version: $(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUBOX_MAINTAINER)" >>$@
	@echo "Source: $(LIBUBOX_REPOSITORY)" >>$@
	@echo "Description: $(LIBBLOBMSG_JSON_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBBLOBMSG_JSON_DEPENDS)" >>$@
	@echo "Suggests: $(LIBBLOBMSG_JSON_SUGGESTS)" >>$@
	@echo "Conflicts: $LIBBLOBMSG_JSON_CONFLICTS)" >>$@

$(JSHN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: jshn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUBOX_PRIORITY)" >>$@
	@echo "Section: $(JSHN_SECTION)" >>$@
	@echo "Version: $(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUBOX_MAINTAINER)" >>$@
	@echo "Source: $(LIBUBOX_REPOSITORY)" >>$@
	@echo "Description: $(JSHN_DESCRIPTION)" >>$@
	@echo "Depends: $(JSHN_DEPENDS)" >>$@
	@echo "Suggests: $(JSHN_SUGGESTS)" >>$@
	@echo "Conflicts: $(JSHN_CONFLICTS)" >>$@

$(LIBJSON_SCRIPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libjson-script" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUBOX_PRIORITY)" >>$@
	@echo "Section: $(LIBJSON_SCRIPT_SECTION)" >>$@
	@echo "Version: $(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUBOX_MAINTAINER)" >>$@
	@echo "Source: $(LIBUBOX_REPOSITORY)" >>$@
	@echo "Description: $(LIBJSON_SCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBJSON_SCRIPT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBJSON_SCRIPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBJSON_SCRIPT_CONFLICTS)" >>$@

$(LIBUBOX_LUA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libubox-lua" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUBOX_PRIORITY)" >>$@
	@echo "Section: $(LIBUBOX_LUA_SECTION)" >>$@
	@echo "Version: $(LIBUBOX_VERSION)-$(LIBUBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUBOX_MAINTAINER)" >>$@
	@echo "Source: $(LIBUBOX_REPOSITORY)" >>$@
	@echo "Description: $(LIBUBOX_LUA_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUBOX_LUA_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUBOX_LUA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUBOX_LUA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/etc/libubox/...
# Documentation files should be installed in $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/doc/libubox/...
# Daemon startup scripts should be installed in $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libubox
#
# You may need to patch your application to make it use these locations.
#
$(LIBUBOX_IPK): $(LIBUBOX_BUILD_DIR)/.built
	rm -rf $(LIBUBOX_IPK_DIR) $(BUILD_DIR)/libubox_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/libubox.so $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(STRIP_COMMAND) $(LIBUBOX_IPK_DIR)$(TARGET_PREFIX)/lib/libubox.so
	$(MAKE) $(LIBUBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUBOX_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUBOX_IPK_DIR)

$(LIBBLOBMSG_JSON_IPK): $(LIBUBOX_BUILD_DIR)/.built
	rm -rf $(LIBBLOBMSG_JSON_IPK_DIR) $(BUILD_DIR)/libblobmsg-json_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBBLOBMSG_JSON_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/libblobmsg_json.so $(LIBBLOBMSG_JSON_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(STRIP_COMMAND) $(LIBBLOBMSG_JSON_IPK_DIR)$(TARGET_PREFIX)/lib/libblobmsg_json.so
	$(MAKE) $(LIBBLOBMSG_JSON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBBLOBMSG_JSON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBBLOBMSG_JSON_IPK_DIR)

$(JSHN_IPK): $(LIBUBOX_BUILD_DIR)/.built
	rm -rf $(JSHN_IPK_DIR) $(BUILD_DIR)/jshn_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(JSHN_IPK_DIR)$(TARGET_PREFIX)/bin \
			$(JSHN_IPK_DIR)$(TARGET_PREFIX)/share/libubox
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/jshn $(JSHN_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/sh/jshn.sh $(JSHN_IPK_DIR)$(TARGET_PREFIX)/share/libubox
	$(STRIP_COMMAND) $(JSHN_IPK_DIR)$(TARGET_PREFIX)/bin/jshn
	$(MAKE) $(JSHN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JSHN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(JSHN_IPK_DIR)

$(LIBJSON_SCRIPT_IPK): $(LIBUBOX_BUILD_DIR)/.built
	rm -rf $(LIBJSON_SCRIPT_IPK_DIR) $(BUILD_DIR)/libjson-script_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBJSON_SCRIPT_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/libjson_script.so $(LIBJSON_SCRIPT_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(STRIP_COMMAND) $(LIBJSON_SCRIPT_IPK_DIR)$(TARGET_PREFIX)/lib/libjson_script.so
	$(MAKE) $(LIBJSON_SCRIPT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBJSON_SCRIPT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBJSON_SCRIPT_IPK_DIR)

$(LIBUBOX_LUA_IPK): $(LIBUBOX_BUILD_DIR)/.built
	rm -rf $(LIBUBOX_LUA_IPK_DIR) $(BUILD_DIR)/libubox-lua_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBUBOX_LUA_IPK_DIR)$(TARGET_PREFIX)/lib/lua/
	$(INSTALL) -m 755 $(LIBUBOX_BUILD_DIR)/lua/uloop.so $(LIBUBOX_LUA_IPK_DIR)$(TARGET_PREFIX)/lib/lua
	$(STRIP_COMMAND) $(LIBUBOX_LUA_IPK_DIR)$(TARGET_PREFIX)/lib/lua/uloop.so
	$(MAKE) $(LIBUBOX_LUA_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUBOX_LUA_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUBOX_LUA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libubox-ipk: $(LIBUBOX_IPK) $(LIBBLOBMSG_JSON_IPK) $(JSHN_IPK) $(LIBJSON_SCRIPT_IPK) $(LIBUBOX_LUA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libubox-clean:
	rm -f $(LIBUBOX_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUBOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libubox-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUBOX_DIR) $(LIBUBOX_BUILD_DIR) \
		$(LIBUBOX_IPK_DIR) $(LIBUBOX_IPK) \
		$(LIBBLOBMSG_JSON_IPK_DIR) $(LIBBLOBMSG_JSON_IPK) \
		$(JSHN_IPK_DIR) $(JSHN_IPK) \
		$(LIBJSON_SCRIPT_IPK_DIR) $(LIBJSON_SCRIPT_IPK) \
		$(LIBUBOX_LUA_IPK_DIR) $(LIBUBOX_LUA_IPK)
#
#
# Some sanity check for the package.
#
libubox-check: $(LIBUBOX_IPK) $(LIBBLOBMSG_JSON_IPK) $(JSHN_IPK) $(LIBJSON_SCRIPT_IPK) $(LIBUBOX_LUA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
