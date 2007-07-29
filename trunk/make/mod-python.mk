###########################################################
#
# mod_python
#
###########################################################

#
# MOD_PYTHON_VERSION, MOD_PYTHON_SITE and MOD_PYTHON_SOURCE define
# the upstream location of the source code for the package.
# MOD_PYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# MOD_PYTHON_UNZIP is the command used to unzip the source.
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
MOD_PYTHON_SITE=http://www.apache.org/dist/httpd/modpython
MOD_PYTHON_VERSION=3.3.1
MOD_PYTHON_SOURCE=mod_python-$(MOD_PYTHON_VERSION).tgz
MOD_PYTHON_DIR=mod_python-$(MOD_PYTHON_VERSION)
MOD_PYTHON_UNZIP=zcat
MOD_PYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOD_PYTHON_DESCRIPTION=Mod_python is an Apache server module that integrates with the Python language.
MOD_PYTHON_SECTION=net
MOD_PYTHON_PRIORITY=optional
MOD_PYTHON_DEPENDS=apache, python25
MOD_PYTHON_SUGGESTS=
MOD_PYTHON_CONFLICTS=

#
# MOD_PYTHON_IPK_VERSION should be incremented when the ipk changes.
#
MOD_PYTHON_IPK_VERSION=1

#
# MOD_PYTHON_CONFFILES should be a list of user-editable files
MOD_PYTHON_CONFFILES=/opt/etc/apache2/conf.d/mod_python.conf

#
# MOD_PYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOD_PYTHON_PATCHES=$(MOD_PYTHON_SOURCE_DIR)/configure.in.patch $(MOD_PYTHON_SOURCE_DIR)/dist-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOD_PYTHON_CPPFLAGS=
MOD_PYTHON_LDFLAGS=

#
# MOD_PYTHON_BUILD_DIR is the directory in which the build is done.
# MOD_PYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOD_PYTHON_IPK_DIR is the directory in which the ipk is built.
# MOD_PYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOD_PYTHON_BUILD_DIR=$(BUILD_DIR)/mod-python
MOD_PYTHON_SOURCE_DIR=$(SOURCE_DIR)/mod-python
MOD_PYTHON_IPK_DIR=$(BUILD_DIR)/mod-python-$(MOD_PYTHON_VERSION)-ipk
MOD_PYTHON_IPK=$(BUILD_DIR)/mod-python_$(MOD_PYTHON_VERSION)-$(MOD_PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

MOD_PYTHON_APACHE_VERSION=$(shell sed -n -e 's/^APACHE_VERSION *=//p' make/apache.mk)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOD_PYTHON_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOD_PYTHON_SITE)/$(MOD_PYTHON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mod-python-source: $(DL_DIR)/$(MOD_PYTHON_SOURCE) $(MOD_PYTHON_PATCHES)

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
# Note: configure breaks if bash 3.1 is installed!
$(MOD_PYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(MOD_PYTHON_SOURCE) $(MOD_PYTHON_PATCHES)
	$(MAKE) python25-stage apache-stage
	rm -rf $(BUILD_DIR)/$(MOD_PYTHON_DIR) $(MOD_PYTHON_BUILD_DIR)
	$(MOD_PYTHON_UNZIP) $(DL_DIR)/$(MOD_PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MOD_PYTHON_PATCHES) | patch -d $(BUILD_DIR)/$(MOD_PYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(MOD_PYTHON_DIR) $(MOD_PYTHON_BUILD_DIR)
	(cd $(MOD_PYTHON_BUILD_DIR); \
		sed -i -e 's:@APACHE_VERSION@:$(MOD_PYTHON_APACHE_VERSION):' configure.in; \
		sed -i -e 's:@CC_AND_LDSHARED@:CC=$(TARGET_CC) LDSHARED="$(TARGET_CC) -shared":' dist/Makefile.in; \
		autoreconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOD_PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOD_PYTHON_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-apxs=$(STAGING_DIR)/opt/sbin/apxs \
		--with-python=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		--disable-nls \
	    ; \
            ( \
                echo "[build_ext]"; \
                echo "include-dirs=$(STAGING_DIR)/opt/include"; \
                echo "library-dirs=$(STAGING_DIR)/opt/lib"; \
                echo "rpath=/opt/lib"; \
                echo "[build_scripts]"; \
                echo "executable=/opt/bin/python2.5"; \
                echo "[install]"; \
                echo "prefix=/opt"; \
            ) > $(MOD_PYTHON_BUILD_DIR)/dist/setup.cfg; \
	)
	touch $(MOD_PYTHON_BUILD_DIR)/.configured

mod-python-unpack: $(MOD_PYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOD_PYTHON_BUILD_DIR)/.built: $(MOD_PYTHON_BUILD_DIR)/.configured
	rm -f $(MOD_PYTHON_BUILD_DIR)/.built
	$(MAKE) -C $(MOD_PYTHON_BUILD_DIR)
	touch $(MOD_PYTHON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mod-python: $(MOD_PYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOD_PYTHON_BUILD_DIR)/.staged: $(MOD_PYTHON_BUILD_DIR)/.built
	rm -f $(MOD_PYTHON_BUILD_DIR)/.staged
	$(TARGET_CONFIGURE_OPTS) \
	LDSHARED="$(TARGET_CC) -shared" \
		$(MAKE) -C $(MOD_PYTHON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MOD_PYTHON_BUILD_DIR)/.staged

mod-python-stage: $(MOD_PYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mod-python
#
$(MOD_PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(MOD_PYTHON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mod-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOD_PYTHON_PRIORITY)" >>$@
	@echo "Section: $(MOD_PYTHON_SECTION)" >>$@
	@echo "Version: $(MOD_PYTHON_VERSION)-$(MOD_PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOD_PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(MOD_PYTHON_SITE)/$(MOD_PYTHON_SOURCE)" >>$@
	@echo "Description: $(MOD_PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(MOD_PYTHON_DEPENDS)" >>$@
	@echo "Suggests: $(MOD_PYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOD_PYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOD_PYTHON_IPK_DIR)/opt/sbin or $(MOD_PYTHON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOD_PYTHON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOD_PYTHON_IPK_DIR)/opt/etc/mod-python/...
# Documentation files should be installed in $(MOD_PYTHON_IPK_DIR)/opt/doc/mod-python/...
# Daemon startup scripts should be installed in $(MOD_PYTHON_IPK_DIR)/opt/etc/init.d/S??mod-python
#
# You may need to patch your application to make it use these locations.
#
$(MOD_PYTHON_IPK): $(MOD_PYTHON_BUILD_DIR)/.built
	rm -rf $(MOD_PYTHON_IPK_DIR) $(BUILD_DIR)/mod-python_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOD_PYTHON_BUILD_DIR) DESTDIR=$(MOD_PYTHON_IPK_DIR) install
	$(STRIP_COMMAND) $(MOD_PYTHON_IPK_DIR)/opt/libexec/mod_python.so
	$(STRIP_COMMAND) $(MOD_PYTHON_IPK_DIR)/opt/lib/python2.5/site-packages/mod_python/_psp.so
	install -d $(MOD_PYTHON_IPK_DIR)/opt/etc/apache2/conf.d/
	install -m 644 $(MOD_PYTHON_SOURCE_DIR)/mod_python.conf $(MOD_PYTHON_IPK_DIR)/opt/etc/apache2/conf.d/mod_python.conf
	$(MAKE) $(MOD_PYTHON_IPK_DIR)/CONTROL/control
	echo $(MOD_PYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(MOD_PYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOD_PYTHON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mod-python-ipk: $(MOD_PYTHON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mod-python-clean:
	-$(MAKE) -C $(MOD_PYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mod-python-dirclean:
	rm -rf $(BUILD_DIR)/$(MOD_PYTHON_DIR) $(MOD_PYTHON_BUILD_DIR) $(MOD_PYTHON_IPK_DIR) $(MOD_PYTHON_IPK)

#
# Some sanity check for the package.
#
mod-python-check: $(MOD_PYTHON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOD_PYTHON_IPK)
