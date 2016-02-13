###########################################################
#
# sysstat
#
###########################################################

# You must replace "sysstat" and "SYSSTAT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SYSSTAT_VERSION, SYSSTAT_SITE and SYSSTAT_SOURCE define
# the upstream location of the source code for the package.
# SYSSTAT_DIR is the directory which is created when the source
# archive is unpacked.
# SYSSTAT_UNZIP is the command used to unzip the source.
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
SYSSTAT_SITE=http://perso.orange.fr/sebastien.godard
#ftp://ibiblio.org/pub/linux/system/status
SYSSTAT_VERSION=9.0.3
SYSSTAT_SOURCE=sysstat-$(SYSSTAT_VERSION).tar.bz2
SYSSTAT_DIR=sysstat-$(SYSSTAT_VERSION)
SYSSTAT_UNZIP=bzcat
SYSSTAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SYSSTAT_DESCRIPTION=System performance tools for linux os
SYSSTAT_SECTION=admin
SYSSTAT_PRIORITY=optional
SYSSTAT_DEPENDS=
SYSSTAT_SUGGESTS=
SYSSTAT_CONFLICTS=

#
# SYSSTAT_IPK_VERSION should be incremented when the ipk changes.
#
SYSSTAT_IPK_VERSION=2

#
# SYSSTAT_CONFFILES should be a list of user-editable files
SYSSTAT_CONFFILES=

#
# SYSSTAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SYSSTAT_PATCHES=$(SYSSTAT_SOURCE_DIR)/common.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SYSSTAT_CPPFLAGS=
SYSSTAT_LDFLAGS=

#
# SYSSTAT_BUILD_DIR is the directory in which the build is done.
# SYSSTAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SYSSTAT_IPK_DIR is the directory in which the ipk is built.
# SYSSTAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SYSSTAT_BUILD_DIR=$(BUILD_DIR)/sysstat
SYSSTAT_SOURCE_DIR=$(SOURCE_DIR)/sysstat
SYSSTAT_IPK_DIR=$(BUILD_DIR)/sysstat-$(SYSSTAT_VERSION)-ipk
SYSSTAT_IPK=$(BUILD_DIR)/sysstat_$(SYSSTAT_VERSION)-$(SYSSTAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sysstat-source sysstat-unpack sysstat sysstat-stage sysstat-ipk sysstat-clean sysstat-dirclean sysstat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SYSSTAT_SOURCE):
	$(WGET) -P $(@D) $(SYSSTAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sysstat-source: $(DL_DIR)/$(SYSSTAT_SOURCE) $(SYSSTAT_PATCHES)

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
$(SYSSTAT_BUILD_DIR)/.configured: $(DL_DIR)/$(SYSSTAT_SOURCE) $(SYSSTAT_PATCHES) make/sysstat.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SYSSTAT_DIR) $(@D)
	$(SYSSTAT_UNZIP) $(DL_DIR)/$(SYSSTAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(SYSSTAT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SYSSTAT_DIR) -p1
	mv $(BUILD_DIR)/$(SYSSTAT_DIR) $(@D)
#	$(INSTALL) -m 644 $(SYSSTAT_SOURCE_DIR)/CONFIG $(@D)/build
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYSSTAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYSSTAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--sysconfdir=$(TARGET_PREFIX)/etc \
		--localstatedir=$(TARGET_PREFIX)/var \
		--disable-nls \
		--disable-static \
		)
	touch $@

sysstat-unpack: $(SYSSTAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SYSSTAT_BUILD_DIR)/.built: $(SYSSTAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		RC_DIR=$(TARGET_PREFIX)/etc \
		SYSCONFIG_DIR=$(TARGET_PREFIX)/etc/sysconfig \
		INIT_DIR=$(TARGET_PREFIX)/etc/init.d \
		SA_DIR=$(TARGET_PREFIX)/var/log/sa \
		LFLAGS="$(STAGING_LDFLAGS) $(SYSSTAT_LDFLAGS) -s" \
		;
	touch $@

#
# This is the build convenience target.
#
sysstat: $(SYSSTAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SYSSTAT_BUILD_DIR)/.staged: $(SYSSTAT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#sysstat-stage: $(SYSSTAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sysstat
#
$(SYSSTAT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: sysstat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SYSSTAT_PRIORITY)" >>$@
	@echo "Section: $(SYSSTAT_SECTION)" >>$@
	@echo "Version: $(SYSSTAT_VERSION)-$(SYSSTAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SYSSTAT_MAINTAINER)" >>$@
	@echo "Source: $(SYSSTAT_SITE)/$(SYSSTAT_SOURCE)" >>$@
	@echo "Description: $(SYSSTAT_DESCRIPTION)" >>$@
	@echo "Depends: $(SYSSTAT_DEPENDS)" >>$@
	@echo "Suggests: $(SYSSTAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SYSSTAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/sysstat/...
# Documentation files should be installed in $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/doc/sysstat/...
# Daemon startup scripts should be installed in $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??sysstat
#
# You may need to patch your application to make it use these locations.
#
$(SYSSTAT_IPK): $(SYSSTAT_BUILD_DIR)/.built
	rm -rf $(SYSSTAT_IPK_DIR) $(BUILD_DIR)/sysstat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SYSSTAT_BUILD_DIR) install \
		DESTDIR=$(SYSSTAT_IPK_DIR) \
		IGNORE_MAN_GROUP=y \
		RC_DIR=$(TARGET_PREFIX)/etc \
		SYSCONFIG_DIR=$(TARGET_PREFIX)/etc/sysconfig \
		INIT_DIR=$(TARGET_PREFIX)/etc/init.d \
		SA_DIR=$(TARGET_PREFIX)/var/log/sa \
		;
#	$(INSTALL) -d $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SYSSTAT_SOURCE_DIR)/sysstat.conf $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/sysstat.conf
	$(INSTALL) -d $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(SYSSTAT_SOURCE_DIR)/rc.sysstat $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S99sysstat
	$(INSTALL) -m 644 $(SYSSTAT_SOURCE_DIR)/sysstat.crond $(SYSSTAT_IPK_DIR)$(TARGET_PREFIX)/share/doc/sysstat-$(SYSSTAT_VERSION)/sysstat.crond
	$(MAKE) $(SYSSTAT_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(SYSSTAT_SOURCE_DIR)/postinst $(SYSSTAT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SYSSTAT_SOURCE_DIR)/prerm $(SYSSTAT_IPK_DIR)/CONTROL/prerm
	echo $(SYSSTAT_CONFFILES) | sed -e 's/ /\n/g' > $(SYSSTAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SYSSTAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sysstat-ipk: $(SYSSTAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sysstat-clean:
	-$(MAKE) -C $(SYSSTAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sysstat-dirclean:
	rm -rf $(BUILD_DIR)/$(SYSSTAT_DIR) $(SYSSTAT_BUILD_DIR) $(SYSSTAT_IPK_DIR) $(SYSSTAT_IPK)

#
# Some sanity check for the package.
#
sysstat-check: $(SYSSTAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
