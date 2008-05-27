###########################################################
#
# tz
#
###########################################################
#
# TZ_VERSION, TZ_SITE and TZ_SOURCE define
# the upstream location of the source code for the package.
# TZ_DIR is the directory which is created when the source
# archive is unpacked.
# TZ_UNZIP is the command used to unzip the source.
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
TZ_SITE=ftp://elsie.nci.nih.gov/pub
TZ_CODE_VERSION=2008a
TZ_DATA_VERSION=2008c
TZ_VERSION=$(TZ_DATA_VERSION)
TZ_CODE_SOURCE=tzcode$(TZ_CODE_VERSION).tar.gz
TZ_DATA_SOURCE=tzdata$(TZ_DATA_VERSION).tar.gz
TZ_DIR=tz-$(TZ_VERSION)
TZ_UNZIP=zcat
TZ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TZ_DESCRIPTION=Timezone utilities and data.
TZ_SECTION=sysadmin
TZ_PRIORITY=optional
TZ_DEPENDS=
TZ_SUGGESTS=
TZ_CONFLICTS=

#
# TZ_IPK_VERSION should be incremented when the ipk changes.
#
TZ_IPK_VERSION=1

#
# TZ_CONFFILES should be a list of user-editable files
#TZ_CONFFILES=/opt/etc/tz.conf /opt/etc/init.d/SXXtz

#
# TZ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TZ_PATCHES=$(TZ_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TZ_CPPFLAGS=
TZ_LDFLAGS=

#
# TZ_BUILD_DIR is the directory in which the build is done.
# TZ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TZ_IPK_DIR is the directory in which the ipk is built.
# TZ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TZ_BUILD_DIR=$(BUILD_DIR)/tz
TZ_SOURCE_DIR=$(SOURCE_DIR)/tz

TZ_IPK_DIR=$(BUILD_DIR)/tz-$(TZ_VERSION)-ipk
TZ_IPK=$(BUILD_DIR)/tz_$(TZ_VERSION)-$(TZ_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tz-source tz-unpack tz tz-stage tz-ipk tz-clean tz-dirclean tz-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TZ_CODE_SOURCE):
	$(WGET) -P $(@D) $(TZ_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TZ_DATA_SOURCE):
	$(WGET) -P $(@D) $(TZ_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tz-source: $(DL_DIR)/$(TZ_CODE_SOURCE) $(DL_DIR)/$(TZ_DATA_SOURCE) $(TZ_PATCHES)

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
$(TZ_BUILD_DIR)/.configured: $(DL_DIR)/$(TZ_CODE_SOURCE) $(DL_DIR)/$(TZ_DATA_SOURCE) $(TZ_PATCHES) make/tz.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TZ_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(TZ_DIR)
	$(TZ_UNZIP) $(DL_DIR)/$(TZ_CODE_SOURCE) | tar -C $(BUILD_DIR)/$(TZ_DIR) -xvf -
	$(TZ_UNZIP) $(DL_DIR)/$(TZ_DATA_SOURCE) | tar -C $(BUILD_DIR)/$(TZ_DIR) -xvf -
	if test -n "$(TZ_PATCHES)" ; \
		then cat $(TZ_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TZ_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TZ_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TZ_DIR) $(@D) ; \
	fi
	sed -i -e 's|-l $$(LOCALTIME) ||' \
	       -e '/^TZDIR/s|/etc/|/share/|' \
		$(@D)/Makefile
#	(cd $(TZ_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TZ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TZ_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

tz-unpack: $(TZ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TZ_BUILD_DIR)/.built: $(TZ_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TZ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TZ_LDFLAGS)" \
		cc=$(TARGET_CC) \
		CFLAGS="-DTZDIR=\\\"/opt/share/zoneinfo\\\"" \
		TOPDIR=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
tz: $(TZ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TZ_BUILD_DIR)/.staged: $(TZ_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tz-stage: $(TZ_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tz
#
$(TZ_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tz" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TZ_PRIORITY)" >>$@
	@echo "Section: $(TZ_SECTION)" >>$@
	@echo "Version: $(TZ_VERSION)-$(TZ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TZ_MAINTAINER)" >>$@
	@echo "Source: $(TZ_SITE)/$(TZ_CODE_SOURCE)" >>$@
	@echo "Description: $(TZ_DESCRIPTION)" >>$@
	@echo "Depends: $(TZ_DEPENDS)" >>$@
	@echo "Suggests: $(TZ_SUGGESTS)" >>$@
	@echo "Conflicts: $(TZ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TZ_IPK_DIR)/opt/sbin or $(TZ_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TZ_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TZ_IPK_DIR)/opt/etc/tz/...
# Documentation files should be installed in $(TZ_IPK_DIR)/opt/doc/tz/...
# Daemon startup scripts should be installed in $(TZ_IPK_DIR)/opt/etc/init.d/S??tz
#
# You may need to patch your application to make it use these locations.
#
$(TZ_IPK): $(TZ_BUILD_DIR)/.built
	rm -rf $(TZ_IPK_DIR) $(BUILD_DIR)/tz_*_$(TARGET_ARCH).ipk
	install -d $(TZ_IPK_DIR)/opt/sbin
	$(MAKE) -C $(TZ_BUILD_DIR) TOPDIR=$(TZ_IPK_DIR)/opt install zic=/usr/sbin/zic
	rm -f $(TZ_IPK_DIR)/opt/etc/tzselect $(TZ_IPK_DIR)/opt/man/man8/tzselect.8
	rm -rf $(TZ_IPK_DIR)/opt/lib
	mv $(TZ_IPK_DIR)/opt/etc/zdump \
	   $(TZ_IPK_DIR)/opt/etc/zic \
	   $(TZ_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(TZ_IPK_DIR)/opt/sbin/*
	sed -i -e 's|/usr/local|/opt|g' $(TZ_IPK_DIR)/opt/man/man*/*
#	install -d $(TZ_IPK_DIR)/opt/etc/
#	install -m 644 $(TZ_SOURCE_DIR)/tz.conf $(TZ_IPK_DIR)/opt/etc/tz.conf
#	install -d $(TZ_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TZ_SOURCE_DIR)/rc.tz $(TZ_IPK_DIR)/opt/etc/init.d/SXXtz
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZ_IPK_DIR)/opt/etc/init.d/SXXtz
	$(MAKE) $(TZ_IPK_DIR)/CONTROL/control
#	install -m 755 $(TZ_SOURCE_DIR)/postinst $(TZ_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZ_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TZ_SOURCE_DIR)/prerm $(TZ_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZ_IPK_DIR)/CONTROL/prerm
	echo $(TZ_CONFFILES) | sed -e 's/ /\n/g' > $(TZ_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TZ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tz-ipk: $(TZ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tz-clean:
	rm -f $(TZ_BUILD_DIR)/.built
	-$(MAKE) -C $(TZ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tz-dirclean:
	rm -rf $(BUILD_DIR)/$(TZ_DIR) $(TZ_BUILD_DIR) $(TZ_IPK_DIR) $(TZ_IPK)
#
#
# Some sanity check for the package.
#
tz-check: $(TZ_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TZ_IPK)
