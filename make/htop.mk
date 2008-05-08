###########################################################
#
# htop
#
###########################################################
#
# HTOP_VERSION, HTOP_SITE and HTOP_SOURCE define
# the upstream location of the source code for the package.
# HTOP_DIR is the directory which is created when the source
# archive is unpacked.
# HTOP_UNZIP is the command used to unzip the source.
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
HTOP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/htop
HTOP_VERSION=0.8
HTOP_IPK_VERSION=1
HTOP_SOURCE=htop-$(HTOP_VERSION).tar.gz
HTOP_DIR=htop-$(HTOP_VERSION)
HTOP_UNZIP=zcat
HTOP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HTOP_DESCRIPTION=An interactive process viewer.
HTOP_SECTION=misc
HTOP_PRIORITY=optional
HTOP_DEPENDS=ncurses
HTOP_SUGGESTS=
HTOP_CONFLICTS=


#
# HTOP_CONFFILES should be a list of user-editable files
#HTOP_CONFFILES=/opt/etc/htop.conf /opt/etc/init.d/SXXhtop

#
# HTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (modutils, $(filter modutils, $(PACKAGES)))
HTOP_PATCHES=$(HTOP_SOURCE_DIR)/linux24-child.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HTOP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses -DDEBUG
HTOP_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
HTOP_CONFIGURE_ENV=\
	ac_cv_file__proc_stat=yes \
	ac_cv_file__proc_meminfo=yes \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes
endif
ifeq (modutils, $(filter modutils, $(PACKAGES)))
HTOP_CONFIGURE_ARGS=--enable-plpa-emulate
endif

#
# HTOP_BUILD_DIR is the directory in which the build is done.
# HTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HTOP_IPK_DIR is the directory in which the ipk is built.
# HTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HTOP_BUILD_DIR=$(BUILD_DIR)/htop
HTOP_SOURCE_DIR=$(SOURCE_DIR)/htop
HTOP_IPK_DIR=$(BUILD_DIR)/htop-$(HTOP_VERSION)-ipk
HTOP_IPK=$(BUILD_DIR)/htop_$(HTOP_VERSION)-$(HTOP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: htop-source htop-unpack htop htop-stage htop-ipk htop-clean htop-dirclean htop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HTOP_SOURCE):
	$(WGET) -P $(@D) $(HTOP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
htop-source: $(DL_DIR)/$(HTOP_SOURCE) $(HTOP_PATCHES)

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
$(HTOP_BUILD_DIR)/.configured: $(DL_DIR)/$(HTOP_SOURCE) $(HTOP_PATCHES) make/htop.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(HTOP_DIR) $(HTOP_BUILD_DIR)
	$(HTOP_UNZIP) $(DL_DIR)/$(HTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HTOP_PATCHES)" ; \
		then cat $(HTOP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HTOP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HTOP_DIR)" != "$(HTOP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(HTOP_DIR) $(HTOP_BUILD_DIR) ; \
	fi
	(cd $(HTOP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HTOP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HTOP_LDFLAGS)" \
		$(HTOP_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		$(HTOP_CONFIGURE_ARGS) \
	)
#	$(PATCH_LIBTOOL) $(HTOP_BUILD_DIR)/libtool
	touch $@

htop-unpack: $(HTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HTOP_BUILD_DIR)/.built: $(HTOP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(HTOP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
htop: $(HTOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HTOP_BUILD_DIR)/.staged: $(HTOP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(HTOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

htop-stage: $(HTOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/htop
#
$(HTOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: htop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HTOP_PRIORITY)" >>$@
	@echo "Section: $(HTOP_SECTION)" >>$@
	@echo "Version: $(HTOP_VERSION)-$(HTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HTOP_MAINTAINER)" >>$@
	@echo "Source: $(HTOP_SITE)/$(HTOP_SOURCE)" >>$@
	@echo "Description: $(HTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(HTOP_DEPENDS)" >>$@
	@echo "Suggests: $(HTOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(HTOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HTOP_IPK_DIR)/opt/sbin or $(HTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HTOP_IPK_DIR)/opt/etc/htop/...
# Documentation files should be installed in $(HTOP_IPK_DIR)/opt/doc/htop/...
# Daemon startup scripts should be installed in $(HTOP_IPK_DIR)/opt/etc/init.d/S??htop
#
# You may need to patch your application to make it use these locations.
#
$(HTOP_IPK): $(HTOP_BUILD_DIR)/.built
	rm -rf $(HTOP_IPK_DIR) $(BUILD_DIR)/htop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HTOP_BUILD_DIR) DESTDIR=$(HTOP_IPK_DIR) install-strip
	$(MAKE) $(HTOP_IPK_DIR)/CONTROL/control
#	echo $(HTOP_CONFFILES) | sed -e 's/ /\n/g' > $(HTOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
htop-ipk: $(HTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
htop-clean:
	rm -f $(HTOP_BUILD_DIR)/.built
	-$(MAKE) -C $(HTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
htop-dirclean:
	rm -rf $(BUILD_DIR)/$(HTOP_DIR) $(HTOP_BUILD_DIR) $(HTOP_IPK_DIR) $(HTOP_IPK)
#
#
# Some sanity check for the package.
#
htop-check: $(HTOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HTOP_IPK)
