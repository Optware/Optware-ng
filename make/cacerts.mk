###########################################################
#
# cacerts
#
###########################################################
#
# CACERTS_VERSION, CACERTS_SITE and CACERTS_SOURCE define
# the upstream location of the source code for the package.
# CACERTS_DIR is the directory which is created when the source
# archive is unpacked.
# CACERTS_UNZIP is the command used to unzip the source.
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
CACERTS_URL=http://www.linuxfromscratch.org/blfs/view/cvs/postlfs/cacerts.html
CACERTS_CERTDATA_URL=http://anduin.linuxfromscratch.org/BLFS/other/certdata.txt
CACERTS_SOURCE=certdata.txt
CACERTS_VERSION:=$(shell ( $(WGET_BINARY) -qO- $(CACERTS_CERTDATA_URL) 2>/dev/null || cat $(DL_DIR)/$(CACERTS_SOURCE) 2>/dev/null ) | head -1 | sed -n -e '/\$$Revision: /s/.*\$$Revision: \([0-9]*\).*/\1/p')
CACERTS_DIR=cacerts
CACERTS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CACERTS_DESCRIPTION=Certificate Authority Certificates.
CACERTS_SECTION=misc
CACERTS_PRIORITY=optional
CACERTS_DEPENDS=
CACERTS_SUGGESTS=
CACERTS_CONFLICTS=

#
# CACERTS_IPK_VERSION should be incremented when the ipk changes.
#
CACERTS_IPK_VERSION=1

#
# CACERTS_CONFFILES should be a list of user-editable files
#CACERTS_CONFFILES=$(TARGET_PREFIX)/etc/cacerts.conf $(TARGET_PREFIX)/etc/init.d/SXXcacerts

#
# CACERTS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CACERTS_PATCHES=$(CACERTS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CACERTS_CPPFLAGS=
CACERTS_LDFLAGS=

#
# CACERTS_BUILD_DIR is the directory in which the build is done.
# CACERTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CACERTS_IPK_DIR is the directory in which the ipk is built.
# CACERTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CACERTS_BUILD_DIR=$(HOST_BUILD_DIR)/cacerts
CACERTS_SOURCE_DIR=$(SOURCE_DIR)/cacerts
CACERTS_IPK_DIR=$(BUILD_DIR)/cacerts-$(CACERTS_VERSION)-ipk
CACERTS_IPK=$(BUILD_DIR)/cacerts_$(CACERTS_VERSION)-$(CACERTS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cacerts-source cacerts-unpack cacerts cacerts-stage cacerts-ipk cacerts-clean cacerts-dirclean cacerts-check

$(DL_DIR)/$(CACERTS_SOURCE): make/cacerts.mk
ifeq (,$(CACERTS_VERSION))
	$(error Failed to fetch $(CACERTS_CERTDATA_URL) or to parse Revision date)
endif
ifneq ($(CACERTS_VERSION), $(shell cat $(DL_DIR)/$(CACERTS_SOURCE) 2>/dev/null | head -1 | sed -e 's/.*\$$Revision: \([0-9]*\).*/\1/'))
	SKIP_CHECKSUM=1 $(WGET) -O $@ $(CACERTS_CERTDATA_URL)
else
	touch $@
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cacerts-source: $(DL_DIR)/$(CACERTS_SOURCE) $(CACERTS_PATCHES)

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
$(CACERTS_BUILD_DIR)/.configured: host/.configured $(DL_DIR)/$(CACERTS_SOURCE) $(CACERTS_PATCHES) make/cacerts.mk
	$(MAKE) openssl-host-stage perl-hostperl
	rm -rf $(@D) $(JRE_CACERTS_BUILD_DIR)/.configured
	$(INSTALL) -d $(@D)
	$(INSTALL) -m 644 $(DL_DIR)/$(CACERTS_SOURCE) $(@D)
	touch $@

cacerts-unpack: $(CACERTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CACERTS_BUILD_DIR)/.built: $(CACERTS_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); \
		CONVERTSCRIPT="$(PERL_HOSTPERL) $(CACERTS_SOURCE_DIR)/make-cert.pl" \
		sh $(CACERTS_SOURCE_DIR)/make-ca.sh && \
		sh $(CACERTS_SOURCE_DIR)/remove-expired-certs.sh certs && \
		$(HOST_STAGING_PREFIX)/bin/c_rehash certs && \
		ln -sfv ../ca-bundle.crt $(@D)/certs/ca-certificates.crt
	touch $@

#
# This is the build convenience target.
#
cacerts: $(CACERTS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cacerts
#
$(CACERTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cacerts" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CACERTS_PRIORITY)" >>$@
	@echo "Section: $(CACERTS_SECTION)" >>$@
	@echo "Version: $(CACERTS_VERSION)-$(CACERTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CACERTS_MAINTAINER)" >>$@
	@echo "Source: $(CACERTS_URL)" >>$@
	@echo "Description: $(CACERTS_DESCRIPTION)" >>$@
	@echo "Depends: $(CACERTS_DEPENDS)" >>$@
	@echo "Suggests: $(CACERTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CACERTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/cacerts/...
# Documentation files should be installed in $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/doc/cacerts/...
# Daemon startup scripts should be installed in $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cacerts
#
# You may need to patch your application to make it use these locations.
#
$(CACERTS_IPK): $(CACERTS_BUILD_DIR)/.built
ifeq (,$(CACERTS_VERSION))
	$(error Failed to fetch $(CACERTS_CERTDATA_URL) or to parse Revision date)
endif
ifneq ($(CACERTS_VERSION), $(shell cat $(DL_DIR)/$(CACERTS_SOURCE) 2>/dev/null | head -1 | sed -e 's/.*\$$Revision: \([0-9]*\).*/\1/'))
	rm -f $(DL_DIR)/$(CACERTS_SOURCE)
	$(MAKE) cacerts
endif
	rm -rf $(CACERTS_IPK_DIR) $(BUILD_DIR)/cacerts_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/ssl
	cp -af $(CACERTS_BUILD_DIR)/{ca-bundle.crt,certs} $(CACERTS_IPK_DIR)$(TARGET_PREFIX)/etc/ssl
	$(MAKE) $(CACERTS_IPK_DIR)/CONTROL/control
	echo $(CACERTS_CONFFILES) | sed -e 's/ /\n/g' > $(CACERTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CACERTS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CACERTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cacerts-ipk: $(CACERTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cacerts-clean:
	rm -f $(CACERTS_BUILD_DIR)/.built
	-$(MAKE) -C $(CACERTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cacerts-dirclean:
	rm -rf $(BUILD_DIR)/$(CACERTS_DIR) $(CACERTS_BUILD_DIR) $(CACERTS_IPK_DIR) $(CACERTS_IPK)
#
#
# Some sanity check for the package.
#
cacerts-check: $(CACERTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
