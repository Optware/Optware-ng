###########################################################
#
# gzip
#
###########################################################

# You must replace "gzip" and "GZIP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GZIP_VERSION, GZIP_SITE and GZIP_SOURCE define
# the upstream location of the source code for the package.
# GZIP_DIR is the directory which is created when the source
# archive is unpacked.
# GZIP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GZIP_SITE=http://ftp.gnu.org/pub/gnu/gzip
GZIP_VERSION=1.2.4a
GZIP_SOURCE=gzip-$(GZIP_VERSION).tar.gz
GZIP_DIR=gzip-$(GZIP_VERSION)
GZIP_UNZIP=zcat
GZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GZIP_DESCRIPTION=GNU Zip data compression program
GZIP_SECTION=compression
GZIP_PRIORITY=optional
GZIP_DEPENDS=
GZIP_CONFLICTS=

#
# GZIP_IPK_VERSION should be incremented when the ipk changes.
#
GZIP_IPK_VERSION=2

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GZIP_CPPFLAGS=
GZIP_LDFLAGS=

#
# GZIP_BUILD_DIR is the directory in which the build is done.
# GZIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GZIP_IPK_DIR is the directory in which the ipk is built.
# GZIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GZIP_BUILD_DIR=$(BUILD_DIR)/gzip
GZIP_SOURCE_DIR=$(SOURCE_DIR)/gzip
GZIP_IPK_DIR=$(BUILD_DIR)/gzip-$(GZIP_VERSION)-ipk
GZIP_IPK=$(BUILD_DIR)/gzip_$(GZIP_VERSION)-$(GZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GZIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(GZIP_SITE)/$(GZIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gzip-source: $(DL_DIR)/$(GZIP_SOURCE) $(GZIP_PATCHES)

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
$(GZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(GZIP_SOURCE) $(GZIP_PATCHES)
	rm -rf $(BUILD_DIR)/$(GZIP_DIR) $(GZIP_BUILD_DIR)
	$(GZIP_UNZIP) $(DL_DIR)/$(GZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(GZIP_DIR) $(GZIP_BUILD_DIR)
	(cd $(GZIP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GZIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GZIP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

gzip-unpack: $(GZIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GZIP_BUILD_DIR)/.built: $(GZIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GZIP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gzip: $(GZIP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gzip
#
$(GZIP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gzip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GZIP_PRIORITY)" >>$@
	@echo "Section: $(GZIP_SECTION)" >>$@
	@echo "Version: $(GZIP_VERSION)-$(GZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GZIP_MAINTAINER)" >>$@
	@echo "Source: $(GZIP_SITE)/$(GZIP_SOURCE)" >>$@
	@echo "Description: $(GZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(GZIP_DEPENDS)" >>$@
	@echo "Conflicts: $(GZIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GZIP_IPK_DIR)/opt/sbin or $(GZIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GZIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GZIP_IPK_DIR)/opt/etc/gzip/...
# Documentation files should be installed in $(GZIP_IPK_DIR)/opt/doc/gzip/...
# Daemon startup scripts should be installed in $(GZIP_IPK_DIR)/opt/etc/init.d/S??gzip
#
# You may need to patch your application to make it use these locations.
#
$(GZIP_IPK): $(GZIP_BUILD_DIR)/.built
	rm -rf $(GZIP_IPK_DIR) $(BUILD_DIR)/gzip_*_$(TARGET_ARCH).ipk
	install -d $(GZIP_IPK_DIR)/opt/bin
	install -d $(GZIP_IPK_DIR)/opt/lib
	install -d $(GZIP_IPK_DIR)/opt/info
	install -d $(GZIP_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(GZIP_BUILD_DIR) prefix=$(GZIP_IPK_DIR)/opt install
	$(MAKE) $(GZIP_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(GZIP_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(GZIP_IPK_DIR)/CONTROL/prerm
	cd $(GZIP_IPK_DIR)/opt/bin; \
	for f in gunzip gzip zcat; do \
	    mv $$f gzip-$$f; \
	    $(STRIP_COMMAND) gzip-$$f; \
	    echo "update-alternatives --install /opt/bin/$$f $$f /opt/bin/gzip-$$f 80" \
		>> $(GZIP_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/bin/gzip-$$f" \
		>> $(GZIP_IPK_DIR)/CONTROL/prerm; \
	done
	echo $(GZIP_CONFFILES) | sed -e 's/ /\n/g' > $(GZIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GZIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gzip-ipk: $(GZIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gzip-clean:
	-$(MAKE) -C $(GZIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gzip-dirclean:
	rm -rf $(BUILD_DIR)/$(GZIP_DIR) $(GZIP_BUILD_DIR) $(GZIP_IPK_DIR) $(GZIP_IPK)

#
# Some sanity check for the package.
#
gzip-check: $(GZIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GZIP_IPK)
