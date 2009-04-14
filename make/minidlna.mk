###########################################################
#
# minidlna
#
###########################################################

#
# MINIDLNA_REPOSITORY defines the upstream location of the source code
# for the package.  MINIDLNA_DIR is the directory which is created when
# this cvs module is checked out.
#

MINIDLNA_REPOSITORY=:pserver:anonymous@minidlna.cvs.sourceforge.net:/cvsroot/minidlna
MINIDLNA_DIR=minidlna
MINIDLNA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIDLNA_DESCRIPTION=The MiniDLNA daemon is an UPnP-A/V and DLNA service which serves multimedia content to compatible clients on the network.
MINIDLNA_SECTION=media
MINIDLNA_PRIORITY=optional
MINIDLNA_DEPENDS=libexif, libid3tag, libjpeg, libvorbis, e2fslibs, ffmpeg, flac, sqlite
ifneq (, $(filter libiconv, $(PACKAGES)))
MINIDLNA_DEPENDS +=, libiconv
endif
MINIDLNA_SUGGESTS=
MINIDLNA_CONFLICTS=

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#

#
# If you want to use a date, uncomment the variables below and modify
# MINIDLNA_CVS_DATE
#

MINIDLNA_CVS_DATE=20090413
MINIDLNA_VERSION=cvs$(MINIDLNA_CVS_DATE)
#MINIDLNA_CVS_OPTS=-D $(MINIDLNA_CVS_DATE)

#
# If you want to use a tag, uncomment the variables below and modify
# MINIDLNA_CVS_TAG and MINIDLNA_CVS_VERSION
#

#MINIDLNA_CVS_TAG=version_1_2_3
#MINIDLNA_VERSION=1.2.3
#MINIDLNA_CVS_OPTS=-r $(MINIDLNA_CVS_TAG)

#
# MINIDLNA_IPK_VERSION should be incremented when the ipk changes.
#
MINIDLNA_IPK_VERSION=1

#
# MINIDLNA_CONFFILES should be a list of user-editable files
#MINIDLNA_CONFFILES=/opt/etc/init.d/S98minidlna

#
# MINIDLNA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIDLNA_PATCHES=$(MINIDLNA_SOURCE_DIR)/inotify-syscalls-mips.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIDLNA_CPPFLAGS=
MINIDLNA_LDFLAGS=
ifneq (, $(filter libiconv, $(PACKAGES)))
MINIDLNA_LDFLAGS= -liconv
endif

#
# MINIDLNA_BUILD_DIR is the directory in which the build is done.
# MINIDLNA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIDLNA_IPK_DIR is the directory in which the ipk is built.
# MINIDLNA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIDLNA_BUILD_DIR=$(BUILD_DIR)/minidlna
MINIDLNA_SOURCE_DIR=$(SOURCE_DIR)/minidlna
MINIDLNA_IPK_DIR=$(BUILD_DIR)/minidlna-$(MINIDLNA_VERSION)-ipk
MINIDLNA_IPK=$(BUILD_DIR)/minidlna_$(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: minidlna-source minidlna-unpack minidlna minidlna-stage minidlna-ipk minidlna-clean minidlna-dirclean minidlna-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(MINIDLNA_DIR) && \
		cvs -d $(MINIDLNA_REPOSITORY) -z3 co $(MINIDLNA_CVS_OPTS) $(MINIDLNA_DIR) && \
		tar -czf $@ $(MINIDLNA_DIR) --exclude CVS && \
		rm -rf $(MINIDLNA_DIR) \
	)

minidlna-source: $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(MINIDLNA_BUILD_DIR)/.configured: $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz make/minidlna.mk
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) libexif-stage libid3tag-stage libjpeg-stage libvorbis-stage
	$(MAKE) e2fsprogs-stage ffmpeg-stage flac-stage sqlite-stage
	rm -rf $(BUILD_DIR)/$(MINIDLNA_DIR) $(MINIDLNA_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/minidlna-$(MINIDLNA_VERSION).tar.gz
	if test -n "$(MINIDLNA_PATCHES)" ; \
		then cat $(MINIDLNA_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(MINIDLNA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MINIDLNA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MINIDLNA_DIR) $(@D) ; \
	fi
	sed -i.orig \
		-e 's|-I/usr/include|-I$(STAGING_INCLUDE_DIR)|g' \
		-e '/$$(CFLAGS).*-c/s|$$(CFLAGS) |&$$(CPPFLAGS) |' \
		-e '/$$(CFLAGS).*$$(LIBS)/s|$$(CFLAGS) |$$(LDFLAGS) |' \
		-e '/^minidlna:/s| $$(LIBS)||' \
		$(@D)/Makefile
	if ! $(TARGET_CC) -E sources/common/test_sendfile.c >/dev/null 2>&1; then \
		sed -i -e 's/-D_FILE_OFFSET_BITS=64 //' $(@D)/Makefile; \
	fi
	sed -i.orig \
		-e 's|\[ *-f /usr/include/sys/inotify.h *\]|$(TARGET_CC) -E $(SOURCE_DIR)/common/have_inotify.c >/dev/null 2>\&1|' \
		-e 's|/usr/include/|$(STAGING_INCLUDE_DIR)/|g' \
		-e '/^echo.*#define/s|$$OS_NAME|Linux|' \
		-e '/^echo.*#define/s|$$OS_VERSION|Cross_compiled|' \
		-e '/^echo.*#define/s|$${OS_URL}|http://www.kernel.org/|' \
		$(@D)/genconfig.sh
	sed -i.orig \
		 -e 's|/etc/|/opt&|' \
		 -e 's|/usr/|/opt/|' \
		$(@D)/minidlna.c
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

minidlna-unpack: $(MINIDLNA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINIDLNA_BUILD_DIR)/.built: $(MINIDLNA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIDLNA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MINIDLNA_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
minidlna: $(MINIDLNA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIDLNA_BUILD_DIR)/.staged: $(MINIDLNA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

minidlna-stage: $(MINIDLNA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minidlna
#
$(MINIDLNA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: minidlna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIDLNA_PRIORITY)" >>$@
	@echo "Section: $(MINIDLNA_SECTION)" >>$@
	@echo "Version: $(MINIDLNA_VERSION)-$(MINIDLNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIDLNA_MAINTAINER)" >>$@
	@echo "Source: $(MINIDLNA_REPOSITORY)" >>$@
	@echo "Description: $(MINIDLNA_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIDLNA_DEPENDS)" >>$@
	@echo "Suggests: $(MINIDLNA_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIDLNA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIDLNA_IPK_DIR)/opt/sbin or $(MINIDLNA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIDLNA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MINIDLNA_IPK_DIR)/opt/etc/minidlna/...
# Documentation files should be installed in $(MINIDLNA_IPK_DIR)/opt/doc/minidlna/...
# Daemon startup scripts should be installed in $(MINIDLNA_IPK_DIR)/opt/etc/init.d/S??minidlna
#
# You may need to patch your application to make it use these locations.
#
$(MINIDLNA_IPK): $(MINIDLNA_BUILD_DIR)/.built
	rm -rf $(MINIDLNA_IPK_DIR) $(BUILD_DIR)/minidlna_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MINIDLNA_BUILD_DIR) install \
		DESTDIR=$(MINIDLNA_IPK_DIR) \
		PREFIX=$(MINIDLNA_IPK_DIR) \
		INSTALLPREFIX=$(MINIDLNA_IPK_DIR)/opt \
		ETCINSTALLDIR=$(MINIDLNA_IPK_DIR)/opt/etc \
		;
	$(STRIP_COMMAND) $(MINIDLNA_IPK_DIR)/opt/sbin/*
#	install -m 644 $(MINIDLNA_SOURCE_DIR)/minidlna.conf $(MINIDLNA_IPK_DIR)/opt/etc/minidlna.conf
#	install -d $(MINIDLNA_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MINIDLNA_BUILD_DIR)/linux/minidlna.init.d.script $(MINIDLNA_IPK_DIR)/opt/etc/init.d/S98minidlna
	$(MAKE) $(MINIDLNA_IPK_DIR)/CONTROL/control
#	install -m 755 $(MINIDLNA_SOURCE_DIR)/postinst $(MINIDLNA_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MINIDLNA_SOURCE_DIR)/prerm $(MINIDLNA_IPK_DIR)/CONTROL/prerm
	echo $(MINIDLNA_CONFFILES) | sed -e 's/ /\n/g' > $(MINIDLNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIDLNA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minidlna-ipk: $(MINIDLNA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minidlna-clean:
	rm -f $(MINIDLNA_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIDLNA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minidlna-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIDLNA_DIR) $(MINIDLNA_BUILD_DIR) $(MINIDLNA_IPK_DIR) $(MINIDLNA_IPK)

#
# Some sanity check for the package.
#
minidlna-check: $(MINIDLNA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
