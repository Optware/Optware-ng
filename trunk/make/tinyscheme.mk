###########################################################
#
# tinyscheme
#
###########################################################
#
# TINYSCHEME_VERSION, TINYSCHEME_SITE and TINYSCHEME_SOURCE define
# the upstream location of the source code for the package.
# TINYSCHEME_DIR is the directory which is created when the source
# archive is unpacked.
# TINYSCHEME_UNZIP is the command used to unzip the source.
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
TINYSCHEME_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tinyscheme
TINYSCHEME_VERSION=1.37
TINYSCHEME_SOURCE=tinyscheme$(TINYSCHEME_VERSION).zip
TINYSCHEME_DIR=tinyscheme$(TINYSCHEME_VERSION)
TINYSCHEME_UNZIP=unzip
TINYSCHEME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TINYSCHEME_DESCRIPTION=An implementation of the algorithmic language Scheme that aims to very small memory footprint while being as close to R5RS as practically feasible.
TINYSCHEME_SECTION=interpreter
TINYSCHEME_PRIORITY=optional
TINYSCHEME_DEPENDS=
TINYSCHEME_SUGGESTS=
TINYSCHEME_CONFLICTS=

#
# TINYSCHEME_IPK_VERSION should be incremented when the ipk changes.
#
TINYSCHEME_IPK_VERSION=1

#
# TINYSCHEME_CONFFILES should be a list of user-editable files
#TINYSCHEME_CONFFILES=/opt/etc/tinyscheme.conf /opt/etc/init.d/SXXtinyscheme

#
# TINYSCHEME_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TINYSCHEME_PATCHES=$(TINYSCHEME_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TINYSCHEME_CPPFLAGS=
TINYSCHEME_LDFLAGS=

#
# TINYSCHEME_BUILD_DIR is the directory in which the build is done.
# TINYSCHEME_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TINYSCHEME_IPK_DIR is the directory in which the ipk is built.
# TINYSCHEME_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TINYSCHEME_BUILD_DIR=$(BUILD_DIR)/tinyscheme
TINYSCHEME_SOURCE_DIR=$(SOURCE_DIR)/tinyscheme
TINYSCHEME_IPK_DIR=$(BUILD_DIR)/tinyscheme-$(TINYSCHEME_VERSION)-ipk
TINYSCHEME_IPK=$(BUILD_DIR)/tinyscheme_$(TINYSCHEME_VERSION)-$(TINYSCHEME_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tinyscheme-source tinyscheme-unpack tinyscheme tinyscheme-stage tinyscheme-ipk tinyscheme-clean tinyscheme-dirclean tinyscheme-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TINYSCHEME_SOURCE):
	$(WGET) -P $(DL_DIR) $(TINYSCHEME_SITE)/$(TINYSCHEME_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tinyscheme-source: $(DL_DIR)/$(TINYSCHEME_SOURCE) $(TINYSCHEME_PATCHES)

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
$(TINYSCHEME_BUILD_DIR)/.configured: $(DL_DIR)/$(TINYSCHEME_SOURCE) $(TINYSCHEME_PATCHES) make/tinyscheme.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TINYSCHEME_DIR) $(TINYSCHEME_BUILD_DIR)
	mkdir -p $(TINYSCHEME_BUILD_DIR)
	cd $(TINYSCHEME_BUILD_DIR) && $(TINYSCHEME_UNZIP) $(DL_DIR)/$(TINYSCHEME_SOURCE)
	if test -n "$(TINYSCHEME_PATCHES)" ; \
		then cat $(TINYSCHEME_PATCHES) | \
		patch -d $(TINYSCHEME_BUILD_DIR) -p0 ; \
	fi
#	(cd $(TINYSCHEME_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TINYSCHEME_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TINYSCHEME_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TINYSCHEME_BUILD_DIR)/libtool
	touch $(TINYSCHEME_BUILD_DIR)/.configured

tinyscheme-unpack: $(TINYSCHEME_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TINYSCHEME_BUILD_DIR)/.built: $(TINYSCHEME_BUILD_DIR)/.configured
	rm -f $(TINYSCHEME_BUILD_DIR)/.built
	$(MAKE) -C $(TINYSCHEME_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		AR="$(TARGET_AR) crs" \
		PLATFORM_FEATURES=-DInitFile=\\\"/opt/lib/tinyscheme/init.scm\\\" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TINYSCHEME_CPPFLAGS)" \
		LDFLAGS="-shared $(STAGING_LDFLAGS) $(TINYSCHEME_LDFLAGS)"
	touch $(TINYSCHEME_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tinyscheme: $(TINYSCHEME_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TINYSCHEME_BUILD_DIR)/.staged: $(TINYSCHEME_BUILD_DIR)/.built
	rm -f $(TINYSCHEME_BUILD_DIR)/.staged
	$(MAKE) -C $(TINYSCHEME_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TINYSCHEME_BUILD_DIR)/.staged

tinyscheme-stage: $(TINYSCHEME_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tinyscheme
#
$(TINYSCHEME_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tinyscheme" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TINYSCHEME_PRIORITY)" >>$@
	@echo "Section: $(TINYSCHEME_SECTION)" >>$@
	@echo "Version: $(TINYSCHEME_VERSION)-$(TINYSCHEME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TINYSCHEME_MAINTAINER)" >>$@
	@echo "Source: $(TINYSCHEME_SITE)/$(TINYSCHEME_SOURCE)" >>$@
	@echo "Description: $(TINYSCHEME_DESCRIPTION)" >>$@
	@echo "Depends: $(TINYSCHEME_DEPENDS)" >>$@
	@echo "Suggests: $(TINYSCHEME_SUGGESTS)" >>$@
	@echo "Conflicts: $(TINYSCHEME_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TINYSCHEME_IPK_DIR)/opt/sbin or $(TINYSCHEME_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TINYSCHEME_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TINYSCHEME_IPK_DIR)/opt/etc/tinyscheme/...
# Documentation files should be installed in $(TINYSCHEME_IPK_DIR)/opt/doc/tinyscheme/...
# Daemon startup scripts should be installed in $(TINYSCHEME_IPK_DIR)/opt/etc/init.d/S??tinyscheme
#
# You may need to patch your application to make it use these locations.
#
$(TINYSCHEME_IPK): $(TINYSCHEME_BUILD_DIR)/.built
	rm -rf $(TINYSCHEME_IPK_DIR) $(BUILD_DIR)/tinyscheme_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(TINYSCHEME_BUILD_DIR) DESTDIR=$(TINYSCHEME_IPK_DIR) install-strip
	install -d $(TINYSCHEME_IPK_DIR)/opt/lib/tinyscheme/
	install $(TINYSCHEME_BUILD_DIR)/libtinyscheme.so $(TINYSCHEME_IPK_DIR)/opt/lib/
	install $(TINYSCHEME_BUILD_DIR)/init.scm $(TINYSCHEME_IPK_DIR)/opt/lib/tinyscheme/
	install -d $(TINYSCHEME_IPK_DIR)/opt/bin/
	install $(TINYSCHEME_BUILD_DIR)/scheme $(TINYSCHEME_IPK_DIR)/opt/bin/tinyscheme
	install -d $(TINYSCHEME_IPK_DIR)/opt/share/doc/tinyscheme/
	for f in BUILDING CHANGES COPYING hack.txt Manual.txt MiniSCHEMETribute.txt; \
		do install $(TINYSCHEME_BUILD_DIR)/$$f $(TINYSCHEME_IPK_DIR)/opt/share/doc/tinyscheme/; done
	install -d $(TINYSCHEME_IPK_DIR)/opt/include/tinyscheme/
	install $(TINYSCHEME_BUILD_DIR)/scheme.h $(TINYSCHEME_IPK_DIR)/opt/include/tinyscheme/
	$(STRIP_COMMAND) $(TINYSCHEME_IPK_DIR)/opt/lib/libtinyscheme.so
	$(STRIP_COMMAND) $(TINYSCHEME_IPK_DIR)/opt/bin/tinyscheme
	$(MAKE) $(TINYSCHEME_IPK_DIR)/CONTROL/control
	echo $(TINYSCHEME_CONFFILES) | sed -e 's/ /\n/g' > $(TINYSCHEME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TINYSCHEME_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tinyscheme-ipk: $(TINYSCHEME_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tinyscheme-clean:
	rm -f $(TINYSCHEME_BUILD_DIR)/.built
	-$(MAKE) -C $(TINYSCHEME_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tinyscheme-dirclean:
	rm -rf $(BUILD_DIR)/$(TINYSCHEME_DIR) $(TINYSCHEME_BUILD_DIR) $(TINYSCHEME_IPK_DIR) $(TINYSCHEME_IPK)
#
#
# Some sanity check for the package.
#
tinyscheme-check: $(TINYSCHEME_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TINYSCHEME_IPK)
