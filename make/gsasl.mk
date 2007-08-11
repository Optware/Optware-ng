###########################################################
#
# gsasl
#
###########################################################
#
# GSASL_VERSION, GSASL_SITE and GSASL_SOURCE define
# the upstream location of the source code for the package.
# GSASL_DIR is the directory which is created when the source
# archive is unpacked.
# GSASL_UNZIP is the command used to unzip the source.
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
GSASL_SITE=http://josefsson.org/gsasl/releases
GSASL_VERSION=0.2.20
GSASL_SOURCE=gsasl-$(GSASL_VERSION).tar.gz
GSASL_DIR=gsasl-$(GSASL_VERSION)
GSASL_UNZIP=zcat
GSASL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GSASL_DESCRIPTION=GNU SASL command line utility.
GSASL_SECTION=util
GSASL_PRIORITY=optional

ifeq (libidn, $(filter libidn, $(PACKAGES)))
LIBGSASL_DEPENDS=libidn
endif
LIBGSASL_SUGGESTS=
LIBGSASL_CONFLICTS=

GSASL_DEPENDS=libgsasl, readline, ncurses
GSASL_SUGGESTS=
GSASL_CONFLICTS=

#
# GSASL_IPK_VERSION should be incremented when the ipk changes.
#
GSASL_IPK_VERSION=1

#
# GSASL_CONFFILES should be a list of user-editable files
#GSASL_CONFFILES=/opt/etc/gsasl.conf /opt/etc/init.d/SXXgsasl

#
# GSASL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GSASL_PATCHES=$(GSASL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GSASL_CPPFLAGS=
GSASL_LDFLAGS=

ifeq (libidn, $(filter libidn, $(PACKAGES)))
GSASL_CONFIG_OPTS=--without-libidn-prefix
endif

#
# GSASL_BUILD_DIR is the directory in which the build is done.
# GSASL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GSASL_IPK_DIR is the directory in which the ipk is built.
# GSASL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GSASL_BUILD_DIR=$(BUILD_DIR)/gsasl
GSASL_SOURCE_DIR=$(SOURCE_DIR)/gsasl

GSASL_IPK_DIR=$(BUILD_DIR)/gsasl-$(GSASL_VERSION)-ipk
GSASL_IPK=$(BUILD_DIR)/gsasl_$(GSASL_VERSION)-$(GSASL_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBGSASL_IPK_DIR=$(BUILD_DIR)/libgsasl-$(GSASL_VERSION)-ipk
LIBGSASL_IPK=$(BUILD_DIR)/libgsasl_$(GSASL_VERSION)-$(GSASL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gsasl-source gsasl-unpack gsasl gsasl-stage gsasl-ipk gsasl-clean gsasl-dirclean gsasl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GSASL_SOURCE):
	$(WGET) -P $(DL_DIR) $(GSASL_SITE)/$(GSASL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GSASL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gsasl-source: $(DL_DIR)/$(GSASL_SOURCE) $(GSASL_PATCHES)

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
$(GSASL_BUILD_DIR)/.configured: $(DL_DIR)/$(GSASL_SOURCE) $(GSASL_PATCHES) make/gsasl.mk
ifeq (libidn, $(filter libidn, $(PACKAGES)))
	$(MAKE) libidn-stage
endif
	$(MAKE) readline-stage
	rm -rf $(BUILD_DIR)/$(GSASL_DIR) $(GSASL_BUILD_DIR)
	$(GSASL_UNZIP) $(DL_DIR)/$(GSASL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GSASL_PATCHES)" ; \
		then cat $(GSASL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GSASL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GSASL_DIR)" != "$(GSASL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GSASL_DIR) $(GSASL_BUILD_DIR) ; \
	fi
#	sed -i.orig -e '/LTLIB.*=.*-R/s/^/true #/' \
		$(GSASL_BUILD_DIR)/configure \
		$(GSASL_BUILD_DIR)/lib/configure
	(cd $(GSASL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GSASL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GSASL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(GSASL_CONFIG_OPTS) \
		--disable-rpath \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(GSASL_BUILD_DIR)/libtool
	touch $@

gsasl-unpack: $(GSASL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GSASL_BUILD_DIR)/.built: $(GSASL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GSASL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gsasl: $(GSASL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GSASL_BUILD_DIR)/.staged: $(GSASL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GSASL_BUILD_DIR)/lib DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libgsasl*.la
	sed -i.orig -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libgsasl.pc
	touch $@

gsasl-stage: $(GSASL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gsasl
#
$(LIBGSASL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libgsasl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GSASL_PRIORITY)" >>$@
	@echo "Section: $(GSASL_SECTION)" >>$@
	@echo "Version: $(GSASL_VERSION)-$(GSASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GSASL_MAINTAINER)" >>$@
	@echo "Source: $(GSASL_SITE)/$(GSASL_SOURCE)" >>$@
	@echo "Description: $(GSASL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGSASL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGSASL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGSASL_CONFLICTS)" >>$@

$(GSASL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gsasl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GSASL_PRIORITY)" >>$@
	@echo "Section: $(GSASL_SECTION)" >>$@
	@echo "Version: $(GSASL_VERSION)-$(GSASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GSASL_MAINTAINER)" >>$@
	@echo "Source: $(GSASL_SITE)/$(GSASL_SOURCE)" >>$@
	@echo "Description: $(GSASL_DESCRIPTION)" >>$@
	@echo "Depends: $(GSASL_DEPENDS)" >>$@
	@echo "Suggests: $(GSASL_SUGGESTS)" >>$@
	@echo "Conflicts: $(GSASL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GSASL_IPK_DIR)/opt/sbin or $(GSASL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GSASL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GSASL_IPK_DIR)/opt/etc/gsasl/...
# Documentation files should be installed in $(GSASL_IPK_DIR)/opt/doc/gsasl/...
# Daemon startup scripts should be installed in $(GSASL_IPK_DIR)/opt/etc/init.d/S??gsasl
#
# You may need to patch your application to make it use these locations.
#
$(LIBGSASL_IPK): $(GSASL_BUILD_DIR)/.built
	rm -rf $(LIBGSASL_IPK_DIR) $(BUILD_DIR)/libgsasl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GSASL_BUILD_DIR)/lib install-strip DESTDIR=$(LIBGSASL_IPK_DIR)
	rm -f $(LIBGSASL_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(LIBGSASL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGSASL_IPK_DIR)

$(GSASL_IPK): $(GSASL_BUILD_DIR)/.built
	rm -rf $(GSASL_IPK_DIR) $(BUILD_DIR)/gsasl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GSASL_BUILD_DIR) install-strip \
		DESTDIR=$(GSASL_IPK_DIR)
#		SUBDIRS=`sed -n -e '/^SUBDIRS *=/{s/^.*= //;s/lib //;p}' $(GSASL_BUILD_DIR)/Makefile`
	rm -rf $(GSASL_IPK_DIR)/opt/include $(GSASL_IPK_DIR)/opt/lib
	$(MAKE) $(GSASL_IPK_DIR)/CONTROL/control
	echo $(GSASL_CONFFILES) | sed -e 's/ /\n/g' > $(GSASL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GSASL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gsasl-ipk: $(LIBGSASL_IPK) $(GSASL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gsasl-clean:
	rm -f $(GSASL_BUILD_DIR)/.built
	-$(MAKE) -C $(GSASL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gsasl-dirclean:
	rm -rf $(BUILD_DIR)/$(GSASL_DIR) $(GSASL_BUILD_DIR)
	rm -rf $(GSASL_IPK_DIR) $(GSASL_IPK)
	rm -rf $(LIBGSASL_IPK_DIR) $(LIBGSASL_IPK)
#
#
# Some sanity check for the package.
#
gsasl-check: $(LIBGSASL_IPK) $(GSASL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBGSASL_IPK) $(GSASL_IPK)
