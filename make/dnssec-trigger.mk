###########################################################
#
# dnssec-trigger
#
###########################################################

# You must replace "dnssec-trigger" and "DNSSEC-TRIGGER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DNSSEC-TRIGGER_VERSION, DNSSEC-TRIGGER_SITE and DNSSEC-TRIGGER_SOURCE define
# the upstream location of the source code for the package.
# DNSSEC-TRIGGER_DIR is the directory which is created when the source
# archive is unpacked.
# DNSSEC-TRIGGER_UNZIP is the command used to unzip the source.
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
DNSSEC-TRIGGER_SITE=http://nlnetlabs.nl/downloads/dnssec-trigger/
DNSSEC-TRIGGER_VERSION=0.10
DNSSEC-TRIGGER_SOURCE=dnssec-trigger-$(DNSSEC-TRIGGER_VERSION).tar.gz
DNSSEC-TRIGGER_DIR=dnssec-trigger-$(DNSSEC-TRIGGER_VERSION)
DNSSEC-TRIGGER_UNZIP=zcat
DNSSEC-TRIGGER_MAINTAINER=Bob Novas <bob@shinkuro.com>
DNSSEC-TRIGGER_DESCRIPTION=dnssec-trigger configures a local copy of unbound DNS server to use security aware resolvers.
DNSSEC-TRIGGER_SECTION=net
DNSSEC-TRIGGER_PRIORITY=optional
DNSSEC-TRIGGER_DEPENDS=
DNSSEC-TRIGGER_SUGGESTS=
DNSSEC-TRIGGER_CONFLICTS=

#
# DNSSEC-TRIGGER_IPK_VERSION should be incremented when the ipk changes.
#
DNSSEC-TRIGGER_IPK_VERSION=1

#
# DNSSEC-TRIGGER_CONFFILES should be a list of user-editable files
#DNSSEC-TRIGGER_CONFFILES=/opt/etc/dnssec-trigger.conf /opt/etc/init.d/SXXdnssec-trigger

#
# DNSSEC-TRIGGER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DNSSEC-TRIGGER_PATCHES=$(DNSSEC-TRIGGER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DNSSEC-TRIGGER_CPPFLAGS=
DNSSEC-TRIGGER_LDFLAGS=

#
# DNSSEC-TRIGGER_BUILD_DIR is the directory in which the build is done.
# DNSSEC-TRIGGER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DNSSEC-TRIGGER_IPK_DIR is the directory in which the ipk is built.
# DNSSEC-TRIGGER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DNSSEC-TRIGGER_BUILD_DIR=$(BUILD_DIR)/dnssec-trigger
DNSSEC-TRIGGER_SOURCE_DIR=$(SOURCE_DIR)/dnssec-trigger
DNSSEC-TRIGGER_IPK_DIR=$(BUILD_DIR)/dnssec-trigger-$(DNSSEC-TRIGGER_VERSION)-ipk
DNSSEC-TRIGGER_IPK=$(BUILD_DIR)/dnssec-trigger_$(DNSSEC-TRIGGER_VERSION)-$(DNSSEC-TRIGGER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dnssec-trigger-source dnssec-trigger-unpack dnssec-trigger dnssec-trigger-stage dnssec-trigger-ipk dnssec-trigger-clean dnssec-trigger-dirclean dnssec-trigger-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DNSSEC-TRIGGER_SOURCE):
	$(WGET) -P $(@D) $(DNSSEC-TRIGGER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dnssec-trigger-source: $(DL_DIR)/$(DNSSEC-TRIGGER_SOURCE) $(DNSSEC-TRIGGER_PATCHES)

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
$(DNSSEC-TRIGGER_BUILD_DIR)/.configured: $(DL_DIR)/$(DNSSEC-TRIGGER_SOURCE) $(DNSSEC-TRIGGER_PATCHES) make/dnssec-trigger.mk
	rm -rf $(BUILD_DIR)/$(DNSSEC-TRIGGER_DIR) $(@D)
	$(DNSSEC-TRIGGER_UNZIP) $(DL_DIR)/$(DNSSEC-TRIGGER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DNSSEC-TRIGGER_PATCHES)" ; \
		then cat $(DNSSEC-TRIGGER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DNSSEC-TRIGGER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DNSSEC-TRIGGER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DNSSEC-TRIGGER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DNSSEC-TRIGGER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DNSSEC-TRIGGER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-gui=bla \
	)
	#$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

dnssec-trigger-unpack: $(DNSSEC-TRIGGER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DNSSEC-TRIGGER_BUILD_DIR)/.built: $(DNSSEC-TRIGGER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dnssec-trigger: $(DNSSEC-TRIGGER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DNSSEC-TRIGGER_BUILD_DIR)/.staged: $(DNSSEC-TRIGGER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

dnssec-trigger-stage: $(DNSSEC-TRIGGER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dnssec-trigger
#
$(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dnssec-trigger" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DNSSEC-TRIGGER_PRIORITY)" >>$@
	@echo "Section: $(DNSSEC-TRIGGER_SECTION)" >>$@
	@echo "Version: $(DNSSEC-TRIGGER_VERSION)-$(DNSSEC-TRIGGER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DNSSEC-TRIGGER_MAINTAINER)" >>$@
	@echo "Source: $(DNSSEC-TRIGGER_SITE)/$(DNSSEC-TRIGGER_SOURCE)" >>$@
	@echo "Description: $(DNSSEC-TRIGGER_DESCRIPTION)" >>$@
	@echo "Depends: $(DNSSEC-TRIGGER_DEPENDS)" >>$@
	@echo "Suggests: $(DNSSEC-TRIGGER_SUGGESTS)" >>$@
	@echo "Conflicts: $(DNSSEC-TRIGGER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DNSSEC-TRIGGER_IPK_DIR)/opt/sbin or $(DNSSEC-TRIGGER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DNSSEC-TRIGGER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/dnssec-trigger/...
# Documentation files should be installed in $(DNSSEC-TRIGGER_IPK_DIR)/opt/doc/dnssec-trigger/...
# Daemon startup scripts should be installed in $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/init.d/S??dnssec-trigger
#
# You may need to patch your application to make it use these locations.
#
$(DNSSEC-TRIGGER_IPK): $(DNSSEC-TRIGGER_BUILD_DIR)/.built
	rm -rf $(DNSSEC-TRIGGER_IPK_DIR) $(BUILD_DIR)/dnssec-trigger_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DNSSEC-TRIGGER_BUILD_DIR) DESTDIR=$(DNSSEC-TRIGGER_IPK_DIR) install
	install -d $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/
	install -m 644 $(DNSSEC-TRIGGER_BUILD_DIR)/example.conf $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/dnssec-trigger.conf
	$(STRIP_COMMAND) \
		$(DNSSEC-TRIGGER_IPK_DIR)/opt/sbin/dnssec-trigger-control \
		$(DNSSEC-TRIGGER_IPK_DIR)/opt/sbin/dnssec-triggerd
#	install -m 755 $(DNSSEC-TRIGGER_SOURCE_DIR)/rc.dnssec-trigger $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/init.d/SXXdnssec-trigger
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSSEC-TRIGGER_IPK_DIR)/opt/etc/init.d/SXXdnssec-trigger
	$(MAKE) $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/control
#	install -m 755 $(DNSSEC-TRIGGER_SOURCE_DIR)/postinst $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DNSSEC-TRIGGER_SOURCE_DIR)/prerm $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/postinst $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DNSSEC-TRIGGER_CONFFILES) | sed -e 's/ /\n/g' > $(DNSSEC-TRIGGER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSSEC-TRIGGER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DNSSEC-TRIGGER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dnssec-trigger-ipk: $(DNSSEC-TRIGGER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dnssec-trigger-clean:
	rm -f $(DNSSEC-TRIGGER_BUILD_DIR)/.built
	-$(MAKE) -C $(DNSSEC-TRIGGER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dnssec-trigger-dirclean:
	rm -rf $(BUILD_DIR)/$(DNSSEC-TRIGGER_DIR) $(DNSSEC-TRIGGER_BUILD_DIR) $(DNSSEC-TRIGGER_IPK_DIR) $(DNSSEC-TRIGGER_IPK)
#
#
# Some sanity check for the package.
#
dnssec-trigger-check: $(DNSSEC-TRIGGER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
