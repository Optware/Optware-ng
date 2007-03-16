###########################################################
#
# libmad
#
###########################################################

# You must replace "libmad" and "LIBMAD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBMAD_VERSION, LIBMAD_SITE and LIBMAD_SOURCE define
# the upstream location of the source code for the package.
# LIBMAD_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMAD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBMAD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mad
LIBMAD_VERSION=0.15.1b
LIBMAD_SOURCE=libmad-$(LIBMAD_VERSION).tar.gz
LIBMAD_DIR=libmad-$(LIBMAD_VERSION)
LIBMAD_UNZIP=zcat
LIBMAD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMAD_DESCRIPTION=MPEG Audio Decoder library
LIBMAD_SECTION=lib
LIBMAD_PRIORITY=optional
LIBMAD_DEPENDS=
LIBMAD_SUGGESTS=
LIBMAD_CONFLICTS=

#
# LIBMAD_IPK_VERSION should be incremented when the ipk changes.
#
LIBMAD_IPK_VERSION=3

#
# LIBMAD_CONFFILES should be a list of user-editable files
LIBMAD_CONFFILES=

#
# LIBMAD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMAD_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMAD_CPPFLAGS=
LIBMAD_LDFLAGS=

#
# LIBMAD_BUILD_DIR is the directory in which the build is done.
# LIBMAD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMAD_IPK_DIR is the directory in which the ipk is built.
# LIBMAD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMAD_BUILD_DIR=$(BUILD_DIR)/libmad
LIBMAD_SOURCE_DIR=$(SOURCE_DIR)/libmad
LIBMAD_IPK_DIR=$(BUILD_DIR)/libmad-$(LIBMAD_VERSION)-ipk
LIBMAD_IPK=$(BUILD_DIR)/libmad_$(LIBMAD_VERSION)-$(LIBMAD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmad-source libmad-unpack libmad libmad-stage libmad-ipk libmad-clean libmad-dirclean libmad-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMAD_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMAD_SITE)/$(LIBMAD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmad-source: $(DL_DIR)/$(LIBMAD_SOURCE) $(LIBMAD_PATCHES)

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
$(LIBMAD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMAD_SOURCE) \
		$(LIBMAD_PATCHES) make/libmad.mk
	rm -rf $(BUILD_DIR)/$(LIBMAD_DIR) $(LIBMAD_BUILD_DIR)
	$(LIBMAD_UNZIP) $(DL_DIR)/$(LIBMAD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMAD_PATCHES)" ; \
		then cat $(LIBMAD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMAD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMAD_DIR)" != "$(LIBMAD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMAD_DIR) $(LIBMAD_BUILD_DIR) ; \
	fi
	(cd $(LIBMAD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMAD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMAD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMAD_BUILD_DIR)/libtool
	touch $(LIBMAD_BUILD_DIR)/.configured

libmad-unpack: $(LIBMAD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMAD_BUILD_DIR)/.built: $(LIBMAD_BUILD_DIR)/.configured
	rm -f $(LIBMAD_BUILD_DIR)/.built
	$(MAKE) -C $(LIBMAD_BUILD_DIR)
	touch $(LIBMAD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libmad: $(LIBMAD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMAD_BUILD_DIR)/.staged: $(LIBMAD_BUILD_DIR)/.built
	rm -f $(LIBMAD_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBMAD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmad.la
	touch $(LIBMAD_BUILD_DIR)/.staged

libmad-stage: $(LIBMAD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(LIBMAD_IPK_DIR)/CONTROL/control:
	@install -d $(LIBMAD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libmad" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMAD_PRIORITY)" >>$@
	@echo "Section: $(LIBMAD_SECTION)" >>$@
	@echo "Version: $(LIBMAD_VERSION)-$(LIBMAD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMAD_MAINTAINER)" >>$@
	@echo "Source: $(LIBMAD_SITE)/$(LIBMAD_SOURCE)" >>$@
	@echo "Description: $(LIBMAD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMAD_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMAD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMAD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(LIBMAD_IPK): $(LIBMAD_BUILD_DIR)/.built
	rm -rf $(LIBMAD_IPK_DIR) $(BUILD_DIR)/libmad_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMAD_BUILD_DIR) DESTDIR=$(LIBMAD_IPK_DIR) install-strip
	rm -f $(LIBMAD_IPK_DIR)/opt/lib/libmad.la
	$(MAKE) $(LIBMAD_IPK_DIR)/CONTROL/control
	echo $(LIBMAD_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMAD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMAD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmad-ipk: $(LIBMAD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmad-clean:
	-$(MAKE) -C $(LIBMAD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmad-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMAD_DIR) $(LIBMAD_BUILD_DIR) $(LIBMAD_IPK_DIR) $(LIBMAD_IPK)
#
#
# Some sanity check for the package.
#
libmad-check: $(LIBMAD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBMAD_IPK)

