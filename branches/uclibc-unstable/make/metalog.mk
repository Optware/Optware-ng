###########################################################
#
# metalog
#
###########################################################

# You must replace "metalog" and "METALOG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# METALOG_VERSION, METALOG_SITE and METALOG_SOURCE define
# the upstream location of the source code for the package.
# METALOG_DIR is the directory which is created when the source
# archive is unpacked.
# METALOG_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
METALOG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/metalog
METALOG_VERSION=0.7
METALOG_SOURCE=metalog-$(METALOG_VERSION).tar.gz
METALOG_DIR=metalog-$(METALOG_VERSION)
METALOG_UNZIP=zcat
METALOG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
METALOG_DESCRIPTION=Modern, highly configurable syslogd replacement
METALOG_SECTION=sys
METALOG_PRIORITY=optional
METALOG_DEPENDS=pcre
METALOG_SUGGESTS=
METALOG_CONFLICTS=

#
# METALOG_IPK_VERSION should be incremented when the ipk changes.
#
METALOG_IPK_VERSION=4

#
# METALOG_CONFFILES should be a list of user-editable files
METALOG_CONFFILES=/opt/etc/metalog.conf

#
# METALOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
METALOG_PATCHES=$(METALOG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
METALOG_CPPFLAGS=
METALOG_LDFLAGS=

#
# METALOG_BUILD_DIR is the directory in which the build is done.
# METALOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# METALOG_IPK_DIR is the directory in which the ipk is built.
# METALOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
METALOG_BUILD_DIR=$(BUILD_DIR)/metalog
METALOG_SOURCE_DIR=$(SOURCE_DIR)/metalog
METALOG_IPK_DIR=$(BUILD_DIR)/metalog-$(METALOG_VERSION)-ipk
METALOG_IPK=$(BUILD_DIR)/metalog_$(METALOG_VERSION)-$(METALOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: metalog-source metalog-unpack metalog metalog-stage metalog-ipk metalog-clean metalog-dirclean metalog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(METALOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(METALOG_SITE)/$(METALOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
metalog-source: $(DL_DIR)/$(METALOG_SOURCE) $(METALOG_PATCHES)

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
$(METALOG_BUILD_DIR)/.configured: $(DL_DIR)/$(METALOG_SOURCE) $(METALOG_PATCHES)
	$(MAKE) pcre-stage 
	rm -rf $(BUILD_DIR)/$(METALOG_DIR) $(METALOG_BUILD_DIR)
	$(METALOG_UNZIP) $(DL_DIR)/$(METALOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(METALOG_PATCHES) | patch -d $(BUILD_DIR)/$(METALOG_DIR) -p1
	mv $(BUILD_DIR)/$(METALOG_DIR) $(METALOG_BUILD_DIR)
	(cd $(METALOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(METALOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(METALOG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(METALOG_BUILD_DIR)/.configured

metalog-unpack: $(METALOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(METALOG_BUILD_DIR)/.built: $(METALOG_BUILD_DIR)/.configured
	rm -f $(METALOG_BUILD_DIR)/.built
	$(MAKE) -C $(METALOG_BUILD_DIR)
	touch $(METALOG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
metalog: $(METALOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(METALOG_BUILD_DIR)/.staged: $(METALOG_BUILD_DIR)/.built
	rm -f $(METALOG_BUILD_DIR)/.staged
#	$(MAKE) -C $(METALOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(METALOG_BUILD_DIR)/.staged

metalog-stage: $(METALOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/metalog
#
$(METALOG_IPK_DIR)/CONTROL/control:
	@install -d $(METALOG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: metalog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(METALOG_PRIORITY)" >>$@
	@echo "Section: $(METALOG_SECTION)" >>$@
	@echo "Version: $(METALOG_VERSION)-$(METALOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(METALOG_MAINTAINER)" >>$@
	@echo "Source: $(METALOG_SITE)/$(METALOG_SOURCE)" >>$@
	@echo "Description: $(METALOG_DESCRIPTION)" >>$@
	@echo "Depends: $(METALOG_DEPENDS)" >>$@
	@echo "Suggests: $(METALOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(METALOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(METALOG_IPK_DIR)/opt/sbin or $(METALOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(METALOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(METALOG_IPK_DIR)/opt/etc/metalog/...
# Documentation files should be installed in $(METALOG_IPK_DIR)/opt/doc/metalog/...
# Daemon startup scripts should be installed in $(METALOG_IPK_DIR)/opt/etc/init.d/S??metalog
#
# You may need to patch your application to make it use these locations.
#
$(METALOG_IPK): $(METALOG_BUILD_DIR)/.built
	rm -rf $(METALOG_IPK_DIR) $(BUILD_DIR)/metalog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(METALOG_BUILD_DIR) DESTDIR=$(METALOG_IPK_DIR) install
	$(STRIP_COMMAND) $(METALOG_IPK_DIR)/opt/sbin/metalog
	$(MAKE) -C $(METALOG_BUILD_DIR) DESTDIR=$(METALOG_IPK_DIR) install-man
	install -d $(METALOG_IPK_DIR)/opt/etc/
	install -m 755 $(METALOG_SOURCE_DIR)/metalog.conf $(METALOG_IPK_DIR)/opt/etc/metalog.conf
	install -d $(METALOG_IPK_DIR)/opt/doc/metalog
	install -m 755 $(METALOG_SOURCE_DIR)/rc.sysinit $(METALOG_IPK_DIR)/opt/doc/metalog
	# Make log directory on HD
	install -d $(METALOG_IPK_DIR)/opt/var/log
	$(MAKE) $(METALOG_IPK_DIR)/CONTROL/control
	install -m 644 $(METALOG_SOURCE_DIR)/postinst $(METALOG_IPK_DIR)/CONTROL/postinst
	install -m 644 $(METALOG_SOURCE_DIR)/prerm $(METALOG_IPK_DIR)/CONTROL/prerm
	echo $(METALOG_CONFFILES) | sed -e 's/ /\n/g' > $(METALOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(METALOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
metalog-ipk: $(METALOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
metalog-clean:
	-$(MAKE) -C $(METALOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
metalog-dirclean:
	rm -rf $(BUILD_DIR)/$(METALOG_DIR) $(METALOG_BUILD_DIR) $(METALOG_IPK_DIR) $(METALOG_IPK)

#
# Some sanity check for the package.
#
metalog-check: $(METALOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(METALOG_IPK)
