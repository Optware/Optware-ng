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
GOLANG_HG_REPO=https://go.googlecode.com/hg
GOLANG_HG_DATE=20100315
GOLANG_HG_REV=194d473264c1
GOLANG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/golang
GOLANG_VERSION=0.hg$(GOLANG_HG_DATE)
GOLANG_SOURCE=golang-$(GOLANG_VERSION).tar.gz
GOLANG_DIR=golang-$(GOLANG_VERSION)
GOLANG_UNZIP=zcat
GOLANG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GOLANG_DESCRIPTION=A systems programming language - expressive, concurrent, garbage-collected
GOLANG_SECTION=lang
GOLANG_PRIORITY=optional
GOLANG_DEPENDS=
GOLANG_SUGGESTS=
GOLANG_CONFLICTS=

GOLANG_IPK_VERSION=1

#GOLANG_CONFFILES=

#GOLANG_HOST_PATCHES=

GOLANG_ARCH=$(strip \
$(if $(filter arm armel, $(TARGET_ARCH)), arm, \
$(if $(filter i686 i386, $(TARGET_ARCH)), 386, \
$(TARGET_ARCH))))

GOLANG_BUILD_CMD=$(strip \
$(if $(filter arm, $(GOLANG_ARCH)), GOARCH=arm GOARM=5 ./make.bash, \
$(if $(filter 386, $(GOLANG_ARCH)), GOARCH=386 ./make.bash, \
echo $(GOLANG_ARCH) not supported)))

#GOLANG_PATCHES=$(GOLANG_SOURCE_DIR)/$(GOLANG_ARCH)-g.patch

#GOLANG_CPPFLAGS=

ifeq (uclibc, $(LIBC_STYLE))
GOLANG_LDFLAGS=-lm
endif

GOLANG_SOURCE_DIR=$(SOURCE_DIR)/golang

GOLANG_BUILD_DIR=$(BUILD_DIR)/golang
GOLANG_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/golang

GOLANG_IPK_DIR=$(BUILD_DIR)/golang-$(GOLANG_VERSION)-ipk
GOLANG_IPK=$(BUILD_DIR)/golang_$(GOLANG_VERSION)-$(GOLANG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: golang-source golang-unpack golang golang-stage golang-ipk golang-clean golang-dirclean golang-check

$(DL_DIR)/$(GOLANG_SOURCE):
ifdef GOLANG_HG_REV
	(cd $(BUILD_DIR); \
		rm -rf $(GOLANG_DIR) && \
		hg clone -r$(GOLANG_HG_REV) $(GOLANG_HG_REPO) $(GOLANG_DIR) && \
		tar -czf $@ \
			--exclude .hg \
			$(GOLANG_DIR) && \
		rm -rf $(GOLANG_DIR) \
	)
else
	$(WGET) -P $(@D) $(GOLANG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

golang-source: $(DL_DIR)/$(GOLANG_SOURCE) $(GOLANG_PATCHES)

$(GOLANG_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GOLANG_SOURCE) $(GOLANG_HOST_PATCHES) # make/golang.mk
	rm -rf $(HOST_BUILD_DIR)/golang
	$(GOLANG_UNZIP) $(DL_DIR)/$(GOLANG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xf -
	if test -n "$(GOLANG_HOST_PATCHES)" ; \
		then cat $(GOLANG_HOST_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(GOLANG_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(GOLANG_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(GOLANG_DIR) $(@D) ; \
	fi
	mkdir -p $(@D)/bin
	sed -i -e '/^for i in/s| pkg.*||' $(@D)/src/make*.bash
	(cd $(@D)/src; \
		GOROOT=$(@D) GOBIN=$(@D)/bin \
		PATH=$(@D)/bin:$$PATH \
		GOOS=linux GOARCH=arm GOARM=5 ./make.bash; \
	)
	(cd $(@D)/src; \
		GOROOT=$(@D) GOBIN=$(@D)/bin \
		PATH=$(@D)/bin:$$PATH \
		GOOS=linux GOARCH=386 ./make.bash; \
	)
	touch $@

golang-host: $(GOLANG_HOST_BUILD_DIR)/.built

$(GOLANG_BUILD_DIR)/.configured: $(GOLANG_HOST_BUILD_DIR)/.built $(GOLANG_PATCHES) make/golang.mk
	rm -rf $(BUILD_DIR)/$(GOLANG_DIR) $(@D)
	$(GOLANG_UNZIP) $(DL_DIR)/$(GOLANG_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(GOLANG_PATCHES)" ; \
		then cat $(GOLANG_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(GOLANG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GOLANG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GOLANG_DIR) $(@D) ; \
	fi
	sed -i -e 's|@CC@|$(TARGET_CC)|' $(@D)/src/quietgcc.bash
ifneq ($(GOLANG_ARCH), amd64)
	sed -i -e 's| -m64||' $(@D)/src/quietgcc.bash
endif
	sed -i -e '/^CC=/s|=.*quietgcc$$|=$(@D)/bin/quietgcc|' \
	       -e '/^LD=/s|=.*quietgcc$$|=$(@D)/bin/quietgcc $(STAGING_LDFLAGS) $(GOLANG_LDFLAGS)|' \
		$(@D)/src/Make.conf
	sed -i -e '/^QUOTED_GOBIN=/s|=.*|=$(GOLANG_HOST_BUILD_DIR)/bin|g' \
		$(@D)/src/Make.cmd $(@D)/src/Make.pkg
	rm -f $(@D)/pkg/~place-holder~
	touch $@

golang-unpack: $(GOLANG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GOLANG_BUILD_DIR)/.built: $(GOLANG_BUILD_DIR)/.configured
	rm -f $@
	mkdir -p $(@D)/bin
	(cd $(@D)/src; \
		CC=$(TARGET_CC) \
		PATH=$(GOLANG_HOST_BUILD_DIR)/bin:$$PATH \
		GOROOT=$(@D) GOBIN=$(@D)/bin GOOS=linux \
		$(GOLANG_BUILD_CMD); \
	)
	touch $@

#
# This is the build convenience target.
#
golang: $(GOLANG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(GOLANG_BUILD_DIR)/.staged: $(GOLANG_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#golang-stage: $(GOLANG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/golang
#
$(GOLANG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: golang" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GOLANG_PRIORITY)" >>$@
	@echo "Section: $(GOLANG_SECTION)" >>$@
	@echo "Version: $(GOLANG_VERSION)-$(GOLANG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GOLANG_MAINTAINER)" >>$@
	@echo "Source: $(GOLANG_SITE)/$(GOLANG_SOURCE)" >>$@
	@echo "Description: $(GOLANG_DESCRIPTION)" >>$@
	@echo "Depends: $(GOLANG_DEPENDS)" >>$@
	@echo "Suggests: $(GOLANG_SUGGESTS)" >>$@
	@echo "Conflicts: $(GOLANG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GOLANG_IPK_DIR)/opt/sbin or $(GOLANG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GOLANG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GOLANG_IPK_DIR)/opt/etc/golang/...
# Documentation files should be installed in $(GOLANG_IPK_DIR)/opt/doc/golang/...
# Daemon startup scripts should be installed in $(GOLANG_IPK_DIR)/opt/etc/init.d/S??golang
#
# You may need to patch your application to make it use these locations.
#
$(GOLANG_IPK): $(GOLANG_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/golang*_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/golang*-ipk
	# golang
	install -d $(GOLANG_IPK_DIR)/opt/share/go
	# $(STRIP_COMMAND) $(GOLANG_IPK_DIR)/opt/bin/*
	rsync -av $(<D)/bin $(<D)/pkg $(<D)/[ACLR]* $(GOLANG_IPK_DIR)/opt/share/go/
	$(MAKE) $(GOLANG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GOLANG_IPK_DIR)

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
