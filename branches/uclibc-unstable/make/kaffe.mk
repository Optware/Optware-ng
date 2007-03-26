###########################################################
#
# kaffe
#
###########################################################
#
# KAFFE_VERSION, KAFFE_SITE and KAFFE_SOURCE define
# the upstream location of the source code for the package.
# KAFFE_DIR is the directory which is created when the source
# archive is unpacked.
# KAFFE_UNZIP is the command used to unzip the source.
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
KAFFE_SITE=ftp://ftp.kaffe.org/pub/kaffe/v1.1.x-development
KAFFE_VERSION=1.1.7
KAFFE_SOURCE=kaffe-$(KAFFE_VERSION).tar.bz2
KAFFE_DIR=kaffe-$(KAFFE_VERSION)
KAFFE_UNZIP=bzcat
KAFFE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
KAFFE_DESCRIPTION=A clean room implementation of the Java virtual machine, plus the associated class libraries.
KAFFE_SECTION=lang
KAFFE_PRIORITY=optional
KAFFE_DEPENDS=
KAFFE_SUGGESTS=
KAFFE_CONFLICTS=

#
# KAFFE_IPK_VERSION should be incremented when the ipk changes.
#
KAFFE_IPK_VERSION=2

#
# KAFFE_CONFFILES should be a list of user-editable files
#KAFFE_CONFFILES=/opt/etc/kaffe.conf /opt/etc/init.d/SXXkaffe

#
# KAFFE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#KAFFE_PATCHES=$(KAFFE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KAFFE_CPPFLAGS=
KAFFE_LDFLAGS="-Wl,-rpath,/opt/jre/lib/$(TARGET_ARCH)"

#
# KAFFE_BUILD_DIR is the directory in which the build is done.
# KAFFE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KAFFE_IPK_DIR is the directory in which the ipk is built.
# KAFFE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KAFFE_BUILD_DIR=$(BUILD_DIR)/kaffe
KAFFE_HOST_BUILD_DIR=$(BUILD_DIR)/kaffe-host
KAFFE_SOURCE_DIR=$(SOURCE_DIR)/kaffe
KAFFE_IPK_DIR=$(BUILD_DIR)/kaffe-$(KAFFE_VERSION)-ipk
KAFFE_IPK=$(BUILD_DIR)/kaffe_$(KAFFE_VERSION)-$(KAFFE_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(OPTWARE_TARGET),wl500g)
KAFFE_CROSS_CONFIG_OPTIONS=--disable-sound
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KAFFE_SOURCE):
	$(WGET) -P $(DL_DIR) $(KAFFE_SITE)/$(KAFFE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kaffe-source: $(DL_DIR)/$(KAFFE_SOURCE) $(KAFFE_PATCHES)

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
$(KAFFE_BUILD_DIR)/.unpacked: $(DL_DIR)/$(KAFFE_SOURCE)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -f $(KAFFE_BUILD_DIR)/.unpacked
	rm -rf $(BUILD_DIR)/$(KAFFE_DIR) $(KAFFE_BUILD_DIR)
	$(KAFFE_UNZIP) $(DL_DIR)/$(KAFFE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(KAFFE_PATCHES)" ; \
		then cat $(KAFFE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(KAFFE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(KAFFE_DIR)" != "$(KAFFE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KAFFE_DIR) $(KAFFE_BUILD_DIR) ; \
	fi
	touch $(KAFFE_BUILD_DIR)/.unpacked

$(KAFFE_BUILD_DIR)/.hostbuilt: $(KAFFE_BUILD_DIR)/.unpacked
#	$(MAKE) <bar>-stage <baz>-stage
	rm -f $(KAFFE_BUILD_DIR)/.hostbuilt
	rm -rf $(BUILD_DIR)/$(KAFFE_DIR) $(KAFFE_HOST_BUILD_DIR)
	$(KAFFE_UNZIP) $(DL_DIR)/$(KAFFE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(KAFFE_DIR) $(KAFFE_HOST_BUILD_DIR) ; \
	(cd $(KAFFE_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-gtk-peer \
		--without-x \
	)
	$(MAKE) -C $(KAFFE_HOST_BUILD_DIR)
	$(MAKE) -C $(KAFFE_HOST_BUILD_DIR) DESTDIR=$(KAFFE_HOST_BUILD_DIR) install
	touch $(KAFFE_BUILD_DIR)/.hostbuilt

$(KAFFE_BUILD_DIR)/.configured: $(KAFFE_BUILD_DIR)/.hostbuilt
	(cd $(KAFFE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KAFFE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KAFFE_LDFLAGS)" \
		KAFFEH=$(KAFFE_HOST_BUILD_DIR)/opt/bin/kaffeh \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-gtk-peer \
		--without-x \
		--enable-binreloc \
		$(KAFFE_CROSS_CONFIG_OPTIONS) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(KAFFE_BUILD_DIR)/libtool
	touch $(KAFFE_BUILD_DIR)/.configured

kaffe-unpack: $(KAFFE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KAFFE_BUILD_DIR)/.built: $(KAFFE_BUILD_DIR)/.configured
	rm -f $(KAFFE_BUILD_DIR)/.built
	$(MAKE) -C $(KAFFE_BUILD_DIR)
	touch $(KAFFE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
kaffe: $(KAFFE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KAFFE_BUILD_DIR)/.staged: $(KAFFE_BUILD_DIR)/.built
	rm -f $(KAFFE_BUILD_DIR)/.staged
	$(MAKE) -C $(KAFFE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(KAFFE_BUILD_DIR)/.staged

kaffe-stage: $(KAFFE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/kaffe
#
$(KAFFE_IPK_DIR)/CONTROL/control:
	@install -d $(KAFFE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: kaffe" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KAFFE_PRIORITY)" >>$@
	@echo "Section: $(KAFFE_SECTION)" >>$@
	@echo "Version: $(KAFFE_VERSION)-$(KAFFE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KAFFE_MAINTAINER)" >>$@
	@echo "Source: $(KAFFE_SITE)/$(KAFFE_SOURCE)" >>$@
	@echo "Description: $(KAFFE_DESCRIPTION)" >>$@
	@echo "Depends: $(KAFFE_DEPENDS)" >>$@
	@echo "Suggests: $(KAFFE_SUGGESTS)" >>$@
	@echo "Conflicts: $(KAFFE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(KAFFE_IPK_DIR)/opt/sbin or $(KAFFE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KAFFE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(KAFFE_IPK_DIR)/opt/etc/kaffe/...
# Documentation files should be installed in $(KAFFE_IPK_DIR)/opt/doc/kaffe/...
# Daemon startup scripts should be installed in $(KAFFE_IPK_DIR)/opt/etc/init.d/S??kaffe
#
# You may need to patch your application to make it use these locations.
#
$(KAFFE_IPK): $(KAFFE_BUILD_DIR)/.built
	rm -rf $(KAFFE_IPK_DIR) $(BUILD_DIR)/kaffe_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(KAFFE_BUILD_DIR) DESTDIR=$(KAFFE_IPK_DIR) install-strip
#	install -d $(KAFFE_IPK_DIR)/opt/etc/
#	install -m 644 $(KAFFE_SOURCE_DIR)/kaffe.conf $(KAFFE_IPK_DIR)/opt/etc/kaffe.conf
#	install -d $(KAFFE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(KAFFE_SOURCE_DIR)/rc.kaffe $(KAFFE_IPK_DIR)/opt/etc/init.d/SXXkaffe
	$(MAKE) $(KAFFE_IPK_DIR)/CONTROL/control
#	install -m 755 $(KAFFE_SOURCE_DIR)/postinst $(KAFFE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(KAFFE_SOURCE_DIR)/prerm $(KAFFE_IPK_DIR)/CONTROL/prerm
	echo $(KAFFE_CONFFILES) | sed -e 's/ /\n/g' > $(KAFFE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KAFFE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
kaffe-ipk: $(KAFFE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
kaffe-clean:
	rm -f $(KAFFE_BUILD_DIR)/.built
	-$(MAKE) -C $(KAFFE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kaffe-dirclean:
	rm -rf $(BUILD_DIR)/$(KAFFE_DIR) $(KAFFE_HOST_BUILD_DIR) $(KAFFE_BUILD_DIR) $(KAFFE_IPK_DIR) $(KAFFE_IPK)
