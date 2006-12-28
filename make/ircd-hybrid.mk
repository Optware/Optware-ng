###########################################################
#
# ircd-hybrid
#
###########################################################

IRCD_HYBRID_DIR=$(BUILD_DIR)/ircd-hybrid
IRCD_HYBRID_VERSION=7.2.2
IRCD_HYBRID=ircd-hybrid-$(IRCD_HYBRID_VERSION)
IRCD_HYBRID_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ircd-hybrid
IRCD_HYBRID_SOURCE_ARCHIVE=$(IRCD_HYBRID).tgz
IRCD_HYBRID_UNZIP=zcat
IRCD_HYBRID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IRCD_HYBRID_DESCRIPTION=IRCD Hybrid
IRCD_HYBRID_SECTION=devel
IRCD_HYBRID_PRIORITY=optional
IRCD_HYBRID_DEPENDS=zlib, flex
IRCD_HYBRID_SUGGESTS=
IRCD_HYBRID_CONFLICTS=

IRCD_HYBRID_IPK_VERSION=1

IRCD_HYBRID_IPK=$(BUILD_DIR)/ircd-hybrid_$(IRCD_HYBRID_VERSION)-$(IRCD_HYBRID_IPK_VERSION)_$(TARGET_ARCH).ipk
IRCD_HYBRID_IPK_DIR=$(BUILD_DIR)/ircd-hybrid-$(IRCD_HYBRID_VERSION)-ipk

ifeq ($(LIBC_STYLE), uclibc)
IRCD_HYBRID_CONFIGURE_OPTS=ac_cv_func_dlinfo=no
else
IRCD_HYBRID_CONFIGURE_OPTS=
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IRCD_HYBRID_SOURCE_ARCHIVE):
	$(WGET) -P $(DL_DIR) $(IRCD_HYBRID_SITE)/$(IRCD_HYBRID_SOURCE_ARCHIVE)

#
# The IRCD Hybrid source code depends on it existing within the
# download directory.  This target will be called by the top level
# Makefile to download the source code's archive (.tar.gz, .bz2, etc.)
#
ircd-hybrid-source: $(DL_DIR)/$(IRCD_HYBRID_SOURCE_ARCHIVE)

#
# This target unpacks the source code into the build directory.
#
$(IRCD_HYBRID_DIR)/.source: $(DL_DIR)/$(IRCD_HYBRID_SOURCE_ARCHIVE)
	$(IRCD_HYBRID_UNZIP) $(DL_DIR)/$(IRCD_HYBRID_SOURCE_ARCHIVE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/ircd-hybrid-$(IRCD_HYBRID_VERSION) $(IRCD_HYBRID_DIR)
	touch $(IRCD_HYBRID_DIR)/.source

#
# This target configures the build within the build directory.
# This is a fairly important note (cuz I wasted about 5 hours on it).
# Flags usch as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(IRCD_HYBRID_DIR)/.configured: $(IRCD_HYBRID_DIR)/.source
	$(MAKE) flex-stage
	(cd $(IRCD_HYBRID_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="-L $(IRCD_HYBRID_DIR)/adns $(STAGING_LDFLAGS)" \
		$(IRCD_HYBRID_CONFIGURE_OPTS) \
		./configure \
			--build=$(GNU_HOST_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--target=$(GNU_TARGET_NAME) \
			--prefix=/opt	\
	);
	touch $(IRCD_HYBRID_DIR)/.configured

#
# This builds the actual binary (ircd).  IRCD Hybrid drops the final binary
# in the src directory once built.
#
$(IRCD_HYBRID_DIR)/src/ircd: $(IRCD_HYBRID_DIR)/.configured
	$(MAKE) -C $(IRCD_HYBRID_DIR)	\
	RANLIB=$(TARGET_RANLIB)

#
# These are the dependencies for the binary.  IRCD Hybrid requires Zlib,
# Flex, and the actual binary to exist before we're done.
#
ircd-hybrid: zlib flex $(IRCD_HYBRID_DIR)/src/ircd

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ircd-hybrid
#
$(IRCD_HYBRID_IPK_DIR)/CONTROL/control:
	@install -d $(IRCD_HYBRID_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ircd-hybrid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IRCD_HYBRID_PRIORITY)" >>$@
	@echo "Section: $(IRCD_HYBRID_SECTION)" >>$@
	@echo "Version: $(IRCD_HYBRID_VERSION)-$(IRCD_HYBRID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IRCD_HYBRID_MAINTAINER)" >>$@
	@echo "Source: $(IRCD_HYBRID_SITE)/$(IRCD_HYBRID_SOURCE)" >>$@
	@echo "Description: $(IRCD_HYBRID_DESCRIPTION)" >>$@
	@echo "Depends: $(IRCD_HYBRID_DEPENDS)" >>$@
	@echo "Suggests: $(IRCD_HYBRID_SUGGESTS)" >>$@
	@echo "Conflicts: $(IRCD_HYBRID_CONFLICTS)" >>$@

# This builds the IPK file.
#
$(IRCD_HYBRID_IPK): $(IRCD_HYBRID_DIR)/src/ircd
	rm -rf $(IRCD_HYBRID_IPK_DIR) $(BUILD_DIR)/ircd-hybrid_*_$(TARGET_ARCH).ipk
	install -d $(IRCD_HYBRID_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(IRCD_HYBRID_DIR)/src/ircd -o $(IRCD_HYBRID_IPK_DIR)/opt/bin/ircd
	install -d $(IRCD_HYBRID_IPK_DIR)/opt/doc/ircd-hybrid
	install -m 644 $(IRCD_HYBRID_DIR)/etc/simple.conf $(IRCD_HYBRID_IPK_DIR)/opt/doc/ircd-hybrid/simple.conf
	$(MAKE) $(IRCD_HYBRID_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRCD_HYBRID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ircd-hybrid-ipk: $(IRCD_HYBRID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ircd-hybrid-clean:
	-$(MAKE) -C $(IRCD_HYBRID_DIR) uninstall
	-$(MAKE) -C $(IRCD_HYBRID_DIR) clean

#
# This is called from the top level makefile to clean ALL files, including
# downloaded source.
#
ircd-hybrid-distclean:
	-rm $(IRCD_HYBRID_DIR)/.configured
	-$(MAKE) -C $(IRCD_HYBRID_DIR) distclean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ircd-hybrid-dirclean:
	rm -rf $(IRCD_HYBRID_DIR) $(IRCD_HYBRID_IPK_DIR) $(IRCD_HYBRID_IPK)
#
#
# Some sanity check for the package.
#
ircd-hybrid-check: $(IRCD_HYBRID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IRCD_HYBRID_IPK)
