###########################################################
#
# tre
#
###########################################################
#
# TRE_VERSION, TRE_SITE and TRE_SOURCE define
# the upstream location of the source code for the package.
# TRE_DIR is the directory which is created when the source
# archive is unpacked.
# TRE_UNZIP is the command used to unzip the source.
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
TRE_SITE=http://laurikari.net/tre
TRE_VERSION=0.7.5
TRE_SOURCE=tre-$(TRE_VERSION).tar.bz2
TRE_DIR=tre-$(TRE_VERSION)
TRE_UNZIP=bzcat
TRE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TRE_DESCRIPTION=a lightweight, robust, efficient, portable, and POSIX compliant regexp matching library.
TRE_SECTION=lib
TRE_PRIORITY=optional
TRE_DEPENDS=
TRE_SUGGESTS=
TRE_CONFLICTS=

#
# TRE_IPK_VERSION should be incremented when the ipk changes.
#
TRE_IPK_VERSION=1

#
# TRE_CONFFILES should be a list of user-editable files
#TRE_CONFFILES=/opt/etc/tre.conf /opt/etc/init.d/SXXtre

#
# TRE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TRE_PATCHES=$(TRE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRE_CPPFLAGS=
TRE_LDFLAGS=

#
# TRE_BUILD_DIR is the directory in which the build is done.
# TRE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRE_IPK_DIR is the directory in which the ipk is built.
# TRE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRE_BUILD_DIR=$(BUILD_DIR)/tre
TRE_SOURCE_DIR=$(SOURCE_DIR)/tre
TRE_IPK_DIR=$(BUILD_DIR)/tre-$(TRE_VERSION)-ipk
TRE_IPK=$(BUILD_DIR)/tre_$(TRE_VERSION)-$(TRE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tre-source tre-unpack tre tre-stage tre-ipk tre-clean tre-dirclean tre-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TRE_SOURCE):
	$(WGET) -P $(DL_DIR) $(TRE_SITE)/$(TRE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TRE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tre-source: $(DL_DIR)/$(TRE_SOURCE) $(TRE_PATCHES)

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
$(TRE_BUILD_DIR)/.configured: $(DL_DIR)/$(TRE_SOURCE) $(TRE_PATCHES) make/tre.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TRE_DIR) $(TRE_BUILD_DIR)
	$(TRE_UNZIP) $(DL_DIR)/$(TRE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRE_PATCHES)" ; \
		then cat $(TRE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TRE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRE_DIR)" != "$(TRE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TRE_DIR) $(TRE_BUILD_DIR) ; \
	fi
	(cd $(TRE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--program-transform-name="" \
	)
	$(PATCH_LIBTOOL) $(TRE_BUILD_DIR)/libtool
	touch $@

tre-unpack: $(TRE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRE_BUILD_DIR)/.built: $(TRE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TRE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tre: $(TRE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TRE_BUILD_DIR)/.staged: $(TRE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TRE_BUILD_DIR) DESTDIR=$(STAGING_DIR) SUBDIRS=lib install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/tre.pc
	touch $@

tre-stage: $(TRE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tre
#
$(TRE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tre" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRE_PRIORITY)" >>$@
	@echo "Section: $(TRE_SECTION)" >>$@
	@echo "Version: $(TRE_VERSION)-$(TRE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TRE_MAINTAINER)" >>$@
	@echo "Source: $(TRE_SITE)/$(TRE_SOURCE)" >>$@
	@echo "Description: $(TRE_DESCRIPTION)" >>$@
	@echo "Depends: $(TRE_DEPENDS)" >>$@
	@echo "Suggests: $(TRE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRE_IPK_DIR)/opt/sbin or $(TRE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRE_IPK_DIR)/opt/etc/tre/...
# Documentation files should be installed in $(TRE_IPK_DIR)/opt/doc/tre/...
# Daemon startup scripts should be installed in $(TRE_IPK_DIR)/opt/etc/init.d/S??tre
#
# You may need to patch your application to make it use these locations.
#
$(TRE_IPK): $(TRE_BUILD_DIR)/.built
	rm -rf $(TRE_IPK_DIR) $(BUILD_DIR)/tre_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TRE_BUILD_DIR) install-strip DESTDIR=$(TRE_IPK_DIR)
	rm -f $(TRE_IPK_DIR)/opt/lib/libtre.la
	$(MAKE) $(TRE_IPK_DIR)/CONTROL/control
	echo $(TRE_CONFFILES) | sed -e 's/ /\n/g' > $(TRE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tre-ipk: $(TRE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tre-clean:
	rm -f $(TRE_BUILD_DIR)/.built
	-$(MAKE) -C $(TRE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tre-dirclean:
	rm -rf $(BUILD_DIR)/$(TRE_DIR) $(TRE_BUILD_DIR) $(TRE_IPK_DIR) $(TRE_IPK)
#
#
# Some sanity check for the package.
#
tre-check: $(TRE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRE_IPK)
