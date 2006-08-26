###########################################################
#
# lha
#
###########################################################

LHA_SITE=http://www2m.biglobe.ne.jp/~dolphin/lha/prog
LHA_VERSION=114i
LHA_SOURCE=lha-$(LHA_VERSION).tar.gz
LHA_DIR=lha-$(LHA_VERSION)
LHA_UNZIP=zcat
LHA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LHA_DESCRIPTION=lha - File archiving utility with compression
LHA_SECTION=apps
LHA_PRIORITY=optional
LHA_DEPENDS=
LHA_SUGGESTS=
LHA_CONFLICTS=

#
# LHA_IPK_VERSION should be incremented when the ipk changes.
#
LHA_IPK_VERSION=1

#
# LHA_CONFFILES should be a list of user-editable files

#
# LHA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LHA_PATCHES= $(LHA_SOURCE_DIR)/lha-114i-symlink.patch \
  $(LHA_SOURCE_DIR)/lha-114i-malloc.patch \
  $(LHA_SOURCE_DIR)/lha-114i-sec.patch \
  $(LHA_SOURCE_DIR)/lha-dir_length_bounds_check.patch \
  $(LHA_SOURCE_DIR)/lha-114i-sec2.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LHA_CPPFLAGS=
LHA_LDFLAGS=

#
# LHA_BUILD_DIR is the directory in which the build is done.
# LHA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LHA_IPK_DIR is the directory in which the ipk is built.
# LHA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LHA_BUILD_DIR=$(BUILD_DIR)/lha
LHA_SOURCE_DIR=$(SOURCE_DIR)/lha
LHA_IPK_DIR=$(BUILD_DIR)/lha-$(LHA_VERSION)-ipk
LHA_IPK=$(BUILD_DIR)/lha_$(LHA_VERSION)-$(LHA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LHA_SOURCE):
	$(WGET) -P $(DL_DIR) $(LHA_SITE)/$(LHA_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lha-source: $(DL_DIR)/$(LHA_SOURCE) $(LHA_PATCHES)

$(LHA_BUILD_DIR)/.configured: $(DL_DIR)/$(LHA_SOURCE) $(LHA_PATCHES) make/lha.mk
	rm -rf $(BUILD_DIR)/$(LHA_DIR) $(LHA_BUILD_DIR)
	$(LHA_UNZIP) $(DL_DIR)/$(LHA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LHA_PATCHES)" ; \
		then cat $(LHA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LHA_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LHA_DIR)" != "$(LHA_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LHA_DIR) $(LHA_BUILD_DIR) ; \
	fi
	touch $(LHA_BUILD_DIR)/.configured

lha-unpack: $(LHA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LHA_BUILD_DIR)/.built: $(LHA_BUILD_DIR)/.configured
	rm -f $(LHA_BUILD_DIR)/.built
	$(MAKE) -C $(LHA_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS)
	touch $(LHA_BUILD_DIR)/.built

#
# This is the build convenience target.
#
lha: $(LHA_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lha
#
$(LHA_IPK_DIR)/CONTROL/control:
	@install -d $(LHA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lha" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LHA_PRIORITY)" >>$@
	@echo "Section: $(LHA_SECTION)" >>$@
	@echo "Version: $(LHA_VERSION)-$(LHA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LHA_MAINTAINER)" >>$@
	@echo "Source: $(LHA_SITE)/$(LHA_SOURCE)" >>$@
	@echo "Description: $(LHA_DESCRIPTION)" >>$@
	@echo "Depends: $(LHA_DEPENDS)" >>$@
	@echo "Suggests: $(LHA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LHA_CONFLICTS)" >>$@

$(LHA_IPK): $(LHA_BUILD_DIR)/.built
	rm -rf $(LHA_IPK_DIR) $(BUILD_DIR)/lha_*_$(TARGET_ARCH).ipk
	install -d $(LHA_IPK_DIR)/opt/bin
	install -m 755 $(LHA_BUILD_DIR)/src/lha $(LHA_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(LHA_IPK_DIR)/opt/bin/lha
	$(MAKE) $(LHA_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LHA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lha-ipk: $(LHA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lha-clean:
	rm -f $(LHA_BUILD_DIR)/.built
	-$(MAKE) -C $(LHA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lha-dirclean:
	rm -rf $(BUILD_DIR)/$(LHA_DIR) $(LHA_BUILD_DIR) $(LHA_IPK_DIR) $(LHA_IPK)
