###########################################################
#
# golang
#
###########################################################
#
# GOLANG_VERSION, GOLANG_SITE and GOLANG_SOURCE define
# the upstream location of the source code for the package.
# GOLANG_DIR is the directory which is created when the source
# archive is unpacked.
# GOLANG_UNZIP is the command used to unzip the source.
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

GOLANG_SITE=https://redirector.gvt1.com/edgedl/go
GOLANG_VERSION:=1.10
GOLANG_SOURCE=go$(GOLANG_VERSION).src.tar.gz
GOLANG_DIR=go

GOLANG_GIT=https://github.com/golang/go.git
#GOLANG_GIT_TAG=go1.10beta2
#GOLANG_GIT_DATE=20171207

ifdef GOLANG_GIT_TAG
  GOLANG_VERSION:=$(GOLANG_VERSION)+git-$(GOLANG_GIT_TAG)
  GOLANG_GIT_TREEISH=$(GOLANG_GIT_TAG)
else
  ifdef GOLANG_GIT_DATE
    GOLANG_VERSION:=$(GOLANG_VERSION)+git$(GOLANG_GIT_DATE)
    # This should be updated when GOLANG_GIT_DATE changes
    GOLANG_GIT_TREEISH=9ce6b5c2ed5d3d5251b9a6a0c548d5fb2c8567e8
  endif
endif

GOLANG_UNZIP=zcat
GOLANG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GOLANG_DESCRIPTION=A systems programming language - expressive, concurrent, garbage-collected
GOLANG_SECTION=lang
GOLANG_PRIORITY=optional
GOLANG_DEPENDS=
GOLANG_SUGGESTS=git, gcc, pkgconfig
GOLANG_CONFLICTS=

GOLANG_IPK_VERSION=1

GOLANG_CONFFILES=

GOLANG_ARCH=$(strip \
$(if $(filter buildroot-armeabi-ng buildroot-armeabihf buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)), arm, \
$(if $(filter buildroot-i686, $(OPTWARE_TARGET)), 386, \
$(if $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)), mipsle, \
$(if $(filter buildroot-x86_64, $(OPTWARE_TARGET)), amd64, \
$(error unsupported arch))))))

GOLANG_GOARM:=$(strip \
$(if $(filter buildroot-armeabi-ng buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)), 5, \
$(if $(filter buildroot-armeabihf, $(OPTWARE_TARGET)), 7, \
)))

GOLANG_GOMIPS:=$(strip \
$(if $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)), softfloat, \
))

GOLANG_PATCHES=\
$(GOLANG_SOURCE_DIR)/default-target-cc-cxx-pkgconfig.patch \
$(GOLANG_SOURCE_DIR)/fix-errno-sign-for-epollctl-on-mips-mips64-and-ppc64.patch \
$(GOLANG_SOURCE_DIR)/optware_crypto_x509_root.patch \

GOLANG_CPPFLAGS=

GOLANG_LDFLAGS=

GOLANG_SOURCE_DIR=$(SOURCE_DIR)/golang

GOLANG_BUILD_DIR=$(BUILD_DIR)/golang
GOLANG_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/golang
GOLANG_IPK_DIR=$(BUILD_DIR)/golang-$(GOLANG_VERSION)-ipk
GOLANG_IPK=$(BUILD_DIR)/golang_$(GOLANG_VERSION)-$(GOLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: golang-source golang-unpack golang golang-stage golang-ipk golang-clean golang-dirclean golang-check golang-host

ifdef GOLANG_GIT_TREEISH
$(DL_DIR)/$(GOLANG_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf golang && \
		git clone --bare $(GOLANG_GIT) golang && \
		(cd golang && \
		git archive --format=tar --prefix=$(GOLANG_DIR)/ $(GOLANG_GIT_TREEISH) | gzip > $@) && \
		rm -rf golang ; \
	)
else
$(DL_DIR)/$(GOLANG_SOURCE):
	$(WGET) -P $(@D) $(GOLANG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

golang-source: $(DL_DIR)/$(GOLANG_SOURCE) $(GOLANG_PATCHES)

$(GOLANG_HOST_BUILD_DIR)/.built: $(DL_DIR)/$(GOLANG_SOURCE)
	# build bootstrap gccgo-go:
	$(MAKE) gcc-host
	rm -rf $(HOST_BUILD_DIR)/$(GOLANG_DIR) $(@D)
	$(GOLANG_UNZIP) $(DL_DIR)/$(GOLANG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xf -
	if test "$(HOST_BUILD_DIR)/$(GOLANG_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(GOLANG_DIR) $(@D) ; \
	fi
	(cd $(@D)/src; \
		CGO_ENABLED=1 \
		GOROOT_BOOTSTRAP=$(GCC_HOST_BIN_DIR)/.. ./make.bash \
	)
	touch $@

golang-host: $(GOLANG_HOST_BUILD_DIR)/.built

$(GOLANG_BUILD_DIR)/.configured: $(DL_DIR)/$(GOLANG_SOURCE) $(GOLANG_PATCHES) make/golang.mk
	# build bootstrap gccgo-go:
	$(MAKE) gcc-host
	rm -rf $(BUILD_DIR)/$(GOLANG_DIR) $(@D)
	$(GOLANG_UNZIP) $(DL_DIR)/$(GOLANG_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(GOLANG_PATCHES)" ; \
		then cat $(GOLANG_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(GOLANG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GOLANG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GOLANG_DIR) $(@D) ; \
	fi
	touch $@

golang-unpack: $(GOLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GOLANG_BUILD_DIR)/.built: $(GOLANG_BUILD_DIR)/.configured
	rm -f $@
	@if [ "$(GOLANG_ARCH)" = amd64 ]; then \
	if [ ! -e $(TARGET_PREFIX)/lib64/ld-linux-x86-64.so.2 ]; then \
		echo "Warning: $(TARGET_PREFIX)/lib64/ld-linux-x86-64.so.2 does not exist" >&2; \
		echo ">>>>>>>> golang build will probably fail." >&2; \
		echo ">>>>>>>> You can try something like this (as root)" >&2; \
		echo ">>>>>>>> # mkdir -p $(TARGET_PREFIX)/lib64" >&2; \
		echo ">>>>>>>> # ln -s /lib64/ld-linux-x86-64.so.2 $(TARGET_PREFIX)/lib64/" >&2; \
	fi; \
	fi
	(cd $(@D)/src; \
		CC_FOR_TARGET=$(TARGET_CC) \
		CXX_FOR_TARGET=$(TARGET_CXX) \
		GOROOT_FINAL=$(TARGET_PREFIX)/lib/golang GOOS=linux GOARCH=$(GOLANG_ARCH) \
		GOARM=$(GOLANG_GOARM) GOMIPS=$(GOLANG_GOMIPS) CGO_ENABLED=1 \
		GOROOT_BOOTSTRAP=$(GCC_HOST_BIN_DIR)/.. ./make.bash \
	)
	@if [ "$(GOLANG_ARCH)" = amd64 ]; then \
	mkdir -p $(@D)/bin/linux_amd64 && \
	cp -af $(@D)/bin/{go,gofmt} $(@D)/bin/linux_amd64; \
	fi
	touch $@

#
# This is the build convenience target.
#
golang: $(GOLANG_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/golang
#
$(GOLANG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: golang" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GOLANG_PRIORITY)" >>$@
	@echo "Section: $(GOLANG_SECTION)" >>$@
	@echo "Version: $(GOLANG_VERSION)-$(GOLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GOLANG_MAINTAINER)" >>$@
ifdef GOLANG_GIT_TREEISH
	@echo "Source: $(GOLANG_GIT)" >>$@
else
	@echo "Source: $(GOLANG_SITE)/$(GOLANG_SOURCE)" >>$@
endif
	@echo "Description: $(GOLANG_DESCRIPTION)" >>$@
	@echo "Depends: $(GOLANG_DEPENDS)" >>$@
	@echo "Suggests: $(GOLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(GOLANG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/etc/golang/...
# Documentation files should be installed in $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/doc/golang/...
# Daemon startup scripts should be installed in $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??golang
#
# You may need to patch your application to make it use these locations.
#
$(GOLANG_IPK): $(GOLANG_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/golang*_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/golang*-ipk
	$(INSTALL) -d $(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang/pkg/tool \
		$(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang/bin
	cp -af $(GOLANG_BUILD_DIR)/bin/linux_$(GOLANG_ARCH)/* \
		$(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang/bin
	cp -af $(GOLANG_BUILD_DIR)/pkg/linux_$(GOLANG_ARCH) \
		$(GOLANG_BUILD_DIR)/pkg/include \
		$(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang/pkg
	cp -af $(GOLANG_BUILD_DIR)/pkg/tool/linux_$(GOLANG_ARCH) \
		$(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang/pkg/tool
	cp -af $(GOLANG_BUILD_DIR)/src \
		$(GOLANG_IPK_DIR)$(TARGET_PREFIX)/lib/golang
	$(MAKE) $(GOLANG_IPK_DIR)/CONTROL/control
	( \
		echo "update-alternatives --install $(TARGET_PREFIX)/bin/go go $(TARGET_PREFIX)/lib/golang/bin/go 90"; \
		echo "update-alternatives --install $(TARGET_PREFIX)/bin/gofmt gofmt $(TARGET_PREFIX)/lib/golang/bin/gofmt 90"; \
	) > $(GOLANG_IPK_DIR)/CONTROL/postinst
	( \
		echo "update-alternatives --remove go $(TARGET_PREFIX)/lib/golang/bin/go"; \
		echo "update-alternatives --remove gofmt $(TARGET_PREFIX)/lib/golang/bin/gofmt"; \
	) > $(GOLANG_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GOLANG_IPK_DIR)/CONTROL/postinst $(GOLANG_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GOLANG_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GOLANG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
golang-ipk: $(GOLANG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
golang-clean:
	rm -f $(GOLANG_BUILD_DIR)/.built
	-$(MAKE) -C $(GOLANG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
golang-dirclean:
	rm -rf $(BUILD_DIR)/$(GOLANG_DIR) $(GOLANG_BUILD_DIR)
	rm -rf $(GOLANG_IPK_DIR) $(GOLANG_IPK)
#
#
# Some sanity check for the package.
#
golang-check: $(GOLANG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
