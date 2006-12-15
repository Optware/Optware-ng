###########################################################
#
# arc
#
###########################################################

ARC_SITE=ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/
ARC_VERSION=5.21o
ARC_SOURCE=arc-$(ARC_VERSION).tgz
ARC_DIR=arc-$(ARC_VERSION)
ARC_UNZIP=zcat
ARC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ARC_DESCRIPTION=arc - Arc archiver
ARC_SECTION=apps
ARC_PRIORITY=optional
ARC_DEPENDS=
ARC_SUGGESTS=
ARC_CONFLICTS=

#
# ARC_IPK_VERSION should be incremented when the ipk changes.
#
ARC_IPK_VERSION=1

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ARC_CPPFLAGS=
ARC_LDFLAGS=

#
# ARC_BUILD_DIR is the directory in which the build is done.
# ARC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ARC_IPK_DIR is the directory in which the ipk is built.
# ARC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ARC_BUILD_DIR=$(BUILD_DIR)/arc
ARC_SOURCE_DIR=$(SOURCE_DIR)/arc
ARC_IPK_DIR=$(BUILD_DIR)/arc-$(ARC_VERSION)-ipk
ARC_IPK=$(BUILD_DIR)/arc_$(ARC_VERSION)-$(ARC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ARC_SOURCE):
	$(WGET) -P $(DL_DIR) $(ARC_SITE)/$(ARC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
arc-source: $(DL_DIR)/$(ARC_SOURCE) $(ARC_PATCHES)

$(ARC_BUILD_DIR)/.configured: $(DL_DIR)/$(ARC_SOURCE) $(ARC_PATCHES) make/arc.mk
	rm -rf $(BUILD_DIR)/$(ARC_DIR) $(ARC_BUILD_DIR)
	$(ARC_UNZIP) $(DL_DIR)/$(ARC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ARC_PATCHES)" ; \
		then cat $(ARC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ARC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ARC_DIR)" != "$(ARC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ARC_DIR) $(ARC_BUILD_DIR) ; \
	fi
	touch $(ARC_BUILD_DIR)/.configured

arc-unpack: $(ARC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ARC_BUILD_DIR)/.built: $(ARC_BUILD_DIR)/.configured
	rm -f $(ARC_BUILD_DIR)/.built
	$(MAKE) -C $(ARC_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS)
	touch $(ARC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
arc: $(ARC_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/arc
#
$(ARC_IPK_DIR)/CONTROL/control:
	@install -d $(ARC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: arc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ARC_PRIORITY)" >>$@
	@echo "Section: $(ARC_SECTION)" >>$@
	@echo "Version: $(ARC_VERSION)-$(ARC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ARC_MAINTAINER)" >>$@
	@echo "Source: $(ARC_SITE)/$(ARC_SOURCE)" >>$@
	@echo "Description: $(ARC_DESCRIPTION)" >>$@
	@echo "Depends: $(ARC_DEPENDS)" >>$@
	@echo "Suggests: $(ARC_SUGGESTS)" >>$@
	@echo "Conflicts: $(ARC_CONFLICTS)" >>$@

$(ARC_IPK): $(ARC_BUILD_DIR)/.built
	rm -rf $(ARC_IPK_DIR) $(BUILD_DIR)/arc_*_$(TARGET_ARCH).ipk
	install -d $(ARC_IPK_DIR)/opt/bin
	install -m 755 $(ARC_BUILD_DIR)/arc $(ARC_IPK_DIR)/opt/bin
	install -m 755 $(ARC_BUILD_DIR)/marc $(ARC_IPK_DIR)/opt/bin
	install -d $(ARC_IPK_DIR)/opt/share/man/man1
	install -m 644 $(ARC_BUILD_DIR)/arc.1 $(ARC_IPK_DIR)/opt/share/man/man1
	$(STRIP_COMMAND) $(ARC_IPK_DIR)/opt/bin/arc
	$(STRIP_COMMAND) $(ARC_IPK_DIR)/opt/bin/marc
	$(MAKE) $(ARC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ARC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
arc-ipk: $(ARC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
arc-clean:
	rm -f $(ARC_BUILD_DIR)/.built
	-$(MAKE) -C $(ARC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
arc-dirclean:
	rm -rf $(BUILD_DIR)/$(ARC_DIR) $(ARC_BUILD_DIR) $(ARC_IPK_DIR) $(ARC_IPK)
