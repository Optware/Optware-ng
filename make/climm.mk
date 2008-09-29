###########################################################
#
# climm
#
###########################################################
#
# CLIMM_VERSION, CLIMM_SITE and CLIMM_SOURCE define
# the upstream location of the source code for the package.
# CLIMM_DIR is the directory which is created when the source
# archive is unpacked.
# CLIMM_UNZIP is the command used to unzip the source.
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
CLIMM_SITE=http://www.climm.org/source
CLIMM_VERSION=0.6.3
CLIMM_SOURCE=climm-$(CLIMM_VERSION).tgz
CLIMM_DIR=climm-$(CLIMM_VERSION)
CLIMM_UNZIP=zcat
CLIMM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CLIMM_DESCRIPTION=A very portable text-mode ICQ clone.
CLIMM_SECTION=net
CLIMM_PRIORITY=optional
CLIMM_DEPENDS=gnutls, libgcrypt, libotr
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
CLIMM_DEPENDS=, libiconv
endif
ifneq (, $(filter gloox, $(PACKAGES)))
CLIMM_DEPENDS=, gloox
endif
CLIMM_SUGGESTS=
CLIMM_CONFLICTS=

#
# CLIMM_IPK_VERSION should be incremented when the ipk changes.
#
CLIMM_IPK_VERSION=1

#
# CLIMM_CONFFILES should be a list of user-editable files
#CLIMM_CONFFILES=/opt/etc/climm.conf /opt/etc/init.d/SXXclimm

#
# CLIMM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CLIMM_PATCHES=$(CLIMM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLIMM_CPPFLAGS=
CLIMM_LDFLAGS=
ifeq (, $(filter gloox, $(PACKAGES)))
CLIMM_CONFIG_ARGS=--disable-xmpp
else
CLIMM_CONFIG_ARGS=--enable-xmpp
endif

#
# CLIMM_BUILD_DIR is the directory in which the build is done.
# CLIMM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLIMM_IPK_DIR is the directory in which the ipk is built.
# CLIMM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLIMM_BUILD_DIR=$(BUILD_DIR)/climm
CLIMM_SOURCE_DIR=$(SOURCE_DIR)/climm
CLIMM_IPK_DIR=$(BUILD_DIR)/climm-$(CLIMM_VERSION)-ipk
CLIMM_IPK=$(BUILD_DIR)/climm_$(CLIMM_VERSION)-$(CLIMM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: climm-source climm-unpack climm climm-stage climm-ipk climm-clean climm-dirclean climm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLIMM_SOURCE):
	$(WGET) -P $(@D) $(CLIMM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
climm-source: $(DL_DIR)/$(CLIMM_SOURCE) $(CLIMM_PATCHES)

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
$(CLIMM_BUILD_DIR)/.configured: $(DL_DIR)/$(CLIMM_SOURCE) $(CLIMM_PATCHES) make/climm.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) libgcrypt-stage gnutls-stage libotr-stage
ifneq (, $(filter gloox, $(PACKAGES)))
	$(MAKE) gloox-stage
endif
	rm -rf $(BUILD_DIR)/$(CLIMM_DIR) $(@D)
	$(CLIMM_UNZIP) $(DL_DIR)/$(CLIMM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CLIMM_PATCHES)" ; \
		then cat $(CLIMM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CLIMM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CLIMM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CLIMM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLIMM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CLIMM_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(CLIMM_CONFIG_ARGS) \
		--with-libgnutls-prefix=$(STAGING_PREFIX) \
		--with-libgcrypt-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

climm-unpack: $(CLIMM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLIMM_BUILD_DIR)/.built: $(CLIMM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
climm: $(CLIMM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLIMM_BUILD_DIR)/.staged: $(CLIMM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

climm-stage: $(CLIMM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/climm
#
$(CLIMM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: climm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLIMM_PRIORITY)" >>$@
	@echo "Section: $(CLIMM_SECTION)" >>$@
	@echo "Version: $(CLIMM_VERSION)-$(CLIMM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLIMM_MAINTAINER)" >>$@
	@echo "Source: $(CLIMM_SITE)/$(CLIMM_SOURCE)" >>$@
	@echo "Description: $(CLIMM_DESCRIPTION)" >>$@
	@echo "Depends: $(CLIMM_DEPENDS)" >>$@
	@echo "Suggests: $(CLIMM_SUGGESTS)" >>$@
	@echo "Conflicts: $(CLIMM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLIMM_IPK_DIR)/opt/sbin or $(CLIMM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLIMM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLIMM_IPK_DIR)/opt/etc/climm/...
# Documentation files should be installed in $(CLIMM_IPK_DIR)/opt/doc/climm/...
# Daemon startup scripts should be installed in $(CLIMM_IPK_DIR)/opt/etc/init.d/S??climm
#
# You may need to patch your application to make it use these locations.
#
$(CLIMM_IPK): $(CLIMM_BUILD_DIR)/.built
	rm -rf $(CLIMM_IPK_DIR) $(BUILD_DIR)/climm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CLIMM_BUILD_DIR) DESTDIR=$(CLIMM_IPK_DIR) install-strip
#	install -d $(CLIMM_IPK_DIR)/opt/etc/
#	install -m 644 $(CLIMM_SOURCE_DIR)/climm.conf $(CLIMM_IPK_DIR)/opt/etc/climm.conf
#	install -d $(CLIMM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CLIMM_SOURCE_DIR)/rc.climm $(CLIMM_IPK_DIR)/opt/etc/init.d/SXXclimm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLIMM_IPK_DIR)/opt/etc/init.d/SXXclimm
	$(MAKE) $(CLIMM_IPK_DIR)/CONTROL/control
#	install -m 755 $(CLIMM_SOURCE_DIR)/postinst $(CLIMM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLIMM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CLIMM_SOURCE_DIR)/prerm $(CLIMM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLIMM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CLIMM_IPK_DIR)/CONTROL/postinst $(CLIMM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CLIMM_CONFFILES) | sed -e 's/ /\n/g' > $(CLIMM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLIMM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
climm-ipk: $(CLIMM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
climm-clean:
	rm -f $(CLIMM_BUILD_DIR)/.built
	-$(MAKE) -C $(CLIMM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
climm-dirclean:
	rm -rf $(BUILD_DIR)/$(CLIMM_DIR) $(CLIMM_BUILD_DIR) $(CLIMM_IPK_DIR) $(CLIMM_IPK)
#
#
# Some sanity check for the package.
#
climm-check: $(CLIMM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CLIMM_IPK)
