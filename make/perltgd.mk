###########################################################
#
# perltgd
#
###########################################################

# You must replace "perltgd" and "PERLTGD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PERLTGD_VERSION, PERLTGD_SITE and PERLTGD_SOURCE define
# the upstream location of the source code for the package.
# PERLTGD_DIR is the directory which is created when the source
# archive is unpacked.
# PERLTGD_UNZIP is the command used to unzip the source.
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
PERLTGD_SITE=http://jim16.110mb.com/
PERLTGD_VERSION=1.0BetaN
PERLTGD_SOURCE=perlTGDSlug-$(PERLTGD_VERSION).tar.gz
PERLTGD_DIR=perltgd-$(PERLTGD_VERSION)
PERLTGD_UNZIP=zcat
PERLTGD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERLTGD_DESCRIPTION=Automated EPG updating for the Topfield range of PVRs
PERLTGD_SECTION=util
PERLTGD_PRIORITY=optional
PERLTGD_DEPENDS=perl, wget, wput, cron
PERLTGD_SUGGESTS=ftpd-topfield, puppy
PERLTGD_CONFLICTS=

#
# PERLTGD_IPK_VERSION should be incremented when the ipk changes.
#
PERLTGD_IPK_VERSION=1

#
# PERLTGD_CONFFILES should be a list of user-editable files
PERLTGD_CONFFILES= \
	/opt/etc/perltgd/perltgd.settings \
	/opt/etc/perltgd/xmltv2tgd.settings \
	/opt/etc/perltgd/append.timers \
	/opt/etc/perltgd/favourites.ini \
	/opt/etc/perltgd/overrun.shows \
	/opt/etc/perltgd/shows.repeat \
	/opt/etc/cron.d/perltgd

#
# PERLTGD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PERLTGD_PATCHES=$(PERLTGD_SOURCE_DIR)/perltgd.patch $(PERLTGD_SOURCE_DIR)/xmltv2tgd.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PERLTGD_CPPFLAGS=
PERLTGD_LDFLAGS=

#
# PERLTGD_BUILD_DIR is the directory in which the build is done.
# PERLTGD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PERLTGD_IPK_DIR is the directory in which the ipk is built.
# PERLTGD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PERLTGD_BUILD_DIR=$(BUILD_DIR)/perltgd
PERLTGD_SOURCE_DIR=$(SOURCE_DIR)/perltgd
PERLTGD_IPK_DIR=$(BUILD_DIR)/perltgd-$(PERLTGD_VERSION)-ipk
PERLTGD_IPK=$(BUILD_DIR)/perltgd_$(PERLTGD_VERSION)-$(PERLTGD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: perltgd-source perltgd-unpack perltgd perltgd-stage perltgd-ipk perltgd-clean perltgd-dirclean perltgd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PERLTGD_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERLTGD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
perltgd-source: $(DL_DIR)/$(PERLTGD_SOURCE) $(PERLTGD_PATCHES)

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
$(PERLTGD_BUILD_DIR)/.configured: $(DL_DIR)/$(PERLTGD_SOURCE) $(PERLTGD_PATCHES) make/perltgd.mk
	rm -rf $(BUILD_DIR)/$(PERLTGD_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(PERLTGD_DIR)
	$(PERLTGD_UNZIP) $(DL_DIR)/$(PERLTGD_SOURCE) | tar -C $(BUILD_DIR)/$(PERLTGD_DIR) -xvf -
	if test -n "$(PERLTGD_PATCHES)" ; \
		then cat $(PERLTGD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PERLTGD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PERLTGD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PERLTGD_DIR) $(@D) ; \
	fi
	touch $@

perltgd-unpack: $(PERLTGD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PERLTGD_BUILD_DIR)/.built: $(PERLTGD_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
perltgd: $(PERLTGD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PERLTGD_BUILD_DIR)/.staged: $(PERLTGD_BUILD_DIR)/.built
	rm -f $@
	touch $@

perltgd-stage: $(PERLTGD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/perltgd
#
$(PERLTGD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perltgd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERLTGD_PRIORITY)" >>$@
	@echo "Section: $(PERLTGD_SECTION)" >>$@
	@echo "Version: $(PERLTGD_VERSION)-$(PERLTGD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERLTGD_MAINTAINER)" >>$@
	@echo "Source: $(PERLTGD_SITE)/$(PERLTGD_SOURCE)" >>$@
	@echo "Description: $(PERLTGD_DESCRIPTION)" >>$@
	@echo "Depends: $(PERLTGD_DEPENDS)" >>$@
	@echo "Suggests: $(PERLTGD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERLTGD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PERLTGD_IPK_DIR)/opt/sbin or $(PERLTGD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PERLTGD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PERLTGD_IPK_DIR)/opt/etc/perltgd/...
# Documentation files should be installed in $(PERLTGD_IPK_DIR)/opt/doc/perltgd/...
# Daemon startup scripts should be installed in $(PERLTGD_IPK_DIR)/opt/etc/init.d/S??perltgd
#
# You may need to patch your application to make it use these locations.
#
$(PERLTGD_IPK): $(PERLTGD_BUILD_DIR)/.built
	rm -rf $(PERLTGD_IPK_DIR) $(BUILD_DIR)/perltgd_*_$(TARGET_ARCH).ipk
	install -d $(PERLTGD_IPK_DIR)/opt/bin
	install -m 755 $(PERLTGD_BUILD_DIR)/perltgdcli.pl $(PERLTGD_IPK_DIR)/opt/bin/perltgd
	install -m 755 $(PERLTGD_BUILD_DIR)/xmltv2tgd.pl $(PERLTGD_IPK_DIR)/opt/bin/xmltv2tgd
	install -d $(PERLTGD_IPK_DIR)/opt/etc/perltgd
	install -m 644 $(PERLTGD_SOURCE_DIR)/perltgd.settings $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -m 644 $(PERLTGD_SOURCE_DIR)/xmltv2tgd.settings $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -m 644 $(PERLTGD_BUILD_DIR)/perlTGDslug/append.timers $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -m 644 $(PERLTGD_BUILD_DIR)/perlTGDslug/favourites.ini $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -m 644 $(PERLTGD_BUILD_DIR)/perlTGDslug/overrun.shows $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -m 644 $(PERLTGD_BUILD_DIR)/perlTGDslug/shows.repeat $(PERLTGD_IPK_DIR)/opt/etc/perltgd/
	install -d $(PERLTGD_IPK_DIR)/opt/etc/cron.d
	install -m 600 $(PERLTGD_SOURCE_DIR)/cron.perltgd $(PERLTGD_IPK_DIR)/opt/etc/cron.d/perltgd
	$(MAKE) $(PERLTGD_IPK_DIR)/CONTROL/control
	install -m 755 $(PERLTGD_SOURCE_DIR)/postinst $(PERLTGD_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PERLTGD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(PERLTGD_SOURCE_DIR)/prerm $(PERLTGD_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PERLTGD_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PERLTGD_IPK_DIR)/CONTROL/postinst $(PERLTGD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PERLTGD_CONFFILES) | sed -e 's/ /\n/g' > $(PERLTGD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERLTGD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
perltgd-ipk: $(PERLTGD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
perltgd-clean:
	rm -f $(PERLTGD_BUILD_DIR)/.built
	-$(MAKE) -C $(PERLTGD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
perltgd-dirclean:
	rm -rf $(BUILD_DIR)/$(PERLTGD_DIR) $(PERLTGD_BUILD_DIR) $(PERLTGD_IPK_DIR) $(PERLTGD_IPK)
#
#
# Some sanity check for the package.
#
perltgd-check: $(PERLTGD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERLTGD_IPK)
