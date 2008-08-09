###########################################################
#
# microdc2
#
###########################################################
#
# MICRODC2_VERSION, MICRODC2_SITE and MICRODC2_SOURCE define
# the upstream location of the source code for the package.
# MICRODC2_DIR is the directory which is created when the source
# archive is unpacked.
# MICRODC2_UNZIP is the command used to unzip the source.
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
MICRODC2_SITE=http://corsair626.no-ip.org/microdc
MICRODC2_VERSION=0.15.6
MICRODC2_SOURCE=microdc2-$(MICRODC2_VERSION).tar.gz
MICRODC2_DIR=microdc2-$(MICRODC2_VERSION)
MICRODC2_UNZIP=zcat
MICRODC2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MICRODC2_DESCRIPTION=A command-line based Direct Connect client.
MICRODC2_SECTION=net
MICRODC2_PRIORITY=optional
MICRODC2_DEPENDS=libxml2, readline, zlib
ifneq (, $(filter libiconv, $(PACKAGES)))
MICRODC2_DEPENDS +=, libiconv
endif
MICRODC2_SUGGESTS=
MICRODC2_CONFLICTS=

#
# MICRODC2_IPK_VERSION should be incremented when the ipk changes.
#
MICRODC2_IPK_VERSION=1

#
# MICRODC2_CONFFILES should be a list of user-editable files
#MICRODC2_CONFFILES=/opt/etc/microdc2.conf /opt/etc/init.d/SXXmicrodc2

#
# MICRODC2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MICRODC2_PATCHES=$(MICRODC2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MICRODC2_CPPFLAGS=
MICRODC2_LDFLAGS=

ifneq (, $(filter libiconv, $(PACKAGES)))
MICRODC2_CONFIG_OPTS = --with-libiconv-prefix=$(STAGING_PREFIX)
else
MICRODC2_CONFIG_OPTS=
endif

#
# MICRODC2_BUILD_DIR is the directory in which the build is done.
# MICRODC2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MICRODC2_IPK_DIR is the directory in which the ipk is built.
# MICRODC2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MICRODC2_BUILD_DIR=$(BUILD_DIR)/microdc2
MICRODC2_SOURCE_DIR=$(SOURCE_DIR)/microdc2
MICRODC2_IPK_DIR=$(BUILD_DIR)/microdc2-$(MICRODC2_VERSION)-ipk
MICRODC2_IPK=$(BUILD_DIR)/microdc2_$(MICRODC2_VERSION)-$(MICRODC2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: microdc2-source microdc2-unpack microdc2 microdc2-stage microdc2-ipk microdc2-clean microdc2-dirclean microdc2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MICRODC2_SOURCE):
	$(WGET) -P $(@D) $(MICRODC2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
microdc2-source: $(DL_DIR)/$(MICRODC2_SOURCE) $(MICRODC2_PATCHES)

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
$(MICRODC2_BUILD_DIR)/.configured: $(DL_DIR)/$(MICRODC2_SOURCE) $(MICRODC2_PATCHES) make/microdc2.mk
	$(MAKE) libxml2-stage readline-stage termcap-stage zlib-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(MICRODC2_DIR) $(@D)
	$(MICRODC2_UNZIP) $(DL_DIR)/$(MICRODC2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MICRODC2_PATCHES)" ; \
		then cat $(MICRODC2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MICRODC2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MICRODC2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MICRODC2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MICRODC2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MICRODC2_LDFLAGS)" \
		ac_cv_path_XML_CONFIG=$(STAGING_PREFIX)/bin/xml2-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MICRODC2_CONFIG_OPTS) \
		--disable-rpath \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

microdc2-unpack: $(MICRODC2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MICRODC2_BUILD_DIR)/.built: $(MICRODC2_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LTLIBICONV=""
	touch $@

#
# This is the build convenience target.
#
microdc2: $(MICRODC2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MICRODC2_BUILD_DIR)/.staged: $(MICRODC2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

microdc2-stage: $(MICRODC2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/microdc2
#
$(MICRODC2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: microdc2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MICRODC2_PRIORITY)" >>$@
	@echo "Section: $(MICRODC2_SECTION)" >>$@
	@echo "Version: $(MICRODC2_VERSION)-$(MICRODC2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MICRODC2_MAINTAINER)" >>$@
	@echo "Source: $(MICRODC2_SITE)/$(MICRODC2_SOURCE)" >>$@
	@echo "Description: $(MICRODC2_DESCRIPTION)" >>$@
	@echo "Depends: $(MICRODC2_DEPENDS)" >>$@
	@echo "Suggests: $(MICRODC2_SUGGESTS)" >>$@
	@echo "Conflicts: $(MICRODC2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MICRODC2_IPK_DIR)/opt/sbin or $(MICRODC2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MICRODC2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MICRODC2_IPK_DIR)/opt/etc/microdc2/...
# Documentation files should be installed in $(MICRODC2_IPK_DIR)/opt/doc/microdc2/...
# Daemon startup scripts should be installed in $(MICRODC2_IPK_DIR)/opt/etc/init.d/S??microdc2
#
# You may need to patch your application to make it use these locations.
#
$(MICRODC2_IPK): $(MICRODC2_BUILD_DIR)/.built
	rm -rf $(MICRODC2_IPK_DIR) $(BUILD_DIR)/microdc2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MICRODC2_BUILD_DIR) DESTDIR=$(MICRODC2_IPK_DIR) install-strip
#	install -d $(MICRODC2_IPK_DIR)/opt/etc/
#	install -m 644 $(MICRODC2_SOURCE_DIR)/microdc2.conf $(MICRODC2_IPK_DIR)/opt/etc/microdc2.conf
#	install -d $(MICRODC2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MICRODC2_SOURCE_DIR)/rc.microdc2 $(MICRODC2_IPK_DIR)/opt/etc/init.d/SXXmicrodc2
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MICRODC2_IPK_DIR)/opt/etc/init.d/SXXmicrodc2
	$(MAKE) $(MICRODC2_IPK_DIR)/CONTROL/control
#	install -m 755 $(MICRODC2_SOURCE_DIR)/postinst $(MICRODC2_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MICRODC2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MICRODC2_SOURCE_DIR)/prerm $(MICRODC2_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MICRODC2_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MICRODC2_IPK_DIR)/CONTROL/postinst $(MICRODC2_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MICRODC2_CONFFILES) | sed -e 's/ /\n/g' > $(MICRODC2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MICRODC2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
microdc2-ipk: $(MICRODC2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
microdc2-clean:
	rm -f $(MICRODC2_BUILD_DIR)/.built
	-$(MAKE) -C $(MICRODC2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
microdc2-dirclean:
	rm -rf $(BUILD_DIR)/$(MICRODC2_DIR) $(MICRODC2_BUILD_DIR) $(MICRODC2_IPK_DIR) $(MICRODC2_IPK)
#
#
# Some sanity check for the package.
#
microdc2-check: $(MICRODC2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MICRODC2_IPK)
