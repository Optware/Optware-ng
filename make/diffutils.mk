###########################################################
#
# diffutils
#
###########################################################

# You must replace "diffutils" and "DIFFUTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DIFFUTILS_VERSION, DIFFUTILS_SITE and DIFFUTILS_SOURCE define
# the upstream location of the source code for the package.
# DIFFUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# DIFFUTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
DIFFUTILS_SITE=http://ftp.gnu.org/pub/gnu/diffutils
DIFFUTILS_VERSION=2.8.1
DIFFUTILS_SOURCE=diffutils-$(DIFFUTILS_VERSION).tar.gz
DIFFUTILS_DIR=diffutils-$(DIFFUTILS_VERSION)
DIFFUTILS_UNZIP=zcat
DIFFUTILS_MAINTAINER=Jeremy Eglen <jieglen@sbcglobal.net>
DIFFUTILS_DESCRIPTION=contains gnu diff, cmp, sdiff and diff3 to display differences between and among text files
DIFFUTILS_SECTION=util
DIFFUTILS_PRIORITY=optional
DIFFUTILS_DEPENDS=
DIFFUTILS_CONFLICTS=

#
# DIFFUTILS_IPK_VERSION should be incremented when the ipk changes.
#
DIFFUTILS_IPK_VERSION=6

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DIFFUTILS_CPPFLAGS=
DIFFUTILS_LDFLAGS=

#
# DIFFUTILS_BUILD_DIR is the directory in which the build is done.
# DIFFUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DIFFUTILS_IPK_DIR is the directory in which the ipk is built.
# DIFFUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DIFFUTILS_BUILD_DIR=$(BUILD_DIR)/diffutils
DIFFUTILS_SOURCE_DIR=$(SOURCE_DIR)/diffutils
DIFFUTILS_IPK_DIR=$(BUILD_DIR)/diffutils-$(DIFFUTILS_VERSION)-ipk
DIFFUTILS_IPK=$(BUILD_DIR)/diffutils_$(DIFFUTILS_VERSION)-$(DIFFUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DIFFUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DIFFUTILS_SITE)/$(DIFFUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
diffutils-source: $(DL_DIR)/$(DIFFUTILS_SOURCE) $(DIFFUTILS_PATCHES)

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
$(DIFFUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(DIFFUTILS_SOURCE) $(DIFFUTILS_PATCHES) make/diffutils.mk
	rm -rf $(BUILD_DIR)/$(DIFFUTILS_DIR) $(DIFFUTILS_BUILD_DIR)
	$(DIFFUTILS_UNZIP) $(DL_DIR)/$(DIFFUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DIFFUTILS_DIR) $(DIFFUTILS_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(DIFFUTILS_BUILD_DIR)/config/
	(cd $(DIFFUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DIFFUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DIFFUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

diffutils-unpack: $(DIFFUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(DIFFUTILS_BUILD_DIR)/.built: $(DIFFUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DIFFUTILS_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
diffutils: $(DIFFUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DIFFUTILS_BUILD_DIR)/.staged: $(DIFFUTILS_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(DIFFUTILS_BUILD_DIR)/diffutils.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(DIFFUTILS_BUILD_DIR)/libdiffutils.a $(STAGING_DIR)/opt/lib
	install -m 644 $(DIFFUTILS_BUILD_DIR)/libdiffutils.so.$(DIFFUTILS_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libdiffutils.so.$(DIFFUTILS_VERSION) libdiffutils.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libdiffutils.so.$(DIFFUTILS_VERSION) libdiffutils.so
	touch $@

diffutils-stage: $(DIFFUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/diffutils
#
$(DIFFUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: diffutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DIFFUTILS_PRIORITY)" >>$@
	@echo "Section: $(DIFFUTILS_SECTION)" >>$@
	@echo "Version: $(DIFFUTILS_VERSION)-$(DIFFUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DIFFUTILS_MAINTAINER)" >>$@
	@echo "Source: $(DIFFUTILS_SITE)/$(DIFFUTILS_SOURCE)" >>$@
	@echo "Description: $(DIFFUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(DIFFUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(DIFFUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DIFFUTILS_IPK_DIR)/opt/sbin or $(DIFFUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DIFFUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DIFFUTILS_IPK_DIR)/opt/etc/diffutils/...
# Documentation files should be installed in $(DIFFUTILS_IPK_DIR)/opt/doc/diffutils/...
# Daemon startup scripts should be installed in $(DIFFUTILS_IPK_DIR)/opt/etc/init.d/S??diffutils
#
# You may need to patch your application to make it use these locations.
#
$(DIFFUTILS_IPK): $(DIFFUTILS_BUILD_DIR)/.built
	rm -rf $(DIFFUTILS_IPK_DIR) $(BUILD_DIR)/diffutils_*_$(TARGET_ARCH).ipk
	install -d $(DIFFUTILS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(DIFFUTILS_BUILD_DIR)/src/cmp -o $(DIFFUTILS_IPK_DIR)/opt/bin/diffutils-cmp
	$(STRIP_COMMAND) $(DIFFUTILS_BUILD_DIR)/src/diff -o $(DIFFUTILS_IPK_DIR)/opt/bin/diffutils-diff
	$(STRIP_COMMAND) $(DIFFUTILS_BUILD_DIR)/src/diff3 -o $(DIFFUTILS_IPK_DIR)/opt/bin/diffutils-diff3
	$(STRIP_COMMAND) $(DIFFUTILS_BUILD_DIR)/src/sdiff -o $(DIFFUTILS_IPK_DIR)/opt/bin/diffutils-sdiff
	$(MAKE) $(DIFFUTILS_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(DIFFUTILS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(DIFFUTILS_IPK_DIR)/CONTROL/prerm
	for f in cmp diff diff3 sdiff; do \
	    echo "update-alternatives --install /opt/bin/$$f $$f /opt/bin/diffutils-$$f 80" \
		>> $(DIFFUTILS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/bin/diffutils-$$f" \
		>> $(DIFFUTILS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DIFFUTILS_IPK_DIR)/CONTROL/postinst $(DIFFUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DIFFUTILS_IPK_DIR)

$(DIFFUTILS_BUILD_DIR)/.ipk: $(DIFFUTILS_IPK)
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
diffutils-ipk: $(DIFFUTILS_BUILD_DIR)/.ipk

#
# This is called from the top level makefile to clean all of the built files.
#
diffutils-clean:
	-$(MAKE) -C $(DIFFUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
diffutils-dirclean:
	rm -rf $(BUILD_DIR)/$(DIFFUTILS_DIR) $(DIFFUTILS_BUILD_DIR) $(DIFFUTILS_IPK_DIR) $(DIFFUTILS_IPK)

#
# Some sanity check for the package.
#
diffutils-check: $(DIFFUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DIFFUTILS_IPK)
