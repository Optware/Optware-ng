###########################################################
#
# ghostscript
#
###########################################################

# You must replace "ghostscript" and "GHOSTSCRIPT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GHOSTSCRIPT_VERSION, GHOSTSCRIPT_SITE and GHOSTSCRIPT_SOURCE define
# the upstream location of the source code for the package.
# GHOSTSCRIPT_DIR is the directory which is created when the source
# archive is unpacked.
# GHOSTSCRIPT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GHOSTSCRIPT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ghostscript
GHOSTSCRIPT_VERSION=8.64
GHOSTSCRIPT_SOURCE=ghostscript-$(GHOSTSCRIPT_VERSION).tar.bz2
GHOSTSCRIPT_DIR=ghostscript-$(GHOSTSCRIPT_VERSION)
GHOSTSCRIPT_UNZIP=bzcat
GHOSTSCRIPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GHOSTSCRIPT_DESCRIPTION=An interpreter for the PostScript (TM) language
GHOSTSCRIPT_SECTION=text
GHOSTSCRIPT_PRIORITY=optional
GHOSTSCRIPT_DEPENDS=cups, fontconfig, libpng, openssl
GHOSTSCRIPT_SUGGESTS=
GHOSTSCRIPT_CONFLICTS=

#
# GHOSTSCRIPT_IPK_VERSION should be incremented when the ipk changes.
#
GHOSTSCRIPT_IPK_VERSION=1

#
# GHOSTSCRIPT_CONFFILES should be a list of user-editable files
# GHOSTSCRIPT_CONFFILES=/opt/etc/ghostscript.conf /opt/etc/init.d/SXXghostscript

#
## GHOSTSCRIPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifdef NO_BUILTIN_MATH
GHOSTSCRIPT_PATCHES=$(GHOSTSCRIPT_SOURCE_DIR)/uclibc-cbrt.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GHOSTSCRIPT_CPPFLAGS=
GHOSTSCRIPT_LDFLAGS=

#
# GHOSTSCRIPT_BUILD_DIR is the directory in which the build is done.
# GHOSTSCRIPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GHOSTSCRIPT_IPK_DIR is the directory in which the ipk is built.
# GHOSTSCRIPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GHOSTSCRIPT_SOURCE_DIR=$(SOURCE_DIR)/ghostscript
GHOSTSCRIPT_BUILD_DIR=$(BUILD_DIR)/ghostscript
GHOSTSCRIPT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/ghostscript
GHOSTSCRIPT_IPK_DIR=$(BUILD_DIR)/ghostscript-$(GHOSTSCRIPT_VERSION)-ipk
GHOSTSCRIPT_IPK=$(BUILD_DIR)/ghostscript_$(GHOSTSCRIPT_VERSION)-$(GHOSTSCRIPT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GHOSTSCRIPT_SOURCE):
	$(WGET) -P $(@D) $(GHOSTSCRIPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ghostscript-source: $(DL_DIR)/$(GHOSTSCRIPT_SOURCE)

$(GHOSTSCRIPT_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) make/ghostscript.mk
	rm -rf $(HOST_BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(@D)
	$(GHOSTSCRIPT_UNZIP) $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(@D)
#	sed -i -e '/^EXTRALIBS/s/$$/ @LDFLAGS@/' $(@D)/Makefile.in
	(cd $(@D); \
		./configure \
		--prefix=/opt \
		--without-x \
		--without-jasper \
		--disable-nls \
		--disable-static \
		; \
	)
	mkdir -p $(@D)/obj
	$(MAKE) -C $(@D) ./obj/echogs ./obj/genarch ./obj/genconf ./obj/mkromfs
	touch $@

ghostscript-host-build: $(GHOSTSCRIPT_HOST_BUILD_DIR)/.built

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
ifeq ($(TARGET_CC),$(HOSTCC))
$(GHOSTSCRIPT_BUILD_DIR)/.configured: $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) $(GHOSTSCRIPT_PATCHES) make/ghostscript.mk
else
$(GHOSTSCRIPT_BUILD_DIR)/.configured: $(GHOSTSCRIPT_HOST_BUILD_DIR)/.built $(GHOSTSCRIPT_PATCHES)
endif
	$(MAKE) cups-stage fontconfig-stage openssl-stage
	$(MAKE) libjpeg-stage libpng-stage libtiff-stage
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(@D)
	$(GHOSTSCRIPT_UNZIP) $(DL_DIR)/$(GHOSTSCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GHOSTSCRIPT_PATCHES)"; then \
		cat $(GHOSTSCRIPT_PATCHES) | patch -d $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(@D)
	sed -i -e '/^EXTRALIBS/s/$$/ @LDFLAGS@/' $(@D)/Makefile.in
	sed -i -e 's|$$(EXP)$$(MKROMFS_XE)|$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/mkromfs|' $(@D)/base/lib.mak
	sed -i -e '/cups-config --image/s| -o |$(STAGING_LDFLAGS)&|' $(@D)/cups/cups.mak
	(cd $(@D); \
		PATH=$(STAGING_PREFIX)/bin:$$PATH \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ESPGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ESPGS_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_path_CUPSCONFIG=$(STAGING_PREFIX)/bin/cups-config \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-gtk \
		--disable-cairo \
		--without-jasper \
		--with-ijs \
		--disable-nls \
		--disable-static \
		; \
	)
	sed -i -e 's|-I/opt/include ||' $(@D)/Makefile
	touch $@

ghostscript-unpack: $(GHOSTSCRIPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GHOSTSCRIPT_BUILD_DIR)/.built: $(GHOSTSCRIPT_BUILD_DIR)/.configured
	rm -f $@
	mkdir -p $(@D)/obj
	# TODO different TARGET_ARCH needs different arch.h
	$(MAKE) -C $(@D) obj/arch.h \
		GENARCH_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/genarch
	[ -e $(GHOSTSCRIPT_SOURCE_DIR)/arch-$(TARGET_ARCH).h ] && \
	cp $(GHOSTSCRIPT_SOURCE_DIR)/arch-$(TARGET_ARCH).h $(@D)/obj/arch.h || \
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then sed -e '/ARCH_IS_BIG_ENDIAN/s/[01]/1/' $(GHOSTSCRIPT_SOURCE_DIR)/arch-unknown.h \
		> $(@D)/obj/arch.h; \
	else sed -e '/ARCH_IS_BIG_ENDIAN/s/[01]/0/' $(GHOSTSCRIPT_SOURCE_DIR)/arch-unknown.h \
		> $(@D)/obj/arch.h; \
	fi
	#
	$(MAKE) -C $(@D) \
		ECHOGS_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/echogs \
		GENARCH_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/genarch \
		GENCONF_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/genconf \
		GENINIT_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/geninit \
		;
	touch $@

#
# This is the build convenience target.
#
ghostscript: $(GHOSTSCRIPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GHOSTSCRIPT_BUILD_DIR)/.staged: $(GHOSTSCRIPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ghostscript-stage: $(GHOSTSCRIPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ghostscript
#
$(GHOSTSCRIPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ghostscript" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GHOSTSCRIPT_PRIORITY)" >>$@
	@echo "Section: $(GHOSTSCRIPT_SECTION)" >>$@
	@echo "Version: $(GHOSTSCRIPT_VERSION)-$(GHOSTSCRIPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GHOSTSCRIPT_MAINTAINER)" >>$@
	@echo "Source: $(GHOSTSCRIPT_SITE)/$(GHOSTSCRIPT_SOURCE)" >>$@
	@echo "Description: $(GHOSTSCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(GHOSTSCRIPT_DEPENDS)" >>$@
	@echo "Suggests: $(GHOSTSCRIPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GHOSTSCRIPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GHOSTSCRIPT_IPK_DIR)/opt/sbin or $(GHOSTSCRIPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GHOSTSCRIPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/etc/ghostscript/...
# Documentation files should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/doc/ghostscript/...
# Daemon startup scripts should be installed in $(GHOSTSCRIPT_IPK_DIR)/opt/etc/init.d/S??ghostscript
#
# You may need to patch your application to make it use these locations.
#
$(GHOSTSCRIPT_IPK): $(GHOSTSCRIPT_BUILD_DIR)/.built
	rm -rf $(GHOSTSCRIPT_IPK_DIR) $(BUILD_DIR)/ghostscript_*_$(TARGET_ARCH).ipk
	PATH=$(STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR) install \
		DESTDIR=$(GHOSTSCRIPT_IPK_DIR) \
		ECHOGS_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/echogs \
		GENARCH_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/genarch \
		GENCONF_XE=$(GHOSTSCRIPT_HOST_BUILD_DIR)/obj/genconf \
		;
	$(STRIP_COMMAND) $(GHOSTSCRIPT_IPK_DIR)/opt/bin/gs $(GHOSTSCRIPT_IPK_DIR)/opt/lib/cups/filter/pdftoraster
	sed -i -e 's|/usr/share|/opt/share|' $(GHOSTSCRIPT_IPK_DIR)/opt/lib/cups/filter/psto*
	$(MAKE) $(GHOSTSCRIPT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GHOSTSCRIPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ghostscript-ipk: $(GHOSTSCRIPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ghostscript-clean:
	-$(MAKE) -C $(GHOSTSCRIPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ghostscript-dirclean:
	rm -rf $(BUILD_DIR)/$(GHOSTSCRIPT_DIR) $(GHOSTSCRIPT_BUILD_DIR) $(GHOSTSCRIPT_IPK_DIR) $(GHOSTSCRIPT_IPK)

#
# Some sanity check for the package.
#
ghostscript-check: $(GHOSTSCRIPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GHOSTSCRIPT_IPK)
