###########################################################
#
# bsdmainutils
#
###########################################################
#
# BSDMAINUTILS_VERSION, BSDMAINUTILS_SITE and BSDMAINUTILS_SOURCE define
# the upstream location of the source code for the package.
# BSDMAINUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BSDMAINUTILS_UNZIP is the command used to unzip the source.
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
BSDMAINUTILS_SITE=http://ftp.debian.org/debian/pool/main/b/bsdmainutils
BSDMAINUTILS_VERSION=6.1.6
BSDMAINUTILS_SOURCE=bsdmainutils_$(BSDMAINUTILS_VERSION).tar.gz
BSDMAINUTILS_DIR=bsdmainutils-$(BSDMAINUTILS_VERSION)
BSDMAINUTILS_UNZIP=zcat
BSDMAINUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BSDMAINUTILS_DESCRIPTION=Small programs many people expect to find when they use a BSD-style Unix system.
BSDMAINUTILS_SECTION=misc
BSDMAINUTILS_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BSDMAINUTILS_DEPENDS=libiconv
else
BSDMAINUTILS_DEPENDS=
endif
BSDMAINUTILS_SUGGESTS=
BSDMAINUTILS_CONFLICTS=

#
# BSDMAINUTILS_IPK_VERSION should be incremented when the ipk changes.
#
BSDMAINUTILS_IPK_VERSION=5

#
# BSDMAINUTILS_CONFFILES should be a list of user-editable files
#BSDMAINUTILS_CONFFILES=/opt/etc/bsdmainutils.conf /opt/etc/init.d/SXXbsdmainutils

#
# BSDMAINUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BSDMAINUTILS_PATCHES=$(BSDMAINUTILS_SOURCE_DIR)/cal-weekstart-on-sunday.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BSDMAINUTILS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
BSDMAINUTILS_LDFLAGS=-lncurses
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BSDMAINUTILS_LDFLAGS+=-liconv
endif

#
# BSDMAINUTILS_BUILD_DIR is the directory in which the build is done.
# BSDMAINUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BSDMAINUTILS_IPK_DIR is the directory in which the ipk is built.
# BSDMAINUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BSDMAINUTILS_BUILD_DIR=$(BUILD_DIR)/bsdmainutils
BSDMAINUTILS_SOURCE_DIR=$(SOURCE_DIR)/bsdmainutils
BSDMAINUTILS_IPK_DIR=$(BUILD_DIR)/bsdmainutils-$(BSDMAINUTILS_VERSION)-ipk
BSDMAINUTILS_IPK=$(BUILD_DIR)/bsdmainutils_$(BSDMAINUTILS_VERSION)-$(BSDMAINUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bsdmainutils-source bsdmainutils-unpack bsdmainutils bsdmainutils-stage bsdmainutils-ipk bsdmainutils-clean bsdmainutils-dirclean bsdmainutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BSDMAINUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(BSDMAINUTILS_SITE)/$(BSDMAINUTILS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(BSDMAINUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bsdmainutils-source: $(DL_DIR)/$(BSDMAINUTILS_SOURCE) $(BSDMAINUTILS_PATCHES)

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
$(BSDMAINUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BSDMAINUTILS_SOURCE) $(BSDMAINUTILS_PATCHES) make/bsdmainutils.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(BSDMAINUTILS_DIR) $(BSDMAINUTILS_BUILD_DIR)
	$(BSDMAINUTILS_UNZIP) $(DL_DIR)/$(BSDMAINUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BSDMAINUTILS_PATCHES)" ; \
		then cat $(BSDMAINUTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BSDMAINUTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BSDMAINUTILS_DIR)" != "$(BSDMAINUTILS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BSDMAINUTILS_DIR) $(BSDMAINUTILS_BUILD_DIR) ; \
	fi
	sed -i \
	    -e 's/install -o root -g root/install /' \
	    -e '/root:tty/s/^/#/' \
	    -e 's|/usr/|/opt/|g' \
		$(BSDMAINUTILS_BUILD_DIR)/{Makefile,*.mk} \
		$(BSDMAINUTILS_BUILD_DIR)/*/*/Makefile \
		$(BSDMAINUTILS_BUILD_DIR)/usr.bin/*/pathnames.h
#	(cd $(BSDMAINUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BSDMAINUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BSDMAINUTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(BSDMAINUTILS_BUILD_DIR)/libtool
	touch $(BSDMAINUTILS_BUILD_DIR)/.configured

bsdmainutils-unpack: $(BSDMAINUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BSDMAINUTILS_BUILD_DIR)/.built: $(BSDMAINUTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(BSDMAINUTILS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		FLAGS="$(STAGING_CPPFLAGS) $(BSDMAINUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BSDMAINUTILS_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
bsdmainutils: $(BSDMAINUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BSDMAINUTILS_BUILD_DIR)/.staged: $(BSDMAINUTILS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(BSDMAINUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

bsdmainutils-stage: $(BSDMAINUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bsdmainutils
#
$(BSDMAINUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bsdmainutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BSDMAINUTILS_PRIORITY)" >>$@
	@echo "Section: $(BSDMAINUTILS_SECTION)" >>$@
	@echo "Version: $(BSDMAINUTILS_VERSION)-$(BSDMAINUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BSDMAINUTILS_MAINTAINER)" >>$@
	@echo "Source: $(BSDMAINUTILS_SITE)/$(BSDMAINUTILS_SOURCE)" >>$@
	@echo "Description: $(BSDMAINUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BSDMAINUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BSDMAINUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BSDMAINUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BSDMAINUTILS_IPK_DIR)/opt/sbin or $(BSDMAINUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BSDMAINUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BSDMAINUTILS_IPK_DIR)/opt/etc/bsdmainutils/...
# Documentation files should be installed in $(BSDMAINUTILS_IPK_DIR)/opt/doc/bsdmainutils/...
# Daemon startup scripts should be installed in $(BSDMAINUTILS_IPK_DIR)/opt/etc/init.d/S??bsdmainutils
#
# You may need to patch your application to make it use these locations.
#
$(BSDMAINUTILS_IPK): $(BSDMAINUTILS_BUILD_DIR)/.built
	rm -rf $(BSDMAINUTILS_IPK_DIR) $(BUILD_DIR)/bsdmainutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BSDMAINUTILS_BUILD_DIR) install \
		DESTDIR=$(BSDMAINUTILS_IPK_DIR) \
		sysconfdir=$(BSDMAINUTILS_IPK_DIR)/opt/etc
	rm -rf $(BSDMAINUTILS_IPK_DIR)/opt/games $(BSDMAINUTILS_IPK_DIR)/opt/share/man/man6
	$(STRIP_COMMAND) `ls $(BSDMAINUTILS_IPK_DIR)/opt/bin/* | egrep -v bin/lorder`
	rm -f $(BSDMAINUTILS_IPK_DIR)/opt/bin/cal
	$(MAKE) $(BSDMAINUTILS_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(BSDMAINUTILS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(BSDMAINUTILS_IPK_DIR)/CONTROL/prerm
	cd $(BSDMAINUTILS_IPK_DIR)/opt/bin; \
	for f in *; do \
	    mv $$f bsdmainutils-$$f; \
	    echo "update-alternatives --install /opt/bin/$$f $$f /opt/bin/bsdmainutils-$$f 50" \
		>> $(BSDMAINUTILS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/bin/bsdmainutils-$$f" \
		>> $(BSDMAINUTILS_IPK_DIR)/CONTROL/prerm; \
	done
	echo "update-alternatives --install /opt/bin/cal cal /opt/bin/ncal 50" \
	    >> $(BSDMAINUTILS_IPK_DIR)/CONTROL/postinst
	echo "update-alternatives --remove cal /opt/bin/ncal" \
	    >> $(BSDMAINUTILS_IPK_DIR)/CONTROL/prerm
	d=/opt/share/man/man1; \
	cd $(BSDMAINUTILS_IPK_DIR)/$$d; \
	for f in *; do \
	    mv $$f bsdmainutils-$$f; \
	    echo "update-alternatives --install $$d/$$f $$f $$d/bsdmainutils-$$f 50" \
		>> $(BSDMAINUTILS_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f $$d/bsdmainutils-$$f" \
		>> $(BSDMAINUTILS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
		$(BSDMAINUTILS_IPK_DIR)/CONTROL/postinst $(BSDMAINUTILS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(BSDMAINUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(BSDMAINUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BSDMAINUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bsdmainutils-ipk: $(BSDMAINUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bsdmainutils-clean:
	rm -f $(BSDMAINUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(BSDMAINUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bsdmainutils-dirclean:
	rm -rf $(BUILD_DIR)/$(BSDMAINUTILS_DIR) $(BSDMAINUTILS_BUILD_DIR) $(BSDMAINUTILS_IPK_DIR) $(BSDMAINUTILS_IPK)

#
# Some sanity check for the package.
#
bsdmainutils-check: $(BSDMAINUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BSDMAINUTILS_IPK)
