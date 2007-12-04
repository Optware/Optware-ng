###########################################################
#
# mlocate
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
MLOCATE_SITE=http://people.redhat.com/mitr/mlocate
ifeq ($(LIBC_STYLE), uclibc)
MLOCATE_VERSION=0.15
MLOCATE_IPK_VERSION=1
MLOCATE_SOURCE=mlocate-$(MLOCATE_VERSION).tar.gz
MLOCATE_UNZIP=zcat
else
MLOCATE_VERSION=0.18
MLOCATE_IPK_VERSION=1
MLOCATE_SOURCE=mlocate-$(MLOCATE_VERSION).tar.bz2
MLOCATE_UNZIP=bzcat
endif
MLOCATE_DIR=mlocate-$(MLOCATE_VERSION)
MLOCATE_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
MLOCATE_DESCRIPTION=A merginging locate program to find files fast
MLOCATE_SECTION=admin
MLOCATE_PRIORITY=optional
ifeq ($(GETTEXT_NLS), enable)
MLOCATE_DEPENDS=adduser, gettext
else
MLOCATE_DEPENDS=adduser
endif
MLOCATE_SUGGESTS=
MLOCATE_CONFLICTS=


#
# MLOCATE_CONFFILES should be a list of user-editable files
MLOCATE_CONFFILES=/opt/etc/cron.d/updatedb-mlocate

#
# MLOCATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# MLOCATE_PATCHES=$(MLOCATE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MLOCATE_CPPFLAGS=
ifneq (, $(filter slugosbe slugosle, $(OPTWARE_TARGET)))
MLOCATE_CPPFLAGS+=-DSSIZE_MAX=2147483647L
endif

MLOCATE_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
MLOCATE_LDFLAGS+=-lintl
endif

#
# MLOCATE_BUILD_DIR is the directory in which the build is done.
# MLOCATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MLOCATE_IPK_DIR is the directory in which the ipk is built.
# MLOCATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MLOCATE_BUILD_DIR=$(BUILD_DIR)/mlocate
MLOCATE_SOURCE_DIR=$(SOURCE_DIR)/mlocate
MLOCATE_IPK_DIR=$(BUILD_DIR)/mlocate-$(MLOCATE_VERSION)-ipk
MLOCATE_IPK=$(BUILD_DIR)/mlocate_$(MLOCATE_VERSION)-$(MLOCATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mlocate-source mlocate-unpack mlocate mlocate-stage mlocate-ipk mlocate-clean mlocate-dirclean mlocate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MLOCATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(MLOCATE_SITE)/$(MLOCATE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MLOCATE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mlocate-source: $(DL_DIR)/$(MLOCATE_SOURCE) $(MLOCATE_PATCHES)

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
$(MLOCATE_BUILD_DIR)/.configured: $(DL_DIR)/$(MLOCATE_SOURCE) $(MLOCATE_PATCHES) make/mlocate.mk
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(MLOCATE_DIR) $(MLOCATE_BUILD_DIR)
	$(MLOCATE_UNZIP) $(DL_DIR)/$(MLOCATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MLOCATE_PATCHES)" ; \
		then cat $(MLOCATE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MLOCATE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MLOCATE_DIR)" != "$(MLOCATE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MLOCATE_DIR) $(MLOCATE_BUILD_DIR) ; \
	fi
	(cd $(MLOCATE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MLOCATE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MLOCATE_LDFLAGS)" \
		ac_cv_type_mbstate_t=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MLOCATE_BUILD_DIR)/libtool
	touch $@

mlocate-unpack: $(MLOCATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MLOCATE_BUILD_DIR)/.built: $(MLOCATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MLOCATE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mlocate: $(MLOCATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MLOCATE_BUILD_DIR)/.staged: $(MLOCATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MLOCATE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mlocate-stage: $(MLOCATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mlocate
#
$(MLOCATE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mlocate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MLOCATE_PRIORITY)" >>$@
	@echo "Section: $(MLOCATE_SECTION)" >>$@
	@echo "Version: $(MLOCATE_VERSION)-$(MLOCATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MLOCATE_MAINTAINER)" >>$@
	@echo "Source: $(MLOCATE_SITE)/$(MLOCATE_SOURCE)" >>$@
	@echo "Description: $(MLOCATE_DESCRIPTION)" >>$@
	@echo "Depends: $(MLOCATE_DEPENDS)" >>$@
	@echo "Suggests: $(MLOCATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(MLOCATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MLOCATE_IPK_DIR)/opt/sbin or $(MLOCATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MLOCATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MLOCATE_IPK_DIR)/opt/etc/mlocate/...
# Documentation files should be installed in $(MLOCATE_IPK_DIR)/opt/doc/mlocate/...
# Daemon startup scripts should be installed in $(MLOCATE_IPK_DIR)/opt/etc/init.d/S??mlocate
#
# You may need to patch your application to make it use these locations.
#
$(MLOCATE_IPK): $(MLOCATE_BUILD_DIR)/.built
	rm -rf $(MLOCATE_IPK_DIR) $(BUILD_DIR)/mlocate_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MLOCATE_BUILD_DIR) DESTDIR=$(MLOCATE_IPK_DIR) install-strip
	install -d $(MLOCATE_IPK_DIR)/opt/etc/
#	install -m 644 $(MLOCATE_SOURCE_DIR)/mlocate.conf $(MLOCATE_IPK_DIR)/opt/etc/mlocate.conf
#	install -d $(MLOCATE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MLOCATE_SOURCE_DIR)/rc.mlocate $(MLOCATE_IPK_DIR)/opt/etc/init.d/SXXmlocate
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MLOCATE_IPK_DIR)/opt/etc/init.d/SXXmlocate
	install -d $(MLOCATE_IPK_DIR)/opt/etc/cron.d
	install -m 755 $(MLOCATE_SOURCE_DIR)/updatedb-daily $(MLOCATE_IPK_DIR)/opt/etc/cron.d/
	$(MAKE) $(MLOCATE_IPK_DIR)/CONTROL/control
	install -m 755 $(MLOCATE_SOURCE_DIR)/postinst $(MLOCATE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MLOCATE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MLOCATE_SOURCE_DIR)/prerm $(MLOCATE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MLOCATE_IPK_DIR)/CONTROL/prerm
#	echo $(MLOCATE_CONFFILES) | sed -e 's/ /\n/g' > $(MLOCATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MLOCATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mlocate-ipk: $(MLOCATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mlocate-clean:
	rm -f $(MLOCATE_BUILD_DIR)/.built
	-$(MAKE) -C $(MLOCATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mlocate-dirclean:
	rm -rf $(BUILD_DIR)/$(MLOCATE_DIR) $(MLOCATE_BUILD_DIR) $(MLOCATE_IPK_DIR) $(MLOCATE_IPK)
#
#
# Some sanity check for the package.
#
mlocate-check: $(MLOCATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MLOCATE_IPK)
