###########################################################
#
# xinetd
#
###########################################################
#
# $Header$
#

# You must replace "xinetd" and "XINETD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# XINETD_VERSION, XINETD_SITE and XINETD_SOURCE define
# the upstream location of the source code for the package.
# XINETD_DIR is the directory which is created when the source
# archive is unpacked.
# XINETD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XINETD_NAME=xinetd
XINETD_SITE=http://www.xinetd.org/
XINETD_VERSION=2.3.14
XINETD_SOURCE=xinetd-$(XINETD_VERSION).tar.gz
XINETD_DIR=xinetd-$(XINETD_VERSION)
XINETD_UNZIP=zcat
XINETD_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
XINETD_DESCRIPTION=Highly configurable, modular and secure inetd
XINETD_SECTION=net
XINETD_PRIORITY=required
XINETD_DEPENDS=

#
# XINETD_IPK_VERSION should be incremented when the ipk changes.
#
XINETD_IPK_VERSION=8

#
# XINETD_CONFFILES should be a list of user-editable files
# NOTE: telnetd and other xinetd conf files are defined as conf files
#        in order not to overwrite possible changes, like 'disable=yes' 
#        when upgrading.
XINETD_CONFFILES=/opt/etc/xinetd.conf

ifeq ($(OPTWARE_TARGET),nslu2)
XINETD_CONFFILES+=/opt/etc/xinetd.d/telnetd /opt/etc/xinetd.d/ftp-sensor
endif

#
# XINETD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XINETD_PATCHES=$(XINETD_SOURCE_DIR)/xconfig.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XINETD_CPPFLAGS=
XINETD_LDFLAGS=

#
# XINETD_BUILD_DIR is the directory in which the build is done.
# XINETD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XINETD_IPK_DIR is the directory in which the ipk is built.
# XINETD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XINETD_BUILD_DIR=$(BUILD_DIR)/xinetd
XINETD_SOURCE_DIR=$(SOURCE_DIR)/xinetd
XINETD_IPK_DIR=$(BUILD_DIR)/xinetd-$(XINETD_VERSION)-ipk
XINETD_IPK=$(BUILD_DIR)/xinetd_$(XINETD_VERSION)-$(XINETD_IPK_VERSION)_$(TARGET_ARCH).ipk



#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XINETD_SOURCE):
	$(WGET) -P $(@D) $(XINETD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xinetd-source: $(DL_DIR)/$(XINETD_SOURCE) $(XINETD_PATCHES)

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
$(XINETD_BUILD_DIR)/.configured: $(DL_DIR)/$(XINETD_SOURCE) $(XINETD_PATCHES) make/xinetd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(XINETD_DIR) $(@D)
	$(XINETD_UNZIP) $(DL_DIR)/$(XINETD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(XINETD_PATCHES) | patch -d $(BUILD_DIR)/$(XINETD_DIR) -p1
	mv $(BUILD_DIR)/$(XINETD_DIR) $(@D)
	cp -f $(SOURCE_DIR)/common/config.* $(@D)/
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XINETD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XINETD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

xinetd-unpack: $(XINETD_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(XINETD_BUILD_DIR)/.built: $(XINETD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
xinetd: $(XINETD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
# $(STAGING_DIR)/opt/lib/libxinetd.so.$(XINETD_VERSION): $(XINETD_BUILD_DIR)/.built


# xinetd-stage: $(STAGING_DIR)/opt/lib/libxinetd.so.$(XINETD_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xinetd
#
$(XINETD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(XINETD_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XINETD_PRIORITY)" >>$@
	@echo "Section: $(XINETD_SECTION)" >>$@
	@echo "Version: $(XINETD_VERSION)-$(XINETD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XINETD_MAINTAINER)" >>$@
	@echo "Source: $(XINETD_SITE)/$(XINETD_SOURCE)" >>$@
	@echo "Description: $(XINETD_DESCRIPTION)" >>$@
	@echo "Depends: $(XINETD_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XINETD_IPK_DIR)/opt/sbin or $(XINETD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XINETD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XINETD_IPK_DIR)/opt/etc/xinetd/...
# Documentation files should be installed in $(XINETD_IPK_DIR)/opt/doc/xinetd/...
# Daemon startup scripts should be installed in $(XINETD_IPK_DIR)/opt/etc/init.d/S??xinetd
#
# You may need to patch your application to make it use these locations.
#
$(XINETD_IPK): $(XINETD_BUILD_DIR)/.built
	rm -rf $(XINETD_IPK_DIR) $(BUILD_DIR)/xinetd_*_$(TARGET_ARCH).ipk
	# Install daemon, utils and man pages
	$(MAKE) -C $(XINETD_BUILD_DIR) DAEMONDIR=$(XINETD_IPK_DIR)/opt/sbin \
		MANDIR=$(XINETD_IPK_DIR)/opt/man install
	# Strip executables
	$(STRIP_COMMAND) $(XINETD_IPK_DIR)/opt/sbin/xinetd $(XINETD_IPK_DIR)/opt/sbin/itox
	# Install reload utility
	install -m 700 $(XINETD_SOURCE_DIR)/xinetd.reload  $(XINETD_IPK_DIR)/opt/sbin
	# Install config file and create the xinetd.d catalog
	install -d $(XINETD_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(XINETD_SOURCE_DIR)/xinetd.conf $(XINETD_IPK_DIR)/opt/etc
ifeq ($(OPTWARE_TARGET),nslu2)
	# Drop in the telnet and ftp-sensor config
	install -m 644 $(XINETD_SOURCE_DIR)/telnetd $(XINETD_IPK_DIR)/opt/etc/xinetd.d
	install -m 644 $(XINETD_BUILD_DIR)/contrib/xinetd.d/ftp-sensor $(XINETD_IPK_DIR)/opt/etc/xinetd.d
endif
	# Install daemon startup file
	install -d $(XINETD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(XINETD_SOURCE_DIR)/rc.xinetd $(XINETD_IPK_DIR)/opt/etc/init.d/S10xinetd
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/S10xinetd
	$(MAKE) $(XINETD_IPK_DIR)/CONTROL/control
	install -m 755 $(XINETD_SOURCE_DIR)/postinst $(XINETD_IPK_DIR)/CONTROL/
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(XINETD_SOURCE_DIR)/prerm $(XINETD_IPK_DIR)/CONTROL/
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(XINETD_CONFFILES) | sed -e 's/ /\n/g' > $(XINETD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XINETD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xinetd-ipk: $(XINETD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xinetd-clean:
	-$(MAKE) -C $(XINETD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xinetd-dirclean:
	rm -rf $(BUILD_DIR)/$(XINETD_DIR) $(XINETD_BUILD_DIR) $(XINETD_IPK_DIR) $(XINETD_IPK)

#
# Some sanity check for the package.
#
xinetd-check: $(XINETD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(XINETD_IPK)
