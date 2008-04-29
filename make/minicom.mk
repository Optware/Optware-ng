###########################################################
#
# minicom
#
###########################################################

# You must replace "minicom" and "MINICOM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MINICOM_VERSION, MINICOM_SITE and MINICOM_SOURCE define
# the upstream location of the source code for the package.
# MINICOM_DIR is the directory which is created when the source
# archive is unpacked.
# MINICOM_UNZIP is the command used to unzip the source.
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
MINICOM_SITE=http://alioth.debian.org/frs/download.php/2332
MINICOM_VERSION=2.3
MINICOM_SOURCE=minicom-$(MINICOM_VERSION).tar.gz
MINICOM_DIR=minicom-$(MINICOM_VERSION)
MINICOM_UNZIP=zcat
MINICOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINICOM_DESCRIPTION=Minicom is a serial communication program. It is a Unix clone of the well-known MS-DOS Telix program. It has ANSI color, a dialing directory, dial-a-list, and a scripting language.
MINICOM_SECTION=misc
MINICOM_PRIORITY=optional
MINICOM_DEPENDS=ncurses, lrzsz
MINICOM_CONFLICTS=

#
# MINICOM_IPK_VERSION should be incremented when the ipk changes.
#
MINICOM_IPK_VERSION=1

#
# MINICOM_CONFFILES should be a list of user-editable files
MINICOM_CONFFILES=/opt/etc/minirc.dfl

#
# MINICOM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINICOM_PATCHES=$(MINICOM_SOURCE_DIR)/lrzsz-paths.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINICOM_CPPFLAGS=
MINICOM_LDFLAGS=

#
# MINICOM_BUILD_DIR is the directory in which the build is done.
# MINICOM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINICOM_IPK_DIR is the directory in which the ipk is built.
# MINICOM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINICOM_BUILD_DIR=$(BUILD_DIR)/minicom
MINICOM_SOURCE_DIR=$(SOURCE_DIR)/minicom
MINICOM_IPK_DIR=$(BUILD_DIR)/minicom-$(MINICOM_VERSION)-ipk
MINICOM_IPK=$(BUILD_DIR)/minicom_$(MINICOM_VERSION)-$(MINICOM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: minicom-source minicom-unpack minicom minicom-stage minicom-ipk minicom-clean minicom-dirclean minicom-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINICOM_SOURCE):
	$(WGET) -P $(@D) $(MINICOM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
minicom-source: $(DL_DIR)/$(MINICOM_SOURCE) $(MINICOM_PATCHES)

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
$(MINICOM_BUILD_DIR)/.configured: $(DL_DIR)/$(MINICOM_SOURCE) $(MINICOM_PATCHES) make/minicom.mk
	$(MAKE) ncurses-stage termcap-stage
	rm -rf $(BUILD_DIR)/$(MINICOM_DIR) $(MINICOM_BUILD_DIR)
	$(MINICOM_UNZIP) $(DL_DIR)/$(MINICOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINICOM_PATCHES)"; \
		then cat $(MINICOM_PATCHES) | patch -d $(BUILD_DIR)/$(MINICOM_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(MINICOM_DIR) $(MINICOM_BUILD_DIR)
	(cd $(MINICOM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINICOM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINICOM_LDFLAGS)" \
		ac_cv_header_ncurses_termcap_h=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

minicom-unpack: $(MINICOM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINICOM_BUILD_DIR)/.built: $(MINICOM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MINICOM_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
minicom: $(MINICOM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINICOM_BUILD_DIR)/.staged: $(MINICOM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MINICOM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

minicom-stage: $(MINICOM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minicom
#
$(MINICOM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: minicom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINICOM_PRIORITY)" >>$@
	@echo "Section: $(MINICOM_SECTION)" >>$@
	@echo "Version: $(MINICOM_VERSION)-$(MINICOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINICOM_MAINTAINER)" >>$@
	@echo "Source: $(MINICOM_SITE)/$(MINICOM_SOURCE)" >>$@
	@echo "Description: $(MINICOM_DESCRIPTION)" >>$@
	@echo "Depends: $(MINICOM_DEPENDS)" >>$@
	@echo "Conflicts: $(MINICOM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINICOM_IPK_DIR)/opt/sbin or $(MINICOM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINICOM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MINICOM_IPK_DIR)/opt/etc/minicom/...
# Documentation files should be installed in $(MINICOM_IPK_DIR)/opt/doc/minicom/...
# Daemon startup scripts should be installed in $(MINICOM_IPK_DIR)/opt/etc/init.d/S??minicom
#
# You may need to patch your application to make it use these locations.
#
$(MINICOM_IPK): $(MINICOM_BUILD_DIR)/.built
	rm -rf $(MINICOM_IPK_DIR) $(BUILD_DIR)/minicom_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINICOM_BUILD_DIR) DESTDIR=$(MINICOM_IPK_DIR) install
	$(TARGET_STRIP) $(MINICOM_IPK_DIR)/opt/bin/ascii-xfr
	$(TARGET_STRIP) $(MINICOM_IPK_DIR)/opt/bin/minicom
	$(TARGET_STRIP) $(MINICOM_IPK_DIR)/opt/bin/runscript
	install -d $(MINICOM_IPK_DIR)/opt/etc/
	install -m 755 $(MINICOM_BUILD_DIR)/doc/minirc.dfl $(MINICOM_IPK_DIR)/opt/etc/minirc.dfl
	$(MAKE) $(MINICOM_IPK_DIR)/CONTROL/control
	echo $(MINICOM_CONFFILES) | sed -e 's/ /\n/g' > $(MINICOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINICOM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minicom-ipk: $(MINICOM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minicom-clean:
	-$(MAKE) -C $(MINICOM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minicom-dirclean:
	rm -rf $(BUILD_DIR)/$(MINICOM_DIR) $(MINICOM_BUILD_DIR) $(MINICOM_IPK_DIR) $(MINICOM_IPK)
#
#
# Some sanity check for the package.
#
minicom-check: $(MINICOM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MINICOM_IPK)
