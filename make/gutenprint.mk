###########################################################
#
# gutenprint
#
###########################################################
#
# GUTENPRINT_VERSION, GUTENPRINT_SITE and GUTENPRINT_SOURCE define
# the upstream location of the source code for the package.
# GUTENPRINT_DIR is the directory which is created when the source
# archive is unpacked.
# GUTENPRINT_UNZIP is the command used to unzip the source.
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
GUTENPRINT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gimp-print
GUTENPRINT_VERSION=5.2.3
GUTENPRINT_SOURCE=gutenprint-$(GUTENPRINT_VERSION).tar.bz2
GUTENPRINT_DIR=gutenprint-$(GUTENPRINT_VERSION)
GUTENPRINT_UNZIP=bzcat
GUTENPRINT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GUTENPRINT_DESCRIPTION=Gutenprint.
GUTENPRINT-CUPS-DRIVER_DESCRIPTION=CUPS driver from Gutenprint.
GUTENPRINT-FOOMATIC-DB_DESCRIPTION=Support for printers using the Gutenprint printer driver suite.
GUTENPRINT_SECTION=print
GUTENPRINT_PRIORITY=optional
GUTENPRINT_DEPENDS=cups, libijs, ncurses, readline
GUTENPRINT_SUGGESTS=
GUTENPRINT_CONFLICTS=

#
# GUTENPRINT_IPK_VERSION should be incremented when the ipk changes.
#
GUTENPRINT_IPK_VERSION=1

#
# GUTENPRINT_CONFFILES should be a list of user-editable files
#GUTENPRINT_CONFFILES=/opt/etc/gutenprint.conf /opt/etc/init.d/SXXgutenprint

#
# GUTENPRINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GUTENPRINT_PATCHES=$(GUTENPRINT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GUTENPRINT_CPPFLAGS=
GUTENPRINT_LDFLAGS=

#
# GUTENPRINT_BUILD_DIR is the directory in which the build is done.
# GUTENPRINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GUTENPRINT_IPK_DIR is the directory in which the ipk is built.
# GUTENPRINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GUTENPRINT_SOURCE_DIR=$(SOURCE_DIR)/gutenprint

GUTENPRINT_BUILD_DIR=$(BUILD_DIR)/gutenprint
GUTENPRINT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gutenprint

GUTENPRINT_IPK_DIR=$(BUILD_DIR)/gutenprint-$(GUTENPRINT_VERSION)-ipk
GUTENPRINT_IPK=$(BUILD_DIR)/gutenprint_$(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

GUTENPRINT-CUPS-DRIVER_IPK_DIR=$(BUILD_DIR)/cups-driver-gutenprint-$(GUTENPRINT_VERSION)-ipk
GUTENPRINT-CUPS-DRIVER_IPK=$(BUILD_DIR)/cups-driver-gutenprint_$(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

GUTENPRINT-FOOMATIC-DB_IPK_DIR=$(BUILD_DIR)/foomatic-db-gutenprint-$(GUTENPRINT_VERSION)-ipk
GUTENPRINT-FOOMATIC-DB_IPK=$(BUILD_DIR)/foomatic-db-gutenprint_$(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gutenprint-source gutenprint-unpack gutenprint gutenprint-stage gutenprint-ipk gutenprint-clean gutenprint-dirclean gutenprint-check

$(DL_DIR)/$(GUTENPRINT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GUTENPRINT_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

gutenprint-source: $(DL_DIR)/$(GUTENPRINT_SOURCE) $(GUTENPRINT_PATCHES)

$(GUTENPRINT_HOST_BUILD_DIR)/.built: $(DL_DIR)/$(GUTENPRINT_SOURCE) make/gutenprint.mk
	$(MAKE) cups-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(GUTENPRINT_DIR) $(@D)
	$(GUTENPRINT_UNZIP) $(DL_DIR)/$(GUTENPRINT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(GUTENPRINT_PATCHES)" ; \
		then cat $(GUTENPRINT_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(GUTENPRINT_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(GUTENPRINT_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(GUTENPRINT_DIR) $(@D) ; \
	fi
#		ac_cv_path_FOOMATIC_CONFIGURE=$(HOST_STAGING_PREFIX)/bin/foomatic-config
	(cd $(@D); \
		ac_cv_path_CUPS_CONFIG=$(HOST_STAGING_PREFIX)/bin/cups-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/opt \
		--with-cups=/opt \
		--enable-cups-ppds \
		--enable-cups-level3-ppds \
		--without-ghostscript \
		--without-foomatic \
		--disable-libgutenprintui2 \
		--disable-gtktest \
		--disable-nls \
		--disable-static \
	)
	LD_LIBRARY_PATH=$(HOST_STAGING_LIB_DIR) \
	$(MAKE) -C $(@D)
	touch $@

gutenprint-host: $(GUTENPRINT_HOST_BUILD_DIR)/.built

$(GUTENPRINT_BUILD_DIR)/.configured: $(DL_DIR)/$(GUTENPRINT_SOURCE) $(GUTENPRINT_PATCHES) make/gutenprint.mk
	$(MAKE) cups-stage libijs-stage ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(GUTENPRINT_DIR) $(GUTENPRINT_BUILD_DIR)
	$(GUTENPRINT_UNZIP) $(DL_DIR)/$(GUTENPRINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GUTENPRINT_PATCHES)" ; \
		then cat $(GUTENPRINT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GUTENPRINT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GUTENPRINT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GUTENPRINT_DIR) $(@D) ; \
	fi
	sed -i -e 's/test -d $${withval}/true/' $(@D)/configure
	sed -i -e 's|./extract-strings |$(GUTENPRINT_HOST_BUILD_DIR)/src/xml/extract-strings |' $(@D)/src/xml/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GUTENPRINT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GUTENPRINT_LDFLAGS)" \
		ac_cv_path_IJS_CONFIG=$(STAGING_PREFIX)/bin/ijs-config \
		ac_cv_path_CUPS_CONFIG=$(STAGING_PREFIX)/bin/cups-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-cups=/opt \
		--disable-cups-ppds \
		--without-foomatic \
		--disable-libgutenprintui2 \
		--disable-gtktest \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gutenprint-unpack: $(GUTENPRINT_BUILD_DIR)/.configured

$(GUTENPRINT_BUILD_DIR)/.built: $(GUTENPRINT_HOST_BUILD_DIR)/.built $(GUTENPRINT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

gutenprint: $(GUTENPRINT_BUILD_DIR)/.built

$(GUTENPRINT_BUILD_DIR)/.staged: $(GUTENPRINT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gutenprint-stage: $(GUTENPRINT_BUILD_DIR)/.staged

$(GUTENPRINT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gutenprint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GUTENPRINT_PRIORITY)" >>$@
	@echo "Section: $(GUTENPRINT_SECTION)" >>$@
	@echo "Version: $(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GUTENPRINT_MAINTAINER)" >>$@
	@echo "Source: $(GUTENPRINT_SITE)/$(GUTENPRINT_SOURCE)" >>$@
	@echo "Description: $(GUTENPRINT_DESCRIPTION)" >>$@
	@echo "Depends: $(GUTENPRINT_DEPENDS)" >>$@
	@echo "Suggests: $(GUTENPRINT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GUTENPRINT_CONFLICTS)" >>$@

$(GUTENPRINT-FOOMATIC-DB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: foomatic-db-gutenprint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GUTENPRINT_PRIORITY)" >>$@
	@echo "Section: $(GUTENPRINT_SECTION)" >>$@
	@echo "Version: $(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GUTENPRINT_MAINTAINER)" >>$@
	@echo "Source: $(GUTENPRINT_SITE)/$(GUTENPRINT_SOURCE)" >>$@
	@echo "Description: $(GUTENPRINT-FOOMATIC-DB_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(GUTENPRINT-CUPS-DRIVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cups-driver-gutenprint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GUTENPRINT_PRIORITY)" >>$@
	@echo "Section: $(GUTENPRINT_SECTION)" >>$@
	@echo "Version: $(GUTENPRINT_VERSION)-$(GUTENPRINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GUTENPRINT_MAINTAINER)" >>$@
	@echo "Source: $(GUTENPRINT_SITE)/$(GUTENPRINT_SOURCE)" >>$@
	@echo "Description: $(GUTENPRINT-CUPS-DRIVER_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(GUTENPRINT_IPK): $(GUTENPRINT_BUILD_DIR)/.built
	rm -rf $(GUTENPRINT_IPK_DIR) $(BUILD_DIR)/gutenprint_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GUTENPRINT_BUILD_DIR) install-strip DESTDIR=$(GUTENPRINT_IPK_DIR)
	$(MAKE) $(GUTENPRINT_IPK_DIR)/CONTROL/control
	echo $(GUTENPRINT_CONFFILES) | sed -e 's/ /\n/g' > $(GUTENPRINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GUTENPRINT_IPK_DIR)

$(GUTENPRINT-CUPS-DRIVER_IPK): $(GUTENPRINT_HOST_BUILD_DIR)/.built
	rm -rf $(GUTENPRINT-CUPS-DRIVER_IPK_DIR) $(BUILD_DIR)/cups-driver-gutenprint_*_$(TARGET_ARCH).ipk
	install -d $(GUTENPRINT-CUPS-DRIVER_IPK_DIR)/opt/share/cups/model
	install $(GUTENPRINT_HOST_BUILD_DIR)/src/cups/ppd/C/*ppd.gz \
		$(GUTENPRINT-CUPS-DRIVER_IPK_DIR)/opt/share/cups/model/
	$(MAKE) $(GUTENPRINT-CUPS-DRIVER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GUTENPRINT-CUPS-DRIVER_IPK_DIR)

$(GUTENPRINT-FOOMATIC-DB_IPK): $(GUTENPRINT_HOST_BUILD_DIR)/.built
	rm -rf $(GUTENPRINT-FOOMATIC-DB_IPK_DIR) $(BUILD_DIR)/foomatic-db-gutenprint_*_$(TARGET_ARCH).ipk
	install -d $(GUTENPRINT-FOOMATIC-DB_IPK_DIR)/opt/share/foomatic
	cp -rp $(GUTENPRINT_HOST_BUILD_DIR)/src/foomatic/foomatic-db \
		$(GUTENPRINT-FOOMATIC-DB_IPK_DIR)/opt/share/foomatic/db
	$(MAKE) $(GUTENPRINT-FOOMATIC-DB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GUTENPRINT-FOOMATIC-DB_IPK_DIR)

#gutenprint-ipk: $(GUTENPRINT_IPK) $(GUTENPRINT-CUPS-DRIVER_IPK) $(GUTENPRINT-FOOMATIC-DB_IPK_DIR)
gutenprint-ipk: $(GUTENPRINT_IPK) $(GUTENPRINT-CUPS-DRIVER_IPK)

gutenprint-clean:
	rm -f $(GUTENPRINT_BUILD_DIR)/.built
	-$(MAKE) -C $(GUTENPRINT_BUILD_DIR) clean

gutenprint-dirclean:
	rm -rf $(BUILD_DIR)/$(GUTENPRINT_DIR) $(GUTENPRINT_BUILD_DIR)
	rm -rf $(GUTENPRINT_IPK_DIR) $(GUTENPRINT_IPK)
	rm -rf $(GUTENPRINT-CUPS-DRIVER_IPK_DIR) $(GUTENPRINT-CUPS-DRIVER_IPK)
	rm -rf $(GUTENPRINT-FOOMATIC-DB_IPK_DIR) $(GUTENPRINT-FOOMATIC-DB_IPK)

gutenprint-check: $(GUTENPRINT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GUTENPRINT_IPK)
