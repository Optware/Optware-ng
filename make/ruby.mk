###########################################################
#
# ruby
#
###########################################################

# You must replace "ruby" and "RUBY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# RUBY_VERSION, RUBY_SITE and RUBY_SOURCE define
# the upstream location of the source code for the package.
# RUBY_DIR is the directory which is created when the source
# archive is unpacked.
# RUBY_UNZIP is the command used to unzip the source.
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
RUBY_SITE=ftp://ftp.ruby-lang.org/pub/ruby
RUBY_VERSION=1.8.2
RUBY_SOURCE=ruby-$(RUBY_VERSION).tar.gz
RUBY_DIR=ruby-$(RUBY_VERSION)
RUBY_UNZIP=zcat
RUBY_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
RUBY_DESCRIPTION=Describe ruby here.
RUBY_SECTION=misc
RUBY_PRIORITY=optional
RUBY_DEPENDS=

#
# RUBY_IPK_VERSION should be incremented when the ipk changes.
#
RUBY_IPK_VERSION=1

#
# RUBY_CONFFILES should be a list of user-editable files
#RUBY_CONFFILES=/opt/etc/ruby.conf /opt/etc/init.d/SXXruby

#
# RUBY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RUBY_PATCHES=$(RUBY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RUBY_CPPFLAGS=
RUBY_LDFLAGS=

#
# RUBY_BUILD_DIR is the directory in which the build is done.
# RUBY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RUBY_IPK_DIR is the directory in which the ipk is built.
# RUBY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RUBY_BUILD_DIR=$(BUILD_DIR)/ruby
RUBY_SOURCE_DIR=$(SOURCE_DIR)/ruby
RUBY_IPK_DIR=$(BUILD_DIR)/ruby-$(RUBY_VERSION)-ipk
RUBY_IPK=$(BUILD_DIR)/ruby_$(RUBY_VERSION)-$(RUBY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RUBY_SOURCE):
	$(WGET) -P $(DL_DIR) $(RUBY_SITE)/$(RUBY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ruby-source: $(DL_DIR)/$(RUBY_SOURCE) $(RUBY_PATCHES)

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
$(RUBY_BUILD_DIR)/.configured: $(DL_DIR)/$(RUBY_SOURCE) $(RUBY_PATCHES)
	# $(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RUBY_DIR) $(RUBY_BUILD_DIR)
	$(RUBY_UNZIP) $(DL_DIR)/$(RUBY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	# cat $(RUBY_PATCHES) | patch -d $(BUILD_DIR)/$(RUBY_DIR) -p1
	mv $(BUILD_DIR)/$(RUBY_DIR) $(RUBY_BUILD_DIR)
	(cd $(RUBY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RUBY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RUBY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(RUBY_BUILD_DIR)/.configured

ruby-unpack: $(RUBY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RUBY_BUILD_DIR)/.built: $(RUBY_BUILD_DIR)/.configured
	rm -f $(RUBY_BUILD_DIR)/.built
	$(MAKE) -C $(RUBY_BUILD_DIR)
	touch $(RUBY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ruby: $(RUBY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RUBY_BUILD_DIR)/.staged: $(RUBY_BUILD_DIR)/.built
	rm -f $(RUBY_BUILD_DIR)/.staged
	$(MAKE) -C $(RUBY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RUBY_BUILD_DIR)/.staged

ruby-stage: $(RUBY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ruby
#
$(RUBY_IPK_DIR)/CONTROL/control:
	@install -d $(RUBY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ruby" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RUBY_PRIORITY)" >>$@
	@echo "Section: $(RUBY_SECTION)" >>$@
	@echo "Version: $(RUBY_VERSION)-$(RUBY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RUBY_MAINTAINER)" >>$@
	@echo "Source: $(RUBY_SITE)/$(RUBY_SOURCE)" >>$@
	@echo "Description: $(RUBY_DESCRIPTION)" >>$@
	@echo "Depends: $(RUBY_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RUBY_IPK_DIR)/opt/sbin or $(RUBY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RUBY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RUBY_IPK_DIR)/opt/etc/ruby/...
# Documentation files should be installed in $(RUBY_IPK_DIR)/opt/doc/ruby/...
# Daemon startup scripts should be installed in $(RUBY_IPK_DIR)/opt/etc/init.d/S??ruby
#
# You may need to patch your application to make it use these locations.
#
$(RUBY_IPK): $(RUBY_BUILD_DIR)/.built
	rm -rf $(RUBY_IPK_DIR) $(BUILD_DIR)/ruby_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RUBY_BUILD_DIR) DESTDIR=$(RUBY_IPK_DIR) install
	install -d $(RUBY_IPK_DIR)/opt/etc/
	$(MAKE) $(RUBY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RUBY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ruby-ipk: $(RUBY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ruby-clean:
	-$(MAKE) -C $(RUBY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ruby-dirclean:
	rm -rf $(BUILD_DIR)/$(RUBY_DIR) $(RUBY_BUILD_DIR) $(RUBY_IPK_DIR) $(RUBY_IPK)
