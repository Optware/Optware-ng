###########################################################
#
# redir
#
###########################################################
#
# REDIR_VERSION, REDIR_SITE and REDIR_SOURCE define
# the upstream location of the source code for the package.
# REDIR_DIR is the directory which is created when the source
# archive is unpacked.
# REDIR_UNZIP is the command used to unzip the source.
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
REDIR_SITE=http://sammy.net/~sammy/hacks
REDIR_VERSION=2.2.1
REDIR_SOURCE=redir-$(REDIR_VERSION).tar.gz
REDIR_DIR=redir-$(REDIR_VERSION)
REDIR_UNZIP=zcat
REDIR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
REDIR_DESCRIPTION=A port redirector.
REDIR_SECTION=net
REDIR_PRIORITY=optional
REDIR_DEPENDS=
REDIR_SUGGESTS=
REDIR_CONFLICTS=

#
# REDIR_IPK_VERSION should be incremented when the ipk changes.
#
REDIR_IPK_VERSION=1

#
# REDIR_CONFFILES should be a list of user-editable files
#REDIR_CONFFILES=/opt/etc/redir.conf /opt/etc/init.d/SXXredir

#
# REDIR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#REDIR_PATCHES=$(REDIR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
REDIR_CPPFLAGS=
REDIR_LDFLAGS=

#
# REDIR_BUILD_DIR is the directory in which the build is done.
# REDIR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# REDIR_IPK_DIR is the directory in which the ipk is built.
# REDIR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
REDIR_BUILD_DIR=$(BUILD_DIR)/redir
REDIR_SOURCE_DIR=$(SOURCE_DIR)/redir
REDIR_IPK_DIR=$(BUILD_DIR)/redir-$(REDIR_VERSION)-ipk
REDIR_IPK=$(BUILD_DIR)/redir_$(REDIR_VERSION)-$(REDIR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: redir-source redir-unpack redir redir-stage redir-ipk redir-clean redir-dirclean redir-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(REDIR_SOURCE):
	$(WGET) -P $(DL_DIR) $(REDIR_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
redir-source: $(DL_DIR)/$(REDIR_SOURCE) $(REDIR_PATCHES)

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
$(REDIR_BUILD_DIR)/.configured: $(DL_DIR)/$(REDIR_SOURCE) $(REDIR_PATCHES) make/redir.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(REDIR_DIR) $(@D)
	$(REDIR_UNZIP) $(DL_DIR)/$(REDIR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(REDIR_PATCHES)" ; \
		then cat $(REDIR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(REDIR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(REDIR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(REDIR_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(REDIR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(REDIR_LDFLAGS)" \
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

redir-unpack: $(REDIR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(REDIR_BUILD_DIR)/.built: $(REDIR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(REDIR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(REDIR_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
redir: $(REDIR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(REDIR_BUILD_DIR)/.staged: $(REDIR_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

redir-stage: $(REDIR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/redir
#
$(REDIR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: redir" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(REDIR_PRIORITY)" >>$@
	@echo "Section: $(REDIR_SECTION)" >>$@
	@echo "Version: $(REDIR_VERSION)-$(REDIR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(REDIR_MAINTAINER)" >>$@
	@echo "Source: $(REDIR_SITE)/$(REDIR_SOURCE)" >>$@
	@echo "Description: $(REDIR_DESCRIPTION)" >>$@
	@echo "Depends: $(REDIR_DEPENDS)" >>$@
	@echo "Suggests: $(REDIR_SUGGESTS)" >>$@
	@echo "Conflicts: $(REDIR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(REDIR_IPK_DIR)/opt/sbin or $(REDIR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(REDIR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(REDIR_IPK_DIR)/opt/etc/redir/...
# Documentation files should be installed in $(REDIR_IPK_DIR)/opt/doc/redir/...
# Daemon startup scripts should be installed in $(REDIR_IPK_DIR)/opt/etc/init.d/S??redir
#
# You may need to patch your application to make it use these locations.
#
$(REDIR_IPK): $(REDIR_BUILD_DIR)/.built
	rm -rf $(REDIR_IPK_DIR) $(BUILD_DIR)/redir_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(REDIR_BUILD_DIR) DESTDIR=$(REDIR_IPK_DIR) install-strip
	install -d $(REDIR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(REDIR_BUILD_DIR)/redir -o $(REDIR_IPK_DIR)/opt/bin/redir
	install -d $(REDIR_IPK_DIR)/opt/share/man/man1
	install -m 644 $(REDIR_BUILD_DIR)/redir.man $(REDIR_IPK_DIR)/opt/share/man/man1/
	install -d $(REDIR_IPK_DIR)/opt/share/doc/redir
	install -m644 $(REDIR_BUILD_DIR)/[CR]* $(REDIR_BUILD_DIR)/transproxy.txt $(REDIR_IPK_DIR)/opt/share/doc/redir
	$(MAKE) $(REDIR_IPK_DIR)/CONTROL/control
	echo $(REDIR_CONFFILES) | sed -e 's/ /\n/g' > $(REDIR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(REDIR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
redir-ipk: $(REDIR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
redir-clean:
	rm -f $(REDIR_BUILD_DIR)/.built
	-$(MAKE) -C $(REDIR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
redir-dirclean:
	rm -rf $(BUILD_DIR)/$(REDIR_DIR) $(REDIR_BUILD_DIR) $(REDIR_IPK_DIR) $(REDIR_IPK)
#
#
# Some sanity check for the package.
#
redir-check: $(REDIR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(REDIR_IPK)
