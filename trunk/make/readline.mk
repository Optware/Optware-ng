###########################################################
#
# readline
#
###########################################################

# You must replace "readline" and "READLINE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# READLINE_VERSION, READLINE_SITE and READLINE_SOURCE define
# the upstream location of the source code for the package.
# READLINE_DIR is the directory which is created when the source
# archive is unpacked.
# READLINE_UNZIP is the command used to unzip the source.
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
READLINE_SITE=ftp://ftp.cwru.edu/pub/bash
READLINE_VERSION=5.2
READLINE_SOURCE=readline-$(READLINE_VERSION).tar.gz
READLINE_DIR=readline-$(READLINE_VERSION)
READLINE_UNZIP=zcat
READLINE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
READLINE_DESCRIPTION=The GNU Readline library provides a set of functions for use by applications that allow users to edit command lines as they are typed in
READLINE_SECTION=misc
READLINE_PRIORITY=optional
READLINE_DEPENDS=

#
# READLINE_IPK_VERSION should be incremented when the ipk changes.
#
READLINE_IPK_VERSION=2

#
# READLINE_CONFFILES should be a list of user-editable files
#READLINE_CONFFILES=/opt/etc/readline.conf /opt/etc/init.d/SXXreadline

#
# READLINE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#READLINE_PATCHES=$(READLINE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
READLINE_CPPFLAGS=
READLINE_LDFLAGS=

#
# READLINE_BUILD_DIR is the directory in which the build is done.
# READLINE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# READLINE_IPK_DIR is the directory in which the ipk is built.
# READLINE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
READLINE_BUILD_DIR=$(BUILD_DIR)/readline
READLINE_SOURCE_DIR=$(SOURCE_DIR)/readline
READLINE_IPK_DIR=$(BUILD_DIR)/readline-$(READLINE_VERSION)-ipk
READLINE_IPK=$(BUILD_DIR)/readline_$(READLINE_VERSION)-$(READLINE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: readline-source readline-unpack readline readline-stage readline-ipk readline-clean readline-dirclean readline-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(READLINE_SOURCE):
	$(WGET) -P $(DL_DIR) $(READLINE_SITE)/$(READLINE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
readline-source: $(DL_DIR)/$(READLINE_SOURCE) $(READLINE_PATCHES)

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
$(READLINE_BUILD_DIR)/.configured: $(DL_DIR)/$(READLINE_SOURCE) $(READLINE_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(READLINE_DIR) $(READLINE_BUILD_DIR)
	$(READLINE_UNZIP) $(DL_DIR)/$(READLINE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(READLINE_PATCHES) | patch -d $(BUILD_DIR)/$(READLINE_DIR) -p1
	mv $(BUILD_DIR)/$(READLINE_DIR) $(READLINE_BUILD_DIR)
	cp $(SOURCE_DIR)/common/config.sub $(READLINE_BUILD_DIR)/support/
	(cd $(READLINE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(READLINE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(READLINE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(READLINE_BUILD_DIR)/.configured

readline-unpack: $(READLINE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(READLINE_BUILD_DIR)/.built: $(READLINE_BUILD_DIR)/.configured
	rm -f $(READLINE_BUILD_DIR)/.built
	$(MAKE) -C $(READLINE_BUILD_DIR)
	touch $(READLINE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
readline: $(READLINE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(READLINE_BUILD_DIR)/.staged: $(READLINE_BUILD_DIR)/.built
	rm -f $(READLINE_BUILD_DIR)/.staged
	$(MAKE) -C $(READLINE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(READLINE_BUILD_DIR)/.staged

readline-stage: $(READLINE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/readline
#
$(READLINE_IPK_DIR)/CONTROL/control:
	@install -d $(READLINE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: readline" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(READLINE_PRIORITY)" >>$@
	@echo "Section: $(READLINE_SECTION)" >>$@
	@echo "Version: $(READLINE_VERSION)-$(READLINE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(READLINE_MAINTAINER)" >>$@
	@echo "Source: $(READLINE_SITE)/$(READLINE_SOURCE)" >>$@
	@echo "Description: $(READLINE_DESCRIPTION)" >>$@
	@echo "Depends: $(READLINE_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(READLINE_IPK_DIR)/opt/sbin or $(READLINE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(READLINE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(READLINE_IPK_DIR)/opt/etc/readline/...
# Documentation files should be installed in $(READLINE_IPK_DIR)/opt/doc/readline/...
# Daemon startup scripts should be installed in $(READLINE_IPK_DIR)/opt/etc/init.d/S??readline
#
# You may need to patch your application to make it use these locations.
#
$(READLINE_IPK): $(READLINE_BUILD_DIR)/.built
	rm -rf $(READLINE_IPK_DIR) $(BUILD_DIR)/readline_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(READLINE_BUILD_DIR) DESTDIR=$(READLINE_IPK_DIR) install
	(cd $(READLINE_IPK_DIR)/opt/lib/ ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(READLINE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(READLINE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
readline-ipk: $(READLINE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
readline-clean:
	-$(MAKE) -C $(READLINE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
readline-dirclean:
	rm -rf $(BUILD_DIR)/$(READLINE_DIR) $(READLINE_BUILD_DIR) $(READLINE_IPK_DIR) $(READLINE_IPK)

#
# Some sanity check for the package.
#
readline-check: $(READLINE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(READLINE_IPK)
