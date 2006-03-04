###########################################################
#
# python
#
###########################################################

# You must replace "python" and "PYTHON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PYTHON_VERSION, PYTHON_SITE and PYTHON_SOURCE define
# the upstream location of the source code for the package.
# PYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON_UNZIP is the command used to unzip the source.
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
PYTHON_VERSION=2.4.2
PYTHON_VERSION_MAJOR=2.4
PYTHON_SITE=http://www.python.org/ftp/python/$(PYTHON_VERSION)
PYTHON_SOURCE=Python-$(PYTHON_VERSION).tar.bz2
PYTHON_DIR=Python-$(PYTHON_VERSION)
PYTHON_UNZIP=bzcat

PYTHON_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON_SECTION=misc
PYTHON_PRIORITY=optional
PYTHON_DEPENDS=libstdc++, readline, ncurses, openssl, libdb, zlib

#
# PYTHON_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON_IPK_VERSION=4

#
# PYTHON_CONFFILES should be a list of user-editable files
#PYTHON_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# PYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON_PATCHES=\
	$(PYTHON_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON_SOURCE_DIR)/README.patch \
	$(PYTHON_SOURCE_DIR)/config.guess.patch \
	$(PYTHON_SOURCE_DIR)/config.sub.patch \
	$(PYTHON_SOURCE_DIR)/configure.in.patch \
	$(PYTHON_SOURCE_DIR)/setup.py.patch \
	$(PYTHON_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON_CPPFLAGS=
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(OPTWARE_TARGET),wl500g)
PYTHON_LDFLAGS=-lncurses -lreadline -lcrypt -lssl
else
PYTHON_LDFLAGS=
endif
PYTHON_HOSTPYTHON_CPPFLAGS=
PYTHON_HOSTPYTHON_LDFLAGS=

#
# PYTHON_BUILD_DIR is the directory in which the build is done.
# PYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON_IPK_DIR is the directory in which the ipk is built.
# PYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON_BUILD_DIR=$(BUILD_DIR)/python
PYTHON_SOURCE_DIR=$(SOURCE_DIR)/python
PYTHON_IPK_DIR=$(BUILD_DIR)/python-$(PYTHON_VERSION)-ipk
PYTHON_IPK=$(BUILD_DIR)/python_$(PYTHON_VERSION)-$(PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYTHON_SITE)/$(PYTHON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python-source: $(DL_DIR)/$(PYTHON_SOURCE) $(PYTHON_PATCHES)

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
$(PYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON_SOURCE) $(PYTHON_PATCHES)
	make readline-stage ncurses-stage openssl-stage libdb-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(PYTHON_DIR) $(PYTHON_BUILD_DIR)
	$(PYTHON_UNZIP) $(DL_DIR)/$(PYTHON_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cd $(BUILD_DIR)/$(PYTHON_DIR); \
	    cat $(PYTHON_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON_DIR) -p1; \
	    autoconf configure.in > configure
	mkdir $(PYTHON_BUILD_DIR)
	(cd $(PYTHON_BUILD_DIR); \
	( \
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > setup.cfg; \
	\
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON_LDFLAGS)" \
		HOSTPYTHON_CPPFLAGS=$(PYTHON_HOSTPYTHON_CPPFLAGS) \
		HOSTPYTHON_LDFLAGS=$(PYTHON_HOSTPYTHON_LDFLAGS) \
		ac_cv_sizeof_off_t=8 \
		../$(PYTHON_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
		--enable-unicode=ucs4 \
	)
	touch $(PYTHON_BUILD_DIR)/.configured

python-unpack: $(PYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON_BUILD_DIR)/.built: $(PYTHON_BUILD_DIR)/.configured
	rm -f $(PYTHON_BUILD_DIR)/.built
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON_BUILD_DIR)
	touch $(PYTHON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
python: $(PYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON_BUILD_DIR)/.staged: $(PYTHON_BUILD_DIR)/.built
	rm -f $(PYTHON_BUILD_DIR)/.staged
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	install $(PYTHON_BUILD_DIR)/buildpython/python $(STAGING_DIR)/opt/bin/
	touch $(PYTHON_BUILD_DIR)/.staged

python-stage: $(PYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(PYTHON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON_PRIORITY)" >>$@
	@echo "Section: $(PYTHON_SECTION)" >>$@
	@echo "Version: $(PYTHON_VERSION)-$(PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON_SITE)/$(PYTHON_SOURCE)" >>$@
	@echo "Description: $(PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON_IPK_DIR)/opt/sbin or $(PYTHON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON_IPK): $(PYTHON_BUILD_DIR)/.built
	rm -rf $(PYTHON_IPK_DIR) $(BUILD_DIR)/python_*_$(TARGET_ARCH).ipk
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON_BUILD_DIR) DESTDIR=$(PYTHON_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON_IPK_DIR)/opt/bin/python$(PYTHON_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON_IPK_DIR)/opt/lib/python$(PYTHON_VERSION_MAJOR)/lib-dynload/*.so
	chmod 755 $(PYTHON_IPK_DIR)/opt/lib/libpython$(PYTHON_VERSION_MAJOR).so.1.0
	$(STRIP_COMMAND) $(PYTHON_IPK_DIR)/opt/lib/libpython$(PYTHON_VERSION_MAJOR).so.1.0
	chmod 555 $(PYTHON_IPK_DIR)/opt/lib/libpython$(PYTHON_VERSION_MAJOR).so.1.0
	rm $(PYTHON_IPK_DIR)/opt/bin/python
	cd $(PYTHON_IPK_DIR)/opt/bin; ln -s python$(PYTHON_VERSION_MAJOR) python
	install -d $(PYTHON_IPK_DIR)/opt/local/bin
	install -d $(PYTHON_IPK_DIR)/opt/local/lib/python$(PYTHON_VERSION_MAJOR)/site-packages
	install -d $(PYTHON_IPK_DIR)/usr/bin
ifneq ($(OPTWARE_TARGET),wl500g)
	ln -s /opt/bin/python $(PYTHON_IPK_DIR)/usr/bin/python
endif
	$(MAKE) $(PYTHON_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON_SOURCE_DIR)/postinst $(PYTHON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON_SOURCE_DIR)/prerm $(PYTHON_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python-ipk: $(PYTHON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python-clean:
	-$(MAKE) -C $(PYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON_DIR) $(PYTHON_BUILD_DIR) $(PYTHON_IPK_DIR) $(PYTHON_IPK)
