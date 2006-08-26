###########################################################
#
# zoo
#
###########################################################

ZOO_SITE=http://security.debian.org/pool/updates/non-free/z/zoo
ZOO_VERSION=2.10
ZOO_SOURCE=zoo_$(ZOO_VERSION).orig.tar.gz
ZOO_DIR=zoo-$(ZOO_VERSION).orig
ZOO_UNZIP=zcat
ZOO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZOO_DESCRIPTION=zoo - File archiving utility with compression
ZOO_SECTION=apps
ZOO_PRIORITY=optional
ZOO_DEPENDS=
ZOO_SUGGESTS=
ZOO_CONFLICTS=

#
# ZOO_IPK_VERSION should be incremented when the ipk changes.
#
ZOO_IPK_VERSION=1

#
# ZOO_CONFFILES should be a list of user-editable files

#
# ZOO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ZOO_PATCHES=$(ZOO_SOURCE_DIR)/zoo_2.10-11sarge0.diff \
  $(ZOO_SOURCE_DIR)/zoo-2.10-CAN-2005-2349.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZOO_CPPFLAGS=-c -O -Wall -DLINT -DLINUX -DANSI_HDRS  -DBIG_MEM -DNDEBUG
ZOO_LDFLAGS=

#
# ZOO_BUILD_DIR is the directory in which the build is done.
# ZOO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZOO_IPK_DIR is the directory in which the ipk is built.
# ZOO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZOO_BUILD_DIR=$(BUILD_DIR)/zoo
ZOO_SOURCE_DIR=$(SOURCE_DIR)/zoo
ZOO_IPK_DIR=$(BUILD_DIR)/zoo-$(ZOO_VERSION)-ipk
ZOO_IPK=$(BUILD_DIR)/zoo_$(ZOO_VERSION)-$(ZOO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ZOO_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZOO_SITE)/$(ZOO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
zoo-source: $(DL_DIR)/$(ZOO_SOURCE) $(ZOO_PATCHES)

$(ZOO_BUILD_DIR)/.configured: $(DL_DIR)/$(ZOO_SOURCE) $(ZOO_PATCHES) make/zoo.mk
	rm -rf $(BUILD_DIR)/$(ZOO_DIR) $(ZOO_BUILD_DIR)
	$(ZOO_UNZIP) $(DL_DIR)/$(ZOO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZOO_PATCHES)" ; \
		then cat $(ZOO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ZOO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ZOO_DIR)" != "$(ZOO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ZOO_DIR) $(ZOO_BUILD_DIR) ; \
	fi
	touch $(ZOO_BUILD_DIR)/.configured

zoo-unpack: $(ZOO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZOO_BUILD_DIR)/.built: $(ZOO_BUILD_DIR)/.configured
	rm -f $(ZOO_BUILD_DIR)/.built
	$(MAKE) -C $(ZOO_BUILD_DIR) zoo fiz \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(STAGING_CPPFLAGS) $(ZOO_CPPFLAGS)"
	touch $(ZOO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
zoo: $(ZOO_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/zoo
#
$(ZOO_IPK_DIR)/CONTROL/control:
	@install -d $(ZOO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: zoo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZOO_PRIORITY)" >>$@
	@echo "Section: $(ZOO_SECTION)" >>$@
	@echo "Version: $(ZOO_VERSION)-$(ZOO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZOO_MAINTAINER)" >>$@
	@echo "Source: $(ZOO_SITE)/$(ZOO_SOURCE)" >>$@
	@echo "Description: $(ZOO_DESCRIPTION)" >>$@
	@echo "Depends: $(ZOO_DEPENDS)" >>$@
	@echo "Suggests: $(ZOO_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZOO_CONFLICTS)" >>$@

$(ZOO_IPK): $(ZOO_BUILD_DIR)/.built
	rm -rf $(ZOO_IPK_DIR) $(BUILD_DIR)/zoo_*_$(TARGET_ARCH).ipk
	install -d $(ZOO_IPK_DIR)/opt/bin
	install -m 755 $(ZOO_BUILD_DIR)/zoo $(ZOO_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(ZOO_IPK_DIR)/opt/bin/zoo
	install -m 755 $(ZOO_BUILD_DIR)/fiz $(ZOO_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(ZOO_IPK_DIR)/opt/bin/fiz
	install -d $(ZOO_IPK_DIR)/opt/share/man/man1
	install -m 644 $(ZOO_BUILD_DIR)/fiz.1  $(ZOO_IPK_DIR)/opt/share/man/man1
	install -m 644 $(ZOO_BUILD_DIR)/zoo.1  $(ZOO_IPK_DIR)/opt/share/man/man1
	$(MAKE) $(ZOO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZOO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
zoo-ipk: $(ZOO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
zoo-clean:
	rm -f $(ZOO_BUILD_DIR)/.built
	-$(MAKE) -C $(ZOO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
zoo-dirclean:
	rm -rf $(BUILD_DIR)/$(ZOO_DIR) $(ZOO_BUILD_DIR) $(ZOO_IPK_DIR) $(ZOO_IPK)
