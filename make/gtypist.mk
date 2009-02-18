###########################################################
#
# gtypist
#
###########################################################
#
# GTYPIST_VERSION, GTYPIST_SITE and GTYPIST_SOURCE define
# the upstream location of the source code for the package.
# GTYPIST_DIR is the directory which is created when the source
# archive is unpacked.
# GTYPIST_UNZIP is the command used to unzip the source.
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
GTYPIST_SITE=ftp://ftp.gnu.org/gnu/gtypist
GTYPIST_VERSION=2.8.3
GTYPIST_SOURCE=gtypist-$(GTYPIST_VERSION).tar.bz2
GTYPIST_DIR=gtypist-$(GTYPIST_VERSION)
GTYPIST_UNZIP=bzcat
GTYPIST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTYPIST_DESCRIPTION=A universal typing tutor.
GTYPIST_SECTION=misc
GTYPIST_PRIORITY=optional
GTYPIST_DEPENDS=ncurses
GTYPIST_SUGGESTS=bsdgames
GTYPIST_CONFLICTS=

#
# GTYPIST_IPK_VERSION should be incremented when the ipk changes.
#
GTYPIST_IPK_VERSION=1

#
# GTYPIST_CONFFILES should be a list of user-editable files
#GTYPIST_CONFFILES=/opt/etc/gtypist.conf /opt/etc/init.d/SXXgtypist

#
# GTYPIST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GTYPIST_PATCHES=$(GTYPIST_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTYPIST_CPPFLAGS=
GTYPIST_LDFLAGS=

#
# GTYPIST_BUILD_DIR is the directory in which the build is done.
# GTYPIST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTYPIST_IPK_DIR is the directory in which the ipk is built.
# GTYPIST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTYPIST_BUILD_DIR=$(BUILD_DIR)/gtypist
GTYPIST_SOURCE_DIR=$(SOURCE_DIR)/gtypist
GTYPIST_IPK_DIR=$(BUILD_DIR)/gtypist-$(GTYPIST_VERSION)-ipk
GTYPIST_IPK=$(BUILD_DIR)/gtypist_$(GTYPIST_VERSION)-$(GTYPIST_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gtypist-source gtypist-unpack gtypist gtypist-stage gtypist-ipk gtypist-clean gtypist-dirclean gtypist-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTYPIST_SOURCE):
	$(WGET) -P $(@D) $(GTYPIST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtypist-source: $(DL_DIR)/$(GTYPIST_SOURCE) $(GTYPIST_PATCHES)

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
$(GTYPIST_BUILD_DIR)/.configured: $(DL_DIR)/$(GTYPIST_SOURCE) $(GTYPIST_PATCHES) make/gtypist.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(GTYPIST_DIR) $(@D)
	$(GTYPIST_UNZIP) $(DL_DIR)/$(GTYPIST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTYPIST_PATCHES)" ; \
		then cat $(GTYPIST_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GTYPIST_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GTYPIST_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GTYPIST_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTYPIST_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTYPIST_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gtypist-unpack: $(GTYPIST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GTYPIST_BUILD_DIR)/.built: $(GTYPIST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gtypist: $(GTYPIST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTYPIST_BUILD_DIR)/.staged: $(GTYPIST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gtypist-stage: $(GTYPIST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gtypist
#
$(GTYPIST_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gtypist" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTYPIST_PRIORITY)" >>$@
	@echo "Section: $(GTYPIST_SECTION)" >>$@
	@echo "Version: $(GTYPIST_VERSION)-$(GTYPIST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTYPIST_MAINTAINER)" >>$@
	@echo "Source: $(GTYPIST_SITE)/$(GTYPIST_SOURCE)" >>$@
	@echo "Description: $(GTYPIST_DESCRIPTION)" >>$@
	@echo "Depends: $(GTYPIST_DEPENDS)" >>$@
	@echo "Suggests: $(GTYPIST_SUGGESTS)" >>$@
	@echo "Conflicts: $(GTYPIST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTYPIST_IPK_DIR)/opt/sbin or $(GTYPIST_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTYPIST_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GTYPIST_IPK_DIR)/opt/etc/gtypist/...
# Documentation files should be installed in $(GTYPIST_IPK_DIR)/opt/doc/gtypist/...
# Daemon startup scripts should be installed in $(GTYPIST_IPK_DIR)/opt/etc/init.d/S??gtypist
#
# You may need to patch your application to make it use these locations.
#
$(GTYPIST_IPK): $(GTYPIST_BUILD_DIR)/.built
	rm -rf $(GTYPIST_IPK_DIR) $(BUILD_DIR)/gtypist_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTYPIST_BUILD_DIR) DESTDIR=$(GTYPIST_IPK_DIR) install-strip
	sed -i -e '/^#!/s|/usr/bin/perl|/opt/bin/perl|' $(GTYPIST_IPK_DIR)/opt/bin/typefortune
	$(MAKE) $(GTYPIST_IPK_DIR)/CONTROL/control
	echo $(GTYPIST_CONFFILES) | sed -e 's/ /\n/g' > $(GTYPIST_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTYPIST_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtypist-ipk: $(GTYPIST_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtypist-clean:
	rm -f $(GTYPIST_BUILD_DIR)/.built
	-$(MAKE) -C $(GTYPIST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtypist-dirclean:
	rm -rf $(BUILD_DIR)/$(GTYPIST_DIR) $(GTYPIST_BUILD_DIR) $(GTYPIST_IPK_DIR) $(GTYPIST_IPK)
#
#
# Some sanity check for the package.
#
gtypist-check: $(GTYPIST_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
