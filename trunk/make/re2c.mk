###########################################################
#
# re2c
#
###########################################################
#
# RE2C_VERSION, RE2C_SITE and RE2C_SOURCE define
# the upstream location of the source code for the package.
# RE2C_DIR is the directory which is created when the source
# archive is unpacked.
# RE2C_UNZIP is the command used to unzip the source.
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
RE2C_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/re2c
RE2C_VERSION=0.13.4
RE2C_SOURCE=re2c-$(RE2C_VERSION).tar.gz
RE2C_DIR=re2c-$(RE2C_VERSION)
RE2C_UNZIP=zcat
RE2C_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RE2C_DESCRIPTION=re2c is a tool for writing very fast and very flexible scanners.
RE2C_SECTION=devel
RE2C_PRIORITY=optional
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
RE2C_DEPENDS=libstdc++
endif
RE2C_SUGGESTS=
RE2C_CONFLICTS=

#
# RE2C_IPK_VERSION should be incremented when the ipk changes.
#
RE2C_IPK_VERSION=1

#
# RE2C_CONFFILES should be a list of user-editable files
#RE2C_CONFFILES=/opt/etc/re2c.conf /opt/etc/init.d/SXXre2c

#
# RE2C_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RE2C_PATCHES=$(RE2C_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RE2C_CPPFLAGS=
RE2C_LDFLAGS=
ifneq ($(TARGET_CC), $(HOSTCC))
RE2C_CONFIGURE_ENV=ac_cv_func_malloc_0_nonnull=yes
endif

#
# RE2C_BUILD_DIR is the directory in which the build is done.
# RE2C_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RE2C_IPK_DIR is the directory in which the ipk is built.
# RE2C_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RE2C_BUILD_DIR=$(BUILD_DIR)/re2c
RE2C_SOURCE_DIR=$(SOURCE_DIR)/re2c
RE2C_IPK_DIR=$(BUILD_DIR)/re2c-$(RE2C_VERSION)-ipk
RE2C_IPK=$(BUILD_DIR)/re2c_$(RE2C_VERSION)-$(RE2C_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: re2c-source re2c-unpack re2c re2c-stage re2c-ipk re2c-clean re2c-dirclean re2c-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RE2C_SOURCE):
	$(WGET) -P $(DL_DIR) $(RE2C_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
re2c-source: $(DL_DIR)/$(RE2C_SOURCE) $(RE2C_PATCHES)

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
$(RE2C_BUILD_DIR)/.configured: $(DL_DIR)/$(RE2C_SOURCE) $(RE2C_PATCHES) make/re2c.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(RE2C_DIR) $(RE2C_BUILD_DIR)
	$(RE2C_UNZIP) $(DL_DIR)/$(RE2C_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RE2C_PATCHES)" ; \
		then cat $(RE2C_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RE2C_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RE2C_DIR)" != "$(RE2C_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RE2C_DIR) $(RE2C_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RE2C_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RE2C_LDFLAGS)" \
		$(RE2C_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(RE2C_BUILD_DIR)/libtool
	touch $@

re2c-unpack: $(RE2C_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RE2C_BUILD_DIR)/.built: $(RE2C_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
re2c: $(RE2C_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RE2C_BUILD_DIR)/.staged: $(RE2C_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

re2c-stage: $(RE2C_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/re2c
#
$(RE2C_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: re2c" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RE2C_PRIORITY)" >>$@
	@echo "Section: $(RE2C_SECTION)" >>$@
	@echo "Version: $(RE2C_VERSION)-$(RE2C_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RE2C_MAINTAINER)" >>$@
	@echo "Source: $(RE2C_SITE)/$(RE2C_SOURCE)" >>$@
	@echo "Description: $(RE2C_DESCRIPTION)" >>$@
	@echo "Depends: $(RE2C_DEPENDS)" >>$@
	@echo "Suggests: $(RE2C_SUGGESTS)" >>$@
	@echo "Conflicts: $(RE2C_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RE2C_IPK_DIR)/opt/sbin or $(RE2C_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RE2C_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RE2C_IPK_DIR)/opt/etc/re2c/...
# Documentation files should be installed in $(RE2C_IPK_DIR)/opt/doc/re2c/...
# Daemon startup scripts should be installed in $(RE2C_IPK_DIR)/opt/etc/init.d/S??re2c
#
# You may need to patch your application to make it use these locations.
#
$(RE2C_IPK): $(RE2C_BUILD_DIR)/.built
	rm -rf $(RE2C_IPK_DIR) $(BUILD_DIR)/re2c_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RE2C_BUILD_DIR) DESTDIR=$(RE2C_IPK_DIR) install-strip
#	install -d $(RE2C_IPK_DIR)/opt/etc/
#	install -m 644 $(RE2C_SOURCE_DIR)/re2c.conf $(RE2C_IPK_DIR)/opt/etc/re2c.conf
#	install -d $(RE2C_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RE2C_SOURCE_DIR)/rc.re2c $(RE2C_IPK_DIR)/opt/etc/init.d/SXXre2c
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RE2C_IPK_DIR)/opt/etc/init.d/SXXre2c
	$(MAKE) $(RE2C_IPK_DIR)/CONTROL/control
#	install -m 755 $(RE2C_SOURCE_DIR)/postinst $(RE2C_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RE2C_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RE2C_SOURCE_DIR)/prerm $(RE2C_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RE2C_IPK_DIR)/CONTROL/prerm
	echo $(RE2C_CONFFILES) | sed -e 's/ /\n/g' > $(RE2C_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RE2C_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
re2c-ipk: $(RE2C_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
re2c-clean:
	rm -f $(RE2C_BUILD_DIR)/.built
	-$(MAKE) -C $(RE2C_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
re2c-dirclean:
	rm -rf $(BUILD_DIR)/$(RE2C_DIR) $(RE2C_BUILD_DIR) $(RE2C_IPK_DIR) $(RE2C_IPK)
#
#
# Some sanity check for the package.
#
re2c-check: $(RE2C_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RE2C_IPK)
