###########################################################
#
# git-core
#
###########################################################

#
# GIT-CORE_VERSION, GIT-CORE_SITE and GIT-CORE_SOURCE define
# the upstream location of the source code for the package.
# GIT-CORE_DIR is the directory which is created when the source
# archive is unpacked.
# GIT-CORE_UNZIP is the command used to unzip the source.
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
GIT-CORE_SITE=http://www.kernel.org/pub/software/scm/git
GIT-CORE_VERSION=1.4.4.4
GIT-CORE_SOURCE=git-$(GIT-CORE_VERSION).tar.gz
GIT-CORE_DIR=git-$(GIT-CORE_VERSION)
GIT-CORE_UNZIP=zcat
GIT-CORE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GIT-CORE_DESCRIPTION=GIT is a "directory tree content manager" that can be used for distributed revision control.
GIT-CORE_SECTION=net
GIT-CORE_PRIORITY=optional
GIT-CORE_DEPENDS=zlib, openssl, libcurl, diffutils, rcs, expat
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GIT-CORE_DEPENDS+=, libiconv
endif
GIT-CORE_SUGGESTS=
GIT-CORE_CONFLICTS=

#
# GIT-CORE_IPK_VERSION should be incremented when the ipk changes.
#
GIT-CORE_IPK_VERSION=2

#
# GIT-CORE_CONFFILES should be a list of user-editable files
#GIT-CORE_CONFFILES=/opt/etc/git-core.conf /opt/etc/init.d/SXXgit-core

#
# GIT-CORE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GIT-CORE_PATCHES=$(GIT-CORE_SOURCE_DIR)/Makefile.patch \
	$(GIT-CORE_SOURCE_DIR)/templates-Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIT-CORE_CPPFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GIT-CORE_LDFLAGS=-liconv
else
GIT-CORE_LDFLAGS=
endif

#
# GIT-CORE_BUILD_DIR is the directory in which the build is done.
# GIT-CORE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIT-CORE_IPK_DIR is the directory in which the ipk is built.
# GIT-CORE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIT-CORE_BUILD_DIR=$(BUILD_DIR)/git-core
GIT-CORE_SOURCE_DIR=$(SOURCE_DIR)/git-core
GIT-CORE_IPK_DIR=$(BUILD_DIR)/git-core-$(GIT-CORE_VERSION)-ipk
GIT-CORE_IPK=$(BUILD_DIR)/git-core_$(GIT-CORE_VERSION)-$(GIT-CORE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: git-core-source git-core-unpack git-core git-core-stage git-core-ipk git-core-clean git-core-dirclean git-core-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIT-CORE_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIT-CORE_SITE)/$(GIT-CORE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
git-core-source: $(DL_DIR)/$(GIT-CORE_SOURCE) $(GIT-CORE_PATCHES)

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
$(GIT-CORE_BUILD_DIR)/.configured: $(DL_DIR)/$(GIT-CORE_SOURCE) $(GIT-CORE_PATCHES)
	$(MAKE) zlib-stage openssl-stage libcurl-stage expat-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GIT-CORE_DIR) $(GIT-CORE_BUILD_DIR)
	$(GIT-CORE_UNZIP) $(DL_DIR)/$(GIT-CORE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GIT-CORE_PATCHES)" ; \
		then cat $(GIT-CORE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GIT-CORE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GIT-CORE_DIR)" != "$(GIT-CORE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GIT-CORE_DIR) $(GIT-CORE_BUILD_DIR) ; \
	fi
#	(cd $(GIT-CORE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIT-CORE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIT-CORE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(GIT-CORE_BUILD_DIR)/libtool
	touch $(GIT-CORE_BUILD_DIR)/.configured

git-core-unpack: $(GIT-CORE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIT-CORE_BUILD_DIR)/.built: $(GIT-CORE_BUILD_DIR)/.configured
	rm -f $(GIT-CORE_BUILD_DIR)/.built
	PATH="$(STAGING_PREFIX)/bin:$$PATH" \
	$(MAKE) -C $(GIT-CORE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIT-CORE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIT-CORE_LDFLAGS)" \
		prefix=/opt all strip
	touch $(GIT-CORE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
git-core: $(GIT-CORE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GIT-CORE_BUILD_DIR)/.staged: $(GIT-CORE_BUILD_DIR)/.built
	rm -f $(GIT-CORE_BUILD_DIR)/.staged
	$(MAKE) -C $(GIT-CORE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GIT-CORE_BUILD_DIR)/.staged

git-core-stage: $(GIT-CORE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/git-core
#
$(GIT-CORE_IPK_DIR)/CONTROL/control:
	@install -d $(GIT-CORE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: git-core" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIT-CORE_PRIORITY)" >>$@
	@echo "Section: $(GIT-CORE_SECTION)" >>$@
	@echo "Version: $(GIT-CORE_VERSION)-$(GIT-CORE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIT-CORE_MAINTAINER)" >>$@
	@echo "Source: $(GIT-CORE_SITE)/$(GIT-CORE_SOURCE)" >>$@
	@echo "Description: $(GIT-CORE_DESCRIPTION)" >>$@
	@echo "Depends: $(GIT-CORE_DEPENDS)" >>$@
	@echo "Suggests: $(GIT-CORE_SUGGESTS)" >>$@
	@echo "Conflicts: $(GIT-CORE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIT-CORE_IPK_DIR)/opt/sbin or $(GIT-CORE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIT-CORE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIT-CORE_IPK_DIR)/opt/etc/git-core/...
# Documentation files should be installed in $(GIT-CORE_IPK_DIR)/opt/doc/git-core/...
# Daemon startup scripts should be installed in $(GIT-CORE_IPK_DIR)/opt/etc/init.d/S??git-core
#
# You may need to patch your application to make it use these locations.
#
$(GIT-CORE_IPK): $(GIT-CORE_BUILD_DIR)/.built
	rm -rf $(GIT-CORE_IPK_DIR) $(BUILD_DIR)/git-core_*_$(TARGET_ARCH).ipk
	PATH="$(STAGING_PREFIX)/bin:$$PATH" \
	$(MAKE) -C $(GIT-CORE_BUILD_DIR) DESTDIR=$(GIT-CORE_IPK_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIT-CORE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIT-CORE_LDFLAGS)" \
		prefix=/opt \
		install
	-$(STRIP_COMMAND) $(GIT-CORE_IPK_DIR)/opt/bin/git-daemon
#	install -d $(GIT-CORE_IPK_DIR)/opt/etc/
#	install -m 644 $(GIT-CORE_SOURCE_DIR)/git-core.conf $(GIT-CORE_IPK_DIR)/opt/etc/git-core.conf
#	install -d $(GIT-CORE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GIT-CORE_SOURCE_DIR)/rc.git-core $(GIT-CORE_IPK_DIR)/opt/etc/init.d/SXXgit-core
	$(MAKE) $(GIT-CORE_IPK_DIR)/CONTROL/control
#	install -m 755 $(GIT-CORE_SOURCE_DIR)/postinst $(GIT-CORE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GIT-CORE_SOURCE_DIR)/prerm $(GIT-CORE_IPK_DIR)/CONTROL/prerm
#	echo $(GIT-CORE_CONFFILES) | sed -e 's/ /\n/g' > $(GIT-CORE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIT-CORE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
git-core-ipk: $(GIT-CORE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
git-core-clean:
	rm -f $(GIT-CORE_BUILD_DIR)/.built
	-$(MAKE) -C $(GIT-CORE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
git-core-dirclean:
	rm -rf $(BUILD_DIR)/$(GIT-CORE_DIR) $(GIT-CORE_BUILD_DIR) $(GIT-CORE_IPK_DIR) $(GIT-CORE_IPK)

#
# Some sanity check for the package.
#
git-core-check: $(GIT-CORE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GIT-CORE_IPK)
