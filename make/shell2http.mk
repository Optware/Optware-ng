###########################################################
#
# shell2http
#
###########################################################
#
# SHELL2HTTP_VERSION, SHELL2HTTP_SITE and SHELL2HTTP_SOURCE define
# the upstream location of the source code for the package.
# SHELL2HTTP_DIR is the directory which is created when the source
# archive is unpacked.
# SHELL2HTTP_UNZIP is the command used to unzip the source.
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
SHELL2HTTP_URL=https://github.com/msoap/shell2http/archive/$(SHELL2HTTP_VERSION).tar.gz
SHELL2HTTP_VERSION?=1.10
SHELL2HTTP_SOURCE=shell2http-$(SHELL2HTTP_VERSION).tar.gz
SHELL2HTTP_DIR=shell2http-$(SHELL2HTTP_VERSION)

SHELL2HTTP_GO_SHELLWORDS_URL=https://github.com/mattn/go-shellwords/archive/v$(SHELL2HTTP_GO_SHELLWORDS_VERSION).tar.gz
SHELL2HTTP_GO_SHELLWORDS_VERSION=1.0.3
SHELL2HTTP_GO_SHELLWORDS_SOURCE=shell2http-go-shellwords-$(SHELL2HTTP_GO_SHELLWORDS_VERSION).tar.gz
SHELL2HTTP_GO_SHELLWORDS_DIR=go-shellwords-$(SHELL2HTTP_GO_SHELLWORDS_VERSION)

SHELL2HTTP_RAPHANUS_URL=https://github.com/msoap/raphanus/archive/$(SHELL2HTTP_RAPHANUS_VERSION).tar.gz
SHELL2HTTP_RAPHANUS_VERSION=0.10
SHELL2HTTP_RAPHANUS_SOURCE=shell2http-raphanus-$(SHELL2HTTP_RAPHANUS_VERSION).tar.gz
SHELL2HTTP_RAPHANUS_DIR=raphanus-$(SHELL2HTTP_RAPHANUS_VERSION)

SHELL2HTTP_UNZIP=zcat
SHELL2HTTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHELL2HTTP_DESCRIPTION=Execute shell commands via simple http server.
SHELL2HTTP_SECTION=net
SHELL2HTTP_PRIORITY=optional
SHELL2HTTP_DEPENDS=libgo
SHELL2HTTP_SUGGESTS=
SHELL2HTTP_CONFLICTS=

#
# SHELL2HTTP_IPK_VERSION should be incremented when the ipk changes.
#
SHELL2HTTP_IPK_VERSION?=1

#
# SHELL2HTTP_CONFFILES should be a list of user-editable files
#SHELL2HTTP_CONFFILES=$(TARGET_PREFIX)/etc/shell2http.conf $(TARGET_PREFIX)/etc/init.d/SXXshell2http

#
# SHELL2HTTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SHELL2HTTP_PATCHES=\
$(SHELL2HTTP_SOURCE_DIR)/raphanus-0.10-compat.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHELL2HTTP_CPPFLAGS=
SHELL2HTTP_LDFLAGS=

#
# SHELL2HTTP_BUILD_DIR is the directory in which the build is done.
# SHELL2HTTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHELL2HTTP_IPK_DIR is the directory in which the ipk is built.
# SHELL2HTTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHELL2HTTP_BUILD_DIR=$(BUILD_DIR)/shell2http
SHELL2HTTP_SOURCE_DIR=$(SOURCE_DIR)/shell2http
SHELL2HTTP_IPK_DIR=$(BUILD_DIR)/shell2http-$(SHELL2HTTP_VERSION)-ipk
SHELL2HTTP_IPK=$(BUILD_DIR)/shell2http_$(SHELL2HTTP_VERSION)-$(SHELL2HTTP_IPK_VERSION)_$(TARGET_ARCH).ipk

SHELL2HTTP_SOURCES=\
$(DL_DIR)/$(SHELL2HTTP_SOURCE) \
$(DL_DIR)/$(SHELL2HTTP_GO_SHELLWORDS_SOURCE) \
$(DL_DIR)/$(SHELL2HTTP_RAPHANUS_SOURCE) \

.PHONY: shell2http-source shell2http-unpack shell2http shell2http-stage shell2http-ipk shell2http-clean shell2http-dirclean shell2http-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(SHELL2HTTP_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(SHELL2HTTP_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(SHELL2HTTP_SOURCE).sha512
#
$(DL_DIR)/$(SHELL2HTTP_SOURCE):
	$(WGET) -O $@ $(SHELL2HTTP_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(SHELL2HTTP_GO_SHELLWORDS_SOURCE):
	$(WGET) -O $@ $(SHELL2HTTP_GO_SHELLWORDS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(SHELL2HTTP_RAPHANUS_SOURCE):
	$(WGET) -O $@ $(SHELL2HTTP_RAPHANUS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
shell2http-source: $(SHELL2HTTP_SOURCES) $(SHELL2HTTP_PATCHES)

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
$(SHELL2HTTP_BUILD_DIR)/.configured: $(SHELL2HTTP_SOURCES) $(SHELL2HTTP_PATCHES) make/shell2http.mk
	$(MAKE) gcc-host
	rm -rf $(BUILD_DIR)/$(SHELL2HTTP_DIR) $(@D)
	$(SHELL2HTTP_UNZIP) $(DL_DIR)/$(SHELL2HTTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(SHELL2HTTP_UNZIP) $(DL_DIR)/$(SHELL2HTTP_GO_SHELLWORDS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(SHELL2HTTP_UNZIP) $(DL_DIR)/$(SHELL2HTTP_RAPHANUS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mkdir -p $(@D)/src/github.com/msoap $(@D)/src/github.com/mattn
	mv -f $(BUILD_DIR)/$(SHELL2HTTP_DIR) $(@D)/src/github.com/msoap/shell2http
	mv -f $(BUILD_DIR)/$(SHELL2HTTP_GO_SHELLWORDS_DIR) $(@D)/src/github.com/mattn/go-shellwords
	mv -f $(BUILD_DIR)/$(SHELL2HTTP_RAPHANUS_DIR) $(@D)/src/github.com/msoap/raphanus
	if test -n "$(SHELL2HTTP_PATCHES)" ; \
		then cat $(SHELL2HTTP_PATCHES) | \
		$(PATCH) -d $(@D) -p1 ; \
	fi
	touch $@

shell2http-unpack: $(SHELL2HTTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SHELL2HTTP_BUILD_DIR)/.built: $(SHELL2HTTP_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_GCCGO_GO_ENV) GOPATH=$(@D) $(GCC_HOST_BIN_DIR)/go install -v github.com/msoap/shell2http
	touch $@

#
# This is the build convenience target.
#
shell2http: $(SHELL2HTTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHELL2HTTP_BUILD_DIR)/.staged: $(SHELL2HTTP_BUILD_DIR)/.built
	rm -f $@
	touch $@

shell2http-stage: $(SHELL2HTTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/shell2http
#
$(SHELL2HTTP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: shell2http" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHELL2HTTP_PRIORITY)" >>$@
	@echo "Section: $(SHELL2HTTP_SECTION)" >>$@
	@echo "Version: $(SHELL2HTTP_VERSION)-$(SHELL2HTTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHELL2HTTP_MAINTAINER)" >>$@
	@echo "Source: $(SHELL2HTTP_URL)" >>$@
	@echo "Description: $(SHELL2HTTP_DESCRIPTION)" >>$@
	@echo "Depends: $(SHELL2HTTP_DEPENDS)" >>$@
	@echo "Suggests: $(SHELL2HTTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHELL2HTTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/shell2http/...
# Documentation files should be installed in $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/doc/shell2http/...
# Daemon startup scripts should be installed in $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??shell2http
#
# You may need to patch your application to make it use these locations.
#
$(SHELL2HTTP_IPK): $(SHELL2HTTP_BUILD_DIR)/.built
	rm -rf $(SHELL2HTTP_IPK_DIR) $(BUILD_DIR)/shell2http_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(SHELL2HTTP_BUILD_DIR)/bin/linux_$(TARGET_GOARCH)/shell2http \
		$(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/bin
#	$(INSTALL) -d $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SHELL2HTTP_SOURCE_DIR)/shell2http.conf $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/shell2http.conf
#	$(INSTALL) -d $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SHELL2HTTP_SOURCE_DIR)/rc.shell2http $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshell2http
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELL2HTTP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshell2http
	$(MAKE) $(SHELL2HTTP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SHELL2HTTP_SOURCE_DIR)/postinst $(SHELL2HTTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELL2HTTP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SHELL2HTTP_SOURCE_DIR)/prerm $(SHELL2HTTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELL2HTTP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SHELL2HTTP_IPK_DIR)/CONTROL/postinst $(SHELL2HTTP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SHELL2HTTP_CONFFILES) | sed -e 's/ /\n/g' > $(SHELL2HTTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHELL2HTTP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SHELL2HTTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
shell2http-ipk: $(SHELL2HTTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
shell2http-clean:
	rm -f $(SHELL2HTTP_BUILD_DIR)/.built
	-$(MAKE) -C $(SHELL2HTTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
shell2http-dirclean:
	rm -rf $(BUILD_DIR)/$(SHELL2HTTP_DIR) $(SHELL2HTTP_BUILD_DIR) $(SHELL2HTTP_IPK_DIR) $(SHELL2HTTP_IPK)
#
#
# Some sanity check for the package.
#
shell2http-check: $(SHELL2HTTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
