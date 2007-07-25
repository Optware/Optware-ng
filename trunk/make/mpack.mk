###########################################################
#
# mpack
#
###########################################################
#
# MPACK_VERSION, MPACK_SITE and MPACK_SOURCE define
# the upstream location of the source code for the package.
# MPACK_DIR is the directory which is created when the source
# archive is unpacked.
# MPACK_UNZIP is the command used to unzip the source.
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
MPACK_SITE=http://ftp.andrew.cmu.edu/pub/mpack/
MPACK_VERSION=1.6
MPACK_SOURCE=mpack-$(MPACK_VERSION).tar.gz
MPACK_DIR=mpack-$(MPACK_VERSION)
MPACK_UNZIP=zcat
MPACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPACK_DESCRIPTION=Tools for encoding/decoding MIME messages.
MPACK_SECTION=misc
MPACK_PRIORITY=optional
MPACK_DEPENDS=
MPACK_SUGGESTS=
MPACK_CONFLICTS=

#
# MPACK_IPK_VERSION should be incremented when the ipk changes.
#
MPACK_IPK_VERSION=3

#
# MPACK_CONFFILES should be a list of user-editable files
#MPACK_CONFFILES=/opt/etc/mpack.conf /opt/etc/init.d/SXXmpack

#
# MPACK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MPACK_PATCHES=$(MPACK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPACK_CPPFLAGS=
MPACK_LDFLAGS=

#
# MPACK_BUILD_DIR is the directory in which the build is done.
# MPACK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPACK_IPK_DIR is the directory in which the ipk is built.
# MPACK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPACK_BUILD_DIR=$(BUILD_DIR)/mpack
MPACK_SOURCE_DIR=$(SOURCE_DIR)/mpack
MPACK_IPK_DIR=$(BUILD_DIR)/mpack-$(MPACK_VERSION)-ipk
MPACK_IPK=$(BUILD_DIR)/mpack_$(MPACK_VERSION)-$(MPACK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpack-source mpack-unpack mpack mpack-stage mpack-ipk mpack-clean mpack-dirclean mpack-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPACK_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPACK_SITE)/$(MPACK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpack-source: $(DL_DIR)/$(MPACK_SOURCE) $(MPACK_PATCHES)

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
$(MPACK_BUILD_DIR)/.configured: $(DL_DIR)/$(MPACK_SOURCE) $(MPACK_PATCHES) make/mpack.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MPACK_DIR) $(MPACK_BUILD_DIR)
	$(MPACK_UNZIP) $(DL_DIR)/$(MPACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPACK_PATCHES)" ; \
		then cat $(MPACK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPACK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPACK_DIR)" != "$(MPACK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPACK_DIR) $(MPACK_BUILD_DIR) ; \
	fi
	(cd $(MPACK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPACK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPACK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/\*malloc()/d; /\*getenv()/d' \
		$(MPACK_BUILD_DIR)/unixos.c $(MPACK_BUILD_DIR)/xmalloc.c
#	$(PATCH_LIBTOOL) $(MPACK_BUILD_DIR)/libtool
	touch $(MPACK_BUILD_DIR)/.configured

mpack-unpack: $(MPACK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPACK_BUILD_DIR)/.built: $(MPACK_BUILD_DIR)/.configured
	rm -f $(MPACK_BUILD_DIR)/.built
	$(MAKE) -C $(MPACK_BUILD_DIR)
	touch $(MPACK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mpack: $(MPACK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPACK_BUILD_DIR)/.staged: $(MPACK_BUILD_DIR)/.built
	rm -f $(MPACK_BUILD_DIR)/.staged
	$(MAKE) -C $(MPACK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MPACK_BUILD_DIR)/.staged

mpack-stage: $(MPACK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpack
#
$(MPACK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPACK_PRIORITY)" >>$@
	@echo "Section: $(MPACK_SECTION)" >>$@
	@echo "Version: $(MPACK_VERSION)-$(MPACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPACK_MAINTAINER)" >>$@
	@echo "Source: $(MPACK_SITE)/$(MPACK_SOURCE)" >>$@
	@echo "Description: $(MPACK_DESCRIPTION)" >>$@
	@echo "Depends: $(MPACK_DEPENDS)" >>$@
	@echo "Suggests: $(MPACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPACK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPACK_IPK_DIR)/opt/sbin or $(MPACK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPACK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPACK_IPK_DIR)/opt/etc/mpack/...
# Documentation files should be installed in $(MPACK_IPK_DIR)/opt/doc/mpack/...
# Daemon startup scripts should be installed in $(MPACK_IPK_DIR)/opt/etc/init.d/S??mpack
#
# You may need to patch your application to make it use these locations.
#
$(MPACK_IPK): $(MPACK_BUILD_DIR)/.built
	rm -rf $(MPACK_IPK_DIR) $(BUILD_DIR)/mpack_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPACK_BUILD_DIR) DESTDIR=$(MPACK_IPK_DIR) install
	$(STRIP_COMMAND) $(MPACK_IPK_DIR)/opt/bin/*
#	install -d $(MPACK_IPK_DIR)/opt/etc/
#	install -m 644 $(MPACK_SOURCE_DIR)/mpack.conf $(MPACK_IPK_DIR)/opt/etc/mpack.conf
#	install -d $(MPACK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MPACK_SOURCE_DIR)/rc.mpack $(MPACK_IPK_DIR)/opt/etc/init.d/SXXmpack
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXmpack
	$(MAKE) $(MPACK_IPK_DIR)/CONTROL/control
#	install -m 755 $(MPACK_SOURCE_DIR)/postinst $(MPACK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MPACK_SOURCE_DIR)/prerm $(MPACK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(MPACK_CONFFILES) | sed -e 's/ /\n/g' > $(MPACK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPACK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpack-ipk: $(MPACK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpack-clean:
	rm -f $(MPACK_BUILD_DIR)/.built
	-$(MAKE) -C $(MPACK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpack-dirclean:
	rm -rf $(BUILD_DIR)/$(MPACK_DIR) $(MPACK_BUILD_DIR) $(MPACK_IPK_DIR) $(MPACK_IPK)
#
#
# Some sanity check for the package.
#
mpack-check: $(MPACK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPACK_IPK)
