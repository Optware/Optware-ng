###########################################################
# telldus-core
# $Id$
#
###########################################################

TELLDUS-CORE_SITE=http://download.telldus.com/TellStick/Software/telldus-core/
TELLDUS-CORE_VERSION=2.0.4
TELLDUS-CORE_SOURCE=telldus-core-$(TELLDUS-CORE_VERSION).tar.gz
TELLDUS-CORE_DIR=telldus-core-$(TELLDUS-CORE_VERSION)
TELLDUS-CORE_UNZIP=zcat
TELLDUS-CORE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TELLDUS-CORE_DESCRIPTION=Utilities to control NEXA and other RF remote receivers through a TellStick USB interface
TELLDUS-CORE_SECTION=util
TELLDUS-CORE_PRIORITY=optional
TELLDUS-CORE_DEPENDS=confuse
TELLDUS-CORE_SUGGESTS=
TELLDUS-CORE_CONFLICTS=

TELLDUS-CORE_IPK_VERSION=1

TELLDUS-CORE_CONFFILES=/opt/etc/tellstick.conf /opt/etc/init.d/S50tellstick
TELLDUS-CORE_PATCHES=$(TELLDUS-CORE_SOURCE_DIR)/telldus-core.patch

TELLDUS-CORE_CPPFLAGS=
TELLDUS-CORE_LDFLAGS=

#
# You should not change any of these variables.
#
TELLDUS-CORE_BUILD_DIR=$(BUILD_DIR)/telldus-core
TELLDUS-CORE_SOURCE_DIR=$(SOURCE_DIR)/telldus-core
TELLDUS-CORE_IPK_DIR=$(BUILD_DIR)/telldus-core-$(TELLDUS-CORE_VERSION)-ipk
TELLDUS-CORE_IPK=$(BUILD_DIR)/telldus-core_$(TELLDUS-CORE_VERSION)-$(TELLDUS-CORE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: telldus-core-source telldus-core-unpack telldus-core telldus-core-stage telldus-core-ipk telldus-core-clean telldus-core-dirclean telldus-core-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TELLDUS-CORE_SOURCE):
	$(WGET) -P $(@D) $(TELLDUS-CORE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
telldus-core-source: $(DL_DIR)/$(TELLDUS-CORE_SOURCE) $(TELLDUS-CORE_PATCHES)

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

$(TELLDUS-CORE_BUILD_DIR)/.configured: $(DL_DIR)/$(TELLDUS-CORE_SOURCE) $(TELLDUS-CORE_PATCHES) make/telldus-core.mk
	$(MAKE) confuse-stage
	rm -rf $(BUILD_DIR)/$(TELLDUS-CORE_DIR) $(@D)
	$(TELLDUS-CORE_UNZIP) $(DL_DIR)/$(TELLDUS-CORE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(TELLDUS-CORE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TELLDUS-CORE_DIR) $(@D) ; \
	fi
	if test -n "$(TELLDUS-CORE_PATCHES)" ; \
		then cat $(TELLDUS-CORE_PATCHES) | \
		patch -d $(@D) -p1 ; \
	fi
	(cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TELLDUS-CORE_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(TELLDUS-CORE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TELLDUS-CORE_LDFLAGS)" \
		cmake \
                        -DCMAKE_SKIP_BUILD_RPATH=TRUE \
                        -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
                        -DCMAKE_INSTALL_RPATH="/opt/lib" \
                        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
			-DBUILD_RFCMD=0 \
			-DCMAKE_INSTALL_PREFIX=/opt \
			-DBUILD_LIBTELLDUS-CORE=1 \
			-DBUILD_TDTOOL=1 \
			-DSUPPORT_TELLSTICK_DUO=0 \
			-DSUPPORT_USB=0 \
			-DGENERATE_MAN=0 \
			-DUSE_QT_SETTINGS_BACKEND=0 \
	)
	touch $@

telldus-core-unpack: $(TELLDUS-CORE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TELLDUS-CORE_BUILD_DIR)/.built: $(TELLDUS-CORE_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D) && \
	$(MAKE)
	touch $@

#
# This is the build convenience target.
#
telldus-core: $(TELLDUS-CORE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TELLDUS-CORE_BUILD_DIR)/.staged: $(TELLDUS-CORE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

telldus-core-stage: $(TELLDUS-CORE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/telldus-core
#
$(TELLDUS-CORE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: telldus-core" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TELLDUS-CORE_PRIORITY)" >>$@
	@echo "Section: $(TELLDUS-CORE_SECTION)" >>$@
	@echo "Version: $(TELLDUS-CORE_VERSION)-$(TELLDUS-CORE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TELLDUS-CORE_MAINTAINER)" >>$@
	@echo "Source: $(TELLDUS-CORE_SITE)/$(TELLDUS-CORE_SOURCE)" >>$@
	@echo "Description: $(TELLDUS-CORE_DESCRIPTION)" >>$@
	@echo "Depends: $(TELLDUS-CORE_DEPENDS)" >>$@
	@echo "Suggests: $(TELLDUS-CORE_SUGGESTS)" >>$@
	@echo "Conflicts: $(TELLDUS-CORE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(TELLDUS-CORE_IPK): $(TELLDUS-CORE_BUILD_DIR)/.built
	rm -rf $(TELLDUS-CORE_IPK_DIR) $(BUILD_DIR)/telldus-core_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TELLDUS-CORE_BUILD_DIR) DESTDIR=$(TELLDUS-CORE_IPK_DIR) install
	$(STRIP_COMMAND) $(TELLDUS-CORE_IPK_DIR)/opt/bin/tdtool
	$(STRIP_COMMAND) $(TELLDUS-CORE_IPK_DIR)/opt/lib/libtelldus-core.so.2.0.4
	install -d $(TELLDUS-CORE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(TELLDUS-CORE_SOURCE_DIR)/rc.tellstick.sh $(TELLDUS-CORE_IPK_DIR)/opt/etc/init.d/S50tellstick
	$(MAKE) $(TELLDUS-CORE_IPK_DIR)/CONTROL/control
	install -m 755 $(TELLDUS-CORE_SOURCE_DIR)/postinst $(TELLDUS-CORE_IPK_DIR)/CONTROL/postinst
	echo $(TELLDUS-CORE_CONFFILES) | sed -e 's/ /\n/g' > $(TELLDUS-CORE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TELLDUS-CORE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(iTELLDUS-CORE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
telldus-core-ipk: $(TELLDUS-CORE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
telldus-core-clean:
	rm -f $(TELLDUS-CORE_BUILD_DIR)/.built
	-$(MAKE) -C $(TELLDUS-CORE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
telldus-core-dirclean:
	rm -rf $(BUILD_DIR)/$(TELLDUS-CORE_DIR) $(TELLDUS-CORE_BUILD_DIR) $(TELLDUS-CORE_IPK_DIR) $(TELLDUS-CORE_IPK)

#
# Some sanity check for the package.
#
telldus-core-check: $(TELLDUS-CORE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

