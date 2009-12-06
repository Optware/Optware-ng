###########################################################
#
# powertop
#
###########################################################

POWERTOP_SVN_REPO=http://powertop.googlecode.com/svn/trunk
POWERTOP_SVN_REV=331
POWERTOP_VERSION=1.12
POWERTOP_SITE=http://www.lesswatts.org/projects/powertop/download
POWERTOP_SOURCE=powertop-$(POWERTOP_VERSION).tar.gz
POWERTOP_DIR=powertop
POWERTOP_UNZIP=zcat
POWERTOP_MAINTAINER=WebOS Internals <support@webos-internals.org>
POWERTOP_DESCRIPTION=PowerTOP is a Linux tool that helps you find programs that are consuming extra power when your computer is idle.
POWERTOP_SECTION=util
POWERTOP_PRIORITY=optional
POWERTOP_DEPENDS=ncurses
ifeq (enable, $(GETTEXT_NLS))
POWERTOP_DEPENDS +=, gettext
endif
POWERTOP_SUGGESTS=
POWERTOP_CONFLICTS=

#
# POWERTOP_IPK_VERSION should be incremented when the ipk changes.
#
POWERTOP_IPK_VERSION=2

#
# POWERTOP_CONFFILES should be a list of user-editable files
#POWERTOP_CONFFILES=/opt/etc/powertop.conf /opt/etc/init.d/SXXpowertop

#
# POWERTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
POWERTOP_PATCHES=$(POWERTOP_SOURCE_DIR)/ti_powertop-1.12.diff $(POWERTOP_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POWERTOP_CPPFLAGS=
ifeq (uclibc, $(LIBC_STYLE))
POWERTOP_LDFLAGS=-lintl
endif

#
# POWERTOP_BUILD_DIR is the directory in which the build is done.
# POWERTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POWERTOP_IPK_DIR is the directory in which the ipk is built.
# POWERTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POWERTOP_BUILD_DIR=$(BUILD_DIR)/powertop
POWERTOP_SOURCE_DIR=$(SOURCE_DIR)/powertop
POWERTOP_IPK_DIR=$(BUILD_DIR)/powertop-$(POWERTOP_VERSION)-ipk
POWERTOP_IPK=$(BUILD_DIR)/powertop_$(POWERTOP_VERSION)-$(POWERTOP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: powertop-source powertop-unpack powertop powertop-stage powertop-ipk powertop-clean powertop-dirclean powertop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(POWERTOP_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(POWERTOP_DIR) && \
		svn co -r$(POWERTOP_SVN_REV) $(POWERTOP_SVN_REPO) powertop && \
		tar -czf $@ $(POWERTOP_DIR) && \
		rm -rf $(POWERTOP_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
powertop-source: $(DL_DIR)/$(POWERTOP_SOURCE) $(POWERTOP_PATCHES)

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
$(POWERTOP_BUILD_DIR)/.configured: $(DL_DIR)/$(POWERTOP_SOURCE) $(POWERTOP_PATCHES) make/powertop.mk
	$(MAKE) ncurses-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(POWERTOP_DIR) $(@D)
	$(POWERTOP_UNZIP) $(DL_DIR)/$(POWERTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POWERTOP_PATCHES)" ; \
		then cat $(POWERTOP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(POWERTOP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(POWERTOP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(POWERTOP_DIR) $(@D) ; \
	fi
	touch $@

powertop-unpack: $(POWERTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POWERTOP_BUILD_DIR)/.built: $(POWERTOP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_INCLUDE_DIR)/ncurses" \
		LDFLAGS="$(STAGING_LDFLAGS) $(POWERTOP_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
powertop: $(POWERTOP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/powertop
#
$(POWERTOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: powertop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POWERTOP_PRIORITY)" >>$@
	@echo "Section: $(POWERTOP_SECTION)" >>$@
	@echo "Version: $(POWERTOP_VERSION)-$(POWERTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POWERTOP_MAINTAINER)" >>$@
	@echo "Source: $(POWERTOP_SITE)/$(POWERTOP_SOURCE)" >>$@
	@echo "Description: $(POWERTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(POWERTOP_DEPENDS)" >>$@
	@echo "Suggests: $(POWERTOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(POWERTOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POWERTOP_IPK_DIR)/opt/sbin or $(POWERTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POWERTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(POWERTOP_IPK_DIR)/opt/etc/powertop/...
# Documentation files should be installed in $(POWERTOP_IPK_DIR)/opt/doc/powertop/...
# Daemon startup scripts should be installed in $(POWERTOP_IPK_DIR)/opt/etc/init.d/S??powertop
#
# You may need to patch your application to make it use these locations.
#
$(POWERTOP_IPK): $(POWERTOP_BUILD_DIR)/.built
	rm -rf $(POWERTOP_IPK_DIR) $(BUILD_DIR)/powertop_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(POWERTOP_BUILD_DIR) DESTDIR=$(POWERTOP_IPK_DIR) install-strip
	install -d $(POWERTOP_IPK_DIR)/opt/sbin/
	install -m 755 $(POWERTOP_BUILD_DIR)/powertop $(POWERTOP_IPK_DIR)/opt/sbin/powertop
	$(STRIP_COMMAND) $(POWERTOP_IPK_DIR)/opt/sbin/powertop
#	install -d $(POWERTOP_IPK_DIR)/opt/etc/
#	install -m 644 $(POWERTOP_SOURCE_DIR)/powertop.conf $(POWERTOP_IPK_DIR)/opt/etc/powertop.conf
#	install -d $(POWERTOP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(POWERTOP_SOURCE_DIR)/rc.powertop $(POWERTOP_IPK_DIR)/opt/etc/init.d/SXXpowertop
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POWERTOP_IPK_DIR)/opt/etc/init.d/SXXpowertop
	$(MAKE) $(POWERTOP_IPK_DIR)/CONTROL/control
#	install -m 755 $(POWERTOP_SOURCE_DIR)/postinst $(POWERTOP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POWERTOP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(POWERTOP_SOURCE_DIR)/prerm $(POWERTOP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POWERTOP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(POWERTOP_IPK_DIR)/CONTROL/postinst $(POWERTOP_IPK_DIR)/CONTROL/prerm; \
	fi
#	echo $(POWERTOP_CONFFILES) | sed -e 's/ /\n/g' > $(POWERTOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POWERTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
powertop-ipk: $(POWERTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
powertop-clean:
	rm -f $(POWERTOP_BUILD_DIR)/.built
	-$(MAKE) -C $(POWERTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
powertop-dirclean:
	rm -rf $(BUILD_DIR)/$(POWERTOP_DIR) $(POWERTOP_BUILD_DIR) $(POWERTOP_IPK_DIR) $(POWERTOP_IPK)
#
#
# Some sanity check for the package.
#
powertop-check: $(POWERTOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
