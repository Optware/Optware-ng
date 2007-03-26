###########################################################
#
# ftpcopy
#
###########################################################
#
# FTPCOPY_VERSION, FTPCOPY_SITE and FTPCOPY_SOURCE define
# the upstream location of the source code for the package.
# FTPCOPY_DIR is the directory which is created when the source
# archive is unpacked.
# FTPCOPY_UNZIP is the command used to unzip the source.
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
FTPCOPY_SITE=http://www.ohse.de/uwe/ftpcopy
FTPCOPY_VERSION=0.6.7
FTPCOPY_SOURCE=ftpcopy-$(FTPCOPY_VERSION).tar.gz
FTPCOPY_DIR=ftpcopy-$(FTPCOPY_VERSION)
FTPCOPY_UNZIP=zcat
FTPCOPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FTPCOPY_DESCRIPTION=A simple FTP client written to copy files or directories (recursively) from a FTP server.
FTPCOPY_SECTION=net
FTPCOPY_PRIORITY=optional
FTPCOPY_DEPENDS=
FTPCOPY_SUGGESTS=
FTPCOPY_CONFLICTS=

#
# FTPCOPY_IPK_VERSION should be incremented when the ipk changes.
#
FTPCOPY_IPK_VERSION=3

#
# FTPCOPY_CONFFILES should be a list of user-editable files
#FTPCOPY_CONFFILES=/opt/etc/ftpcopy.conf /opt/etc/init.d/SXXftpcopy

#
# FTPCOPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(TARGET_CC), $(HOSTCC))
FTPCOPY_PATCHES=$(FTPCOPY_SOURCE_DIR)/src-have_func.sh.patch $(FTPCOPY_SOURCE_DIR)/src-iopause.sh.patch $(FTPCOPY_SOURCE_DIR)/src-typesize.sh.patch
FTPCOPY_CROSS_ENV=env \
	ac_cv_sizeof_short=2 \
	ac_cv_sizeof_int=4 \
	ac_cv_sizeof_long=4 \
	ac_cv_sizeof_unsigned_short=2 \
	ac_cv_sizeof_unsigned_int=4 \
	ac_cv_sizeof_unsigned_long=4 \
	ac_cv_sizeof_long_long=8 \
	ac_cv_sizeof_unsigned_long_long=8 \
	ftpcopy_iopause_use=poll
else
FTPCOPY_PATCHES=
FTPCOPY_CROSS_ENV=
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FTPCOPY_CPPFLAGS=
FTPCOPY_LDFLAGS=

#
# FTPCOPY_BUILD_DIR is the directory in which the build is done.
# FTPCOPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FTPCOPY_IPK_DIR is the directory in which the ipk is built.
# FTPCOPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FTPCOPY_BUILD_DIR=$(BUILD_DIR)/ftpcopy
FTPCOPY_SOURCE_DIR=$(SOURCE_DIR)/ftpcopy
FTPCOPY_IPK_DIR=$(BUILD_DIR)/ftpcopy-$(FTPCOPY_VERSION)-ipk
FTPCOPY_IPK=$(BUILD_DIR)/ftpcopy_$(FTPCOPY_VERSION)-$(FTPCOPY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ftpcopy-source ftpcopy-unpack ftpcopy ftpcopy-stage ftpcopy-ipk ftpcopy-clean ftpcopy-dirclean ftpcopy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FTPCOPY_SOURCE):
	$(WGET) -P $(DL_DIR) $(FTPCOPY_SITE)/$(FTPCOPY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ftpcopy-source: $(DL_DIR)/$(FTPCOPY_SOURCE) $(FTPCOPY_PATCHES)

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
$(FTPCOPY_BUILD_DIR)/.configured: $(DL_DIR)/$(FTPCOPY_SOURCE) $(FTPCOPY_PATCHES) make/ftpcopy.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FTPCOPY_DIR) $(FTPCOPY_BUILD_DIR)
	$(FTPCOPY_UNZIP) $(DL_DIR)/$(FTPCOPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/web/$(FTPCOPY_DIR) $(BUILD_DIR)/ && rmdir $(BUILD_DIR)/web
	if test -n "$(FTPCOPY_PATCHES)" ; \
		then cat $(FTPCOPY_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(FTPCOPY_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FTPCOPY_DIR)" != "$(FTPCOPY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FTPCOPY_DIR) $(FTPCOPY_BUILD_DIR) ; \
	fi
#	(cd $(FTPCOPY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FTPCOPY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FTPCOPY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
ifneq ($(TARGET_CC), $(HOSTCC))
	sed -i -e '/^LFS_CFLAGS=$$/s/=$$/="-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"/' \
	       -e '/^lfs$$/s/^/#/' \
		$(FTPCOPY_BUILD_DIR)/src/guess-compiler.sh
	sed -i -e '/perl uogo2man/s/^/#/' $(FTPCOPY_BUILD_DIR)/src/Makefile
	sed -i -e '/^doit documentation/s/^/#/' $(FTPCOPY_BUILD_DIR)/package/compile
endif
	mkdir -p $(FTPCOPY_BUILD_DIR)/compile
	echo $(TARGET_CC) > $(FTPCOPY_BUILD_DIR)/compile/conf-cc
	echo $(TARGET_CC) > $(FTPCOPY_BUILD_DIR)/compile/conf-ld
	echo $(TARGET_AR) > $(FTPCOPY_BUILD_DIR)/compile/conf-ar
	echo $(TARGET_RANLIB) > $(FTPCOPY_BUILD_DIR)/compile/conf-ranlib
	echo "$(STAGING_CPPFLAGS) $(FTPCOPY_CPPFLAGS)" > $(FTPCOPY_BUILD_DIR)/compile/conf-cflags
	echo "$(STAGING_LDFLAGS) $(FTPCOPY_LDFLAGS)" > $(FTPCOPY_BUILD_DIR)/compile/conf-ldflags
#	$(PATCH_LIBTOOL) $(FTPCOPY_BUILD_DIR)/libtool
	touch $(FTPCOPY_BUILD_DIR)/.configured

ftpcopy-unpack: $(FTPCOPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FTPCOPY_BUILD_DIR)/.built: $(FTPCOPY_BUILD_DIR)/.configured
	rm -f $(FTPCOPY_BUILD_DIR)/.built
	$(FTPCOPY_CROSS_ENV) \
	$(MAKE) -C $(FTPCOPY_BUILD_DIR)
	touch $(FTPCOPY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ftpcopy: $(FTPCOPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FTPCOPY_BUILD_DIR)/.staged: $(FTPCOPY_BUILD_DIR)/.built
	rm -f $(FTPCOPY_BUILD_DIR)/.staged
	$(MAKE) -C $(FTPCOPY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FTPCOPY_BUILD_DIR)/.staged

ftpcopy-stage: $(FTPCOPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ftpcopy
#
$(FTPCOPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ftpcopy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FTPCOPY_PRIORITY)" >>$@
	@echo "Section: $(FTPCOPY_SECTION)" >>$@
	@echo "Version: $(FTPCOPY_VERSION)-$(FTPCOPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FTPCOPY_MAINTAINER)" >>$@
	@echo "Source: $(FTPCOPY_SITE)/$(FTPCOPY_SOURCE)" >>$@
	@echo "Description: $(FTPCOPY_DESCRIPTION)" >>$@
	@echo "Depends: $(FTPCOPY_DEPENDS)" >>$@
	@echo "Suggests: $(FTPCOPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(FTPCOPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FTPCOPY_IPK_DIR)/opt/sbin or $(FTPCOPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FTPCOPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FTPCOPY_IPK_DIR)/opt/etc/ftpcopy/...
# Documentation files should be installed in $(FTPCOPY_IPK_DIR)/opt/doc/ftpcopy/...
# Daemon startup scripts should be installed in $(FTPCOPY_IPK_DIR)/opt/etc/init.d/S??ftpcopy
#
# You may need to patch your application to make it use these locations.
#
$(FTPCOPY_IPK): $(FTPCOPY_BUILD_DIR)/.built
	rm -rf $(FTPCOPY_IPK_DIR) $(BUILD_DIR)/ftpcopy_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FTPCOPY_BUILD_DIR) DESTDIR=$(FTPCOPY_IPK_DIR) install-strip
	install -d $(FTPCOPY_IPK_DIR)/opt/bin/
	install $(FTPCOPY_BUILD_DIR)/command/* $(FTPCOPY_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(FTPCOPY_IPK_DIR)/opt/bin/ftpcopy $(FTPCOPY_IPK_DIR)/opt/bin/ftpls
	$(MAKE) $(FTPCOPY_IPK_DIR)/CONTROL/control
	echo $(FTPCOPY_CONFFILES) | sed -e 's/ /\n/g' > $(FTPCOPY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FTPCOPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ftpcopy-ipk: $(FTPCOPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ftpcopy-clean:
	rm -f $(FTPCOPY_BUILD_DIR)/.built
	-$(MAKE) -C $(FTPCOPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ftpcopy-dirclean:
	rm -rf $(BUILD_DIR)/$(FTPCOPY_DIR) $(FTPCOPY_BUILD_DIR) $(FTPCOPY_IPK_DIR) $(FTPCOPY_IPK)
#
#
# Some sanity check for the package.
#
ftpcopy-check:
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FTPCOPY_IPK)
