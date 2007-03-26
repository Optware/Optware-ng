###########################################################
#
# unarj
#
###########################################################

UNARJ_SITE=ftp://ftp.freebsd.org/pub/FreeBSD/ports/local-distfiles/ache
UNARJ_VERSION=2.65
UNARJ_SOURCE=unarj-$(UNARJ_VERSION).tgz
UNARJ_DIR=unarj-$(UNARJ_VERSION)
UNARJ_UNZIP=zcat
UNARJ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNARJ_DESCRIPTION=unarj - An uncompressor for .arj format archive files
UNARJ_SECTION=apps
UNARJ_PRIORITY=optional
UNARJ_DEPENDS=
UNARJ_SUGGESTS=
UNARJ_CONFLICTS=

#
# UNARJ_IPK_VERSION should be incremented when the ipk changes.
#
UNARJ_IPK_VERSION=1

#
# UNARJ_CONFFILES should be a list of user-editable files

#
# UNARJ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UNARJ_PATCHES= $(UNARJ_SOURCE_DIR)/unarj-2.65-overflow.diff \
  $(UNARJ_SOURCE_DIR)/unarj-2.65-path.diff \
  $(UNARJ_SOURCE_DIR)/unarj-2.65-time.diff \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNARJ_CPPFLAGS=
UNARJ_LDFLAGS=

#
# UNARJ_BUILD_DIR is the directory in which the build is done.
# UNARJ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNARJ_IPK_DIR is the directory in which the ipk is built.
# UNARJ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNARJ_BUILD_DIR=$(BUILD_DIR)/unarj
UNARJ_SOURCE_DIR=$(SOURCE_DIR)/unarj
UNARJ_IPK_DIR=$(BUILD_DIR)/unarj-$(UNARJ_VERSION)-ipk
UNARJ_IPK=$(BUILD_DIR)/unarj_$(UNARJ_VERSION)-$(UNARJ_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNARJ_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNARJ_SITE)/$(UNARJ_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unarj-source: $(DL_DIR)/$(UNARJ_SOURCE) $(UNARJ_PATCHES)

$(UNARJ_BUILD_DIR)/.configured: $(DL_DIR)/$(UNARJ_SOURCE) $(UNARJ_PATCHES) make/unarj.mk
	rm -rf $(BUILD_DIR)/$(UNARJ_DIR) $(UNARJ_BUILD_DIR)
	$(UNARJ_UNZIP) $(DL_DIR)/$(UNARJ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNARJ_PATCHES)" ; \
		then cat $(UNARJ_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UNARJ_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNARJ_DIR)" != "$(UNARJ_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UNARJ_DIR) $(UNARJ_BUILD_DIR) ; \
	fi
	touch $(UNARJ_BUILD_DIR)/.configured

unarj-unpack: $(UNARJ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNARJ_BUILD_DIR)/.built: $(UNARJ_BUILD_DIR)/.configured
	rm -f $(UNARJ_BUILD_DIR)/.built
	$(MAKE) -C $(UNARJ_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS)
	touch $(UNARJ_BUILD_DIR)/.built

#
# This is the build convenience target.
#
unarj: $(UNARJ_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unarj
#
$(UNARJ_IPK_DIR)/CONTROL/control:
	@install -d $(UNARJ_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: unarj" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNARJ_PRIORITY)" >>$@
	@echo "Section: $(UNARJ_SECTION)" >>$@
	@echo "Version: $(UNARJ_VERSION)-$(UNARJ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNARJ_MAINTAINER)" >>$@
	@echo "Source: $(UNARJ_SITE)/$(UNARJ_SOURCE)" >>$@
	@echo "Description: $(UNARJ_DESCRIPTION)" >>$@
	@echo "Depends: $(UNARJ_DEPENDS)" >>$@
	@echo "Suggests: $(UNARJ_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNARJ_CONFLICTS)" >>$@

$(UNARJ_IPK): $(UNARJ_BUILD_DIR)/.built
	rm -rf $(UNARJ_IPK_DIR) $(BUILD_DIR)/unarj_*_$(TARGET_ARCH).ipk
	install -d $(UNARJ_IPK_DIR)/opt/bin
	install -m 755 $(UNARJ_BUILD_DIR)/unarj $(UNARJ_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(UNARJ_IPK_DIR)/opt/bin/unarj
	$(MAKE) $(UNARJ_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNARJ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unarj-ipk: $(UNARJ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unarj-clean:
	rm -f $(UNARJ_BUILD_DIR)/.built
	-$(MAKE) -C $(UNARJ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unarj-dirclean:
	rm -rf $(BUILD_DIR)/$(UNARJ_DIR) $(UNARJ_BUILD_DIR) $(UNARJ_IPK_DIR) $(UNARJ_IPK)
