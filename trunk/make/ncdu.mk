###########################################################
#
# ncdu
#
###########################################################
#
# NCDU_VERSION, NCDU_SITE and NCDU_SOURCE define
# the upstream location of the source code for the package.
# NCDU_DIR is the directory which is created when the source
# archive is unpacked.
# NCDU_UNZIP is the command used to unzip the source.
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
NCDU_SITE=http://dev.yorhel.nl/download
NCDU_VERSION=1.3
NCDU_SOURCE=ncdu-$(NCDU_VERSION).tar.gz
NCDU_DIR=ncdu-$(NCDU_VERSION)
NCDU_UNZIP=zcat
NCDU_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NCDU_DESCRIPTION=NCurses Disk Usage.
NCDU_SECTION=utils
NCDU_PRIORITY=optional
NCDU_DEPENDS=ncurses
NCDU_SUGGESTS=
NCDU_CONFLICTS=

#
# NCDU_IPK_VERSION should be incremented when the ipk changes.
#
NCDU_IPK_VERSION=1

#
# NCDU_CONFFILES should be a list of user-editable files
#NCDU_CONFFILES=/opt/etc/ncdu.conf /opt/etc/init.d/SXXncdu

#
# NCDU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NCDU_PATCHES=$(NCDU_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NCDU_CPPFLAGS=
NCDU_LDFLAGS=

#
# NCDU_BUILD_DIR is the directory in which the build is done.
# NCDU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NCDU_IPK_DIR is the directory in which the ipk is built.
# NCDU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NCDU_BUILD_DIR=$(BUILD_DIR)/ncdu
NCDU_SOURCE_DIR=$(SOURCE_DIR)/ncdu
NCDU_IPK_DIR=$(BUILD_DIR)/ncdu-$(NCDU_VERSION)-ipk
NCDU_IPK=$(BUILD_DIR)/ncdu_$(NCDU_VERSION)-$(NCDU_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ncdu-source ncdu-unpack ncdu ncdu-stage ncdu-ipk ncdu-clean ncdu-dirclean ncdu-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NCDU_SOURCE):
	$(WGET) -P $(DL_DIR) $(NCDU_SITE)/$(NCDU_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NCDU_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ncdu-source: $(DL_DIR)/$(NCDU_SOURCE) $(NCDU_PATCHES)

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
$(NCDU_BUILD_DIR)/.configured: $(DL_DIR)/$(NCDU_SOURCE) $(NCDU_PATCHES) make/ncdu.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NCDU_DIR) $(NCDU_BUILD_DIR)
	$(NCDU_UNZIP) $(DL_DIR)/$(NCDU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NCDU_PATCHES)" ; \
		then cat $(NCDU_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NCDU_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NCDU_DIR)" != "$(NCDU_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NCDU_DIR) $(NCDU_BUILD_DIR) ; \
	fi
	(cd $(NCDU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NCDU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NCDU_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(NCDU_BUILD_DIR)/libtool
	touch $@

ncdu-unpack: $(NCDU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NCDU_BUILD_DIR)/.built: $(NCDU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NCDU_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
ncdu: $(NCDU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NCDU_BUILD_DIR)/.staged: $(NCDU_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NCDU_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

ncdu-stage: $(NCDU_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ncdu
#
$(NCDU_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ncdu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCDU_PRIORITY)" >>$@
	@echo "Section: $(NCDU_SECTION)" >>$@
	@echo "Version: $(NCDU_VERSION)-$(NCDU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCDU_MAINTAINER)" >>$@
	@echo "Source: $(NCDU_SITE)/$(NCDU_SOURCE)" >>$@
	@echo "Description: $(NCDU_DESCRIPTION)" >>$@
	@echo "Depends: $(NCDU_DEPENDS)" >>$@
	@echo "Suggests: $(NCDU_SUGGESTS)" >>$@
	@echo "Conflicts: $(NCDU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NCDU_IPK_DIR)/opt/sbin or $(NCDU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NCDU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NCDU_IPK_DIR)/opt/etc/ncdu/...
# Documentation files should be installed in $(NCDU_IPK_DIR)/opt/doc/ncdu/...
# Daemon startup scripts should be installed in $(NCDU_IPK_DIR)/opt/etc/init.d/S??ncdu
#
# You may need to patch your application to make it use these locations.
#
$(NCDU_IPK): $(NCDU_BUILD_DIR)/.built
	rm -rf $(NCDU_IPK_DIR) $(BUILD_DIR)/ncdu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NCDU_BUILD_DIR) DESTDIR=$(NCDU_IPK_DIR) install-strip
#	install -d $(NCDU_IPK_DIR)/opt/etc/
#	install -m 644 $(NCDU_SOURCE_DIR)/ncdu.conf $(NCDU_IPK_DIR)/opt/etc/ncdu.conf
#	install -d $(NCDU_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NCDU_SOURCE_DIR)/rc.ncdu $(NCDU_IPK_DIR)/opt/etc/init.d/SXXncdu
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCDU_IPK_DIR)/opt/etc/init.d/SXXncdu
	$(MAKE) $(NCDU_IPK_DIR)/CONTROL/control
#	install -m 755 $(NCDU_SOURCE_DIR)/postinst $(NCDU_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCDU_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NCDU_SOURCE_DIR)/prerm $(NCDU_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NCDU_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NCDU_IPK_DIR)/CONTROL/postinst $(NCDU_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NCDU_CONFFILES) | sed -e 's/ /\n/g' > $(NCDU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCDU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ncdu-ipk: $(NCDU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ncdu-clean:
	rm -f $(NCDU_BUILD_DIR)/.built
	-$(MAKE) -C $(NCDU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ncdu-dirclean:
	rm -rf $(BUILD_DIR)/$(NCDU_DIR) $(NCDU_BUILD_DIR) $(NCDU_IPK_DIR) $(NCDU_IPK)
#
#
# Some sanity check for the package.
#
ncdu-check: $(NCDU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NCDU_IPK)
