###########################################################
#
# freecell
#
###########################################################
#
# FREECELL_VERSION, FREECELL_SITE and FREECELL_SOURCE define
# the upstream location of the source code for the package.
# FREECELL_DIR is the directory which is created when the source
# archive is unpacked.
# FREECELL_UNZIP is the command used to unzip the source.
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
FREECELL_SITE=http://www.linusakesson.net/files
FREECELL_VERSION=1.0
FREECELL_SOURCE=freecell-$(FREECELL_VERSION).tar.gz
FREECELL_DIR=freecell-$(FREECELL_VERSION)
FREECELL_UNZIP=zcat
FREECELL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FREECELL_DESCRIPTION=Freecell is a console (ncurses) version of the popular solitaire game Freecell. It supports the standard Microsoft compatible game-numbering scheme.
FREECELL_SECTION=games
FREECELL_PRIORITY=optional
FREECELL_DEPENDS=
FREECELL_SUGGESTS=
FREECELL_CONFLICTS=

#
# FREECELL_IPK_VERSION should be incremented when the ipk changes.
#
FREECELL_IPK_VERSION=1

#
# FREECELL_CONFFILES should be a list of user-editable files
#FREECELL_CONFFILES=/opt/etc/freecell.conf /opt/etc/init.d/SXXfreecell

#
# FREECELL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FREECELL_PATCHES=$(FREECELL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FREECELL_CPPFLAGS=
FREECELL_LDFLAGS=

#
# FREECELL_BUILD_DIR is the directory in which the build is done.
# FREECELL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FREECELL_IPK_DIR is the directory in which the ipk is built.
# FREECELL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FREECELL_BUILD_DIR=$(BUILD_DIR)/freecell
FREECELL_SOURCE_DIR=$(SOURCE_DIR)/freecell
FREECELL_IPK_DIR=$(BUILD_DIR)/freecell-$(FREECELL_VERSION)-ipk
FREECELL_IPK=$(BUILD_DIR)/freecell_$(FREECELL_VERSION)-$(FREECELL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: freecell-source freecell-unpack freecell freecell-stage freecell-ipk freecell-clean freecell-dirclean freecell-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FREECELL_SOURCE):
	$(WGET) -P $(DL_DIR) $(FREECELL_SITE)/$(FREECELL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FREECELL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
freecell-source: $(DL_DIR)/$(FREECELL_SOURCE) $(FREECELL_PATCHES)

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
$(FREECELL_BUILD_DIR)/.configured: $(DL_DIR)/$(FREECELL_SOURCE) $(FREECELL_PATCHES) make/freecell.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(FREECELL_DIR) $(FREECELL_BUILD_DIR)
	$(FREECELL_UNZIP) $(DL_DIR)/$(FREECELL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FREECELL_PATCHES)" ; \
		then cat $(FREECELL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FREECELL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FREECELL_DIR)" != "$(FREECELL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FREECELL_DIR) $(FREECELL_BUILD_DIR) ; \
	fi
	(cd $(FREECELL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FREECELL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FREECELL_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(FREECELL_BUILD_DIR)/libtool
	touch $@

freecell-unpack: $(FREECELL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FREECELL_BUILD_DIR)/.built: $(FREECELL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FREECELL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
freecell: $(FREECELL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FREECELL_BUILD_DIR)/.staged: $(FREECELL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FREECELL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

freecell-stage: $(FREECELL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/freecell
#
$(FREECELL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: freecell" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FREECELL_PRIORITY)" >>$@
	@echo "Section: $(FREECELL_SECTION)" >>$@
	@echo "Version: $(FREECELL_VERSION)-$(FREECELL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FREECELL_MAINTAINER)" >>$@
	@echo "Source: $(FREECELL_SITE)/$(FREECELL_SOURCE)" >>$@
	@echo "Description: $(FREECELL_DESCRIPTION)" >>$@
	@echo "Depends: $(FREECELL_DEPENDS)" >>$@
	@echo "Suggests: $(FREECELL_SUGGESTS)" >>$@
	@echo "Conflicts: $(FREECELL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FREECELL_IPK_DIR)/opt/sbin or $(FREECELL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FREECELL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FREECELL_IPK_DIR)/opt/etc/freecell/...
# Documentation files should be installed in $(FREECELL_IPK_DIR)/opt/doc/freecell/...
# Daemon startup scripts should be installed in $(FREECELL_IPK_DIR)/opt/etc/init.d/S??freecell
#
# You may need to patch your application to make it use these locations.
#
$(FREECELL_IPK): $(FREECELL_BUILD_DIR)/.built
	rm -rf $(FREECELL_IPK_DIR) $(BUILD_DIR)/freecell_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FREECELL_BUILD_DIR) DESTDIR=$(FREECELL_IPK_DIR) install-strip
	$(MAKE) $(FREECELL_IPK_DIR)/CONTROL/control
	echo $(FREECELL_CONFFILES) | sed -e 's/ /\n/g' > $(FREECELL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FREECELL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
freecell-ipk: $(FREECELL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
freecell-clean:
	rm -f $(FREECELL_BUILD_DIR)/.built
	-$(MAKE) -C $(FREECELL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
freecell-dirclean:
	rm -rf $(BUILD_DIR)/$(FREECELL_DIR) $(FREECELL_BUILD_DIR) $(FREECELL_IPK_DIR) $(FREECELL_IPK)
#
#
# Some sanity check for the package.
#
freecell-check: $(FREECELL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FREECELL_IPK)
