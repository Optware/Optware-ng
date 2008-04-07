###########################################################
#
# popt
#
###########################################################

# You must replace "popt" and "POPT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# POPT_VERSION, POPT_SITE and POPT_SOURCE define
# the upstream location of the source code for the package.
# POPT_DIR is the directory which is created when the source
# archive is unpacked.
# POPT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
POPT_SITE=http://rpm5.org/files/popt
POPT_VERSION=1.14
POPT_SOURCE=popt-$(POPT_VERSION).tar.gz
POPT_DIR=popt-$(POPT_VERSION)
POPT_UNZIP=zcat
POPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POPT_DESCRIPTION=A C library for parsing command line parameters.
POPT_SECTION=libs
POPT_PRIORITY=optional
POPT_DEPENDS=
POPT_SUGGESTS=
POPT_CONFLICTS=

#
# POPT_IPK_VERSION should be incremented when the ipk changes.
#
POPT_IPK_VERSION=1

#
# POPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# POPT_PATCHES=$(POPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POPT_CPPFLAGS=
POPT_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
POPT_CONFIG_ARGS=ac_cv_va_copy=C99
endif

#
# POPT_BUILD_DIR is the directory in which the build is done.
# POPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POPT_IPK_DIR is the directory in which the ipk is built.
# POPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POPT_BUILD_DIR=$(BUILD_DIR)/popt
POPT_SOURCE_DIR=$(SOURCE_DIR)/popt
POPT_IPK_DIR=$(BUILD_DIR)/popt-$(POPT_VERSION)-ipk
POPT_IPK=$(BUILD_DIR)/popt_$(POPT_VERSION)-$(POPT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POPT_SOURCE):
	$(WGET) -P $(@D) $(POPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
popt-source: $(DL_DIR)/$(POPT_SOURCE) $(POPT_PATCHES)

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
$(POPT_BUILD_DIR)/.configured: $(DL_DIR)/$(POPT_SOURCE) $(POPT_PATCHES) make/popt.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR)
	$(POPT_UNZIP) $(DL_DIR)/$(POPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(POPT_PATCHES) | patch -d $(BUILD_DIR)/$(POPT_DIR) -p1
	mv $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(POPT_BUILD_DIR)/
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(POPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POPT_LDFLAGS)" \
		$(POPT_CONFIG_ARGS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

popt-unpack: $(POPT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(POPT_BUILD_DIR)/.built: $(POPT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
popt: $(POPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POPT_BUILD_DIR)/.staged: $(POPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpopt.la
	touch $@

popt-stage: $(POPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources
#
$(POPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: popt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POPT_PRIORITY)" >>$@
	@echo "Section: $(POPT_SECTION)" >>$@
	@echo "Version: $(POPT_VERSION)-$(POPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POPT_MAINTAINER)" >>$@
	@echo "Source: $(POPT_SITE)/$(POPT_SOURCE)" >>$@
	@echo "Description: $(POPT_DESCRIPTION)" >>$@
	@echo "Depends: $(POPT_DEPENDS)" >>$@
	@echo "Suggests: $(POPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(POPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(POPT_IPK): $(POPT_BUILD_DIR)/.built
	rm -rf $(POPT_IPK_DIR) $(BUILD_DIR)/popt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POPT_BUILD_DIR) DESTDIR=$(POPT_IPK_DIR) install-strip transform=""
	rm -f $(POPT_IPK_DIR)/opt/lib/*.a
	rm -f $(POPT_IPK_DIR)/opt/lib/*.la
	$(STRIP_COMMAND) $(POPT_IPK_DIR)/opt/lib/*
	$(MAKE) $(POPT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
popt-ipk: $(POPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
popt-clean:
	-$(MAKE) -C $(POPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
popt-dirclean:
	rm -rf $(BUILD_DIR)/$(POPT_DIR) $(POPT_BUILD_DIR) $(POPT_IPK_DIR) $(POPT_IPK)

#
# Some sanity check for the package.
#
popt-check: $(POPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POPT_IPK)
