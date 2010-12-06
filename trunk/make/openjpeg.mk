###########################################################
#
# openjpeg
#
###########################################################
#
# OPENJPEG_VERSION, OPENJPEG_SITE and OPENJPEG_SOURCE define
# the upstream location of the source code for the package.
# OPENJPEG_DIR is the directory which is created when the source
# archive is unpacked.
# OPENJPEG_UNZIP is the command used to unzip the source.
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
OPENJPEG_SITE=http://openjpeg.googlecode.com/files
OPENJPEG_UPSTREAM_VERSION=v1_3
OPENJPEG_VERSION=1.3
OPENJPEG_SOURCE=openjpeg_$(OPENJPEG_UPSTREAM_VERSION).tar.gz
OPENJPEG_DIR=OpenJPEG_$(OPENJPEG_UPSTREAM_VERSION)
OPENJPEG_UNZIP=zcat
OPENJPEG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENJPEG_DESCRIPTION=The OpenJPEG library is an open-source JPEG 2000 codec.
OPENJPEG_SECTION=lib
OPENJPEG_PRIORITY=optional
ifneq (, $(filter libstdc++, $(PACKAGES)))
OPENJPEG_DEPENDS=libstdc++
endif
OPENJPEG_SUGGESTS=
OPENJPEG_CONFLICTS=

#
# OPENJPEG_IPK_VERSION should be incremented when the ipk changes.
#
OPENJPEG_IPK_VERSION=1

#
# OPENJPEG_CONFFILES should be a list of user-editable files
#OPENJPEG_CONFFILES=/opt/etc/openjpeg.conf /opt/etc/init.d/SXXopenjpeg

#
# OPENJPEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENJPEG_PATCHES=$(OPENJPEG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENJPEG_CPPFLAGS=
OPENJPEG_LDFLAGS=

#
# OPENJPEG_BUILD_DIR is the directory in which the build is done.
# OPENJPEG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENJPEG_IPK_DIR is the directory in which the ipk is built.
# OPENJPEG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENJPEG_BUILD_DIR=$(BUILD_DIR)/openjpeg
OPENJPEG_SOURCE_DIR=$(SOURCE_DIR)/openjpeg
OPENJPEG_IPK_DIR=$(BUILD_DIR)/openjpeg-$(OPENJPEG_VERSION)-ipk
OPENJPEG_IPK=$(BUILD_DIR)/openjpeg_$(OPENJPEG_VERSION)-$(OPENJPEG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openjpeg-source openjpeg-unpack openjpeg openjpeg-stage openjpeg-ipk openjpeg-clean openjpeg-dirclean openjpeg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OPENJPEG_SOURCE):
	$(WGET) -P $(@D) $(OPENJPEG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openjpeg-source: $(DL_DIR)/$(OPENJPEG_SOURCE) $(OPENJPEG_PATCHES)

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
$(OPENJPEG_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENJPEG_SOURCE) $(OPENJPEG_PATCHES) make/openjpeg.mk
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(OPENJPEG_DIR) $(@D)
	$(OPENJPEG_UNZIP) $(DL_DIR)/$(OPENJPEG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OPENJPEG_PATCHES)" ; \
		then cat $(OPENJPEG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OPENJPEG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OPENJPEG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(OPENJPEG_DIR) $(@D) ; \
	fi
	sed -i -e 's|-o root -g root||;/-shared/s| -o| $$(LDFLAGS)&|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENJPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENJPEG_LDFLAGS)" \
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

openjpeg-unpack: $(OPENJPEG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENJPEG_BUILD_DIR)/.built: $(OPENJPEG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OPENJPEG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OPENJPEG_LDFLAGS)" \
		PREFIX=/opt
	touch $@

#
# This is the build convenience target.
#
openjpeg: $(OPENJPEG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENJPEG_BUILD_DIR)/.staged: $(OPENJPEG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install DESTDIR=$(STAGING_DIR) PREFIX=/opt
	rm -f $(STAGING_LIB_DIR)/libopenjpeg.a
	cd $(STAGING_LIB_DIR); ln -s libopenjpeg.so.2 libopenjpeg.so
	touch $@

openjpeg-stage: $(OPENJPEG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/openjpeg
#
$(OPENJPEG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: openjpeg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJPEG_PRIORITY)" >>$@
	@echo "Section: $(OPENJPEG_SECTION)" >>$@
	@echo "Version: $(OPENJPEG_VERSION)-$(OPENJPEG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJPEG_MAINTAINER)" >>$@
	@echo "Source: $(OPENJPEG_SITE)/$(OPENJPEG_SOURCE)" >>$@
	@echo "Description: $(OPENJPEG_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJPEG_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJPEG_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJPEG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENJPEG_IPK_DIR)/opt/sbin or $(OPENJPEG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENJPEG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OPENJPEG_IPK_DIR)/opt/etc/openjpeg/...
# Documentation files should be installed in $(OPENJPEG_IPK_DIR)/opt/doc/openjpeg/...
# Daemon startup scripts should be installed in $(OPENJPEG_IPK_DIR)/opt/etc/init.d/S??openjpeg
#
# You may need to patch your application to make it use these locations.
#
$(OPENJPEG_IPK): $(OPENJPEG_BUILD_DIR)/.built
	rm -rf $(OPENJPEG_IPK_DIR) $(BUILD_DIR)/openjpeg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(<D) install DESTDIR=$(OPENJPEG_IPK_DIR) PREFIX=/opt
	rm -f $(OPENJPEG_IPK_DIR)/opt/lib/libopenjpeg.a
	cd $(OPENJPEG_IPK_DIR)/opt/lib; ln -s libopenjpeg.so.2 libopenjpeg.so
	$(MAKE) $(OPENJPEG_IPK_DIR)/CONTROL/control
	echo $(OPENJPEG_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJPEG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJPEG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openjpeg-ipk: $(OPENJPEG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openjpeg-clean:
	rm -f $(OPENJPEG_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENJPEG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openjpeg-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENJPEG_DIR) $(OPENJPEG_BUILD_DIR) $(OPENJPEG_IPK_DIR) $(OPENJPEG_IPK)
#
#
# Some sanity check for the package.
#
openjpeg-check: $(OPENJPEG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
