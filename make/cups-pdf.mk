###########################################################
#
# cups-pdf
#
###########################################################
#
# CUPS_PDF_VERSION, CUPS_PDF_SITE and CUPS_PDF_SOURCE define
# the upstream location of the source code for the package.
# CUPS_PDF_DIR is the directory which is created when the source
# archive is unpacked.
# CUPS_PDF_UNZIP is the command used to unzip the source.
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
CUPS_PDF_SITE=http://www.cups-pdf.de/src
CUPS_PDF_VERSION=3.0.1
CUPS_PDF_SOURCE=cups-pdf_$(CUPS_PDF_VERSION).tar.gz
CUPS_PDF_DIR=cups-pdf-$(CUPS_PDF_VERSION)
CUPS_PDF_UNZIP=zcat
CUPS_PDF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CUPS_PDF_DESCRIPTION=CUPS-PDF provides a PDF Writer backend to CUPS. This can be used as a virtual printer in a paperless network.
CUPS_PDF_SECTION=util
CUPS_PDF_PRIORITY=optional
CUPS_PDF_DEPENDS=cups, ghostscript
CUPS_PDF_SUGGESTS=
CUPS_PDF_CONFLICTS=

#
# CUPS_PDF_IPK_VERSION should be incremented when the ipk changes.
#
CUPS_PDF_IPK_VERSION=1

#
# CUPS_PDF_CONFFILES should be a list of user-editable files
CUPS_PDF_CONFFILES=$(TARGET_PREFIX)/etc/cups/cups-pdf.conf

#
# CUPS_PDF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CUPS_PDF_PATCHES=\
$(CUPS_PDF_SOURCE_DIR)/cups-pdf.h.patch \
$(CUPS_PDF_SOURCE_DIR)/cups-pdf.conf.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUPS_PDF_CPPFLAGS=
CUPS_PDF_LDFLAGS=-lcups

#
# CUPS_PDF_BUILD_DIR is the directory in which the build is done.
# CUPS_PDF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS_PDF_IPK_DIR is the directory in which the ipk is built.
# CUPS_PDF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS_PDF_BUILD_DIR=$(BUILD_DIR)/cups-pdf
CUPS_PDF_SOURCE_DIR=$(SOURCE_DIR)/cups-pdf
CUPS_PDF_IPK_DIR=$(BUILD_DIR)/cups-pdf-$(CUPS_PDF_VERSION)-ipk
CUPS_PDF_IPK=$(BUILD_DIR)/cups-pdf_$(CUPS_PDF_VERSION)-$(CUPS_PDF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cups-pdf-source cups-pdf-unpack cups-pdf cups-pdf-stage cups-pdf-ipk cups-pdf-clean cups-pdf-dirclean cups-pdf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUPS_PDF_SOURCE):
	$(WGET) -P $(@D) $(CUPS_PDF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-pdf-source: $(DL_DIR)/$(CUPS_PDF_SOURCE) $(CUPS_PDF_PATCHES)

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
$(CUPS_PDF_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS_PDF_SOURCE) $(CUPS_PDF_PATCHES) make/cups-pdf.mk
	rm -rf $(BUILD_DIR)/$(CUPS_PDF_DIR) $(@D)
	$(CUPS_PDF_UNZIP) $(DL_DIR)/$(CUPS_PDF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUPS_PDF_PATCHES)" ; \
		then cat $(CUPS_PDF_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CUPS_PDF_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(CUPS_PDF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CUPS_PDF_DIR) $(@D) ; \
	fi
	touch $@

cups-pdf-unpack: $(CUPS_PDF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CUPS_PDF_BUILD_DIR)/.built: $(CUPS_PDF_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/src; \
	$(TARGET_CC) \
		$(STAGING_CPPFLAGS) $(CUPS_PDF_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(CUPS_PDF_LDFLAGS) -g -o cups-pdf cups-pdf.c
	touch $@

#
# This is the build convenience target.
#
cups-pdf: $(CUPS_PDF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(CUPS_PDF_BUILD_DIR)/.staged: $(CUPS_PDF_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#cups-pdf-stage: $(CUPS_PDF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups-pdf
#
$(CUPS_PDF_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: cups-pdf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS_PDF_PRIORITY)" >>$@
	@echo "Section: $(CUPS_PDF_SECTION)" >>$@
	@echo "Version: $(CUPS_PDF_VERSION)-$(CUPS_PDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS_PDF_MAINTAINER)" >>$@
	@echo "Source: $(CUPS_PDF_SITE)/$(CUPS_PDF_SOURCE)" >>$@
	@echo "Description: $(CUPS_PDF_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS_PDF_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS_PDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS_PDF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/etc/cups-pdf/...
# Documentation files should be installed in $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/doc/cups-pdf/...
# Daemon startup scripts should be installed in $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??cups-pdf
#
# You may need to patch your application to make it use these locations.
#
$(CUPS_PDF_IPK): $(CUPS_PDF_BUILD_DIR)/.built
	rm -rf $(CUPS_PDF_IPK_DIR) $(BUILD_DIR)/cups-pdf_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(CUPS_PDF_BUILD_DIR) DESTDIR=$(CUPS_PDF_IPK_DIR) install-strip
	$(INSTALL) -d -m 755 $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/lib/cups/backend
	$(INSTALL) -m 700 $(CUPS_PDF_BUILD_DIR)/src/cups-pdf $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/lib/cups/backend/cups-pdf
	$(STRIP_COMMAND) $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/lib/cups/backend/cups-pdf
	$(INSTALL) -d $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/etc/cups
	$(INSTALL) -m 644 $(CUPS_PDF_BUILD_DIR)/extra/cups-pdf.conf $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/etc/cups
	$(INSTALL) -d $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/var/tmp
	$(INSTALL) -d $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/cups/model
	$(INSTALL) -m 644 $(CUPS_PDF_BUILD_DIR)/extra/CUPS-PDF_opt.ppd \
		$(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/cups/model/CUPS-PDF.ppd
	$(INSTALL) -d $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/doc/cups-pdf/
#	$(INSTALL) -d $(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/doc/cups-pdf/examples/
	$(INSTALL) \
		$(CUPS_PDF_BUILD_DIR)/ChangeLog \
		$(CUPS_PDF_BUILD_DIR)/COPYING \
		$(CUPS_PDF_BUILD_DIR)/README \
		$(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/doc/cups-pdf/
#	cp -rp \
		$(CUPS_PDF_BUILD_DIR)/contrib/cups-pdf-dispatch* \
		$(CUPS_PDF_BUILD_DIR)/contrib/pstitleiconv* \
		$(CUPS_PDF_IPK_DIR)$(TARGET_PREFIX)/share/doc/cups-pdf/examples/
	$(MAKE) $(CUPS_PDF_IPK_DIR)/CONTROL/control
	echo $(CUPS_PDF_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS_PDF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS_PDF_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CUPS_PDF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cups-pdf-ipk: $(CUPS_PDF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cups-pdf-clean:
	rm -f $(CUPS_PDF_BUILD_DIR)/.built
	-$(MAKE) -C $(CUPS_PDF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cups-pdf-dirclean:
	rm -rf $(BUILD_DIR)/$(CUPS_PDF_DIR) $(CUPS_PDF_BUILD_DIR) $(CUPS_PDF_IPK_DIR) $(CUPS_PDF_IPK)
#
#
# Some sanity check for the package.
#
cups-pdf-check: $(CUPS_PDF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
