###########################################################
#
# tor
#
###########################################################
#
# TOR_VERSION, TOR_SITE and TOR_SOURCE define
# the upstream location of the source code for the package.
# TOR_DIR is the directory which is created when the source
# archive is unpacked.
# TOR_UNZIP is the command used to unzip the source.
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
TOR_SITE=http://tor.eff.org/dist
TOR_VERSION=0.1.2.17
TOR_SOURCE=tor-$(TOR_VERSION).tar.gz
TOR_DIR=tor-$(TOR_VERSION)
TOR_UNZIP=zcat
TOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TOR_DESCRIPTION=Connection-oriented anonymizing communication service
TOR_SECTION=net
TOR_PRIORITY=optional
TOR_DEPENDS=libevent, openssl, zlib
TOR_SUGGESTS=
TOR_CONFLICTS=

#
# TOR_IPK_VERSION should be incremented when the ipk changes.
#
TOR_IPK_VERSION=1

#
# TOR_CONFFILES should be a list of user-editable files
TOR_CONFFILES=/opt/etc/tor.conf /opt/etc/init.d/SXXtor

#
# TOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TOR_PATCHES=$(TOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TOR_CPPFLAGS=
TOR_LDFLAGS=

#
# TOR_BUILD_DIR is the directory in which the build is done.
# TOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TOR_IPK_DIR is the directory in which the ipk is built.
# TOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TOR_BUILD_DIR=$(BUILD_DIR)/tor
TOR_SOURCE_DIR=$(SOURCE_DIR)/tor
TOR_IPK_DIR=$(BUILD_DIR)/tor-$(TOR_VERSION)-ipk
TOR_IPK=$(BUILD_DIR)/tor_$(TOR_VERSION)-$(TOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tor-source tor-unpack tor tor-stage tor-ipk tor-clean tor-dirclean tor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOR_SITE)/$(TOR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tor-source: $(DL_DIR)/$(TOR_SOURCE) $(TOR_PATCHES)

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
$(TOR_BUILD_DIR)/.configured: $(DL_DIR)/$(TOR_SOURCE) $(TOR_PATCHES) make/tor.mk
	$(MAKE) libevent-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TOR_DIR) $(TOR_BUILD_DIR)
	$(TOR_UNZIP) $(DL_DIR)/$(TOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TOR_PATCHES)" ; \
		then cat $(TOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TOR_DIR)" != "$(TOR_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TOR_DIR) $(TOR_BUILD_DIR) ; \
	fi
	(cd $(TOR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TOR_LDFLAGS)" \
		tor_cv_libevent_linker_option=-levent \
		tor_cv_openssl_linker_option=-lssl \
		tor_cv_null_is_zero=yes \
		tor_cv_unaligned_ok=yes \
		tor_cv_time_t_signed=yes \
		tor_cv_twos_complement=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-libevent-dir=$(STAGING_PREFIX) \
		--with-openssl-dir=$(STAGING_PREFIX) \
	)
#	$(PATCH_LIBTOOL) $(TOR_BUILD_DIR)/libtool
	touch $@

tor-unpack: $(TOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TOR_BUILD_DIR)/.built: $(TOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TOR_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tor: $(TOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TOR_BUILD_DIR)/.staged: $(TOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

tor-stage: $(TOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tor
#
$(TOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TOR_PRIORITY)" >>$@
	@echo "Section: $(TOR_SECTION)" >>$@
	@echo "Version: $(TOR_VERSION)-$(TOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TOR_MAINTAINER)" >>$@
	@echo "Source: $(TOR_SITE)/$(TOR_SOURCE)" >>$@
	@echo "Description: $(TOR_DESCRIPTION)" >>$@
	@echo "Depends: $(TOR_DEPENDS)" >>$@
	@echo "Suggests: $(TOR_SUGGESTS)" >>$@
	@echo "Conflicts: $(TOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TOR_IPK_DIR)/opt/sbin or $(TOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TOR_IPK_DIR)/opt/etc/tor/...
# Documentation files should be installed in $(TOR_IPK_DIR)/opt/doc/tor/...
# Daemon startup scripts should be installed in $(TOR_IPK_DIR)/opt/etc/init.d/S??tor
#
# You may need to patch your application to make it use these locations.
#
$(TOR_IPK): $(TOR_BUILD_DIR)/.built
	rm -rf $(TOR_IPK_DIR) $(BUILD_DIR)/tor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TOR_BUILD_DIR) DESTDIR=$(TOR_IPK_DIR) install
	$(TARGET_STRIP) $(TOR_IPK_DIR)/opt/bin/tor
	$(TARGET_STRIP) $(TOR_IPK_DIR)/opt/bin/tor-resolve
	install -d $(TOR_IPK_DIR)/opt/etc/tor
#	install -m 644 $(TOR_SOURCE_DIR)/tor.conf $(TOR_IPK_DIR)/opt/etc/tor.conf
#	install -d $(TOR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TOR_SOURCE_DIR)/rc.tor $(TOR_IPK_DIR)/opt/etc/init.d/SXXtor
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXtor
	$(MAKE) $(TOR_IPK_DIR)/CONTROL/control
#	install -m 755 $(TOR_SOURCE_DIR)/postinst $(TOR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TOR_SOURCE_DIR)/prerm $(TOR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(TOR_CONFFILES) | sed -e 's/ /\n/g' > $(TOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tor-ipk: $(TOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tor-clean:
	rm -f $(TOR_BUILD_DIR)/.built
	-$(MAKE) -C $(TOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tor-dirclean:
	rm -rf $(BUILD_DIR)/$(TOR_DIR) $(TOR_BUILD_DIR) $(TOR_IPK_DIR) $(TOR_IPK)
#
#
# Some sanity check for the package.
#
tor-check: $(TOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TOR_IPK)
