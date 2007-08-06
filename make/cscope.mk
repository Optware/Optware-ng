###########################################################
#
# cscope
#
###########################################################
#
# CSCOPE_VERSION, CSCOPE_SITE and CSCOPE_SOURCE define
# the upstream location of the source code for the package.
# CSCOPE_DIR is the directory which is created when the source
# archive is unpacked.
# CSCOPE_UNZIP is the command used to unzip the source.
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
CSCOPE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/cscope
CSCOPE_VERSION=15.6
CSCOPE_SOURCE=cscope-$(CSCOPE_VERSION).tar.gz
CSCOPE_DIR=cscope-$(CSCOPE_VERSION)
CSCOPE_UNZIP=zcat
CSCOPE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CSCOPE_DESCRIPTION=A tool for developer to browse source code.
CSCOPE_SECTION=misc
CSCOPE_PRIORITY=optional
CSCOPE_DEPENDS=ncurses
CSCOPE_SUGGESTS=
CSCOPE_CONFLICTS=

#
# CSCOPE_IPK_VERSION should be incremented when the ipk changes.
#
CSCOPE_IPK_VERSION=1

#
# CSCOPE_CONFFILES should be a list of user-editable files
# CSCOPE_CONFFILES=/opt/etc/cscope.conf /opt/etc/init.d/SXXcscope

#
# CSCOPE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# CSCOPE_PATCHES=$(CSCOPE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CSCOPE_CPPFLAGS=
CSCOPE_LDFLAGS=

#
# CSCOPE_BUILD_DIR is the directory in which the build is done.
# CSCOPE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CSCOPE_IPK_DIR is the directory in which the ipk is built.
# CSCOPE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CSCOPE_BUILD_DIR=$(BUILD_DIR)/cscope
CSCOPE_SOURCE_DIR=$(SOURCE_DIR)/cscope
CSCOPE_IPK_DIR=$(BUILD_DIR)/cscope-$(CSCOPE_VERSION)-ipk
CSCOPE_IPK=$(BUILD_DIR)/cscope_$(CSCOPE_VERSION)-$(CSCOPE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cscope-source cscope-unpack cscope cscope-stage cscope-ipk cscope-clean cscope-dirclean cscope-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CSCOPE_SOURCE):
	$(WGET) -P $(DL_DIR) $(CSCOPE_SITE)/$(CSCOPE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cscope-source: $(DL_DIR)/$(CSCOPE_SOURCE) $(CSCOPE_PATCHES)

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
$(CSCOPE_BUILD_DIR)/.configured: $(DL_DIR)/$(CSCOPE_SOURCE) $(CSCOPE_PATCHES) make/cscope.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(CSCOPE_DIR) $(CSCOPE_BUILD_DIR)
	$(CSCOPE_UNZIP) $(DL_DIR)/$(CSCOPE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CSCOPE_PATCHES)" ; \
		then cat $(CSCOPE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CSCOPE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CSCOPE_DIR)" != "$(CSCOPE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CSCOPE_DIR) $(CSCOPE_BUILD_DIR) ; \
	fi
	(cd $(CSCOPE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STAGING_CPPFLAGS)/ncurses $(CSCOPE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CSCOPE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CSCOPE_BUILD_DIR)/libtool
	touch $(CSCOPE_BUILD_DIR)/.configured

cscope-unpack: $(CSCOPE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CSCOPE_BUILD_DIR)/.built: $(CSCOPE_BUILD_DIR)/.configured
	rm -f $(CSCOPE_BUILD_DIR)/.built
	$(MAKE) -C $(CSCOPE_BUILD_DIR)
	touch $(CSCOPE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cscope: $(CSCOPE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CSCOPE_BUILD_DIR)/.staged: $(CSCOPE_BUILD_DIR)/.built
	rm -f $(CSCOPE_BUILD_DIR)/.staged
	$(MAKE) -C $(CSCOPE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CSCOPE_BUILD_DIR)/.staged

cscope-stage: $(CSCOPE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cscope
#
$(CSCOPE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cscope" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CSCOPE_PRIORITY)" >>$@
	@echo "Section: $(CSCOPE_SECTION)" >>$@
	@echo "Version: $(CSCOPE_VERSION)-$(CSCOPE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CSCOPE_MAINTAINER)" >>$@
	@echo "Source: $(CSCOPE_SITE)/$(CSCOPE_SOURCE)" >>$@
	@echo "Description: $(CSCOPE_DESCRIPTION)" >>$@
	@echo "Depends: $(CSCOPE_DEPENDS)" >>$@
	@echo "Suggests: $(CSCOPE_SUGGESTS)" >>$@
	@echo "Conflicts: $(CSCOPE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CSCOPE_IPK_DIR)/opt/sbin or $(CSCOPE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CSCOPE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CSCOPE_IPK_DIR)/opt/etc/cscope/...
# Documentation files should be installed in $(CSCOPE_IPK_DIR)/opt/doc/cscope/...
# Daemon startup scripts should be installed in $(CSCOPE_IPK_DIR)/opt/etc/init.d/S??cscope
#
# You may need to patch your application to make it use these locations.
#
$(CSCOPE_IPK): $(CSCOPE_BUILD_DIR)/.built
	rm -rf $(CSCOPE_IPK_DIR) $(BUILD_DIR)/cscope_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CSCOPE_BUILD_DIR) DESTDIR=$(CSCOPE_IPK_DIR) install-strip
#	install -d $(CSCOPE_IPK_DIR)/opt/etc/
#	install -m 644 $(CSCOPE_SOURCE_DIR)/cscope.conf $(CSCOPE_IPK_DIR)/opt/etc/cscope.conf
#	install -d $(CSCOPE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CSCOPE_SOURCE_DIR)/rc.cscope $(CSCOPE_IPK_DIR)/opt/etc/init.d/SXXcscope
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXcscope
	$(MAKE) $(CSCOPE_IPK_DIR)/CONTROL/control
#	install -m 755 $(CSCOPE_SOURCE_DIR)/postinst $(CSCOPE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CSCOPE_SOURCE_DIR)/prerm $(CSCOPE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(CSCOPE_CONFFILES) | sed -e 's/ /\n/g' > $(CSCOPE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CSCOPE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cscope-ipk: $(CSCOPE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cscope-clean:
	rm -f $(CSCOPE_BUILD_DIR)/.built
	-$(MAKE) -C $(CSCOPE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cscope-dirclean:
	rm -rf $(BUILD_DIR)/$(CSCOPE_DIR) $(CSCOPE_BUILD_DIR) $(CSCOPE_IPK_DIR) $(CSCOPE_IPK)
#
#
# Some sanity check for the package.
#
cscope-check: $(CSCOPE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CSCOPE_IPK)
