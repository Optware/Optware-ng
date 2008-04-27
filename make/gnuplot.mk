###########################################################
#
# gnuplot
#
###########################################################
#
# GNUPLOT_VERSION, GNUPLOT_SITE and GNUPLOT_SOURCE define
# the upstream location of the source code for the package.
# GNUPLOT_DIR is the directory which is created when the source
# archive is unpacked.
# GNUPLOT_UNZIP is the command used to unzip the source.
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
GNUPLOT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gnuplot
GNUPLOT_VERSION=4.2.3
GNUPLOT_SOURCE=gnuplot-$(GNUPLOT_VERSION).tar.gz
GNUPLOT_DIR=gnuplot-$(GNUPLOT_VERSION)
GNUPLOT_UNZIP=zcat
GNUPLOT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNUPLOT_DESCRIPTION=Command-line driven interactive data and function plotting utility
GNUPLOT_SECTION=graphics
GNUPLOT_PRIORITY=optional
GNUPLOT_DEPENDS=readline, libgd, ncurses, expat, libstdc++
GNUPLOT_SUGGESTS=
GNUPLOT_CONFLICTS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GNUPLOT_DEPENDS+=, libiconv
endif
#
# GNUPLOT_IPK_VERSION should be incremented when the ipk changes.
#
GNUPLOT_IPK_VERSION=1

#
# GNUPLOT_CONFFILES should be a list of user-editable files
#GNUPLOT_CONFFILES=/opt/etc/gnuplot.conf /opt/etc/init.d/SXXgnuplot

#
# GNUPLOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GNUPLOT_PATCHES=$(GNUPLOT_SOURCE_DIR)/Makefile.in.patch \
		$(GNUPLOT_SOURCE_DIR)/docs-Makefile.in.patch \

ifneq (, $(filter openwrt-brcm24 openwrt-ixp4xx, $(OPTWARE_TARGET)))
GNUPLOT_PATCHES += $(GNUPLOT_SOURCE_DIR)/no-specfun.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNUPLOT_CPPFLAGS=
GNUPLOT_LDFLAGS=

#
# GNUPLOT_BUILD_DIR is the directory in which the build is done.
# GNUPLOT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNUPLOT_IPK_DIR is the directory in which the ipk is built.
# GNUPLOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNUPLOT_BUILD_DIR=$(BUILD_DIR)/gnuplot
GNUPLOT_SOURCE_DIR=$(SOURCE_DIR)/gnuplot
GNUPLOT_IPK_DIR=$(BUILD_DIR)/gnuplot-$(GNUPLOT_VERSION)-ipk
GNUPLOT_IPK=$(BUILD_DIR)/gnuplot_$(GNUPLOT_VERSION)-$(GNUPLOT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnuplot-source gnuplot-unpack gnuplot gnuplot-stage gnuplot-ipk gnuplot-clean gnuplot-dirclean gnuplot-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNUPLOT_SOURCE):
	$(WGET) -P $(@D) $(GNUPLOT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnuplot-source: $(DL_DIR)/$(GNUPLOT_SOURCE) $(GNUPLOT_PATCHES)

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
$(GNUPLOT_BUILD_DIR)/.configured: $(DL_DIR)/$(GNUPLOT_SOURCE) $(GNUPLOT_PATCHES) make/gnuplot.mk
	$(MAKE) readline-stage libpng-stage libgd-stage ncurses-stage expat-stage
	rm -rf $(BUILD_DIR)/$(GNUPLOT_DIR) $(GNUPLOT_BUILD_DIR)
	$(GNUPLOT_UNZIP) $(DL_DIR)/$(GNUPLOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNUPLOT_PATCHES)" ; \
		then cat $(GNUPLOT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNUPLOT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GNUPLOT_DIR)" != "$(GNUPLOT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GNUPLOT_DIR) $(GNUPLOT_BUILD_DIR) ; \
	fi
	(cd $(GNUPLOT_BUILD_DIR); \
                autoconf configure.in > configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNUPLOT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNUPLOT_LDFLAGS)" \
		PATH="$(STAGING_DIR)/opt/bin:${PATH}" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		HOSTCC=$(HOSTCC) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-x   \
		--with-readline=$(STAGING_DIR)/opt \
		--with-png=$(STAGING_DIR)/opt \
		--with-gd=$(STAGING_DIR)/opt \
		--without-lisp-files \
		--without-tutorial \
		--disable-wxwidgets \
	)
#	$(PATCH_LIBTOOL) $(GNUPLOT_BUILD_DIR)/libtool
	touch $@

gnuplot-unpack: $(GNUPLOT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNUPLOT_BUILD_DIR)/.built: $(GNUPLOT_BUILD_DIR)/.configured
	rm -f $@
ifneq (, $(filter cs05q3armel ds101 fsg3v4 gumstix1151, $(OPTWARE_TARGET)))
# no optimization
	$(MAKE) -C $(@D)/src HOSTCC=$(HOSTCC) matrix.o \
		CFLAGS="" CPPFLAGS="-I$(STAGING_INCLUDE_DIR)"
endif
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(GNUPLOT_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $@

#
# This is the build convenience target.
#
gnuplot: $(GNUPLOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNUPLOT_BUILD_DIR)/.staged: $(GNUPLOT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GNUPLOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

gnuplot-stage: $(GNUPLOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnuplot
#
$(GNUPLOT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnuplot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUPLOT_PRIORITY)" >>$@
	@echo "Section: $(GNUPLOT_SECTION)" >>$@
	@echo "Version: $(GNUPLOT_VERSION)-$(GNUPLOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUPLOT_MAINTAINER)" >>$@
	@echo "Source: $(GNUPLOT_SITE)/$(GNUPLOT_SOURCE)" >>$@
	@echo "Description: $(GNUPLOT_DESCRIPTION)" >>$@
	@echo "Depends: $(GNUPLOT_DEPENDS)" >>$@
	@echo "Suggests: $(GNUPLOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNUPLOT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNUPLOT_IPK_DIR)/opt/sbin or $(GNUPLOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNUPLOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNUPLOT_IPK_DIR)/opt/etc/gnuplot/...
# Documentation files should be installed in $(GNUPLOT_IPK_DIR)/opt/doc/gnuplot/...
# Daemon startup scripts should be installed in $(GNUPLOT_IPK_DIR)/opt/etc/init.d/S??gnuplot
#
# You may need to patch your application to make it use these locations.
#
$(GNUPLOT_IPK): $(GNUPLOT_BUILD_DIR)/.built
	rm -rf $(GNUPLOT_IPK_DIR) $(BUILD_DIR)/gnuplot_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNUPLOT_BUILD_DIR) DESTDIR=$(GNUPLOT_IPK_DIR) install-strip
#	install -d $(GNUPLOT_IPK_DIR)/opt/etc/
#	install -m 644 $(GNUPLOT_SOURCE_DIR)/gnuplot.conf $(GNUPLOT_IPK_DIR)/opt/etc/gnuplot.conf
#	install -d $(GNUPLOT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNUPLOT_SOURCE_DIR)/rc.gnuplot $(GNUPLOT_IPK_DIR)/opt/etc/init.d/SXXgnuplot
	$(MAKE) $(GNUPLOT_IPK_DIR)/CONTROL/control
#install -m 755 $(GNUPLOT_SOURCE_DIR)/postinst $(GNUPLOT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNUPLOT_SOURCE_DIR)/prerm $(GNUPLOT_IPK_DIR)/CONTROL/prerm
#	echo $(GNUPLOT_CONFFILES) | sed -e 's/ /\n/g' > $(GNUPLOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUPLOT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnuplot-ipk: $(GNUPLOT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnuplot-clean:
	rm -f $(GNUPLOT_BUILD_DIR)/.built
	-$(MAKE) -C $(GNUPLOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnuplot-dirclean:
	rm -rf $(BUILD_DIR)/$(GNUPLOT_DIR) $(GNUPLOT_BUILD_DIR) $(GNUPLOT_IPK_DIR) $(GNUPLOT_IPK)

#
#
# Some sanity check for the package.
#
gnuplot-check: $(GNUPLOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNUPLOT_IPK)
