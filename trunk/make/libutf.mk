###########################################################
#
# libutf
#
###########################################################
#
# LIBUTF_VERSION, LIBUTF_SITE and LIBUTF_SOURCE define
# the upstream location of the source code for the package.
# LIBUTF_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUTF_UNZIP is the command used to unzip the source.
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
LIBUTF_SITE=http://www.westley.demon.co.uk/src
LIBUTF_VERSION=2.10
LIBUTF_SOURCE=libutf-$(LIBUTF_VERSION).tar.gz
LIBUTF_DIR=libutf-$(LIBUTF_VERSION)
LIBUTF_UNZIP=zcat
LIBUTF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUTF_DESCRIPTION=A library of UTF and Unicode routines, including UTF-aware regular expression functionality.
LIBUTF_SECTION=lib
LIBUTF_PRIORITY=optional
LIBUTF_DEPENDS=
LIBUTF_SUGGESTS=
LIBUTF_CONFLICTS=

#
# LIBUTF_IPK_VERSION should be incremented when the ipk changes.
#
LIBUTF_IPK_VERSION=1

#
# LIBUTF_CONFFILES should be a list of user-editable files
#LIBUTF_CONFFILES=/opt/etc/libutf.conf /opt/etc/init.d/SXXlibutf

#
# LIBUTF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBUTF_PATCHES=$(LIBUTF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUTF_CPPFLAGS=
LIBUTF_LDFLAGS=

#
# LIBUTF_BUILD_DIR is the directory in which the build is done.
# LIBUTF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUTF_IPK_DIR is the directory in which the ipk is built.
# LIBUTF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUTF_BUILD_DIR=$(BUILD_DIR)/libutf
LIBUTF_SOURCE_DIR=$(SOURCE_DIR)/libutf
LIBUTF_IPK_DIR=$(BUILD_DIR)/libutf-$(LIBUTF_VERSION)-ipk
LIBUTF_IPK=$(BUILD_DIR)/libutf_$(LIBUTF_VERSION)-$(LIBUTF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libutf-source libutf-unpack libutf libutf-stage libutf-ipk libutf-clean libutf-dirclean libutf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUTF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBUTF_SITE)/$(LIBUTF_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBUTF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libutf-source: $(DL_DIR)/$(LIBUTF_SOURCE) $(LIBUTF_PATCHES)

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
$(LIBUTF_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUTF_SOURCE) $(LIBUTF_PATCHES) make/libutf.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUTF_DIR) $(@D)
	$(LIBUTF_UNZIP) $(DL_DIR)/$(LIBUTF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUTF_PATCHES)" ; \
		then cat $(LIBUTF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBUTF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUTF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUTF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUTF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUTF_LDFLAGS)" \
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

libutf-unpack: $(LIBUTF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUTF_BUILD_DIR)/.built: $(LIBUTF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libutf: $(LIBUTF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUTF_BUILD_DIR)/.staged: $(LIBUTF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) prefix=$(STAGING_DIR)/opt install
	touch $@

libutf-stage: $(LIBUTF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libutf
#
$(LIBUTF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libutf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUTF_PRIORITY)" >>$@
	@echo "Section: $(LIBUTF_SECTION)" >>$@
	@echo "Version: $(LIBUTF_VERSION)-$(LIBUTF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUTF_MAINTAINER)" >>$@
	@echo "Source: $(LIBUTF_SITE)/$(LIBUTF_SOURCE)" >>$@
	@echo "Description: $(LIBUTF_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUTF_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUTF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUTF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUTF_IPK_DIR)/opt/sbin or $(LIBUTF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUTF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBUTF_IPK_DIR)/opt/etc/libutf/...
# Documentation files should be installed in $(LIBUTF_IPK_DIR)/opt/doc/libutf/...
# Daemon startup scripts should be installed in $(LIBUTF_IPK_DIR)/opt/etc/init.d/S??libutf
#
# You may need to patch your application to make it use these locations.
#
$(LIBUTF_IPK): $(LIBUTF_BUILD_DIR)/.built
	rm -rf $(LIBUTF_IPK_DIR) $(BUILD_DIR)/libutf_*_$(TARGET_ARCH).ipk
	$(MAKE) $(LIBUTF_IPK_DIR)/CONTROL/control
	echo $(LIBUTF_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUTF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUTF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
#libutf-ipk: $(LIBUTF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libutf-clean:
	rm -f $(LIBUTF_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUTF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libutf-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUTF_DIR) $(LIBUTF_BUILD_DIR) $(LIBUTF_IPK_DIR) $(LIBUTF_IPK)
#
#
# Some sanity check for the package.
#
libutf-check: $(LIBUTF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBUTF_IPK)
