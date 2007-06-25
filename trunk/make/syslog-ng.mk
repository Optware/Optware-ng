###########################################################
#
# syslog-ng
#
###########################################################

# You must replace "syslog-ng" and "SYSLOG-NG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SYSLOG-NG_VERSION, SYSLOG-NG_SITE and SYSLOG-NG_SOURCE define
# the upstream location of the source code for the package.
# SYSLOG-NG_DIR is the directory which is created when the soucce
# archive is unpacked.
# SYSLOG-NG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SYSLOG-NG_SITE=http://www.balabit.com/downloads/files/syslog-ng/sources/stable/src
SYSLOG-NG_VERSION=2.0.4
SYSLOG-NG_SOURCE=syslog-ng-$(SYSLOG-NG_VERSION).tar.gz
SYSLOG-NG_DIR=syslog-ng-$(SYSLOG-NG_VERSION)
SYSLOG-NG_UNZIP=zcat
SYSLOG-NG_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
SYSLOG-NG_DESCRIPTION=Syslog replacement logging on behalf of remote hosts
SYSLOG-NG_SECTION=sys
SYSLOG-NG_PRIORITY=optional
SYSLOG-NG_DEPENDS=glib, eventlog
SYSLOG-NG_CONFLICTS=

#
# SYSLOG-NG_IPK_VERSION should be incremented when the ipk changes.
#
SYSLOG-NG_IPK_VERSION=1

#
# SYSLOG-NG_CONFFILES should be a list of user-editable files
SYSLOG-NG_CONFFILES=/opt/etc/syslog-ng/syslog-ng.conf

#
# SYSLOG-NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SYSLOG-NG_PATCHES=
#$(SYSLOG-NG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SYSLOG-NG_CPPFLAGS=
SYSLOG-NG_LDFLAGS=

#
# SYSLOG-NG_BUILD_DIR is the directory in which the build is done.
# SYSLOG-NG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SYSLOG-NG_IPK_DIR is the directory in which the ipk is built.
# SYSLOG-NG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SYSLOG-NG_BUILD_DIR=$(BUILD_DIR)/syslog-ng
SYSLOG-NG_SOURCE_DIR=$(SOURCE_DIR)/syslog-ng
SYSLOG-NG_IPK_DIR=$(BUILD_DIR)/syslog-ng-$(SYSLOG-NG_VERSION)-ipk
SYSLOG-NG_IPK=$(BUILD_DIR)/syslog-ng_$(SYSLOG-NG_VERSION)-$(SYSLOG-NG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: syslog-ng-source syslog-ng-unpack syslog-ng syslog-ng-stage syslog-ng-ipk syslog-ng-clean syslog-ng-dirclean syslog-ng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SYSLOG-NG_SOURCE):
	$(WGET) -P $(DL_DIR) $(SYSLOG-NG_SITE)/$(SYSLOG-NG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
syslog-ng-source: $(DL_DIR)/$(SYSLOG-NG_SOURCE) $(SYSLOG-NG_PATCHES)

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
$(SYSLOG-NG_BUILD_DIR)/.configured: $(DL_DIR)/$(SYSLOG-NG_SOURCE) $(SYSLOG-NG_PATCHES) make/syslog-ng.mk
	$(MAKE) glib-stage eventlog-stage libnet10-stage flex-stage
	rm -rf $(BUILD_DIR)/$(SYSLOG-NG_DIR) $(SYSLOG-NG_BUILD_DIR)
	$(SYSLOG-NG_UNZIP) $(DL_DIR)/$(SYSLOG-NG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(SYSLOG-NG_PATCHES) | patch -d $(BUILD_DIR)/$(SYSLOG-NG_DIR) -p1
	mv $(BUILD_DIR)/$(SYSLOG-NG_DIR) $(SYSLOG-NG_BUILD_DIR)
	(cd $(SYSLOG-NG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SYSLOG-NG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SYSLOG-NG_LDFLAGS)" \
                PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
                PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		EVTLOG_CFLAGS="-I$(STAGING_INCLUDE_DIR)/eventlog" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-dynamic-linking \
		--disable-nls \
		--disable-spoof-source \
	)
	touch $(SYSLOG-NG_BUILD_DIR)/.configured

syslog-ng-unpack: $(SYSLOG-NG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SYSLOG-NG_BUILD_DIR)/.built: $(SYSLOG-NG_BUILD_DIR)/.configured
	rm -f $(SYSLOG-NG_BUILD_DIR)/.built
	$(MAKE) -C $(SYSLOG-NG_BUILD_DIR)
	touch $(SYSLOG-NG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
syslog-ng: $(SYSLOG-NG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SYSLOG-NG_BUILD_DIR)/.staged: $(SYSLOG-NG_BUILD_DIR)/.built
	rm -f $(SYSLOG-NG_BUILD_DIR)/.staged
	$(MAKE) -C $(SYSLOG-NG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SYSLOG-NG_BUILD_DIR)/.staged

syslog-ng-stage: $(SYSLOG-NG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/syslog-ng
#
$(SYSLOG-NG_IPK_DIR)/CONTROL/control:
	@install -d $(SYSLOG-NG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: syslog-ng" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SYSLOG-NG_PRIORITY)" >>$@
	@echo "Section: $(SYSLOG-NG_SECTION)" >>$@
	@echo "Version: $(SYSLOG-NG_VERSION)-$(SYSLOG-NG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SYSLOG-NG_MAINTAINER)" >>$@
	@echo "Source: $(SYSLOG-NG_SITE)/$(SYSLOG-NG_SOURCE)" >>$@
	@echo "Description: $(SYSLOG-NG_DESCRIPTION)" >>$@
	@echo "Depends: $(SYSLOG-NG_DEPENDS)" >>$@
	@echo "Conflicts: $(SYSLOG-NG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SYSLOG-NG_IPK_DIR)/opt/sbin or $(SYSLOG-NG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SYSLOG-NG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SYSLOG-NG_IPK_DIR)/opt/etc/syslog-ng/...
# Documentation files should be installed in $(SYSLOG-NG_IPK_DIR)/opt/doc/syslog-ng/...
# Daemon startup scripts should be installed in $(SYSLOG-NG_IPK_DIR)/opt/etc/init.d/S??syslog-ng
#
# You may need to patch your application to make it use these locations.
#
$(SYSLOG-NG_IPK): $(SYSLOG-NG_BUILD_DIR)/.built
	rm -rf $(SYSLOG-NG_IPK_DIR) $(BUILD_DIR)/syslog-ng_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SYSLOG-NG_BUILD_DIR) DESTDIR=$(SYSLOG-NG_IPK_DIR) install
	$(STRIP_COMMAND) $(SYSLOG-NG_IPK_DIR)/opt/sbin/syslog-ng
	install -d $(SYSLOG-NG_IPK_DIR)/opt/etc/syslog-ng
	install -m 644 $(SYSLOG-NG_SOURCE_DIR)/syslog-ng.conf $(SYSLOG-NG_IPK_DIR)/opt/etc/syslog-ng
	install -d $(SYSLOG-NG_IPK_DIR)/opt/doc/syslog-ng
	install -m 755 $(SYSLOG-NG_SOURCE_DIR)/README.optware $(SYSLOG-NG_IPK_DIR)/opt/doc/syslog-ng
	install -d $(SYSLOG-NG_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SYSLOG-NG_SOURCE_DIR)/rc.syslog-ng $(SYSLOG-NG_IPK_DIR)/opt/etc/init.d/S01syslog-ng
	install -d $(SYSLOG-NG_IPK_DIR)/opt/var/log
	$(MAKE) $(SYSLOG-NG_IPK_DIR)/CONTROL/control
	install -m 755 $(SYSLOG-NG_SOURCE_DIR)/postinst $(SYSLOG-NG_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SYSLOG-NG_SOURCE_DIR)/prerm $(SYSLOG-NG_IPK_DIR)/CONTROL/prerm
	echo $(SYSLOG-NG_CONFFILES) | sed -e 's/ /\n/g' > $(SYSLOG-NG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SYSLOG-NG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
syslog-ng-ipk: $(SYSLOG-NG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
syslog-ng-clean:
	-$(MAKE) -C $(SYSLOG-NG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
syslog-ng-dirclean:
	rm -rf $(BUILD_DIR)/$(SYSLOG-NG_DIR) $(SYSLOG-NG_BUILD_DIR) $(SYSLOG-NG_IPK_DIR) $(SYSLOG-NG_IPK)

#
# Some sanity check for the package.
#
syslog-ng-check: $(SYSLOG-NG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SYSLOG-NG_IPK)
