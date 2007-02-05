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
RUBYGEMS_SITE=http://rubyforge.org/frs/download.php/16452
RUBYGEMS_VERSION=0.9.1
RUBYGEMS_SOURCE=rubygems-$(RUBYGEMS_VERSION).tgz
RUBYGEMS_DIR=rubygems-$(RUBYGEMS_VERSION)
RUBYGEMS_UNZIP=zcat
RUBYGEMS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RUBYGEMS_DESCRIPTION=Ruby packaging and installation framework.
RUBYGEMS_SECTION=misc
RUBYGEMS_PRIORITY=optional
RUBYGEMS_DEPENDS=ruby (>= 1.8.4-2)
RUBYGEMS_SUGGESTS=
RUBYGEMS_CONFLICTS=

#
# RUBYGEMS_IPK_VERSION should be incremented when the ipk changes.
#
RUBYGEMS_IPK_VERSION=1

#
# RUBYGEMS_CONFFILES should be a list of user-editable files
#RUBYGEMS_CONFFILES=/opt/etc/rubygems.conf /opt/etc/init.d/SXXrubygems

#
# RUBYGEMS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RUBYGEMS_PATCHES=\
	$(RUBYGEMS_SOURCE_DIR)/lib-rubygems.rb.patch \

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
$(RUBYGEMS_BUILD_DIR)/.configured: $(DL_DIR)/$(RUBYGEMS_SOURCE) $(RUBYGEMS_PATCHES)
#	$(MAKE) ruby-stage
	rm -rf $(BUILD_DIR)/$(RUBYGEMS_DIR) $(RUBYGEMS_BUILD_DIR)
	$(RUBYGEMS_UNZIP) $(DL_DIR)/$(RUBYGEMS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RUBYGEMS_PATCHES)" ; \
		then cat $(RUBYGEMS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RUBYGEMS_DIR) -p1 ; \
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
	@install -d $(RUBYGEMS_IPK_DIR)/CONTROL
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
# Binaries should be installed into $(RUBYGEMS_IPK_DIR)/opt/sbin or $(RUBYGEMS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RUBYGEMS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RUBYGEMS_IPK_DIR)/opt/etc/rubygems/...
# Documentation files should be installed in $(RUBYGEMS_IPK_DIR)/opt/doc/rubygems/...
# Daemon startup scripts should be installed in $(RUBYGEMS_IPK_DIR)/opt/etc/init.d/S??rubygems
#
# You may need to patch your application to make it use these locations.
#
#		-r$(STAGING_LIB_DIR)/ruby/1.8/armv5b-linux/rbconfig.rb \
		-r $(RUBYGEMS_SOURCE_DIR)/destdir.rb \
#
$(RUBYGEMS_IPK): $(RUBYGEMS_BUILD_DIR)/.built
	$(MAKE) ruby-host-stage
	rm -rf $(RUBYGEMS_IPK_DIR) $(BUILD_DIR)/rubygems_*_$(TARGET_ARCH).ipk
	DESTDIR=$(RUBYGEMS_IPK_DIR) \
	GEM_HOME=$(RUBYGEMS_IPK_DIR)/opt/local/lib/ruby/gems/1.8 \
	$(RUBY_HOST_RUBY) -C $(RUBYGEMS_BUILD_DIR) setup.rb all \
		--prefix=$(RUBYGEMS_IPK_DIR)/opt \
		--siteruby='$$prefix/lib/ruby'
	install -d $(RUBYGEMS_IPK_DIR)/opt/local/bin
	install -d $(RUBYGEMS_IPK_DIR)/opt/share/doc/rubygems/{examples,gemspecs}
	cp -R $(RUBYGEMS_BUILD_DIR)/doc/* $(RUBYGEMS_IPK_DIR)/opt/share/doc/rubygems
	cp -R $(RUBYGEMS_BUILD_DIR)/examples $(RUBYGEMS_IPK_DIR)/opt/share/doc/rubygems/examples
	cp -R $(RUBYGEMS_BUILD_DIR)/gemspecs $(RUBYGEMS_IPK_DIR)/opt/share/doc/rubygems/gemspecs
	$(MAKE) $(RUBYGEMS_IPK_DIR)/CONTROL/control
#	install -m 755 $(RUBYGEMS_SOURCE_DIR)/postinst $(RUBYGEMS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RUBYGEMS_SOURCE_DIR)/prerm $(RUBYGEMS_IPK_DIR)/CONTROL/prerm
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
