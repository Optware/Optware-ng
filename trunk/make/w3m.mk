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
W3M_VERSION=0.5.2
W3M_SOURCE=w3m-$(W3M_VERSION).tar.gz
W3M_DIR=w3m-$(W3M_VERSION)
W3M_UNZIP=zcat
W3M_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
W3M_DESCRIPTION=Pager/text-based WWW browser with tables/frames support
W3M_SECTION=web
W3M_PRIORITY=optional
W3M_DEPENDS=libgc, openssl
W3M_CONFLICTS=

#
# W3M_IPK_VERSION should be incremented when the ipk changes.
#
W3M_IPK_VERSION=1

#
# W3M_CONFFILES should be a list of user-editable files
#W3M_CONFFILES=/opt/etc/w3m.conf /opt/etc/init.d/SXXw3m

#
# W3M_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
W3M_PATCHES=$(W3M_SOURCE_DIR)/Makefile.in.patch
ifneq ($(HOSTCC), $(TARGET_CC))
W3M_PATCHES+=$(W3M_SOURCE_DIR)/configure.in.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
W3M_CPPFLAGS=-I$(STAGING_DIR)/opt/include/gc
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
	$(WGET) -P $(DL_DIR) $(W3M_SITE)/$(W3M_SOURCE)

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
$(W3M_BUILD_DIR)/.configured: $(DL_DIR)/$(W3M_SOURCE) $(W3M_PATCHES)
	$(MAKE) libgc-stage openssl-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(W3M_DIR) $(W3M_BUILD_DIR)
	$(W3M_UNZIP) $(DL_DIR)/$(W3M_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(W3M_PATCHES) | patch -b -d $(BUILD_DIR)/$(W3M_DIR) -p1
	mv $(BUILD_DIR)/$(W3M_DIR) $(W3M_BUILD_DIR)
ifeq ($(HOSTCC), $(TARGET_CC))
	(cd $(W3M_BUILD_DIR); \
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
		--prefix=/opt \
		--with-ssl \
		--disable-image \
	)
else
	rm -rf $(W3M_LIBGC_HOSTBUILD_DIR)
	mkdir $(W3M_LIBGC_HOSTBUILD_DIR)
	$(LIBGC_UNZIP) $(DL_DIR)/$(LIBGC_SOURCE) | tar -C $(W3M_LIBGC_HOSTBUILD_DIR) -xvf -
	@echo "=============================== host libgc configure & build ============"
	cd $(W3M_LIBGC_HOSTBUILD_DIR)/$(LIBGC_DIR); \
		./configure --prefix=/opt --disable-static; \
		make DESTDIR=$(W3M_LIBGC_HOSTBUILD_DIR) install
	mkdir $(W3M_BUILD_DIR)/hostbuild
	@echo "=============================== host w3m configure ======================="
	cd $(W3M_BUILD_DIR)/hostbuild; \
		ac_cv_sizeof_long_long=8 \
		../configure \
		--disable-image \
		--without-ssl \
		--with-gc=$(W3M_LIBGC_HOSTBUILD_DIR)/opt
	@echo "=============================== host w3m mktable =========================="
	$(MAKE) -C $(W3M_BUILD_DIR)/hostbuild mktable CROSS_COMPILATION=no
	cp $(W3M_BUILD_DIR)/hostbuild/mktable $(W3M_BUILD_DIR)
	@echo "=============================== cross w3m configure ======================"
	(cd $(W3M_BUILD_DIR); \
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
		--prefix=/opt \
		--with-ssl=$(STAGING_PREFIX) \
		--with-gc=$(STAGING_PREFIX) \
		--disable-image \
	)
	touch $(W3M_BUILD_DIR)/mktable
endif
	touch $(W3M_BUILD_DIR)/.configured

w3m-unpack: $(W3M_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(W3M_BUILD_DIR)/.built: $(W3M_BUILD_DIR)/.configured
	rm -f $(W3M_BUILD_DIR)/.built
ifeq ($(HOSTCC), $(TARGET_CC))
	LD_LIBRARY_PATH=$(STAGING_LIB_DIR) \
	    $(MAKE) -C $(W3M_BUILD_DIR) CROSS_COMPILATION=no
else
	@echo "=============================== cross w3m build ============================"
	LD_LIBRARY_PATH=$(W3M_LIBGC_HOSTBUILD_DIR)/opt/lib \
	$(MAKE) -C $(W3M_BUILD_DIR) CROSS_COMPILATION=yes
endif
	touch $(W3M_BUILD_DIR)/.built

#
# This is the build convenience target.
#
w3m: $(W3M_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(W3M_BUILD_DIR)/.staged: $(W3M_BUILD_DIR)/.built
	rm -f $(W3M_BUILD_DIR)/.staged
	$(MAKE) -C $(W3M_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(W3M_BUILD_DIR)/.staged

w3m-stage: $(W3M_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/w3m
#
$(W3M_IPK_DIR)/CONTROL/control:
	@install -d $(W3M_IPK_DIR)/CONTROL
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
# Binaries should be installed into $(W3M_IPK_DIR)/opt/sbin or $(W3M_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(W3M_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(W3M_IPK_DIR)/opt/etc/w3m/...
# Documentation files should be installed in $(W3M_IPK_DIR)/opt/doc/w3m/...
# Daemon startup scripts should be installed in $(W3M_IPK_DIR)/opt/etc/init.d/S??w3m
#
# You may need to patch your application to make it use these locations.
#
$(W3M_IPK): $(W3M_BUILD_DIR)/.built
	rm -rf $(W3M_IPK_DIR) $(BUILD_DIR)/w3m_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(W3M_BUILD_DIR) DESTDIR=$(W3M_IPK_DIR) install
	$(STRIP_COMMAND) $(W3M_IPK_DIR)/opt/bin/w3m
	$(STRIP_COMMAND) $(W3M_IPK_DIR)/opt/libexec/w3m/inflate
	$(STRIP_COMMAND) $(W3M_IPK_DIR)/opt/libexec/w3m/cgi-bin/{w3mbookmark,w3mhelperpanel}
#	install -d $(W3M_IPK_DIR)/opt/etc/
#	install -m 644 $(W3M_SOURCE_DIR)/w3m.conf $(W3M_IPK_DIR)/opt/etc/w3m.conf
#	install -d $(W3M_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(W3M_SOURCE_DIR)/rc.w3m $(W3M_IPK_DIR)/opt/etc/init.d/SXXw3m
	$(MAKE) $(W3M_IPK_DIR)/CONTROL/control
#	install -m 755 $(W3M_SOURCE_DIR)/postinst $(W3M_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(W3M_SOURCE_DIR)/prerm $(W3M_IPK_DIR)/CONTROL/prerm
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(W3M_IPK)
