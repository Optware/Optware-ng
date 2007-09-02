###########################################################
#
# autossh
#
###########################################################
#
# AUTOSSH_VERSION, AUTOSSH_SITE and AUTOSSH_SOURCE define
# the upstream location of the source code for the package.
# AUTOSSH_DIR is the directory which is created when the source
# archive is unpacked.
# AUTOSSH_UNZIP is the command used to unzip the source.
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
AUTOSSH_SITE=http://www.harding.motd.ca/autossh
AUTOSSH_VERSION=1.4a
AUTOSSH_SOURCE=autossh-$(AUTOSSH_VERSION).tgz
AUTOSSH_DIR=autossh-$(AUTOSSH_VERSION)
AUTOSSH_UNZIP=zcat
AUTOSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
AUTOSSH_DESCRIPTION=Automatically restart SSH sessions and tunnels.
AUTOSSH_SECTION=net
AUTOSSH_PRIORITY=optional
AUTOSSH_DEPENDS=openssh
AUTOSSH_SUGGESTS=
AUTOSSH_CONFLICTS=

#
# AUTOSSH_IPK_VERSION should be incremented when the ipk changes.
#
AUTOSSH_IPK_VERSION=1

#
# AUTOSSH_CONFFILES should be a list of user-editable files
#AUTOSSH_CONFFILES=/opt/etc/autossh.conf /opt/etc/init.d/SXXautossh

#
# AUTOSSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#AUTOSSH_PATCHES=$(AUTOSSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
AUTOSSH_CPPFLAGS=
AUTOSSH_LDFLAGS=

#
# AUTOSSH_BUILD_DIR is the directory in which the build is done.
# AUTOSSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# AUTOSSH_IPK_DIR is the directory in which the ipk is built.
# AUTOSSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
AUTOSSH_BUILD_DIR=$(BUILD_DIR)/autossh
AUTOSSH_SOURCE_DIR=$(SOURCE_DIR)/autossh
AUTOSSH_IPK_DIR=$(BUILD_DIR)/autossh-$(AUTOSSH_VERSION)-ipk
AUTOSSH_IPK=$(BUILD_DIR)/autossh_$(AUTOSSH_VERSION)-$(AUTOSSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: autossh-source autossh-unpack autossh autossh-stage autossh-ipk autossh-clean autossh-dirclean autossh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(AUTOSSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(AUTOSSH_SITE)/$(AUTOSSH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(AUTOSSH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
autossh-source: $(DL_DIR)/$(AUTOSSH_SOURCE) $(AUTOSSH_PATCHES)

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
$(AUTOSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(AUTOSSH_SOURCE) $(AUTOSSH_PATCHES) make/autossh.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(AUTOSSH_DIR) $(AUTOSSH_BUILD_DIR)
	$(AUTOSSH_UNZIP) $(DL_DIR)/$(AUTOSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(AUTOSSH_PATCHES)" ; \
		then cat $(AUTOSSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(AUTOSSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(AUTOSSH_DIR)" != "$(AUTOSSH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(AUTOSSH_DIR) $(AUTOSSH_BUILD_DIR) ; \
	fi
	(cd $(AUTOSSH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(AUTOSSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(AUTOSSH_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(AUTOSSH_BUILD_DIR)/libtool
	touch $@

autossh-unpack: $(AUTOSSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(AUTOSSH_BUILD_DIR)/.built: $(AUTOSSH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(AUTOSSH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
autossh: $(AUTOSSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(AUTOSSH_BUILD_DIR)/.staged: $(AUTOSSH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(AUTOSSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

autossh-stage: $(AUTOSSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/autossh
#
$(AUTOSSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: autossh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(AUTOSSH_PRIORITY)" >>$@
	@echo "Section: $(AUTOSSH_SECTION)" >>$@
	@echo "Version: $(AUTOSSH_VERSION)-$(AUTOSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(AUTOSSH_MAINTAINER)" >>$@
	@echo "Source: $(AUTOSSH_SITE)/$(AUTOSSH_SOURCE)" >>$@
	@echo "Description: $(AUTOSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(AUTOSSH_DEPENDS)" >>$@
	@echo "Suggests: $(AUTOSSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(AUTOSSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(AUTOSSH_IPK_DIR)/opt/sbin or $(AUTOSSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(AUTOSSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(AUTOSSH_IPK_DIR)/opt/etc/autossh/...
# Documentation files should be installed in $(AUTOSSH_IPK_DIR)/opt/doc/autossh/...
# Daemon startup scripts should be installed in $(AUTOSSH_IPK_DIR)/opt/etc/init.d/S??autossh
#
# You may need to patch your application to make it use these locations.
#
$(AUTOSSH_IPK): $(AUTOSSH_BUILD_DIR)/.built
	rm -rf $(AUTOSSH_IPK_DIR) $(BUILD_DIR)/autossh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(AUTOSSH_BUILD_DIR) install \
		DESTDIR=$(AUTOSSH_IPK_DIR) \
		prefix=$(AUTOSSH_IPK_DIR)/opt
	$(STRIP_COMMAND) $(AUTOSSH_IPK_DIR)/opt/bin/*
	$(MAKE) $(AUTOSSH_IPK_DIR)/CONTROL/control
	echo $(AUTOSSH_CONFFILES) | sed -e 's/ /\n/g' > $(AUTOSSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(AUTOSSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
autossh-ipk: $(AUTOSSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
autossh-clean:
	rm -f $(AUTOSSH_BUILD_DIR)/.built
	-$(MAKE) -C $(AUTOSSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
autossh-dirclean:
	rm -rf $(BUILD_DIR)/$(AUTOSSH_DIR) $(AUTOSSH_BUILD_DIR) $(AUTOSSH_IPK_DIR) $(AUTOSSH_IPK)
#
#
# Some sanity check for the package.
#
autossh-check: $(AUTOSSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(AUTOSSH_IPK)
