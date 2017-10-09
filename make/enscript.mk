###########################################################
#
# enscript
#
###########################################################
#
# ENSCRIPT_VERSION, ENSCRIPT_SITE and ENSCRIPT_SOURCE define
# the upstream location of the source code for the package.
# ENSCRIPT_DIR is the directory which is created when the source
# archive is unpacked.
# ENSCRIPT_UNZIP is the command used to unzip the source.
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
ENSCRIPT_SITE=http://www.codento.com/people/mtr/genscript
ENSCRIPT_VERSION=1.6.4
ENSCRIPT_SOURCE=enscript-$(ENSCRIPT_VERSION).tar.gz
ENSCRIPT_DIR=enscript-$(ENSCRIPT_VERSION)
ENSCRIPT_UNZIP=zcat
ENSCRIPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ENSCRIPT_DESCRIPTION=GNU enscript converts ASCII files to PostScript and spools generated PostScript output to the specified printer or leaves it to file.
ENSCRIPT_SECTION=print
ENSCRIPT_PRIORITY=optional
ENSCRIPT_DEPENDS=
ENSCRIPT_SUGGESTS=
ENSCRIPT_CONFLICTS=

#
# ENSCRIPT_IPK_VERSION should be incremented when the ipk changes.
#
ENSCRIPT_IPK_VERSION=2

#
# ENSCRIPT_CONFFILES should be a list of user-editable files
#ENSCRIPT_CONFFILES=$(TARGET_PREFIX)/etc/enscript.conf $(TARGET_PREFIX)/etc/init.d/SXXenscript

#
# ENSCRIPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ENSCRIPT_PATCHES=$(ENSCRIPT_SOURCE_DIR)/patch-afm_Makefile.in \
$(ENSCRIPT_SOURCE_DIR)/patch-lib_Makefile.in \
$(ENSCRIPT_SOURCE_DIR)/patch-states_hl_Makefile.in

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENSCRIPT_CPPFLAGS=
ENSCRIPT_LDFLAGS=

#
# ENSCRIPT_BUILD_DIR is the directory in which the build is done.
# ENSCRIPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENSCRIPT_IPK_DIR is the directory in which the ipk is built.
# ENSCRIPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENSCRIPT_BUILD_DIR=$(BUILD_DIR)/enscript
ENSCRIPT_SOURCE_DIR=$(SOURCE_DIR)/enscript
ENSCRIPT_IPK_DIR=$(BUILD_DIR)/enscript-$(ENSCRIPT_VERSION)-ipk
ENSCRIPT_IPK=$(BUILD_DIR)/enscript_$(ENSCRIPT_VERSION)-$(ENSCRIPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: enscript-source enscript-unpack enscript enscript-stage enscript-ipk enscript-clean enscript-dirclean enscript-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENSCRIPT_SOURCE):
	$(WGET) -P $(@D) $(ENSCRIPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
enscript-source: $(DL_DIR)/$(ENSCRIPT_SOURCE) $(ENSCRIPT_PATCHES)

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
$(ENSCRIPT_BUILD_DIR)/.configured: $(DL_DIR)/$(ENSCRIPT_SOURCE) $(ENSCRIPT_PATCHES) make/enscript.mk
	$(MAKE) flex-stage
	rm -rf $(BUILD_DIR)/$(ENSCRIPT_DIR) $(@D)
	$(ENSCRIPT_UNZIP) $(DL_DIR)/$(ENSCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ENSCRIPT_PATCHES)" ; \
		then cat $(ENSCRIPT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(ENSCRIPT_DIR) -bp0 ; \
	fi
	if test "$(BUILD_DIR)/$(ENSCRIPT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ENSCRIPT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENSCRIPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENSCRIPT_LDFLAGS)" \
		AMDEP_TRUE='#' \
		am__fastdepCC_TRUE='#' \
		ac_objext='o' \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-dependency-tracking \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

enscript-unpack: $(ENSCRIPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ENSCRIPT_BUILD_DIR)/.built: $(ENSCRIPT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) OBJEXT='o'
	touch $@

#
# This is the build convenience target.
#
enscript: $(ENSCRIPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(ENSCRIPT_BUILD_DIR)/.staged: $(ENSCRIPT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#enscript-stage: $(ENSCRIPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/enscript
#
$(ENSCRIPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: enscript" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENSCRIPT_PRIORITY)" >>$@
	@echo "Section: $(ENSCRIPT_SECTION)" >>$@
	@echo "Version: $(ENSCRIPT_VERSION)-$(ENSCRIPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENSCRIPT_MAINTAINER)" >>$@
	@echo "Source: $(ENSCRIPT_SITE)/$(ENSCRIPT_SOURCE)" >>$@
	@echo "Description: $(ENSCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(ENSCRIPT_DEPENDS)" >>$@
	@echo "Suggests: $(ENSCRIPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENSCRIPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/etc/enscript/...
# Documentation files should be installed in $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/doc/enscript/...
# Daemon startup scripts should be installed in $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??enscript
#
# You may need to patch your application to make it use these locations.
#
$(ENSCRIPT_IPK): $(ENSCRIPT_BUILD_DIR)/.built
	rm -rf $(ENSCRIPT_IPK_DIR) $(BUILD_DIR)/enscript_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ENSCRIPT_BUILD_DIR) DESTDIR=$(ENSCRIPT_IPK_DIR)  OBJEXT='o' install-strip
	rm -rf $(ENSCRIPT_IPK_DIR)$(TARGET_PREFIX)/info/dir*
	$(MAKE) $(ENSCRIPT_IPK_DIR)/CONTROL/control
	echo $(ENSCRIPT_CONFFILES) | sed -e 's/ /\n/g' > $(ENSCRIPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENSCRIPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
enscript-ipk: $(ENSCRIPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
enscript-clean:
	rm -f $(ENSCRIPT_BUILD_DIR)/.built
	-$(MAKE) -C $(ENSCRIPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
enscript-dirclean:
	rm -rf $(BUILD_DIR)/$(ENSCRIPT_DIR) $(ENSCRIPT_BUILD_DIR) $(ENSCRIPT_IPK_DIR) $(ENSCRIPT_IPK)
#
#
# Some sanity check for the package.
#
enscript-check: $(ENSCRIPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
