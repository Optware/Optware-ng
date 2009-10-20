###########################################################
#
# werc
#
###########################################################
#
# WERC_VERSION, WERC_SITE and WERC_SOURCE define
# the upstream location of the source code for the package.
# WERC_DIR is the directory which is created when the source
# archive is unpacked.
# WERC_UNZIP is the command used to unzip the source.
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
WERC_SITE=http://werc.cat-v.org/download
WERC_VERSION=1.2.3
WERC_SOURCE=werc-$(WERC_VERSION).tar.gz
WERC_DIR=werc-$(WERC_VERSION)
WERC_UNZIP=zcat
WERC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WERC_DESCRIPTION=A sane web anti-framework
WERC_SECTION=web
WERC_PRIORITY=optional
WERC_DEPENDS=9base
WERC_SUGGESTS=
WERC_CONFLICTS=

#
# WERC_IPK_VERSION should be incremented when the ipk changes.
#
WERC_IPK_VERSION=1

#
# WERC_CONFFILES should be a list of user-editable files
WERC_CONFFILES=/opt/share/www/werc/etc/initrc

#
# WERC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WERC_PATCHES=$(WERC_SOURCE_DIR)/path.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WERC_CPPFLAGS=
WERC_LDFLAGS=

#
# WERC_BUILD_DIR is the directory in which the build is done.
# WERC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WERC_IPK_DIR is the directory in which the ipk is built.
# WERC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WERC_BUILD_DIR=$(BUILD_DIR)/werc
WERC_SOURCE_DIR=$(SOURCE_DIR)/werc
WERC_IPK_DIR=$(BUILD_DIR)/werc-$(WERC_VERSION)-ipk
WERC_IPK=$(BUILD_DIR)/werc_$(WERC_VERSION)-$(WERC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: werc-source werc-unpack werc werc-stage werc-ipk werc-clean werc-dirclean werc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WERC_SOURCE):
	$(WGET) -P $(@D) $(WERC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
werc-source: $(DL_DIR)/$(WERC_SOURCE) $(WERC_PATCHES)

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
$(WERC_BUILD_DIR)/.configured: $(DL_DIR)/$(WERC_SOURCE) $(WERC_PATCHES) make/werc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(WERC_DIR) $(@D)
	$(WERC_UNZIP) $(DL_DIR)/$(WERC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WERC_PATCHES)" ; \
		then cat $(WERC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WERC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WERC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(WERC_DIR) $(@D) ; \
	fi
	sed -i -e '1s|#!.*|#!/opt/lib/9base/bin/rc|' $(@D)/bin/werc.rc
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WERC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WERC_LDFLAGS)" \
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

werc-unpack: $(WERC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WERC_BUILD_DIR)/.built: $(WERC_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
werc: $(WERC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WERC_BUILD_DIR)/.staged: $(WERC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

werc-stage: $(WERC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/werc
#
$(WERC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: werc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WERC_PRIORITY)" >>$@
	@echo "Section: $(WERC_SECTION)" >>$@
	@echo "Version: $(WERC_VERSION)-$(WERC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WERC_MAINTAINER)" >>$@
	@echo "Source: $(WERC_SITE)/$(WERC_SOURCE)" >>$@
	@echo "Description: $(WERC_DESCRIPTION)" >>$@
	@echo "Depends: $(WERC_DEPENDS)" >>$@
	@echo "Suggests: $(WERC_SUGGESTS)" >>$@
	@echo "Conflicts: $(WERC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WERC_IPK_DIR)/opt/sbin or $(WERC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WERC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WERC_IPK_DIR)/opt/etc/werc/...
# Documentation files should be installed in $(WERC_IPK_DIR)/opt/doc/werc/...
# Daemon startup scripts should be installed in $(WERC_IPK_DIR)/opt/etc/init.d/S??werc
#
# You may need to patch your application to make it use these locations.
#
$(WERC_IPK): $(WERC_BUILD_DIR)/.built
	rm -rf $(WERC_IPK_DIR) $(BUILD_DIR)/werc_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(WERC_BUILD_DIR) DESTDIR=$(WERC_IPK_DIR) install-strip
	install -d $(WERC_IPK_DIR)/opt/share/www
	rsync -av $(WERC_BUILD_DIR) $(WERC_IPK_DIR)/opt/share/www/
	rm -f $(WERC_IPK_DIR)/opt/share/www/werc/.configured \
	      $(WERC_IPK_DIR)/opt/share/www/werc/.built
	$(MAKE) $(WERC_IPK_DIR)/CONTROL/control
	echo $(WERC_CONFFILES) | sed -e 's/ /\n/g' > $(WERC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WERC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
werc-ipk: $(WERC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
werc-clean:
	rm -f $(WERC_BUILD_DIR)/.built
	-$(MAKE) -C $(WERC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
werc-dirclean:
	rm -rf $(BUILD_DIR)/$(WERC_DIR) $(WERC_BUILD_DIR) $(WERC_IPK_DIR) $(WERC_IPK)
#
#
# Some sanity check for the package.
#
werc-check: $(WERC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
