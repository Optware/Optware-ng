###########################################################
#
# slrn
#
###########################################################
#
# SLRN_VERSION, SLRN_SITE and SLRN_SOURCE define
# the upstream location of the source code for the package.
# SLRN_DIR is the directory which is created when the source
# archive is unpacked.
# SLRN_UNZIP is the command used to unzip the source.
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
SLRN_SITE=ftp://space.mit.edu/pub/davis/slrn
SLRN_VERSION=0.9.9p1
SLRN_SOURCE=slrn-$(SLRN_VERSION).tar.gz
SLRN_DIR=slrn-$(SLRN_VERSION)
SLRN_UNZIP=zcat
SLRN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SLRN_DESCRIPTION=slrn (``s-lang read news'') is a newsreader run in console mode.
SLRN_SECTION=news
SLRN_PRIORITY=optional
SLRN_DEPENDS=openssl,slang
SLRN_SUGGESTS=
SLRN_CONFLICTS=

#
# SLRN_IPK_VERSION should be incremented when the ipk changes.
#
SLRN_IPK_VERSION=1

#
# SLRN_CONFFILES should be a list of user-editable files
#SLRN_CONFFILES=/opt/etc/slrn.conf /opt/etc/init.d/SXXslrn

#
# SLRN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SLRN_PATCHES=$(SLRN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SLRN_CPPFLAGS=
SLRN_LDFLAGS=-lslang

#
# SLRN_BUILD_DIR is the directory in which the build is done.
# SLRN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SLRN_IPK_DIR is the directory in which the ipk is built.
# SLRN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SLRN_BUILD_DIR=$(BUILD_DIR)/slrn
SLRN_SOURCE_DIR=$(SOURCE_DIR)/slrn
SLRN_IPK_DIR=$(BUILD_DIR)/slrn-$(SLRN_VERSION)-ipk
SLRN_IPK=$(BUILD_DIR)/slrn_$(SLRN_VERSION)-$(SLRN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: slrn-source slrn-unpack slrn slrn-stage slrn-ipk slrn-clean slrn-dirclean slrn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SLRN_SOURCE):
	$(WGET) -P $(@D) $(SLRN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
slrn-source: $(DL_DIR)/$(SLRN_SOURCE) $(SLRN_PATCHES)

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
$(SLRN_BUILD_DIR)/.configured: $(DL_DIR)/$(SLRN_SOURCE) $(SLRN_PATCHES) make/slrn.mk
	$(MAKE) slang-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(SLRN_DIR) $(SLRN_BUILD_DIR)
	$(SLRN_UNZIP) $(DL_DIR)/$(SLRN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SLRN_PATCHES)" ; \
		then cat $(SLRN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SLRN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SLRN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SLRN_DIR) $(@D) ; \
	fi
	sed -i -e '/^	.*\/chkslang/s/^/#/' \
	       -e '/-m 755/s/ -s//' \
		$(@D)/src/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(SLRN_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(SLRN_LDFLAGS) $(STAGING_LDFLAGS)" \
		slrn_cv_va_copy=yes \
		slrn_cv___va_copy=yes \
		slrn_cv_va_val_copy=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-slang=$(STAGING_PREFIX) \
		--with-ssl=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

slrn-unpack: $(SLRN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SLRN_BUILD_DIR)/.built: $(SLRN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) all RPATH=""
	touch $@

#
# This is the build convenience target.
#
slrn: $(SLRN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SLRN_BUILD_DIR)/.staged: $(SLRN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(SLRN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

slrn-stage: $(SLRN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/slrn
#
$(SLRN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: slrn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SLRN_PRIORITY)" >>$@
	@echo "Section: $(SLRN_SECTION)" >>$@
	@echo "Version: $(SLRN_VERSION)-$(SLRN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SLRN_MAINTAINER)" >>$@
	@echo "Source: $(SLRN_SITE)/$(SLRN_SOURCE)" >>$@
	@echo "Description: $(SLRN_DESCRIPTION)" >>$@
	@echo "Depends: $(SLRN_DEPENDS)" >>$@
	@echo "Suggests: $(SLRN_SUGGESTS)" >>$@
	@echo "Conflicts: $(SLRN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SLRN_IPK_DIR)/opt/sbin or $(SLRN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SLRN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SLRN_IPK_DIR)/opt/etc/slrn/...
# Documentation files should be installed in $(SLRN_IPK_DIR)/opt/doc/slrn/...
# Daemon startup scripts should be installed in $(SLRN_IPK_DIR)/opt/etc/init.d/S??slrn
#
# You may need to patch your application to make it use these locations.
#
$(SLRN_IPK): $(SLRN_BUILD_DIR)/.built
	rm -rf $(SLRN_IPK_DIR) $(BUILD_DIR)/slrn_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SLRN_BUILD_DIR) DESTDIR=$(SLRN_IPK_DIR) install
	$(STRIP_COMMAND) $(SLRN_IPK_DIR)/opt/bin/slrn
	$(MAKE) $(SLRN_IPK_DIR)/CONTROL/control
	echo $(SLRN_CONFFILES) | sed -e 's/ /\n/g' > $(SLRN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SLRN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
slrn-ipk: $(SLRN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
slrn-clean:
	rm -f $(SLRN_BUILD_DIR)/.built
	-$(MAKE) -C $(SLRN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
slrn-dirclean:
	rm -rf $(BUILD_DIR)/$(SLRN_DIR) $(SLRN_BUILD_DIR) $(SLRN_IPK_DIR) $(SLRN_IPK)
#
#
# Some sanity check for the package.
#
slrn-check: $(SLRN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
