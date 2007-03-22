###########################################################
#
# file
#
###########################################################

# You must replace "file" and "FILE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# FILE_VERSION, FILE_SITE and FILE_SOURCE define
# the upstream location of the source code for the package.
# FILE_DIR is the directory which is created when the source
# archive is unpacked.
# FILE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
FILE_SITE=ftp://ftp.astron.com/pub/file
FILE_VERSION=4.20
FILE_SOURCE=file-$(FILE_VERSION).tar.gz
FILE_DIR=file-$(FILE_VERSION)
FILE_UNZIP=zcat
FILE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FILE_DESCRIPTION=Ubiquitous file identification utility.
FILE_SECTION=utility
FILE_PRIORITY=optional
FILE_DEPENDS=zlib
FILE_CONFLICTS=

#
# FILE_IPK_VERSION should be incremented when the ipk changes.
#
FILE_IPK_VERSION=1

#
# FILE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FILE_PATCHES=$(FILE_SOURCE_DIR)/REG_STARTEND.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FILE_CPPFLAGS=
FILE_LDFLAGS=

#
# FILE_BUILD_DIR is the directory in which the build is done.
# FILE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FILE_IPK_DIR is the directory in which the ipk is built.
# FILE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FILE_BUILD_DIR=$(BUILD_DIR)/file
FILE_SOURCE_DIR=$(SOURCE_DIR)/file
FILE_IPK_DIR=$(BUILD_DIR)/file-$(FILE_VERSION)-ipk
FILE_IPK=$(BUILD_DIR)/file_$(FILE_VERSION)-$(FILE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: file-source file-unpack file file-stage file-ipk file-clean file-dirclean file-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FILE_SOURCE):
	$(WGET) -P $(DL_DIR) $(FILE_SITE)/$(FILE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
file-source: $(DL_DIR)/$(FILE_SOURCE) $(FILE_PATCHES)

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
$(FILE_BUILD_DIR)/.configured: $(DL_DIR)/$(FILE_SOURCE) $(FILE_PATCHES)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(FILE_DIR) $(FILE_BUILD_DIR)
	$(FILE_UNZIP) $(DL_DIR)/$(FILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FILE_PATCHES)"; \
		then cat $(FILE_PATCHES) | patch -d $(BUILD_DIR)/$(FILE_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(FILE_DIR) $(FILE_BUILD_DIR)
	(cd $(FILE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FILE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FILE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(FILE_BUILD_DIR)/libtool
	touch $@

file-unpack: $(FILE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(FILE_BUILD_DIR)/.built: $(FILE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(FILE_BUILD_DIR) SUBDIRS=src
	$(MAKE) -C $(FILE_BUILD_DIR)/magic pkgdata_DATA="magic magic.mime"
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
file: $(FILE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FILE_BUILD_DIR)/.staged: $(FILE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) SUBDIRS=src install
	$(MAKE) -C $(FILE_BUILD_DIR)/magic DESTDIR=$(STAGING_DIR) pkgdata_DATA="magic magic.mime" install
	touch $@

file-stage: $(FILE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/file
#
$(FILE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: file" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FILE_PRIORITY)" >>$@
	@echo "Section: $(FILE_SECTION)" >>$@
	@echo "Version: $(FILE_VERSION)-$(FILE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FILE_MAINTAINER)" >>$@
	@echo "Source: $(FILE_SITE)/$(FILE_SOURCE)" >>$@
	@echo "Description: $(FILE_DESCRIPTION)" >>$@
	@echo "Depends: $(FILE_DEPENDS)" >>$@
	@echo "Conflicts: $(FILE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FILE_IPK_DIR)/opt/sbin or $(FILE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FILE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FILE_IPK_DIR)/opt/etc/file/...
# Documentation files should be installed in $(FILE_IPK_DIR)/opt/doc/file/...
# Daemon startup scripts should be installed in $(FILE_IPK_DIR)/opt/etc/init.d/S??file
#
# You may need to patch your application to make it use these locations.
#
$(FILE_IPK): $(FILE_BUILD_DIR)/.built
	rm -rf $(FILE_IPK_DIR) $(BUILD_DIR)/file_*_$(TARGET_ARCH).ipk
	install -d $(FILE_IPK_DIR)/opt/bin
	$(MAKE) -C $(FILE_BUILD_DIR) DESTDIR=$(FILE_IPK_DIR) SUBDIRS=src install-strip
	$(MAKE) -C $(FILE_BUILD_DIR)/magic DESTDIR=$(FILE_IPK_DIR) pkgdata_DATA="magic magic.mime" install-strip
	$(MAKE) $(FILE_IPK_DIR)/CONTROL/control
	install -m 644 $(FILE_SOURCE_DIR)/postinst $(FILE_IPK_DIR)/CONTROL/postinst
	install -m 644 $(FILE_SOURCE_DIR)/prerm $(FILE_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FILE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
file-ipk: $(FILE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
file-clean:
	-$(MAKE) -C $(FILE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
file-dirclean:
	rm -rf $(BUILD_DIR)/$(FILE_DIR) $(FILE_BUILD_DIR) $(FILE_IPK_DIR) $(FILE_IPK)

#
# Some sanity check for the package.
#
file-check: $(FILE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FILE_IPK)
