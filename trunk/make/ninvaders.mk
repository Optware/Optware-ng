###########################################################
#
# ninvaders
#
###########################################################
#
# NINVADERS_VERSION, NINVADERS_SITE and NINVADERS_SOURCE define
# the upstream location of the source code for the package.
# NINVADERS_DIR is the directory which is created when the source
# archive is unpacked.
# NINVADERS_UNZIP is the command used to unzip the source.
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
NINVADERS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ninvaders
NINVADERS_VERSION=0.1.1
NINVADERS_SOURCE=ninvaders-$(NINVADERS_VERSION).tar.gz
NINVADERS_DIR=ninvaders-$(NINVADERS_VERSION)
NINVADERS_UNZIP=zcat
NINVADERS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NINVADERS_DESCRIPTION=They are approaching as we speak.
NINVADERS_SECTION=games
NINVADERS_PRIORITY=optional
NINVADERS_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET)
NINVADERS_SUGGESTS=
NINVADERS_CONFLICTS=

#
# NINVADERS_IPK_VERSION should be incremented when the ipk changes.
#
NINVADERS_IPK_VERSION=1

#
# NINVADERS_CONFFILES should be a list of user-editable files
NINVADERS_CONFFILES=/opt/etc/ninvaders.conf /opt/etc/init.d/SXXninvaders

#
# NINVADERS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# NINVADERS_PATCHES=$(NINVADERS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NINVADERS_CPPFLAGS=
NINVADERS_LDFLAGS=

#
# NINVADERS_BUILD_DIR is the directory in which the build is done.
# NINVADERS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NINVADERS_IPK_DIR is the directory in which the ipk is built.
# NINVADERS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NINVADERS_BUILD_DIR=$(BUILD_DIR)/ninvaders
NINVADERS_SOURCE_DIR=$(SOURCE_DIR)/ninvaders
NINVADERS_IPK_DIR=$(BUILD_DIR)/ninvaders-$(NINVADERS_VERSION)-ipk
NINVADERS_IPK=$(BUILD_DIR)/ninvaders_$(NINVADERS_VERSION)-$(NINVADERS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ninvaders-source ninvaders-unpack ninvaders ninvaders-stage ninvaders-ipk ninvaders-clean ninvaders-dirclean ninvaders-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NINVADERS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NINVADERS_SITE)/$(NINVADERS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NINVADERS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ninvaders-source: $(DL_DIR)/$(NINVADERS_SOURCE) $(NINVADERS_PATCHES)

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
$(NINVADERS_BUILD_DIR)/.configured: $(DL_DIR)/$(NINVADERS_SOURCE) $(NINVADERS_PATCHES) make/ninvaders.mk
	$(MAKE)  $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(NINVADERS_DIR) $(NINVADERS_BUILD_DIR)
	$(NINVADERS_UNZIP) $(DL_DIR)/$(NINVADERS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NINVADERS_PATCHES)" ; \
		then cat $(NINVADERS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NINVADERS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NINVADERS_DIR)" != "$(NINVADERS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NINVADERS_DIR) $(NINVADERS_BUILD_DIR) ; \
	fi
	(cd $(NINVADERS_BUILD_DIR); \
		sed -i.orig -e '/^CC/d;/^CFLAGS/d' Makefile \
	)
	touch $@

ninvaders-unpack: $(NINVADERS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NINVADERS_BUILD_DIR)/.built: $(NINVADERS_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(NINVADERS_CPPFLAGS)" \
        LDFLAGS="$(STAGING_LDFLAGS) $(NINVADERS_LDFLAGS)" \
	$(MAKE) -C $(NINVADERS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
ninvaders: $(NINVADERS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NINVADERS_BUILD_DIR)/.staged: $(NINVADERS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NINVADERS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

ninvaders-stage: $(NINVADERS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ninvaders
#
$(NINVADERS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ninvaders" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NINVADERS_PRIORITY)" >>$@
	@echo "Section: $(NINVADERS_SECTION)" >>$@
	@echo "Version: $(NINVADERS_VERSION)-$(NINVADERS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NINVADERS_MAINTAINER)" >>$@
	@echo "Source: $(NINVADERS_SITE)/$(NINVADERS_SOURCE)" >>$@
	@echo "Description: $(NINVADERS_DESCRIPTION)" >>$@
	@echo "Depends: $(NINVADERS_DEPENDS)" >>$@
	@echo "Suggests: $(NINVADERS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NINVADERS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NINVADERS_IPK_DIR)/opt/sbin or $(NINVADERS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NINVADERS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NINVADERS_IPK_DIR)/opt/etc/ninvaders/...
# Documentation files should be installed in $(NINVADERS_IPK_DIR)/opt/doc/ninvaders/...
# Daemon startup scripts should be installed in $(NINVADERS_IPK_DIR)/opt/etc/init.d/S??ninvaders
#
# You may need to patch your application to make it use these locations.
#
$(NINVADERS_IPK): $(NINVADERS_BUILD_DIR)/.built
	rm -rf $(NINVADERS_IPK_DIR) $(BUILD_DIR)/ninvaders_*_$(TARGET_ARCH).ipk
	install -d $(NINVADERS_IPK_DIR)/opt/bin/
	install -m 755 $(NINVADERS_BUILD_DIR)/nInvaders $(NINVADERS_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(NINVADERS_IPK_DIR)/opt/bin/nInvaders
	$(MAKE) $(NINVADERS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NINVADERS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ninvaders-ipk: $(NINVADERS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ninvaders-clean:
	rm -f $(NINVADERS_BUILD_DIR)/.built
	-$(MAKE) -C $(NINVADERS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ninvaders-dirclean:
	rm -rf $(BUILD_DIR)/$(NINVADERS_DIR) $(NINVADERS_BUILD_DIR) $(NINVADERS_IPK_DIR) $(NINVADERS_IPK)
#
#
# Some sanity check for the package.
#
ninvaders-check: $(NINVADERS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NINVADERS_IPK)
