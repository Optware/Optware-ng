###########################################################
#
# jamvm
#
###########################################################

# You must replace "jamvm" and "JAMVM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# JAMVM_VERSION, JAMVM_SITE and JAMVM_SOURCE define
# the upstream location of the source code for the package.
# JAMVM_DIR is the directory which is created when the source
# archive is unpacked.
# JAMVM_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
JAMVM_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/jamvm
JAMVM_VERSION ?= 1.5.2
JAMVM_IPK_VERSION ?= 1
JAMVM_SOURCE=jamvm-$(JAMVM_VERSION).tar.gz
JAMVM_DIR=jamvm-$(JAMVM_VERSION)
JAMVM_UNZIP=zcat
JAMVM_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
JAMVM_DESCRIPTION=VM spec version 2 conformant. Extremely small with stripped executable
JAMVM_SECTION=language
JAMVM_PRIORITY=optional
JAMVM_DEPENDS=zlib
JAMVM_SUGGESTS=classpath
JAMVM_CONFLICTS=


#
# JAMVM_CONFFILES should be a list of user-editable files
#JAMVM_CONFFILES=/opt/etc/jamvm.conf /opt/etc/init.d/SXXjamvm

#
# JAMVM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JAMVM_PATCHES=$(JAMVM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JAMVM_CPPFLAGS=
JAMVM_LDFLAGS=

#
# JAMVM_BUILD_DIR is the directory in which the build is done.
# JAMVM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JAMVM_IPK_DIR is the directory in which the ipk is built.
# JAMVM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JAMVM_BUILD_DIR=$(BUILD_DIR)/jamvm
JAMVM_SOURCE_DIR=$(SOURCE_DIR)/jamvm
JAMVM_IPK_DIR=$(BUILD_DIR)/jamvm-$(JAMVM_VERSION)-ipk
JAMVM_IPK=$(BUILD_DIR)/jamvm_$(JAMVM_VERSION)-$(JAMVM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: jamvm-source jamvm-unpack jamvm jamvm-stage jamvm-ipk jamvm-clean jamvm-dirclean jamvm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JAMVM_SOURCE):
	$(WGET) -P $(@D) $(JAMVM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jamvm-source: $(DL_DIR)/$(JAMVM_SOURCE) $(JAMVM_PATCHES)

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
$(JAMVM_BUILD_DIR)/.configured: $(DL_DIR)/$(JAMVM_SOURCE) $(JAMVM_PATCHES)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(JAMVM_DIR) $(JAMVM_BUILD_DIR)
	$(JAMVM_UNZIP) $(DL_DIR)/$(JAMVM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(JAMVM_PATCHES) | patch -d $(BUILD_DIR)/$(JAMVM_DIR) -p1
	mv $(BUILD_DIR)/$(JAMVM_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JAMVM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JAMVM_LDFLAGS)" \
		./configure \
		--with-classpath-install-dir=/opt \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

jamvm-unpack: $(JAMVM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JAMVM_BUILD_DIR)/.built: $(JAMVM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
jamvm: $(JAMVM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libjamvm.so.$(JAMVM_VERSION): $(JAMVM_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(JAMVM_BUILD_DIR)/jamvm.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(JAMVM_BUILD_DIR)/libjamvm.a $(STAGING_DIR)/opt/lib
	install -m 644 $(JAMVM_BUILD_DIR)/libjamvm.so.$(JAMVM_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libjamvm.so.$(JAMVM_VERSION) libjamvm.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libjamvm.so.$(JAMVM_VERSION) libjamvm.so

jamvm-stage: $(STAGING_DIR)/opt/lib/libjamvm.so.$(JAMVM_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jamvm
#
$(JAMVM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: jamvm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JAMVM_PRIORITY)" >>$@
	@echo "Section: $(JAMVM_SECTION)" >>$@
	@echo "Version: $(JAMVM_VERSION)-$(JAMVM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JAMVM_MAINTAINER)" >>$@
	@echo "Source: $(JAMVM_SITE)/$(JAMVM_SOURCE)" >>$@
	@echo "Description: $(JAMVM_DESCRIPTION)" >>$@
	@echo "Depends: $(JAMVM_DEPENDS)" >>$@
	@echo "Suggests: $(JAMVM_SUGGESTS)" >>$@
	@echo "Conflicts: $(JAMVM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JAMVM_IPK_DIR)/opt/sbin or $(JAMVM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JAMVM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JAMVM_IPK_DIR)/opt/etc/jamvm/...
# Documentation files should be installed in $(JAMVM_IPK_DIR)/opt/doc/jamvm/...
# Daemon startup scripts should be installed in $(JAMVM_IPK_DIR)/opt/etc/init.d/S??jamvm
#
# You may need to patch your application to make it use these locations.
#
$(JAMVM_IPK): $(JAMVM_BUILD_DIR)/.built
	rm -rf $(JAMVM_IPK_DIR) $(BUILD_DIR)/jamvm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(JAMVM_BUILD_DIR) install-strip prefix=$(JAMVM_IPK_DIR)/opt
	install -d $(JAMVM_IPK_DIR)/opt/include/jamvm/
	mv $(JAMVM_IPK_DIR)/opt/include/jni.h $(JAMVM_IPK_DIR)/opt/include/jamvm/jni.h
	$(MAKE) $(JAMVM_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JAMVM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jamvm-ipk: $(JAMVM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jamvm-clean:
	-$(MAKE) -C $(JAMVM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jamvm-dirclean:
	rm -rf $(BUILD_DIR)/$(JAMVM_DIR) $(JAMVM_BUILD_DIR) $(JAMVM_IPK_DIR) $(JAMVM_IPK)

#
# Some sanity check for the package.
#
jamvm-check: $(JAMVM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
