###########################################################
#
# tcpflow
#
###########################################################
#
# TCPFLOW_VERSION, TCPFLOW_SITE and TCPFLOW_SOURCE define
# the upstream location of the source code for the package.
# TCPFLOW_DIR is the directory which is created when the source
# archive is unpacked.
# TCPFLOW_UNZIP is the command used to unzip the source.
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
TCPFLOW_SITE=http://www.circlemud.org/pub/jelson/tcpflow
TCPFLOW_VERSION=0.21
TCPFLOW_SOURCE=tcpflow-$(TCPFLOW_VERSION).tar.gz
TCPFLOW_DIR=tcpflow-$(TCPFLOW_VERSION)
TCPFLOW_UNZIP=zcat
TCPFLOW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TCPFLOW_DESCRIPTION=tcpflow is a program that captures data transmitted as part of TCP connections (flows), and stores the data in a way that is convenient for protocol analysis or debugging.
TCPFLOW_SECTION=net
TCPFLOW_PRIORITY=optional
TCPFLOW_DEPENDS=
TCPFLOW_SUGGESTS=
TCPFLOW_CONFLICTS=

#
# TCPFLOW_IPK_VERSION should be incremented when the ipk changes.
#
TCPFLOW_IPK_VERSION=1

#
# TCPFLOW_CONFFILES should be a list of user-editable files
#TCPFLOW_CONFFILES=/opt/etc/tcpflow.conf /opt/etc/init.d/SXXtcpflow

#
# TCPFLOW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TCPFLOW_PATCHES=$(TCPFLOW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TCPFLOW_CPPFLAGS=
TCPFLOW_LDFLAGS=

#
# TCPFLOW_BUILD_DIR is the directory in which the build is done.
# TCPFLOW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TCPFLOW_IPK_DIR is the directory in which the ipk is built.
# TCPFLOW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TCPFLOW_BUILD_DIR=$(BUILD_DIR)/tcpflow
TCPFLOW_SOURCE_DIR=$(SOURCE_DIR)/tcpflow
TCPFLOW_IPK_DIR=$(BUILD_DIR)/tcpflow-$(TCPFLOW_VERSION)-ipk
TCPFLOW_IPK=$(BUILD_DIR)/tcpflow_$(TCPFLOW_VERSION)-$(TCPFLOW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tcpflow-source tcpflow-unpack tcpflow tcpflow-stage tcpflow-ipk tcpflow-clean tcpflow-dirclean tcpflow-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TCPFLOW_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCPFLOW_SITE)/$(TCPFLOW_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TCPFLOW_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tcpflow-source: $(DL_DIR)/$(TCPFLOW_SOURCE) $(TCPFLOW_PATCHES)

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
$(TCPFLOW_BUILD_DIR)/.configured: $(DL_DIR)/$(TCPFLOW_SOURCE) $(TCPFLOW_PATCHES) make/tcpflow.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(TCPFLOW_DIR) $(TCPFLOW_BUILD_DIR)
	$(TCPFLOW_UNZIP) $(DL_DIR)/$(TCPFLOW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TCPFLOW_PATCHES)" ; \
		then cat $(TCPFLOW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TCPFLOW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TCPFLOW_DIR)" != "$(TCPFLOW_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TCPFLOW_DIR) $(TCPFLOW_BUILD_DIR) ; \
	fi
	cp $(SOURCE_DIR)/common/config.* $(TCPFLOW_BUILD_DIR)/
	(cd $(TCPFLOW_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TCPFLOW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TCPFLOW_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TCPFLOW_BUILD_DIR)/libtool
	touch $@

tcpflow-unpack: $(TCPFLOW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TCPFLOW_BUILD_DIR)/.built: $(TCPFLOW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TCPFLOW_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tcpflow: $(TCPFLOW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TCPFLOW_BUILD_DIR)/.staged: $(TCPFLOW_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TCPFLOW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

tcpflow-stage: $(TCPFLOW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tcpflow
#
$(TCPFLOW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tcpflow" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TCPFLOW_PRIORITY)" >>$@
	@echo "Section: $(TCPFLOW_SECTION)" >>$@
	@echo "Version: $(TCPFLOW_VERSION)-$(TCPFLOW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TCPFLOW_MAINTAINER)" >>$@
	@echo "Source: $(TCPFLOW_SITE)/$(TCPFLOW_SOURCE)" >>$@
	@echo "Description: $(TCPFLOW_DESCRIPTION)" >>$@
	@echo "Depends: $(TCPFLOW_DEPENDS)" >>$@
	@echo "Suggests: $(TCPFLOW_SUGGESTS)" >>$@
	@echo "Conflicts: $(TCPFLOW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TCPFLOW_IPK_DIR)/opt/sbin or $(TCPFLOW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TCPFLOW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TCPFLOW_IPK_DIR)/opt/etc/tcpflow/...
# Documentation files should be installed in $(TCPFLOW_IPK_DIR)/opt/doc/tcpflow/...
# Daemon startup scripts should be installed in $(TCPFLOW_IPK_DIR)/opt/etc/init.d/S??tcpflow
#
# You may need to patch your application to make it use these locations.
#
$(TCPFLOW_IPK): $(TCPFLOW_BUILD_DIR)/.built
	rm -rf $(TCPFLOW_IPK_DIR) $(BUILD_DIR)/tcpflow_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TCPFLOW_BUILD_DIR) DESTDIR=$(TCPFLOW_IPK_DIR) install
	$(STRIP_COMMAND) $(TCPFLOW_IPK_DIR)/opt/bin/tcpflow
#	install -d $(TCPFLOW_IPK_DIR)/opt/etc/
#	install -m 644 $(TCPFLOW_SOURCE_DIR)/tcpflow.conf $(TCPFLOW_IPK_DIR)/opt/etc/tcpflow.conf
#	install -d $(TCPFLOW_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TCPFLOW_SOURCE_DIR)/rc.tcpflow $(TCPFLOW_IPK_DIR)/opt/etc/init.d/SXXtcpflow
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPFLOW_IPK_DIR)/opt/etc/init.d/SXXtcpflow
	$(MAKE) $(TCPFLOW_IPK_DIR)/CONTROL/control
#	install -m 755 $(TCPFLOW_SOURCE_DIR)/postinst $(TCPFLOW_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPFLOW_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TCPFLOW_SOURCE_DIR)/prerm $(TCPFLOW_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPFLOW_IPK_DIR)/CONTROL/prerm
	echo $(TCPFLOW_CONFFILES) | sed -e 's/ /\n/g' > $(TCPFLOW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCPFLOW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tcpflow-ipk: $(TCPFLOW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tcpflow-clean:
	rm -f $(TCPFLOW_BUILD_DIR)/.built
	-$(MAKE) -C $(TCPFLOW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tcpflow-dirclean:
	rm -rf $(BUILD_DIR)/$(TCPFLOW_DIR) $(TCPFLOW_BUILD_DIR) $(TCPFLOW_IPK_DIR) $(TCPFLOW_IPK)
#
#
# Some sanity check for the package.
#
tcpflow-check: $(TCPFLOW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TCPFLOW_IPK)
