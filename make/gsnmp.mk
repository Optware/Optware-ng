###########################################################
#
# gsnmp
#
###########################################################
#
# GSNMP_VERSION, GSNMP_SITE and GSNMP_SOURCE define
# the upstream location of the source code for the package.
# GSNMP_DIR is the directory which is created when the source
# archive is unpacked.
# GSNMP_UNZIP is the command used to unzip the source.
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
GSNMP_SITE=ftp://ftp.ibr.cs.tu-bs.de/pub/local/gsnmp
GSNMP_VERSION=0.2.0
GSNMP_SOURCE=gsnmp-$(GSNMP_VERSION).tar.gz
GSNMP_DIR=gsnmp-$(GSNMP_VERSION)
GSNMP_UNZIP=zcat
GSNMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GSNMP_DESCRIPTION=SNMP lib.
GSNMP_SECTION=net
GSNMP_PRIORITY=optional
GSNMP_DEPENDS=gnet
GSNMP_SUGGESTS=
GSNMP_CONFLICTS=

#
# GSNMP_IPK_VERSION should be incremented when the ipk changes.
#
GSNMP_IPK_VERSION=1

#
# GSNMP_CONFFILES should be a list of user-editable files
#GSNMP_CONFFILES=/opt/etc/gsnmp.conf /opt/etc/init.d/SXXgsnmp

#
# GSNMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GSNMP_PATCHES=$(GSNMP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GSNMP_CPPFLAGS=
GSNMP_LDFLAGS=

#
# GSNMP_BUILD_DIR is the directory in which the build is done.
# GSNMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GSNMP_IPK_DIR is the directory in which the ipk is built.
# GSNMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GSNMP_BUILD_DIR=$(BUILD_DIR)/gsnmp
GSNMP_SOURCE_DIR=$(SOURCE_DIR)/gsnmp
GSNMP_IPK_DIR=$(BUILD_DIR)/gsnmp-$(GSNMP_VERSION)-ipk
GSNMP_IPK=$(BUILD_DIR)/gsnmp_$(GSNMP_VERSION)-$(GSNMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gsnmp-source gsnmp-unpack gsnmp gsnmp-stage gsnmp-ipk gsnmp-clean gsnmp-dirclean gsnmp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GSNMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(GSNMP_SITE)/$(GSNMP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GSNMP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gsnmp-source: $(DL_DIR)/$(GSNMP_SOURCE) $(GSNMP_PATCHES)

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
$(GSNMP_BUILD_DIR)/.configured: $(DL_DIR)/$(GSNMP_SOURCE) $(GSNMP_PATCHES) make/gsnmp.mk
	$(MAKE) gnet-stage
	rm -rf $(BUILD_DIR)/$(GSNMP_DIR) $(GSNMP_BUILD_DIR)
	$(GSNMP_UNZIP) $(DL_DIR)/$(GSNMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GSNMP_PATCHES)" ; \
		then cat $(GSNMP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GSNMP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GSNMP_DIR)" != "$(GSNMP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GSNMP_DIR) $(GSNMP_BUILD_DIR) ; \
	fi
	(cd $(GSNMP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GSNMP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GSNMP_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(GSNMP_BUILD_DIR)/libtool
	touch $@

gsnmp-unpack: $(GSNMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GSNMP_BUILD_DIR)/.built: $(GSNMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GSNMP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gsnmp: $(GSNMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GSNMP_BUILD_DIR)/.staged: $(GSNMP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GSNMP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/gsnmp*.pc
	touch $@

gsnmp-stage: $(GSNMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gsnmp
#
$(GSNMP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gsnmp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GSNMP_PRIORITY)" >>$@
	@echo "Section: $(GSNMP_SECTION)" >>$@
	@echo "Version: $(GSNMP_VERSION)-$(GSNMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GSNMP_MAINTAINER)" >>$@
	@echo "Source: $(GSNMP_SITE)/$(GSNMP_SOURCE)" >>$@
	@echo "Description: $(GSNMP_DESCRIPTION)" >>$@
	@echo "Depends: $(GSNMP_DEPENDS)" >>$@
	@echo "Suggests: $(GSNMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(GSNMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GSNMP_IPK_DIR)/opt/sbin or $(GSNMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GSNMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GSNMP_IPK_DIR)/opt/etc/gsnmp/...
# Documentation files should be installed in $(GSNMP_IPK_DIR)/opt/doc/gsnmp/...
# Daemon startup scripts should be installed in $(GSNMP_IPK_DIR)/opt/etc/init.d/S??gsnmp
#
# You may need to patch your application to make it use these locations.
#
$(GSNMP_IPK): $(GSNMP_BUILD_DIR)/.built
	rm -rf $(GSNMP_IPK_DIR) $(BUILD_DIR)/gsnmp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GSNMP_BUILD_DIR) DESTDIR=$(GSNMP_IPK_DIR) install
	$(STRIP_COMMAND) $(GSNMP_IPK_DIR)/opt/bin/gsnmp-get \
	    $(GSNMP_IPK_DIR)/opt/lib/libgsnmp.so.[0-9]*.[0-9]*.[0-9]*
#	install -d $(GSNMP_IPK_DIR)/opt/etc/
#	install -m 644 $(GSNMP_SOURCE_DIR)/gsnmp.conf $(GSNMP_IPK_DIR)/opt/etc/gsnmp.conf
#	install -d $(GSNMP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GSNMP_SOURCE_DIR)/rc.gsnmp $(GSNMP_IPK_DIR)/opt/etc/init.d/SXXgsnmp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSNMP_IPK_DIR)/opt/etc/init.d/SXXgsnmp
	$(MAKE) $(GSNMP_IPK_DIR)/CONTROL/control
#	install -m 755 $(GSNMP_SOURCE_DIR)/postinst $(GSNMP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSNMP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GSNMP_SOURCE_DIR)/prerm $(GSNMP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GSNMP_IPK_DIR)/CONTROL/prerm
	echo $(GSNMP_CONFFILES) | sed -e 's/ /\n/g' > $(GSNMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GSNMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gsnmp-ipk: $(GSNMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gsnmp-clean:
	rm -f $(GSNMP_BUILD_DIR)/.built
	-$(MAKE) -C $(GSNMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gsnmp-dirclean:
	rm -rf $(BUILD_DIR)/$(GSNMP_DIR) $(GSNMP_BUILD_DIR) $(GSNMP_IPK_DIR) $(GSNMP_IPK)
#
#
# Some sanity check for the package.
#
gsnmp-check: $(GSNMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GSNMP_IPK)
