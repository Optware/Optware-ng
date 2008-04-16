###########################################################
#
# tar
#
###########################################################

# You must replace "tar" and "TAR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TAR_VERSION, TAR_SITE and TAR_SOURCE define
# the upstream location of the source code for the package.
# TAR_DIR is the directory which is created when the source
# archive is unpacked.
# TAR_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
TAR_SITE=http://ftp.gnu.org/gnu/tar
ifneq ($(OPTWARE_TARGET), wl500g)
TAR_VERSION=1.20
TAR_IPK_VERSION=1
else
TAR_VERSION=1.16.1
TAR_IPK_VERSION=3
endif
TAR_SOURCE=tar-$(TAR_VERSION).tar.bz2
TAR_DIR=tar-$(TAR_VERSION)
TAR_UNZIP=bzcat
TAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TAR_DESCRIPTION=heavyweight version of the Tape ARchiver
TAR_SECTION=util
TAR_PRIORITY=optional
TAR_DEPENDS=bzip2
TAR_CONFLICTS=


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TAR_CPPFLAGS=
ifeq ($(OPTWARE_TARGET),wl500g)
TAR_CPPFLAGS+=-DMB_CUR_MAX=1
endif
TAR_LDFLAGS=

#
# TAR_BUILD_DIR is the directory in which the build is done.
# TAR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TAR_IPK_DIR is the directory in which the ipk is built.
# TAR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TAR_BUILD_DIR=$(BUILD_DIR)/tar
TAR_SOURCE_DIR=$(SOURCE_DIR)/tar
TAR_IPK_DIR=$(BUILD_DIR)/tar-$(TAR_VERSION)-ipk
TAR_IPK=$(BUILD_DIR)/tar_$(TAR_VERSION)-$(TAR_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TAR_SOURCE):
	$(WGET) -P $(DL_DIR) $(TAR_SITE)/$(TAR_SOURCE)

.PHONY: tar-source tar-unpack tar tar-stage tar-ipk tar-clean tar-dirclean tar-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tar-source: $(DL_DIR)/$(TAR_SOURCE) $(TAR_PATCHES)

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
$(TAR_BUILD_DIR)/.configured: $(DL_DIR)/$(TAR_SOURCE) $(TAR_PATCHES)
	rm -rf $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR)
	$(TAR_UNZIP) $(DL_DIR)/$(TAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR)
	(cd $(TAR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TAR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TAR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

tar-unpack: $(TAR_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(TAR_BUILD_DIR)/.built: $(TAR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TAR_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
tar: $(TAR_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tar
#
$(TAR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TAR_PRIORITY)" >>$@
	@echo "Section: $(TAR_SECTION)" >>$@
	@echo "Version: $(TAR_VERSION)-$(TAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TAR_MAINTAINER)" >>$@
	@echo "Source: $(TAR_SITE)/$(TAR_SOURCE)" >>$@
	@echo "Description: $(TAR_DESCRIPTION)" >>$@
	@echo "Depends: $(TAR_DEPENDS)" >>$@
	@echo "Conflicts: $(TAR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TAR_IPK_DIR)/opt/sbin or $(TAR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TAR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TAR_IPK_DIR)/opt/etc/tar/...
# Documentation files should be installed in $(TAR_IPK_DIR)/opt/doc/tar/...
# Daemon startup scripts should be installed in $(TAR_IPK_DIR)/opt/etc/init.d/S??tar
#
# You may need to patch your application to make it use these locations.
#
$(TAR_IPK): $(TAR_BUILD_DIR)/.built
	rm -rf $(TAR_IPK_DIR) $(BUILD_DIR)/tar_*_$(TARGET_ARCH).ipk
	install -d $(TAR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TAR_BUILD_DIR)/src/tar -o $(TAR_IPK_DIR)/opt/bin/gnutar
	install -d $(TAR_IPK_DIR)/opt/libexec
#	$(STRIP_COMMAND) $(TAR_BUILD_DIR)/src/rmt -o $(TAR_IPK_DIR)/opt/libexec/rmt
	$(MAKE) $(TAR_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/tar tar /opt/bin/gnutar 80"; \
	) > $(TAR_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove tar /opt/bin/gnutar"; \
	) > $(TAR_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(TAR_IPK_DIR)/CONTROL/postinst $(TAR_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TAR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tar-ipk: $(TAR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tar-clean:
	-$(MAKE) -C $(TAR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tar-dirclean:
	rm -rf $(BUILD_DIR)/$(TAR_DIR) $(TAR_BUILD_DIR) $(TAR_IPK_DIR) $(TAR_IPK)

#
# Some sanity check for the package.
#
tar-check: $(TAR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TAR_IPK)
