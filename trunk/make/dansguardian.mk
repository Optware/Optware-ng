###########################################################
#
# dansguardian
#
###########################################################
#
# DANSGUARDIAN_VERSION, DANSGUARDIAN_SITE and DANSGUARDIAN_SOURCE define
# the upstream location of the source code for the package.
# DANSGUARDIAN_DIR is the directory which is created when the source
# archive is unpacked.
# DANSGUARDIAN_UNZIP is the command used to unzip the source.
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
DANSGUARDIAN_SITE=http://dansguardian.org/downloads/2/Beta
DANSGUARDIAN_VERSION=2.9.8.2
DANSGUARDIAN_SOURCE=dansguardian-$(DANSGUARDIAN_VERSION).tar.gz
DANSGUARDIAN_DIR=dansguardian-$(DANSGUARDIAN_VERSION)
DANSGUARDIAN_UNZIP=zcat
DANSGUARDIAN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DANSGUARDIAN_DESCRIPTION=A web content filter.
DANSGUARDIAN_SECTION=web
DANSGUARDIAN_PRIORITY=optional
DANSGUARDIAN_DEPENDS=pcre, zlib
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
DANSGUARDIAN_DEPENDS+=libstdc++
endif
DANSGUARDIAN_SUGGESTS=
DANSGUARDIAN_CONFLICTS=

#
# DANSGUARDIAN_IPK_VERSION should be incremented when the ipk changes.
#
DANSGUARDIAN_IPK_VERSION=1

#
# DANSGUARDIAN_CONFFILES should be a list of user-editable files
#DANSGUARDIAN_CONFFILES=/opt/etc/dansguardian.conf /opt/etc/init.d/SXXdansguardian

#
# DANSGUARDIAN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DANSGUARDIAN_PATCHES=$(DANSGUARDIAN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DANSGUARDIAN_CPPFLAGS=
DANSGUARDIAN_LDFLAGS=

#
# DANSGUARDIAN_BUILD_DIR is the directory in which the build is done.
# DANSGUARDIAN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DANSGUARDIAN_IPK_DIR is the directory in which the ipk is built.
# DANSGUARDIAN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DANSGUARDIAN_BUILD_DIR=$(BUILD_DIR)/dansguardian
DANSGUARDIAN_SOURCE_DIR=$(SOURCE_DIR)/dansguardian
DANSGUARDIAN_IPK_DIR=$(BUILD_DIR)/dansguardian-$(DANSGUARDIAN_VERSION)-ipk
DANSGUARDIAN_IPK=$(BUILD_DIR)/dansguardian_$(DANSGUARDIAN_VERSION)-$(DANSGUARDIAN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dansguardian-source dansguardian-unpack dansguardian dansguardian-stage dansguardian-ipk dansguardian-clean dansguardian-dirclean dansguardian-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DANSGUARDIAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(DANSGUARDIAN_SITE)/$(DANSGUARDIAN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DANSGUARDIAN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dansguardian-source: $(DL_DIR)/$(DANSGUARDIAN_SOURCE) $(DANSGUARDIAN_PATCHES)

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
$(DANSGUARDIAN_BUILD_DIR)/.configured: $(DL_DIR)/$(DANSGUARDIAN_SOURCE) $(DANSGUARDIAN_PATCHES) make/dansguardian.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) pcre-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(DANSGUARDIAN_DIR) $(DANSGUARDIAN_BUILD_DIR)
	$(DANSGUARDIAN_UNZIP) $(DL_DIR)/$(DANSGUARDIAN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DANSGUARDIAN_PATCHES)" ; \
		then cat $(DANSGUARDIAN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DANSGUARDIAN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DANSGUARDIAN_DIR)" != "$(DANSGUARDIAN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DANSGUARDIAN_DIR) $(DANSGUARDIAN_BUILD_DIR) ; \
	fi
	(cd $(DANSGUARDIAN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DANSGUARDIAN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DANSGUARDIAN_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e 's|chown -R|true chown -R|' $(DANSGUARDIAN_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(DANSGUARDIAN_BUILD_DIR)/libtool
	touch $@

dansguardian-unpack: $(DANSGUARDIAN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DANSGUARDIAN_BUILD_DIR)/.built: $(DANSGUARDIAN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DANSGUARDIAN_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
dansguardian: $(DANSGUARDIAN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DANSGUARDIAN_BUILD_DIR)/.staged: $(DANSGUARDIAN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DANSGUARDIAN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

dansguardian-stage: $(DANSGUARDIAN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dansguardian
#
$(DANSGUARDIAN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dansguardian" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DANSGUARDIAN_PRIORITY)" >>$@
	@echo "Section: $(DANSGUARDIAN_SECTION)" >>$@
	@echo "Version: $(DANSGUARDIAN_VERSION)-$(DANSGUARDIAN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DANSGUARDIAN_MAINTAINER)" >>$@
	@echo "Source: $(DANSGUARDIAN_SITE)/$(DANSGUARDIAN_SOURCE)" >>$@
	@echo "Description: $(DANSGUARDIAN_DESCRIPTION)" >>$@
	@echo "Depends: $(DANSGUARDIAN_DEPENDS)" >>$@
	@echo "Suggests: $(DANSGUARDIAN_SUGGESTS)" >>$@
	@echo "Conflicts: $(DANSGUARDIAN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DANSGUARDIAN_IPK_DIR)/opt/sbin or $(DANSGUARDIAN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DANSGUARDIAN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DANSGUARDIAN_IPK_DIR)/opt/etc/dansguardian/...
# Documentation files should be installed in $(DANSGUARDIAN_IPK_DIR)/opt/doc/dansguardian/...
# Daemon startup scripts should be installed in $(DANSGUARDIAN_IPK_DIR)/opt/etc/init.d/S??dansguardian
#
# You may need to patch your application to make it use these locations.
#
$(DANSGUARDIAN_IPK): $(DANSGUARDIAN_BUILD_DIR)/.built
	rm -rf $(DANSGUARDIAN_IPK_DIR) $(BUILD_DIR)/dansguardian_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DANSGUARDIAN_BUILD_DIR) DESTDIR=$(DANSGUARDIAN_IPK_DIR) install-strip
#	install -d $(DANSGUARDIAN_IPK_DIR)/opt/etc/
#	install -m 644 $(DANSGUARDIAN_SOURCE_DIR)/dansguardian.conf $(DANSGUARDIAN_IPK_DIR)/opt/etc/dansguardian.conf
#	install -d $(DANSGUARDIAN_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DANSGUARDIAN_SOURCE_DIR)/rc.dansguardian $(DANSGUARDIAN_IPK_DIR)/opt/etc/init.d/SXXdansguardian
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DANSGUARDIAN_IPK_DIR)/opt/etc/init.d/SXXdansguardian
	$(MAKE) $(DANSGUARDIAN_IPK_DIR)/CONTROL/control
#	install -m 755 $(DANSGUARDIAN_SOURCE_DIR)/postinst $(DANSGUARDIAN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DANSGUARDIAN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(DANSGUARDIAN_SOURCE_DIR)/prerm $(DANSGUARDIAN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DANSGUARDIAN_IPK_DIR)/CONTROL/prerm
	echo $(DANSGUARDIAN_CONFFILES) | sed -e 's/ /\n/g' > $(DANSGUARDIAN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DANSGUARDIAN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dansguardian-ipk: $(DANSGUARDIAN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dansguardian-clean:
	rm -f $(DANSGUARDIAN_BUILD_DIR)/.built
	-$(MAKE) -C $(DANSGUARDIAN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dansguardian-dirclean:
	rm -rf $(BUILD_DIR)/$(DANSGUARDIAN_DIR) $(DANSGUARDIAN_BUILD_DIR) $(DANSGUARDIAN_IPK_DIR) $(DANSGUARDIAN_IPK)
#
#
# Some sanity check for the package.
#
dansguardian-check: $(DANSGUARDIAN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DANSGUARDIAN_IPK)
