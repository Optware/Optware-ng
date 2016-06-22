###########################################################
#
# rubygems
#
###########################################################

#
# RUBYGEMS_VERSION, RUBYGEMS_SITE and RUBYGEMS_SOURCE define
# the upstream location of the source code for the package.
# RUBYGEMS_DIR is the directory which is created when the source
# archive is unpacked.
# RUBYGEMS_UNZIP is the command used to unzip the source.
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
RUBYGEMS_SITE=http://production.cf.rubygems.org/rubygems
ifneq (wl500g, $(OPTWARE_TARGET))
RUBYGEMS_VERSION=2.6.5
else
RUBYGEMS_VERSION=1.1.1
endif
RUBYGEMS_SOURCE=rubygems-$(RUBYGEMS_VERSION).tgz
RUBYGEMS_DIR=rubygems-$(RUBYGEMS_VERSION)
RUBYGEMS_UNZIP=zcat
RUBYGEMS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RUBYGEMS_DESCRIPTION=Ruby packaging and installation framework.
RUBYGEMS_SECTION=misc
RUBYGEMS_PRIORITY=optional
RUBYGEMS_DEPENDS=ruby (>= ${RUBY_VERSION}-${RUBY_IPK_VERSION})
RUBYGEMS_SUGGESTS=
RUBYGEMS_CONFLICTS=

#
# RUBYGEMS_IPK_VERSION should be incremented when the ipk changes.
#
RUBYGEMS_IPK_VERSION=1

#
# RUBYGEMS_CONFFILES should be a list of user-editable files
#RUBYGEMS_CONFFILES=$(TARGET_PREFIX)/etc/rubygems.conf $(TARGET_PREFIX)/etc/init.d/SXXrubygems

#
# RUBYGEMS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (wl500g, $(OPTWARE_TARGET))
RUBYGEMS_PATCHES=\
	$(RUBYGEMS_SOURCE_DIR)/hash-bang-path.patch \
	$(RUBYGEMS_SOURCE_DIR)/install-lib-dir.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RUBYGEMS_CPPFLAGS=
RUBYGEMS_LDFLAGS=

#
# RUBYGEMS_BUILD_DIR is the directory in which the build is done.
# RUBYGEMS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RUBYGEMS_IPK_DIR is the directory in which the ipk is built.
# RUBYGEMS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RUBYGEMS_BUILD_DIR=$(BUILD_DIR)/rubygems
RUBYGEMS_SOURCE_DIR=$(SOURCE_DIR)/rubygems
RUBYGEMS_IPK_DIR=$(BUILD_DIR)/rubygems-$(RUBYGEMS_VERSION)-ipk
RUBYGEMS_IPK=$(BUILD_DIR)/rubygems_$(RUBYGEMS_VERSION)-$(RUBYGEMS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rubygems-source rubygems-unpack rubygems rubygems-stage rubygems-ipk rubygems-clean rubygems-dirclean rubygems-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RUBYGEMS_SOURCE):
	$(WGET) -P $(DL_DIR) $(RUBYGEMS_SITE)/$(RUBYGEMS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(RUBYGEMS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rubygems-source: $(DL_DIR)/$(RUBYGEMS_SOURCE) $(RUBYGEMS_PATCHES)

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
$(RUBYGEMS_BUILD_DIR)/.configured: $(DL_DIR)/$(RUBYGEMS_SOURCE) $(RUBYGEMS_PATCHES) make/rubygems.mk
#	$(MAKE) ruby-stage
	rm -rf $(BUILD_DIR)/$(RUBYGEMS_DIR) $(RUBYGEMS_BUILD_DIR)
	$(RUBYGEMS_UNZIP) $(DL_DIR)/$(RUBYGEMS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RUBYGEMS_PATCHES)" ; \
		then cat $(RUBYGEMS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RUBYGEMS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RUBYGEMS_DIR)" != "$(RUBYGEMS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RUBYGEMS_DIR) $(RUBYGEMS_BUILD_DIR) ; \
	fi
	touch $(RUBYGEMS_BUILD_DIR)/.configured

rubygems-unpack: $(RUBYGEMS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RUBYGEMS_BUILD_DIR)/.built: $(RUBYGEMS_BUILD_DIR)/.configured
	rm -f $(RUBYGEMS_BUILD_DIR)/.built
	touch $(RUBYGEMS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rubygems: $(RUBYGEMS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RUBYGEMS_BUILD_DIR)/.staged: $(RUBYGEMS_BUILD_DIR)/.built
	rm -f $(RUBYGEMS_BUILD_DIR)/.staged
	$(MAKE) -C $(RUBYGEMS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RUBYGEMS_BUILD_DIR)/.staged

rubygems-stage: $(RUBYGEMS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rubygems
#
$(RUBYGEMS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(RUBYGEMS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rubygems" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RUBYGEMS_PRIORITY)" >>$@
	@echo "Section: $(RUBYGEMS_SECTION)" >>$@
	@echo "Version: $(RUBYGEMS_VERSION)-$(RUBYGEMS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RUBYGEMS_MAINTAINER)" >>$@
	@echo "Source: $(RUBYGEMS_SITE)/$(RUBYGEMS_SOURCE)" >>$@
	@echo "Description: $(RUBYGEMS_DESCRIPTION)" >>$@
	@echo "Depends: $(RUBYGEMS_DEPENDS)" >>$@
	@echo "Suggests: $(RUBYGEMS_SUGGESTS)" >>$@
	@echo "Conflicts: $(RUBYGEMS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/etc/rubygems/...
# Documentation files should be installed in $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/doc/rubygems/...
# Daemon startup scripts should be installed in $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??rubygems
#
# You may need to patch your application to make it use these locations.
#
#		-r$(STAGING_LIB_DIR)/ruby/1.8/armv5b-linux/rbconfig.rb \
		-r $(RUBYGEMS_SOURCE_DIR)/destdir.rb \
#
$(RUBYGEMS_IPK): $(RUBYGEMS_BUILD_DIR)/.built
	$(MAKE) ruby-host-stage
	rm -rf $(RUBYGEMS_IPK_DIR) $(BUILD_DIR)/rubygems_*_$(TARGET_ARCH).ipk
	$(RUBY_HOST_RUBY) -C $(RUBYGEMS_BUILD_DIR) setup.rb all \
		--prefix=$(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)
	sed -i -e '0,/^#!/s|^#!.*|#!$(TARGET_PREFIX)/bin/ruby|' $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/bin/gem
	mv -f $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/bin/gem $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/bin/rubygems-gem
ifeq (wl500g, $(OPTWARE_TARGET))
	$(INSTALL) -d $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/share/doc/rubygems
	cp -R $(RUBYGEMS_BUILD_DIR)/doc/* $(RUBYGEMS_IPK_DIR)$(TARGET_PREFIX)/share/doc/rubygems
endif
	$(MAKE) $(RUBYGEMS_IPK_DIR)/CONTROL/control
	echo -e "#!/bin/sh\nupdate-alternatives --install '$(TARGET_PREFIX)/bin/gem' 'gem' $(TARGET_PREFIX)/bin/rubygems-gem 40" > \
		$(RUBYGEMS_IPK_DIR)/CONTROL/postinst
	echo -e "#!/bin/sh\nupdate-alternatives --remove 'gem' $(TARGET_PREFIX)/bin/rubygems-gem" > \
		$(RUBYGEMS_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
		$(RUBYGEMS_IPK_DIR)/CONTROL/postinst $(RUBYGEMS_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(RUBYGEMS_IPK_DIR)/CONTROL/postinst
	chmod 755 $(RUBYGEMS_IPK_DIR)/CONTROL/prerm
	echo $(RUBYGEMS_CONFFILES) | sed -e 's/ /\n/g' > $(RUBYGEMS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RUBYGEMS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rubygems-ipk: $(RUBYGEMS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rubygems-clean:
	rm -f $(RUBYGEMS_BUILD_DIR)/.built
	-$(MAKE) -C $(RUBYGEMS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rubygems-dirclean:
	rm -rf $(BUILD_DIR)/$(RUBYGEMS_DIR) $(RUBYGEMS_BUILD_DIR) $(RUBYGEMS_IPK_DIR) $(RUBYGEMS_IPK)

#
# Some sanity check for the package.
#
rubygems-check: $(RUBYGEMS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RUBYGEMS_IPK)
