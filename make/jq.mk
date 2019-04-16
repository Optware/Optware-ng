###########################################################
#
# jq
#
###########################################################
#
# JQ_VERSION, JQ_SITE and JQ_SOURCE define
# the upstream location of the source code for the package.
# JQ_DIR is the directory which is created when the source
# archive is unpacked.
# JQ_UNZIP is the command used to unzip the source.
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
JQ_URL=https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERSION)
JQ_VERSION=1.6
JQ_SOURCE=jq-$(JQ_VERSION).tar.gz
JQ_DIR=jq-$(JQ_VERSION)
JQ_UNZIP=zcat
JQ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
JQ_DESCRIPTION=Lightweight and flexible command-line JSON processor
JQ_SECTION=util
JQ_PRIORITY=optional
JQ_DEPENDS=oniguruma
JQ_SUGGESTS=
JQ_CONFLICTS=

#
# JQ_IPK_VERSION should be incremented when the ipk changes.
#
JQ_IPK_VERSION=1

#
# JQ_CONFFILES should be a list of user-editable files
#JQ_CONFFILES=$(TARGET_PREFIX)/etc/jq.conf $(TARGET_PREFIX)/etc/init.d/SXXjq

#
# JQ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JQ_PATCHES=$(JQ_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JQ_CPPFLAGS=
JQ_LDFLAGS=

#
# JQ_BUILD_DIR is the directory in which the build is done.
# JQ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JQ_IPK_DIR is the directory in which the ipk is built.
# JQ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JQ_BUILD_DIR=$(BUILD_DIR)/jq
JQ_SOURCE_DIR=$(SOURCE_DIR)/jq
JQ_IPK_DIR=$(BUILD_DIR)/jq-$(JQ_VERSION)-ipk
JQ_IPK=$(BUILD_DIR)/jq_$(JQ_VERSION)-$(JQ_IPK_VERSION)_$(TARGET_ARCH).ipk
JQ_DEV_IPK_DIR=$(BUILD_DIR)/jq-dev-$(JQ_VERSION)-ipk
JQ_DEV_IPK=$(BUILD_DIR)/jq-dev_$(JQ_VERSION)-$(JQ_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: jq-source jq-unpack jq jq-stage jq-ipk jq-clean jq-dirclean jq-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(JQ_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(JQ_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(JQ_SOURCE).sha512
#
$(DL_DIR)/$(JQ_SOURCE):
	$(WGET) -P $(@D) $(JQ_URL)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jq-source: $(DL_DIR)/$(JQ_SOURCE) $(JQ_PATCHES)

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
$(JQ_BUILD_DIR)/.configured: $(DL_DIR)/$(JQ_SOURCE) $(JQ_PATCHES) make/jq.mk
	$(MAKE) oniguruma-stage
	rm -rf $(BUILD_DIR)/$(JQ_DIR) $(@D)
	$(JQ_UNZIP) $(DL_DIR)/$(JQ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(JQ_PATCHES)" ; \
		then cat $(JQ_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(JQ_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(JQ_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(JQ_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JQ_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JQ_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-valgrind \
		--disable-docs \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

jq-unpack: $(JQ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JQ_BUILD_DIR)/.built: $(JQ_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@
#
# This is the build convenience target.
#
jq: $(JQ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JQ_BUILD_DIR)/.staged: $(JQ_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

jq-stage: $(JQ_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jq
#
$(JQ_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: jq" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JQ_PRIORITY)" >>$@
	@echo "Section: $(JQ_SECTION)" >>$@
	@echo "Version: $(JQ_VERSION)-$(JQ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JQ_MAINTAINER)" >>$@
	@echo "Source: $(JQ_URL)" >>$@
	@echo "Description: $(JQ_DESCRIPTION)" >>$@
	@echo "Depends: $(JQ_DEPENDS)" >>$@
	@echo "Suggests: $(JQ_SUGGESTS)" >>$@
	@echo "Conflicts: $(JQ_CONFLICTS)" >>$@

$(JQ_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: jq-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JQ_PRIORITY)" >>$@
	@echo "Section: $(JQ_SECTION)" >>$@
	@echo "Version: $(JQ_VERSION)-$(JQ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JQ_MAINTAINER)" >>$@
	@echo "Source: $(JQ_URL)" >>$@
	@echo "Description: Development files for JQ" >>$@
	@echo "Depends: jq" >>$@
	@echo "Suggests: $(JQ_SUGGESTS)" >>$@
	@echo "Conflicts: $(JQ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JQ_IPK_DIR)$(TARGET_PREFIX)/sbin or $(JQ_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JQ_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(JQ_IPK_DIR)$(TARGET_PREFIX)/etc/jq/...
# Documentation files should be installed in $(JQ_IPK_DIR)$(TARGET_PREFIX)/doc/jq/...
# Daemon startup scripts should be installed in $(JQ_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??jq
#
# You may need to patch your application to make it use these locations.
#
$(JQ_IPK) $(JQ_DEV_IPK): $(JQ_BUILD_DIR)/.built
	rm -rf	$(JQ_IPK_DIR) $(BUILD_DIR)/jq_*_$(TARGET_ARCH).ipk \
		$(JQ_DEV_IPK_DIR) $(BUILD_DIR)/jq-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(JQ_BUILD_DIR) DESTDIR=$(JQ_IPK_DIR) install-strip
	$(MAKE) -C $(JQ_BUILD_DIR) DESTDIR=$(JQ_DEV_IPK_DIR) install-strip
	rm -fr	$(JQ_IPK_DIR)$(TARGET_PREFIX)/include \
		$(JQ_IPK_DIR)$(TARGET_PREFIX)/lib/*.la \
		$(JQ_IPK_DIR)$(TARGET_PREFIX)/share/doc
	rm -fr	$(JQ_DEV_IPK_DIR)$(TARGET_PREFIX)/bin \
		$(JQ_DEV_IPK_DIR)$(TARGET_PREFIX)/lib \
		$(JQ_DEV_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(JQ_IPK_DIR)/CONTROL/control
	$(MAKE) $(JQ_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JQ_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JQ_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(JQ_IPK_DIR) $(JQ_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jq-ipk: $(JQ_IPK) $(JQ_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jq-clean:
	rm -f $(JQ_BUILD_DIR)/.built
	-$(MAKE) -C $(JQ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jq-dirclean:
	rm -rf $(BUILD_DIR)/$(JQ_DIR) $(JQ_BUILD_DIR) $(JQ_IPK_DIR) $(JQ_IPK) \
		$(JQ_DEV_IPK_DIR) $(JQ_DEV_IPK)
#
#
# Some sanity check for the package.
#
jq-check: $(JQ_IPK) $(JQ_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
