###########################################################
#
# poco
#
###########################################################
#
# POCO_VERSION, POCO_SITE and POCO_SOURCE define
# the upstream location of the source code for the package.
# POCO_DIR is the directory which is created when the source
# archive is unpacked.
# POCO_UNZIP is the command used to unzip the source.
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
POCO_VERSION=1.7.4
POCO_URL=http://pocoproject.org/releases/poco-$(POCO_VERSION)/poco-$(POCO_VERSION).tar.gz
POCO_SOURCE=poco-$(POCO_VERSION).tar.gz
POCO_DIR=poco-$(POCO_VERSION)
POCO_UNZIP=zcat
POCO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POCO_DESCRIPTION=POCO C++ Libraries.
POCO_SECTION=libs
POCO_PRIORITY=optional
POCO_DEPENDS=libstdc++
POCO_SUGGESTS=
POCO_CONFLICTS=

#
# POCO_IPK_VERSION should be incremented when the ipk changes.
#
POCO_IPK_VERSION=4

#
# POCO_CONFFILES should be a list of user-editable files
#POCO_CONFFILES=$(TARGET_PREFIX)/etc/poco.conf $(TARGET_PREFIX)/etc/init.d/SXXpoco

#
# POCO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#

#POCO_PATCHES=$(POCO_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
POCO_CPPFLAGS=-fPIC
POCO_LDFLAGS=

#
# POCO_BUILD_DIR is the directory in which the build is done.
# POCO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# POCO_IPK_DIR is the directory in which the ipk is built.
# POCO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
POCO_BUILD_DIR=$(BUILD_DIR)/poco
POCO_SOURCE_DIR=$(SOURCE_DIR)/poco
POCO_IPK_DIR=$(BUILD_DIR)/poco-$(POCO_VERSION)-ipk
POCO_IPK=$(BUILD_DIR)/poco_$(POCO_VERSION)-$(POCO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: poco-source poco-unpack poco poco-stage poco-ipk poco-clean poco-dirclean poco-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(POCO_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(POCO_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(POCO_SOURCE).sha512
#
$(DL_DIR)/$(POCO_SOURCE):
	$(WGET) -O $@ $(POCO_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
poco-source: $(DL_DIR)/$(POCO_SOURCE) $(POCO_PATCHES)

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

$(POCO_BUILD_DIR)/.configured: $(DL_DIR)/$(POCO_SOURCE) $(POCO_PATCHES) make/poco.mk
	rm -rf $(BUILD_DIR)/$(POCO_DIR) $(@D)
	$(POCO_UNZIP) $(DL_DIR)/$(POCO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(POCO_PATCHES)" ; \
		then cat $(POCO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(POCO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(POCO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(POCO_DIR) $(@D) ; \
	fi
	(cd $(@D)/build/config; \
	    ( \
		echo 'LINKMODE = SHARED'; \
		echo 'POCO_TARGET_OSNAME = Linux'; \
		echo "POCO_TARGET_OSARCH = $(TARGET_ARCH)"; \
		echo 'CC      = $(TARGET_CC)'; \
		echo 'CXX     = $(TARGET_CXX)'; \
		echo 'LINK    = $$(CXX)'; \
		echo 'LIB     = $(TARGET_AR) -cr'; \
		echo 'RANLIB  = $(TARGET_RANLIB)'; \
		echo 'STRIP   = $(TARGET_STRIP)'; \
		echo 'SHLIB   = $$(CXX) -shared -Wl,-soname,$$(notdir $$@) -o $$@'; \
		echo 'SHLIBLN = $$(POCO_BASE)/build/script/shlibln'; \
		echo 'DEP     = $$(POCO_BASE)/build/script/makedepend.gcc'; \
		echo 'SHELL   = sh'; \
		echo 'RM      = rm -rf'; \
		echo 'CP      = cp'; \
		echo 'MKDIR   = mkdir -p'; \
		echo 'SHAREDLIBEXT     = .so.$$(target_version)'; \
		echo 'SHAREDLIBLINKEXT = .so'; \
		echo 'CFLAGS          = -Isrc $(STAGING_CPPFLAGS) $(POCO_CPPFLAGS)'; \
		echo 'CFLAGS32        ='; \
		echo 'CFLAGS64        ='; \
		echo 'CXXFLAGS        = $(STAGING_CPPFLAGS) $(POCO_CPPFLAGS)'; \
		echo 'CXXFLAGS32      ='; \
		echo 'CXXFLAGS64      ='; \
		echo 'LINKFLAGS       ='; \
		echo 'LINKFLAGS32     ='; \
		echo 'LINKFLAGS64     ='; \
		echo 'STATICOPT_CC    ='; \
		echo 'STATICOPT_CXX   ='; \
		echo 'STATICOPT_LINK  = -static'; \
		echo 'SHAREDOPT_CC    = -fPIC'; \
		echo "SHAREDOPT_CXX   = $(STAGING_CPPFLAGS) $(POCO_CPPFLAGS)"; \
		echo "SHAREDOPT_LINK  = $(STAGING_LDFLAGS) $(POCO_LDFLAGS)"; \
		echo 'DEBUGOPT_CC     = -g -D_DEBUG'; \
		echo 'DEBUGOPT_CXX    = -g -D_DEBUG'; \
		echo 'DEBUGOPT_LINK   = -g'; \
		echo 'RELEASEOPT_CC   = -O2 -DNDEBUG'; \
		echo 'RELEASEOPT_CXX  = -O2 -DNDEBUG'; \
		echo 'RELEASEOPT_LINK = -O2'; \
		echo 'SHLIBFLAGS      = $(STAGING_LDFLAGS) $(POCO_LDFLAGS)'; \
		echo 'SYSFLAGS = -D_XOPEN_SOURCE=500 -D_BSD_SOURCE -D_REENTRANT -D_THREAD_SAFE -DPOCO_NO_FPENVIRONMENT'; \
		echo 'SYSLIBS  = -lpthread -ldl -lrt'; \
	    ) >> Optware-ng; \
	)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--config=Optware-ng \
		--minimal \
		--no-samples \
		--no-tests \
		--no-prefix \
	)
	touch $@

poco-unpack: $(POCO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(POCO_BUILD_DIR)/.built: $(POCO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
poco: $(POCO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(POCO_BUILD_DIR)/.staged: $(POCO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR)$(TARGET_PREFIX) install
	touch $@

poco-stage: $(POCO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/poco
#
$(POCO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: poco" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POCO_PRIORITY)" >>$@
	@echo "Section: $(POCO_SECTION)" >>$@
	@echo "Version: $(POCO_VERSION)-$(POCO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POCO_MAINTAINER)" >>$@
	@echo "Source: $(POCO_URL)" >>$@
	@echo "Description: $(POCO_DESCRIPTION)" >>$@
	@echo "Depends: $(POCO_DEPENDS)" >>$@
	@echo "Suggests: $(POCO_SUGGESTS)" >>$@
	@echo "Conflicts: $(POCO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(POCO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(POCO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(POCO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(POCO_IPK_DIR)$(TARGET_PREFIX)/etc/poco/...
# Documentation files should be installed in $(POCO_IPK_DIR)$(TARGET_PREFIX)/doc/poco/...
# Daemon startup scripts should be installed in $(POCO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??poco
#
# You may need to patch your application to make it use these locations.
#
$(POCO_IPK): $(POCO_BUILD_DIR)/.built
	rm -rf $(POCO_IPK_DIR) $(BUILD_DIR)/poco_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POCO_BUILD_DIR) DESTDIR=$(POCO_IPK_DIR)$(TARGET_PREFIX) install
	$(STRIP_COMMAND) $(POCO_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	$(MAKE) $(POCO_IPK_DIR)/CONTROL/control
	echo $(POCO_CONFFILES) | sed -e 's/ /\n/g' > $(POCO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POCO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(POCO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
poco-ipk: $(POCO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
poco-clean:
	rm -f $(POCO_BUILD_DIR)/.built
	-$(MAKE) -C $(POCO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
poco-dirclean:
	rm -rf $(BUILD_DIR)/$(POCO_DIR) $(POCO_BUILD_DIR) $(POCO_IPK_DIR) $(POCO_IPK)
#
#
# Some sanity check for the package.
#
poco-check: $(POCO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
