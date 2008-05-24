###########################################################
#
# tinypy
#
###########################################################
#
# TINYPY_VERSION, TINYPY_SITE and TINYPY_SOURCE define
# the upstream location of the source code for the package.
# TINYPY_DIR is the directory which is created when the source
# archive is unpacked.
# TINYPY_UNZIP is the command used to unzip the source.
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
TINYPY_SITE=http://tinypy.googlecode.com/files
TINYPY_VERSION=1.1
TINYPY_SOURCE=tinypy-$(TINYPY_VERSION).tar.gz
TINYPY_DIR=tinypy-$(TINYPY_VERSION)
TINYPY_UNZIP=zcat
TINYPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TINYPY_DESCRIPTION=tinypy is a minimalist implementation of Python in 64k of code.
TINYPY_SECTION=lang
TINYPY_PRIORITY=optional
TINYPY_DEPENDS=
TINYPY_SUGGESTS=
TINYPY_CONFLICTS=

#
# TINYPY_IPK_VERSION should be incremented when the ipk changes.
#
TINYPY_IPK_VERSION=1

#
# TINYPY_CONFFILES should be a list of user-editable files
#TINYPY_CONFFILES=/opt/etc/tinypy.conf /opt/etc/init.d/SXXtinypy

#
# TINYPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TINYPY_PATCHES=$(TINYPY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TINYPY_CPPFLAGS=
TINYPY_LDFLAGS=

#
# TINYPY_BUILD_DIR is the directory in which the build is done.
# TINYPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TINYPY_IPK_DIR is the directory in which the ipk is built.
# TINYPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TINYPY_BUILD_DIR=$(BUILD_DIR)/tinypy
TINYPY_SOURCE_DIR=$(SOURCE_DIR)/tinypy
TINYPY_IPK_DIR=$(BUILD_DIR)/tinypy-$(TINYPY_VERSION)-ipk
TINYPY_IPK=$(BUILD_DIR)/tinypy_$(TINYPY_VERSION)-$(TINYPY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tinypy-source tinypy-unpack tinypy tinypy-stage tinypy-ipk tinypy-clean tinypy-dirclean tinypy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TINYPY_SOURCE):
	$(WGET) -P $(@D) $(TINYPY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tinypy-source: $(DL_DIR)/$(TINYPY_SOURCE) $(TINYPY_PATCHES)

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
$(TINYPY_BUILD_DIR)/.configured: $(DL_DIR)/$(TINYPY_SOURCE) $(TINYPY_PATCHES) make/tinypy.mk
	rm -rf $(BUILD_DIR)/$(TINYPY_DIR) $(@D)
	$(TINYPY_UNZIP) $(DL_DIR)/$(TINYPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TINYPY_PATCHES)" ; \
		then cat $(TINYPY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TINYPY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TINYPY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TINYPY_DIR) $(@D) ; \
	fi
	sed -i.orig \
	    -e '/do_cmd/s|gcc |$(TARGET_CC) |' \
	    -e 's|-std=c89|-std=c99|' \
	    $(@D)/setup.py
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
	    sed -i -e 's|-Wc++-compat||' $(@D)/setup.py; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TINYPY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TINYPY_LDFLAGS)" \
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

tinypy-unpack: $(TINYPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TINYPY_BUILD_DIR)/.built: $(TINYPY_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); python setup.py linux math
	touch $@

#
# This is the build convenience target.
#
tinypy: $(TINYPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TINYPY_BUILD_DIR)/.staged: $(TINYPY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tinypy-stage: $(TINYPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tinypy
#
$(TINYPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tinypy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TINYPY_PRIORITY)" >>$@
	@echo "Section: $(TINYPY_SECTION)" >>$@
	@echo "Version: $(TINYPY_VERSION)-$(TINYPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TINYPY_MAINTAINER)" >>$@
	@echo "Source: $(TINYPY_SITE)/$(TINYPY_SOURCE)" >>$@
	@echo "Description: $(TINYPY_DESCRIPTION)" >>$@
	@echo "Depends: $(TINYPY_DEPENDS)" >>$@
	@echo "Suggests: $(TINYPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(TINYPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TINYPY_IPK_DIR)/opt/sbin or $(TINYPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TINYPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TINYPY_IPK_DIR)/opt/etc/tinypy/...
# Documentation files should be installed in $(TINYPY_IPK_DIR)/opt/doc/tinypy/...
# Daemon startup scripts should be installed in $(TINYPY_IPK_DIR)/opt/etc/init.d/S??tinypy
#
# You may need to patch your application to make it use these locations.
#
$(TINYPY_IPK): $(TINYPY_BUILD_DIR)/.built
	rm -rf $(TINYPY_IPK_DIR) $(BUILD_DIR)/tinypy_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(TINYPY_BUILD_DIR) DESTDIR=$(TINYPY_IPK_DIR) install-strip
	install -d $(TINYPY_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(TINYPY_BUILD_DIR)/build/tinypy -o $(TINYPY_IPK_DIR)/opt/bin/tinypy
	$(MAKE) $(TINYPY_IPK_DIR)/CONTROL/control
	echo $(TINYPY_CONFFILES) | sed -e 's/ /\n/g' > $(TINYPY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TINYPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tinypy-ipk: $(TINYPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tinypy-clean:
	rm -f $(TINYPY_BUILD_DIR)/.built
	-$(MAKE) -C $(TINYPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tinypy-dirclean:
	rm -rf $(BUILD_DIR)/$(TINYPY_DIR) $(TINYPY_BUILD_DIR) $(TINYPY_IPK_DIR) $(TINYPY_IPK)
#
#
# Some sanity check for the package.
#
tinypy-check: $(TINYPY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TINYPY_IPK)
