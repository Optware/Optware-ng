###########################################################
#
# fcgi
#
###########################################################

FCGI_SITE=http://www.fastcgi.com/dist
FCGI_VERSION=2.4.0
FCGI_SOURCE=fcgi-$(FCGI_VERSION).tar.gz
FCGI_DIR=fcgi-$(FCGI_VERSION)
FCGI_UNZIP=zcat
FCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FCGI_DESCRIPTION=FastCGI is a language independent, scalable, open extension to CGI that provides high performance without the limitations of server specific APIs
FCGI_SECTION=net
FCGI_PRIORITY=optional
FCGI_DEPENDS=
FCGI_SUGGESTS=
FCGI_CONFLICTS=

#
# FCGI_IPK_VERSION should be incremented when the ipk changes.
#
FCGI_IPK_VERSION=3

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FCGI_CPPFLAGS=
FCGI_LDFLAGS=-lm

FCGI_BUILD_DIR=$(BUILD_DIR)/fcgi
FCGI_SOURCE_DIR=$(SOURCE_DIR)/fcgi
FCGI_IPK_DIR=$(BUILD_DIR)/fcgi-$(FCGI_VERSION)-ipk
FCGI_IPK=$(BUILD_DIR)/fcgi_$(FCGI_VERSION)-$(FCGI_IPK_VERSION)_$(TARGET_ARCH).ipk
FCGI_DEV_IPK_DIR=$(BUILD_DIR)/fcgi-dev-$(FCGI_VERSION)-ipk
FCGI_DEV_IPK=$(BUILD_DIR)/fcgi-dev_$(FCGI_VERSION)-$(FCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fcgi-source fcgi-unpack fcgi fcgi-stage fcgi-ipk fcgi-clean fcgi-dirclean fcgi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FCGI_SOURCE):
	$(WGET) -P $(DL_DIR) $(FCGI_SITE)/$(FCGI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fcgi-source: $(DL_DIR)/$(FCGI_SOURCE) $(FCGI_PATCHES)

$(FCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(FCGI_SOURCE) $(FCGI_PATCHES) make/fcgi.mk
	rm -rf $(BUILD_DIR)/$(FCGI_DIR) $(@D)
	$(FCGI_UNZIP) $(DL_DIR)/$(FCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FCGI_PATCHES)" ; \
		then cat $(FCGI_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FCGI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FCGI_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FCGI_DIR) $(@D) ; \
	fi
	sed -i -e '1 i #include <stdio.h>' $(@D)/libfcgi/fcgio.cpp
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(FCGI_CPPFLAGS)" \
		LDFLAGS="$(FCGI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(FCGI_BUILD_DIR)/libtool
	touch $@

fcgi-unpack: $(FCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FCGI_BUILD_DIR)/.built: $(FCGI_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/libfcgi libfcgi.la
	$(MAKE) -C $(@D)/libfcgi libfcgi++.la
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fcgi: $(FCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FCGI_BUILD_DIR)/.staged: $(FCGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

fcgi-stage: $(FCGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fcgi
#
$(FCGI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(FCGI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: fcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FCGI_PRIORITY)" >>$@
	@echo "Section: $(FCGI_SECTION)" >>$@
	@echo "Version: $(FCGI_VERSION)-$(FCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FCGI_MAINTAINER)" >>$@
	@echo "Source: $(FCGI_SITE)/$(FCGI_SOURCE)" >>$@
	@echo "Description: $(FCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(FCGI_DEPENDS)" >>$@
	@echo "Suggests: $(FCGI_SUGGESTS)" >>$@
	@echo "Conflicts: $(FCGI_CONFLICTS)" >>$@

$(FCGI_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(FCGI_DEV_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: fcgi-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FCGI_PRIORITY)" >>$@
	@echo "Section: $(FCGI_SECTION)" >>$@
	@echo "Version: $(FCGI_VERSION)-$(FCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FCGI_MAINTAINER)" >>$@
	@echo "Source: $(FCGI_SITE)/$(FCGI_SOURCE)" >>$@
	@echo "Description: Development stuff for native compiling FCGI apps." >>$@
	@echo "Depends: fcgi" >>$@

#
# This builds the IPK file.
#
$(FCGI_IPK) $(FCGI_DEV_IPK): $(FCGI_BUILD_DIR)/.built
	rm -rf $(FCGI_IPK_DIR) $(BUILD_DIR)/fcgi_*_$(TARGET_ARCH).ipk
	rm -rf $(FCGI_DEV_IPK_DIR) $(BUILD_DIR)/fcgi-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FCGI_BUILD_DIR) DESTDIR=$(FCGI_DEV_IPK_DIR) install
	rm -rf $(FCGI_DEV_IPK_DIR)/{opt/bin,opt/lib/*.so.*} 
	$(MAKE) -C $(FCGI_BUILD_DIR) DESTDIR=$(FCGI_IPK_DIR) install
	rm -rf $(FCGI_IPK_DIR)/{opt/include,opt/lib/{*.a,*la,*.so}} 
	$(MAKE) $(FCGI_DEV_IPK_DIR)/CONTROL/control
	$(MAKE) $(FCGI_IPK_DIR)/CONTROL/control
	-$(STRIP_COMMAND) $(FCGI_IPK_DIR)$(TARGET_PREFIX)/bin/*
	-$(STRIP_COMMAND) $(FCGI_IPK_DIR)$(TARGET_PREFIX)/lib/*.so.*
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FCGI_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fcgi-ipk: $(FCGI_IPK) $(FCGI_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fcgi-clean:
	rm -f $(FCGI_BUILD_DIR)/.built
	-$(MAKE) -C $(FCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fcgi-dirclean:
	rm -rf $(BUILD_DIR)/$(FCGI_DIR) $(FCGI_BUILD_DIR) $(FCGI_IPK_DIR) $(FCGI_IPK) $(FCGI_DEV_IPK_DIR) $(FCGI_DEV_IPK)

#
# Some sanity check for the package.
#
fcgi-check: $(FCGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FCGI_IPK) $^
