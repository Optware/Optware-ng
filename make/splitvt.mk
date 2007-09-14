###########################################################
#
# splitvt
#
###########################################################
#
# SPLITVT_VERSION, SPLITVT_SITE and SPLITVT_SOURCE define
# the upstream location of the source code for the package.
# SPLITVT_DIR is the directory which is created when the source
# archive is unpacked.
# SPLITVT_UNZIP is the command used to unzip the source.
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
SPLITVT_SITE=http://www.devolution.com/~slouken/projects/splitvt
SPLITVT_VERSION=1.6.6
SPLITVT_SOURCE=splitvt-$(SPLITVT_VERSION).tar.gz
SPLITVT_DIR=splitvt-$(SPLITVT_VERSION)
SPLITVT_UNZIP=zcat
SPLITVT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPLITVT_DESCRIPTION=This program takes any VT100 terminal window and splits it into two shell windows, one on top and one on bottom.
SPLITVT_SECTION=misc
SPLITVT_PRIORITY=optional
SPLITVT_DEPENDS=ncurses
SPLITVT_SUGGESTS=
SPLITVT_CONFLICTS=

#
# SPLITVT_IPK_VERSION should be incremented when the ipk changes.
#
SPLITVT_IPK_VERSION=1

#
# SPLITVT_CONFFILES should be a list of user-editable files
#SPLITVT_CONFFILES=/opt/etc/splitvt.conf /opt/etc/init.d/SXXsplitvt

#
# SPLITVT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPLITVT_PATCHES=$(SPLITVT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPLITVT_CPPFLAGS=
SPLITVT_LDFLAGS=

#
# SPLITVT_BUILD_DIR is the directory in which the build is done.
# SPLITVT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPLITVT_IPK_DIR is the directory in which the ipk is built.
# SPLITVT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPLITVT_BUILD_DIR=$(BUILD_DIR)/splitvt
SPLITVT_SOURCE_DIR=$(SOURCE_DIR)/splitvt
SPLITVT_IPK_DIR=$(BUILD_DIR)/splitvt-$(SPLITVT_VERSION)-ipk
SPLITVT_IPK=$(BUILD_DIR)/splitvt_$(SPLITVT_VERSION)-$(SPLITVT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: splitvt-source splitvt-unpack splitvt splitvt-stage splitvt-ipk splitvt-clean splitvt-dirclean splitvt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPLITVT_SOURCE):
	$(WGET) -P $(DL_DIR) $(SPLITVT_SITE)/$(SPLITVT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SPLITVT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
splitvt-source: $(DL_DIR)/$(SPLITVT_SOURCE) $(SPLITVT_PATCHES)

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
$(SPLITVT_BUILD_DIR)/.configured: $(DL_DIR)/$(SPLITVT_SOURCE) $(SPLITVT_PATCHES) make/splitvt.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(SPLITVT_DIR) $(SPLITVT_BUILD_DIR)
	$(SPLITVT_UNZIP) $(DL_DIR)/$(SPLITVT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPLITVT_PATCHES)" ; \
		then cat $(SPLITVT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SPLITVT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SPLITVT_DIR)" != "$(SPLITVT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SPLITVT_DIR) $(SPLITVT_BUILD_DIR) ; \
	fi
	cp $(SPLITVT_SOURCE_DIR)/Makefile $(SPLITVT_BUILD_DIR)
#	(cd $(SPLITVT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPLITVT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPLITVT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SPLITVT_BUILD_DIR)/libtool
	touch $@

splitvt-unpack: $(SPLITVT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPLITVT_BUILD_DIR)/.built: $(SPLITVT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(SPLITVT_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPLITVT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPLITVT_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
splitvt: $(SPLITVT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPLITVT_BUILD_DIR)/.staged: $(SPLITVT_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(SPLITVT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

splitvt-stage: $(SPLITVT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/splitvt
#
$(SPLITVT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: splitvt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPLITVT_PRIORITY)" >>$@
	@echo "Section: $(SPLITVT_SECTION)" >>$@
	@echo "Version: $(SPLITVT_VERSION)-$(SPLITVT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPLITVT_MAINTAINER)" >>$@
	@echo "Source: $(SPLITVT_SITE)/$(SPLITVT_SOURCE)" >>$@
	@echo "Description: $(SPLITVT_DESCRIPTION)" >>$@
	@echo "Depends: $(SPLITVT_DEPENDS)" >>$@
	@echo "Suggests: $(SPLITVT_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPLITVT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPLITVT_IPK_DIR)/opt/sbin or $(SPLITVT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPLITVT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SPLITVT_IPK_DIR)/opt/etc/splitvt/...
# Documentation files should be installed in $(SPLITVT_IPK_DIR)/opt/doc/splitvt/...
# Daemon startup scripts should be installed in $(SPLITVT_IPK_DIR)/opt/etc/init.d/S??splitvt
#
# You may need to patch your application to make it use these locations.
#
$(SPLITVT_IPK): $(SPLITVT_BUILD_DIR)/.built
	rm -rf $(SPLITVT_IPK_DIR) $(BUILD_DIR)/splitvt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPLITVT_BUILD_DIR) DESTDIR=$(SPLITVT_IPK_DIR) install
	$(STRIP_COMMAND) $(SPLITVT_IPK_DIR)/opt/bin/splitvt
	$(MAKE) $(SPLITVT_IPK_DIR)/CONTROL/control
	echo $(SPLITVT_CONFFILES) | sed -e 's/ /\n/g' > $(SPLITVT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPLITVT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
splitvt-ipk: $(SPLITVT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
splitvt-clean:
	rm -f $(SPLITVT_BUILD_DIR)/.built
	-$(MAKE) -C $(SPLITVT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
splitvt-dirclean:
	rm -rf $(BUILD_DIR)/$(SPLITVT_DIR) $(SPLITVT_BUILD_DIR) $(SPLITVT_IPK_DIR) $(SPLITVT_IPK)
#
#
# Some sanity check for the package.
#
splitvt-check: $(SPLITVT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SPLITVT_IPK)
