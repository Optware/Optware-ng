###########################################################
#
# tig
#
###########################################################
#
# TIG_VERSION, TIG_SITE and TIG_SOURCE define
# the upstream location of the source code for the package.
# TIG_DIR is the directory which is created when the source
# archive is unpacked.
# TIG_UNZIP is the command used to unzip the source.
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
TIG_SITE=http://jonas.nitro.dk/tig/releases
TIG_VERSION=0.12
TIG_SOURCE=tig-$(TIG_VERSION).tar.gz
TIG_DIR=tig-$(TIG_VERSION)
TIG_UNZIP=zcat
TIG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TIG_DESCRIPTION=Tig is a git repository browser that additionally can act as a pager for output from various git commands.
TIG_SECTION=devel
TIG_PRIORITY=optional
TIG_DEPENDS=git, ncursesw
TIG_SUGGESTS=
TIG_CONFLICTS=

#
# TIG_IPK_VERSION should be incremented when the ipk changes.
#
TIG_IPK_VERSION=1

#
# TIG_CONFFILES should be a list of user-editable files
#TIG_CONFFILES=/opt/etc/tig.conf /opt/etc/init.d/SXXtig

#
# TIG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TIG_PATCHES=$(TIG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TIG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncursesw
TIG_LDFLAGS=

#
# TIG_BUILD_DIR is the directory in which the build is done.
# TIG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TIG_IPK_DIR is the directory in which the ipk is built.
# TIG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TIG_BUILD_DIR=$(BUILD_DIR)/tig
TIG_SOURCE_DIR=$(SOURCE_DIR)/tig
TIG_IPK_DIR=$(BUILD_DIR)/tig-$(TIG_VERSION)-ipk
TIG_IPK=$(BUILD_DIR)/tig_$(TIG_VERSION)-$(TIG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tig-source tig-unpack tig tig-stage tig-ipk tig-clean tig-dirclean tig-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TIG_SOURCE):
	$(WGET) -P $(DL_DIR) $(TIG_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tig-source: $(DL_DIR)/$(TIG_SOURCE) $(TIG_PATCHES)

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
$(TIG_BUILD_DIR)/.configured: $(DL_DIR)/$(TIG_SOURCE) $(TIG_PATCHES) make/tig.mk
	$(MAKE) ncursesw-stage
	rm -rf $(BUILD_DIR)/$(TIG_DIR) $(@D)
	$(TIG_UNZIP) $(DL_DIR)/$(TIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TIG_PATCHES)" ; \
		then cat $(TIG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TIG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TIG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TIG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TIG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TIG_LDFLAGS)" \
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

tig-unpack: $(TIG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TIG_BUILD_DIR)/.built: $(TIG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tig: $(TIG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TIG_BUILD_DIR)/.staged: $(TIG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tig-stage: $(TIG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tig
#
$(TIG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TIG_PRIORITY)" >>$@
	@echo "Section: $(TIG_SECTION)" >>$@
	@echo "Version: $(TIG_VERSION)-$(TIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TIG_MAINTAINER)" >>$@
	@echo "Source: $(TIG_SITE)/$(TIG_SOURCE)" >>$@
	@echo "Description: $(TIG_DESCRIPTION)" >>$@
	@echo "Depends: $(TIG_DEPENDS)" >>$@
	@echo "Suggests: $(TIG_SUGGESTS)" >>$@
	@echo "Conflicts: $(TIG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TIG_IPK_DIR)/opt/sbin or $(TIG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TIG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TIG_IPK_DIR)/opt/etc/tig/...
# Documentation files should be installed in $(TIG_IPK_DIR)/opt/doc/tig/...
# Daemon startup scripts should be installed in $(TIG_IPK_DIR)/opt/etc/init.d/S??tig
#
# You may need to patch your application to make it use these locations.
#
$(TIG_IPK): $(TIG_BUILD_DIR)/.built
	rm -rf $(TIG_IPK_DIR) $(BUILD_DIR)/tig_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TIG_BUILD_DIR) DESTDIR=$(TIG_IPK_DIR) install install-doc-man
	$(STRIP_COMMAND) $(TIG_IPK_DIR)/opt/bin/tig
	$(MAKE) $(TIG_IPK_DIR)/CONTROL/control
	echo $(TIG_CONFFILES) | sed -e 's/ /\n/g' > $(TIG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TIG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tig-ipk: $(TIG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tig-clean:
	rm -f $(TIG_BUILD_DIR)/.built
	-$(MAKE) -C $(TIG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tig-dirclean:
	rm -rf $(BUILD_DIR)/$(TIG_DIR) $(TIG_BUILD_DIR) $(TIG_IPK_DIR) $(TIG_IPK)
#
#
# Some sanity check for the package.
#
tig-check: $(TIG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TIG_IPK)
