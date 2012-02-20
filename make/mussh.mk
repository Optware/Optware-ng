###########################################################
#
# mussh
#
###########################################################
#
# MUSSH_VERSION, MUSSH_SITE and MUSSH_SOURCE define
# the upstream location of the source code for the package.
# MUSSH_DIR is the directory which is created when the source
# archive is unpacked.
# MUSSH_UNZIP is the command used to unzip the source.
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
MUSSH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mussh
MUSSH_VERSION=1.0
MUSSH_SOURCE=mussh-$(MUSSH_VERSION).tgz
MUSSH_DIR=mussh
MUSSH_UNZIP=zcat
MUSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MUSSH_DESCRIPTION=Multihost SSH wrapper.
MUSSH_SECTION=utils
MUSSH_PRIORITY=optional
MUSSH_DEPENDS=bash
MUSSH_SUGGESTS=
MUSSH_CONFLICTS=

#
# MUSSH_IPK_VERSION should be incremented when the ipk changes.
#
MUSSH_IPK_VERSION=1

#
# MUSSH_CONFFILES should be a list of user-editable files
#MUSSH_CONFFILES=/opt/etc/mussh.conf /opt/etc/init.d/SXXmussh

#
# MUSSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# MUSSH_PATCHES=$(MUSSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MUSSH_CPPFLAGS=
MUSSH_LDFLAGS=

#
# MUSSH_BUILD_DIR is the directory in which the build is done.
# MUSSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MUSSH_IPK_DIR is the directory in which the ipk is built.
# MUSSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MUSSH_BUILD_DIR=$(BUILD_DIR)/mussh
MUSSH_SOURCE_DIR=$(SOURCE_DIR)/mussh
MUSSH_IPK_DIR=$(BUILD_DIR)/mussh-$(MUSSH_VERSION)-ipk
MUSSH_IPK=$(BUILD_DIR)/mussh_$(MUSSH_VERSION)-$(MUSSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mussh-source mussh-unpack mussh mussh-stage mussh-ipk mussh-clean mussh-dirclean mussh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MUSSH_SOURCE):
	$(WGET) -P $(@D) $(MUSSH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mussh-source: $(DL_DIR)/$(MUSSH_SOURCE) $(MUSSH_PATCHES)

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
$(MUSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(MUSSH_SOURCE) $(MUSSH_PATCHES) make/mussh.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MUSSH_DIR) $(@D)
	$(MUSSH_UNZIP) $(DL_DIR)/$(MUSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MUSSH_PATCHES)" ; \
		then cat $(MUSSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MUSSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MUSSH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MUSSH_DIR) $(@D) ; \
	fi
	rm -f $(@D)/*.swp
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MUSSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MUSSH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mussh-unpack: $(MUSSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MUSSH_BUILD_DIR)/.built: $(MUSSH_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mussh: $(MUSSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(MUSSH_BUILD_DIR)/.staged: $(MUSSH_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#mussh-stage: $(MUSSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mussh
#
$(MUSSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mussh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MUSSH_PRIORITY)" >>$@
	@echo "Section: $(MUSSH_SECTION)" >>$@
	@echo "Version: $(MUSSH_VERSION)-$(MUSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MUSSH_MAINTAINER)" >>$@
	@echo "Source: $(MUSSH_SITE)/$(MUSSH_SOURCE)" >>$@
	@echo "Description: $(MUSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(MUSSH_DEPENDS)" >>$@
	@echo "Suggests: $(MUSSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(MUSSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MUSSH_IPK_DIR)/opt/sbin or $(MUSSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MUSSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MUSSH_IPK_DIR)/opt/etc/mussh/...
# Documentation files should be installed in $(MUSSH_IPK_DIR)/opt/doc/mussh/...
# Daemon startup scripts should be installed in $(MUSSH_IPK_DIR)/opt/etc/init.d/S??mussh
#
# You may need to patch your application to make it use these locations.
#
$(MUSSH_IPK): $(MUSSH_BUILD_DIR)/.built
	rm -rf $(MUSSH_IPK_DIR) $(BUILD_DIR)/mussh_*_$(TARGET_ARCH).ipk
	install -d $(MUSSH_IPK_DIR)/opt/bin
	install -m 755 $(MUSSH_BUILD_DIR)/mussh $(MUSSH_IPK_DIR)/opt/bin/
	install -d $(MUSSH_IPK_DIR)/opt/share/man/man1
	install -m 644 $(MUSSH_BUILD_DIR)/mussh.1 $(MUSSH_IPK_DIR)/opt/share/man/man1
	$(MAKE) $(MUSSH_IPK_DIR)/CONTROL/control
	echo $(MUSSH_CONFFILES) | sed -e 's/ /\n/g' > $(MUSSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MUSSH_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MUSSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mussh-ipk: $(MUSSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mussh-clean:
	rm -f $(MUSSH_BUILD_DIR)/.built
	-$(MAKE) -C $(MUSSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mussh-dirclean:
	rm -rf $(BUILD_DIR)/$(MUSSH_DIR) $(MUSSH_BUILD_DIR) $(MUSSH_IPK_DIR) $(MUSSH_IPK)
#
#
# Some sanity check for the package.
#
mussh-check: $(MUSSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
