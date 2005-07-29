###########################################################
#
# dev-pts
#
###########################################################

DEV-PTS_SITE=
DEV-PTS_VERSION=5.5
DEV-PTS_SOURCE=
DEV-PTS_DIR=dev-pts-$(DEV-PTS_VERSION)
DEV-PTS_UNZIP=zcat
DEV-PTS_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
DEV-PTS_DESCRIPTION=Enables unix98-style ptys on unslung.
DEV-PTS_SECTION=base
DEV-PTS_PRIORITY=optional
DEV-PTS_DEPENDS=
DEV-PTS_SUGGESTS=
DEV-PTS_CONFLICTS=

#
# DEV-PTS_IPK_VERSION should be incremented when the ipk changes.
#
DEV-PTS_IPK_VERSION=1

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DEV-PTS_CPPFLAGS=
DEV-PTS_LDFLAGS=

#
# DEV-PTS_BUILD_DIR is the directory in which the build is done.
# DEV-PTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DEV-PTS_IPK_DIR is the directory in which the ipk is built.
# DEV-PTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DEV-PTS_BUILD_DIR=$(BUILD_DIR)/dev-pts
DEV-PTS_SOURCE_DIR=$(SOURCE_DIR)/dev-pts
DEV-PTS_IPK_DIR=$(BUILD_DIR)/dev-pts-$(DEV-PTS_VERSION)-ipk
DEV-PTS_IPK=$(BUILD_DIR)/dev-pts_$(DEV-PTS_VERSION)-$(DEV-PTS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dev-pts-source:

$(DEV-PTS_BUILD_DIR)/.configured:
	mkdir -p $(DEV-PTS_BUILD_DIR)
	touch $(DEV-PTS_BUILD_DIR)/.configured

dev-pts-unpack: $(DEV-PTS_BUILD_DIR)/.configured

$(DEV-PTS_BUILD_DIR)/.built:
	mkdir -p $(DEV-PTS_BUILD_DIR)
	touch $(DEV-PTS_BUILD_DIR)/.built

dev-pts: $(DEV-PTS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dev-pts
#
$(DEV-PTS_IPK_DIR)/CONTROL/control:
	@install -d $(DEV-PTS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dev-pts" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DEV-PTS_PRIORITY)" >>$@
	@echo "Section: $(DEV-PTS_SECTION)" >>$@
	@echo "Version: $(DEV-PTS_VERSION)-$(DEV-PTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DEV-PTS_MAINTAINER)" >>$@
	@echo "Source: $(DEV-PTS_SITE)/$(DEV-PTS_SOURCE)" >>$@
	@echo "Description: $(DEV-PTS_DESCRIPTION)" >>$@
	@echo "Depends: $(DEV-PTS_DEPENDS)" >>$@
	@echo "Suggests: $(DEV-PTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(DEV-PTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(DEV-PTS_IPK):
	rm -rf $(DEV-PTS_IPK_DIR) $(BUILD_DIR)/dev-pts_*_$(TARGET_ARCH).ipk
	install -d $(DEV-PTS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(DEV-PTS_SOURCE_DIR)/S05devpts $(DEV-PTS_IPK_DIR)/opt/etc/init.d/S05devpts
	$(MAKE) $(DEV-PTS_IPK_DIR)/CONTROL/control
	install -m 755 $(DEV-PTS_SOURCE_DIR)/postinst $(DEV-PTS_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DEV-PTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dev-pts-ipk: $(DEV-PTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dev-pts-clean:
	-$(MAKE) -C $(DEV-PTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dev-pts-dirclean:
	rm -rf $(BUILD_DIR)/$(DEV-PTS_DIR) $(DEV-PTS_BUILD_DIR) $(DEV-PTS_IPK_DIR) $(DEV-PTS_IPK)
