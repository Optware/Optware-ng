###########################################################
#
# clearsilver
#
###########################################################
#
# CLEARSILVER_VERSION, CLEARSILVER_SITE and CLEARSILVER_SOURCE define
# the upstream location of the source code for the package.
# CLEARSILVER_DIR is the directory which is created when the source
# archive is unpacked.
# CLEARSILVER_UNZIP is the command used to unzip the source.
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
CLEARSILVER_SITE=http://www.clearsilver.net/downloads
CLEARSILVER_VERSION=0.10.5
CLEARSILVER_SOURCE=clearsilver-$(CLEARSILVER_VERSION).tar.gz
CLEARSILVER_DIR=clearsilver-$(CLEARSILVER_VERSION)
CLEARSILVER_UNZIP=zcat
CLEARSILVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CLEARSILVER_DESCRIPTION=A fast, powerful, and language-neutral HTML template system.
CLEARSILVER_SECTION=misc
CLEARSILVER_PRIORITY=optional
CLEARSILVER_DEPENDS=zlib
CLEARSILVER_SUGGESTS=
CLEARSILVER_CONFLICTS=

#
# CLEARSILVER_IPK_VERSION should be incremented when the ipk changes.
#
CLEARSILVER_IPK_VERSION=1

#
# CLEARSILVER_CONFFILES should be a list of user-editable files
#CLEARSILVER_CONFFILES=/opt/etc/clearsilver.conf /opt/etc/init.d/SXXclearsilver

#
# CLEARSILVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CLEARSILVER_PATCHES=$(CLEARSILVER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLEARSILVER_CPPFLAGS=
CLEARSILVER_LDFLAGS=

#
# CLEARSILVER_BUILD_DIR is the directory in which the build is done.
# CLEARSILVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLEARSILVER_IPK_DIR is the directory in which the ipk is built.
# CLEARSILVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLEARSILVER_BUILD_DIR=$(BUILD_DIR)/clearsilver
CLEARSILVER_SOURCE_DIR=$(SOURCE_DIR)/clearsilver
CLEARSILVER_IPK_DIR=$(BUILD_DIR)/clearsilver-$(CLEARSILVER_VERSION)-ipk
CLEARSILVER_IPK=$(BUILD_DIR)/clearsilver_$(CLEARSILVER_VERSION)-$(CLEARSILVER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: clearsilver-source clearsilver-unpack clearsilver clearsilver-stage clearsilver-ipk clearsilver-clean clearsilver-dirclean clearsilver-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLEARSILVER_SOURCE):
	$(WGET) -P $(DL_DIR) $(CLEARSILVER_SITE)/$(CLEARSILVER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
clearsilver-source: $(DL_DIR)/$(CLEARSILVER_SOURCE) $(CLEARSILVER_PATCHES)

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
$(CLEARSILVER_BUILD_DIR)/.configured: $(DL_DIR)/$(CLEARSILVER_SOURCE) $(CLEARSILVER_PATCHES) make/clearsilver.mk
	$(MAKE) python-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(CLEARSILVER_DIR) $(CLEARSILVER_BUILD_DIR)
	$(CLEARSILVER_UNZIP) $(DL_DIR)/$(CLEARSILVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CLEARSILVER_PATCHES)" ; \
		then cat $(CLEARSILVER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CLEARSILVER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CLEARSILVER_DIR)" != "$(CLEARSILVER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CLEARSILVER_DIR) $(CLEARSILVER_BUILD_DIR) ; \
	fi
	cp -f $(SOURCE_DIR)/common/config.* $(CLEARSILVER_BUILD_DIR)/
	cp -a $(CLEARSILVER_BUILD_DIR)/python $(CLEARSILVER_BUILD_DIR)/python2.5
#	        echo "rpath=/opt/lib";
	(cd $(CLEARSILVER_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > python/setup.cfg; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > python2.5/setup.cfg; \
	)
	(cd $(CLEARSILVER_BUILD_DIR); \
		sed -i \
		    -e 's/^LDSHARED.*/& @LDFLAGS@/' \
		    -e '/^LD/s/$$(CC) -o/$$(CC) @LDFLAGS@ -o/' \
		    rules.mk.in; \
		sed -i -e '/^TARGETS.* test$$/s/ test$$//' cs/Makefile; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLEARSILVER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CLEARSILVER_LDFLAGS)" \
		PYTHON_SITE="/opt/lib/python2.4/site-packages" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-apache \
		--disable-csharp \
		--disable-java \
		--disable-perl \
		--enable-python \
		--with-python=$(HOST_STAGING_PREFIX)/bin/python2.4 \
		--disable-ruby \
		--disable-nls \
		--disable-static \
		; \
	)
#	$(PATCH_LIBTOOL) $(CLEARSILVER_BUILD_DIR)/libtool
	touch $(CLEARSILVER_BUILD_DIR)/.configured

clearsilver-unpack: $(CLEARSILVER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLEARSILVER_BUILD_DIR)/.built: $(CLEARSILVER_BUILD_DIR)/.configured
	rm -f $(CLEARSILVER_BUILD_DIR)/.built
	$(MAKE) -C $(CLEARSILVER_BUILD_DIR)
	$(MAKE) -C $(CLEARSILVER_BUILD_DIR)/python2.5 \
		PYTHON_SITE=/opt/lib/python2.5/site-packages
	touch $(CLEARSILVER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
clearsilver: $(CLEARSILVER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLEARSILVER_BUILD_DIR)/.staged: $(CLEARSILVER_BUILD_DIR)/.built
	rm -f $(CLEARSILVER_BUILD_DIR)/.staged
	$(MAKE) -C $(CLEARSILVER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CLEARSILVER_BUILD_DIR)/.staged

clearsilver-stage: $(CLEARSILVER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/clearsilver
#
$(CLEARSILVER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: clearsilver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLEARSILVER_PRIORITY)" >>$@
	@echo "Section: $(CLEARSILVER_SECTION)" >>$@
	@echo "Version: $(CLEARSILVER_VERSION)-$(CLEARSILVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLEARSILVER_MAINTAINER)" >>$@
	@echo "Source: $(CLEARSILVER_SITE)/$(CLEARSILVER_SOURCE)" >>$@
	@echo "Description: $(CLEARSILVER_DESCRIPTION)" >>$@
	@echo "Depends: $(CLEARSILVER_DEPENDS)" >>$@
	@echo "Suggests: $(CLEARSILVER_SUGGESTS)" >>$@
	@echo "Conflicts: $(CLEARSILVER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLEARSILVER_IPK_DIR)/opt/sbin or $(CLEARSILVER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLEARSILVER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLEARSILVER_IPK_DIR)/opt/etc/clearsilver/...
# Documentation files should be installed in $(CLEARSILVER_IPK_DIR)/opt/doc/clearsilver/...
# Daemon startup scripts should be installed in $(CLEARSILVER_IPK_DIR)/opt/etc/init.d/S??clearsilver
#
# You may need to patch your application to make it use these locations.
#
$(CLEARSILVER_IPK): $(CLEARSILVER_BUILD_DIR)/.built
	rm -rf $(CLEARSILVER_IPK_DIR) $(BUILD_DIR)/clearsilver_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CLEARSILVER_BUILD_DIR) DESTDIR=$(CLEARSILVER_IPK_DIR) install
	$(STRIP_COMMAND) $(CLEARSILVER_IPK_DIR)/opt/bin/*
	$(MAKE) -C $(CLEARSILVER_BUILD_DIR)/python2.5 DESTDIR=$(CLEARSILVER_IPK_DIR) install \
		PYTHON_SITE=/opt/lib/python2.5/site-packages
	$(STRIP_COMMAND) `find $(CLEARSILVER_IPK_DIR)/opt/lib -name '*.so'`
#	install -d $(CLEARSILVER_IPK_DIR)/opt/etc/
#	install -m 644 $(CLEARSILVER_SOURCE_DIR)/clearsilver.conf $(CLEARSILVER_IPK_DIR)/opt/etc/clearsilver.conf
#	install -d $(CLEARSILVER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CLEARSILVER_SOURCE_DIR)/rc.clearsilver $(CLEARSILVER_IPK_DIR)/opt/etc/init.d/SXXclearsilver
	$(MAKE) $(CLEARSILVER_IPK_DIR)/CONTROL/control
#	install -m 755 $(CLEARSILVER_SOURCE_DIR)/postinst $(CLEARSILVER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CLEARSILVER_SOURCE_DIR)/prerm $(CLEARSILVER_IPK_DIR)/CONTROL/prerm
#	echo $(CLEARSILVER_CONFFILES) | sed -e 's/ /\n/g' > $(CLEARSILVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLEARSILVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
clearsilver-ipk: $(CLEARSILVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
clearsilver-clean:
	rm -f $(CLEARSILVER_BUILD_DIR)/.built
	-$(MAKE) -C $(CLEARSILVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
clearsilver-dirclean:
	rm -rf $(BUILD_DIR)/$(CLEARSILVER_DIR) $(CLEARSILVER_BUILD_DIR) $(CLEARSILVER_IPK_DIR) $(CLEARSILVER_IPK)

#
# Some sanity check for the package.
#
clearsilver-check: $(CLEARSILVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CLEARSILVER_IPK)

