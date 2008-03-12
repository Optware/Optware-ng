###########################################################
#
# surfraw
#
###########################################################
#
# SURFRAW_VERSION, SURFRAW_SITE and SURFRAW_SOURCE define
# the upstream location of the source code for the package.
# SURFRAW_DIR is the directory which is created when the source
# archive is unpacked.
# SURFRAW_UNZIP is the command used to unzip the source.
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
SURFRAW_SITE=http://surfraw.alioth.debian.org/dist
SURFRAW_VERSION=2.2.1
SURFRAW_SOURCE=surfraw-$(SURFRAW_VERSION).tar.gz
SURFRAW_DIR=surfraw-$(SURFRAW_VERSION)
SURFRAW_UNZIP=zcat
SURFRAW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SURFRAW_DESCRIPTION=Surfraw (Shell Users Revolutionary Front Rage Against the Web) provides CLI to a variety of popular Web search engines and sites.
SURFRAW_SECTION=web
SURFRAW_PRIORITY=optional
SURFRAW_DEPENDS=
ifneq (, $(filter perl, $(PACKAGES)))
SURFRAW_SUGGESTS=perl
else
SURFRAW_SUGGESTS=
endif
SURFRAW_CONFLICTS=

#
# SURFRAW_IPK_VERSION should be incremented when the ipk changes.
#
SURFRAW_IPK_VERSION=1

#
# SURFRAW_CONFFILES should be a list of user-editable files
#SURFRAW_CONFFILES=/opt/etc/surfraw.conf /opt/etc/init.d/SXXsurfraw

#
# SURFRAW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SURFRAW_PATCHES=$(SURFRAW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SURFRAW_CPPFLAGS=
SURFRAW_LDFLAGS=

#
# SURFRAW_BUILD_DIR is the directory in which the build is done.
# SURFRAW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SURFRAW_IPK_DIR is the directory in which the ipk is built.
# SURFRAW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SURFRAW_BUILD_DIR=$(BUILD_DIR)/surfraw
SURFRAW_SOURCE_DIR=$(SOURCE_DIR)/surfraw
SURFRAW_IPK_DIR=$(BUILD_DIR)/surfraw-$(SURFRAW_VERSION)-ipk
SURFRAW_IPK=$(BUILD_DIR)/surfraw_$(SURFRAW_VERSION)-$(SURFRAW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: surfraw-source surfraw-unpack surfraw surfraw-stage surfraw-ipk surfraw-clean surfraw-dirclean surfraw-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SURFRAW_SOURCE):
	$(WGET) -P $(@D) $(SURFRAW_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
surfraw-source: $(DL_DIR)/$(SURFRAW_SOURCE) $(SURFRAW_PATCHES)

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
$(SURFRAW_BUILD_DIR)/.configured: $(DL_DIR)/$(SURFRAW_SOURCE) $(SURFRAW_PATCHES) make/surfraw.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SURFRAW_DIR) $(@D)
	$(SURFRAW_UNZIP) $(DL_DIR)/$(SURFRAW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SURFRAW_PATCHES)" ; \
		then cat $(SURFRAW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SURFRAW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SURFRAW_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SURFRAW_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SURFRAW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SURFRAW_LDFLAGS)" \
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

surfraw-unpack: $(SURFRAW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SURFRAW_BUILD_DIR)/.built: $(SURFRAW_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
surfraw: $(SURFRAW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SURFRAW_BUILD_DIR)/.staged: $(SURFRAW_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

surfraw-stage: $(SURFRAW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/surfraw
#
$(SURFRAW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: surfraw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SURFRAW_PRIORITY)" >>$@
	@echo "Section: $(SURFRAW_SECTION)" >>$@
	@echo "Version: $(SURFRAW_VERSION)-$(SURFRAW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SURFRAW_MAINTAINER)" >>$@
	@echo "Source: $(SURFRAW_SITE)/$(SURFRAW_SOURCE)" >>$@
	@echo "Description: $(SURFRAW_DESCRIPTION)" >>$@
	@echo "Depends: $(SURFRAW_DEPENDS)" >>$@
	@echo "Suggests: $(SURFRAW_SUGGESTS)" >>$@
	@echo "Conflicts: $(SURFRAW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SURFRAW_IPK_DIR)/opt/sbin or $(SURFRAW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SURFRAW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SURFRAW_IPK_DIR)/opt/etc/surfraw/...
# Documentation files should be installed in $(SURFRAW_IPK_DIR)/opt/doc/surfraw/...
# Daemon startup scripts should be installed in $(SURFRAW_IPK_DIR)/opt/etc/init.d/S??surfraw
#
# You may need to patch your application to make it use these locations.
#
$(SURFRAW_IPK): $(SURFRAW_BUILD_DIR)/.built
	rm -rf $(SURFRAW_IPK_DIR) $(BUILD_DIR)/surfraw_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SURFRAW_BUILD_DIR) DESTDIR=$(SURFRAW_IPK_DIR) install-strip
	sed -i -e '/^#!\/usr\/bin\/perl/s|/usr/|/opt/|' $(SURFRAW_IPK_DIR)/opt/bin/*
	$(MAKE) $(SURFRAW_IPK_DIR)/CONTROL/control
	echo $(SURFRAW_CONFFILES) | sed -e 's/ /\n/g' > $(SURFRAW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SURFRAW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
surfraw-ipk: $(SURFRAW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
surfraw-clean:
	rm -f $(SURFRAW_BUILD_DIR)/.built
	-$(MAKE) -C $(SURFRAW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
surfraw-dirclean:
	rm -rf $(BUILD_DIR)/$(SURFRAW_DIR) $(SURFRAW_BUILD_DIR) $(SURFRAW_IPK_DIR) $(SURFRAW_IPK)
#
#
# Some sanity check for the package.
#
surfraw-check: $(SURFRAW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SURFRAW_IPK)
