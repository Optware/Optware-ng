###########################################################
#
# rxtx
#
###########################################################
#
# RXTX_VERSION, RXTX_SITE and RXTX_SOURCE define
# the upstream location of the source code for the package.
# RXTX_DIR is the directory which is created when the source
# archive is unpacked.
# RXTX_UNZIP is the command used to unzip the source.
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
RXTX_SITE=ftp://ftp.qbang.org/pub/rxtx
RXTX_VERSION=2.1-7r2
RXTX_SOURCE=rxtx-$(RXTX_VERSION).zip
RXTX_DIR=rxtx-$(RXTX_VERSION)
RXTX_UNZIP=unzip
RXTX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RXTX_DESCRIPTION=Describe rxtx here.
RXTX_SECTION=util
RXTX_PRIORITY=optional
RXTX_DEPENDS=
RXTX_SUGGESTS=
RXTX_CONFLICTS=

#
# RXTX_IPK_VERSION should be incremented when the ipk changes.
#
RXTX_IPK_VERSION=1

#
# RXTX_CONFFILES should be a list of user-editable files
#RXTX_CONFFILES=/opt/etc/rxtx.conf /opt/etc/init.d/SXXrxtx

#
# RXTX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RXTX_PATCHES=$(RXTX_SOURCE_DIR)/no-UTS_RELEASE.patch
#http://ftp.riken.go.jp/pub/Linux/gentoo/dev-java/rxtx/files/rxtx-2.1-7r2-nouts.diff

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RXTX_CPPFLAGS=
RXTX_LDFLAGS=

#
# RXTX_BUILD_DIR is the directory in which the build is done.
# RXTX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RXTX_IPK_DIR is the directory in which the ipk is built.
# RXTX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RXTX_BUILD_DIR=$(BUILD_DIR)/rxtx
RXTX_SOURCE_DIR=$(SOURCE_DIR)/rxtx
RXTX_IPK_DIR=$(BUILD_DIR)/rxtx-$(RXTX_VERSION)-ipk
RXTX_IPK=$(BUILD_DIR)/rxtx_$(RXTX_VERSION)-$(RXTX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rxtx-source rxtx-unpack rxtx rxtx-stage rxtx-ipk rxtx-clean rxtx-dirclean rxtx-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RXTX_SOURCE):
	$(WGET) -P $(DL_DIR) $(RXTX_SITE)/$(RXTX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(RXTX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rxtx-source: $(DL_DIR)/$(RXTX_SOURCE) $(RXTX_PATCHES)

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
$(RXTX_BUILD_DIR)/.configured: $(DL_DIR)/$(RXTX_SOURCE) $(RXTX_PATCHES) # make/rxtx.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RXTX_DIR) $(RXTX_BUILD_DIR)
	cd $(BUILD_DIR) && $(RXTX_UNZIP) $(DL_DIR)/$(RXTX_SOURCE)
	if test -n "$(RXTX_PATCHES)" ; \
		then cat $(RXTX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RXTX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RXTX_DIR)" != "$(RXTX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RXTX_DIR) $(RXTX_BUILD_DIR) ; \
	fi
	sed -i -e 's:UTS_RELEASE::' \
	       -e '/`uname -r`/s:`./conftest`:`uname -r`:' \
		$(RXTX_BUILD_DIR)/configure
	(cd $(RXTX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RXTX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RXTX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RXTX_BUILD_DIR)/libtool
	touch $@

rxtx-unpack: $(RXTX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RXTX_BUILD_DIR)/.built: $(RXTX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(RXTX_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
rxtx: $(RXTX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RXTX_BUILD_DIR)/.staged: $(RXTX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(RXTX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

rxtx-stage: $(RXTX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rxtx
#
$(RXTX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rxtx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RXTX_PRIORITY)" >>$@
	@echo "Section: $(RXTX_SECTION)" >>$@
	@echo "Version: $(RXTX_VERSION)-$(RXTX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RXTX_MAINTAINER)" >>$@
	@echo "Source: $(RXTX_SITE)/$(RXTX_SOURCE)" >>$@
	@echo "Description: $(RXTX_DESCRIPTION)" >>$@
	@echo "Depends: $(RXTX_DEPENDS)" >>$@
	@echo "Suggests: $(RXTX_SUGGESTS)" >>$@
	@echo "Conflicts: $(RXTX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RXTX_IPK_DIR)/opt/sbin or $(RXTX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RXTX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RXTX_IPK_DIR)/opt/etc/rxtx/...
# Documentation files should be installed in $(RXTX_IPK_DIR)/opt/doc/rxtx/...
# Daemon startup scripts should be installed in $(RXTX_IPK_DIR)/opt/etc/init.d/S??rxtx
#
# You may need to patch your application to make it use these locations.
#
$(RXTX_IPK): $(RXTX_BUILD_DIR)/.built
	rm -rf $(RXTX_IPK_DIR) $(BUILD_DIR)/rxtx_*_$(TARGET_ARCH).ipk
	install -d $(RXTX_IPK_DIR)/opt/lib/java
	$(MAKE) -C $(RXTX_BUILD_DIR) install \
		DESTDIR=$(RXTX_IPK_DIR) \
		JHOME=$(RXTX_IPK_DIR)/opt/lib/java \
		RXTX_PATH=$(RXTX_IPK_DIR)/opt/lib \
		;
	$(STRIP_COMMAND) $(RXTX_IPK_DIR)/opt/lib/*.so
#	install -d $(RXTX_IPK_DIR)/opt/etc/
#	install -m 644 $(RXTX_SOURCE_DIR)/rxtx.conf $(RXTX_IPK_DIR)/opt/etc/rxtx.conf
#	install -d $(RXTX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RXTX_SOURCE_DIR)/rc.rxtx $(RXTX_IPK_DIR)/opt/etc/init.d/SXXrxtx
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RXTX_IPK_DIR)/opt/etc/init.d/SXXrxtx
	$(MAKE) $(RXTX_IPK_DIR)/CONTROL/control
#	install -m 755 $(RXTX_SOURCE_DIR)/postinst $(RXTX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RXTX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RXTX_SOURCE_DIR)/prerm $(RXTX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RXTX_IPK_DIR)/CONTROL/prerm
	echo $(RXTX_CONFFILES) | sed -e 's/ /\n/g' > $(RXTX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RXTX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rxtx-ipk: $(RXTX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rxtx-clean:
	rm -f $(RXTX_BUILD_DIR)/.built
	-$(MAKE) -C $(RXTX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rxtx-dirclean:
	rm -rf $(BUILD_DIR)/$(RXTX_DIR) $(RXTX_BUILD_DIR) $(RXTX_IPK_DIR) $(RXTX_IPK)
#
#
# Some sanity check for the package.
#
rxtx-check: $(RXTX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RXTX_IPK)
