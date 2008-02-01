###########################################################
#
# pv
#
###########################################################
#
# PV_VERSION, PV_SITE and PV_SOURCE define
# the upstream location of the source code for the package.
# PV_DIR is the directory which is created when the source
# archive is unpacked.
# PV_UNZIP is the command used to unzip the source.
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
PV_SITE=http://pipeviewer.googlecode.com/files
PV_VERSION=1.1.0
PV_SOURCE=pv-$(PV_VERSION).tar.bz2
PV_DIR=pv-$(PV_VERSION)
PV_UNZIP=bzcat
PV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PV_DESCRIPTION=Pipe Viewer - is a terminal-based tool for monitoring the progress of data through a pipeline.
PV_SECTION=utils
PV_PRIORITY=optional
PV_DEPENDS=
PV_SUGGESTS=
PV_CONFLICTS=

#
# PV_IPK_VERSION should be incremented when the ipk changes.
#
PV_IPK_VERSION=1

#
# PV_CONFFILES should be a list of user-editable files
#PV_CONFFILES=/opt/etc/pv.conf /opt/etc/init.d/SXXpv

#
# PV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PV_PATCHES=$(PV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PV_CPPFLAGS=
PV_LDFLAGS=

#
# PV_BUILD_DIR is the directory in which the build is done.
# PV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PV_IPK_DIR is the directory in which the ipk is built.
# PV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PV_BUILD_DIR=$(BUILD_DIR)/pv
PV_SOURCE_DIR=$(SOURCE_DIR)/pv
PV_IPK_DIR=$(BUILD_DIR)/pv-$(PV_VERSION)-ipk
PV_IPK=$(BUILD_DIR)/pv_$(PV_VERSION)-$(PV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pv-source pv-unpack pv pv-stage pv-ipk pv-clean pv-dirclean pv-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PV_SOURCE):
	$(WGET) -P $(DL_DIR) $(PV_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pv-source: $(DL_DIR)/$(PV_SOURCE) $(PV_PATCHES)

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
$(PV_BUILD_DIR)/.configured: $(DL_DIR)/$(PV_SOURCE) $(PV_PATCHES) make/pv.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PV_DIR) $(@D)
	$(PV_UNZIP) $(DL_DIR)/$(PV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PV_PATCHES)" ; \
		then cat $(PV_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PV_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PV_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PV_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PV_LDFLAGS)" \
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

pv-unpack: $(PV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PV_BUILD_DIR)/.built: $(PV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		;
	touch $@

#
# This is the build convenience target.
#
pv: $(PV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PV_BUILD_DIR)/.staged: $(PV_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

pv-stage: $(PV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pv
#
$(PV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pv" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PV_PRIORITY)" >>$@
	@echo "Section: $(PV_SECTION)" >>$@
	@echo "Version: $(PV_VERSION)-$(PV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PV_MAINTAINER)" >>$@
	@echo "Source: $(PV_SITE)/$(PV_SOURCE)" >>$@
	@echo "Description: $(PV_DESCRIPTION)" >>$@
	@echo "Depends: $(PV_DEPENDS)" >>$@
	@echo "Suggests: $(PV_SUGGESTS)" >>$@
	@echo "Conflicts: $(PV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PV_IPK_DIR)/opt/sbin or $(PV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PV_IPK_DIR)/opt/etc/pv/...
# Documentation files should be installed in $(PV_IPK_DIR)/opt/doc/pv/...
# Daemon startup scripts should be installed in $(PV_IPK_DIR)/opt/etc/init.d/S??pv
#
# You may need to patch your application to make it use these locations.
#
$(PV_IPK): $(PV_BUILD_DIR)/.built
	rm -rf $(PV_IPK_DIR) $(BUILD_DIR)/pv_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PV_BUILD_DIR) DESTDIR=$(PV_IPK_DIR) install
	$(STRIP_COMMAND) $(PV_IPK_DIR)/opt/bin/pv
	$(MAKE) $(PV_IPK_DIR)/CONTROL/control
	echo $(PV_CONFFILES) | sed -e 's/ /\n/g' > $(PV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pv-ipk: $(PV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pv-clean:
	rm -f $(PV_BUILD_DIR)/.built
	-$(MAKE) -C $(PV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pv-dirclean:
	rm -rf $(BUILD_DIR)/$(PV_DIR) $(PV_BUILD_DIR) $(PV_IPK_DIR) $(PV_IPK)
#
#
# Some sanity check for the package.
#
pv-check: $(PV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PV_IPK)
