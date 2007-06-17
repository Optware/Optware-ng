###########################################################
#
# lzma
#
###########################################################
#
# LZMA_VERSION, LZMA_SITE and LZMA_SOURCE define
# the upstream location of the source code for the package.
# LZMA_DIR is the directory which is created when the source
# archive is unpacked.
# LZMA_UNZIP is the command used to unzip the source.
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
LZMA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/sevenzip
LZMA_VERSION=443
LZMA_SOURCE=lzma$(LZMA_VERSION).tar.bz2
LZMA_DIR=lzma$(LZMA_VERSION)
LZMA_UNZIP=bzcat
LZMA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
# This make/lzma.mk file currently does not generate package, lzma-unpack is used by make/upx.mk
LZMA_DESCRIPTION=Lempel-Ziv-Markov chain-Algorithm (LZMA) is a data compression algorithm in development since 1998 and used in the 7z format of the 7-Zip archiver.
LZMA_SECTION=compression
LZMA_PRIORITY=optional
LZMA_DEPENDS=
LZMA_SUGGESTS=
LZMA_CONFLICTS=

#
# LZMA_IPK_VERSION should be incremented when the ipk changes.
#
LZMA_IPK_VERSION=1

#
# LZMA_CONFFILES should be a list of user-editable files
#LZMA_CONFFILES=/opt/etc/lzma.conf /opt/etc/init.d/SXXlzma

#
# LZMA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LZMA_PATCHES=$(LZMA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LZMA_CPPFLAGS=
LZMA_LDFLAGS=

#
# LZMA_BUILD_DIR is the directory in which the build is done.
# LZMA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LZMA_IPK_DIR is the directory in which the ipk is built.
# LZMA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LZMA_BUILD_DIR=$(BUILD_DIR)/lzma
LZMA_SOURCE_DIR=$(SOURCE_DIR)/lzma
LZMA_IPK_DIR=$(BUILD_DIR)/lzma-$(LZMA_VERSION)-ipk
LZMA_IPK=$(BUILD_DIR)/lzma_$(LZMA_VERSION)-$(LZMA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lzma-source lzma-unpack lzma lzma-stage lzma-ipk lzma-clean lzma-dirclean lzma-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LZMA_SOURCE):
	$(WGET) -P $(DL_DIR) $(LZMA_SITE)/$(LZMA_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LZMA_SOURCE)

lzma-source: $(DL_DIR)/$(LZMA_SOURCE) $(LZMA_PATCHES)

$(LZMA_BUILD_DIR)/.configured: $(DL_DIR)/$(LZMA_SOURCE) $(LZMA_PATCHES) make/lzma.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LZMA_DIR) $(LZMA_BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(LZMA_DIR)
	$(LZMA_UNZIP) $(DL_DIR)/$(LZMA_SOURCE) | tar -C $(BUILD_DIR)/$(LZMA_DIR) -xvf -
	if test -n "$(LZMA_PATCHES)" ; \
		then cat $(LZMA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LZMA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LZMA_DIR)" != "$(LZMA_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LZMA_DIR) $(LZMA_BUILD_DIR) ; \
	fi
	touch $@

lzma-unpack: $(LZMA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LZMA_BUILD_DIR)/.built: $(LZMA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LZMA_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
lzma: $(LZMA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LZMA_BUILD_DIR)/.staged: $(LZMA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LZMA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

lzma-stage: $(LZMA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lzma
#
$(LZMA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lzma" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LZMA_PRIORITY)" >>$@
	@echo "Section: $(LZMA_SECTION)" >>$@
	@echo "Version: $(LZMA_VERSION)-$(LZMA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LZMA_MAINTAINER)" >>$@
	@echo "Source: $(LZMA_SITE)/$(LZMA_SOURCE)" >>$@
	@echo "Description: $(LZMA_DESCRIPTION)" >>$@
	@echo "Depends: $(LZMA_DEPENDS)" >>$@
	@echo "Suggests: $(LZMA_SUGGESTS)" >>$@
	@echo "Conflicts: $(LZMA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LZMA_IPK_DIR)/opt/sbin or $(LZMA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LZMA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LZMA_IPK_DIR)/opt/etc/lzma/...
# Documentation files should be installed in $(LZMA_IPK_DIR)/opt/doc/lzma/...
# Daemon startup scripts should be installed in $(LZMA_IPK_DIR)/opt/etc/init.d/S??lzma
#
# You may need to patch your application to make it use these locations.
#
$(LZMA_IPK): $(LZMA_BUILD_DIR)/.built
	rm -rf $(LZMA_IPK_DIR) $(BUILD_DIR)/lzma_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LZMA_BUILD_DIR) DESTDIR=$(LZMA_IPK_DIR) install-strip
#	install -d $(LZMA_IPK_DIR)/opt/etc/
#	install -m 644 $(LZMA_SOURCE_DIR)/lzma.conf $(LZMA_IPK_DIR)/opt/etc/lzma.conf
#	install -d $(LZMA_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LZMA_SOURCE_DIR)/rc.lzma $(LZMA_IPK_DIR)/opt/etc/init.d/SXXlzma
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LZMA_IPK_DIR)/opt/etc/init.d/SXXlzma
	$(MAKE) $(LZMA_IPK_DIR)/CONTROL/control
#	install -m 755 $(LZMA_SOURCE_DIR)/postinst $(LZMA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LZMA_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LZMA_SOURCE_DIR)/prerm $(LZMA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LZMA_IPK_DIR)/CONTROL/prerm
	echo $(LZMA_CONFFILES) | sed -e 's/ /\n/g' > $(LZMA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LZMA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lzma-ipk: $(LZMA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lzma-clean:
	rm -f $(LZMA_BUILD_DIR)/.built
	-$(MAKE) -C $(LZMA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lzma-dirclean:
	rm -rf $(BUILD_DIR)/$(LZMA_DIR) $(LZMA_BUILD_DIR) $(LZMA_IPK_DIR) $(LZMA_IPK)
#
#
# Some sanity check for the package.
#
lzma-check: $(LZMA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LZMA_IPK)
