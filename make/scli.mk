###########################################################
#
# scli
#
###########################################################
#
# SCLI_VERSION, SCLI_SITE and SCLI_SOURCE define
# the upstream location of the source code for the package.
# SCLI_DIR is the directory which is created when the source
# archive is unpacked.
# SCLI_UNZIP is the command used to unzip the source.
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
SCLI_SITE=ftp://ftp.ibr.cs.tu-bs.de/pub/local/scli
SCLI_VERSION=0.3.1
SCLI_SOURCE=scli-$(SCLI_VERSION).tar.gz
SCLI_DIR=scli-$(SCLI_VERSION)
SCLI_UNZIP=zcat
SCLI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SCLI_DESCRIPTION=SNMP Command Line Interface.
SCLI_SECTION=net
SCLI_PRIORITY=optional
SCLI_DEPENDS=gsnmp, libxml2, ncurses, readline, zlib
SCLI_SUGGESTS=
SCLI_CONFLICTS=

#
# SCLI_IPK_VERSION should be incremented when the ipk changes.
#
SCLI_IPK_VERSION=2

#
# SCLI_CONFFILES should be a list of user-editable files
#SCLI_CONFFILES=/opt/etc/scli.conf /opt/etc/init.d/SXXscli

#
# SCLI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SCLI_PATCHES=$(SCLI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SCLI_CPPFLAGS=
SCLI_LDFLAGS=

#
# SCLI_BUILD_DIR is the directory in which the build is done.
# SCLI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SCLI_IPK_DIR is the directory in which the ipk is built.
# SCLI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SCLI_BUILD_DIR=$(BUILD_DIR)/scli
SCLI_SOURCE_DIR=$(SOURCE_DIR)/scli
SCLI_IPK_DIR=$(BUILD_DIR)/scli-$(SCLI_VERSION)-ipk
SCLI_IPK=$(BUILD_DIR)/scli_$(SCLI_VERSION)-$(SCLI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: scli-source scli-unpack scli scli-stage scli-ipk scli-clean scli-dirclean scli-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SCLI_SOURCE):
	$(WGET) -P $(DL_DIR) $(SCLI_SITE)/$(SCLI_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SCLI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
scli-source: $(DL_DIR)/$(SCLI_SOURCE) $(SCLI_PATCHES)

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
$(SCLI_BUILD_DIR)/.configured: $(DL_DIR)/$(SCLI_SOURCE) $(SCLI_PATCHES) make/scli.mk
	$(MAKE) gsnmp-stage
	$(MAKE) libxml2-stage
	$(MAKE) ncurses-stage
	$(MAKE) readline-stage
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(SCLI_DIR) $(SCLI_BUILD_DIR)
	$(SCLI_UNZIP) $(DL_DIR)/$(SCLI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SCLI_PATCHES)" ; \
		then cat $(SCLI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SCLI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SCLI_DIR)" != "$(SCLI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SCLI_DIR) $(SCLI_BUILD_DIR) ; \
	fi
	(cd $(SCLI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SCLI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SCLI_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		XML2_CONFIG=$(STAGING_PREFIX)/bin/xml2-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SCLI_BUILD_DIR)/libtool
	touch $@

scli-unpack: $(SCLI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SCLI_BUILD_DIR)/.built: $(SCLI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SCLI_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
scli: $(SCLI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SCLI_BUILD_DIR)/.staged: $(SCLI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(SCLI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

scli-stage: $(SCLI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/scli
#
$(SCLI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: scli" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SCLI_PRIORITY)" >>$@
	@echo "Section: $(SCLI_SECTION)" >>$@
	@echo "Version: $(SCLI_VERSION)-$(SCLI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SCLI_MAINTAINER)" >>$@
	@echo "Source: $(SCLI_SITE)/$(SCLI_SOURCE)" >>$@
	@echo "Description: $(SCLI_DESCRIPTION)" >>$@
	@echo "Depends: $(SCLI_DEPENDS)" >>$@
	@echo "Suggests: $(SCLI_SUGGESTS)" >>$@
	@echo "Conflicts: $(SCLI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SCLI_IPK_DIR)/opt/sbin or $(SCLI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SCLI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SCLI_IPK_DIR)/opt/etc/scli/...
# Documentation files should be installed in $(SCLI_IPK_DIR)/opt/doc/scli/...
# Daemon startup scripts should be installed in $(SCLI_IPK_DIR)/opt/etc/init.d/S??scli
#
# You may need to patch your application to make it use these locations.
#
$(SCLI_IPK): $(SCLI_BUILD_DIR)/.built
	rm -rf $(SCLI_IPK_DIR) $(BUILD_DIR)/scli_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SCLI_BUILD_DIR) DESTDIR=$(SCLI_IPK_DIR) install-strip
#	install -d $(SCLI_IPK_DIR)/opt/etc/
#	install -m 644 $(SCLI_SOURCE_DIR)/scli.conf $(SCLI_IPK_DIR)/opt/etc/scli.conf
#	install -d $(SCLI_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SCLI_SOURCE_DIR)/rc.scli $(SCLI_IPK_DIR)/opt/etc/init.d/SXXscli
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCLI_IPK_DIR)/opt/etc/init.d/SXXscli
	$(MAKE) $(SCLI_IPK_DIR)/CONTROL/control
#	install -m 755 $(SCLI_SOURCE_DIR)/postinst $(SCLI_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCLI_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SCLI_SOURCE_DIR)/prerm $(SCLI_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SCLI_IPK_DIR)/CONTROL/prerm
	echo $(SCLI_CONFFILES) | sed -e 's/ /\n/g' > $(SCLI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SCLI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
scli-ipk: $(SCLI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
scli-clean:
	rm -f $(SCLI_BUILD_DIR)/.built
	-$(MAKE) -C $(SCLI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
scli-dirclean:
	rm -rf $(BUILD_DIR)/$(SCLI_DIR) $(SCLI_BUILD_DIR) $(SCLI_IPK_DIR) $(SCLI_IPK)
#
#
# Some sanity check for the package.
#
scli-check: $(SCLI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SCLI_IPK)
