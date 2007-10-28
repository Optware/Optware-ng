###########################################################
#
# e2fsprogs
#
###########################################################

# You must replace "e2fsprogs" and "E2FSPROGS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# E2FSPROGS_VERSION, E2FSPROGS_SITE and E2FSPROGS_SOURCE define
# the upstream location of the source code for the package.
# E2FSPROGS_DIR is the directory which is created when the source
# archive is unpacked.
# E2FSPROGS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
E2FSPROGS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/e2fsprogs
E2FSPROGS_VERSION=1.40.2
E2FSPROGS_SOURCE=e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_DIR=e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_UNZIP=zcat
E2FSPROGS_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
E2FSPROGS_DESCRIPTION=Ext2 Filesystem Utilities
E2FSPROGS_SECTION=lib
E2FSPROGS_PRIORITY=optional
E2FSPROGS_DEPENDS=
E2FSPROGS_CONFLICTS=

#
# E2FSPROGS_IPK_VERSION should be incremented when the ipk changes.
#
E2FSPROGS_IPK_VERSION=4

#
# E2FSPROGS_CONFFILES should be a list of user-editable files
E2FSPROGS_CONFFILES=/opt/etc/mke2fs.conf

#
# E2FSPROGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
E2FSPROGS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
E2FSPROGS_CPPFLAGS=
E2FSPROGS_LDFLAGS=

#
# E2FSPROGS_BUILD_DIR is the directory in which the build is done.
# E2FSPROGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# E2FSPROGS_IPK_DIR is the directory in which the ipk is built.
# E2FSPROGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
E2FSPROGS_BUILD_DIR=$(BUILD_DIR)/e2fsprogs
E2FSPROGS_SOURCE_DIR=$(SOURCE_DIR)/e2fsprogs
E2FSPROGS_IPK_DIR=$(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION)-ipk
E2FSPROGS_IPK=$(BUILD_DIR)/e2fsprogs_$(E2FSPROGS_VERSION)-$(E2FSPROGS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: e2fsprogs-source e2fsprogs-unpack e2fsprogs e2fsprogs-stage e2fsprogs-ipk e2fsprogs-clean e2fsprogs-dirclean e2fsprogs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
e2fsprogs-source: $(DL_DIR)/$(E2FSPROGS_SOURCE) $(E2FSPROGS_PATCHES)

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
$(E2FSPROGS_BUILD_DIR)/.configured: $(DL_DIR)/$(E2FSPROGS_SOURCE) $(E2FSPROGS_PATCHES)
	rm -rf $(BUILD_DIR)/$(E2FSPROGS_DIR) $(E2FSPROGS_BUILD_DIR)
	$(E2FSPROGS_UNZIP) $(DL_DIR)/$(E2FSPROGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(E2FSPROGS_PATCHES) | patch -d $(BUILD_DIR)/$(E2FSPROGS_DIR) -p1
	mv $(BUILD_DIR)/$(E2FSPROGS_DIR) $(E2FSPROGS_BUILD_DIR)
	(cd $(E2FSPROGS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(E2FSPROGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(E2FSPROGS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-ldopts="$(STAGING_LDFLAGS) $(E2FSPROGS_LDFLAGS)" \
		--enable-elf-shlibs \
		--enable-rpath \
	)
	sed -i -e '/LN_S/s|-f $$(ELF_INSTALL_DIR)/$$(ELF_SONAME)|-f $$(ELF_SONAME)|' \
		$(E2FSPROGS_BUILD_DIR)/lib/Makefile* \
		$(E2FSPROGS_BUILD_DIR)/lib/*/Makefile
	touch $@

e2fsprogs-unpack: $(E2FSPROGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(E2FSPROGS_BUILD_DIR)/.built: $(E2FSPROGS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
e2fsprogs: $(E2FSPROGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(E2FSPROGS_BUILD_DIR)/.staged: $(E2FSPROGS_BUILD_DIR)/.built
	rm -f $(E2FSPROGS_BUILD_DIR)/.staged
	LDCONFIG=true DESTDIR=$(STAGING_DIR) \
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR)  install
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/ext2fs DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/et DESTDIR=$(STAGING_DIR) install
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR)/lib/blkid DESTDIR=$(STAGING_DIR) install
	touch $@

e2fsprogs-stage: $(E2FSPROGS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/e2fsprogs
#
$(E2FSPROGS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: e2fsprogs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(E2FSPROGS_PRIORITY)" >>$@
	@echo "Section: $(E2FSPROGS_SECTION)" >>$@
	@echo "Version: $(E2FSPROGS_VERSION)-$(E2FSPROGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(E2FSPROGS_MAINTAINER)" >>$@
	@echo "Source: $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)" >>$@
	@echo "Description: $(E2FSPROGS_DESCRIPTION)" >>$@
	@echo "Depends: $(E2FSPROGS_DEPENDS)" >>$@
	@echo "Conflicts: $(E2FSPROGS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(E2FSPROGS_IPK_DIR)/opt/sbin or $(E2FSPROGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(E2FSPROGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(E2FSPROGS_IPK_DIR)/opt/etc/e2fsprogs/...
# Documentation files should be installed in $(E2FSPROGS_IPK_DIR)/opt/doc/e2fsprogs/...
# Daemon startup scripts should be installed in $(E2FSPROGS_IPK_DIR)/opt/etc/init.d/S??e2fsprogs
#
# You may need to patch your application to make it use these locations.
#
$(E2FSPROGS_IPK): $(E2FSPROGS_BUILD_DIR)/.built
	rm -rf $(E2FSPROGS_IPK_DIR) $(BUILD_DIR)/e2fsprogs_*_$(TARGET_ARCH).ipk
	# We place files in /opt/lib and /opt/sbin only
	install -d $(E2FSPROGS_IPK_DIR)/opt/etc
	install -d $(E2FSPROGS_IPK_DIR)/opt/lib
	install -d $(E2FSPROGS_IPK_DIR)/opt/sbin
	install -d $(E2FSPROGS_IPK_DIR)/opt/bin
	install -d $(E2FSPROGS_IPK_DIR)/opt/man/man8
	install -d $(E2FSPROGS_IPK_DIR)/opt/man/man1
	DESTDIR=$(E2FSPROGS_IPK_DIR) LDCONFIG=true \
	$(MAKE) -C $(E2FSPROGS_BUILD_DIR) install-strip
	rmdir $(E2FSPROGS_IPK_DIR)/etc
	# Strip in the 3 executables - take both e2fsck versions for now
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/debugfs/debugfs -o $(E2FSPROGS_IPK_DIR)/opt/sbin/debugfs
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/e2fsck/e2fsck.shared -o $(E2FSPROGS_IPK_DIR)/opt/sbin/e2fsck
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/resize/resize2fs -o $(E2FSPROGS_IPK_DIR)/opt/sbin/resize2fs
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/misc/tune2fs -o $(E2FSPROGS_IPK_DIR)/opt/sbin/tune2fs
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/misc/dumpe2fs -o $(E2FSPROGS_IPK_DIR)/opt/sbin/dumpe2fs
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/misc/chattr -o $(E2FSPROGS_IPK_DIR)/opt/bin/chattr
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/misc/lsattr -o $(E2FSPROGS_IPK_DIR)/opt/bin/lsattr
	$(STRIP_COMMAND) $(E2FSPROGS_IPK_DIR)/opt/bin/uuidgen $(E2FSPROGS_IPK_DIR)/opt/lib/e2initrd_helper
ifeq ($(OPTWARE_TARGET),ts72xx)
	$(STRIP_COMMAND) $(E2FSPROGS_BUILD_DIR)/misc/mke2fs -o $(E2FSPROGS_IPK_DIR)/opt/sbin/mke2fs
else
	rm -f $(E2FSPROGS_IPK_DIR)/opt/sbin/mke2fs
endif
	install -m 644  $(E2FSPROGS_BUILD_DIR)/resize/resize2fs.8 $(E2FSPROGS_IPK_DIR)/opt/man/man8/resize2fs.8
	install -m 644  $(E2FSPROGS_BUILD_DIR)/e2fsck/e2fsck.8 $(E2FSPROGS_IPK_DIR)/opt/man/man8/e2fsck.8
	install -m 644  $(E2FSPROGS_BUILD_DIR)/debugfs/debugfs.8 $(E2FSPROGS_IPK_DIR)/opt/man/man8/debugfs.8
	install -m 644  $(E2FSPROGS_BUILD_DIR)/misc/tune2fs.8 $(E2FSPROGS_IPK_DIR)/opt/man/man8/tune2fs.8
	install -m 644  $(E2FSPROGS_BUILD_DIR)/misc/dumpe2fs.8 $(E2FSPROGS_IPK_DIR)/opt/man/man8/dumpe2fs.8
	install -m 644  $(E2FSPROGS_BUILD_DIR)/misc/lsattr.1 $(E2FSPROGS_IPK_DIR)/opt/man/man1/lsattr.1
	install -m 644  $(E2FSPROGS_BUILD_DIR)/misc/chattr.1 $(E2FSPROGS_IPK_DIR)/opt/man/man1/chattr.1
	# Package files
	$(MAKE) $(E2FSPROGS_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(E2FSPROGS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(E2FSPROGS_IPK_DIR)/CONTROL/prerm
	for f in chattr lsattr; do \
	    mv $(E2FSPROGS_IPK_DIR)/opt/bin/$$f $(E2FSPROGS_IPK_DIR)/opt/bin/e2fsprogs-$$f; \
	    echo "update-alternatives --install /opt/bin/$$f $$f /opt/bin/e2fsprogs-$$f 80" \
		>> $(E2FSPROGS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/bin/e2fsprogs-$$f" \
		>> $(E2FSPROGS_IPK_DIR)/CONTROL/prerm; \
	done
	for f in fsck; do \
	    mv $(E2FSPROGS_IPK_DIR)/opt/sbin/$$f $(E2FSPROGS_IPK_DIR)/opt/sbin/e2fsprogs-$$f; \
	    echo "update-alternatives --install /opt/sbin/$$f $$f /opt/sbin/e2fsprogs-$$f 80" \
		>> $(E2FSPROGS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/sbin/e2fsprogs-$$f" \
		>> $(E2FSPROGS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(E2FSPROGS_IPK_DIR)/CONTROL/postinst $(E2FSPROGS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(E2FSPROGS_CONFFILES) | sed -e 's/ /\n/g' > $(E2FSPROGS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(E2FSPROGS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
e2fsprogs-ipk: $(E2FSPROGS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
e2fsprogs-clean:
	-$(MAKE) -C $(E2FSPROGS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
e2fsprogs-dirclean:
	rm -rf $(BUILD_DIR)/$(E2FSPROGS_DIR) $(E2FSPROGS_BUILD_DIR) $(E2FSPROGS_IPK_DIR) $(E2FSPROGS_IPK)

#
# Some sanity check for the package.
#
e2fsprogs-check: $(E2FSPROGS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(E2FSPROGS_IPK)
