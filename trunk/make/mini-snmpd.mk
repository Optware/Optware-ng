###########################################################
#
# mini-snmpd
#
###########################################################
#
# MINI-SNMPD_VERSION, MINI-SNMPD_SITE and MINI-SNMPD_SOURCE define
# the upstream location of the source code for the package.
# MINI-SNMPD_DIR is the directory which is created when the source
# archive is unpacked.
# MINI-SNMPD_UNZIP is the command used to unzip the source.
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
MINI-SNMPD_SITE=http://members.aon.at/linuxfreak/linux
MINI-SNMPD_VERSION=1.0
MINI-SNMPD_TARBALL=mini_snmpd.tar.gz
MINI-SNMPD_TARBALL_MD5=13f2202ff01ff6b6463989f34f453063
MINI-SNMPD_SOURCE=mini_snmpd-$(MINI-SNMPD_VERSION).tar.gz
MINI-SNMPD_DIR=mini_snmpd
MINI-SNMPD_UNZIP=zcat
MINI-SNMPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINI-SNMPD_DESCRIPTION=SNMP server for embedded systems
MINI-SNMPD_SECTION=net
MINI-SNMPD_PRIORITY=optional
MINI-SNMPD_DEPENDS=
MINI-SNMPD_SUGGESTS=
MINI-SNMPD_CONFLICTS=

#
# MINI-SNMPD_IPK_VERSION should be incremented when the ipk changes.
#
MINI-SNMPD_IPK_VERSION=1

#
# MINI-SNMPD_CONFFILES should be a list of user-editable files
#MINI-SNMPD_CONFFILES=/opt/etc/mini-snmpd.conf /opt/etc/init.d/SXXmini-snmpd

#
# MINI-SNMPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINI-SNMPD_PATCHES=\
$(MINI-SNMPD_SOURCE_DIR)/102-compile_fix.patch \
$(MINI-SNMPD_SOURCE_DIR)/103-mib_encode_snmp_element_oid_fix.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINI-SNMPD_CPPFLAGS=-DSYSLOG
MINI-SNMPD_LDFLAGS=

#
# MINI-SNMPD_BUILD_DIR is the directory in which the build is done.
# MINI-SNMPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINI-SNMPD_IPK_DIR is the directory in which the ipk is built.
# MINI-SNMPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINI-SNMPD_BUILD_DIR=$(BUILD_DIR)/mini-snmpd
MINI-SNMPD_SOURCE_DIR=$(SOURCE_DIR)/mini-snmpd
MINI-SNMPD_IPK_DIR=$(BUILD_DIR)/mini-snmpd-$(MINI-SNMPD_VERSION)-ipk
MINI-SNMPD_IPK=$(BUILD_DIR)/mini-snmpd_$(MINI-SNMPD_VERSION)-$(MINI-SNMPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mini-snmpd-source mini-snmpd-unpack mini-snmpd mini-snmpd-stage mini-snmpd-ipk mini-snmpd-clean mini-snmpd-dirclean mini-snmpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINI-SNMPD_SOURCE):
	rm -f $(@D)/$(MINI-SNMPD_TARBALL) $@
	$(WGET) -P $(@D) $(MINI-SNMPD_SITE)/$(MINI-SNMPD_TARBALL) && \
	[ `md5sum $(@D)/$(MINI-SNMPD_TARBALL) | cut -f1 -d" "` = $(MINI-SNMPD_TARBALL_MD5) ] && \
	mv $(@D)/$(MINI-SNMPD_TARBALL) $@ || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mini-snmpd-source: $(DL_DIR)/$(MINI-SNMPD_SOURCE) $(MINI-SNMPD_PATCHES)

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
$(MINI-SNMPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MINI-SNMPD_SOURCE) $(MINI-SNMPD_PATCHES) make/mini-snmpd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MINI-SNMPD_DIR) $(@D)
	$(MINI-SNMPD_UNZIP) $(DL_DIR)/$(MINI-SNMPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINI-SNMPD_PATCHES)" ; \
		then cat $(MINI-SNMPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MINI-SNMPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MINI-SNMPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINI-SNMPD_DIR) $(@D) ; \
	fi
	sed -i -e 's|-O2|$$(CPPFLAGS)|' $(@D)/Makefile
	touch $@

mini-snmpd-unpack: $(MINI-SNMPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINI-SNMPD_BUILD_DIR)/.built: $(MINI-SNMPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINI-SNMPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINI-SNMPD_LDFLAGS)" \
		mini_snmpd ;
	touch $@

#
# This is the build convenience target.
#
mini-snmpd: $(MINI-SNMPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MINI-SNMPD_BUILD_DIR)/.staged: $(MINI-SNMPD_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#mini-snmpd-stage: $(MINI-SNMPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mini-snmpd
#
$(MINI-SNMPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mini-snmpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINI-SNMPD_PRIORITY)" >>$@
	@echo "Section: $(MINI-SNMPD_SECTION)" >>$@
	@echo "Version: $(MINI-SNMPD_VERSION)-$(MINI-SNMPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINI-SNMPD_MAINTAINER)" >>$@
	@echo "Source: $(MINI-SNMPD_SITE)/$(MINI-SNMPD_SOURCE)" >>$@
	@echo "Description: $(MINI-SNMPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MINI-SNMPD_DEPENDS)" >>$@
	@echo "Suggests: $(MINI-SNMPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINI-SNMPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINI-SNMPD_IPK_DIR)/opt/sbin or $(MINI-SNMPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINI-SNMPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MINI-SNMPD_IPK_DIR)/opt/etc/mini-snmpd/...
# Documentation files should be installed in $(MINI-SNMPD_IPK_DIR)/opt/doc/mini-snmpd/...
# Daemon startup scripts should be installed in $(MINI-SNMPD_IPK_DIR)/opt/etc/init.d/S??mini-snmpd
#
# You may need to patch your application to make it use these locations.
#
$(MINI-SNMPD_IPK): $(MINI-SNMPD_BUILD_DIR)/.built
	rm -rf $(MINI-SNMPD_IPK_DIR) $(BUILD_DIR)/mini-snmpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINI-SNMPD_BUILD_DIR) INSTALL_ROOT=$(MINI-SNMPD_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(MINI-SNMPD_IPK_DIR)/opt/sbin/*
	$(MAKE) $(MINI-SNMPD_IPK_DIR)/CONTROL/control
	echo $(MINI-SNMPD_CONFFILES) | sed -e 's/ /\n/g' > $(MINI-SNMPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINI-SNMPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mini-snmpd-ipk: $(MINI-SNMPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mini-snmpd-clean:
	rm -f $(MINI-SNMPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MINI-SNMPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mini-snmpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MINI-SNMPD_DIR) $(MINI-SNMPD_BUILD_DIR) $(MINI-SNMPD_IPK_DIR) $(MINI-SNMPD_IPK)
#
#
# Some sanity check for the package.
#
mini-snmpd-check: $(MINI-SNMPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
