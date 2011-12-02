###########################################################
#
# znc
#
###########################################################

# You must replace "znc" and "ZNC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ZNC_VERSION, ZNC_SITE and ZNC_SOURCE define
# the upstream location of the source code for the package.
# ZNC_DIR is the directory which is created when the source
# archive is unpacked.
# ZNC_UNZIP is the command used to unzip the source.
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
ZNC_SITE=http://znc.in/releases/
ZNC_VERSION=0.202
ZNC_SOURCE=znc-$(ZNC_VERSION).tar.gz
ZNC_DIR=znc-$(ZNC_VERSION)
ZNC_UNZIP=zcat
ZNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZNC_DESCRIPTION=an advanced IRC bouncer
ZNC_SECTION=net
ZNC_PRIORITY=optional
ZNC_DEPENDS=adduser, c-ares, libgmp, openssl
ZNC_SUGGESTS=
ZNC_CONFLICTS=

#
# ZNC_IPK_VERSION should be incremented when the ipk changes.
#
ZNC_IPK_VERSION=1

#
# ZNC_CONFFILES should be a list of user-editable files
ZNC_CONFFILES=/opt/etc/default/znc /opt/etc/init.d/S91znc

#
# ZNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ZNC_PATCHES=$(ZNC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZNC_CPPFLAGS=
ZNC_LDFLAGS=-s

#
# ZNC_BUILD_DIR is the directory in which the build is done.
# ZNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZNC_IPK_DIR is the directory in which the ipk is built.
# ZNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZNC_BUILD_DIR=$(BUILD_DIR)/znc
ZNC_SOURCE_DIR=$(SOURCE_DIR)/znc
ZNC_IPK_DIR=$(BUILD_DIR)/znc-$(ZNC_VERSION)-ipk
ZNC_IPK=$(BUILD_DIR)/znc_$(ZNC_VERSION)-$(ZNC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: znc-source znc-unpack znc znc-stage znc-ipk znc-clean znc-dirclean znc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ZNC_SOURCE):
	$(WGET) -P $(@D) $(ZNC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
znc-source: $(DL_DIR)/$(ZNC_SOURCE) $(ZNC_PATCHES)

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
$(ZNC_BUILD_DIR)/.configured: $(DL_DIR)/$(ZNC_SOURCE) $(ZNC_PATCHES) make/znc.mk
	$(MAKE) c-ares-stage libgmp-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(ZNC_DIR) $(@D)
	$(ZNC_UNZIP) $(DL_DIR)/$(ZNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZNC_PATCHES)" ; \
		then cat $(ZNC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ZNC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ZNC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ZNC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ZNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ZNC_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(ZNC_CONFIG_ARGS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-c-ares \
		--enable-extra \
		--disable-python \
	)
	touch $@

znc-unpack: $(ZNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZNC_BUILD_DIR)/.built: $(ZNC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
znc: $(ZNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ZNC_BUILD_DIR)/.staged: $(ZNC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

znc-stage: $(ZNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/znc
#
$(ZNC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: znc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZNC_PRIORITY)" >>$@
	@echo "Section: $(ZNC_SECTION)" >>$@
	@echo "Version: $(ZNC_VERSION)-$(ZNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZNC_MAINTAINER)" >>$@
	@echo "Source: $(ZNC_SITE)/$(ZNC_SOURCE)" >>$@
	@echo "Description: $(ZNC_DESCRIPTION)" >>$@
	@echo "Depends: $(ZNC_DEPENDS)" >>$@
	@echo "Suggests: $(ZNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ZNC_IPK_DIR)/opt/sbin or $(ZNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ZNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ZNC_IPK_DIR)/opt/etc/znc/...
# Documentation files should be installed in $(ZNC_IPK_DIR)/opt/doc/znc/...
# Daemon startup scripts should be installed in $(ZNC_IPK_DIR)/opt/etc/init.d/S??znc
#
# You may need to patch your application to make it use these locations.
#
$(ZNC_IPK): $(ZNC_BUILD_DIR)/.built
	rm -rf $(ZNC_IPK_DIR) $(BUILD_DIR)/znc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ZNC_BUILD_DIR) DESTDIR=$(ZNC_IPK_DIR) install
	install -d $(ZNC_IPK_DIR)/opt/etc/init.d
	install -d $(ZNC_IPK_DIR)/opt/etc/default
	install -m 644 $(ZNC_SOURCE_DIR)/znc.default $(ZNC_IPK_DIR)/opt/etc/default/znc
	install -m 755 $(ZNC_SOURCE_DIR)/rc.znc $(ZNC_IPK_DIR)/opt/etc/init.d/S91znc
	$(MAKE) $(ZNC_IPK_DIR)/CONTROL/control
	install -m 755 $(ZNC_SOURCE_DIR)/postinst $(ZNC_IPK_DIR)/CONTROL/postinst
	install -m 755 $(ZNC_SOURCE_DIR)/prerm $(ZNC_IPK_DIR)/CONTROL/prerm
	echo $(ZNC_CONFFILES) | sed -e 's/ /\n/g' > $(ZNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZNC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(ZNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
znc-ipk: $(ZNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
znc-clean:
	rm -f $(ZNC_BUILD_DIR)/.built
	-$(MAKE) -C $(ZNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
znc-dirclean:
	rm -rf $(BUILD_DIR)/$(ZNC_DIR) $(ZNC_BUILD_DIR) $(ZNC_IPK_DIR) $(ZNC_IPK)
#
#
# Some sanity check for the package.
#
znc-check: $(ZNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
