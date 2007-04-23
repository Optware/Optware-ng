###########################################################
#
# fann
#
###########################################################
#
# FANN_VERSION, FANN_SITE and FANN_SOURCE define
# the upstream location of the source code for the package.
# FANN_DIR is the directory which is created when the source
# archive is unpacked.
# FANN_UNZIP is the command used to unzip the source.
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
FANN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/fann
FANN_VERSION=2.0.0
FANN_SOURCE=fann-$(FANN_VERSION).tar.bz2
FANN_DIR=fann-$(FANN_VERSION)
FANN_UNZIP=bzcat
FANN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FANN_DESCRIPTION=Fast Artificial Neural Network Library is a free open source neural network library.
FANN_SECTION=libs
FANN_PRIORITY=optional
FANN_DEPENDS=
FANN_SUGGESTS=
FANN_CONFLICTS=

#
# FANN_IPK_VERSION should be incremented when the ipk changes.
#
FANN_IPK_VERSION=1

#
# FANN_CONFFILES should be a list of user-editable files
#FANN_CONFFILES=/opt/etc/fann.conf /opt/etc/init.d/SXXfann

#
# FANN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FANN_PATCHES=$(FANN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FANN_CPPFLAGS=
FANN_LDFLAGS=

#
# FANN_BUILD_DIR is the directory in which the build is done.
# FANN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FANN_IPK_DIR is the directory in which the ipk is built.
# FANN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FANN_BUILD_DIR=$(BUILD_DIR)/fann
FANN_SOURCE_DIR=$(SOURCE_DIR)/fann
FANN_IPK_DIR=$(BUILD_DIR)/fann-$(FANN_VERSION)-ipk
FANN_IPK=$(BUILD_DIR)/fann_$(FANN_VERSION)-$(FANN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fann-source fann-unpack fann fann-stage fann-ipk fann-clean fann-dirclean fann-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FANN_SOURCE):
	$(WGET) -P $(DL_DIR) $(FANN_SITE)/$(FANN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FANN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fann-source: $(DL_DIR)/$(FANN_SOURCE) $(FANN_PATCHES)

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
$(FANN_BUILD_DIR)/.configured: $(DL_DIR)/$(FANN_SOURCE) $(FANN_PATCHES) make/fann.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FANN_DIR) $(FANN_BUILD_DIR)
	$(FANN_UNZIP) $(DL_DIR)/$(FANN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FANN_PATCHES)" ; \
		then cat $(FANN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FANN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FANN_DIR)" != "$(FANN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FANN_DIR) $(FANN_BUILD_DIR) ; \
	fi
	(cd $(FANN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FANN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FANN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(FANN_BUILD_DIR)/libtool
	touch $@

fann-unpack: $(FANN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FANN_BUILD_DIR)/.built: $(FANN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FANN_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
fann: $(FANN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FANN_BUILD_DIR)/.staged: $(FANN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FANN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e '/^prefix=/s|=/opt|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fann.pc
	touch $@

fann-stage: $(FANN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fann
#
$(FANN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fann" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FANN_PRIORITY)" >>$@
	@echo "Section: $(FANN_SECTION)" >>$@
	@echo "Version: $(FANN_VERSION)-$(FANN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FANN_MAINTAINER)" >>$@
	@echo "Source: $(FANN_SITE)/$(FANN_SOURCE)" >>$@
	@echo "Description: $(FANN_DESCRIPTION)" >>$@
	@echo "Depends: $(FANN_DEPENDS)" >>$@
	@echo "Suggests: $(FANN_SUGGESTS)" >>$@
	@echo "Conflicts: $(FANN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FANN_IPK_DIR)/opt/sbin or $(FANN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FANN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FANN_IPK_DIR)/opt/etc/fann/...
# Documentation files should be installed in $(FANN_IPK_DIR)/opt/doc/fann/...
# Daemon startup scripts should be installed in $(FANN_IPK_DIR)/opt/etc/init.d/S??fann
#
# You may need to patch your application to make it use these locations.
#
$(FANN_IPK): $(FANN_BUILD_DIR)/.built
	rm -rf $(FANN_IPK_DIR) $(BUILD_DIR)/fann_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FANN_BUILD_DIR) DESTDIR=$(FANN_IPK_DIR) install-strip
	$(MAKE) $(FANN_IPK_DIR)/CONTROL/control
	echo $(FANN_CONFFILES) | sed -e 's/ /\n/g' > $(FANN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FANN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fann-ipk: $(FANN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fann-clean:
	rm -f $(FANN_BUILD_DIR)/.built
	-$(MAKE) -C $(FANN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fann-dirclean:
	rm -rf $(BUILD_DIR)/$(FANN_DIR) $(FANN_BUILD_DIR) $(FANN_IPK_DIR) $(FANN_IPK)
#
#
# Some sanity check for the package.
#
fann-check: $(FANN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FANN_IPK)
