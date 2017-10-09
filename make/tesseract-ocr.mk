###########################################################
#
# tesseract-ocr
#
###########################################################
#
# TESSERACT-OCR_VERSION, TESSERACT-OCR_SITE and TESSERACT-OCR_SOURCE define
# the upstream location of the source code for the package.
# TESSERACT-OCR_DIR is the directory which is created when the source
# archive is unpacked.
# TESSERACT-OCR_UNZIP is the command used to unzip the source.
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
TESSERACT-OCR_SITE=http://tesseract-ocr.googlecode.com/files
TESSERACT-OCR_VERSION=2.03
TESSERACT-OCR_SOURCE=tesseract-$(TESSERACT-OCR_VERSION).tar.gz
TESSERACT-OCR_DIR=tesseract-$(TESSERACT-OCR_VERSION)
TESSERACT-OCR_UNZIP=zcat
TESSERACT-OCR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TESSERACT-OCR_DESCRIPTION=An OCR Engine
TESSERACT-OCR_SECTION=utils
TESSERACT-OCR_PRIORITY=optional
TESSERACT-OCR_DEPENDS=libstdc++, libjpeg, libpng, libtiff, zlib
TESSERACT-OCR_SUGGESTS=
TESSERACT-OCR_CONFLICTS=

#
# TESSERACT-OCR_IPK_VERSION should be incremented when the ipk changes.
#
TESSERACT-OCR_IPK_VERSION=5

#
# TESSERACT-OCR_CONFFILES should be a list of user-editable files
#TESSERACT-OCR_CONFFILES=$(TARGET_PREFIX)/etc/tesseract-ocr.conf $(TARGET_PREFIX)/etc/init.d/SXXtesseract-ocr

#
# TESSERACT-OCR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TESSERACT-OCR_PATCHES=$(TESSERACT-OCR_SOURCE_DIR)/includes.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TESSERACT-OCR_CPPFLAGS=
ifdef NO_BUILTIN_MATH
TESSERACT-OCR_CPPFLAGS += -fno-builtin-ceil -fno-builtin-sin -fno-builtin-cos -fno-builtin-log
endif
TESSERACT-OCR_LDFLAGS=

TESSERACT-OCR_LANGS_200=eng fra ita deu nld spa
TESSERACT-OCR_LANGS_201=deu-f por vie
TESSERACT-OCR_LANGS=$(TESSERACT-OCR_LANGS_200) $(TESSERACT-OCR_LANGS_201)

#
# TESSERACT-OCR_BUILD_DIR is the directory in which the build is done.
# TESSERACT-OCR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TESSERACT-OCR_IPK_DIR is the directory in which the ipk is built.
# TESSERACT-OCR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TESSERACT-OCR_BUILD_DIR=$(BUILD_DIR)/tesseract-ocr
TESSERACT-OCR_SOURCE_DIR=$(SOURCE_DIR)/tesseract-ocr
TESSERACT-OCR_IPK_DIR=$(BUILD_DIR)/tesseract-ocr-$(TESSERACT-OCR_VERSION)-ipk
TESSERACT-OCR_IPK=$(BUILD_DIR)/tesseract-ocr_$(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)_$(TARGET_ARCH).ipk
TESSERACT-OCR-DEV_IPK_DIR=$(BUILD_DIR)/tesseract-ocr-dev-$(TESSERACT-OCR_VERSION)-ipk
TESSERACT-OCR-DEV_IPK=$(BUILD_DIR)/tesseract-ocr-dev_$(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)_$(TARGET_ARCH).ipk

TESSERACT-OCR-LANG_IPKS=$(foreach lang,$(TESSERACT-OCR_LANGS),\
$(BUILD_DIR)/tesseract-ocr-lang-$(lang)_$(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)_$(TARGET_ARCH).ipk)

TESSERACT-OCR-LANG_TARBALLS=\
$(foreach lang,$(TESSERACT-OCR_LANGS_200),$(DL_DIR)/tesseract-2.00.$(lang).tar.gz) \
$(foreach lang,$(TESSERACT-OCR_LANGS_201),$(DL_DIR)/tesseract-2.01.$(lang).tar.gz) \


.PHONY: tesseract-ocr-source tesseract-ocr-unpack tesseract-ocr tesseract-ocr-stage tesseract-ocr-ipk tesseract-ocr-clean tesseract-ocr-dirclean tesseract-ocr-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TESSERACT-OCR_SOURCE):
	$(WGET) -P $(@D) $(TESSERACT-OCR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/tesseract-2.00.%.tar.gz $(DL_DIR)/tesseract-2.01.%.tar.gz:
	$(WGET) -P $(@D) $(TESSERACT-OCR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tesseract-ocr-source: $(DL_DIR)/$(TESSERACT-OCR_SOURCE) $(TESSERACT-OCR_PATCHES)

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
$(TESSERACT-OCR_BUILD_DIR)/.configured: $(DL_DIR)/$(TESSERACT-OCR_SOURCE) $(TESSERACT-OCR_PATCHES) make/tesseract-ocr.mk
	$(MAKE) libstdc++-stage libjpeg-stage libpng-stage libtiff-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TESSERACT-OCR_DIR) $(@D)
	$(TESSERACT-OCR_UNZIP) $(DL_DIR)/$(TESSERACT-OCR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TESSERACT-OCR_PATCHES)" ; \
		then cat $(TESSERACT-OCR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TESSERACT-OCR_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TESSERACT-OCR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TESSERACT-OCR_DIR) $(@D) ; \
	fi
	sed -i \
		-e 's|ld |$(TARGET_LD) |' \
		-e 's|ar |$(TARGET_AR) |' \
		$(@D)/ccmain/Makefile.in
	mv $(@D)/java/makefile $(@D)/java/makefile.bak
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TESSERACT-OCR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TESSERACT-OCR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

tesseract-ocr-unpack: $(TESSERACT-OCR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TESSERACT-OCR_BUILD_DIR)/.built: $(TESSERACT-OCR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tesseract-ocr: $(TESSERACT-OCR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TESSERACT-OCR_BUILD_DIR)/.staged: $(TESSERACT-OCR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tesseract-ocr-stage: $(TESSERACT-OCR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tesseract-ocr
#
$(TESSERACT-OCR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: tesseract-ocr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TESSERACT-OCR_PRIORITY)" >>$@
	@echo "Section: $(TESSERACT-OCR_SECTION)" >>$@
	@echo "Version: $(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TESSERACT-OCR_MAINTAINER)" >>$@
	@echo "Source: $(TESSERACT-OCR_SITE)/$(TESSERACT-OCR_SOURCE)" >>$@
	@echo "Description: $(TESSERACT-OCR_DESCRIPTION)" >>$@
	@echo "Depends: $(TESSERACT-OCR_DEPENDS)" >>$@
	@echo "Suggests: $(TESSERACT-OCR_SUGGESTS)" >>$@
	@echo "Conflicts: $(TESSERACT-OCR_CONFLICTS)" >>$@

$(TESSERACT-OCR-DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: tesseract-ocr-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TESSERACT-OCR_PRIORITY)" >>$@
	@echo "Section: $(TESSERACT-OCR_SECTION)" >>$@
	@echo "Version: $(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TESSERACT-OCR_MAINTAINER)" >>$@
	@echo "Source: $(TESSERACT-OCR_SITE)/$(TESSERACT-OCR_SOURCE)" >>$@
	@echo "Description: $(TESSERACT-OCR_DESCRIPTION), devel files" >>$@
	@echo "Depends: $(TESSERACT-OCR_DEPENDS)" >>$@
	@echo "Suggests: $(TESSERACT-OCR_SUGGESTS)" >>$@
	@echo "Conflicts: $(TESSERACT-OCR_CONFLICTS)" >>$@

$(TESSERACT-OCR_IPK_DIR)-langs/%/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: tesseract-ocr-lang-$*" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TESSERACT-OCR_PRIORITY)" >>$@
	@echo "Section: $(TESSERACT-OCR_SECTION)" >>$@
	@echo "Version: $(TESSERACT-OCR_VERSION)-$(TESSERACT-OCR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TESSERACT-OCR_MAINTAINER)" >>$@
	@echo "Source: $(TESSERACT-OCR_SITE)/$(TESSERACT-OCR_SOURCE)" >>$@
	@echo "Description: $(TESSERACT-OCR_DESCRIPTION), $* language files" >>$@
	@echo "Depends: tesseract-ocr" >>$@
	@echo "Suggests: $(TESSERACT-OCR_SUGGESTS)" >>$@
	@echo "Conflicts: $(TESSERACT-OCR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/etc/tesseract-ocr/...
# Documentation files should be installed in $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/doc/tesseract-ocr/...
# Daemon startup scripts should be installed in $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??tesseract-ocr
#
# You may need to patch your application to make it use these locations.
#
$(TESSERACT-OCR_IPK) $(TESSERACT-OCR-DEV_IPK): $(TESSERACT-OCR_BUILD_DIR)/.built
	rm -rf $(TESSERACT-OCR_IPK_DIR) $(BUILD_DIR)/tesseract-ocr*_$(TARGET_ARCH).ipk
	rm -rf $(TESSERACT-OCR-DEV_IPK_DIR) $(BUILD_DIR)/tesseract-ocr-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TESSERACT-OCR_BUILD_DIR) DESTDIR=$(TESSERACT-OCR_IPK_DIR) install
	$(STRIP_COMMAND) $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/bin/*
	rm -f $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/share/tessdata/???.*
	$(MAKE) $(TESSERACT-OCR_IPK_DIR)/CONTROL/control
	$(MAKE) $(TESSERACT-OCR-DEV_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(TESSERACT-OCR-DEV_IPK_DIR)$(TARGET_PREFIX)
	mv $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/include $(TESSERACT-OCR_IPK_DIR)$(TARGET_PREFIX)/lib $(TESSERACT-OCR-DEV_IPK_DIR)$(TARGET_PREFIX)/
#	echo $(TESSERACT-OCR_CONFFILES) | sed -e 's/ /\n/g' > $(TESSERACT-OCR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TESSERACT-OCR_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TESSERACT-OCR-DEV_IPK_DIR)

$(TESSERACT-OCR_BUILD_DIR)/.lang-ipks-done: $(TESSERACT-OCR-LANG_TARBALLS) $(TESSERACT-OCR_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(TESSERACT-OCR_IPK_DIR)-langs $(BUILD_DIR)/tesseract-ocr-lang-*_*_$(TARGET_ARCH).ipk
	$(MAKE) $(foreach l,$(TESSERACT-OCR_LANGS),$(TESSERACT-OCR_IPK_DIR)-langs/$(l)/CONTROL/control)
	for l in $(TESSERACT-OCR_LANGS_200); do \
		$(INSTALL) -d $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share; \
		tar -C $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share -xzvf $(DL_DIR)/tesseract-2.00.$$l.tar.gz; \
		chmod 644 $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share/tessdata/*; \
		cd $(BUILD_DIR); $(IPKG_BUILD) $(TESSERACT-OCR_IPK_DIR)-langs/$$l; \
	done
	for l in $(TESSERACT-OCR_LANGS_201); do \
		$(INSTALL) -d $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share; \
		tar -C $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share -xzvf $(DL_DIR)/tesseract-2.01.$$l.tar.gz; \
		chmod 644 $(TESSERACT-OCR_IPK_DIR)-langs/$$l$(TARGET_PREFIX)/share/tessdata/*; \
		cd $(BUILD_DIR); $(IPKG_BUILD) $(TESSERACT-OCR_IPK_DIR)-langs/$$l; \
	done
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
tesseract-ocr-ipk: $(TESSERACT-OCR_IPK) $(TESSERACT-OCR-DEV_IPK) $(TESSERACT-OCR_BUILD_DIR)/.lang-ipks-done


#
# This is called from the top level makefile to clean all of the built files.
#
tesseract-ocr-clean:
	rm -f $(TESSERACT-OCR_BUILD_DIR)/.built
	-$(MAKE) -C $(TESSERACT-OCR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tesseract-ocr-dirclean:
	rm -rf $(BUILD_DIR)/$(TESSERACT-OCR_DIR) $(TESSERACT-OCR_BUILD_DIR)
	rm -rf $(TESSERACT-OCR_IPK_DIR) $(TESSERACT-OCR_IPK) $(TESSERACT-OCR-DEV_IPK)
	rm -rf $(TESSERACT-OCR_IPK_DIR)-langs $(BUILD_DIR)/tesseract-ocr-lang-*_*_$(TARGET_ARCH).ipk
#
#
# Some sanity check for the package.
#
tesseract-ocr-check: $(TESSERACT-OCR_IPK) $(TESSERACT-OCR-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
