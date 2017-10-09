###########################################################
#
# pcal
#
###########################################################
#
# PCAL_VERSION, PCAL_SITE and PCAL_SOURCE define
# the upstream location of the source code for the package.
# PCAL_DIR is the directory which is created when the source
# archive is unpacked.
# PCAL_UNZIP is the command used to unzip the source.
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
PCAL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pcal
PCAL_VERSION=4.11.0
PCAL_SOURCE=pcal-$(PCAL_VERSION).tgz
PCAL_DIR=pcal-$(PCAL_VERSION)
PCAL_UNZIP=zcat
PCAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCAL_DESCRIPTION=Calendar-generation programs which produce nice-looking PostScript output.
PCAL_SECTION=misc
PCAL_PRIORITY=optional
PCAL_DEPENDS=
PCAL_SUGGESTS=
PCAL_CONFLICTS=

#
# PCAL_IPK_VERSION should be incremented when the ipk changes.
#
PCAL_IPK_VERSION=2

#
# PCAL_CONFFILES should be a list of user-editable files
#PCAL_CONFFILES=$(TARGET_PREFIX)/etc/pcal.conf $(TARGET_PREFIX)/etc/init.d/SXXpcal

#
# PCAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PCAL_PATCHES=$(PCAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCAL_CPPFLAGS=
PCAL_LDFLAGS=

#
# PCAL_BUILD_DIR is the directory in which the build is done.
# PCAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCAL_IPK_DIR is the directory in which the ipk is built.
# PCAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCAL_BUILD_DIR=$(BUILD_DIR)/pcal
PCAL_SOURCE_DIR=$(SOURCE_DIR)/pcal
PCAL_IPK_DIR=$(BUILD_DIR)/pcal-$(PCAL_VERSION)-ipk
PCAL_IPK=$(BUILD_DIR)/pcal_$(PCAL_VERSION)-$(PCAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pcal-source pcal-unpack pcal pcal-stage pcal-ipk pcal-clean pcal-dirclean pcal-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCAL_SOURCE):
	$(WGET) -P $(@D) $(PCAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pcal-source: $(DL_DIR)/$(PCAL_SOURCE) $(PCAL_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(PCAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PCAL_SOURCE) $(PCAL_PATCHES) make/pcal.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PCAL_DIR) $(@D)
	$(PCAL_UNZIP) $(DL_DIR)/$(PCAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PCAL_PATCHES)" ; \
		then cat $(PCAL_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PCAL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PCAL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PCAL_DIR) $(@D) ; \
	fi
	sed -i -e '/groff -man -Thtml/s|^|#|;/$$(CATDIR)/s|^|#|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCAL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pcal-unpack: $(PCAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCAL_BUILD_DIR)/.built: $(PCAL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCAL_LDFLAGS)" \
		PACK=: BINDIR=$(TARGET_PREFIX)/bin MANDIR=$(TARGET_PREFIX)/share/man/man1 CATDIR=$(TARGET_PREFIX)/share/man/cat1
	touch $@

#
# This is the build convenience target.
#
pcal: $(PCAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCAL_BUILD_DIR)/.staged: $(PCAL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

pcal-stage: $(PCAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pcal
#
$(PCAL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: pcal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCAL_PRIORITY)" >>$@
	@echo "Section: $(PCAL_SECTION)" >>$@
	@echo "Version: $(PCAL_VERSION)-$(PCAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCAL_MAINTAINER)" >>$@
	@echo "Source: $(PCAL_SITE)/$(PCAL_SOURCE)" >>$@
	@echo "Description: $(PCAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PCAL_DEPENDS)" >>$@
	@echo "Suggests: $(PCAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PCAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCAL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PCAL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCAL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PCAL_IPK_DIR)$(TARGET_PREFIX)/etc/pcal/...
# Documentation files should be installed in $(PCAL_IPK_DIR)$(TARGET_PREFIX)/doc/pcal/...
# Daemon startup scripts should be installed in $(PCAL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??pcal
#
# You may need to patch your application to make it use these locations.
#
$(PCAL_IPK): $(PCAL_BUILD_DIR)/.built
	rm -rf $(PCAL_IPK_DIR) $(BUILD_DIR)/pcal_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCAL_BUILD_DIR) DESTDIR=$(PCAL_IPK_DIR) install \
		PACK=: BINDIR=$(TARGET_PREFIX)/bin MANDIR=$(TARGET_PREFIX)/share/man/man1 CATDIR=$(TARGET_PREFIX)/share/man/cat1
	$(STRIP_COMMAND) $(PCAL_IPK_DIR)$(TARGET_PREFIX)/bin/pcal
	$(MAKE) $(PCAL_IPK_DIR)/CONTROL/control
	echo $(PCAL_CONFFILES) | sed -e 's/ /\n/g' > $(PCAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pcal-ipk: $(PCAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pcal-clean:
	rm -f $(PCAL_BUILD_DIR)/.built
	-$(MAKE) -C $(PCAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pcal-dirclean:
	rm -rf $(BUILD_DIR)/$(PCAL_DIR) $(PCAL_BUILD_DIR) $(PCAL_IPK_DIR) $(PCAL_IPK)
#
#
# Some sanity check for the package.
#
pcal-check: $(PCAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
