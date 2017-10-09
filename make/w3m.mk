###########################################################
#
# w3m
#
###########################################################

# You must replace "w3m" and "W3M" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# W3M_VERSION, W3M_SITE and W3M_SOURCE define
# the upstream location of the source code for the package.
# W3M_DIR is the directory which is created when the source
# archive is unpacked.
# W3M_UNZIP is the command used to unzip the source.
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
W3M_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/w3m
W3M_VERSION=0.5.3
W3M_SOURCE=w3m-$(W3M_VERSION).tar.gz
W3M_DIR=w3m-$(W3M_VERSION)
W3M_UNZIP=zcat
W3M_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
W3M_DESCRIPTION=Pager/text-based WWW browser with tables/frames support
W3M_SECTION=web
W3M_PRIORITY=optional
W3M_DEPENDS=libgc, openssl, zlib
W3M_CONFLICTS=

#
# W3M_IPK_VERSION should be incremented when the ipk changes.
#
W3M_IPK_VERSION=5

#
# W3M_CONFFILES should be a list of user-editable files
#W3M_CONFFILES=$(TARGET_PREFIX)/etc/w3m.conf $(TARGET_PREFIX)/etc/init.d/SXXw3m

#
# W3M_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
W3M_PATCHES=\
$(W3M_SOURCE_DIR)/Makefile.in.patch \
$(W3M_SOURCE_DIR)/main.c.patch
ifneq ($(HOSTCC), $(TARGET_CC))
W3M_PATCHES+=$(W3M_SOURCE_DIR)/configure.in.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
W3M_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/gc
W3M_LDFLAGS=-ldl -lpthread

#
# W3M_BUILD_DIR is the directory in which the build is done.
# W3M_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# W3M_IPK_DIR is the directory in which the ipk is built.
# W3M_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
W3M_BUILD_DIR=$(BUILD_DIR)/w3m
W3M_LIBGC_HOSTBUILD_DIR=$(W3M_BUILD_DIR)/libgc-hostbuild
W3M_SOURCE_DIR=$(SOURCE_DIR)/w3m
W3M_IPK_DIR=$(BUILD_DIR)/w3m-$(W3M_VERSION)-ipk
W3M_IPK=$(BUILD_DIR)/w3m_$(W3M_VERSION)-$(W3M_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: w3m-source w3m-unpack w3m w3m-stage w3m-ipk w3m-clean w3m-dirclean w3m-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(W3M_SOURCE):
	$(WGET) -P $(@D) $(W3M_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
w3m-source: $(DL_DIR)/$(W3M_SOURCE) $(W3M_PATCHES)

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
$(W3M_BUILD_DIR)/.configured: $(DL_DIR)/$(W3M_SOURCE) $(W3M_PATCHES) make/w3m.mk
	$(MAKE) libgc-stage openssl-stage ncurses-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(W3M_DIR) $(@D)
	$(W3M_UNZIP) $(DL_DIR)/$(W3M_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(W3M_PATCHES) | $(PATCH) -b -d $(BUILD_DIR)/$(W3M_DIR) -p1
	mv $(BUILD_DIR)/$(W3M_DIR) $(@D)
	find $(@D) -type f -name '*.[ch]' -exec sed -i -e 's/file_handle/_&_/g' {} \;
#	GC_set_warn_proc in newer libgc returns void
#	use GC_get_warn_proc() to get the old warning procedure
	sed -i -e \
	's|orig_GC_warn_proc = GC_set_warn_proc(wrap_GC_warn_proc);|orig_GC_warn_proc = GC_get_warn_proc();\n    GC_set_warn_proc(wrap_GC_warn_proc);|' \
				$(@D)/main.c
	$(HOST_TOOL_AUTOMAKE1.10)
	cd $(@D); export PATH=$(HOST_STAGING_PREFIX)/bin:$$PATH; \
		libtoolize -c -f
ifeq ($(HOSTCC), $(TARGET_CC))
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(W3M_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(W3M_LDFLAGS)" \
		WCCFLAGS="-DUSE_UNICODE $(STAGING_CPPFLAGS) $(W3M_CPPFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		LD_LIBRARY_PATH=$(STAGING_LIB_DIR) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-ssl \
		--disable-image \
	)
else
	rm -rf $(W3M_LIBGC_HOSTBUILD_DIR)
	mkdir -p $(W3M_LIBGC_HOSTBUILD_DIR)/build/libatomic_ops
	$(LIBGC_UNZIP) $(DL_DIR)/$(LIBGC_SOURCE) | tar -C $(W3M_LIBGC_HOSTBUILD_DIR)/build -xvf - --strip-components=1
	$(LIBATOMIC_OPS_UNZIP) $(DL_DIR)/$(LIBATOMIC_OPS_SOURCE) | tar -C $(W3M_LIBGC_HOSTBUILD_DIR)/build/libatomic_ops -xvf - --strip-components=1
	@echo "=============================== host libgc configure & build ============"
	$(AUTORECONF1.10) -vif $(W3M_LIBGC_HOSTBUILD_DIR)/build
	cd $(W3M_LIBGC_HOSTBUILD_DIR)/build; \
		CPPFLAGS="-fPIC" \
		LDFLAGS="-pthread" \
		./configure --prefix=$(TARGET_PREFIX) --disable-shared && \
		make DESTDIR=$(W3M_LIBGC_HOSTBUILD_DIR) install
	mkdir $(@D)/hostbuild
	@echo "=============================== host w3m configure ======================="
	cd $(@D)/hostbuild; \
		ac_cv_sizeof_long_long=8 \
		CPPFLAGS="-I$(W3M_LIBGC_HOSTBUILD_DIR)$(TARGET_PREFIX)/include" \
		LDFLAGS="-L$(W3M_LIBGC_HOSTBUILD_DIR)$(TARGET_PREFIX)/lib -pthread" \
		../configure \
		--disable-image \
		--without-ssl \
		--with-gc=$(W3M_LIBGC_HOSTBUILD_DIR)$(TARGET_PREFIX)
	@echo "=============================== host w3m mktable =========================="
	$(MAKE) -C $(@D)/hostbuild mktable CROSS_COMPILATION=no
	cp $(@D)/hostbuild/mktable $(@D)
	@echo "=============================== cross w3m configure ======================"
	(cd $(@D); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(W3M_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(W3M_LDFLAGS)" \
		WCCFLAGS="-DUSE_UNICODE $(STAGING_CPPFLAGS) $(W3M_CPPFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-ssl=$(STAGING_PREFIX) \
		--with-gc=$(STAGING_PREFIX) \
		--disable-image \
	)
	touch $(@D)/mktable
endif
	touch $@

w3m-unpack: $(W3M_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(W3M_BUILD_DIR)/.built: $(W3M_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(HOSTCC), $(TARGET_CC))
	LD_LIBRARY_PATH=$(STAGING_LIB_DIR) \
	    $(MAKE) -C $(@D) CROSS_COMPILATION=no
else
	@echo "=============================== cross w3m build ============================"
	LD_LIBRARY_PATH=$(W3M_LIBGC_HOSTBUILD_DIR)$(TARGET_PREFIX)/lib \
	$(MAKE) -C $(@D) CROSS_COMPILATION=yes
endif
	touch $@

#
# This is the build convenience target.
#
w3m: $(W3M_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(W3M_BUILD_DIR)/.staged: $(W3M_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

w3m-stage: $(W3M_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/w3m
#
$(W3M_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: w3m" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(W3M_PRIORITY)" >>$@
	@echo "Section: $(W3M_SECTION)" >>$@
	@echo "Version: $(W3M_VERSION)-$(W3M_IPK_VERSION)" >>$@
	@echo "Maintainer: $(W3M_MAINTAINER)" >>$@
	@echo "Source: $(W3M_SITE)/$(W3M_SOURCE)" >>$@
	@echo "Description: $(W3M_DESCRIPTION)" >>$@
	@echo "Depends: $(W3M_DEPENDS)" >>$@
	@echo "Conflicts: $(W3M_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(W3M_IPK_DIR)$(TARGET_PREFIX)/sbin or $(W3M_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(W3M_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/w3m/...
# Documentation files should be installed in $(W3M_IPK_DIR)$(TARGET_PREFIX)/doc/w3m/...
# Daemon startup scripts should be installed in $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??w3m
#
# You may need to patch your application to make it use these locations.
#
$(W3M_IPK): $(W3M_BUILD_DIR)/.built
	rm -rf $(W3M_IPK_DIR) $(BUILD_DIR)/w3m_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(W3M_BUILD_DIR) DESTDIR=$(W3M_IPK_DIR) install
	$(STRIP_COMMAND) $(W3M_IPK_DIR)$(TARGET_PREFIX)/bin/w3m
	$(STRIP_COMMAND) $(W3M_IPK_DIR)$(TARGET_PREFIX)/libexec/w3m/inflate
	$(STRIP_COMMAND) $(W3M_IPK_DIR)$(TARGET_PREFIX)/libexec/w3m/cgi-bin/w3mbookmark $(W3M_IPK_DIR)$(TARGET_PREFIX)/libexec/w3m/cgi-bin/w3mhelperpanel
#	$(INSTALL) -d $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(W3M_SOURCE_DIR)/w3m.conf $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/w3m.conf
#	$(INSTALL) -d $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(W3M_SOURCE_DIR)/rc.w3m $(W3M_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXw3m
	$(MAKE) $(W3M_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(W3M_SOURCE_DIR)/postinst $(W3M_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(W3M_SOURCE_DIR)/prerm $(W3M_IPK_DIR)/CONTROL/prerm
#	echo $(W3M_CONFFILES) | sed -e 's/ /\n/g' > $(W3M_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(W3M_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
w3m-ipk: $(W3M_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
w3m-clean:
	-$(MAKE) -C $(W3M_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
w3m-dirclean:
	rm -rf $(BUILD_DIR)/$(W3M_DIR) $(W3M_BUILD_DIR) $(W3M_IPK_DIR) $(W3M_IPK)

#
# Some sanity check for the package.
#
w3m-check: $(W3M_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
