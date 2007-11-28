###########################################################
#
# cups-pdf
#
###########################################################
#
# CUPS-PDF_VERSION, CUPS-PDF_SITE and CUPS-PDF_SOURCE define
# the upstream location of the source code for the package.
# CUPS-PDF_DIR is the directory which is created when the source
# archive is unpacked.
# CUPS-PDF_UNZIP is the command used to unzip the source.
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
CUPS-PDF_SITE=http://www.cups-pdf.de/src
CUPS-PDF_VERSION=2.4.6
CUPS-PDF_SOURCE=cups-pdf_$(CUPS-PDF_VERSION).tar.gz
CUPS-PDF_DIR=cups-pdf-$(CUPS-PDF_VERSION)
CUPS-PDF_UNZIP=zcat
CUPS-PDF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CUPS-PDF_DESCRIPTION=CUPS-PDF provides a PDF Writer backend to CUPS. This can be used as a virtual printer in a paperless network.
CUPS-PDF_SECTION=util
CUPS-PDF_PRIORITY=optional
CUPS-PDF_DEPENDS=cups, ghostscript
CUPS-PDF_SUGGESTS=
CUPS-PDF_CONFLICTS=

#
# CUPS-PDF_IPK_VERSION should be incremented when the ipk changes.
#
CUPS-PDF_IPK_VERSION=2

#
# CUPS-PDF_CONFFILES should be a list of user-editable files
CUPS-PDF_CONFFILES=/opt/etc/cups-pdf.conf

#
# CUPS-PDF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CUPS-PDF_PATCHES=$(CUPS-PDF_SOURCE_DIR)/cups-pdf.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CUPS-PDF_CPPFLAGS=
CUPS-PDF_LDFLAGS=

#
# CUPS-PDF_BUILD_DIR is the directory in which the build is done.
# CUPS-PDF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CUPS-PDF_IPK_DIR is the directory in which the ipk is built.
# CUPS-PDF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CUPS-PDF_BUILD_DIR=$(BUILD_DIR)/cups-pdf
CUPS-PDF_SOURCE_DIR=$(SOURCE_DIR)/cups-pdf
CUPS-PDF_IPK_DIR=$(BUILD_DIR)/cups-pdf-$(CUPS-PDF_VERSION)-ipk
CUPS-PDF_IPK=$(BUILD_DIR)/cups-pdf_$(CUPS-PDF_VERSION)-$(CUPS-PDF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cups-pdf-source cups-pdf-unpack cups-pdf cups-pdf-stage cups-pdf-ipk cups-pdf-clean cups-pdf-dirclean cups-pdf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CUPS-PDF_SOURCE):
	$(WGET) -P $(DL_DIR) $(CUPS-PDF_SITE)/$(CUPS-PDF_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CUPS-PDF_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cups-pdf-source: $(DL_DIR)/$(CUPS-PDF_SOURCE) $(CUPS-PDF_PATCHES)

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
$(CUPS-PDF_BUILD_DIR)/.configured: $(DL_DIR)/$(CUPS-PDF_SOURCE) $(CUPS-PDF_PATCHES) make/cups-pdf.mk
	rm -rf $(BUILD_DIR)/$(CUPS-PDF_DIR) $(CUPS-PDF_BUILD_DIR)
	$(CUPS-PDF_UNZIP) $(DL_DIR)/$(CUPS-PDF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CUPS-PDF_PATCHES)" ; \
		then cat $(CUPS-PDF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CUPS-PDF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CUPS-PDF_DIR)" != "$(CUPS-PDF_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CUPS-PDF_DIR) $(CUPS-PDF_BUILD_DIR) ; \
	fi
	touch $@

cups-pdf-unpack: $(CUPS-PDF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CUPS-PDF_BUILD_DIR)/.built: $(CUPS-PDF_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/src; \
	$(TARGET_CC) \
		$(STAGING_CPPFLAGS) $(CUPS-PDF_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(CUPS-PDF_LDFLAGS) \
		-s -o cups-pdf cups-pdf.c
	touch $@

#
# This is the build convenience target.
#
cups-pdf: $(CUPS-PDF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CUPS-PDF_BUILD_DIR)/.staged: $(CUPS-PDF_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(CUPS-PDF_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

cups-pdf-stage: $(CUPS-PDF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cups-pdf
#
$(CUPS-PDF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cups-pdf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CUPS-PDF_PRIORITY)" >>$@
	@echo "Section: $(CUPS-PDF_SECTION)" >>$@
	@echo "Version: $(CUPS-PDF_VERSION)-$(CUPS-PDF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CUPS-PDF_MAINTAINER)" >>$@
	@echo "Source: $(CUPS-PDF_SITE)/$(CUPS-PDF_SOURCE)" >>$@
	@echo "Description: $(CUPS-PDF_DESCRIPTION)" >>$@
	@echo "Depends: $(CUPS-PDF_DEPENDS)" >>$@
	@echo "Suggests: $(CUPS-PDF_SUGGESTS)" >>$@
	@echo "Conflicts: $(CUPS-PDF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CUPS-PDF_IPK_DIR)/opt/sbin or $(CUPS-PDF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CUPS-PDF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CUPS-PDF_IPK_DIR)/opt/etc/cups-pdf/...
# Documentation files should be installed in $(CUPS-PDF_IPK_DIR)/opt/doc/cups-pdf/...
# Daemon startup scripts should be installed in $(CUPS-PDF_IPK_DIR)/opt/etc/init.d/S??cups-pdf
#
# You may need to patch your application to make it use these locations.
#
$(CUPS-PDF_IPK): $(CUPS-PDF_BUILD_DIR)/.built
	rm -rf $(CUPS-PDF_IPK_DIR) $(BUILD_DIR)/cups-pdf_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(CUPS-PDF_BUILD_DIR) DESTDIR=$(CUPS-PDF_IPK_DIR) install-strip
	install -d $(CUPS-PDF_IPK_DIR)/opt/lib/cups/backend
	$(STRIP_COMMAND) $(CUPS-PDF_BUILD_DIR)/src/cups-pdf \
		-o $(CUPS-PDF_IPK_DIR)/opt/lib/cups/backend/cups-pdf
	install -d $(CUPS-PDF_IPK_DIR)/opt/etc
	install -m 644 $(CUPS-PDF_BUILD_DIR)/extra/cups-pdf.conf $(CUPS-PDF_IPK_DIR)/opt/etc/
	sed -i -e 's| /var/| /opt/var/|g' $(CUPS-PDF_IPK_DIR)/opt/etc/cups-pdf.conf
	install -d $(CUPS-PDF_IPK_DIR)/opt/share/cups/model
	install -m 644 $(CUPS-PDF_BUILD_DIR)/extra/PostscriptColor.ppd \
		$(CUPS-PDF_IPK_DIR)/opt/share/cups/model/
	install -d $(CUPS-PDF_IPK_DIR)/opt/share/doc/cups-pdf/examples/
	install \
		$(CUPS-PDF_BUILD_DIR)/ChangeLog \
		$(CUPS-PDF_BUILD_DIR)/COPYING \
		$(CUPS-PDF_BUILD_DIR)/README \
		$(CUPS-PDF_IPK_DIR)/opt/share/doc/cups-pdf/
	cp -rp \
		$(CUPS-PDF_BUILD_DIR)/contrib/cups-pdf-dispatch* \
		$(CUPS-PDF_BUILD_DIR)/contrib/pstitleiconv* \
		$(CUPS-PDF_IPK_DIR)/opt/share/doc/cups-pdf/examples/
	$(MAKE) $(CUPS-PDF_IPK_DIR)/CONTROL/control
	echo $(CUPS-PDF_CONFFILES) | sed -e 's/ /\n/g' > $(CUPS-PDF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CUPS-PDF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cups-pdf-ipk: $(CUPS-PDF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cups-pdf-clean:
	rm -f $(CUPS-PDF_BUILD_DIR)/.built
	-$(MAKE) -C $(CUPS-PDF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cups-pdf-dirclean:
	rm -rf $(BUILD_DIR)/$(CUPS-PDF_DIR) $(CUPS-PDF_BUILD_DIR) $(CUPS-PDF_IPK_DIR) $(CUPS-PDF_IPK)
#
#
# Some sanity check for the package.
#
cups-pdf-check: $(CUPS-PDF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CUPS-PDF_IPK)
