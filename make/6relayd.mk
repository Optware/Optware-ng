###########################################################
#
# 6relayd
#
###########################################################
#
# 6RELAYD_VERSION, 6RELAYD_SITE and 6RELAYD_SOURCE define
# the upstream location of the source code for the package.
# 6RELAYD_DIR is the directory which is created when the source
# archive is unpacked.
# 6RELAYD_UNZIP is the command used to unzip the source.
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
6RELAYD_REPOSITORY=git://github.com/sbyx/6relayd.git
6RELAYD_GIT_DATE=20131210
6RELAYD_VERSION=git$(6RELAYD_GIT_DATE)
6RELAYD_TREEISH=`git rev-list --max-count=1 --until=2013-12-10 HEAD`
6RELAYD_SOURCE=6relayd-$(6RELAYD_VERSION).tar.gz
6RELAYD_DIR=6relayd-$(6RELAYD_VERSION)
6RELAYD_UNZIP=zcat
6RELAYD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
6RELAYD_DESCRIPTION=6relayd is a daemon for serving and relaying IPv6 management protocols to configure clients and downstream routers.
6RELAYD_SECTION=net
6RELAYD_PRIORITY=optional
6RELAYD_DEPENDS=
6RELAYD_SUGGESTS=
6RELAYD_CONFLICTS=

#
# 6RELAYD_IPK_VERSION should be incremented when the ipk changes.
#
6RELAYD_IPK_VERSION=3

#
# 6RELAYD_CONFFILES should be a list of user-editable files
#6RELAYD_CONFFILES=$(TARGET_PREFIX)/etc/6relayd.conf $(TARGET_PREFIX)/etc/init.d/SXX6relayd

#
# 6RELAYD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#6RELAYD_PATCHES=$(6RELAYD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
6RELAYD_CPPFLAGS=
6RELAYD_LDFLAGS=

#
# 6RELAYD_BUILD_DIR is the directory in which the build is done.
# 6RELAYD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# 6RELAYD_IPK_DIR is the directory in which the ipk is built.
# 6RELAYD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
6RELAYD_BUILD_DIR=$(BUILD_DIR)/6relayd
6RELAYD_SOURCE_DIR=$(SOURCE_DIR)/6relayd
6RELAYD_IPK_DIR=$(BUILD_DIR)/6relayd-$(6RELAYD_VERSION)-ipk
6RELAYD_IPK=$(BUILD_DIR)/6relayd_$(6RELAYD_VERSION)-$(6RELAYD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: 6relayd-source 6relayd-unpack 6relayd 6relayd-stage 6relayd-ipk 6relayd-clean 6relayd-dirclean 6relayd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(6RELAYD_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(6RELAYD_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(6RELAYD_SOURCE).sha512
#
$(DL_DIR)/$(6RELAYD_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf 6relayd && \
		git clone --bare $(6RELAYD_REPOSITORY) 6relayd && \
		(cd 6relayd && \
		git archive --format=tar --prefix=$(6RELAYD_DIR)/ $(6RELAYD_TREEISH) | gzip > $@) && \
		rm -rf 6relayd ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
6relayd-source: $(DL_DIR)/$(6RELAYD_SOURCE) $(6RELAYD_PATCHES)

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
$(6RELAYD_BUILD_DIR)/.configured: $(DL_DIR)/$(6RELAYD_SOURCE) $(6RELAYD_PATCHES) make/6relayd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(6RELAYD_DIR) $(@D)
	$(6RELAYD_UNZIP) $(DL_DIR)/$(6RELAYD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(6RELAYD_PATCHES)" ; \
		then cat $(6RELAYD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(6RELAYD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(6RELAYD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(6RELAYD_DIR) $(@D) ; \
	fi
	sed -i -e 's/-Werror//' $(@D)/CMakeLists.txt
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(6RELAYD_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(6RELAYD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(6RELAYD_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(6RELAYD_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(6RELAYD_LDFLAGS)"
ifeq ($(OPTWARE_TARGET), $(filter buildroot-ppc-603e ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
	# '_unused' macro declaration conflicts with 'struct sigcontext' declaration in <asm/sigcontext.h>
	sed -i -e 's/_unused/_&/g' $(@D)/src/*.[ch]
endif
	touch $@

6relayd-unpack: $(6RELAYD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(6RELAYD_BUILD_DIR)/.built: $(6RELAYD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
6relayd: $(6RELAYD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(6RELAYD_BUILD_DIR)/.staged: $(6RELAYD_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#6relayd-stage: $(6RELAYD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/6relayd
#
$(6RELAYD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: 6relayd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(6RELAYD_PRIORITY)" >>$@
	@echo "Section: $(6RELAYD_SECTION)" >>$@
	@echo "Version: $(6RELAYD_VERSION)-$(6RELAYD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(6RELAYD_MAINTAINER)" >>$@
	@echo "Source: $(6RELAYD_REPOSITORY)" >>$@
	@echo "Description: $(6RELAYD_DESCRIPTION)" >>$@
	@echo "Depends: $(6RELAYD_DEPENDS)" >>$@
	@echo "Suggests: $(6RELAYD_SUGGESTS)" >>$@
	@echo "Conflicts: $(6RELAYD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/etc/6relayd/...
# Documentation files should be installed in $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/doc/6relayd/...
# Daemon startup scripts should be installed in $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??6relayd
#
# You may need to patch your application to make it use these locations.
#
$(6RELAYD_IPK): $(6RELAYD_BUILD_DIR)/.built
	rm -rf $(6RELAYD_IPK_DIR) $(BUILD_DIR)/6relayd_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(INSTALL) -m 755 $(6RELAYD_BUILD_DIR)/6relayd  $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(STRIP_COMMAND) $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/sbin/6relayd 
#	$(INSTALL) -m 755 $(6RELAYD_SOURCE_DIR)/rc.6relayd $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXX6relayd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(6RELAYD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXX6relayd
	$(MAKE) $(6RELAYD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(6RELAYD_SOURCE_DIR)/postinst $(6RELAYD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(6RELAYD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(6RELAYD_SOURCE_DIR)/prerm $(6RELAYD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(6RELAYD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(6RELAYD_IPK_DIR)/CONTROL/postinst $(6RELAYD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(6RELAYD_CONFFILES) | sed -e 's/ /\n/g' > $(6RELAYD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(6RELAYD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(6RELAYD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
6relayd-ipk: $(6RELAYD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
6relayd-clean:
	rm -f $(6RELAYD_BUILD_DIR)/.built
	-$(MAKE) -C $(6RELAYD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
6relayd-dirclean:
	rm -rf $(BUILD_DIR)/$(6RELAYD_DIR) $(6RELAYD_BUILD_DIR) $(6RELAYD_IPK_DIR) $(6RELAYD_IPK)
#
#
# Some sanity check for the package.
#
6relayd-check: $(6RELAYD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
