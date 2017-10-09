###########################################################
#
# rox-filer
#
###########################################################

# You must replace "rox-filer" and "ROX-FILER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ROX-FILER_VERSION, ROX-FILER_SITE and ROX-FILER_SOURCE define
# the upstream location of the source code for the package.
# ROX-FILER_DIR is the directory which is created when the source
# archive is unpacked.
# ROX-FILER_UNZIP is the command used to unzip the source.
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
ROX-FILER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/rox
ROX-FILER_VERSION=2.11
ROX-FILER_SOURCE=rox-filer-$(ROX-FILER_VERSION).tar.bz2
ROX-FILER_DIR=rox-filer-$(ROX-FILER_VERSION)
ROX-FILER_UNZIP=bzcat
ROX-FILER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ROX-FILER_DESCRIPTION=ROX-Filer is a fast and powerful graphical file manager.
ROX-FILER_SECTION=utilities
ROX-FILER_PRIORITY=optional
ROX-FILER_DEPENDS=gtk2, file, sm
ROX-FILER_SUGGESTS=
ROX-FILER_CONFLICTS=

#
# ROX-FILER_IPK_VERSION should be incremented when the ipk changes.
#
ROX-FILER_IPK_VERSION=3

#
# ROX-FILER_CONFFILES should be a list of user-editable files
#ROX-FILER_CONFFILES=$(TARGET_PREFIX)/etc/rox-filer.conf $(TARGET_PREFIX)/etc/init.d/SXXrox-filer

#
# ROX-FILER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ROX-FILER_PATCHES=$(ROX-FILER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ROX-FILER_CPPFLAGS=
ROX-FILER_LDFLAGS=-lm -ldl

#
# ROX-FILER_BUILD_DIR is the directory in which the build is done.
# ROX-FILER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ROX-FILER_IPK_DIR is the directory in which the ipk is built.
# ROX-FILER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ROX-FILER_BUILD_DIR=$(BUILD_DIR)/rox-filer
ROX-FILER_SOURCE_DIR=$(SOURCE_DIR)/rox-filer
ROX-FILER_IPK_DIR=$(BUILD_DIR)/rox-filer-$(ROX-FILER_VERSION)-ipk
ROX-FILER_IPK=$(BUILD_DIR)/rox-filer_$(ROX-FILER_VERSION)-$(ROX-FILER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rox-filer-source rox-filer-unpack rox-filer rox-filer-stage rox-filer-ipk rox-filer-clean rox-filer-dirclean rox-filer-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ROX-FILER_SOURCE):
	$(WGET) -P $(@D) $(ROX-FILER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rox-filer-source: $(DL_DIR)/$(ROX-FILER_SOURCE) $(ROX-FILER_PATCHES)

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
$(ROX-FILER_BUILD_DIR)/.configured: $(DL_DIR)/$(ROX-FILER_SOURCE) $(ROX-FILER_PATCHES) make/rox-filer.mk
	$(MAKE) gtk2-stage file-stage shared-mime-info-stage sm-stage
	rm -rf $(BUILD_DIR)/$(ROX-FILER_DIR) $(@D)
	$(ROX-FILER_UNZIP) $(DL_DIR)/$(ROX-FILER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ROX-FILER_PATCHES)" ; \
		then cat $(ROX-FILER_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ROX-FILER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ROX-FILER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ROX-FILER_DIR) $(@D) ; \
	fi
	sed -i -e 's:/usr/share\|/usr/local/share:$(TARGET_PREFIX)/share:g' $(@D)/ROX-Filer/src/*.c
	sed -i -e 's:g_strdup(getenv("APP_DIR")):"$(TARGET_PREFIX)/share/rox":' $(@D)/ROX-Filer/src/main.c
	sed -i -e 's|/etc/xdg|$(TARGET_PREFIX)/etc/xdg|g' -e 's|g_build_filename(g_get_home_dir(), "\.config"|g_build_filename("$(TARGET_PREFIX)/etc"|' \
									$(@D)/ROX-Filer/src/choices.c
	(cd $(@D)/ROX-Filer; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(ROX-FILER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ROX-FILER_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		src/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	sed -i -e 's|-I/usr/include ||' -e '/mv "\$${PROG}"/s/.*/#\\/' $(@D)/ROX-Filer/Makefile
ifneq (, $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
	sed -i -e '/HAVE_SYS_INOTIFY_H/s|^|//|' $(@D)/ROX-Filer/config.h
endif
	touch $@

rox-filer-unpack: $(ROX-FILER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ROX-FILER_BUILD_DIR)/.built: $(ROX-FILER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/ROX-Filer \
		PKG_CONFIG='PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" pkg-config'
	touch $@

#
# This is the build convenience target.
#
rox-filer: $(ROX-FILER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(ROX-FILER_BUILD_DIR)/.staged: $(ROX-FILER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D)/ROX-Filer DESTDIR=$(STAGING_DIR) install
#	touch $@

#rox-filer-stage: $(ROX-FILER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rox-filer
#
$(ROX-FILER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: rox-filer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ROX-FILER_PRIORITY)" >>$@
	@echo "Section: $(ROX-FILER_SECTION)" >>$@
	@echo "Version: $(ROX-FILER_VERSION)-$(ROX-FILER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ROX-FILER_MAINTAINER)" >>$@
	@echo "Source: $(ROX-FILER_SITE)/$(ROX-FILER_SOURCE)" >>$@
	@echo "Description: $(ROX-FILER_DESCRIPTION)" >>$@
	@echo "Depends: $(ROX-FILER_DEPENDS)" >>$@
	@echo "Suggests: $(ROX-FILER_SUGGESTS)" >>$@
	@echo "Conflicts: $(ROX-FILER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/rox-filer/...
# Documentation files should be installed in $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/doc/rox-filer/...
# Daemon startup scripts should be installed in $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??rox-filer
#
# You may need to patch your application to make it use these locations.
#
$(ROX-FILER_IPK): $(ROX-FILER_BUILD_DIR)/.built
	rm -rf $(ROX-FILER_IPK_DIR) $(BUILD_DIR)/rox-filer_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/bin $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/share/rox \
			$(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/man/man1
	$(STRIP_COMMAND) $(ROX-FILER_BUILD_DIR)/ROX-Filer/ROX-Filer
	cp -f $(ROX-FILER_BUILD_DIR)/ROX-Filer/ROX-Filer $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/bin/rox
	ln -s rox $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/bin/rox-filer
	cp -af $(addprefix $(ROX-FILER_BUILD_DIR)/ROX-Filer/, Help Messages Options.xml \
			ROX images style.css .DirIcon) $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/share/rox
	cp -f $(ROX-FILER_BUILD_DIR)/rox.1 $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/man/man1
	cd $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/share/rox/ROX/MIME      && \
	ln -s text-x-{diff,patch}.png                       && \
	ln -s application-x-font-{afm,type1}.png            && \
	ln -s application-xml{,-dtd}.png                    && \
	ln -s application-xml{,-external-parsed-entity}.png && \
	ln -s application-{,rdf+}xml.png                    && \
	ln -s application-x{ml,-xbel}.png                   && \
	ln -s application-{x-shell,java}script.png          && \
	ln -s application-x-{bzip,xz}-compressed-tar.png    && \
	ln -s application-x-{bzip,lzma}-compressed-tar.png  && \
	ln -s application-x-{bzip-compressed-tar,lzo}.png   && \
	ln -s application-x-{bzip,xz}.png                   && \
	ln -s application-x-{gzip,lzma}.png                 && \
	ln -s application-{msword,rtf}.png
#	$(MAKE) -C $(ROX-FILER_BUILD_DIR)/ROX-Filer DESTDIR=$(ROX-FILER_IPK_DIR) install-strip
#	$(INSTALL) -d $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(ROX-FILER_SOURCE_DIR)/rox-filer.conf $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/rox-filer.conf
#	$(INSTALL) -d $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(ROX-FILER_SOURCE_DIR)/rc.rox-filer $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrox-filer
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ROX-FILER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrox-filer
	$(MAKE) $(ROX-FILER_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(ROX-FILER_SOURCE_DIR)/postinst $(ROX-FILER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ROX-FILER_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(ROX-FILER_SOURCE_DIR)/prerm $(ROX-FILER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ROX-FILER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(ROX-FILER_IPK_DIR)/CONTROL/postinst $(ROX-FILER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(ROX-FILER_CONFFILES) | sed -e 's/ /\n/g' > $(ROX-FILER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ROX-FILER_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(ROX-FILER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rox-filer-ipk: $(ROX-FILER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rox-filer-clean:
	rm -f $(ROX-FILER_BUILD_DIR)/.built
	-$(MAKE) -C $(ROX-FILER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rox-filer-dirclean:
	rm -rf $(BUILD_DIR)/$(ROX-FILER_DIR) $(ROX-FILER_BUILD_DIR) $(ROX-FILER_IPK_DIR) $(ROX-FILER_IPK)
#
#
# Some sanity check for the package.
#
rox-filer-check: $(ROX-FILER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
