###########################################################
#
# eventlog
#
###########################################################

EVENTLOG_SITE=http://www.balabit.com/downloads/files/syslog-ng/sources/stable/src
EVENTLOG_VERSION=0.2.5
EVENTLOG_SOURCE=eventlog-$(EVENTLOG_VERSION).tar.gz
EVENTLOG_DIR=eventlog-$(EVENTLOG_VERSION)
EVENTLOG_UNZIP=zcat
EVENTLOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EVENTLOG_DESCRIPTION=library needed by syslog-ng
EVENTLOG_SECTION=libs
EVENTLOG_PRIORITY=optional
EVENTLOG_DEPENDS=
EVENTLOG_SUGGESTS=
EVENTLOG_CONFLICTS=

#
# EVENTLOG_IPK_VERSION should be incremented when the ipk changes.
#
EVENTLOG_IPK_VERSION=1

#
# EVENTLOG_CONFFILES should be a list of user-editable files
EVENTLOG_CONFFILES=

#
# EVENTLOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EVENTLOG_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EVENTLOG_CPPFLAGS=
EVENTLOG_LDFLAGS=

#
# EVENTLOG_BUILD_DIR is the directory in which the build is done.
# EVENTLOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EVENTLOG_IPK_DIR is the directory in which the ipk is built.
# EVENTLOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EVENTLOG_BUILD_DIR=$(BUILD_DIR)/eventlog
EVENTLOG_SOURCE_DIR=$(SOURCE_DIR)/eventlog
EVENTLOG_IPK_DIR=$(BUILD_DIR)/eventlog-$(EVENTLOG_VERSION)-ipk
EVENTLOG_IPK=$(BUILD_DIR)/eventlog_$(EVENTLOG_VERSION)-$(EVENTLOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: eventlog-source eventlog-unpack eventlog eventlog-stage eventlog-ipk eventlog-clean eventlog-dirclean eventlog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EVENTLOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(EVENTLOG_SITE)/$(EVENTLOG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(EVENTLOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
eventlog-source: $(DL_DIR)/$(EVENTLOG_SOURCE) $(EVENTLOG_PATCHES)

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
$(EVENTLOG_BUILD_DIR)/.configured: $(DL_DIR)/$(EVENTLOG_SOURCE) $(EVENTLOG_PATCHES) make/eventlog.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(EVENTLOG_DIR) $(EVENTLOG_BUILD_DIR)
	$(EVENTLOG_UNZIP) $(DL_DIR)/$(EVENTLOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EVENTLOG_PATCHES)" ; \
		then cat $(EVENTLOG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EVENTLOG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EVENTLOG_DIR)" != "$(EVENTLOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(EVENTLOG_DIR) $(EVENTLOG_BUILD_DIR) ; \
	fi
	(cd $(EVENTLOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EVENTLOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EVENTLOG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(EVENTLOG_BUILD_DIR)/libtool
	touch $@

eventlog-unpack: $(EVENTLOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EVENTLOG_BUILD_DIR)/.built: $(EVENTLOG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(EVENTLOG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
eventlog: $(EVENTLOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EVENTLOG_BUILD_DIR)/.staged: $(EVENTLOG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(EVENTLOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

eventlog-stage: $(EVENTLOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/eventlog
#
$(EVENTLOG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: eventlog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EVENTLOG_PRIORITY)" >>$@
	@echo "Section: $(EVENTLOG_SECTION)" >>$@
	@echo "Version: $(EVENTLOG_VERSION)-$(EVENTLOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EVENTLOG_MAINTAINER)" >>$@
	@echo "Source: $(EVENTLOG_SITE)/$(EVENTLOG_SOURCE)" >>$@
	@echo "Description: $(EVENTLOG_DESCRIPTION)" >>$@
	@echo "Depends: $(EVENTLOG_DEPENDS)" >>$@
	@echo "Suggests: $(EVENTLOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(EVENTLOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EVENTLOG_IPK_DIR)/opt/sbin or $(EVENTLOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EVENTLOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EVENTLOG_IPK_DIR)/opt/etc/eventlog/...
# Documentation files should be installed in $(EVENTLOG_IPK_DIR)/opt/doc/eventlog/...
# Daemon startup scripts should be installed in $(EVENTLOG_IPK_DIR)/opt/etc/init.d/S??eventlog
#
# You may need to patch your application to make it use these locations.
#
$(EVENTLOG_IPK): $(EVENTLOG_BUILD_DIR)/.built
	rm -rf $(EVENTLOG_IPK_DIR) $(BUILD_DIR)/eventlog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EVENTLOG_BUILD_DIR) DESTDIR=$(EVENTLOG_IPK_DIR) install-strip
	$(MAKE) $(EVENTLOG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EVENTLOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
eventlog-ipk: $(EVENTLOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
eventlog-clean:
	rm -f $(EVENTLOG_BUILD_DIR)/.built
	-$(MAKE) -C $(EVENTLOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
eventlog-dirclean:
	rm -rf $(BUILD_DIR)/$(EVENTLOG_DIR) $(EVENTLOG_BUILD_DIR) $(EVENTLOG_IPK_DIR) $(EVENTLOG_IPK)
#
#
# Some sanity check for the package.
#
eventlog-check: $(EVENTLOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(EVENTLOG_IPK)
