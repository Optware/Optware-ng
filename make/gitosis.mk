###########################################################
#
# gitosis
#
###########################################################

#
# GITOSIS_REPOSITORY defines the upstream location of the source code
# for the package.
#

GITOSIS_REPOSITORY=git://eagain.net/gitosis.git
GITOSIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GITOSIS_DESCRIPTION=Git repository hosting application.
GITOSIS_SECTION=misc
GITOSIS_PRIORITY=optional
GITOSIS_DEPENDS=adduser, git, openssh, python25
GITOSIS_SUGGESTS=sudo
GITOSIS_CONFLICTS=

#
# Software cloned from GIT repositories must either use a tag or a
# date to ensure that the same sources can be recreated later.
#

#
# If you want to use a date, uncomment the variables below and modify
# GITOSIS_GIT_DATE
#

GITOSIS_GIT_DATE=20080901
GITOSIS_VERSION=git$(GITOSIS_GIT_DATE)
GITOSIS_TREEISH=`git rev-list --max-count=1 --until=2008-09-01 HEAD`

#
# If you want to use a tag, uncomment the variables below and modify
# GITOSIS_GIT_TAG and GITOSIS_GIT_VERSION
#

#GITOSIS_GIT_TAG=v1.2.3
#GITOSIS_VERSION=1.2.3
#GITOSIS_TREEISH=$(GITOSIS_GIT_TAG)

GITOSIS_DIR=gitosis-$(GITOSIS_VERSION)

#
# GITOSIS_IPK_VERSION should be incremented when the ipk changes.
#
GITOSIS_IPK_VERSION=1

#
# GITOSIS_CONFFILES should be a list of user-editable files
GITOSIS_CONFFILES=

#
# GITOSIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GITOSIS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GITOSIS_CPPFLAGS=
GITOSIS_LDFLAGS=

#
# GITOSIS_BUILD_DIR is the directory in which the build is done.
# GITOSIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GITOSIS_IPK_DIR is the directory in which the ipk is built.
# GITOSIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GITOSIS_BUILD_DIR=$(BUILD_DIR)/gitosis
GITOSIS_SOURCE_DIR=$(SOURCE_DIR)/gitosis
GITOSIS_IPK_DIR=$(BUILD_DIR)/gitosis-$(GITOSIS_VERSION)-ipk
GITOSIS_IPK=$(BUILD_DIR)/gitosis_$(GITOSIS_VERSION)-$(GITOSIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gitosis-source gitosis-unpack gitosis gitosis-stage gitosis-ipk gitosis-clean gitosis-dirclean gitosis-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/$(GITOSIS_DIR).tar.gz:
	(cd $(BUILD_DIR) ; \
		rm -rf gitosis && \
		git clone --bare $(GITOSIS_REPOSITORY) gitosis && \
		cd gitosis && \
		(git archive --format=tar --prefix=$(GITOSIS_DIR)/ $(GITOSIS_TREEISH) | gzip > $@) && \
		rm -rf gitosis ; \
	)

gitosis-source: $(DL_DIR)/$(GITOSIS_DIR).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(GITOSIS_BUILD_DIR)/.configured: $(DL_DIR)/gitosis-$(GITOSIS_VERSION).tar.gz make/gitosis.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(GITOSIS_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/gitosis-$(GITOSIS_VERSION).tar.gz
	if test -n "$(GITOSIS_PATCHES)" ; \
		then cat $(GITOSIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GITOSIS_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(GITOSIS_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
		( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
		) > setup.cfg \
	)
	touch $@

gitosis-unpack: $(GITOSIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GITOSIS_BUILD_DIR)/.built: $(GITOSIS_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
gitosis: $(GITOSIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(GITOSIS_BUILD_DIR)/.staged: $(GITOSIS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#gitosis-stage: $(GITOSIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gitosis
#
$(GITOSIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gitosis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GITOSIS_PRIORITY)" >>$@
	@echo "Section: $(GITOSIS_SECTION)" >>$@
	@echo "Version: $(GITOSIS_VERSION)-$(GITOSIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GITOSIS_MAINTAINER)" >>$@
	@echo "Source: $(GITOSIS_REPOSITORY)" >>$@
	@echo "Description: $(GITOSIS_DESCRIPTION)" >>$@
	@echo "Depends: $(GITOSIS_DEPENDS)" >>$@
	@echo "Suggests: $(GITOSIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(GITOSIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GITOSIS_IPK_DIR)/opt/sbin or $(GITOSIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GITOSIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GITOSIS_IPK_DIR)/opt/etc/gitosis/...
# Documentation files should be installed in $(GITOSIS_IPK_DIR)/opt/doc/gitosis/...
# Daemon startup scripts should be installed in $(GITOSIS_IPK_DIR)/opt/etc/init.d/S??gitosis
#
# You may need to patch your application to make it use these locations.
#
$(GITOSIS_IPK): $(GITOSIS_BUILD_DIR)/.built
	rm -rf $(GITOSIS_IPK_DIR) $(BUILD_DIR)/gitosis_*_$(TARGET_ARCH).ipk
	cd $(<D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(GITOSIS_IPK_DIR) --prefix=/opt
	install -d $(GITOSIS_IPK_DIR)/opt/share/doc/gitosis
	install $(<D)/2.5/[CMRT]* $(<D)/2.5/example.conf $(GITOSIS_IPK_DIR)/opt/share/doc/gitosis/
	$(MAKE) $(GITOSIS_IPK_DIR)/CONTROL/control
	install -m 755 $(GITOSIS_SOURCE_DIR)/postinst $(GITOSIS_IPK_DIR)/CONTROL/postinst
	echo $(GITOSIS_CONFFILES) | sed -e 's/ /\n/g' > $(GITOSIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GITOSIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gitosis-ipk: $(GITOSIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gitosis-clean:
	rm -f $(GITOSIS_BUILD_DIR)/.built
	-$(MAKE) -C $(GITOSIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gitosis-dirclean:
	rm -rf $(BUILD_DIR)/$(GITOSIS_DIR) $(GITOSIS_BUILD_DIR) $(GITOSIS_IPK_DIR) $(GITOSIS_IPK)

#
# Some sanity check for the package.
#
gitosis-check: $(GITOSIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GITOSIS_IPK)
