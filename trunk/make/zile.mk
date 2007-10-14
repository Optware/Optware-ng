###########################################################
#
# zile
#
###########################################################
#
# ZILE_VERSION, ZILE_SITE and ZILE_SOURCE define
# the upstream location of the source code for the package.
# ZILE_DIR is the directory which is created when the source
# archive is unpacked.
# ZILE_UNZIP is the command used to unzip the source.
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
ZILE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/zile
ZILE_VERSION=2.2.45
ZILE_SOURCE=zile-$(ZILE_VERSION).tar.gz
ZILE_DIR=zile-$(ZILE_VERSION)
ZILE_UNZIP=zcat
ZILE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZILE_DESCRIPTION=Zile is Lossy Emacs, a small, fast, and powerful Emacs clone.
ZILE_SECTION=editor
ZILE_PRIORITY=optional
ZILE_DEPENDS=ncurses
ZILE_SUGGESTS=
ZILE_CONFLICTS=

#
# ZILE_IPK_VERSION should be incremented when the ipk changes.
#
ZILE_IPK_VERSION=1

#
# ZILE_CONFFILES should be a list of user-editable files
#ZILE_CONFFILES=/opt/etc/zile.conf /opt/etc/init.d/SXXzile

#
# ZILE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ZILE_PATCHES=$(ZILE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZILE_CPPFLAGS=
ZILE_LDFLAGS=

#
# ZILE_BUILD_DIR is the directory in which the build is done.
# ZILE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZILE_IPK_DIR is the directory in which the ipk is built.
# ZILE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZILE_BUILD_DIR=$(BUILD_DIR)/zile
ZILE_SOURCE_DIR=$(SOURCE_DIR)/zile
ZILE_IPK_DIR=$(BUILD_DIR)/zile-$(ZILE_VERSION)-ipk
ZILE_IPK=$(BUILD_DIR)/zile_$(ZILE_VERSION)-$(ZILE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: zile-source zile-unpack zile zile-stage zile-ipk zile-clean zile-dirclean zile-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ZILE_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZILE_SITE)/$(ZILE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(ZILE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
zile-source: $(DL_DIR)/$(ZILE_SOURCE) $(ZILE_PATCHES)

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
$(ZILE_BUILD_DIR)/.configured: $(DL_DIR)/$(ZILE_SOURCE) $(ZILE_PATCHES) make/zile.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(ZILE_DIR) $(ZILE_BUILD_DIR)
	$(ZILE_UNZIP) $(DL_DIR)/$(ZILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZILE_PATCHES)" ; \
		then cat $(ZILE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ZILE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ZILE_DIR)" != "$(ZILE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ZILE_DIR) $(ZILE_BUILD_DIR) ; \
	fi
	(cd $(ZILE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ZILE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ZILE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(ZILE_BUILD_DIR)/libtool
	touch $@

zile-unpack: $(ZILE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZILE_BUILD_DIR)/.built: $(ZILE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(ZILE_BUILD_DIR)/doc mkdoc CPPFLAGS="" LDFLAGS=""
	$(MAKE) -C $(ZILE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
zile: $(ZILE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ZILE_BUILD_DIR)/.staged: $(ZILE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ZILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

zile-stage: $(ZILE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/zile
#
$(ZILE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: zile" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZILE_PRIORITY)" >>$@
	@echo "Section: $(ZILE_SECTION)" >>$@
	@echo "Version: $(ZILE_VERSION)-$(ZILE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZILE_MAINTAINER)" >>$@
	@echo "Source: $(ZILE_SITE)/$(ZILE_SOURCE)" >>$@
	@echo "Description: $(ZILE_DESCRIPTION)" >>$@
	@echo "Depends: $(ZILE_DEPENDS)" >>$@
	@echo "Suggests: $(ZILE_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZILE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ZILE_IPK_DIR)/opt/sbin or $(ZILE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ZILE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ZILE_IPK_DIR)/opt/etc/zile/...
# Documentation files should be installed in $(ZILE_IPK_DIR)/opt/doc/zile/...
# Daemon startup scripts should be installed in $(ZILE_IPK_DIR)/opt/etc/init.d/S??zile
#
# You may need to patch your application to make it use these locations.
#
$(ZILE_IPK): $(ZILE_BUILD_DIR)/.built
	rm -rf $(ZILE_IPK_DIR) $(BUILD_DIR)/zile_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ZILE_BUILD_DIR) DESTDIR=$(ZILE_IPK_DIR) install-strip
	$(MAKE) $(ZILE_IPK_DIR)/CONTROL/control
	echo $(ZILE_CONFFILES) | sed -e 's/ /\n/g' > $(ZILE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZILE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
zile-ipk: $(ZILE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
zile-clean:
	rm -f $(ZILE_BUILD_DIR)/.built
	-$(MAKE) -C $(ZILE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
zile-dirclean:
	rm -rf $(BUILD_DIR)/$(ZILE_DIR) $(ZILE_BUILD_DIR) $(ZILE_IPK_DIR) $(ZILE_IPK)
#
#
# Some sanity check for the package.
#
zile-check: $(ZILE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ZILE_IPK)
