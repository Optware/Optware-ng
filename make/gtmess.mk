###########################################################
#
# gtmess
#
###########################################################
#
# GTMESS_VERSION, GTMESS_SITE and GTMESS_SOURCE define
# the upstream location of the source code for the package.
# GTMESS_DIR is the directory which is created when the source
# archive is unpacked.
# GTMESS_UNZIP is the command used to unzip the source.
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
GTMESS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gtmess
GTMESS_VERSION=0.94
GTMESS_SOURCE=gtmess-$(GTMESS_VERSION).tar.gz
GTMESS_DIR=gtmess-$(GTMESS_VERSION)
GTMESS_UNZIP=zcat
GTMESS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GTMESS_DESCRIPTION=Describe gtmess here.
GTMESS_SECTION=net
GTMESS_PRIORITY=optional
GTMESS_DEPENDS=ncureses, openssl
ifneq (, $(filter libiconv, $(PACKAGES)))
GTMESS_DEPENDS+=, libiconv
endif
GTMESS_SUGGESTS=
GTMESS_CONFLICTS=

#
# GTMESS_IPK_VERSION should be incremented when the ipk changes.
#
GTMESS_IPK_VERSION=1

#
# GTMESS_CONFFILES should be a list of user-editable files
#GTMESS_CONFFILES=/opt/etc/gtmess.conf /opt/etc/init.d/SXXgtmess

#
# GTMESS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GTMESS_PATCHES=$(GTMESS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GTMESS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
GTMESS_LDFLAGS=

#
# GTMESS_BUILD_DIR is the directory in which the build is done.
# GTMESS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GTMESS_IPK_DIR is the directory in which the ipk is built.
# GTMESS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GTMESS_BUILD_DIR=$(BUILD_DIR)/gtmess
GTMESS_SOURCE_DIR=$(SOURCE_DIR)/gtmess
GTMESS_IPK_DIR=$(BUILD_DIR)/gtmess-$(GTMESS_VERSION)-ipk
GTMESS_IPK=$(BUILD_DIR)/gtmess_$(GTMESS_VERSION)-$(GTMESS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gtmess-source gtmess-unpack gtmess gtmess-stage gtmess-ipk gtmess-clean gtmess-dirclean gtmess-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GTMESS_SOURCE):
	$(WGET) -P $(DL_DIR) $(GTMESS_SITE)/$(GTMESS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GTMESS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gtmess-source: $(DL_DIR)/$(GTMESS_SOURCE) $(GTMESS_PATCHES)

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
$(GTMESS_BUILD_DIR)/.configured: $(DL_DIR)/$(GTMESS_SOURCE) $(GTMESS_PATCHES) make/gtmess.mk
	$(MAKE) ncurses-stage openssl-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GTMESS_DIR) $(@D)
	$(GTMESS_UNZIP) $(DL_DIR)/$(GTMESS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GTMESS_PATCHES)" ; \
		then cat $(GTMESS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GTMESS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GTMESS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GTMESS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GTMESS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GTMESS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gtmess-unpack: $(GTMESS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GTMESS_BUILD_DIR)/.built: $(GTMESS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gtmess: $(GTMESS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GTMESS_BUILD_DIR)/.staged: $(GTMESS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gtmess-stage: $(GTMESS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gtmess
#
$(GTMESS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gtmess" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GTMESS_PRIORITY)" >>$@
	@echo "Section: $(GTMESS_SECTION)" >>$@
	@echo "Version: $(GTMESS_VERSION)-$(GTMESS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GTMESS_MAINTAINER)" >>$@
	@echo "Source: $(GTMESS_SITE)/$(GTMESS_SOURCE)" >>$@
	@echo "Description: $(GTMESS_DESCRIPTION)" >>$@
	@echo "Depends: $(GTMESS_DEPENDS)" >>$@
	@echo "Suggests: $(GTMESS_SUGGESTS)" >>$@
	@echo "Conflicts: $(GTMESS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GTMESS_IPK_DIR)/opt/sbin or $(GTMESS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GTMESS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GTMESS_IPK_DIR)/opt/etc/gtmess/...
# Documentation files should be installed in $(GTMESS_IPK_DIR)/opt/doc/gtmess/...
# Daemon startup scripts should be installed in $(GTMESS_IPK_DIR)/opt/etc/init.d/S??gtmess
#
# You may need to patch your application to make it use these locations.
#
$(GTMESS_IPK): $(GTMESS_BUILD_DIR)/.built
	rm -rf $(GTMESS_IPK_DIR) $(BUILD_DIR)/gtmess_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GTMESS_BUILD_DIR) DESTDIR=$(GTMESS_IPK_DIR) install-strip
#	install -d $(GTMESS_IPK_DIR)/opt/etc/
#	install -m 644 $(GTMESS_SOURCE_DIR)/gtmess.conf $(GTMESS_IPK_DIR)/opt/etc/gtmess.conf
#	install -d $(GTMESS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GTMESS_SOURCE_DIR)/rc.gtmess $(GTMESS_IPK_DIR)/opt/etc/init.d/SXXgtmess
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTMESS_IPK_DIR)/opt/etc/init.d/SXXgtmess
	$(MAKE) $(GTMESS_IPK_DIR)/CONTROL/control
#	install -m 755 $(GTMESS_SOURCE_DIR)/postinst $(GTMESS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTMESS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GTMESS_SOURCE_DIR)/prerm $(GTMESS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GTMESS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GTMESS_IPK_DIR)/CONTROL/postinst $(GTMESS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GTMESS_CONFFILES) | sed -e 's/ /\n/g' > $(GTMESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GTMESS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gtmess-ipk: $(GTMESS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gtmess-clean:
	rm -f $(GTMESS_BUILD_DIR)/.built
	-$(MAKE) -C $(GTMESS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gtmess-dirclean:
	rm -rf $(BUILD_DIR)/$(GTMESS_DIR) $(GTMESS_BUILD_DIR) $(GTMESS_IPK_DIR) $(GTMESS_IPK)
#
#
# Some sanity check for the package.
#
gtmess-check: $(GTMESS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GTMESS_IPK)
