###########################################################
#
# launchtool
#
###########################################################
#
# LAUNCHTOOL_VERSION, LAUNCHTOOL_SITE and LAUNCHTOOL_SOURCE define
# the upstream location of the source code for the package.
# LAUNCHTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# LAUNCHTOOL_UNZIP is the command used to unzip the source.
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
LAUNCHTOOL_SITE=http://people.debian.org/~enrico/woody/source
LAUNCHTOOL_VERSION=0.7
LAUNCHTOOL_SOURCE=launchtool_$(LAUNCHTOOL_VERSION)-1.tar.gz
LAUNCHTOOL_DIR=launchtool-$(LAUNCHTOOL_VERSION)
LAUNCHTOOL_UNZIP=zcat
LAUNCHTOOL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LAUNCHTOOL_DESCRIPTION=A tool that runs a user-supplied command and can supervise its execution in many ways.
LAUNCHTOOL_SECTION=admin
LAUNCHTOOL_PRIORITY=optional
LAUNCHTOOL_DEPENDS=popt
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
LAUNCHTOOL_DEPENDS+=, libstdc++
endif
LAUNCHTOOL_SUGGESTS=
LAUNCHTOOL_CONFLICTS=

#
# LAUNCHTOOL_IPK_VERSION should be incremented when the ipk changes.
#
LAUNCHTOOL_IPK_VERSION=1

#
# LAUNCHTOOL_CONFFILES should be a list of user-editable files
#LAUNCHTOOL_CONFFILES=/opt/etc/launchtool.conf /opt/etc/init.d/SXXlaunchtool

#
# LAUNCHTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# LAUNCHTOOL_PATCHES=$(LAUNCHTOOL_SOURCE_DIR)/src-common-LoggerMethods.cc.patch
# $(LAUNCHTOOL_SOURCE_DIR)/sys_siglist.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LAUNCHTOOL_CPPFLAGS=
LAUNCHTOOL_LDFLAGS=

ifeq ($(LIBC_STYLE), uclibc)
LAUNCHTOOL_CONFIG_ENV=CXX=$(TARGET_GXX)
endif

#
# LAUNCHTOOL_BUILD_DIR is the directory in which the build is done.
# LAUNCHTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LAUNCHTOOL_IPK_DIR is the directory in which the ipk is built.
# LAUNCHTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LAUNCHTOOL_BUILD_DIR=$(BUILD_DIR)/launchtool
LAUNCHTOOL_SOURCE_DIR=$(SOURCE_DIR)/launchtool
LAUNCHTOOL_IPK_DIR=$(BUILD_DIR)/launchtool-$(LAUNCHTOOL_VERSION)-ipk
LAUNCHTOOL_IPK=$(BUILD_DIR)/launchtool_$(LAUNCHTOOL_VERSION)-$(LAUNCHTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: launchtool-source launchtool-unpack launchtool launchtool-stage launchtool-ipk launchtool-clean launchtool-dirclean launchtool-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LAUNCHTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LAUNCHTOOL_SITE)/$(LAUNCHTOOL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LAUNCHTOOL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
launchtool-source: $(DL_DIR)/$(LAUNCHTOOL_SOURCE) $(LAUNCHTOOL_PATCHES)

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
$(LAUNCHTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(LAUNCHTOOL_SOURCE) $(LAUNCHTOOL_PATCHES) make/launchtool.mk
	$(MAKE) popt-stage
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(LAUNCHTOOL_DIR) $(LAUNCHTOOL_BUILD_DIR)
	$(LAUNCHTOOL_UNZIP) $(DL_DIR)/$(LAUNCHTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LAUNCHTOOL_PATCHES)" ; \
		then cat $(LAUNCHTOOL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LAUNCHTOOL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LAUNCHTOOL_DIR)" != "$(LAUNCHTOOL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LAUNCHTOOL_DIR) $(LAUNCHTOOL_BUILD_DIR) ; \
	fi
	(cd $(LAUNCHTOOL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LAUNCHTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LAUNCHTOOL_LDFLAGS)" \
		$(LAUNCHTOOL_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(LAUNCHTOOL_BUILD_DIR)/libtool
	touch $@

launchtool-unpack: $(LAUNCHTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LAUNCHTOOL_BUILD_DIR)/.built: $(LAUNCHTOOL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LAUNCHTOOL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
launchtool: $(LAUNCHTOOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LAUNCHTOOL_BUILD_DIR)/.staged: $(LAUNCHTOOL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LAUNCHTOOL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

launchtool-stage: $(LAUNCHTOOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/launchtool
#
$(LAUNCHTOOL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: launchtool" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LAUNCHTOOL_PRIORITY)" >>$@
	@echo "Section: $(LAUNCHTOOL_SECTION)" >>$@
	@echo "Version: $(LAUNCHTOOL_VERSION)-$(LAUNCHTOOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LAUNCHTOOL_MAINTAINER)" >>$@
	@echo "Source: $(LAUNCHTOOL_SITE)/$(LAUNCHTOOL_SOURCE)" >>$@
	@echo "Description: $(LAUNCHTOOL_DESCRIPTION)" >>$@
	@echo "Depends: $(LAUNCHTOOL_DEPENDS)" >>$@
	@echo "Suggests: $(LAUNCHTOOL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LAUNCHTOOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LAUNCHTOOL_IPK_DIR)/opt/sbin or $(LAUNCHTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LAUNCHTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LAUNCHTOOL_IPK_DIR)/opt/etc/launchtool/...
# Documentation files should be installed in $(LAUNCHTOOL_IPK_DIR)/opt/doc/launchtool/...
# Daemon startup scripts should be installed in $(LAUNCHTOOL_IPK_DIR)/opt/etc/init.d/S??launchtool
#
# You may need to patch your application to make it use these locations.
#
$(LAUNCHTOOL_IPK): $(LAUNCHTOOL_BUILD_DIR)/.built
	rm -rf $(LAUNCHTOOL_IPK_DIR) $(BUILD_DIR)/launchtool_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LAUNCHTOOL_BUILD_DIR) DESTDIR=$(LAUNCHTOOL_IPK_DIR) install
	$(STRIP_COMMAND) $(LAUNCHTOOL_IPK_DIR)/opt/bin/launchtool
	install -d $(LAUNCHTOOL_IPK_DIR)/opt/man/man1
	install -m 644 $(LAUNCHTOOL_BUILD_DIR)/launchtool.1 $(LAUNCHTOOL_IPK_DIR)/opt/man/man1/
#	install -d $(LAUNCHTOOL_IPK_DIR)/opt/etc/
#	install -m 644 $(LAUNCHTOOL_SOURCE_DIR)/launchtool.conf $(LAUNCHTOOL_IPK_DIR)/opt/etc/launchtool.conf
#	install -d $(LAUNCHTOOL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LAUNCHTOOL_SOURCE_DIR)/rc.launchtool $(LAUNCHTOOL_IPK_DIR)/opt/etc/init.d/SXXlaunchtool
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LAUNCHTOOL_IPK_DIR)/opt/etc/init.d/SXXlaunchtool
	$(MAKE) $(LAUNCHTOOL_IPK_DIR)/CONTROL/control
#	install -m 755 $(LAUNCHTOOL_SOURCE_DIR)/postinst $(LAUNCHTOOL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LAUNCHTOOL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LAUNCHTOOL_SOURCE_DIR)/prerm $(LAUNCHTOOL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LAUNCHTOOL_IPK_DIR)/CONTROL/prerm
	echo $(LAUNCHTOOL_CONFFILES) | sed -e 's/ /\n/g' > $(LAUNCHTOOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LAUNCHTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
launchtool-ipk: $(LAUNCHTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
launchtool-clean:
	rm -f $(LAUNCHTOOL_BUILD_DIR)/.built
	-$(MAKE) -C $(LAUNCHTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
launchtool-dirclean:
	rm -rf $(BUILD_DIR)/$(LAUNCHTOOL_DIR) $(LAUNCHTOOL_BUILD_DIR) $(LAUNCHTOOL_IPK_DIR) $(LAUNCHTOOL_IPK)
#
#
# Some sanity check for the package.
#
launchtool-check: $(LAUNCHTOOL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LAUNCHTOOL_IPK)
