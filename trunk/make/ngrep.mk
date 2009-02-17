###########################################################
#
# ngrep
#
###########################################################
#
# NGREP_VERSION, NGREP_SITE and NGREP_SOURCE define
# the upstream location of the source code for the package.
# NGREP_DIR is the directory which is created when the source
# archive is unpacked.
# NGREP_UNZIP is the command used to unzip the source.
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
NGREP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ngrep
NGREP_VERSION=1.45
NGREP_SOURCE=ngrep-$(NGREP_VERSION).tar.bz2
NGREP_DIR=ngrep-$(NGREP_VERSION)
NGREP_UNZIP=bzcat
NGREP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NGREP_DESCRIPTION=network grep.
NGREP_SECTION=net
NGREP_PRIORITY=optional
NGREP_DEPENDS=libpcap
NGREP_SUGGESTS=
NGREP_CONFLICTS=

#
# NGREP_IPK_VERSION should be incremented when the ipk changes.
#
NGREP_IPK_VERSION=4

#
# NGREP_CONFFILES should be a list of user-editable files
#NGREP_CONFFILES=/opt/etc/ngrep.conf /opt/etc/init.d/SXXngrep

#
# NGREP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NGREP_PATCHES=$(NGREP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NGREP_CPPFLAGS=
NGREP_LDFLAGS=
ifneq (no,$(IPV6))
NGREP_IPV6=--enable-ipv6
endif

#
# NGREP_BUILD_DIR is the directory in which the build is done.
# NGREP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NGREP_IPK_DIR is the directory in which the ipk is built.
# NGREP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NGREP_BUILD_DIR=$(BUILD_DIR)/ngrep
NGREP_SOURCE_DIR=$(SOURCE_DIR)/ngrep
NGREP_IPK_DIR=$(BUILD_DIR)/ngrep-$(NGREP_VERSION)-ipk
NGREP_IPK=$(BUILD_DIR)/ngrep_$(NGREP_VERSION)-$(NGREP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ngrep-source ngrep-unpack ngrep ngrep-stage ngrep-ipk ngrep-clean ngrep-dirclean ngrep-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NGREP_SOURCE):
	$(WGET) -P $(@D) $(NGREP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ngrep-source: $(DL_DIR)/$(NGREP_SOURCE) $(NGREP_PATCHES)

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
$(NGREP_BUILD_DIR)/.configured: $(DL_DIR)/$(NGREP_SOURCE) $(NGREP_PATCHES) make/ngrep.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(NGREP_DIR) $(@D)
	$(NGREP_UNZIP) $(DL_DIR)/$(NGREP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NGREP_PATCHES)" ; \
		then cat $(NGREP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NGREP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NGREP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NGREP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NGREP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NGREP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-pcap-includes=$(STAGING_INCLUDE_DIR) \
		$(NGREP_IPV6) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ngrep-unpack: $(NGREP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NGREP_BUILD_DIR)/.built: $(NGREP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) MAKEFLAGS=""
	touch $@

#
# This is the build convenience target.
#
ngrep: $(NGREP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NGREP_BUILD_DIR)/.staged: $(NGREP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ngrep-stage: $(NGREP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ngrep
#
$(NGREP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ngrep" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NGREP_PRIORITY)" >>$@
	@echo "Section: $(NGREP_SECTION)" >>$@
	@echo "Version: $(NGREP_VERSION)-$(NGREP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NGREP_MAINTAINER)" >>$@
	@echo "Source: $(NGREP_SITE)/$(NGREP_SOURCE)" >>$@
	@echo "Description: $(NGREP_DESCRIPTION)" >>$@
	@echo "Depends: $(NGREP_DEPENDS)" >>$@
	@echo "Suggests: $(NGREP_SUGGESTS)" >>$@
	@echo "Conflicts: $(NGREP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NGREP_IPK_DIR)/opt/sbin or $(NGREP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NGREP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NGREP_IPK_DIR)/opt/etc/ngrep/...
# Documentation files should be installed in $(NGREP_IPK_DIR)/opt/doc/ngrep/...
# Daemon startup scripts should be installed in $(NGREP_IPK_DIR)/opt/etc/init.d/S??ngrep
#
# You may need to patch your application to make it use these locations.
#
$(NGREP_IPK): $(NGREP_BUILD_DIR)/.built
	rm -rf $(NGREP_IPK_DIR) $(BUILD_DIR)/ngrep_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NGREP_BUILD_DIR) DESTDIR=$(NGREP_IPK_DIR) install
#	install -d $(NGREP_IPK_DIR)/opt/etc/
#	install -m 644 $(NGREP_SOURCE_DIR)/ngrep.conf $(NGREP_IPK_DIR)/opt/etc/ngrep.conf
#	install -d $(NGREP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NGREP_SOURCE_DIR)/rc.ngrep $(NGREP_IPK_DIR)/opt/etc/init.d/SXXngrep
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NGREP_IPK_DIR)/opt/etc/init.d/SXXngrep
	$(MAKE) $(NGREP_IPK_DIR)/CONTROL/control
#	install -m 755 $(NGREP_SOURCE_DIR)/postinst $(NGREP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NGREP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NGREP_SOURCE_DIR)/prerm $(NGREP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NGREP_IPK_DIR)/CONTROL/prerm
	echo $(NGREP_CONFFILES) | sed -e 's/ /\n/g' > $(NGREP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NGREP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ngrep-ipk: $(NGREP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ngrep-clean:
	rm -f $(NGREP_BUILD_DIR)/.built
	-$(MAKE) -C $(NGREP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ngrep-dirclean:
	rm -rf $(BUILD_DIR)/$(NGREP_DIR) $(NGREP_BUILD_DIR) $(NGREP_IPK_DIR) $(NGREP_IPK)
#
#
# Some sanity check for the package.
#
ngrep-check: $(NGREP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
