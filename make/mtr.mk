###########################################################
#
# mtr
#
###########################################################
#
# MTR_VERSION, MTR_SITE and MTR_SOURCE define
# the upstream location of the source code for the package.
# MTR_DIR is the directory which is created when the source
# archive is unpacked.
# MTR_UNZIP is the command used to unzip the source.
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
MTR_SITE=ftp://ftp.bitwizard.nl/mtr
MTR_VERSION=0.74
MTR_SOURCE=mtr-$(MTR_VERSION).tar.gz
MTR_DIR=mtr-$(MTR_VERSION)
MTR_UNZIP=zcat
MTR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MTR_DESCRIPTION=mtr combines the functionality of the 'traceroute' and 'ping' programs in a single network diagnostic tool.
MTR_SECTION=net
MTR_PRIORITY=optional
MTR_DEPENDS=ncurses
MTR_SUGGESTS=
MTR_CONFLICTS=

#
# MTR_IPK_VERSION should be incremented when the ipk changes.
#
MTR_IPK_VERSION=1

#
# MTR_CONFFILES should be a list of user-editable files
#MTR_CONFFILES=/opt/etc/mtr.conf /opt/etc/init.d/SXXmtr

#
# MTR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MTR_PATCHES=$(MTR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MTR_CPPFLAGS=
MTR_LDFLAGS=

#
# MTR_BUILD_DIR is the directory in which the build is done.
# MTR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MTR_IPK_DIR is the directory in which the ipk is built.
# MTR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MTR_BUILD_DIR=$(BUILD_DIR)/mtr
MTR_SOURCE_DIR=$(SOURCE_DIR)/mtr
MTR_IPK_DIR=$(BUILD_DIR)/mtr-$(MTR_VERSION)-ipk
MTR_IPK=$(BUILD_DIR)/mtr_$(MTR_VERSION)-$(MTR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mtr-source mtr-unpack mtr mtr-stage mtr-ipk mtr-clean mtr-dirclean mtr-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MTR_SOURCE):
	$(WGET) -P $(@D) $(MTR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mtr-source: $(DL_DIR)/$(MTR_SOURCE) $(MTR_PATCHES)

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
$(MTR_BUILD_DIR)/.configured: $(DL_DIR)/$(MTR_SOURCE) $(MTR_PATCHES) make/mtr.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(MTR_DIR) $(@D)
	$(MTR_UNZIP) $(DL_DIR)/$(MTR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MTR_PATCHES)" ; \
		then cat $(MTR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MTR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MTR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MTR_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MTR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MTR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-gtk \
		--disable-nls \
		--disable-static \
	)
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
		sed -i -e 's|-Wno-pointer-sign||' $(@D)/Makefile; \
	fi
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mtr-unpack: $(MTR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MTR_BUILD_DIR)/.built: $(MTR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MTR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MTR_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
mtr: $(MTR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MTR_BUILD_DIR)/.staged: $(MTR_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#mtr-stage: $(MTR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mtr
#
$(MTR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mtr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MTR_PRIORITY)" >>$@
	@echo "Section: $(MTR_SECTION)" >>$@
	@echo "Version: $(MTR_VERSION)-$(MTR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MTR_MAINTAINER)" >>$@
	@echo "Source: $(MTR_SITE)/$(MTR_SOURCE)" >>$@
	@echo "Description: $(MTR_DESCRIPTION)" >>$@
	@echo "Depends: $(MTR_DEPENDS)" >>$@
	@echo "Suggests: $(MTR_SUGGESTS)" >>$@
	@echo "Conflicts: $(MTR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MTR_IPK_DIR)/opt/sbin or $(MTR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MTR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MTR_IPK_DIR)/opt/etc/mtr/...
# Documentation files should be installed in $(MTR_IPK_DIR)/opt/doc/mtr/...
# Daemon startup scripts should be installed in $(MTR_IPK_DIR)/opt/etc/init.d/S??mtr
#
# You may need to patch your application to make it use these locations.
#
$(MTR_IPK): $(MTR_BUILD_DIR)/.built
	rm -rf $(MTR_IPK_DIR) $(BUILD_DIR)/mtr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MTR_BUILD_DIR) DESTDIR=$(MTR_IPK_DIR) install
	$(STRIP_COMMAND) $(MTR_IPK_DIR)/opt/sbin/mtr
#	install -d $(MTR_IPK_DIR)/opt/etc/
#	install -m 644 $(MTR_SOURCE_DIR)/mtr.conf $(MTR_IPK_DIR)/opt/etc/mtr.conf
#	install -d $(MTR_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MTR_SOURCE_DIR)/rc.mtr $(MTR_IPK_DIR)/opt/etc/init.d/SXXmtr
	$(MAKE) $(MTR_IPK_DIR)/CONTROL/control
#	install -m 755 $(MTR_SOURCE_DIR)/postinst $(MTR_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MTR_SOURCE_DIR)/prerm $(MTR_IPK_DIR)/CONTROL/prerm
	echo $(MTR_CONFFILES) | sed -e 's/ /\n/g' > $(MTR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MTR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mtr-ipk: $(MTR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mtr-clean:
	rm -f $(MTR_BUILD_DIR)/.built
	-$(MAKE) -C $(MTR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mtr-dirclean:
	rm -rf $(BUILD_DIR)/$(MTR_DIR) $(MTR_BUILD_DIR) $(MTR_IPK_DIR) $(MTR_IPK)
#
#
# Some sanity check for the package.
#
mtr-check: $(MTR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MTR_IPK)
