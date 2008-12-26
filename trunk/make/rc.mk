###########################################################
#
# rc
#
###########################################################
#
# RC_VERSION, RC_SITE and RC_SOURCE define
# the upstream location of the source code for the package.
# RC_DIR is the directory which is created when the source
# archive is unpacked.
# RC_UNZIP is the command used to unzip the source.
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
RC_SITE=ftp://rc.quanstro.net/pub
RC_VERSION=1.7.2
RC_SOURCE=rc-$(RC_VERSION).tbz
RC_DIR=rc-$(RC_VERSION)
RC_UNZIP=bzcat
RC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RC_DESCRIPTION=A port of the AT&T Plan 9 shell.
RC_SECTION=shell
RC_PRIORITY=optional
RC_DEPENDS=
RC_SUGGESTS=
RC_CONFLICTS=

#
# RC_IPK_VERSION should be incremented when the ipk changes.
#
RC_IPK_VERSION=1

#
# RC_CONFFILES should be a list of user-editable files
#RC_CONFFILES=/opt/etc/rc.conf /opt/etc/init.d/SXXrc

#
# RC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RC_PATCHES=$(RC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RC_CPPFLAGS=
RC_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
RC_CONFIGURE_ENV=ac_cv_func_setpgrp_void=yes
else
RC_CONFIGURE_ENV=
endif

#
# RC_BUILD_DIR is the directory in which the build is done.
# RC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RC_IPK_DIR is the directory in which the ipk is built.
# RC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RC_BUILD_DIR=$(BUILD_DIR)/rc
RC_SOURCE_DIR=$(SOURCE_DIR)/rc
RC_IPK_DIR=$(BUILD_DIR)/rc-$(RC_VERSION)-ipk
RC_IPK=$(BUILD_DIR)/rc_$(RC_VERSION)-$(RC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rc-source rc-unpack rc rc-stage rc-ipk rc-clean rc-dirclean rc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RC_SOURCE):
	$(WGET) -P $(@D) $(RC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rc-source: $(DL_DIR)/$(RC_SOURCE) $(RC_PATCHES)

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
$(RC_BUILD_DIR)/.configured: $(DL_DIR)/$(RC_SOURCE) $(RC_PATCHES) make/rc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RC_DIR) $(RC_BUILD_DIR)
	$(RC_UNZIP) $(DL_DIR)/$(RC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RC_PATCHES)" ; \
		then cat $(RC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RC_LDFLAGS)" \
		$(RC_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RC_BUILD_DIR)/libtool
	touch $@

rc-unpack: $(RC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RC_BUILD_DIR)/.built: $(RC_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(@D) mksignal mkstatval CC=$(HOSTCC) CPPFLAGS="" LDFLAGS=""
endif
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
rc: $(RC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(RC_BUILD_DIR)/.staged: $(RC_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#rc-stage: $(RC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rc
#
$(RC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RC_PRIORITY)" >>$@
	@echo "Section: $(RC_SECTION)" >>$@
	@echo "Version: $(RC_VERSION)-$(RC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RC_MAINTAINER)" >>$@
	@echo "Source: $(RC_SITE)/$(RC_SOURCE)" >>$@
	@echo "Description: $(RC_DESCRIPTION)" >>$@
	@echo "Depends: $(RC_DEPENDS)" >>$@
	@echo "Suggests: $(RC_SUGGESTS)" >>$@
	@echo "Conflicts: $(RC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RC_IPK_DIR)/opt/sbin or $(RC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RC_IPK_DIR)/opt/etc/rc/...
# Documentation files should be installed in $(RC_IPK_DIR)/opt/doc/rc/...
# Daemon startup scripts should be installed in $(RC_IPK_DIR)/opt/etc/init.d/S??rc
#
# You may need to patch your application to make it use these locations.
#
$(RC_IPK): $(RC_BUILD_DIR)/.built
	rm -rf $(RC_IPK_DIR) $(BUILD_DIR)/rc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RC_BUILD_DIR) DESTDIR=$(RC_IPK_DIR) install-strip
#	install -d $(RC_IPK_DIR)/opt/etc/
#	install -m 644 $(RC_SOURCE_DIR)/rc.conf $(RC_IPK_DIR)/opt/etc/rc.conf
#	install -d $(RC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RC_SOURCE_DIR)/rc.rc $(RC_IPK_DIR)/opt/etc/init.d/SXXrc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXrc
	$(MAKE) $(RC_IPK_DIR)/CONTROL/control
#	install -m 755 $(RC_SOURCE_DIR)/postinst $(RC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RC_SOURCE_DIR)/prerm $(RC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(RC_CONFFILES) | sed -e 's/ /\n/g' > $(RC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rc-ipk: $(RC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rc-clean:
	rm -f $(RC_BUILD_DIR)/.built
	-$(MAKE) -C $(RC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rc-dirclean:
	rm -rf $(BUILD_DIR)/$(RC_DIR) $(RC_BUILD_DIR) $(RC_IPK_DIR) $(RC_IPK)
#
#
# Some sanity check for the package.
#
rc-check: $(RC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RC_IPK)
