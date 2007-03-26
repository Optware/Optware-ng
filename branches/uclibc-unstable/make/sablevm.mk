###########################################################
#
# sablevm
#
###########################################################
#
# SABLEVM_VERSION, SABLEVM_SITE and SABLEVM_SOURCE define
# the upstream location of the source code for the package.
# SABLEVM_DIR is the directory which is created when the source
# archive is unpacked.
# SABLEVM_UNZIP is the command used to unzip the source.
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
SABLEVM_VERSION=1.13
SABLEVM_SITE=http://sources.nslu2-linux.org/sources/
SABLEVM_SOURCE=sablevm-sdk-$(SABLEVM_VERSION).tar.gz
SABLEVM_DIR=sablevm-sdk-$(SABLEVM_VERSION)
SABLEVM_UNZIP=zcat
SABLEVM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SABLEVM_DESCRIPTION=A robust, extremely portable, efficient, and specifications-compliant JVM.
SABLEVM_SECTION=lang
SABLEVM_PRIORITY=optional
# it really depends on libltdl
SABLEVM_DEPENDS=libtool
SABLEVM_SUGGESTS=
SABLEVM_CONFLICTS=classpath

#
# SABLEVM_IPK_VERSION should be incremented when the ipk changes.
#
SABLEVM_IPK_VERSION=2

#
# SABLEVM_CONFFILES should be a list of user-editable files
#SABLEVM_CONFFILES=/opt/etc/sablevm.conf /opt/etc/init.d/SXXsablevm

#
# SABLEVM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SABLEVM_PATCHES=$(SABLEVM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SABLEVM_CPPFLAGS=
SABLEVM_LDFLAGS=

#
# SABLEVM_BUILD_DIR is the directory in which the build is done.
# SABLEVM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SABLEVM_IPK_DIR is the directory in which the ipk is built.
# SABLEVM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SABLEVM_BUILD_DIR=$(BUILD_DIR)/sablevm-sdk
SABLEVM_SOURCE_DIR=$(SOURCE_DIR)/sablevm
SABLEVM_IPK_DIR=$(BUILD_DIR)/sablevm-$(SABLEVM_VERSION)-ipk
SABLEVM_IPK=$(BUILD_DIR)/sablevm_$(SABLEVM_VERSION)-$(SABLEVM_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(OPTWARE_TARGET),wl500g)
SABLEVM_INTERNAL_LIBFFI=--with-internal-libffi
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SABLEVM_SOURCE):
	$(WGET) -P $(DL_DIR) $(SABLEVM_SITE)/$(SABLEVM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sablevm-source: $(DL_DIR)/$(SABLEVM_SOURCE) $(SABLEVM_PATCHES)

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
$(SABLEVM_BUILD_DIR)/.configured: $(DL_DIR)/$(SABLEVM_SOURCE) $(SABLEVM_PATCHES) # make/sablevm.mk
	$(MAKE) libtool-stage
	rm -rf $(BUILD_DIR)/$(SABLEVM_DIR) $(SABLEVM_BUILD_DIR)
	$(SABLEVM_UNZIP) $(DL_DIR)/$(SABLEVM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SABLEVM_PATCHES)" ; \
		then cat $(SABLEVM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SABLEVM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SABLEVM_DIR)" != "$(SABLEVM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SABLEVM_DIR) $(SABLEVM_BUILD_DIR) ; \
	fi
	(cd $(SABLEVM_BUILD_DIR)/sablevm; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SABLEVM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SABLEVM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(SABLEVM_INTERNAL_LIBFFI) \
		--disable-nls \
		--disable-static \
	)
	(cd $(SABLEVM_BUILD_DIR)/sablevm-classpath; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SABLEVM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SABLEVM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-gtk-peer \
		--disable-qt-peer \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SABLEVM_BUILD_DIR)/libtool
	touch $(SABLEVM_BUILD_DIR)/.configured

sablevm-unpack: $(SABLEVM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SABLEVM_BUILD_DIR)/.built: $(SABLEVM_BUILD_DIR)/.configured
	rm -f $(SABLEVM_BUILD_DIR)/.built
	$(MAKE) -C $(SABLEVM_BUILD_DIR)/sablevm
	$(MAKE) -C $(SABLEVM_BUILD_DIR)/sablevm-classpath
	touch $(SABLEVM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
sablevm: $(SABLEVM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SABLEVM_BUILD_DIR)/.staged: $(SABLEVM_BUILD_DIR)/.built
	rm -f $(SABLEVM_BUILD_DIR)/.staged
	$(MAKE) -C $(SABLEVM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SABLEVM_BUILD_DIR)/.staged

sablevm-stage: $(SABLEVM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sablevm
#
$(SABLEVM_IPK_DIR)/CONTROL/control:
	@install -d $(SABLEVM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sablevm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SABLEVM_PRIORITY)" >>$@
	@echo "Section: $(SABLEVM_SECTION)" >>$@
	@echo "Version: $(SABLEVM_VERSION)-$(SABLEVM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SABLEVM_MAINTAINER)" >>$@
	@echo "Source: $(SABLEVM_SITE)/$(SABLEVM_SOURCE)" >>$@
	@echo "Description: $(SABLEVM_DESCRIPTION)" >>$@
	@echo "Depends: $(SABLEVM_DEPENDS)" >>$@
	@echo "Suggests: $(SABLEVM_SUGGESTS)" >>$@
	@echo "Conflicts: $(SABLEVM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SABLEVM_IPK_DIR)/opt/sbin or $(SABLEVM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SABLEVM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SABLEVM_IPK_DIR)/opt/etc/sablevm/...
# Documentation files should be installed in $(SABLEVM_IPK_DIR)/opt/doc/sablevm/...
# Daemon startup scripts should be installed in $(SABLEVM_IPK_DIR)/opt/etc/init.d/S??sablevm
#
# You may need to patch your application to make it use these locations.
#
$(SABLEVM_IPK): $(SABLEVM_BUILD_DIR)/.built
	rm -rf $(SABLEVM_IPK_DIR) $(BUILD_DIR)/sablevm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SABLEVM_BUILD_DIR)/sablevm \
	    DESTDIR=$(SABLEVM_IPK_DIR) \
	    install
	$(STRIP_COMMAND) $(SABLEVM_IPK_DIR)/opt/bin/sablevm $(SABLEVM_IPK_DIR)/opt/lib/libsablevm*.so
	$(MAKE) -C $(SABLEVM_BUILD_DIR)/sablevm-classpath \
	    DESTDIR=$(SABLEVM_IPK_DIR) \
	    INSTALL_STRIP_PROGRAM="$(STRIP_COMMAND)" \
	    install-strip
#	install -d $(SABLEVM_IPK_DIR)/opt/etc/
#	install -m 644 $(SABLEVM_SOURCE_DIR)/sablevm.conf $(SABLEVM_IPK_DIR)/opt/etc/sablevm.conf
#	install -d $(SABLEVM_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SABLEVM_SOURCE_DIR)/rc.sablevm $(SABLEVM_IPK_DIR)/opt/etc/init.d/SXXsablevm
	$(MAKE) $(SABLEVM_IPK_DIR)/CONTROL/control
#	install -m 755 $(SABLEVM_SOURCE_DIR)/postinst $(SABLEVM_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SABLEVM_SOURCE_DIR)/prerm $(SABLEVM_IPK_DIR)/CONTROL/prerm
	echo $(SABLEVM_CONFFILES) | sed -e 's/ /\n/g' > $(SABLEVM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SABLEVM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sablevm-ipk: $(SABLEVM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sablevm-clean:
	rm -f $(SABLEVM_BUILD_DIR)/.built
	-$(MAKE) -C $(SABLEVM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sablevm-dirclean:
	rm -rf $(BUILD_DIR)/$(SABLEVM_DIR) $(SABLEVM_BUILD_DIR) $(SABLEVM_IPK_DIR) $(SABLEVM_IPK)
