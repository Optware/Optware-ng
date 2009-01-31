###########################################################
#
# mono
#
###########################################################
#
# MONO_VERSION, MONO_SITE and MONO_SOURCE define
# the upstream location of the source code for the package.
# MONO_DIR is the directory which is created when the source
# archive is unpacked.
# MONO_UNZIP is the command used to unzip the source.
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
MONO_SITE=http://ftp.novell.com/pub/mono/sources/mono
MONO_VERSION=2.2
MONO_SOURCE=mono-$(MONO_VERSION).tar.bz2
MONO_DIR=mono-$(MONO_VERSION)
MONO_UNZIP=bzcat
MONO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MONO_DESCRIPTION=An open source implementation of the Common Language Infrastructure.
MONO_SECTION=lang
MONO_PRIORITY=optional
MONO_DEPENDS=glib
MONO_SUGGESTS=
MONO_CONFLICTS=

#
# MONO_IPK_VERSION should be incremented when the ipk changes.
#
MONO_IPK_VERSION=1

#
# MONO_CONFFILES should be a list of user-editable files
#MONO_CONFFILES=/opt/etc/mono.conf /opt/etc/init.d/SXXmono

#
# MONO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MONO_PATCHES=$(MONO_SOURCE_DIR)/ULLONG_MAX.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MONO_CPPFLAGS=$(strip \
$(if $(filter nslu2, $(OPTWARE_TARGET)), -DARM_FPU_FPA, \
$(if $(filter slugosbe slugosle, $(OPTWARE_TARGET)), -DARM_FPU_FPA, \
$(if $(filter arm armeb, $(TARGET_ARCH)), -DARM_FPU_VFP, ) \
)))
MONO_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
MONO_CONFIG_ENVS=mono_cv_uscore=no mono_cv_sizeof_sunpath=1024
MONO_CONFIG_ARGS=--disable-mcs-build --with-tls=pthread --with-sigaltstack=no
#		--with-crosspkgdir=$(STAGING_LIB_DIR)/pkgconfig
endif

#
# MONO_BUILD_DIR is the directory in which the build is done.
# MONO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MONO_IPK_DIR is the directory in which the ipk is built.
# MONO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MONO_BUILD_DIR=$(BUILD_DIR)/mono
MONO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/mono
MONO_SOURCE_DIR=$(SOURCE_DIR)/mono
MONO_IPK_DIR=$(BUILD_DIR)/mono-$(MONO_VERSION)-ipk
MONO_IPK=$(BUILD_DIR)/mono_$(MONO_VERSION)-$(MONO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mono-source mono-unpack mono mono-stage mono-ipk mono-clean mono-dirclean mono-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MONO_SOURCE):
	$(WGET) -P $(@D) $(MONO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mono-source: $(DL_DIR)/$(MONO_SOURCE) $(MONO_PATCHES)

$(MONO_HOST_BUILD_DIR)/.built: $(DL_DIR)/$(MONO_SOURCE) # make/mono.mk
#	$(MAKE) glib-stage
	rm -rf $(HOST_BUILD_DIR)/$(MONO_DIR) $(@D)
	$(MONO_UNZIP) $(DL_DIR)/$(MONO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(MONO_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(MONO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(@D)
	touch $@

mono-hostbuild: $(MONO_HOST_BUILD_DIR)/.built

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(MONO_BUILD_DIR)/.configured: $(DL_DIR)/$(MONO_SOURCE) $(MONO_PATCHES) make/mono.mk
else
$(MONO_BUILD_DIR)/.configured: $(MONO_HOST_BUILD_DIR)/.built $(MONO_PATCHES) # make/mono.mk
endif
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(MONO_DIR) $(@D)
	$(MONO_UNZIP) $(DL_DIR)/$(MONO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MONO_PATCHES)" ; \
		then cat $(MONO_PATCHES) | \
		patch -l -d $(BUILD_DIR)/$(MONO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MONO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MONO_DIR) $(@D) ; \
	fi
ifneq (, $(filter nslu2, $(OPTWARE_TARGET)))
	sed -i.orig -e 's/st_mtim.tv_sec/st_mtime/' $(@D)/mono/profiler/mono-profiler-logging.c
endif
	sed -i -e '/SUBDIRS =/s/ docs$$//' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MONO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MONO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(MONO_CONFIG_ENVS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MONO_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
	)
ifneq (, $(filter ds101g, $(OPTWARE_TARGET)))
	sed -i -e '/HAVE_SCHED_SETAFFINITY/s|.*|/* #undef HAVE_REMAP_FILE_PAGES */|' $(@D)/config.h
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mono-unpack: $(MONO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MONO_BUILD_DIR)/.built: $(MONO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mono: $(MONO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MONO_BUILD_DIR)/.staged: $(MONO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mono-stage: $(MONO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mono
#
$(MONO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mono" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MONO_PRIORITY)" >>$@
	@echo "Section: $(MONO_SECTION)" >>$@
	@echo "Version: $(MONO_VERSION)-$(MONO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MONO_MAINTAINER)" >>$@
	@echo "Source: $(MONO_SITE)/$(MONO_SOURCE)" >>$@
	@echo "Description: $(MONO_DESCRIPTION)" >>$@
	@echo "Depends: $(MONO_DEPENDS)" >>$@
	@echo "Suggests: $(MONO_SUGGESTS)" >>$@
	@echo "Conflicts: $(MONO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MONO_IPK_DIR)/opt/sbin or $(MONO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MONO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MONO_IPK_DIR)/opt/etc/mono/...
# Documentation files should be installed in $(MONO_IPK_DIR)/opt/doc/mono/...
# Daemon startup scripts should be installed in $(MONO_IPK_DIR)/opt/etc/init.d/S??mono
#
# You may need to patch your application to make it use these locations.
#
$(MONO_IPK): $(MONO_BUILD_DIR)/.built
	rm -rf $(MONO_IPK_DIR) $(BUILD_DIR)/mono_*_$(TARGET_ARCH).ipk
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) -C $(MONO_HOST_BUILD_DIR) install DESTDIR=$(MONO_IPK_DIR) install-strip
endif
	$(MAKE) -C $(MONO_BUILD_DIR) DESTDIR=$(MONO_IPK_DIR) transform='' install-strip
ifneq ($(HOSTCC), $(TARGET_CC))
	rm -f $(MONO_IPK_DIR)/opt/bin/jay
endif
	cd $(MONO_IPK_DIR)/opt/lib/mono && \
	tar --remove-files -cvzf long-symlinks.tar.gz \
		`find . -type l -ls | awk '{ if (length($$13) > 100) { print $$11}}'`
	$(MAKE) $(MONO_IPK_DIR)/CONTROL/control
	install -m755 $(MONO_SOURCE_DIR)/postinst $(MONO_IPK_DIR)/CONTROL/postinst
	install -m755 $(MONO_SOURCE_DIR)/prerm $(MONO_IPK_DIR)/CONTROL/prerm
	echo $(MONO_CONFFILES) | sed -e 's/ /\n/g' > $(MONO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MONO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mono-ipk: $(MONO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mono-clean:
	rm -f $(MONO_BUILD_DIR)/.built
	-$(MAKE) -C $(MONO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mono-dirclean:
	rm -rf $(BUILD_DIR)/$(MONO_DIR) $(MONO_BUILD_DIR) $(MONO_IPK_DIR) $(MONO_IPK)
#
#
# Some sanity check for the package.
#
mono-check: $(MONO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
