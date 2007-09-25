###########################################################
#
# haserl
#
###########################################################
#
# HASERL_VERSION, HASERL_SITE and HASERL_SOURCE define
# the upstream location of the source code for the package.
# HASERL_DIR is the directory which is created when the source
# archive is unpacked.
# HASERL_UNZIP is the command used to unzip the source.
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
HASERL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/haserl
HASERL_VERSION=0.9.20
HASERL_SOURCE=haserl-$(HASERL_VERSION).tar.gz
HASERL_DIR=haserl-$(HASERL_VERSION)
HASERL_UNZIP=zcat
HASERL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HASERL_DESCRIPTION=Haserl is a small program that uses shell or Lua script to create cgi web scripts.
HASERL_SECTION=web
HASERL_PRIORITY=optional
HASERL_DEPENDS=
HASERL_SUGGESTS=
HASERL_CONFLICTS=

#
# HASERL_IPK_VERSION should be incremented when the ipk changes.
#
HASERL_IPK_VERSION=1

#
# HASERL_CONFFILES should be a list of user-editable files
#HASERL_CONFFILES=/opt/etc/haserl.conf /opt/etc/init.d/SXXhaserl

#
# HASERL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HASERL_PATCHES=$(HASERL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HASERL_CPPFLAGS=
HASERL_LDFLAGS=

#
# HASERL_BUILD_DIR is the directory in which the build is done.
# HASERL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HASERL_IPK_DIR is the directory in which the ipk is built.
# HASERL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HASERL_BUILD_DIR=$(BUILD_DIR)/haserl
HASERL_SOURCE_DIR=$(SOURCE_DIR)/haserl
HASERL_IPK_DIR=$(BUILD_DIR)/haserl-$(HASERL_VERSION)-ipk
HASERL_IPK=$(BUILD_DIR)/haserl_$(HASERL_VERSION)-$(HASERL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: haserl-source haserl-unpack haserl haserl-stage haserl-ipk haserl-clean haserl-dirclean haserl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HASERL_SOURCE):
	$(WGET) -P $(DL_DIR) $(HASERL_SITE)/$(HASERL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(HASERL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
haserl-source: $(DL_DIR)/$(HASERL_SOURCE) $(HASERL_PATCHES)

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
$(HASERL_BUILD_DIR)/.configured: $(DL_DIR)/$(HASERL_SOURCE) $(HASERL_PATCHES) make/haserl.mk
	$(MAKE) lua-stage
	rm -rf $(BUILD_DIR)/$(HASERL_DIR) $(HASERL_BUILD_DIR)
	mkdir -p $(HASERL_BUILD_DIR)
	# with-lua
	$(HASERL_UNZIP) $(DL_DIR)/$(HASERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HASERL_PATCHES)" ; \
		then cat $(HASERL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HASERL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HASERL_DIR)" != "$(HASERL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HASERL_DIR) $(HASERL_BUILD_DIR)/with-lua ; \
	fi
	(cd $(HASERL_BUILD_DIR)/with-lua; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HASERL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HASERL_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-lua \
	)
	# without-lua
	$(HASERL_UNZIP) $(DL_DIR)/$(HASERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HASERL_PATCHES)" ; \
		then cat $(HASERL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HASERL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HASERL_DIR)" != "$(HASERL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HASERL_DIR) $(HASERL_BUILD_DIR)/without-lua ; \
	fi
	(cd $(HASERL_BUILD_DIR)/without-lua; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HASERL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HASERL_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-lua \
	)
#	$(PATCH_LIBTOOL) $(HASERL_BUILD_DIR)/libtool
	touch $@

haserl-unpack: $(HASERL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HASERL_BUILD_DIR)/.built: $(HASERL_BUILD_DIR)/.configured
	rm -f $@
	cd $(HASERL_BUILD_DIR)/with-lua/src; \
		$(HOSTCC) -I$(LUA_HOST_BUILD_DIR)/opt/include \
		-Wl,-E -L$(LUA_HOST_BUILD_DIR)/opt/lib \
		-o lua2c lua2c.c \
		-llua -lm
	if test -f $(HASERL_SOURCE_DIR)/haserl_lualib.inc.$(TARGET_ARCH); then \
		cp $(HASERL_SOURCE_DIR)/haserl_lualib.inc.$(TARGET_ARCH) $(HASERL_BUILD_DIR)/with-lua/src/; \
	fi
	$(MAKE) -C $(HASERL_BUILD_DIR)/with-lua
	$(MAKE) -C $(HASERL_BUILD_DIR)/without-lua
	touch $@

#
# This is the build convenience target.
#
haserl: $(HASERL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HASERL_BUILD_DIR)/.staged: $(HASERL_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(HASERL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

haserl-stage: $(HASERL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/haserl
#
$(HASERL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: haserl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HASERL_PRIORITY)" >>$@
	@echo "Section: $(HASERL_SECTION)" >>$@
	@echo "Version: $(HASERL_VERSION)-$(HASERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HASERL_MAINTAINER)" >>$@
	@echo "Source: $(HASERL_SITE)/$(HASERL_SOURCE)" >>$@
	@echo "Description: $(HASERL_DESCRIPTION)" >>$@
	@echo "Depends: $(HASERL_DEPENDS)" >>$@
	@echo "Suggests: $(HASERL_SUGGESTS)" >>$@
	@echo "Conflicts: $(HASERL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HASERL_IPK_DIR)/opt/sbin or $(HASERL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HASERL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HASERL_IPK_DIR)/opt/etc/haserl/...
# Documentation files should be installed in $(HASERL_IPK_DIR)/opt/doc/haserl/...
# Daemon startup scripts should be installed in $(HASERL_IPK_DIR)/opt/etc/init.d/S??haserl
#
# You may need to patch your application to make it use these locations.
#
$(HASERL_IPK): $(HASERL_BUILD_DIR)/.built
	rm -rf $(HASERL_IPK_DIR) $(BUILD_DIR)/haserl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HASERL_BUILD_DIR)/with-lua DESTDIR=$(HASERL_IPK_DIR) install-strip
	mv $(HASERL_IPK_DIR)/opt/bin/haserl $(HASERL_IPK_DIR)/opt/bin/haserl-with-lua
	install $(HASERL_BUILD_DIR)/without-lua/src/haserl $(HASERL_IPK_DIR)/opt/bin/haserl-without-lua
	$(STRIP_COMMAND) $(HASERL_IPK_DIR)/opt/bin/haserl-without-lua
	cd $(HASERL_IPK_DIR)/opt/bin && ln -sf haserl-without-lua haserl
	$(MAKE) $(HASERL_IPK_DIR)/CONTROL/control
	echo $(HASERL_CONFFILES) | sed -e 's/ /\n/g' > $(HASERL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HASERL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
haserl-ipk: $(HASERL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
haserl-clean:
	rm -f $(HASERL_BUILD_DIR)/.built
	-$(MAKE) -C $(HASERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
haserl-dirclean:
	rm -rf $(BUILD_DIR)/$(HASERL_DIR) $(HASERL_BUILD_DIR) $(HASERL_IPK_DIR) $(HASERL_IPK)
#
#
# Some sanity check for the package.
#
haserl-check: $(HASERL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HASERL_IPK)
