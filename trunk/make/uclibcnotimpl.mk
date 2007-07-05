###########################################################
#
# uclibcnotimpl
#
###########################################################
#
# uclibcnotimpl_VERSION, uclibcnotimpl_SITE and uclibcnotimpl_SOURCE define
# the upstream location of the source code for the package.
# uclibcnotimpl_DIR is the directory which is created when the source
# archive is unpacked.
# uclibcnotimpl_UNZIP is the command used to unzip the source.
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

UCLIBCNOTIMPL_VERSION=0.9.28
UCLIBCNOTIMPL_SOURCE=uclibcnotimpl-$(UCLIBCNOTIMPL_VERSION).tar.gz
UCLIBCNOTIMPL_DIR=uclibcnotimpl-$(UCLIBCNOTIMPL_VERSION)
UCLIBCNOTIMPL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UCLIBCNOTIMPL_DESCRIPTION=Not implemented uClibc routines.
UCLIBCNOTIMPL_SECTION=libs
UCLIBCNOTIMPL_PRIORITY=optional
UCLIBCNOTIMPL_DEPENDS=
UCLIBCNOTIMPL_SUGGESTS=
UCLIBCNOTIMPL_CONFLICTS=

#
# UCLIBCNOTIMPL_IPK_VERSION should be incremented when the ipk changes.
#
UCLIBCNOTIMPL_IPK_VERSION=1

#
# UCLIBCNOTIMPL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UCLIBCNOTIMPL_PATCHES=$(UCLIBCNOTIMPL_SOURCE_DIR)/math.c

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UCLIBCNOTIMPL_CPPFLAGS=
UCLIBCNOTIMPL_LDFLAGS=

#
# UCLIBCNOTIMPL_BUILD_DIR is the directory in which the build is done.
# UCLIBCNOTIMPL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UCLIBCNOTIMPL_IPK_DIR is the directory in which the ipk is built.
# UCLIBCNOTIMPL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UCLIBCNOTIMPL_BUILD_DIR=$(BUILD_DIR)/uclibcnotimpl
UCLIBCNOTIMPL_SOURCE_DIR=$(SOURCE_DIR)/uclibcnotimpl
UCLIBCNOTIMPL_IPK_DIR=$(BUILD_DIR)/uclibcnotimpl-$(UCLIBCNOTIMPL_VERSION)-ipk
UCLIBCNOTIMPL_IPK=$(BUILD_DIR)/UCLIBCNOTIMPL_$(UCLIBCNOTIMPL_VERSION)-$(UCLIBCNOTIMPL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: uclibcnotimpl-source uclibcnotimpl-unpack uclibcnotimpl uclibcnotimpl-stage uclibcnotimpl-ipk uclibcnotimpl-clean uclibcnotimpl-dirclean uclibcnotimpl-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
uclibcnotimpl-source: $(UCLIBCNOTIMPL_PATCHES)

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
$(UCLIBCNOTIMPL_BUILD_DIR)/.configured: $(UCLIBCNOTIMPL_PATCHES) make/uclibcnotimpl.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UCLIBCNOTIMPL_DIR) $(UCLIBCNOTIMPL_BUILD_DIR)
	install -d  $(UCLIBCNOTIMPL_BUILD_DIR)
	if test -n "$(UCLIBCNOTIMPL_PATCHES)" ; \
	   then cp $(UCLIBCNOTIMPL_PATCHES) $(UCLIBCNOTIMPL_BUILD_DIR) ; \
	fi
	touch $@

uclibcnotimpl-unpack: $(UCLIBCNOTIMPL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UCLIBCNOTIMPL_BUILD_DIR)/.built: $(UCLIBCNOTIMPL_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CC) $(TARGET_CFLAGS) -Wall \
		-c $(UCLIBCNOTIMPL_BUILD_DIR)/math.c -o \
		$(UCLIBCNOTIMPL_BUILD_DIR)/math.o

	$(TARGET_CROSS)ar rc $(UCLIBCNOTIMPL_BUILD_DIR)/libuclibcnotimpl.a \
		$(UCLIBCNOTIMPL_BUILD_DIR)/*.o
#	$(MAKE) -C $(UCLIBCNOTIMPL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
uclibcnotimpl: $(UCLIBCNOTIMPL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UCLIBCNOTIMPL_BUILD_DIR)/.staged: $(UCLIBCNOTIMPL_BUILD_DIR)/.built
	rm -f $@
	install -m 644 $(UCLIBCNOTIMPL_BUILD_DIR)/libuclibcnotimpl.a \
		$(STAGING_LIB_DIR)
	touch $@

uclibcnotimpl-stage: $(UCLIBCNOTIMPL_BUILD_DIR)/.staged
uclibcnotimpl-toolchain: $(UCLIBCNOTIMPL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/uclibcnotimpl
#
$(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: uclibcnotimpl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UCLIBCNOTIMPL_PRIORITY)" >>$@
	@echo "Section: $(UCLIBCNOTIMPL_SECTION)" >>$@
	@echo "Version: $(UCLIBCNOTIMPL_VERSION)-$(UCLIBCNOTIMPL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UCLIBCNOTIMPL_MAINTAINER)" >>$@
	@echo "Source: $(UCLIBCNOTIMPL_SITE)/$(UCLIBCNOTIMPL_SOURCE)" >>$@
	@echo "Description: $(UCLIBCNOTIMPL_DESCRIPTION)" >>$@
	@echo "Depends: $(UCLIBCNOTIMPL_DEPENDS)" >>$@
	@echo "Suggests: $(UCLIBCNOTIMPL_SUGGESTS)" >>$@
	@echo "Conflicts: $(UCLIBCNOTIMPL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UCLIBCNOTIMPL_IPK_DIR)/opt/sbin or $(UCLIBCNOTIMPL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UCLIBCNOTIMPL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/uclibcnotimpl/...
# Documentation files should be installed in $(UCLIBCNOTIMPL_IPK_DIR)/opt/doc/uclibcnotimpl/...
# Daemon startup scripts should be installed in $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/init.d/S??uclibcnotimpl
#
# You may need to patch your application to make it use these locations.
#
$(UCLIBCNOTIMPL_IPK): $(UCLIBCNOTIMPL_BUILD_DIR)/.built
	rm -rf $(UCLIBCNOTIMPL_IPK_DIR) $(BUILD_DIR)/UCLIBCNOTIMPL_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(UCLIBCNOTIMPL_BUILD_DIR) DESTDIR=$(UCLIBCNOTIMPL_IPK_DIR) install-strip
	install -d $(UCLIBCNOTIMPL_IPK_DIR)/opt/lib
	install -m 644  $(UCLIBCNOTIMPL_BUILD_DIR)/libuclibcnotimpl.a \
		$(UCLIBCNOTIMPL_IPK_DIR)/opt/lib/
#	install -m 644 $(UCLIBCNOTIMPL_SOURCE_DIR)/uclibcnotimpl.conf $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/uclibcnotimpl.conf
#	install -d $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UCLIBCNOTIMPL_SOURCE_DIR)/rc.uclibcnotimpl $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/init.d/SXXuclibcnotimpl
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCLIBCNOTIMPL_IPK_DIR)/opt/etc/init.d/SXXuclibcnotimpl
	$(MAKE) $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/control
#	install -m 755 $(UCLIBCNOTIMPL_SOURCE_DIR)/postinst $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UCLIBCNOTIMPL_SOURCE_DIR)/prerm $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/prerm
#	echo $(UCLIBCNOTIMPL_CONFFILES) | sed -e 's/ /\n/g' > $(UCLIBCNOTIMPL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UCLIBCNOTIMPL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
uclibcnotimpl-ipk: $(UCLIBCNOTIMPL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
uclibcnotimpl-clean:
	rm -f $(UCLIBCNOTIMPL_BUILD_DIR)/.built
	-$(MAKE) -C $(UCLIBCNOTIMPL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
uclibcnotimpl-dirclean:
	rm -rf $(BUILD_DIR)/$(UCLIBCNOTIMPL_DIR) $(UCLIBCNOTIMPL_BUILD_DIR) $(UCLIBCNOTIMPL_IPK_DIR) $(UCLIBCNOTIMPL_IPK)
#
#
# Some sanity check for the package.
#
uclibcnotimpl-check: $(UCLIBCNOTIMPL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UCLIBCNOTIMPL_IPK)
