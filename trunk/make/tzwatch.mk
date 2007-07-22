###########################################################
#
# tzwatch
#
###########################################################
#
# TZWATCH_VERSION, TZWATCH_SITE and TZWATCH_SOURCE define
# the upstream location of the source code for the package.
# TZWATCH_DIR is the directory which is created when the source
# archive is unpacked.
# TZWATCH_UNZIP is the command used to unzip the source.
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
TZWATCH_SITE=http://ftp.debian.org/debian/pool/main/g/gworldclock
TZWATCH_VERSION=1.4.4
TZWATCH_SOURCE=gworldclock_$(TZWATCH_VERSION).orig.tar.gz
TZWATCH_DIR=gworldclock-$(TZWATCH_VERSION)
TZWATCH_UNZIP=zcat
TZWATCH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TZWATCH_DESCRIPTION=Displays time and date in specified time zones on console.
TZWATCH_SECTION=misc
TZWATCH_PRIORITY=optional
TZWATCH_DEPENDS=bash
ifeq (coreutils, $(filter coreutils, $(PACKAGES)))
TZWATCH_DEPENDS+=, coreutils
endif
TZWATCH_SUGGESTS=tz
TZWATCH_CONFLICTS=

#
# TZWATCH_IPK_VERSION should be incremented when the ipk changes.
#
TZWATCH_IPK_VERSION=1

#
# TZWATCH_CONFFILES should be a list of user-editable files
#TZWATCH_CONFFILES=/opt/etc/tzwatch.conf /opt/etc/init.d/SXXtzwatch

#
# TZWATCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TZWATCH_PATCHES=$(TZWATCH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TZWATCH_CPPFLAGS=
TZWATCH_LDFLAGS=

#
# TZWATCH_BUILD_DIR is the directory in which the build is done.
# TZWATCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TZWATCH_IPK_DIR is the directory in which the ipk is built.
# TZWATCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TZWATCH_BUILD_DIR=$(BUILD_DIR)/tzwatch
TZWATCH_SOURCE_DIR=$(SOURCE_DIR)/tzwatch
TZWATCH_IPK_DIR=$(BUILD_DIR)/tzwatch-$(TZWATCH_VERSION)-ipk
TZWATCH_IPK=$(BUILD_DIR)/tzwatch_$(TZWATCH_VERSION)-$(TZWATCH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tzwatch-source tzwatch-unpack tzwatch tzwatch-stage tzwatch-ipk tzwatch-clean tzwatch-dirclean tzwatch-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TZWATCH_SOURCE):
	$(WGET) -P $(DL_DIR) $(TZWATCH_SITE)/$(TZWATCH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TZWATCH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tzwatch-source: $(DL_DIR)/$(TZWATCH_SOURCE) $(TZWATCH_PATCHES)

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
$(TZWATCH_BUILD_DIR)/.configured: $(DL_DIR)/$(TZWATCH_SOURCE) $(TZWATCH_PATCHES) make/tzwatch.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TZWATCH_DIR) $(TZWATCH_BUILD_DIR)
	$(TZWATCH_UNZIP) $(DL_DIR)/$(TZWATCH_SOURCE) | tar -C $(BUILD_DIR) --wildcards -xvf - $(TZWATCH_DIR)/tzwatch*
	if test -n "$(TZWATCH_PATCHES)" ; \
		then cat $(TZWATCH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TZWATCH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TZWATCH_DIR)" != "$(TZWATCH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TZWATCH_DIR) $(TZWATCH_BUILD_DIR) ; \
	fi
ifeq (coreutils, $(filter coreutils, $(PACKAGES)))
	sed -i -e '/TZdate/s| date| /opt/bin/date|' $(TZWATCH_BUILD_DIR)/tzwatch
endif
	sed -i -e '/>/s|tzselect|/opt/bin/bash tzselect|' $(TZWATCH_BUILD_DIR)/tzwatch
#	(cd $(TZWATCH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TZWATCH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TZWATCH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TZWATCH_BUILD_DIR)/libtool
	touch $@

tzwatch-unpack: $(TZWATCH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TZWATCH_BUILD_DIR)/.built: $(TZWATCH_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(TZWATCH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tzwatch: $(TZWATCH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TZWATCH_BUILD_DIR)/.staged: $(TZWATCH_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(TZWATCH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

tzwatch-stage: $(TZWATCH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tzwatch
#
$(TZWATCH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tzwatch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TZWATCH_PRIORITY)" >>$@
	@echo "Section: $(TZWATCH_SECTION)" >>$@
	@echo "Version: $(TZWATCH_VERSION)-$(TZWATCH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TZWATCH_MAINTAINER)" >>$@
	@echo "Source: $(TZWATCH_SITE)/$(TZWATCH_SOURCE)" >>$@
	@echo "Description: $(TZWATCH_DESCRIPTION)" >>$@
	@echo "Depends: $(TZWATCH_DEPENDS)" >>$@
	@echo "Suggests: $(TZWATCH_SUGGESTS)" >>$@
	@echo "Conflicts: $(TZWATCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TZWATCH_IPK_DIR)/opt/sbin or $(TZWATCH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TZWATCH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TZWATCH_IPK_DIR)/opt/etc/tzwatch/...
# Documentation files should be installed in $(TZWATCH_IPK_DIR)/opt/doc/tzwatch/...
# Daemon startup scripts should be installed in $(TZWATCH_IPK_DIR)/opt/etc/init.d/S??tzwatch
#
# You may need to patch your application to make it use these locations.
#
$(TZWATCH_IPK): $(TZWATCH_BUILD_DIR)/.built
	rm -rf $(TZWATCH_IPK_DIR) $(BUILD_DIR)/tzwatch_*_$(TARGET_ARCH).ipk
	install -d $(TZWATCH_IPK_DIR)/opt/bin/ $(TZWATCH_IPK_DIR)/opt/man/man1/
	install $(TZWATCH_BUILD_DIR)/tzwatch $(TZWATCH_IPK_DIR)/opt/bin/
	install $(TZWATCH_BUILD_DIR)/tzwatch.1 $(TZWATCH_IPK_DIR)/opt/man/man1/
	$(MAKE) $(TZWATCH_IPK_DIR)/CONTROL/control
#	install -m 755 $(TZWATCH_SOURCE_DIR)/postinst $(TZWATCH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZWATCH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TZWATCH_SOURCE_DIR)/prerm $(TZWATCH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TZWATCH_IPK_DIR)/CONTROL/prerm
#	echo $(TZWATCH_CONFFILES) | sed -e 's/ /\n/g' > $(TZWATCH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TZWATCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tzwatch-ipk: $(TZWATCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tzwatch-clean:
	rm -f $(TZWATCH_BUILD_DIR)/.built
	-$(MAKE) -C $(TZWATCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tzwatch-dirclean:
	rm -rf $(BUILD_DIR)/$(TZWATCH_DIR) $(TZWATCH_BUILD_DIR) $(TZWATCH_IPK_DIR) $(TZWATCH_IPK)
#
#
# Some sanity check for the package.
#
tzwatch-check: $(TZWATCH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TZWATCH_IPK)
