###########################################################
#
# m4
#
###########################################################

# You must replace "m4" and "M4" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# M4_VERSION, M4_SITE and M4_SOURCE define
# the upstream location of the source code for the package.
# M4_DIR is the directory which is created when the source
# archive is unpacked.
# M4_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
M4_SITE=http://ftp.gnu.org/pub/gnu/m4
M4_VERSION=1.4.12
M4_SOURCE=m4-$(M4_VERSION).tar.gz
M4_DIR=m4-$(M4_VERSION)
M4_UNZIP=zcat
M4_MAINTAINER=Jeremy Eglen <jieglen@sbcglobal.net>
M4_DESCRIPTION=gnu macro processor and compiler front end
M4_SECTION=util
M4_PRIORITY=optional
M4_DEPENDS=
M4_CONFLICTS=

#
# M4_IPK_VERSION should be incremented when the ipk changes.
#
M4_IPK_VERSION=1

#
# M4_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#M4_PATCHES=$(M4_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(OPTWARE_TARGET),wl500g)
  M4_CPPFLAGS=-DMB_CUR_MAX=1
else
  M4_CPPFLAGS=
endif
M4_LDFLAGS=

#
# M4_BUILD_DIR is the directory in which the build is done.
# M4_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# M4_IPK_DIR is the directory in which the ipk is built.
# M4_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
M4_BUILD_DIR=$(BUILD_DIR)/m4
M4_SOURCE_DIR=$(SOURCE_DIR)/m4
M4_IPK_DIR=$(BUILD_DIR)/m4-$(M4_VERSION)-ipk
M4_IPK=$(BUILD_DIR)/m4_$(M4_VERSION)-$(M4_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: m4-source m4-unpack m4 m4-stage m4-ipk m4-clean m4-dirclean m4-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(M4_SOURCE):
	$(WGET) -P $(@D) $(M4_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
m4-source: $(DL_DIR)/$(M4_SOURCE) $(M4_PATCHES)

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
$(M4_BUILD_DIR)/.configured: $(DL_DIR)/$(M4_SOURCE) $(M4_PATCHES) make/m4.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(M4_DIR) $(@D)
	$(M4_UNZIP) $(DL_DIR)/$(M4_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(M4_PATCHES) | patch -d $(BUILD_DIR)/$(M4_DIR) -p1
	mv $(BUILD_DIR)/$(M4_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(M4_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(M4_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

m4-unpack: $(M4_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(M4_BUILD_DIR)/.built: $(M4_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
m4: $(M4_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/m4
#
$(M4_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: m4" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(M4_PRIORITY)" >>$@
	@echo "Section: $(M4_SECTION)" >>$@
	@echo "Version: $(M4_VERSION)-$(M4_IPK_VERSION)" >>$@
	@echo "Maintainer: $(M4_MAINTAINER)" >>$@
	@echo "Source: $(M4_SITE)/$(M4_SOURCE)" >>$@
	@echo "Description: $(M4_DESCRIPTION)" >>$@
	@echo "Depends: $(M4_DEPENDS)" >>$@
	@echo "Conflicts: $(M4_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(M4_IPK_DIR)/opt/sbin or $(M4_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(M4_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(M4_IPK_DIR)/opt/etc/m4/...
# Documentation files should be installed in $(M4_IPK_DIR)/opt/doc/m4/...
# Daemon startup scripts should be installed in $(M4_IPK_DIR)/opt/etc/init.d/S??m4
#
# You may need to patch your application to make it use these locations.
#
$(M4_IPK): $(M4_BUILD_DIR)/.built
	rm -rf $(M4_IPK_DIR) $(M4_IPK)
	$(MAKE) -C $(M4_BUILD_DIR) DESTDIR=$(M4_IPK_DIR) install-strip
#	install -d $(M4_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(M4_SOURCE_DIR)/rc.m4 $(M4_IPK_DIR)/opt/etc/init.d/SXXm4
	$(MAKE) $(M4_IPK_DIR)/CONTROL/control
#	install -m 644 $(M4_SOURCE_DIR)/postinst $(M4_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(M4_SOURCE_DIR)/prerm $(M4_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(M4_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
m4-ipk: $(M4_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
m4-clean:
	-$(MAKE) -C $(M4_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
m4-dirclean:
	rm -rf $(BUILD_DIR)/$(M4_DIR) $(M4_BUILD_DIR) $(M4_IPK_DIR) $(M4_IPK)

#
# Some sanity check for the package.
#
m4-check: $(M4_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(M4_IPK)
