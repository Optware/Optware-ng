###########################################################
#
# lunaservice
#
###########################################################

LUNASERVICE_REPOSITORY=git://git.webos-internals.org/libraries/lunaservice.git
LUNASERVICE_MAINTAINER=WebOS Internals <support@webos-internals.org>
LUNASERVICE_DESCRIPTION=Palm Luna Service header files and dummy link library.
LUNASERVICE_SECTION=lib
LUNASERVICE_PRIORITY=optional
LUNASERVICE_DEPENDS=
LUNASERVICE_SUGGESTS=
LUNASERVICE_CONFLICTS=

#
# Software cloned from GIT repositories must either use a tag or a
# date to ensure that the same sources can be recreated later.
#

#
# If you want to use a date, uncomment the variables below and modify
# LUNASERVICE_GIT_DATE
#

# LUNASERVICE_GIT_DATE=20090917
# LUNASERVICE_VERSION=git$(LUNASERVICE_GIT_DATE)
# LUNASERVICE_TREEISH=`git rev-list --max-count=1 --until=2009-09-17 HEAD`

#
# If you want to use a tag, uncomment the variables below and modify
# LUNASERVICE_GIT_TAG and LUNASERVICE_GIT_VERSION
#

LUNASERVICE_GIT_TAG=v0.0.1
LUNASERVICE_VERSION=0.0.1
LUNASERVICE_TREEISH=$(LUNASERVICE_GIT_TAG)

LUNASERVICE_DIR=lunaservice-$(LUNASERVICE_VERSION)
LUNASERVICE_SOURCE=$(LUNASERVICE_DIR).tar.gz
LUNASERVICE_UNZIP=zcat

#
# LUNASERVICE_IPK_VERSION should be incremented when the ipk changes.
#
LUNASERVICE_IPK_VERSION=1

#
# LUNASERVICE_CONFFILES should be a list of user-editable files
#LUNASERVICE_CONFFILES=/opt/etc/lunaservice.conf /opt/etc/init.d/SXXlunaservice

#
# LUNASERVICE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LUNASERVICE_PATCHES=$(LUNASERVICE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LUNASERVICE_CPPFLAGS=-I${STAGING_INCLUDE_DIR}/glib-2.0
LUNASERVICE_LDFLAGS=

#
# LUNASERVICE_BUILD_DIR is the directory in which the build is done.
# LUNASERVICE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LUNASERVICE_IPK_DIR is the directory in which the ipk is built.
# LUNASERVICE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LUNASERVICE_BUILD_DIR=$(BUILD_DIR)/lunaservice
LUNASERVICE_SOURCE_DIR=$(SOURCE_DIR)/lunaservice
LUNASERVICE_IPK_DIR=$(BUILD_DIR)/lunaservice-$(LUNASERVICE_VERSION)-ipk
LUNASERVICE_IPK=$(BUILD_DIR)/lunaservice_$(LUNASERVICE_VERSION)-$(LUNASERVICE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lunaservice-source lunaservice-unpack lunaservice lunaservice-stage lunaservice-ipk lunaservice-clean lunaservice-dirclean lunaservice-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with git
#
$(DL_DIR)/$(LUNASERVICE_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf lunaservice && \
		git clone --bare $(LUNASERVICE_REPOSITORY) lunaservice && \
		cd lunaservice && \
		(git archive --format=tar --prefix=$(LUNASERVICE_DIR)/ $(LUNASERVICE_TREEISH) | gzip > $@) && \
		rm -rf lunaservice ; \
	)

lunaservice-source: $(DL_DIR)/$(LUNASERVICE_SOURCE)

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
$(LUNASERVICE_BUILD_DIR)/.configured: $(DL_DIR)/$(LUNASERVICE_SOURCE) $(LUNASERVICE_PATCHES) make/lunaservice.mk
	$(MAKE) glib-stage mjson-stage
	rm -rf $(BUILD_DIR)/$(LUNASERVICE_DIR) $(@D)
	$(LUNASERVICE_UNZIP) $(DL_DIR)/$(LUNASERVICE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LUNASERVICE_PATCHES)" ; \
		then cat $(LUNASERVICE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LUNASERVICE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LUNASERVICE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LUNASERVICE_DIR) $(@D) ; \
	fi
	touch $@

lunaservice-unpack: $(LUNASERVICE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LUNASERVICE_BUILD_DIR)/.built: $(LUNASERVICE_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(@D) \
	CC="$(TARGET_CROSS)gcc" \
	CFLAGS="$(STAGING_CPPFLAGS) $(LUNASERVICE_CPPFLAGS)" INCLUDES= \
	LIBS="$(STAGING_LDFLAGS) $(LUNASERVICE_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
lunaservice: $(LUNASERVICE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LUNASERVICE_BUILD_DIR)/.staged: $(LUNASERVICE_BUILD_DIR)/.built
	rm -f $@
	mkdir -p $(STAGING_DIR)/opt/include $(STAGING_DIR)/opt/lib
	install -m 644 $(LUNASERVICE_BUILD_DIR)/lunaservice.h $(STAGING_DIR)/opt/include/
	install -m 644 $(LUNASERVICE_BUILD_DIR)/lunaservice-errors.h $(STAGING_DIR)/opt/include/
	install -m 644 $(LUNASERVICE_BUILD_DIR)/liblunaservice.so $(STAGING_DIR)/opt/lib/
	touch $@

lunaservice-stage: $(LUNASERVICE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lunaservice
#
$(LUNASERVICE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lunaservice" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LUNASERVICE_PRIORITY)" >>$@
	@echo "Section: $(LUNASERVICE_SECTION)" >>$@
	@echo "Version: $(LUNASERVICE_VERSION)-$(LUNASERVICE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LUNASERVICE_MAINTAINER)" >>$@
	@echo "Source: $(LUNASERVICE_SITE)/$(LUNASERVICE_SOURCE)" >>$@
	@echo "Description: $(LUNASERVICE_DESCRIPTION)" >>$@
	@echo "Depends: $(LUNASERVICE_DEPENDS)" >>$@
	@echo "Suggests: $(LUNASERVICE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LUNASERVICE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LUNASERVICE_IPK_DIR)/opt/sbin or $(LUNASERVICE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LUNASERVICE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LUNASERVICE_IPK_DIR)/opt/etc/lunaservice/...
# Documentation files should be installed in $(LUNASERVICE_IPK_DIR)/opt/doc/lunaservice/...
# Daemon startup scripts should be installed in $(LUNASERVICE_IPK_DIR)/opt/etc/init.d/S??lunaservice
#
# You may need to patch your application to make it use these locations.
#
$(LUNASERVICE_IPK): $(LUNASERVICE_BUILD_DIR)/.built
	rm -rf $(LUNASERVICE_IPK_DIR) $(BUILD_DIR)/lunaservice_*_$(TARGET_ARCH).ipk
	mkdir -p $(LUNASERVICE_IPK_DIR)/opt/include $(LUNASERVICE_IPK_DIR)/opt/lib
	install -m 644 $(LUNASERVICE_BUILD_DIR)/lunaservice.h $(LUNASERVICE_IPK_DIR)/opt/include/
	install -m 644 $(LUNASERVICE_BUILD_DIR)/lunaservice-errors.h $(LUNASERVICE_IPK_DIR)/opt/include/
	install -m 644 $(LUNASERVICE_BUILD_DIR)/liblunaservice.so $(LUNASERVICE_IPK_DIR)/opt/lib/
	$(MAKE) $(LUNASERVICE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LUNASERVICE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lunaservice-ipk: $(LUNASERVICE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lunaservice-clean:
	rm -f $(LUNASERVICE_BUILD_DIR)/.built
	-$(MAKE) -C $(LUNASERVICE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lunaservice-dirclean:
	rm -rf $(BUILD_DIR)/$(LUNASERVICE_DIR) $(LUNASERVICE_BUILD_DIR) $(LUNASERVICE_IPK_DIR) $(LUNASERVICE_IPK)
#
#
# Some sanity check for the package.
#
lunaservice-check: $(LUNASERVICE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
