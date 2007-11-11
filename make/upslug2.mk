###########################################################
#
# upslug2
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
# UPSLUG2_REPOSITORY defines the upstream location of the source code
# for the package.  UPSLUG2_DIR is the directory which is created when
# this cvs module is checked out.
#

UPSLUG2_SVN_REPO=http://svn.nslu2-linux.org/svnroot/upslug2/trunk
UPSLUG2_DIR=upslug2
UPSLUG2_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
UPSLUG2_DESCRIPTION=Slug upgrade server
UPSLUG2_SECTION=net
UPSLUG2_PRIORITY=optional
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
UPSLUG2_DEPENDS=libstdc++
endif
UPSLUG2_SUGGESTS=
UPSLUG2_CONFLICTS=

#
# Software downloaded from SVN repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#

#
# If you want to use a date, uncomment the variables below and modify
# UPSLUG2_SVN_DATE
#

#UPSLUG2_SVN_DATE=20050201
#UPSLUG2_VERSION=cvs$(UPSLUG2_SVN_DATE)
#UPSLUG2_SVN_OPTS=-D $(UPSLUG2_SVN_DATE)

#
# If you want to use a tag, uncomment the variables below and modify
# UPSLUG2_SVN_TAG and UPSLUG2_SVN_VERSION
#

UPSLUG2_SVN_REV=0040
UPSLUG2_VERSION=0.0+svn$(UPSLUG2_SVN_REV)

#
# UPSLUG2_IPK_VERSION should be incremented when the ipk changes.
#
UPSLUG2_IPK_VERSION=1

#
# UPSLUG2_CONFFILES should be a list of user-editable files
UPSLUG2_CONFFILES=

#
# UPSLUG2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UPSLUG2_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UPSLUG2_CPPFLAGS=
UPSLUG2_LDFLAGS=

#
# UPSLUG2_BUILD_DIR is the directory in which the build is done.
# UPSLUG2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UPSLUG2_IPK_DIR is the directory in which the ipk is built.
# UPSLUG2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UPSLUG2_BUILD_DIR=$(BUILD_DIR)/upslug2
UPSLUG2_SOURCE_DIR=$(SOURCE_DIR)/upslug2
UPSLUG2_IPK_DIR=$(BUILD_DIR)/upslug2-$(UPSLUG2_VERSION)-ipk
UPSLUG2_IPK=$(BUILD_DIR)/upslug2_$(UPSLUG2_VERSION)-$(UPSLUG2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: upslug2-source upslug2-unpack upslug2 upslug2-stage upslug2-ipk upslug2-clean upslug2-dirclean upslug2-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with SVN
#
$(DL_DIR)/upslug2-$(UPSLUG2_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(UPSLUG2_DIR) && \
		svn co -r$(UPSLUG2_SVN_REV) $(UPSLUG2_SVN_REPO) upslug2 && \
		tar -czf $@ $(UPSLUG2_DIR) && \
		rm -rf $(UPSLUG2_DIR) \
	)

upslug2-source: $(DL_DIR)/upslug2-$(UPSLUG2_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) upslug2-stage <baz>-stage").
#
$(UPSLUG2_BUILD_DIR)/.configured: $(DL_DIR)/upslug2-$(UPSLUG2_VERSION).tar.gz
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(UPSLUG2_DIR) $(UPSLUG2_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/upslug2-$(UPSLUG2_VERSION).tar.gz
	if test -n "$(UPSLUG2_PATCHES)" ; \
		then cat $(UPSLUG2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UPSLUG2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UPSLUG2_DIR)" != "$(UPSLUG2_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UPSLUG2_DIR) $(UPSLUG2_BUILD_DIR) ; \
	fi
	(cd $(UPSLUG2_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -i ;\
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UPSLUG2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UPSLUG2_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(UPSLUG2_BUILD_DIR)/.configured

upslug2-unpack: $(UPSLUG2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UPSLUG2_BUILD_DIR)/.built: $(UPSLUG2_BUILD_DIR)/.configured
	rm -f $(UPSLUG2_BUILD_DIR)/.built
	$(MAKE) -C $(UPSLUG2_BUILD_DIR)
	touch $(UPSLUG2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
upslug2: $(UPSLUG2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UPSLUG2_BUILD_DIR)/.staged: $(UPSLUG2_BUILD_DIR)/.built
	rm -f $(UPSLUG2_BUILD_DIR)/.staged
	$(MAKE) -C $(UPSLUG2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(UPSLUG2_BUILD_DIR)/.staged

upslug2-stage: $(UPSLUG2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/upslug2
#
$(UPSLUG2_IPK_DIR)/CONTROL/control:
	@install -d $(UPSLUG2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: upslug2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UPSLUG2_PRIORITY)" >>$@
	@echo "Section: $(UPSLUG2_SECTION)" >>$@
	@echo "Version: $(UPSLUG2_VERSION)-$(UPSLUG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UPSLUG2_MAINTAINER)" >>$@
	@echo "Source: $(UPSLUG2_SVN_REPO)" >>$@
	@echo "Description: $(UPSLUG2_DESCRIPTION)" >>$@
	@echo "Depends: $(UPSLUG2_DEPENDS)" >>$@
	@echo "Suggests: $(UPSLUG2_SUGGESTS)" >>$@
	@echo "Conflicts: $(UPSLUG2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UPSLUG2_IPK_DIR)/opt/sbin or $(UPSLUG2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UPSLUG2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UPSLUG2_IPK_DIR)/opt/etc/upslug2/...
# Documentation files should be installed in $(UPSLUG2_IPK_DIR)/opt/doc/upslug2/...
# Daemon startup scripts should be installed in $(UPSLUG2_IPK_DIR)/opt/etc/init.d/S??upslug2
#
# You may need to patch your application to make it use these locations.
#
$(UPSLUG2_IPK): $(UPSLUG2_BUILD_DIR)/.built
	rm -rf $(UPSLUG2_IPK_DIR) $(BUILD_DIR)/upslug2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UPSLUG2_BUILD_DIR) DESTDIR=$(UPSLUG2_IPK_DIR) install-strip
#	install -d $(UPSLUG2_IPK_DIR)/opt/etc/
#	install -m 644 $(UPSLUG2_SOURCE_DIR)/upslug2.conf $(UPSLUG2_IPK_DIR)/opt/etc/upslug2.conf
#	install -d $(UPSLUG2_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UPSLUG2_SOURCE_DIR)/rc.upslug2 $(UPSLUG2_IPK_DIR)/opt/etc/init.d/SXXupslug2
	$(MAKE) $(UPSLUG2_IPK_DIR)/CONTROL/control
#	install -m 755 $(UPSLUG2_SOURCE_DIR)/postinst $(UPSLUG2_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UPSLUG2_SOURCE_DIR)/prerm $(UPSLUG2_IPK_DIR)/CONTROL/prerm
#	echo $(UPSLUG2_CONFFILES) | sed -e 's/ /\n/g' > $(UPSLUG2_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UPSLUG2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
upslug2-ipk: $(UPSLUG2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
upslug2-clean:
	rm -f $(UPSLUG2_BUILD_DIR)/.built
	-$(MAKE) -C $(UPSLUG2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
upslug2-dirclean:
	rm -rf $(BUILD_DIR)/$(UPSLUG2_DIR) $(UPSLUG2_BUILD_DIR) $(UPSLUG2_IPK_DIR) $(UPSLUG2_IPK)

#
# Some sanity check for the package.
#
upslug2-check: $(UPSLUG2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UPSLUG2_IPK)
