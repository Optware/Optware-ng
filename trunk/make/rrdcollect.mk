###########################################################
#
# rrdcollect
#
###########################################################
#
# RRDCOLLECT_VERSION, RRDCOLLECT_SITE and RRDCOLLECT_SOURCE define
# the upstream location of the source code for the package.
# RRDCOLLECT_DIR is the directory which is created when the source
# archive is unpacked.
# RRDCOLLECT_UNZIP is the command used to unzip the source.
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
RRDCOLLECT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/rrdcollect
RRDCOLLECT_VERSION=0.2.3
RRDCOLLECT_SOURCE=rrdcollect-$(RRDCOLLECT_VERSION).tar.gz
RRDCOLLECT_DIR=rrdcollect-$(RRDCOLLECT_VERSION)
RRDCOLLECT_UNZIP=zcat
RRDCOLLECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RRDCOLLECT_DESCRIPTION=A system for reading system statistical data and feeding it to RRDtool
RRDCOLLECT_SECTION=admin
RRDCOLLECT_PRIORITY=optional
RRDCOLLECT_DEPENDS=rrdtool, pcre
RRDCOLLECT_SUGGESTS=
RRDCOLLECT_CONFLICTS=

#
# RRDCOLLECT_IPK_VERSION should be incremented when the ipk changes.
#
RRDCOLLECT_IPK_VERSION=4

#
# RRDCOLLECT_CONFFILES should be a list of user-editable files
RRDCOLLECT_CONFFILES=/opt/etc/rrdcollect.conf /opt/etc/init.d/S95rrdcollect

#
# RRDCOLLECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RRDCOLLECT_PATCHES= \
	$(RRDCOLLECT_SOURCE_DIR)/rrdcollect-scan.patch \
	$(RRDCOLLECT_SOURCE_DIR)/loglevel.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RRDCOLLECT_CPPFLAGS=
RRDCOLLECT_LDFLAGS=

#
# RRDCOLLECT_BUILD_DIR is the directory in which the build is done.
# RRDCOLLECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RRDCOLLECT_IPK_DIR is the directory in which the ipk is built.
# RRDCOLLECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RRDCOLLECT_BUILD_DIR=$(BUILD_DIR)/rrdcollect
RRDCOLLECT_SOURCE_DIR=$(SOURCE_DIR)/rrdcollect
RRDCOLLECT_IPK_DIR=$(BUILD_DIR)/rrdcollect-$(RRDCOLLECT_VERSION)-ipk
RRDCOLLECT_IPK=$(BUILD_DIR)/rrdcollect_$(RRDCOLLECT_VERSION)-$(RRDCOLLECT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rrdcollect-source rrdcollect-unpack rrdcollect rrdcollect-stage rrdcollect-ipk rrdcollect-clean rrdcollect-dirclean rrdcollect-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RRDCOLLECT_SOURCE):
	$(WGET) -P $(DL_DIR) $(RRDCOLLECT_SITE)/$(RRDCOLLECT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rrdcollect-source: $(DL_DIR)/$(RRDCOLLECT_SOURCE) $(RRDCOLLECT_PATCHES)

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
$(RRDCOLLECT_BUILD_DIR)/.configured: $(DL_DIR)/$(RRDCOLLECT_SOURCE) $(RRDCOLLECT_PATCHES) make/rrdcollect.mk
	$(MAKE) rrdtool-stage pcre-stage
	rm -rf $(BUILD_DIR)/$(RRDCOLLECT_DIR) $(RRDCOLLECT_BUILD_DIR)
	$(RRDCOLLECT_UNZIP) $(DL_DIR)/$(RRDCOLLECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RRDCOLLECT_PATCHES)" ; \
		then cat $(RRDCOLLECT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RRDCOLLECT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RRDCOLLECT_DIR)" != "$(RRDCOLLECT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RRDCOLLECT_DIR) $(RRDCOLLECT_BUILD_DIR) ; \
	fi
	(cd $(RRDCOLLECT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RRDCOLLECT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RRDCOLLECT_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-rpath \
		--enable-exec \
		--with-gnu-ld \
		--with-librrd \
	)
#	$(PATCH_LIBTOOL) $(RRDCOLLECT_BUILD_DIR)/libtool
	touch $(RRDCOLLECT_BUILD_DIR)/.configured

rrdcollect-unpack: $(RRDCOLLECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RRDCOLLECT_BUILD_DIR)/.built: $(RRDCOLLECT_BUILD_DIR)/.configured
	rm -f $(RRDCOLLECT_BUILD_DIR)/.built
	$(MAKE) -C $(RRDCOLLECT_BUILD_DIR)
	touch $(RRDCOLLECT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rrdcollect: $(RRDCOLLECT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RRDCOLLECT_BUILD_DIR)/.staged: $(RRDCOLLECT_BUILD_DIR)/.built
	rm -f $(RRDCOLLECT_BUILD_DIR)/.staged
	$(MAKE) -C $(RRDCOLLECT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RRDCOLLECT_BUILD_DIR)/.staged

rrdcollect-stage: $(RRDCOLLECT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rrdcollect
#
$(RRDCOLLECT_IPK_DIR)/CONTROL/control:
	@install -d $(RRDCOLLECT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rrdcollect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RRDCOLLECT_PRIORITY)" >>$@
	@echo "Section: $(RRDCOLLECT_SECTION)" >>$@
	@echo "Version: $(RRDCOLLECT_VERSION)-$(RRDCOLLECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RRDCOLLECT_MAINTAINER)" >>$@
	@echo "Source: $(RRDCOLLECT_SITE)/$(RRDCOLLECT_SOURCE)" >>$@
	@echo "Description: $(RRDCOLLECT_DESCRIPTION)" >>$@
	@echo "Depends: $(RRDCOLLECT_DEPENDS)" >>$@
	@echo "Suggests: $(RRDCOLLECT_SUGGESTS)" >>$@
	@echo "Conflicts: $(RRDCOLLECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RRDCOLLECT_IPK_DIR)/opt/sbin or $(RRDCOLLECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RRDCOLLECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RRDCOLLECT_IPK_DIR)/opt/etc/rrdcollect/...
# Documentation files should be installed in $(RRDCOLLECT_IPK_DIR)/opt/doc/rrdcollect/...
# Daemon startup scripts should be installed in $(RRDCOLLECT_IPK_DIR)/opt/etc/init.d/S??rrdcollect
#
# You may need to patch your application to make it use these locations.
#
$(RRDCOLLECT_IPK): $(RRDCOLLECT_BUILD_DIR)/.built
	rm -rf $(RRDCOLLECT_IPK_DIR) $(BUILD_DIR)/rrdcollect_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RRDCOLLECT_BUILD_DIR) DESTDIR=$(RRDCOLLECT_IPK_DIR) install-strip
	install -d $(RRDCOLLECT_IPK_DIR)/opt/etc/
	install -m 644  $(RRDCOLLECT_SOURCE_DIR)/rrdcollect.conf  $(RRDCOLLECT_IPK_DIR)/opt/etc
	install -d $(RRDCOLLECT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(RRDCOLLECT_SOURCE_DIR)/rc.rrdcollect $(RRDCOLLECT_IPK_DIR)/opt/etc/init.d/S95rrdcollect
	$(MAKE) $(RRDCOLLECT_IPK_DIR)/CONTROL/control
	install -m 755 $(RRDCOLLECT_SOURCE_DIR)/postinst $(RRDCOLLECT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RRDCOLLECT_SOURCE_DIR)/prerm $(RRDCOLLECT_IPK_DIR)/CONTROL/prerm
	echo $(RRDCOLLECT_CONFFILES) | sed -e 's/ /\n/g' > $(RRDCOLLECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RRDCOLLECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rrdcollect-ipk: $(RRDCOLLECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rrdcollect-clean:
	rm -f $(RRDCOLLECT_BUILD_DIR)/.built
	-$(MAKE) -C $(RRDCOLLECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rrdcollect-dirclean:
	rm -rf $(BUILD_DIR)/$(RRDCOLLECT_DIR) $(RRDCOLLECT_BUILD_DIR) $(RRDCOLLECT_IPK_DIR) $(RRDCOLLECT_IPK)

#
#
# Some sanity check for the package.
#
rrdcollect-check: $(RRDCOLLECT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RRDCOLLECT_IPK)
