###########################################################
#
# plowshare
#
###########################################################
#
# PLOWSHARE_VERSION, PLOWSHARE_SITE and PLOWSHARE_SOURCE define
# the upstream location of the source code for the package.
# PLOWSHARE_DIR is the directory which is created when the source
# archive is unpacked.
# PLOWSHARE_UNZIP is the command used to unzip the source.
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
PLOWSHARE_SITE=http://plowshare.googlecode.com/files
PLOWSHARE_VERSION=0.9.1
PLOWSHARE_SOURCE=plowshare-$(PLOWSHARE_VERSION).tgz
PLOWSHARE_DIR=plowshare-$(PLOWSHARE_VERSION)
PLOWSHARE_UNZIP=zcat
PLOWSHARE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PLOWSHARE_DESCRIPTION=A command-line downloader and uploader for some of the most popular file sharing websites
PLOWSHARE_SECTION=utils
PLOWSHARE_PRIORITY=optional
PLOWSHARE_DEPENDS=bash, libcurl, sed, recode, util-linux-ng
PLOWSHARE_SUGGESTS=imagemagick, py25-pil, ossp-js, tesseract-ocr
PLOWSHARE_CONFLICTS=

#
# PLOWSHARE_IPK_VERSION should be incremented when the ipk changes.
#
PLOWSHARE_IPK_VERSION=1

#
# PLOWSHARE_CONFFILES should be a list of user-editable files
#PLOWSHARE_CONFFILES=/opt/etc/plowshare.conf /opt/etc/init.d/SXXplowshare

#
# PLOWSHARE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PLOWSHARE_PATCHES=$(PLOWSHARE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PLOWSHARE_CPPFLAGS=
PLOWSHARE_LDFLAGS=

#
# PLOWSHARE_BUILD_DIR is the directory in which the build is done.
# PLOWSHARE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PLOWSHARE_IPK_DIR is the directory in which the ipk is built.
# PLOWSHARE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PLOWSHARE_BUILD_DIR=$(BUILD_DIR)/plowshare
PLOWSHARE_SOURCE_DIR=$(SOURCE_DIR)/plowshare
PLOWSHARE_IPK_DIR=$(BUILD_DIR)/plowshare-$(PLOWSHARE_VERSION)-ipk
PLOWSHARE_IPK=$(BUILD_DIR)/plowshare_$(PLOWSHARE_VERSION)-$(PLOWSHARE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: plowshare-source plowshare-unpack plowshare plowshare-stage plowshare-ipk plowshare-clean plowshare-dirclean plowshare-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PLOWSHARE_SOURCE):
	$(WGET) -P $(@D) $(PLOWSHARE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
plowshare-source: $(DL_DIR)/$(PLOWSHARE_SOURCE) $(PLOWSHARE_PATCHES)

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
$(PLOWSHARE_BUILD_DIR)/.configured: $(DL_DIR)/$(PLOWSHARE_SOURCE) $(PLOWSHARE_PATCHES) make/plowshare.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PLOWSHARE_DIR) $(@D)
	$(PLOWSHARE_UNZIP) $(DL_DIR)/$(PLOWSHARE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PLOWSHARE_PATCHES)" ; \
		then cat $(PLOWSHARE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PLOWSHARE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PLOWSHARE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PLOWSHARE_DIR) $(@D) ; \
	fi
	sed -i -e '/^USRDIR=/s|/usr/local|/opt|' $(@D)/setup.sh
	find $(@D)/src -name '*.sh' | \
		xargs sed -i -e '1s|#!.*/bash|#!/opt/bin/bash|'
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PLOWSHARE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PLOWSHARE_LDFLAGS)" \
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

plowshare-unpack: $(PLOWSHARE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PLOWSHARE_BUILD_DIR)/.built: $(PLOWSHARE_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
plowshare: $(PLOWSHARE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PLOWSHARE_BUILD_DIR)/.staged: $(PLOWSHARE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#plowshare-stage: $(PLOWSHARE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/plowshare
#
$(PLOWSHARE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: plowshare" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PLOWSHARE_PRIORITY)" >>$@
	@echo "Section: $(PLOWSHARE_SECTION)" >>$@
	@echo "Version: $(PLOWSHARE_VERSION)-$(PLOWSHARE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PLOWSHARE_MAINTAINER)" >>$@
	@echo "Source: $(PLOWSHARE_SITE)/$(PLOWSHARE_SOURCE)" >>$@
	@echo "Description: $(PLOWSHARE_DESCRIPTION)" >>$@
	@echo "Depends: $(PLOWSHARE_DEPENDS)" >>$@
	@echo "Suggests: $(PLOWSHARE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PLOWSHARE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PLOWSHARE_IPK_DIR)/opt/sbin or $(PLOWSHARE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PLOWSHARE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PLOWSHARE_IPK_DIR)/opt/etc/plowshare/...
# Documentation files should be installed in $(PLOWSHARE_IPK_DIR)/opt/doc/plowshare/...
# Daemon startup scripts should be installed in $(PLOWSHARE_IPK_DIR)/opt/etc/init.d/S??plowshare
#
# You may need to patch your application to make it use these locations.
#
$(PLOWSHARE_IPK): $(PLOWSHARE_BUILD_DIR)/.built
	rm -rf $(PLOWSHARE_IPK_DIR) $(BUILD_DIR)/plowshare_*_$(TARGET_ARCH).ipk
	cd $(<D); \
		DESTDIR=$(PLOWSHARE_IPK_DIR) PREFIX=/opt ./setup.sh install
	$(MAKE) $(PLOWSHARE_IPK_DIR)/CONTROL/control
	install -m755 $(PLOWSHARE_SOURCE_DIR)/postinst $(PLOWSHARE_IPK_DIR)/CONTROL/
	echo $(PLOWSHARE_CONFFILES) | sed -e 's/ /\n/g' > $(PLOWSHARE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PLOWSHARE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
plowshare-ipk: $(PLOWSHARE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
plowshare-clean:
	rm -f $(PLOWSHARE_BUILD_DIR)/.built
	-$(MAKE) -C $(PLOWSHARE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
plowshare-dirclean:
	rm -rf $(BUILD_DIR)/$(PLOWSHARE_DIR) $(PLOWSHARE_BUILD_DIR) $(PLOWSHARE_IPK_DIR) $(PLOWSHARE_IPK)
#
#
# Some sanity check for the package.
#
plowshare-check: $(PLOWSHARE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
