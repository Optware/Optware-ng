###########################################################
#
# espgs
#
###########################################################

# You must replace "espgs" and "ESPGS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ESPGS_VERSION, ESPGS_SITE and ESPGS_SOURCE define
# the upstream location of the source code for the package.
# ESPGS_DIR is the directory which is created when the source
# archive is unpacked.
# ESPGS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ESPGS_VERSION=8.15.4
ESPGS_SITE=http://ftp.easysw.com/pub/ghostscript/$(ESPGS_VERSION)
ESPGS_SOURCE=espgs-$(ESPGS_VERSION)-source.tar.bz2
ESPGS_DIR=espgs-$(ESPGS_VERSION)
ESPGS_UNZIP=bzcat
ESPGS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
# Keith Garry Boyce <nslu2-linux@yahoogroups.com>
ESPGS_DESCRIPTION=ESP Ghostscript
ESPGS_SECTION=tool
ESPGS_PRIORITY=optional
ESPGS_DEPENDS=
ESPGS_SUGGESTS=
ESPGS_CONFLICTS=

#
# ESPGS_IPK_VERSION should be incremented when the ipk changes.
#
ESPGS_IPK_VERSION=1

#
# ESPGS_CONFFILES should be a list of user-editable files
# ESPGS_CONFFILES=/opt/etc/espgs.conf /opt/etc/init.d/SXXespgs

#
## ESPGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ESPGS_PATCHES=$(ESPGS_SOURCE_DIR)/patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ESPGS_CPPFLAGS=
ESPGS_LDFLAGS=

#
# ESPGS_BUILD_DIR is the directory in which the build is done.
# ESPGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ESPGS_IPK_DIR is the directory in which the ipk is built.
# ESPGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ESPGS_SOURCE_DIR=$(SOURCE_DIR)/espgs

ESPGS_BUILD_DIR=$(BUILD_DIR)/espgs
ESPGS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/espgs

ESPGS_IPK_DIR=$(BUILD_DIR)/espgs-$(ESPGS_VERSION)-ipk
ESPGS_IPK=$(BUILD_DIR)/espgs_$(ESPGS_VERSION)-$(ESPGS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ESPGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ESPGS_SITE)/$(ESPGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
espgs-source: $(DL_DIR)/$(ESPGS_SOURCE)

$(ESPGS_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(ESPGS_SOURCE) $(ESPGS_PATCHES)
	rm -rf $(HOST_BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_HOST_BUILD_DIR)
	$(ESPGS_UNZIP) $(DL_DIR)/$(ESPGS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_HOST_BUILD_DIR)
	cd $(ESPGS_HOST_BUILD_DIR); \
		./configure --prefix=/opt
	mkdir -p $(ESPGS_HOST_BUILD_DIR)/obj
	$(MAKE) -C $(ESPGS_HOST_BUILD_DIR) ./obj/echogs
	touch $@

espgs-host-build: $(ESPGS_HOST_BUILD_DIR)/.built

$(ESPGS_BUILD_DIR)/.configured: $(DL_DIR)/$(ESPGS_SOURCE) $(ESPGS_PATCHES)
	$(MAKE) libjpeg-stage zlib-stage libpng-stage libtiff-stage
	$(MAKE) cups-stage openssl-stage zlib-stage
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR)
	$(ESPGS_UNZIP) $(DL_DIR)/$(ESPGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ESPGS_PATCHES) | patch -d $(BUILD_DIR)/$(ESPGS_DIR) -p1
	mv $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR)
#	sed -i \
	       -e '/-mkdir -p $$(datadir)/s|mkdir -p |mkdir -p $$(install_prefix)|' \
		$(ESPGS_BUILD_DIR)/src/unixinst.mak
	(cd $(ESPGS_BUILD_DIR); \
		PATH=$(STAGING_PREFIX)/bin:$$PATH \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESPGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESPGS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--with-ijs \
		--disable-nls \
		--disable-static \
		; \
	)
	touch $@

espgs-unpack: $(ESPGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ESPGS_BUILD_DIR)/.built: $(ESPGS_BUILD_DIR)/.configured
	rm -f $@
	mkdir -p $(@D)/obj
	$(MAKE) -C $(@D) ./obj/echogs ./obj/genarch ./obj/genconf CC=$(HOSTCC)
	mv $(@D)/obj/echogs $(@D)/obj/echogs.build
	mv $(@D)/obj/genarch $(@D)/obj/genarch.build
	mv $(@D)/obj/genconf $(@D)/obj/genconf.build
	# TODO different TARGET_ARCH needs different arch.h
	$(MAKE) -C $(@D) obj/arch.h \
		GENARCH_XE=$(@D)/obj/genarch.build
	cp $(@D)/obj/arch.h $(@D)/obj/arch.h.orig
	cp $(ESPGS_SOURCE_DIR)/arch.h $(@D)/obj/arch.h
	#
	$(MAKE) -C $(@D) \
		ECHOGS_XE=$(@D)/obj/echogs.build \
		GENARCH_XE=$(@D)/obj/genarch.build \
		GENCONF_XE=$(@D)/obj/genconf.build \
		;
	touch $@

#
# This is the build convenience target.
#
espgs: $(ESPGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ESPGS_BUILD_DIR)/.staged: $(ESPGS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ESPGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

espgs-stage: $(ESPGS_BUILD_DIR)/.staged

$(ESPGS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: espgs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ESPGS_PRIORITY)" >>$@
	@echo "Section: $(ESPGS_SECTION)" >>$@
	@echo "Version: $(ESPGS_VERSION)-$(ESPGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ESPGS_MAINTAINER)" >>$@
	@echo "Source: $(ESPGS_SITE)/$(ESPGS_SOURCE)" >>$@
	@echo "Description: $(ESPGS_DESCRIPTION)" >>$@
	@echo "Depends: $(ESPGS_DEPENDS)" >>$@
	@echo "Suggests: $(ESPGS_SUGGESTS)" >>$@
	@echo "Conflicts: $(ESPGS_CONFLICTS)" >>$@

$(ESPGS_IPK): $(ESPGS_BUILD_DIR)/.built
	rm -rf $(ESPGS_IPK_DIR) $(BUILD_DIR)/espgs_*_$(TARGET_ARCH).ipk
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(ESPGS_BUILD_DIR) install \
		DESTDIR=$(ESPGS_IPK_DIR) \
		install_prefix=$(ESPGS_IPK_DIR) \
		prefix=/opt \
		ECHOGS_XE=$(ESPGS_BUILD_DIR)/obj/echogs.build \
		GENARCH_XE=$(ESPGS_BUILD_DIR)/obj/genarch.build \
		GENCONF_XE=$(ESPGS_BUILD_DIR)/obj/genconf.build \
		;
	sed -i -e 's|/usr/share|/opt/share|' $(ESPGS_IPK_DIR)/opt/lib/cups/filter/psto*
	$(STRIP_COMMAND) $(ESPGS_IPK_DIR)/opt/bin/gs
	$(MAKE) $(ESPGS_IPK_DIR)/CONTROL/control
	echo $(ESPGS_CONFFILES) | sed -e 's/ /\n/g' > $(ESPGS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ESPGS_IPK_DIR)

espgs-ipk: $(ESPGS_IPK)

espgs-clean:
	-$(MAKE) -C $(ESPGS_BUILD_DIR) clean

espgs-dirclean:
	rm -rf $(BUILD_DIR)/$(ESPGS_DIR) $(ESPGS_BUILD_DIR) $(ESPGS_IPK_DIR) $(ESPGS_IPK)

espgs-check: $(ESPGS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ESPGS_IPK)
