###########################################################
#
# indent
#
###########################################################
#
# INDENT_VERSION, INDENT_SITE and INDENT_SOURCE define
# the upstream location of the source code for the package.
# INDENT_DIR is the directory which is created when the source
# archive is unpacked.
# INDENT_UNZIP is the command used to unzip the source.
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
INDENT_SITE=ftp://ftp.gnu.org/pub/gnu/indent
INDENT_VERSION=2.2.9
INDENT_SOURCE=indent-$(INDENT_VERSION).tar.gz
INDENT_DIR=indent-$(INDENT_VERSION)
INDENT_UNZIP=zcat
INDENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INDENT_DESCRIPTION=A program to make code easier to read, can also be used for C coding style conversion.
INDENT_SECTION=misc
INDENT_PRIORITY=optional
INDENT_DEPENDS=
INDENT_SUGGESTS=
INDENT_CONFLICTS=

#
# INDENT_IPK_VERSION should be incremented when the ipk changes.
#
INDENT_IPK_VERSION=2

#
# INDENT_CONFFILES should be a list of user-editable files
#INDENT_CONFFILES=/opt/etc/indent.conf /opt/etc/init.d/SXXindent

#
# INDENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
INDENT_PATCHES=$(INDENT_SOURCE_DIR)/output.c.path

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INDENT_CPPFLAGS=
INDENT_LDFLAGS=

#
# INDENT_BUILD_DIR is the directory in which the build is done.
# INDENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INDENT_IPK_DIR is the directory in which the ipk is built.
# INDENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INDENT_BUILD_DIR=$(BUILD_DIR)/indent
INDENT_SOURCE_DIR=$(SOURCE_DIR)/indent
INDENT_IPK_DIR=$(BUILD_DIR)/indent-$(INDENT_VERSION)-ipk
INDENT_IPK=$(BUILD_DIR)/indent_$(INDENT_VERSION)-$(INDENT_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(HOSTCC), $(TARGET_CC))
INDENT_CROSS_CONFIGURE_ENV=ac_cv_func_mmap_fixed_mapped=yes gt_cv_int_divbyzero_sigfpe=yes
endif

.PHONY: indent-source indent-unpack indent indent-stage indent-ipk indent-clean indent-dirclean indent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INDENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(INDENT_SITE)/$(INDENT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
indent-source: $(DL_DIR)/$(INDENT_SOURCE) $(INDENT_PATCHES)

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
$(INDENT_BUILD_DIR)/.configured: $(DL_DIR)/$(INDENT_SOURCE) $(INDENT_PATCHES) make/indent.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(INDENT_DIR) $(INDENT_BUILD_DIR)
	$(INDENT_UNZIP) $(DL_DIR)/$(INDENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(INDENT_PATCHES)" ; \
		then cat $(INDENT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INDENT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(INDENT_DIR)" != "$(INDENT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(INDENT_DIR) $(INDENT_BUILD_DIR) ; \
	fi
	(cd $(INDENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INDENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INDENT_LDFLAGS)" \
		$(INDENT_CROSS_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(INDENT_BUILD_DIR)/libtool
	touch $(INDENT_BUILD_DIR)/.configured

indent-unpack: $(INDENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INDENT_BUILD_DIR)/.built: $(INDENT_BUILD_DIR)/.configured
	rm -f $(INDENT_BUILD_DIR)/.built
	$(MAKE) -C $(INDENT_BUILD_DIR)
	touch $(INDENT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
indent: $(INDENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(INDENT_BUILD_DIR)/.staged: $(INDENT_BUILD_DIR)/.built
	rm -f $(INDENT_BUILD_DIR)/.staged
	$(MAKE) -C $(INDENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(INDENT_BUILD_DIR)/.staged

indent-stage: $(INDENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/indent
#
$(INDENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: indent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INDENT_PRIORITY)" >>$@
	@echo "Section: $(INDENT_SECTION)" >>$@
	@echo "Version: $(INDENT_VERSION)-$(INDENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INDENT_MAINTAINER)" >>$@
	@echo "Source: $(INDENT_SITE)/$(INDENT_SOURCE)" >>$@
	@echo "Description: $(INDENT_DESCRIPTION)" >>$@
	@echo "Depends: $(INDENT_DEPENDS)" >>$@
	@echo "Suggests: $(INDENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(INDENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INDENT_IPK_DIR)/opt/sbin or $(INDENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INDENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INDENT_IPK_DIR)/opt/etc/indent/...
# Documentation files should be installed in $(INDENT_IPK_DIR)/opt/doc/indent/...
# Daemon startup scripts should be installed in $(INDENT_IPK_DIR)/opt/etc/init.d/S??indent
#
# You may need to patch your application to make it use these locations.
#
$(INDENT_IPK): $(INDENT_BUILD_DIR)/.built
	rm -rf $(INDENT_IPK_DIR) $(BUILD_DIR)/indent_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(INDENT_BUILD_DIR) DESTDIR=$(INDENT_IPK_DIR) install-strip
	rm -f $(INDENT_IPK_DIR)/opt/info/dir $(INDENT_IPK_DIR)/opt/info/dir.old
	$(MAKE) $(INDENT_IPK_DIR)/CONTROL/control
#	echo $(INDENT_CONFFILES) | sed -e 's/ /\n/g' > $(INDENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INDENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
indent-ipk: $(INDENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
indent-clean:
	rm -f $(INDENT_BUILD_DIR)/.built
	-$(MAKE) -C $(INDENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
indent-dirclean:
	rm -rf $(BUILD_DIR)/$(INDENT_DIR) $(INDENT_BUILD_DIR) $(INDENT_IPK_DIR) $(INDENT_IPK)
#
#
# Some sanity check for the package.
#
indent-check: $(INDENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(INDENT_IPK)
