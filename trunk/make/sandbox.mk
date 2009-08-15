###########################################################
#
# sandbox
#
###########################################################

# You must replace "sandbox" and "SANDBOX" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SANDBOX_VERSION, SANDBOX_SITE and SANDBOX_SOURCE define
# the upstream location of the source code for the package.
# SANDBOX_DIR is the directory which is created when the source
# archive is unpacked.
# SANDBOX_UNZIP is the command used to unzip the source.
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
SANDBOX_SITE=http://dev.gentoo.org/~vapier/dist
SANDBOX_VERSION=2.0
SANDBOX_SOURCE=sandbox-$(SANDBOX_VERSION).tar.lzma
SANDBOX_DIR=sandbox-$(SANDBOX_VERSION)
SANDBOX_UNZIP=lzma -d -c
SANDBOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SANDBOX_DESCRIPTION=Sandbox is a library (and helper utility) to run programs in a "sandboxed" environment.
SANDBOX_SECTION=admin
SANDBOX_PRIORITY=optional
SANDBOX_DEPENDS=
SANDBOX_SUGGESTS=
SANDBOX_CONFLICTS=

#
# SANDBOX_IPK_VERSION should be incremented when the ipk changes.
#
SANDBOX_IPK_VERSION=1

#
# SANDBOX_CONFFILES should be a list of user-editable files
#SANDBOX_CONFFILES=/opt/etc/sandbox.conf /opt/etc/init.d/SXXsandbox

#
# SANDBOX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# SANDBOX_PATCHES=$(SANDBOX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SANDBOX_CPPFLAGS=
SANDBOX_LDFLAGS=

#
# SANDBOX_BUILD_DIR is the directory in which the build is done.
# SANDBOX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SANDBOX_IPK_DIR is the directory in which the ipk is built.
# SANDBOX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SANDBOX_BUILD_DIR=$(BUILD_DIR)/sandbox
SANDBOX_SOURCE_DIR=$(SOURCE_DIR)/sandbox
SANDBOX_IPK_DIR=$(BUILD_DIR)/sandbox-$(SANDBOX_VERSION)-ipk
SANDBOX_IPK=$(BUILD_DIR)/sandbox_$(SANDBOX_VERSION)-$(SANDBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: sandbox-source sandbox-unpack sandbox sandbox-stage sandbox-ipk sandbox-clean sandbox-dirclean sandbox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SANDBOX_SOURCE):
	$(WGET) -P $(@D) $(SANDBOX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sandbox-source: $(DL_DIR)/$(SANDBOX_SOURCE) $(SANDBOX_PATCHES)

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
$(SANDBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(SANDBOX_SOURCE) $(SANDBOX_PATCHES) make/sandbox.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SANDBOX_DIR) $(@D)
	$(SANDBOX_UNZIP) $(DL_DIR)/$(SANDBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SANDBOX_PATCHES)" ; \
		then cat $(SANDBOX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SANDBOX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SANDBOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SANDBOX_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SANDBOX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SANDBOX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sandbox-unpack: $(SANDBOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SANDBOX_BUILD_DIR)/.built: $(SANDBOX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sandbox: $(SANDBOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SANDBOX_BUILD_DIR)/.staged: $(SANDBOX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

sandbox-stage: $(SANDBOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sandbox
#
$(SANDBOX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sandbox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SANDBOX_PRIORITY)" >>$@
	@echo "Section: $(SANDBOX_SECTION)" >>$@
	@echo "Version: $(SANDBOX_VERSION)-$(SANDBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SANDBOX_MAINTAINER)" >>$@
	@echo "Source: $(SANDBOX_SITE)/$(SANDBOX_SOURCE)" >>$@
	@echo "Description: $(SANDBOX_DESCRIPTION)" >>$@
	@echo "Depends: $(SANDBOX_DEPENDS)" >>$@
	@echo "Suggests: $(SANDBOX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SANDBOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SANDBOX_IPK_DIR)/opt/sbin or $(SANDBOX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SANDBOX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SANDBOX_IPK_DIR)/opt/etc/sandbox/...
# Documentation files should be installed in $(SANDBOX_IPK_DIR)/opt/doc/sandbox/...
# Daemon startup scripts should be installed in $(SANDBOX_IPK_DIR)/opt/etc/init.d/S??sandbox
#
# You may need to patch your application to make it use these locations.
#
$(SANDBOX_IPK): $(SANDBOX_BUILD_DIR)/.built
	rm -rf $(SANDBOX_IPK_DIR) $(BUILD_DIR)/sandbox_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SANDBOX_BUILD_DIR) DESTDIR=$(SANDBOX_IPK_DIR) install-strip
#	install -d $(SANDBOX_IPK_DIR)/opt/etc/
#	install -m 644 $(SANDBOX_SOURCE_DIR)/sandbox.conf $(SANDBOX_IPK_DIR)/opt/etc/sandbox.conf
#	install -d $(SANDBOX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SANDBOX_SOURCE_DIR)/rc.sandbox $(SANDBOX_IPK_DIR)/opt/etc/init.d/SXXsandbox
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SANDBOX_IPK_DIR)/opt/etc/init.d/SXXsandbox
	$(MAKE) $(SANDBOX_IPK_DIR)/CONTROL/control
#	install -m 755 $(SANDBOX_SOURCE_DIR)/postinst $(SANDBOX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SANDBOX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SANDBOX_SOURCE_DIR)/prerm $(SANDBOX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SANDBOX_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SANDBOX_IPK_DIR)/CONTROL/postinst $(SANDBOX_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SANDBOX_CONFFILES) | sed -e 's/ /\n/g' > $(SANDBOX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SANDBOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sandbox-ipk: $(SANDBOX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sandbox-clean:
	rm -f $(SANDBOX_BUILD_DIR)/.built
	-$(MAKE) -C $(SANDBOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sandbox-dirclean:
	rm -rf $(BUILD_DIR)/$(SANDBOX_DIR) $(SANDBOX_BUILD_DIR) $(SANDBOX_IPK_DIR) $(SANDBOX_IPK)
#
#
# Some sanity check for the package.
#
sandbox-check: $(SANDBOX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
