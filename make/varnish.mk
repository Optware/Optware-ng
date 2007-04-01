###########################################################
#
# varnish
#
###########################################################
#
# VARNISH_VERSION, VARNISH_SITE and VARNISH_SOURCE define
# the upstream location of the source code for the package.
# VARNISH_DIR is the directory which is created when the source
# archive is unpacked.
# VARNISH_UNZIP is the command used to unzip the source.
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
VARNISH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/varnish
VARNISH_VERSION=1.0.3
VARNISH_SOURCE=varnish-$(VARNISH_VERSION).tar.gz
VARNISH_DIR=varnish-$(VARNISH_VERSION)
VARNISH_UNZIP=zcat
VARNISH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VARNISH_DESCRIPTION=A high-performace HTTP accelerator designed for content-heavy dynamic web sites.
VARNISH_SECTION=web
VARNISH_PRIORITY=optional
VARNISH_DEPENDS=
VARNISH_SUGGESTS=
VARNISH_CONFLICTS=

#
# VARNISH_IPK_VERSION should be incremented when the ipk changes.
#
VARNISH_IPK_VERSION=1

#
# VARNISH_CONFFILES should be a list of user-editable files
#VARNISH_CONFFILES=/opt/etc/varnish.conf /opt/etc/init.d/SXXvarnish

#
# VARNISH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VARNISH_PATCHES=$(VARNISH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VARNISH_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
VARNISH_LDFLAGS=

#
# VARNISH_BUILD_DIR is the directory in which the build is done.
# VARNISH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VARNISH_IPK_DIR is the directory in which the ipk is built.
# VARNISH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VARNISH_BUILD_DIR=$(BUILD_DIR)/varnish
VARNISH_SOURCE_DIR=$(SOURCE_DIR)/varnish
VARNISH_IPK_DIR=$(BUILD_DIR)/varnish-$(VARNISH_VERSION)-ipk
VARNISH_IPK=$(BUILD_DIR)/varnish_$(VARNISH_VERSION)-$(VARNISH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: varnish-source varnish-unpack varnish varnish-stage varnish-ipk varnish-clean varnish-dirclean varnish-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VARNISH_SOURCE):
	$(WGET) -P $(DL_DIR) $(VARNISH_SITE)/$(VARNISH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(VARNISH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
varnish-source: $(DL_DIR)/$(VARNISH_SOURCE) $(VARNISH_PATCHES)

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
$(VARNISH_BUILD_DIR)/.configured: $(DL_DIR)/$(VARNISH_SOURCE) $(VARNISH_PATCHES) make/varnish.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(VARNISH_DIR) $(VARNISH_BUILD_DIR)
	$(VARNISH_UNZIP) $(DL_DIR)/$(VARNISH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VARNISH_PATCHES)" ; \
		then cat $(VARNISH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VARNISH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VARNISH_DIR)" != "$(VARNISH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(VARNISH_DIR) $(VARNISH_BUILD_DIR) ; \
	fi
	sed -i -e 's|-lcurses|-lncurses|' $(VARNISH_BUILD_DIR)/bin/*/Makefile.in
	(cd $(VARNISH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VARNISH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VARNISH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(VARNISH_BUILD_DIR)/libtool
	touch $@

varnish-unpack: $(VARNISH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VARNISH_BUILD_DIR)/.built: $(VARNISH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(VARNISH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
varnish: $(VARNISH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VARNISH_BUILD_DIR)/.staged: $(VARNISH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(VARNISH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

varnish-stage: $(VARNISH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/varnish
#
$(VARNISH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: varnish" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VARNISH_PRIORITY)" >>$@
	@echo "Section: $(VARNISH_SECTION)" >>$@
	@echo "Version: $(VARNISH_VERSION)-$(VARNISH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VARNISH_MAINTAINER)" >>$@
	@echo "Source: $(VARNISH_SITE)/$(VARNISH_SOURCE)" >>$@
	@echo "Description: $(VARNISH_DESCRIPTION)" >>$@
	@echo "Depends: $(VARNISH_DEPENDS)" >>$@
	@echo "Suggests: $(VARNISH_SUGGESTS)" >>$@
	@echo "Conflicts: $(VARNISH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VARNISH_IPK_DIR)/opt/sbin or $(VARNISH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VARNISH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VARNISH_IPK_DIR)/opt/etc/varnish/...
# Documentation files should be installed in $(VARNISH_IPK_DIR)/opt/doc/varnish/...
# Daemon startup scripts should be installed in $(VARNISH_IPK_DIR)/opt/etc/init.d/S??varnish
#
# You may need to patch your application to make it use these locations.
#
$(VARNISH_IPK): $(VARNISH_BUILD_DIR)/.built
	rm -rf $(VARNISH_IPK_DIR) $(BUILD_DIR)/varnish_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VARNISH_BUILD_DIR) DESTDIR=$(VARNISH_IPK_DIR) transform='' install-strip
#	install -d $(VARNISH_IPK_DIR)/opt/etc/
#	install -m 644 $(VARNISH_SOURCE_DIR)/varnish.conf $(VARNISH_IPK_DIR)/opt/etc/varnish.conf
#	install -d $(VARNISH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(VARNISH_SOURCE_DIR)/rc.varnish $(VARNISH_IPK_DIR)/opt/etc/init.d/SXXvarnish
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VARNISH_IPK_DIR)/opt/etc/init.d/SXXvarnish
	$(MAKE) $(VARNISH_IPK_DIR)/CONTROL/control
#	install -m 755 $(VARNISH_SOURCE_DIR)/postinst $(VARNISH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VARNISH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(VARNISH_SOURCE_DIR)/prerm $(VARNISH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VARNISH_IPK_DIR)/CONTROL/prerm
	echo $(VARNISH_CONFFILES) | sed -e 's/ /\n/g' > $(VARNISH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VARNISH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
varnish-ipk: $(VARNISH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
varnish-clean:
	rm -f $(VARNISH_BUILD_DIR)/.built
	-$(MAKE) -C $(VARNISH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
varnish-dirclean:
	rm -rf $(BUILD_DIR)/$(VARNISH_DIR) $(VARNISH_BUILD_DIR) $(VARNISH_IPK_DIR) $(VARNISH_IPK)
#
#
# Some sanity check for the package.
#
varnish-check: $(VARNISH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VARNISH_IPK)
