###########################################################
#
# ppp
#
###########################################################

# You must replace "ppp" and "PPP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PPP_VERSION, PPP_SITE and PPP_SOURCE define
# the upstream location of the source code for the package.
# PPP_DIR is the directory which is created when the source
# archive is unpacked.
# PPP_UNZIP is the command used to unzip the source.
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
PPP_SITE=ftp://ftp.samba.org/pub/ppp/
PPP_VERSION=2.4.3
PPP_SOURCE=ppp-$(PPP_VERSION).tar.gz
PPP_DIR=ppp-$(PPP_VERSION)
PPP_UNZIP=zcat
PPP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PPP_DESCRIPTION=PPP is the Point-to-Point Protocol daemon.
PPP_SECTION=net
PPP_PRIORITY=optional
PPP_DEPENDS=
PPP_SUGGESTS=
PPP_CONFLICTS=

#
# PPP_IPK_VERSION should be incremented when the ipk changes.
#
PPP_IPK_VERSION=1

#
# PPP_CONFFILES should be a list of user-editable files
PPP_CONFFILES=/opt/etc/ppp/options

#
# PPP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PPP_PATCHES=$(PPP_SOURCE_DIR)/remove-strip.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PPP_CPPFLAGS=
PPP_LDFLAGS=

#
# PPP_BUILD_DIR is the directory in which the build is done.
# PPP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PPP_IPK_DIR is the directory in which the ipk is built.
# PPP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PPP_BUILD_DIR=$(BUILD_DIR)/ppp
PPP_SOURCE_DIR=$(SOURCE_DIR)/ppp
PPP_IPK_DIR=$(BUILD_DIR)/ppp-$(PPP_VERSION)-ipk
PPP_IPK=$(BUILD_DIR)/ppp_$(PPP_VERSION)-$(PPP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ppp-source ppp-unpack ppp ppp-stage ppp-ipk ppp-clean ppp-dirclean ppp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PPP_SOURCE):
	$(WGET) -P $(@D) $(PPP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ppp-source: $(DL_DIR)/$(PPP_SOURCE) $(PPP_PATCHES)

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
$(PPP_BUILD_DIR)/.configured: $(DL_DIR)/$(PPP_SOURCE) $(PPP_PATCHES) make/ppp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PPP_DIR) $(@D)
	$(PPP_UNZIP) $(DL_DIR)/$(PPP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PPP_PATCHES)" ; \
		then cat $(PPP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PPP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PPP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PPP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PPP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PPP_LDFLAGS)" \
		./configure \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ppp-unpack: $(PPP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PPP_BUILD_DIR)/.built: $(PPP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) ${TARGET_CONFIGURE_OPTS}
	touch $@

#
# This is the build convenience target.
#
ppp: $(PPP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ppp
#
$(PPP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ppp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PPP_PRIORITY)" >>$@
	@echo "Section: $(PPP_SECTION)" >>$@
	@echo "Version: $(PPP_VERSION)-$(PPP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PPP_MAINTAINER)" >>$@
	@echo "Source: $(PPP_SITE)/$(PPP_SOURCE)" >>$@
	@echo "Description: $(PPP_DESCRIPTION)" >>$@
	@echo "Depends: $(PPP_DEPENDS)" >>$@
	@echo "Suggests: $(PPP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PPP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PPP_IPK_DIR)/opt/sbin or $(PPP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PPP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PPP_IPK_DIR)/opt/etc/ppp/...
# Documentation files should be installed in $(PPP_IPK_DIR)/opt/doc/ppp/...
# Daemon startup scripts should be installed in $(PPP_IPK_DIR)/opt/etc/init.d/S??ppp
#
# You may need to patch your application to make it use these locations.
#
$(PPP_IPK): $(PPP_BUILD_DIR)/.built
	rm -rf $(PPP_IPK_DIR) $(BUILD_DIR)/ppp_*_$(TARGET_ARCH).ipk
	install -d $(PPP_IPK_DIR)/opt/sbin/
	install -m 755 $(PPP_BUILD_DIR)/pppd/pppd $(PPP_IPK_DIR)/opt/sbin/pppd
	$(STRIP_COMMAND) $(PPP_IPK_DIR)/opt/sbin/pppd
	install -d $(PPP_IPK_DIR)/opt/etc/ppp
	install -m 644 $(PPP_BUILD_DIR)/etc.ppp/options $(PPP_IPK_DIR)/opt/etc/ppp/options
	$(MAKE) $(PPP_IPK_DIR)/CONTROL/control
	echo $(PPP_CONFFILES) | sed -e 's/ /\n/g' > $(PPP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PPP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ppp-ipk: $(PPP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ppp-clean:
	rm -f $(PPP_BUILD_DIR)/.built
	-$(MAKE) -C $(PPP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ppp-dirclean:
	rm -rf $(BUILD_DIR)/$(PPP_DIR) $(PPP_BUILD_DIR) $(PPP_IPK_DIR) $(PPP_IPK)
#
#
# Some sanity check for the package.
#
ppp-check: $(PPP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PPP_IPK)
