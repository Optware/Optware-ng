###########################################################
#
# ii
#
###########################################################
#
# II_VERSION, II_SITE and II_SOURCE define
# the upstream location of the source code for the package.
# II_DIR is the directory which is created when the source
# archive is unpacked.
# II_UNZIP is the command used to unzip the source.
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
II_SITE=http://code.suckless.org/dl/tools
II_VERSION=1.4
II_SOURCE=ii-$(II_VERSION).tar.gz
II_DIR=ii-$(II_VERSION)
II_UNZIP=zcat
II_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
II_DESCRIPTION=ii is a minimalist FIFO and filesystem-based IRC client.
II_SECTION=irc
II_PRIORITY=optional
II_DEPENDS=
II_SUGGESTS=
II_CONFLICTS=

#
# II_IPK_VERSION should be incremented when the ipk changes.
#
II_IPK_VERSION=1

#
# II_CONFFILES should be a list of user-editable files
#II_CONFFILES=/opt/etc/ii.conf /opt/etc/init.d/SXXii

#
# II_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#II_PATCHES=$(II_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
II_CPPFLAGS=
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
II_CPPFLAGS+= -D_POSIX_PATH_MAX=4096
endif
II_LDFLAGS=

#
# II_BUILD_DIR is the directory in which the build is done.
# II_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# II_IPK_DIR is the directory in which the ipk is built.
# II_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
II_BUILD_DIR=$(BUILD_DIR)/ii
II_SOURCE_DIR=$(SOURCE_DIR)/ii
II_IPK_DIR=$(BUILD_DIR)/ii-$(II_VERSION)-ipk
II_IPK=$(BUILD_DIR)/ii_$(II_VERSION)-$(II_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ii-source ii-unpack ii ii-stage ii-ipk ii-clean ii-dirclean ii-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(II_SOURCE):
	$(WGET) -P $(@D) $(II_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ii-source: $(DL_DIR)/$(II_SOURCE) $(II_PATCHES)

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
$(II_BUILD_DIR)/.configured: $(DL_DIR)/$(II_SOURCE) $(II_PATCHES) make/ii.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(II_DIR) $(@D)
	$(II_UNZIP) $(DL_DIR)/$(II_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(II_PATCHES)" ; \
		then cat $(II_PATCHES) | \
		patch -d $(BUILD_DIR)/$(II_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(II_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(II_DIR) $(@D) ; \
	fi
	sed -i.orig \
		-e 's| -I/usr/include| $$(CPPFLAGS)|' \
		-e 's| -L/usr/lib||' $(@D)/config.mk
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(II_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(II_LDFLAGS)" \
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

ii-unpack: $(II_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(II_BUILD_DIR)/.built: $(II_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(II_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(II_LDFLAGS)" \
		INCDIR=$(STAGING_INCLUDE_DIR) \
		;
	touch $@

#
# This is the build convenience target.
#
ii: $(II_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(II_BUILD_DIR)/.staged: $(II_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#ii-stage: $(II_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ii
#
$(II_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ii" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(II_PRIORITY)" >>$@
	@echo "Section: $(II_SECTION)" >>$@
	@echo "Version: $(II_VERSION)-$(II_IPK_VERSION)" >>$@
	@echo "Maintainer: $(II_MAINTAINER)" >>$@
	@echo "Source: $(II_SITE)/$(II_SOURCE)" >>$@
	@echo "Description: $(II_DESCRIPTION)" >>$@
	@echo "Depends: $(II_DEPENDS)" >>$@
	@echo "Suggests: $(II_SUGGESTS)" >>$@
	@echo "Conflicts: $(II_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(II_IPK_DIR)/opt/sbin or $(II_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(II_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(II_IPK_DIR)/opt/etc/ii/...
# Documentation files should be installed in $(II_IPK_DIR)/opt/doc/ii/...
# Daemon startup scripts should be installed in $(II_IPK_DIR)/opt/etc/init.d/S??ii
#
# You may need to patch your application to make it use these locations.
#
$(II_IPK): $(II_BUILD_DIR)/.built
	rm -rf $(II_IPK_DIR) $(BUILD_DIR)/ii_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(II_BUILD_DIR) install \
		DESTDIR=$(II_IPK_DIR) PREFIX=/opt
	$(STRIP_COMMAND) $(II_IPK_DIR)/opt/bin/ii
	$(MAKE) $(II_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(II_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ii-ipk: $(II_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ii-clean:
	rm -f $(II_BUILD_DIR)/.built
	-$(MAKE) -C $(II_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ii-dirclean:
	rm -rf $(BUILD_DIR)/$(II_DIR) $(II_BUILD_DIR) $(II_IPK_DIR) $(II_IPK)
#
#
# Some sanity check for the package.
#
ii-check: $(II_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(II_IPK)
