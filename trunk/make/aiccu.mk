###########################################################
#
# aiccu
#
###########################################################
#
# AICCU_VERSION, AICCU_SITE and AICCU_SOURCE define
# the upstream location of the source code for the package.
# AICCU_DIR is the directory which is created when the source
# archive is unpacked.
# AICCU_UNZIP is the command used to unzip the source.
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
AICCU_SITE=http://www.sixxs.net/archive/sixxs/aiccu/unix
AICCU_VERSION=20070115
AICCU_SOURCE=aiccu_$(AICCU_VERSION).tar.gz
AICCU_DIR=aiccu
AICCU_UNZIP=zcat
AICCU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AICCU_DESCRIPTION=Automatic IPv6 Connectivity Client Utility.
AICCU_SECTION=net
AICCU_PRIORITY=optional
ifneq (, $(filter gnutls, $(PACKAGES)))
AICCU_WITH_GNUTLS=HAVE_GNUTLS=yes
endif
AICCU_DEPENDS=$(if $(AICCU_WITH_GNUTLS),gnutls,)
AICCU_SUGGESTS=
AICCU_CONFLICTS=

#
# AICCU_IPK_VERSION should be incremented when the ipk changes.
#
AICCU_IPK_VERSION=2

#
# AICCU_CONFFILES should be a list of user-editable files
AICCU_CONFFILES=/opt/etc/aiccu.conf /opt/etc/init.d/S50aiccu

#
# AICCU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#	patches from openwrt
AICCU_PATCHES=$(wildcard $(AICCU_SOURCE_DIR)/*.patch)


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AICCU_CPPFLAGS=
AICCU_LDFLAGS=

#
# AICCU_BUILD_DIR is the directory in which the build is done.
# AICCU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AICCU_IPK_DIR is the directory in which the ipk is built.
# AICCU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AICCU_BUILD_DIR=$(BUILD_DIR)/aiccu
AICCU_SOURCE_DIR=$(SOURCE_DIR)/aiccu
AICCU_IPK_DIR=$(BUILD_DIR)/aiccu-$(AICCU_VERSION)-ipk
AICCU_IPK=$(BUILD_DIR)/aiccu_$(AICCU_VERSION)-$(AICCU_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: aiccu-source aiccu-unpack aiccu aiccu-stage aiccu-ipk aiccu-clean aiccu-dirclean aiccu-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AICCU_SOURCE):
	$(WGET) -P $(@D) $(AICCU_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
aiccu-source: $(DL_DIR)/$(AICCU_SOURCE) $(AICCU_PATCHES)

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
$(AICCU_BUILD_DIR)/.configured: $(DL_DIR)/$(AICCU_SOURCE) $(AICCU_PATCHES) make/aiccu.mk
ifneq (,$(AICCU_WITH_GNUTLS))
	$(MAKE) gnutls-stage
endif
	rm -rf $(BUILD_DIR)/$(AICCU_DIR) $(@D)
	$(AICCU_UNZIP) $(DL_DIR)/$(AICCU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AICCU_PATCHES)" ; \
		then cat $(AICCU_PATCHES) | \
		patch -d $(BUILD_DIR)/$(AICCU_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(AICCU_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(AICCU_DIR) $(@D) ; \
	fi
	sed -i -e 's|/etc/aiccu.conf|/opt&|' $(@D)/common/aiccu.h $(@D)/doc/HOWTO
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AICCU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AICCU_LDFLAGS)" \
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

aiccu-unpack: $(AICCU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AICCU_BUILD_DIR)/.built: $(AICCU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AICCU_CPPFLAGS)" \
		EXTRA_LDFLAGS="$(STAGING_LDFLAGS) $(AICCU_LDFLAGS)" \
		OS_NAME=Linux \
		dirsbin=/opt/sbin/ \
		dirbin=/opt/bin/ \
		diretc=/opt/etc/ \
		dirdoc=/opt/share/doc/aiccu/ \
		$(AICCU_WITH_GNUTLS) \
		STRIP="$(STRIP_COMMAND)" \
		;
	touch $@

#
# This is the build convenience target.
#
aiccu: $(AICCU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AICCU_BUILD_DIR)/.staged: $(AICCU_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

aiccu-stage: $(AICCU_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/aiccu
#
$(AICCU_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: aiccu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AICCU_PRIORITY)" >>$@
	@echo "Section: $(AICCU_SECTION)" >>$@
	@echo "Version: $(AICCU_VERSION)-$(AICCU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AICCU_MAINTAINER)" >>$@
	@echo "Source: $(AICCU_SITE)/$(AICCU_SOURCE)" >>$@
	@echo "Description: $(AICCU_DESCRIPTION)" >>$@
	@echo "Depends: $(AICCU_DEPENDS)" >>$@
	@echo "Suggests: $(AICCU_SUGGESTS)" >>$@
	@echo "Conflicts: $(AICCU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AICCU_IPK_DIR)/opt/sbin or $(AICCU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AICCU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AICCU_IPK_DIR)/opt/etc/aiccu/...
# Documentation files should be installed in $(AICCU_IPK_DIR)/opt/doc/aiccu/...
# Daemon startup scripts should be installed in $(AICCU_IPK_DIR)/opt/etc/init.d/S??aiccu
#
# You may need to patch your application to make it use these locations.
#
$(AICCU_IPK): $(AICCU_BUILD_DIR)/.built
	rm -rf $(AICCU_IPK_DIR) $(BUILD_DIR)/aiccu_*_$(TARGET_ARCH).ipk
	install -d $(AICCU_IPK_DIR)/opt/etc
	$(MAKE) -C $(AICCU_BUILD_DIR) install \
		DESTDIR=$(AICCU_IPK_DIR) \
		dirsbin=/opt/sbin/ \
		dirbin=/opt/bin/ \
		diretc=/opt/etc/ \
		dirdoc=/opt/share/doc/aiccu/ \
		;
	rm -f $(AICCU_IPK_DIR)/opt/etc/init.d/aiccu
	install -m 755 $(AICCU_SOURCE_DIR)/rc.aiccu $(AICCU_IPK_DIR)/opt/etc/init.d/S50aiccu
	$(MAKE) $(AICCU_IPK_DIR)/CONTROL/control
	echo $(AICCU_CONFFILES) | sed -e 's/ /\n/g' > $(AICCU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AICCU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
aiccu-ipk: $(AICCU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
aiccu-clean:
	rm -f $(AICCU_BUILD_DIR)/.built
	-$(MAKE) -C $(AICCU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
aiccu-dirclean:
	rm -rf $(BUILD_DIR)/$(AICCU_DIR) $(AICCU_BUILD_DIR) $(AICCU_IPK_DIR) $(AICCU_IPK)
#
#
# Some sanity check for the package.
#
aiccu-check: $(AICCU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AICCU_IPK)
