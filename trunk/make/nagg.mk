###########################################################
#
# nagg
#
###########################################################
#
# NAGG_VERSION, NAGG_SITE and NAGG_SOURCE define
# the upstream location of the source code for the package.
# NAGG_DIR is the directory which is created when the source
# archive is unpacked.
# NAGG_UNZIP is the command used to unzip the source.
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
NAGG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nagg
NAGG_VERSION=0.9.9
NAGG_SOURCE=nagg-$(NAGG_VERSION).tar.gz
NAGG_DIR=nagg-$(NAGG_VERSION)
NAGG_UNZIP=zcat
NAGG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NAGG_DESCRIPTION=Not Another Gallery Generator
NAGG_SECTION=web
NAGG_PRIORITY=optional
NAGG_DEPENDS=bash, imagemagick
NAGG_SUGGESTS=sed, gawk
NAGG_CONFLICTS=

#
# NAGG_IPK_VERSION should be incremented when the ipk changes.
#
NAGG_IPK_VERSION=1

#
# NAGG_CONFFILES should be a list of user-editable files
NAGG_CONFFILES=/opt/lib/nagg/nagg.conf /opt/lib/nagg/nagg.css \
	/opt/lib/nagg/indextemplate.html /opt/lib/nagg/slidetemplate.html

#
# NAGG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NAGG_PATCHES=$(NAGG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NAGG_CPPFLAGS=
NAGG_LDFLAGS=

#
# NAGG_BUILD_DIR is the directory in which the build is done.
# NAGG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NAGG_IPK_DIR is the directory in which the ipk is built.
# NAGG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NAGG_BUILD_DIR=$(BUILD_DIR)/nagg
NAGG_SOURCE_DIR=$(SOURCE_DIR)/nagg
NAGG_IPK_DIR=$(BUILD_DIR)/nagg-$(NAGG_VERSION)-ipk
NAGG_IPK=$(BUILD_DIR)/nagg_$(NAGG_VERSION)-$(NAGG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nagg-source nagg-unpack nagg nagg-stage nagg-ipk nagg-clean nagg-dirclean nagg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NAGG_SOURCE):
	$(WGET) -P $(DL_DIR) $(NAGG_SITE)/$(NAGG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NAGG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nagg-source: $(DL_DIR)/$(NAGG_SOURCE) $(NAGG_PATCHES)

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
$(NAGG_BUILD_DIR)/.configured: $(DL_DIR)/$(NAGG_SOURCE) $(NAGG_PATCHES) make/nagg.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NAGG_DIR) $(NAGG_BUILD_DIR)
	$(NAGG_UNZIP) $(DL_DIR)/$(NAGG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NAGG_PATCHES)" ; \
		then cat $(NAGG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NAGG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NAGG_DIR)" != "$(NAGG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NAGG_DIR) $(NAGG_BUILD_DIR) ; \
	fi
	(cd $(NAGG_BUILD_DIR); \
		sed -i -e '/^DESTDIR/d' Makefile; \
		sed -i -e '/^libdir=/s|.*|libdir=/opt/lib/nagg|' \
			-e 's|/bin/bash|/opt/bin/bash|' nagg \
	)
	touch $@

nagg-unpack: $(NAGG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NAGG_BUILD_DIR)/.built: $(NAGG_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(NAGG_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
nagg: $(NAGG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NAGG_BUILD_DIR)/.staged: $(NAGG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NAGG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

nagg-stage: $(NAGG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nagg
#
$(NAGG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nagg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NAGG_PRIORITY)" >>$@
	@echo "Section: $(NAGG_SECTION)" >>$@
	@echo "Version: $(NAGG_VERSION)-$(NAGG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NAGG_MAINTAINER)" >>$@
	@echo "Source: $(NAGG_SITE)/$(NAGG_SOURCE)" >>$@
	@echo "Description: $(NAGG_DESCRIPTION)" >>$@
	@echo "Depends: $(NAGG_DEPENDS)" >>$@
	@echo "Suggests: $(NAGG_SUGGESTS)" >>$@
	@echo "Conflicts: $(NAGG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NAGG_IPK_DIR)/opt/sbin or $(NAGG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NAGG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NAGG_IPK_DIR)/opt/etc/nagg/...
# Documentation files should be installed in $(NAGG_IPK_DIR)/opt/doc/nagg/...
# Daemon startup scripts should be installed in $(NAGG_IPK_DIR)/opt/etc/init.d/S??nagg
#
# You may need to patch your application to make it use these locations.
#
$(NAGG_IPK): $(NAGG_BUILD_DIR)/.built
	rm -rf $(NAGG_IPK_DIR) $(BUILD_DIR)/nagg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NAGG_BUILD_DIR) DESTDIR=$(NAGG_IPK_DIR)/opt install
#	install -d $(NAGG_IPK_DIR)/opt/etc/
#	install -m 644 $(NAGG_SOURCE_DIR)/nagg.conf $(NAGG_IPK_DIR)/opt/etc/nagg.conf
#	install -d $(NAGG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NAGG_SOURCE_DIR)/rc.nagg $(NAGG_IPK_DIR)/opt/etc/init.d/SXXnagg
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NAGG_IPK_DIR)/opt/etc/init.d/SXXnagg
	$(MAKE) $(NAGG_IPK_DIR)/CONTROL/control
#	install -m 755 $(NAGG_SOURCE_DIR)/postinst $(NAGG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NAGG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NAGG_SOURCE_DIR)/prerm $(NAGG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NAGG_IPK_DIR)/CONTROL/prerm
	echo $(NAGG_CONFFILES) | sed -e 's/ /\n/g' > $(NAGG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NAGG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nagg-ipk: $(NAGG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nagg-clean:
	rm -f $(NAGG_BUILD_DIR)/.built
	-$(MAKE) -C $(NAGG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nagg-dirclean:
	rm -rf $(BUILD_DIR)/$(NAGG_DIR) $(NAGG_BUILD_DIR) $(NAGG_IPK_DIR) $(NAGG_IPK)
#
#
# Some sanity check for the package.
#
nagg-check: $(NAGG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NAGG_IPK)
