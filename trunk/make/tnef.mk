###########################################################
#
# tnef
#
###########################################################

TNEF_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tnef
TNEF_VERSION=1.4.2
TNEF_SOURCE=tnef-$(TNEF_VERSION).tar.gz
TNEF_DIR=tnef-$(TNEF_VERSION)
TNEF_UNZIP=zcat
TNEF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TNEF_DESCRIPTION=TNEF is a program for unpacking ms-tnef type MIME attachments
TNEF_SECTION=apps
TNEF_PRIORITY=optional
TNEF_DEPENDS=
TNEF_SUGGESTS=
TNEF_CONFLICTS=

#
# TNEF_IPK_VERSION should be incremented when the ipk changes.
#
TNEF_IPK_VERSION=1

#
# TNEF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TNEF_PATCHES=$(TNEF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TNEF_CPPFLAGS=
TNEF_LDFLAGS=

#
# TNEF_BUILD_DIR is the directory in which the build is done.
# TNEF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TNEF_IPK_DIR is the directory in which the ipk is built.
# TNEF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TNEF_BUILD_DIR=$(BUILD_DIR)/tnef
TNEF_SOURCE_DIR=$(SOURCE_DIR)/tnef
TNEF_IPK_DIR=$(BUILD_DIR)/tnef-$(TNEF_VERSION)-ipk
TNEF_IPK=$(BUILD_DIR)/tnef_$(TNEF_VERSION)-$(TNEF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TNEF_SOURCE):
	$(WGET) -P $(DL_DIR) $(TNEF_SITE)/$(TNEF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tnef-source: $(DL_DIR)/$(TNEF_SOURCE) $(TNEF_PATCHES)

$(TNEF_BUILD_DIR)/.configured: $(DL_DIR)/$(TNEF_SOURCE) $(TNEF_PATCHES) make/tnef.mk
	rm -rf $(BUILD_DIR)/$(TNEF_DIR) $(TNEF_BUILD_DIR)
	$(TNEF_UNZIP) $(DL_DIR)/$(TNEF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TNEF_PATCHES)" ; \
		then cat $(TNEF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TNEF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TNEF_DIR)" != "$(TNEF_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TNEF_DIR) $(TNEF_BUILD_DIR) ; \
	fi
	(cd $(TNEF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TNEF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TNEF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(TNEF_BUILD_DIR)/.configured

tnef-unpack: $(TNEF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TNEF_BUILD_DIR)/.built: $(TNEF_BUILD_DIR)/.configured
	rm -f $(TNEF_BUILD_DIR)/.built
	$(MAKE) -C $(TNEF_BUILD_DIR)
	touch $(TNEF_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tnef: $(TNEF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TNEF_BUILD_DIR)/.staged: $(TNEF_BUILD_DIR)/.built
	rm -f $(TNEF_BUILD_DIR)/.staged
	$(MAKE) -C $(TNEF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TNEF_BUILD_DIR)/.staged

tnef-stage: $(TNEF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tnef
#
$(TNEF_IPK_DIR)/CONTROL/control:
	@install -d $(TNEF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tnef" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TNEF_PRIORITY)" >>$@
	@echo "Section: $(TNEF_SECTION)" >>$@
	@echo "Version: $(TNEF_VERSION)-$(TNEF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TNEF_MAINTAINER)" >>$@
	@echo "Source: $(TNEF_SITE)/$(TNEF_SOURCE)" >>$@
	@echo "Description: $(TNEF_DESCRIPTION)" >>$@
	@echo "Depends: $(TNEF_DEPENDS)" >>$@
	@echo "Suggests: $(TNEF_SUGGESTS)" >>$@
	@echo "Conflicts: $(TNEF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TNEF_IPK_DIR)/opt/sbin or $(TNEF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TNEF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TNEF_IPK_DIR)/opt/etc/tnef/...
# Documentation files should be installed in $(TNEF_IPK_DIR)/opt/doc/tnef/...
# Daemon startup scripts should be installed in $(TNEF_IPK_DIR)/opt/etc/init.d/S??tnef
#
# You may need to patch your application to make it use these locations.
#
$(TNEF_IPK): $(TNEF_BUILD_DIR)/.built
	rm -rf $(TNEF_IPK_DIR) $(BUILD_DIR)/tnef_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TNEF_BUILD_DIR) DESTDIR=$(TNEF_IPK_DIR) install-strip
	$(MAKE) $(TNEF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TNEF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tnef-ipk: $(TNEF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tnef-clean:
	rm -f $(TNEF_BUILD_DIR)/.built
	-$(MAKE) -C $(TNEF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tnef-dirclean:
	rm -rf $(BUILD_DIR)/$(TNEF_DIR) $(TNEF_BUILD_DIR) $(TNEF_IPK_DIR) $(TNEF_IPK)
