###########################################################
#
# tcpdump
#
###########################################################
#
# TCPDUMP_VERSION, TCPDUMP_SITE and TCPDUMP_SOURCE define
# the upstream location of the source code for the package.
# TCPDUMP_DIR is the directory which is created when the source
# archive is unpacked.
# TCPDUMP_UNZIP is the command used to unzip the source.
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
TCPDUMP_SITE=http://www.tcpdump.org/release
TCPDUMP_VERSION=3.9.8
TCPDUMP_SOURCE=tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_DIR=tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_UNZIP=zcat
TCPDUMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TCPDUMP_DESCRIPTION=tcpdump dumps the traffic on a network
TCPDUMP_SECTION=net
TCPDUMP_PRIORITY=optional
TCPDUMP_DEPENDS=libpcap
TCPDUMP_SUGGESTS=
TCPDUMP_CONFLICTS=

#
# TCPDUMP_IPK_VERSION should be incremented when the ipk changes.
#
TCPDUMP_IPK_VERSION=3

#
# TCPDUMP_CONFFILES should be a list of user-editable files
#TCPDUMP_CONFFILES=/opt/etc/tcpdump.conf /opt/etc/init.d/SXXtcpdump

#
# TCPDUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TCPDUMP_PATCHES=$(TCPDUMP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TCPDUMP_CPPFLAGS=
TCPDUMP_LDFLAGS=

#
# TCPDUMP_BUILD_DIR is the directory in which the build is done.
# TCPDUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TCPDUMP_IPK_DIR is the directory in which the ipk is built.
# TCPDUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TCPDUMP_BUILD_DIR=$(BUILD_DIR)/tcpdump
TCPDUMP_SOURCE_DIR=$(SOURCE_DIR)/tcpdump
TCPDUMP_IPK_DIR=$(BUILD_DIR)/tcpdump-$(TCPDUMP_VERSION)-ipk
TCPDUMP_IPK=$(BUILD_DIR)/tcpdump_$(TCPDUMP_VERSION)-$(TCPDUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tcpdump-source tcpdump-unpack tcpdump tcpdump-stage tcpdump-ipk tcpdump-clean tcpdump-dirclean tcpdump-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TCPDUMP_SOURCE):
	$(WGET) -P $(@D) $(TCPDUMP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tcpdump-source: $(DL_DIR)/$(TCPDUMP_SOURCE) $(TCPDUMP_PATCHES)

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
$(TCPDUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(TCPDUMP_SOURCE) $(TCPDUMP_PATCHES) make/tcpdump.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(TCPDUMP_DIR) $(@D)
	$(TCPDUMP_UNZIP) $(DL_DIR)/$(TCPDUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TCPDUMP_PATCHES)" ; \
		then cat $(TCPDUMP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TCPDUMP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TCPDUMP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TCPDUMP_DIR) $(@D) ; \
	fi
	sed -i -e 's/ @V_\(PCAPDEP\|INCLS\)@//' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TCPDUMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TCPDUMP_LDFLAGS)" \
		ac_cv_linux_vers=2 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-smb \
		--without-crypto \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

tcpdump-unpack: $(TCPDUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TCPDUMP_BUILD_DIR)/.built: $(TCPDUMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LIBS=-lpcap INCLS=-I.
	touch $@

#
# This is the build convenience target.
#
tcpdump: $(TCPDUMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TCPDUMP_BUILD_DIR)/.staged: $(TCPDUMP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tcpdump-stage: $(TCPDUMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tcpdump
#
$(TCPDUMP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tcpdump" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TCPDUMP_PRIORITY)" >>$@
	@echo "Section: $(TCPDUMP_SECTION)" >>$@
	@echo "Version: $(TCPDUMP_VERSION)-$(TCPDUMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TCPDUMP_MAINTAINER)" >>$@
	@echo "Source: $(TCPDUMP_SITE)/$(TCPDUMP_SOURCE)" >>$@
	@echo "Description: $(TCPDUMP_DESCRIPTION)" >>$@
	@echo "Depends: $(TCPDUMP_DEPENDS)" >>$@
	@echo "Suggests: $(TCPDUMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(TCPDUMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TCPDUMP_IPK_DIR)/opt/sbin or $(TCPDUMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TCPDUMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TCPDUMP_IPK_DIR)/opt/etc/tcpdump/...
# Documentation files should be installed in $(TCPDUMP_IPK_DIR)/opt/doc/tcpdump/...
# Daemon startup scripts should be installed in $(TCPDUMP_IPK_DIR)/opt/etc/init.d/S??tcpdump
#
# You may need to patch your application to make it use these locations.
#
$(TCPDUMP_IPK): $(TCPDUMP_BUILD_DIR)/.built
	rm -rf $(TCPDUMP_IPK_DIR) $(BUILD_DIR)/tcpdump_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TCPDUMP_BUILD_DIR) DESTDIR=$(TCPDUMP_IPK_DIR) install
	$(STRIP_COMMAND) $(TCPDUMP_IPK_DIR)/opt/sbin/tcpdump
#	install -d $(TCPDUMP_IPK_DIR)/opt/etc/
#	install -m 644 $(TCPDUMP_SOURCE_DIR)/tcpdump.conf $(TCPDUMP_IPK_DIR)/opt/etc/tcpdump.conf
#	install -d $(TCPDUMP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TCPDUMP_SOURCE_DIR)/rc.tcpdump $(TCPDUMP_IPK_DIR)/opt/etc/init.d/SXXtcpdump
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPDUMP_IPK_DIR)/opt/etc/init.d/SXXtcpdump
	$(MAKE) $(TCPDUMP_IPK_DIR)/CONTROL/control
#	install -m 755 $(TCPDUMP_SOURCE_DIR)/postinst $(TCPDUMP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPDUMP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TCPDUMP_SOURCE_DIR)/prerm $(TCPDUMP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TCPDUMP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(TCPDUMP_IPK_DIR)/CONTROL/postinst $(TCPDUMP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(TCPDUMP_CONFFILES) | sed -e 's/ /\n/g' > $(TCPDUMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCPDUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tcpdump-ipk: $(TCPDUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tcpdump-clean:
	rm -f $(TCPDUMP_BUILD_DIR)/.built
	-$(MAKE) -C $(TCPDUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tcpdump-dirclean:
	rm -rf $(BUILD_DIR)/$(TCPDUMP_DIR) $(TCPDUMP_BUILD_DIR) $(TCPDUMP_IPK_DIR) $(TCPDUMP_IPK)
#
#
# Some sanity check for the package.
#
tcpdump-check: $(TCPDUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
