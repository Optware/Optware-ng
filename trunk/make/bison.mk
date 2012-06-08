###########################################################
#
# bison
#
###########################################################

BISON_SITE=http://ftp.gnu.org/gnu/bison
BISON_VERSION=2.5.1
BISON_SOURCE=bison-$(BISON_VERSION).tar.xz
BISON_DIR=bison-$(BISON_VERSION)
BISON_UNZIP=$(HOST_STAGING_PREFIX)/bin/xzcat
BISON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BISON_DESCRIPTION=a general-purpose parser generator that converts an annotated context-free grammar into an LALR(1) or GLR parser for that grammar.
BISON_SECTION=devel
BISON_PRIORITY=optional
BISON_DEPENDS=m4
BISON_SUGGESTS=
BISON_CONFLICTS=

BISON_IPK_VERSION=1

BISON_IPK=$(BUILD_DIR)/bison_$(BISON_VERSION)-$(BISON_IPK_VERSION)_$(TARGET_ARCH).ipk
BISON_IPK_DIR=$(BUILD_DIR)/bison-$(BISON_VERSION)-ipk

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BISON_CPPFLAGS=
BISON_LDFLAGS=

#
# BISON_BUILD_DIR is the directory in which the build is done.
# BISON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BISON_IPK_DIR is the directory in which the ipk is built.
# BISON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BISON_BUILD_DIR=$(BUILD_DIR)/bison
BISON_SOURCE_DIR=$(SOURCE_DIR)/bison
BISON_IPK_DIR=$(BUILD_DIR)/bison-$(BISON_VERSION)-ipk
BISON_IPK=$(BUILD_DIR)/bison_$(BISON_VERSION)-$(BISON_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(HOSTCC), $(TARGET_CC))
BISON_CROSS_CONFIGURE_ENV=ac_cv_func_malloc_0_nonnull=yes ac_cv_func_strnlen_working=yes ac_cv_prog_gnu_m4_gnu=\"/opt/bin/m4\"
ifeq (uclibc,$(LIBC_STYLE))
BISON_CROSS_CONFIGURE_SIGNBIT=gl_cv_func_signbit_gcc=no gl_cv_func_signbit=no
else
BISON_CROSS_CONFIGURE_SIGNBIT=gl_cv_func_signbit_gcc=no gl_cv_func_signbit=yes
endif
endif

.PHONY: bison-source bison-unpack bison bison-stage bison-ipk bison-clean bison-dirclean bison-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BISON_SOURCE):
	$(WGET) -P $(@D) $(BISON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bison-source: $(DL_DIR)/$(BISON_SOURCE)

$(BISON_BUILD_DIR)/.configured: $(DL_DIR)/$(BISON_SOURCE) $(BISON_PATCHES) make/bison.mk
	$(MAKE) xz-utils-host-stage
	rm -rf $(BUILD_DIR)/$(BISON_DIR) $(@D)
	$(BISON_UNZIP) $(DL_DIR)/$(BISON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BISON_DIR) $(@D)
	(cd $(@D); \
	    if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BISON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BISON_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		$(BISON_CROSS_CONFIGURE_ENV) \
		$(BISON_CROSS_CONFIGURE_SIGNBIT) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		; \
	    else \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BISON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BISON_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		$(BISON_CROSS_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		; \
	    fi; \
	);
	touch $@

bison-unpack: $(BISON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BISON_BUILD_DIR)/.built: $(BISON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bison: $(BISON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BISON_BUILD_DIR)/.staged: $(BISON_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bison-stage: $(BISON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bison
#
$(BISON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bison" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BISON_PRIORITY)" >>$@
	@echo "Section: $(BISON_SECTION)" >>$@
	@echo "Version: $(BISON_VERSION)-$(BISON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BISON_MAINTAINER)" >>$@
	@echo "Source: $(BISON_SITE)/$(BISON_SOURCE)" >>$@
	@echo "Description: $(BISON_DESCRIPTION)" >>$@
	@echo "Depends: $(BISON_DEPENDS)" >>$@
	@echo "Suggests: $(BISON_SUGGESTS)" >>$@
	@echo "Conflicts: $(BISON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BISON_IPK_DIR)/opt/sbin or $(BISON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BISON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BISON_IPK_DIR)/opt/etc/ushare/...
# Documentation files should be installed in $(BISON_IPK_DIR)/opt/doc/ushare/...
# Daemon startup scripts should be installed in $(BISON_IPK_DIR)/opt/etc/init.d/S??ushare
#
# You may need to patch your application to make it use these locations.
#
	install -d $(BISON_IPK_DIR)/opt/bin/


$(BISON_IPK): $(BISON_BUILD_DIR)/.built
	rm -rf $(BISON_IPK_DIR) $(BUILD_DIR)/bison_*_$(TARGET_ARCH).ipk
	install -d $(BISON_IPK_DIR)/opt/bin $(BISON_IPK_DIR)/opt/share/bison
	$(MAKE) -C $(BISON_BUILD_DIR) DESTDIR=$(BISON_IPK_DIR) install-strip
# for now ignore the locale files
#	$(STRIP_COMMAND) $(BISON_DIR)/src/bison -o $(BISON_IPK_DIR)/opt/bin/bison
	cp $(BISON_BUILD_DIR)/src/yacc $(BISON_IPK_DIR)/opt/bin/yacc
	cp $(BISON_BUILD_DIR)/data/README   $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_BUILD_DIR)/data/c.m4     $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_BUILD_DIR)/data/glr.c    $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_BUILD_DIR)/data/lalr1.cc $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_BUILD_DIR)/data/yacc.c   $(BISON_IPK_DIR)/opt/share/bison
	install -d $(BISON_IPK_DIR)/opt/share/bison/m4
	cp -a $(BISON_BUILD_DIR)/m4 $(BISON_IPK_DIR)/opt/share/bison/m4
	$(MAKE) $(BISON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BISON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BISON_IPK_DIR)

#
#
# This is called from the top level makefile to create the IPK file.
#
bison-ipk: $(BISON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bison-clean:
	rm -f $(bison_BUILD_DIR)/.built
	-$(MAKE) -C $(BISON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bison-dirclean:
	rm -rf $(BUILD_DIR)/$(BISON_DIR) $(BISON_BUILD_DIR) $(BISON_IPK_DIR) $(BISON_IPK)

#
# Some sanity check for the package.
#
bison-check: $(BISON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
