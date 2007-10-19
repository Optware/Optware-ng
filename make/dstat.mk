###########################################################
#
# dstat
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
DSTAT_SITE=http://dag.wieers.com/home-made/dstat/
DSTAT_VERSION=0.6.6
DSTAT_SOURCE=dstat-$(DSTAT_VERSION).tar.bz2
DSTAT_DIR=dstat-$(DSTAT_VERSION)
DSTAT_UNZIP=bzcat
DSTAT_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
DSTAT_DESCRIPTION=dstat is a versatile replacement for vmstat, iostat, netstat, nfsstat, and ifstat
DSTAT_SECTION=admin
DSTAT_PRIORITY=optional
DSTAT_DEPENDS=python
DSTAT_SUGGESTS=
DSTAT_CONFLICTS=

#
# DSTAT_IPK_VERSION should be incremented when the ipk changes.
#
DSTAT_IPK_VERSION=1

#
# DSTAT_CONFFILES should be a list of user-editable files
#DSTAT_CONFFILES=/opt/etc/dstat.conf /opt/etc/init.d/SXXdstat

#
# DSTAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# DSTAT_PATCHES=$(DSTAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DSTAT_CPPFLAGS=
DSTAT_LDFLAGS=

#
# DSTAT_BUILD_DIR is the directory in which the build is done.
# DSTAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DSTAT_IPK_DIR is the directory in which the ipk is built.
# DSTAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DSTAT_BUILD_DIR=$(BUILD_DIR)/dstat
DSTAT_SOURCE_DIR=$(SOURCE_DIR)/dstat
DSTAT_IPK_DIR=$(BUILD_DIR)/dstat-$(DSTAT_VERSION)-ipk
DSTAT_IPK=$(BUILD_DIR)/dstat_$(DSTAT_VERSION)-$(DSTAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dstat-source dstat-unpack dstat dstat-stage dstat-ipk dstat-clean dstat-dirclean dstat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DSTAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(DSTAT_SITE)/$(DSTAT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DSTAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dstat-source: $(DL_DIR)/$(DSTAT_SOURCE) $(DSTAT_PATCHES)

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
$(DSTAT_BUILD_DIR)/.configured: $(DL_DIR)/$(DSTAT_SOURCE) $(DSTAT_PATCHES) make/dstat.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DSTAT_DIR) $(DSTAT_BUILD_DIR)
	$(DSTAT_UNZIP) $(DL_DIR)/$(DSTAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DSTAT_PATCHES)" ; \
		then cat $(DSTAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DSTAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DSTAT_DIR)" != "$(DSTAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DSTAT_DIR) $(DSTAT_BUILD_DIR) ; \
	fi
	(cd $(DSTAT_BUILD_DIR); \
		sed -i -e 's#prefix = /usr#prefix = /opt#' \
			-e 's#sysconfdir = /etc#sysconfdir = /opt/etc#' Makefile)
	touch $@

dstat-unpack: $(DSTAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DSTAT_BUILD_DIR)/.built: $(DSTAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DSTAT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
dstat: $(DSTAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DSTAT_BUILD_DIR)/.staged: $(DSTAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DSTAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

dstat-stage: $(DSTAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dstat
#
$(DSTAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dstat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DSTAT_PRIORITY)" >>$@
	@echo "Section: $(DSTAT_SECTION)" >>$@
	@echo "Version: $(DSTAT_VERSION)-$(DSTAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DSTAT_MAINTAINER)" >>$@
	@echo "Source: $(DSTAT_SITE)/$(DSTAT_SOURCE)" >>$@
	@echo "Description: $(DSTAT_DESCRIPTION)" >>$@
	@echo "Depends: $(DSTAT_DEPENDS)" >>$@
	@echo "Suggests: $(DSTAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(DSTAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DSTAT_IPK_DIR)/opt/sbin or $(DSTAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DSTAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DSTAT_IPK_DIR)/opt/etc/dstat/...
# Documentation files should be installed in $(DSTAT_IPK_DIR)/opt/doc/dstat/...
# Daemon startup scripts should be installed in $(DSTAT_IPK_DIR)/opt/etc/init.d/S??dstat
#
# You may need to patch your application to make it use these locations.
#
$(DSTAT_IPK): $(DSTAT_BUILD_DIR)/.built
	rm -rf $(DSTAT_IPK_DIR) $(BUILD_DIR)/dstat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DSTAT_BUILD_DIR) DESTDIR=$(DSTAT_IPK_DIR) install
	#install -d $(DSTAT_IPK_DIR)/opt/etc/
	#install -m 644 $(DSTAT_SOURCE_DIR)/dstat.conf $(DSTAT_IPK_DIR)/opt/etc/dstat.conf
	#install -d $(DSTAT_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(DSTAT_SOURCE_DIR)/rc.dstat $(DSTAT_IPK_DIR)/opt/etc/init.d/SXXdstat
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DSTAT_IPK_DIR)/opt/etc/init.d/SXXdstat
	$(MAKE) $(DSTAT_IPK_DIR)/CONTROL/control
	#install -m 755 $(DSTAT_SOURCE_DIR)/postinst $(DSTAT_IPK_DIR)/CONTROL/postinst
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DSTAT_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(DSTAT_SOURCE_DIR)/prerm $(DSTAT_IPK_DIR)/CONTROL/prerm
	#sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DSTAT_IPK_DIR)/CONTROL/prerm
	#echo $(DSTAT_CONFFILES) | sed -e 's/ /\n/g' > $(DSTAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DSTAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dstat-ipk: $(DSTAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dstat-clean:
	rm -f $(DSTAT_BUILD_DIR)/.built
	-$(MAKE) -C $(DSTAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dstat-dirclean:
	rm -rf $(BUILD_DIR)/$(DSTAT_DIR) $(DSTAT_BUILD_DIR) $(DSTAT_IPK_DIR) $(DSTAT_IPK)
#
#
# Some sanity check for the package.
#
dstat-check: $(DSTAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DSTAT_IPK)
