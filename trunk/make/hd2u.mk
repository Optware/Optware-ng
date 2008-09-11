###########################################################
#
# hd2u
#
###########################################################
#
# HD2U_VERSION, HD2U_SITE and HD2U_SOURCE define
# the upstream location of the source code for the package.
# HD2U_DIR is the directory which is created when the source
# archive is unpacked.
# HD2U_UNZIP is the command used to unzip the source.
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
HD2U_SITE=http://hany.sk/~hany/_data/hd2u
HD2U_VERSION=1.0.3
HD2U_SOURCE=hd2u-$(HD2U_VERSION).tgz
HD2U_DIR=hd2u-$(HD2U_VERSION)
HD2U_UNZIP=zcat
HD2U_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HD2U_DESCRIPTION=Hany''s Dos2Unix
HD2U_SECTION=utils
HD2U_PRIORITY=optional
HD2U_DEPENDS=popt
HD2U_SUGGESTS=
HD2U_CONFLICTS=

#
# HD2U_IPK_VERSION should be incremented when the ipk changes.
#
HD2U_IPK_VERSION=1

#
# HD2U_CONFFILES should be a list of user-editable files
#HD2U_CONFFILES=/opt/etc/hd2u.conf /opt/etc/init.d/SXXhd2u

#
# HD2U_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HD2U_PATCHES=$(HD2U_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HD2U_CPPFLAGS=
HD2U_LDFLAGS=

#
# HD2U_BUILD_DIR is the directory in which the build is done.
# HD2U_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HD2U_IPK_DIR is the directory in which the ipk is built.
# HD2U_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HD2U_BUILD_DIR=$(BUILD_DIR)/hd2u
HD2U_SOURCE_DIR=$(SOURCE_DIR)/hd2u
HD2U_IPK_DIR=$(BUILD_DIR)/hd2u-$(HD2U_VERSION)-ipk
HD2U_IPK=$(BUILD_DIR)/hd2u_$(HD2U_VERSION)-$(HD2U_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hd2u-source hd2u-unpack hd2u hd2u-stage hd2u-ipk hd2u-clean hd2u-dirclean hd2u-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HD2U_SOURCE):
	$(WGET) -P $(@D) $(HD2U_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hd2u-source: $(DL_DIR)/$(HD2U_SOURCE) $(HD2U_PATCHES)

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
$(HD2U_BUILD_DIR)/.configured: $(DL_DIR)/$(HD2U_SOURCE) $(HD2U_PATCHES) make/hd2u.mk
	$(MAKE) popt-stage
	rm -rf $(BUILD_DIR)/$(HD2U_DIR) $(@D)
	$(HD2U_UNZIP) $(DL_DIR)/$(HD2U_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HD2U_PATCHES)" ; \
		then cat $(HD2U_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HD2U_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HD2U_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HD2U_DIR) $(@D) ; \
	fi
	sed -i -e '/^$$(TARGET):/s/ config.h$$//' \
	       -e '/^CFLAGS *=/s/$$/ $$(CPPFLAGS)/' \
	       -e '/^LIBS *=/s/$$/ $$(LDFLAGS)/' \
	       -e '/$$(INSTALL)/s/ -s//' \
		$(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HD2U_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HD2U_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

hd2u-unpack: $(HD2U_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HD2U_BUILD_DIR)/.built: $(HD2U_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HD2U_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HD2U_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
hd2u: $(HD2U_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(HD2U_BUILD_DIR)/.staged: $(HD2U_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#hd2u-stage: $(HD2U_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hd2u
#
$(HD2U_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hd2u" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HD2U_PRIORITY)" >>$@
	@echo "Section: $(HD2U_SECTION)" >>$@
	@echo "Version: $(HD2U_VERSION)-$(HD2U_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HD2U_MAINTAINER)" >>$@
	@echo "Source: $(HD2U_SITE)/$(HD2U_SOURCE)" >>$@
	@echo "Description: $(HD2U_DESCRIPTION)" >>$@
	@echo "Depends: $(HD2U_DEPENDS)" >>$@
	@echo "Suggests: $(HD2U_SUGGESTS)" >>$@
	@echo "Conflicts: $(HD2U_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HD2U_IPK_DIR)/opt/sbin or $(HD2U_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HD2U_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HD2U_IPK_DIR)/opt/etc/hd2u/...
# Documentation files should be installed in $(HD2U_IPK_DIR)/opt/doc/hd2u/...
# Daemon startup scripts should be installed in $(HD2U_IPK_DIR)/opt/etc/init.d/S??hd2u
#
# You may need to patch your application to make it use these locations.
#
$(HD2U_IPK): $(HD2U_BUILD_DIR)/.built
	rm -rf $(HD2U_IPK_DIR) $(BUILD_DIR)/hd2u_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HD2U_BUILD_DIR) install \
		DESTDIR=$(HD2U_IPK_DIR) \
		prefix=$(HD2U_IPK_DIR)/opt \
		;
	$(STRIP_COMMAND) $(HD2U_IPK_DIR)/opt/bin/*
	mv $(HD2U_IPK_DIR)/opt/bin/dos2unix $(HD2U_IPK_DIR)/opt/bin/hd2u-dos2unix
	install -d $(HD2U_IPK_DIR)/opt/share/doc/hd2u
	install $(HD2U_BUILD_DIR)/AUTHORS \
		$(HD2U_BUILD_DIR)/ChangeLog \
		$(HD2U_BUILD_DIR)/COPYING \
		$(HD2U_BUILD_DIR)/CREDITS \
		$(HD2U_BUILD_DIR)/INSTALL \
		$(HD2U_BUILD_DIR)/NEWS \
		$(HD2U_BUILD_DIR)/README \
		$(HD2U_BUILD_DIR)/TODO \
		$(HD2U_IPK_DIR)/opt/share/doc/hd2u/
	$(MAKE) $(HD2U_IPK_DIR)/CONTROL/control
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/dos2unix dos2unix /opt/bin/hd2u-dos2unix 60"; \
	) > $(HD2U_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove dos2unix /opt/bin/hd2u-dos2unix"; \
	) > $(HD2U_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HD2U_IPK_DIR)/CONTROL/postinst $(HD2U_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HD2U_CONFFILES) | sed -e 's/ /\n/g' > $(HD2U_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HD2U_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hd2u-ipk: $(HD2U_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hd2u-clean:
	rm -f $(HD2U_BUILD_DIR)/.built
	-$(MAKE) -C $(HD2U_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hd2u-dirclean:
	rm -rf $(BUILD_DIR)/$(HD2U_DIR) $(HD2U_BUILD_DIR) $(HD2U_IPK_DIR) $(HD2U_IPK)
#
#
# Some sanity check for the package.
#
hd2u-check: $(HD2U_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HD2U_IPK)
