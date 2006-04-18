###########################################################
#
# ecl
#
###########################################################

# You must replace "ecl" and "ECL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ECL_VERSION, ECL_SITE and ECL_SOURCE define
# the upstream location of the source code for the package.
# ECL_DIR is the directory which is created when the source
# archive is unpacked.
# ECL_UNZIP is the command used to unzip the source.
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
ECL_SITE=http://dl.sourceforge.net/sourceforge/ecls
ECL_VERSION=0.9h
ECL_SOURCE=ecl-$(ECL_VERSION).tgz
ECL_DIR=ecl-$(ECL_VERSION)
ECL_UNZIP=zcat
ECL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ECL_DESCRIPTION=Embeddable Common-Lisp.
ECL_SECTION=lang
ECL_PRIORITY=optional
ECL_DEPENDS=
ECL_SUGGESTS=
ECL_CONFLICTS=

#
# ECL_IPK_VERSION should be incremented when the ipk changes.
#
ECL_IPK_VERSION=1

#
# ECL_CONFFILES should be a list of user-editable files
#ECL_CONFFILES=/opt/etc/ecl.conf /opt/etc/init.d/SXXecl

#
# ECL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ECL_PATCHES=$(ECL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ECL_CPPFLAGS=
ECL_LDFLAGS=

#
# ECL_BUILD_DIR is the directory in which the build is done.
# ECL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ECL_IPK_DIR is the directory in which the ipk is built.
# ECL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ECL_BUILD_DIR=$(BUILD_DIR)/ecl
ECL_HOST_BUILD_DIR=$(BUILD_DIR)/ecl-host
ECL_SOURCE_DIR=$(SOURCE_DIR)/ecl
ECL_IPK_DIR=$(BUILD_DIR)/ecl-$(ECL_VERSION)-ipk
ECL_IPK=$(BUILD_DIR)/ecl_$(ECL_VERSION)-$(ECL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ECL_SOURCE):
	$(WGET) -P $(DL_DIR) $(ECL_SITE)/$(ECL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ecl-source: $(DL_DIR)/$(ECL_SOURCE) $(ECL_PATCHES)

$(ECL_HOST_BUILD_DIR)/.host-built: $(DL_DIR)/$(ECL_SOURCE) $(ECL_PATCHES)
	rm -rf $(BUILD_DIR)/$(ECL_DIR) $(ECL_HOST_BUILD_DIR)
	$(ECL_UNZIP) $(DL_DIR)/$(ECL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(ECL_DIR) $(ECL_HOST_BUILD_DIR)
	(cd $(ECL_HOST_BUILD_DIR); \
		./configure \
		--prefix=$(ECL_HOST_BUILD_DIR)/install \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(ECL_HOST_BUILD_DIR) all install
# now ready to invoke like this:
#	LD_LIBRARY_PATH=$(ECL_HOST_BUILD_DIR)/build $(ECL_HOST_BUILD_DIR)/build/ecl -dir $(ECL_HOST_BUILD_DIR)/build
	touch $(ECL_HOST_BUILD_DIR)/.host-built

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
$(ECL_BUILD_DIR)/.configured: $(DL_DIR)/$(ECL_SOURCE) $(ECL_PATCHES) $(ECL_HOST_BUILD_DIR)/.host-built
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ECL_DIR) $(ECL_BUILD_DIR)
	$(ECL_UNZIP) $(DL_DIR)/$(ECL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ECL_PATCHES)" ; \
		then cat $(ECL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ECL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ECL_DIR)" != "$(ECL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ECL_DIR) $(ECL_BUILD_DIR) ; \
	fi
	cp $(ECL_SOURCE_DIR)/cross_config_$(OPTWARE_TARGET) $(ECL_BUILD_DIR)/cross_config
	echo ECL_TO_RUN=$(ECL_HOST_BUILD_DIR)/install/bin/ecl >> $(ECL_BUILD_DIR)/cross_config
	(cd $(ECL_BUILD_DIR); \
		PATH=$(ECL_HOST_BUILD_DIR)/install/bin:$$PATH \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ECL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ECL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-cross-config=$(ECL_BUILD_DIR)/cross_config \
		--without-clx \
		--without-defsystem \
	)
#	$(PATCH_LIBTOOL) $(ECL_BUILD_DIR)/libtool
	touch $(ECL_BUILD_DIR)/.configured

ecl-unpack: $(ECL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ECL_BUILD_DIR)/.built: $(ECL_BUILD_DIR)/.configured
	rm -f $(ECL_BUILD_DIR)/.built
	$(MAKE) -C $(ECL_BUILD_DIR) all
	touch $(ECL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ecl: $(ECL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ECL_BUILD_DIR)/.staged: $(ECL_BUILD_DIR)/.built
	rm -f $(ECL_BUILD_DIR)/.staged
	$(MAKE) -C $(ECL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ECL_BUILD_DIR)/.staged

ecl-stage: $(ECL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ecl
#
$(ECL_IPK_DIR)/CONTROL/control:
	@install -d $(ECL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ecl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ECL_PRIORITY)" >>$@
	@echo "Section: $(ECL_SECTION)" >>$@
	@echo "Version: $(ECL_VERSION)-$(ECL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ECL_MAINTAINER)" >>$@
	@echo "Source: $(ECL_SITE)/$(ECL_SOURCE)" >>$@
	@echo "Description: $(ECL_DESCRIPTION)" >>$@
	@echo "Depends: $(ECL_DEPENDS)" >>$@
	@echo "Suggests: $(ECL_SUGGESTS)" >>$@
	@echo "Conflicts: $(ECL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ECL_IPK_DIR)/opt/sbin or $(ECL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ECL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ECL_IPK_DIR)/opt/etc/ecl/...
# Documentation files should be installed in $(ECL_IPK_DIR)/opt/doc/ecl/...
# Daemon startup scripts should be installed in $(ECL_IPK_DIR)/opt/etc/init.d/S??ecl
#
# You may need to patch your application to make it use these locations.
#
$(ECL_IPK): $(ECL_BUILD_DIR)/.built
	rm -rf $(ECL_IPK_DIR) $(BUILD_DIR)/ecl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ECL_BUILD_DIR) DESTDIR=$(ECL_IPK_DIR) install
	rm -f $(ECL_IPK_DIR)/opt/info/*
	$(STRIP_COMMAND) $(ECL_IPK_DIR)/opt/bin/ecl
	$(STRIP_COMMAND) $(ECL_IPK_DIR)/opt/lib/ecl/{*.so,*.fas}
#	install -d $(ECL_IPK_DIR)/opt/etc/
#	install -m 644 $(ECL_SOURCE_DIR)/ecl.conf $(ECL_IPK_DIR)/opt/etc/ecl.conf
#	install -d $(ECL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ECL_SOURCE_DIR)/rc.ecl $(ECL_IPK_DIR)/opt/etc/init.d/SXXecl
	$(MAKE) $(ECL_IPK_DIR)/CONTROL/control
#	install -m 755 $(ECL_SOURCE_DIR)/postinst $(ECL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ECL_SOURCE_DIR)/prerm $(ECL_IPK_DIR)/CONTROL/prerm
	echo $(ECL_CONFFILES) | sed -e 's/ /\n/g' > $(ECL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ECL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ecl-ipk: $(ECL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ecl-clean:
	rm -f $(ECL_BUILD_DIR)/.built
	-$(MAKE) -C $(ECL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ecl-dirclean:
	rm -rf $(BUILD_DIR)/$(ECL_DIR) $(ECL_BUILD_DIR) $(ECL_HOST_BUILD_DIR) $(ECL_IPK_DIR) $(ECL_IPK)
