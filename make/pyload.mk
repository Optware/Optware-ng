###########################################################
#
# pyload
#
###########################################################

# You must replace "pyload" and "PYLOAD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PYLOAD_VERSION, PYLOAD_SITE and PYLOAD_SOURCE define
# the upstream location of the source code for the package.
# PYLOAD_DIR is the directory which is created when the source
# archive is unpacked.
# PYLOAD_UNZIP is the command used to unzip the source.
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
PYLOAD_SITE=http://get.pyload.org/get/src
PYLOAD_REPOSITORY=https://github.com/pyload/pyload.git
ifndef PYLOAD_REPOSITORY
PYLOAD_VERSION=0.4.9
else
PYLOAD_GIT_DATE=20151031
PYLOAD_TREEISH=`git rev-list --max-count=1 --until=2015-10-31 HEAD`
PYLOAD_VERSION=0.4.9+git$(PYLOAD_GIT_DATE)
endif
PYLOAD_SOURCE=pyload-src-v$(PYLOAD_VERSION).zip
PYLOAD_DIR=pyload
PYLOAD_UNZIP=unzip
PYLOAD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYLOAD_DESCRIPTION=A fast, lightweight and full featured download manager.
PYLOAD_SECTION=net
PYLOAD_PRIORITY=optional
PYLOAD_DEPENDS=py27-crypto, py27-curl, py27-openssl, py27-django, py27-pil, \
tesseract-ocr, unzip, sqlite, unrar, ossp-js
PYLOAD_SUGGESTS=
PYLOAD_CONFLICTS=

#
# PYLOAD_IPK_VERSION should be incremented when the ipk changes.
#
PYLOAD_IPK_VERSION=2

#
# PYLOAD_CONFFILES should be a list of user-editable files
PYLOAD_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S98Pyload

#
# PYLOAD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PYLOAD_PATCHES=\
$(PYLOAD_SOURCE_DIR)/UpdateManager.py.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYLOAD_CPPFLAGS=
PYLOAD_LDFLAGS=

#
# PYLOAD_BUILD_DIR is the directory in which the build is done.
# PYLOAD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYLOAD_IPK_DIR is the directory in which the ipk is built.
# PYLOAD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYLOAD_BUILD_DIR=$(BUILD_DIR)/pyload
PYLOAD_SOURCE_DIR=$(SOURCE_DIR)/pyload
PYLOAD_IPK_DIR=$(BUILD_DIR)/pyload-$(PYLOAD_VERSION)-ipk
PYLOAD_IPK=$(BUILD_DIR)/pyload_$(PYLOAD_VERSION)-$(PYLOAD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pyload-source pyload-unpack pyload pyload-stage pyload-ipk pyload-clean pyload-dirclean pyload-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYLOAD_SOURCE):
ifndef PYLOAD_REPOSITORY
	$(WGET) -P $(@D) $(PYLOAD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	(cd $(BUILD_DIR) ; \
		rm -rf pyload && \
		git clone --bare $(PYLOAD_REPOSITORY) pyload && \
		(cd pyload && \
		git archive --format=zip --prefix=$(PYLOAD_DIR)/ $(PYLOAD_TREEISH) > $@) && \
		rm -rf pyload ; \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pyload-source: $(DL_DIR)/$(PYLOAD_SOURCE) $(PYLOAD_PATCHES)

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
$(PYLOAD_BUILD_DIR)/.configured: $(DL_DIR)/$(PYLOAD_SOURCE) $(PYLOAD_PATCHES) make/pyload.mk \
	$(PYLOAD_SOURCE_DIR)/postinst $(PYLOAD_SOURCE_DIR)/rc.pyload
	rm -rf $(BUILD_DIR)/$(PYLOAD_DIR) $(@D)
	cd $(BUILD_DIR); $(PYLOAD_UNZIP) $(DL_DIR)/$(PYLOAD_SOURCE)
	if test -n "$(PYLOAD_PATCHES)" ; \
		then cat $(PYLOAD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PYLOAD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PYLOAD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PYLOAD_DIR) $(@D) ; \
	fi
	touch $@

pyload-unpack: $(PYLOAD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYLOAD_BUILD_DIR)/.built: $(PYLOAD_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
pyload: $(PYLOAD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYLOAD_BUILD_DIR)/.staged: $(PYLOAD_BUILD_DIR)/.built
	rm -f $@
	touch $@

pyload-stage: $(PYLOAD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pyload
#
$(PYLOAD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: pyload" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYLOAD_PRIORITY)" >>$@
	@echo "Section: $(PYLOAD_SECTION)" >>$@
	@echo "Version: $(PYLOAD_VERSION)-$(PYLOAD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYLOAD_MAINTAINER)" >>$@
	@echo "Source: $(PYLOAD_SITE)/$(PYLOAD_SOURCE)" >>$@
	@echo "Description: $(PYLOAD_DESCRIPTION)" >>$@
	@echo "Depends: $(PYLOAD_DEPENDS)" >>$@
	@echo "Suggests: $(PYLOAD_SUGGESTS)" >>$@
	@echo "Conflicts: $(PYLOAD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/pyload/...
# Documentation files should be installed in $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/doc/pyload/...
# Daemon startup scripts should be installed in $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??pyload
#
# You may need to patch your application to make it use these locations.
#
$(PYLOAD_IPK): $(PYLOAD_BUILD_DIR)/.built
	rm -rf $(PYLOAD_IPK_DIR) $(BUILD_DIR)/pyload_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PYLOAD_BUILD_DIR) DESTDIR=$(PYLOAD_IPK_DIR) install-strip
	$(INSTALL) -d $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/share/pyload
	cp -af $(PYLOAD_BUILD_DIR)/* $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/share/pyload
	$(INSTALL) -d $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(PYLOAD_SOURCE_DIR)/rc.pyload $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S98Pyload
	ln -s S98Pyload $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K10Pyload
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PYLOAD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXpyload
	$(MAKE) $(PYLOAD_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(PYLOAD_SOURCE_DIR)/postinst $(PYLOAD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PYLOAD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PYLOAD_SOURCE_DIR)/prerm $(PYLOAD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PYLOAD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PYLOAD_IPK_DIR)/CONTROL/postinst $(PYLOAD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PYLOAD_CONFFILES) | sed -e 's/ /\n/g' > $(PYLOAD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYLOAD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PYLOAD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pyload-ipk: $(PYLOAD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pyload-clean:
	rm -f $(PYLOAD_BUILD_DIR)/.built
	-$(MAKE) -C $(PYLOAD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pyload-dirclean:
	rm -rf $(BUILD_DIR)/$(PYLOAD_DIR) $(PYLOAD_BUILD_DIR) $(PYLOAD_IPK_DIR) $(PYLOAD_IPK)
#
#
# Some sanity check for the package.
#
pyload-check: $(PYLOAD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
