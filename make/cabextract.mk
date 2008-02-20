###########################################################
#
# cabextract
#
###########################################################

CABEXTRACT_SITE=http://www.cabextract.org.uk
CABEXTRACT_VERSION=1.2
CABEXTRACT_SOURCE=cabextract-$(CABEXTRACT_VERSION).tar.gz
CABEXTRACT_DIR=cabextract-$(CABEXTRACT_VERSION)
CABEXTRACT_UNZIP=zcat
CABEXTRACT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CABEXTRACT_DESCRIPTION=cabextract - Program to extract Microsoft Cabinet files
CABEXTRACT_SECTION=apps
CABEXTRACT_PRIORITY=optional
CABEXTRACT_DEPENDS=
CABEXTRACT_SUGGESTS=
CABEXTRACT_CONFLICTS=

#
# CABEXTRACT_IPK_VERSION should be incremented when the ipk changes.
#
CABEXTRACT_IPK_VERSION=1

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CABEXTRACT_CPPFLAGS=
CABEXTRACT_LDFLAGS=

#
# CABEXTRACT_BUILD_DIR is the directory in which the build is done.
# CABEXTRACT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CABEXTRACT_IPK_DIR is the directory in which the ipk is built.
# CABEXTRACT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CABEXTRACT_BUILD_DIR=$(BUILD_DIR)/cabextract
CABEXTRACT_SOURCE_DIR=$(SOURCE_DIR)/cabextract
CABEXTRACT_IPK_DIR=$(BUILD_DIR)/cabextract-$(CABEXTRACT_VERSION)-ipk
CABEXTRACT_IPK=$(BUILD_DIR)/cabextract_$(CABEXTRACT_VERSION)-$(CABEXTRACT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cabextract-source cabextract-unpack cabextract cabextract-stage cabextract-ipk cabextract-clean cabextract-dirclean cabextract-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CABEXTRACT_SOURCE):
	$(WGET) -P $(DL_DIR) $(CABEXTRACT_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cabextract-source: $(DL_DIR)/$(CABEXTRACT_SOURCE) $(CABEXTRACT_PATCHES)

$(CABEXTRACT_BUILD_DIR)/.configured: $(DL_DIR)/$(CABEXTRACT_SOURCE) $(CABEXTRACT_PATCHES) make/cabextract.mk
	rm -rf $(BUILD_DIR)/$(CABEXTRACT_DIR) $(CABEXTRACT_BUILD_DIR)
	$(CABEXTRACT_UNZIP) $(DL_DIR)/$(CABEXTRACT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CABEXTRACT_PATCHES)" ; \
		then cat $(CABEXTRACT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CABEXTRACT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CABEXTRACT_DIR)" != "$(CABEXTRACT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CABEXTRACT_DIR) $(CABEXTRACT_BUILD_DIR) ; \
	fi
	(cd $(CABEXTRACT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CABEXTRACT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CABEXTRACT_LDFLAGS)" \
		ac_cv_func_fnmatch_works=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(CABEXTRACT_BUILD_DIR)/.configured

cabextract-unpack: $(CABEXTRACT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CABEXTRACT_BUILD_DIR)/.built: $(CABEXTRACT_BUILD_DIR)/.configured
	rm -f $(CABEXTRACT_BUILD_DIR)/.built
	$(MAKE) -C $(CABEXTRACT_BUILD_DIR) 
	touch $(CABEXTRACT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
cabextract: $(CABEXTRACT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cabextract
#
$(CABEXTRACT_IPK_DIR)/CONTROL/control:
	@install -d $(CABEXTRACT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cabextract" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CABEXTRACT_PRIORITY)" >>$@
	@echo "Section: $(CABEXTRACT_SECTION)" >>$@
	@echo "Version: $(CABEXTRACT_VERSION)-$(CABEXTRACT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CABEXTRACT_MAINTAINER)" >>$@
	@echo "Source: $(CABEXTRACT_SITE)/$(CABEXTRACT_SOURCE)" >>$@
	@echo "Description: $(CABEXTRACT_DESCRIPTION)" >>$@
	@echo "Depends: $(CABEXTRACT_DEPENDS)" >>$@
	@echo "Suggests: $(CABEXTRACT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CABEXTRACT_CONFLICTS)" >>$@

$(CABEXTRACT_IPK): $(CABEXTRACT_BUILD_DIR)/.built
	rm -rf $(CABEXTRACT_IPK_DIR) $(BUILD_DIR)/cabextract_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CABEXTRACT_BUILD_DIR) DESTDIR=$(CABEXTRACT_IPK_DIR) install-strip
	$(MAKE) $(CABEXTRACT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CABEXTRACT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cabextract-ipk: $(CABEXTRACT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cabextract-clean:
	rm -f $(CABEXTRACT_BUILD_DIR)/.built
	-$(MAKE) -C $(CABEXTRACT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cabextract-dirclean:
	rm -rf $(BUILD_DIR)/$(CABEXTRACT_DIR) $(CABEXTRACT_BUILD_DIR) $(CABEXTRACT_IPK_DIR) $(CABEXTRACT_IPK)

#
# Some sanity check for the package.
#
cabextract-check: $(CABEXTRACT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CABEXTRACT_IPK)
