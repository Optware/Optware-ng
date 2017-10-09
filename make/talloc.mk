###########################################################
#
# talloc
#
###########################################################
#
# TALLOC_VERSION, TALLOC_SITE and TALLOC_SOURCE define
# the upstream location of the source code for the package.
# TALLOC_DIR is the directory which is created when the source
# archive is unpacked.
# TALLOC_UNZIP is the command used to unzip the source.
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
TALLOC_URL=https://www.samba.org/ftp/talloc/talloc-$(TALLOC_VERSION).tar.gz
TALLOC_VERSION=2.1.4
TALLOC_SOURCE=talloc-$(TALLOC_VERSION).tar.gz
TALLOC_DIR=talloc-$(TALLOC_VERSION)
TALLOC_UNZIP=zcat
TALLOC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TALLOC_DESCRIPTION=Talloc provides a hierarchical, reference counted memory pool system with destructors. It is the core memory allocator used in Samba.
TALLOC_SECTION=library
TALLOC_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TALLOC_DEPENDS=attr, libiconv
else
TALLOC_DEPENDS=attr
endif
TALLOC_SUGGESTS=
TALLOC_CONFLICTS=

#
# TALLOC_IPK_VERSION should be incremented when the ipk changes.
#
TALLOC_IPK_VERSION=4

#
# TALLOC_CONFFILES should be a list of user-editable files
#TALLOC_CONFFILES=$(TARGET_PREFIX)/etc/talloc.conf $(TARGET_PREFIX)/etc/init.d/SXXtalloc

#
# TALLOC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TALLOC_PATCHES=$(TALLOC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TALLOC_CPPFLAGS=
TALLOC_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TALLOC_LDFLAGS += -liconv
endif

#
# TALLOC_BUILD_DIR is the directory in which the build is done.
# TALLOC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TALLOC_IPK_DIR is the directory in which the ipk is built.
# TALLOC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TALLOC_BUILD_DIR=$(BUILD_DIR)/talloc
TALLOC_SOURCE_DIR=$(SOURCE_DIR)/talloc
TALLOC_IPK_DIR=$(BUILD_DIR)/talloc-$(TALLOC_VERSION)-ipk
TALLOC_IPK=$(BUILD_DIR)/talloc_$(TALLOC_VERSION)-$(TALLOC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: talloc-source talloc-unpack talloc talloc-stage talloc-ipk talloc-clean talloc-dirclean talloc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(TALLOC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(TALLOC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(TALLOC_SOURCE).sha512
#
$(DL_DIR)/$(TALLOC_SOURCE):
	$(WGET) -O $@ $(TALLOC_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
talloc-source: $(DL_DIR)/$(TALLOC_SOURCE) $(TALLOC_PATCHES)

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
$(TALLOC_BUILD_DIR)/.configured: $(DL_DIR)/$(TALLOC_SOURCE) $(TALLOC_PATCHES) make/talloc.mk
	$(MAKE) attr-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(TALLOC_DIR) $(@D)
	$(TALLOC_UNZIP) $(DL_DIR)/$(TALLOC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TALLOC_PATCHES)" ; \
		then cat $(TALLOC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TALLOC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TALLOC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TALLOC_DIR) $(@D) ; \
	fi
	(	echo "Checking uname sysname type: \"`uname -s`\""; \
		echo "Checking uname machine type: \"`uname -m`\""; \
		echo "Checking uname release type: \"`uname -r`\""; \
		echo "Checking uname version type: \"`uname -v`\""; \
		echo "Checking simple C program: OK"; \
		echo "rpath library support: OK"; \
		echo "-Wl,--version-script support: OK"; \
		echo "Checking getconf LFS_CFLAGS: \"-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64\""; \
		echo "Checking getconf large file support flags work: OK"; \
		echo "Checking for large file support without additional flags: OK"; \
		echo "Checking correct behavior of strtoll: OK"; \
		echo "Checking for working strptime: OK"; \
		echo "Checking for C99 vsnprintf: OK"; \
		echo "Checking for HAVE_SHARED_MMAP: OK"; \
		echo "Checking for HAVE_MREMAP: OK"; \
		echo "Checking for HAVE_INCOHERENT_MMAP: NO"; \
		echo "Checking for HAVE_SECURE_MKSTEMP: OK"; \
		echo "Checking for HAVE_IFACE_GETIFADDRS: OK"; \
		echo "Checking for HAVE_IFACE_IFCONF: OK"; \
	) > $(@D)/answers.txt
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(TALLOC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TALLOC_LDFLAGS)" \
		./buildtools/bin/waf \
		configure \
		--cross-compile \
		--cross-answers=answers.txt \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--libdir='$${PREFIX}/lib/talloc' \
		--includedir='$${PREFIX}/include/libtalloc' \
		--disable-python \
	)
	sed -i -e "/^CPPPATH =/s|=.*|= ['$(STAGING_INCLUDE_DIR)']|" \
	       -e "/^LIBPATH =/s|=.*|= ['$(STAGING_LIB_DIR)']|" $(@D)/bin/c4che/default.cache.py
	touch $@

talloc-unpack: $(TALLOC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TALLOC_BUILD_DIR)/.built: $(TALLOC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
talloc: $(TALLOC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TALLOC_BUILD_DIR)/.staged: $(TALLOC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	mkdir -p $(STAGING_LIB_DIR)/pkgconfig
	sed -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/talloc/pkgconfig/talloc.pc > $(STAGING_LIB_DIR)/pkgconfig/talloc.pc
	touch $@

talloc-stage: $(TALLOC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/talloc
#
$(TALLOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: talloc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TALLOC_PRIORITY)" >>$@
	@echo "Section: $(TALLOC_SECTION)" >>$@
	@echo "Version: $(TALLOC_VERSION)-$(TALLOC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TALLOC_MAINTAINER)" >>$@
	@echo "Source: $(TALLOC_URL)" >>$@
	@echo "Description: $(TALLOC_DESCRIPTION)" >>$@
	@echo "Depends: $(TALLOC_DEPENDS)" >>$@
	@echo "Suggests: $(TALLOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(TALLOC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/talloc/...
# Documentation files should be installed in $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/doc/talloc/...
# Daemon startup scripts should be installed in $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??talloc
#
# You may need to patch your application to make it use these locations.
#
$(TALLOC_IPK): $(TALLOC_BUILD_DIR)/.built
	rm -rf $(TALLOC_IPK_DIR) $(BUILD_DIR)/talloc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TALLOC_BUILD_DIR) DESTDIR=$(TALLOC_IPK_DIR) install
	$(STRIP_COMMAND) $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/lib/talloc/*.so
	mv -f $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/lib/talloc/pkgconfig $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/lib
#	$(INSTALL) -d $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(TALLOC_SOURCE_DIR)/talloc.conf $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/talloc.conf
#	$(INSTALL) -d $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(TALLOC_SOURCE_DIR)/rc.talloc $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXtalloc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TALLOC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXtalloc
	$(MAKE) $(TALLOC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(TALLOC_SOURCE_DIR)/postinst $(TALLOC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TALLOC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(TALLOC_SOURCE_DIR)/prerm $(TALLOC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TALLOC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(TALLOC_IPK_DIR)/CONTROL/postinst $(TALLOC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(TALLOC_CONFFILES) | sed -e 's/ /\n/g' > $(TALLOC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TALLOC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TALLOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
talloc-ipk: $(TALLOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
talloc-clean:
	rm -f $(TALLOC_BUILD_DIR)/.built
	-$(MAKE) -C $(TALLOC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
talloc-dirclean:
	rm -rf $(BUILD_DIR)/$(TALLOC_DIR) $(TALLOC_BUILD_DIR) $(TALLOC_IPK_DIR) $(TALLOC_IPK)
#
#
# Some sanity check for the package.
#
talloc-check: $(TALLOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
