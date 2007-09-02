###########################################################
#
# python30
#
###########################################################

#
# PYTHON30_VERSION, PYTHON30_SITE and PYTHON30_SOURCE define
# the upstream location of the source code for the package.
# PYTHON30_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON30_UNZIP is the command used to unzip the source.
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
PYTHON30_VERSION=3.0a1
PYTHON30_VERSION_MAJOR=3.0
PYTHON30_SITE=http://www.python.org/ftp/python/$(PYTHON30_VERSION_MAJOR)/
PYTHON30_SOURCE=Python-$(PYTHON30_VERSION).tgz
PYTHON30_DIR=Python-$(PYTHON30_VERSION)
PYTHON30_UNZIP=zcat

PYTHON30_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON30_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON30_SECTION=misc
PYTHON30_PRIORITY=optional
PYTHON30_DEPENDS=readline, bzip2, openssl, libdb, zlib, sqlite
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PYTHON30_DEPENDS+=, libstdc++
endif
PYTHON30_DEPENDS+=, $(NCURSES_FOR_OPTWARE_TARGET)
PYTHON30_SUGGESTS=

#
# PYTHON30_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON30_IPK_VERSION=1

#
# PYTHON30_CONFFILES should be a list of user-editable files
#PYTHON30_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON30_CPPFLAGS=
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(LIBC_STYLE),uclibc)
PYTHON30_LDFLAGS=-lbz2 -lcrypt -ldb-$(LIBDB_LIB_VERSION) -lncurses -lreadline -lssl -lz
else
PYTHON30_LDFLAGS=
endif

#
# PYTHON30_BUILD_DIR is the directory in which the build is done.
# PYTHON30_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON30_IPK_DIR is the directory in which the ipk is built.
# PYTHON30_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON30_BUILD_DIR=$(BUILD_DIR)/python30
PYTHON30_SOURCE_DIR=$(SOURCE_DIR)/python30
PYTHON30_IPK_DIR=$(BUILD_DIR)/python30-$(PYTHON30_VERSION)-ipk
PYTHON30_IPK=$(BUILD_DIR)/python30_$(PYTHON30_VERSION)-$(PYTHON30_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# PYTHON30_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON30_PATCHES=\
	$(PYTHON30_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON30_SOURCE_DIR)/README.patch \
	$(PYTHON30_SOURCE_DIR)/config.guess.patch \
	$(PYTHON30_SOURCE_DIR)/config.sub.patch \
	$(PYTHON30_SOURCE_DIR)/configure.in.patch \
	$(PYTHON30_SOURCE_DIR)/setup.py.patch \
	$(PYTHON30_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON30_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \

ifeq ($(NCURSES_FOR_OPTWARE_TARGET), ncurses)
PYTHON30_PATCHES+= $(PYTHON30_SOURCE_DIR)/disable-ncursesw.patch
endif

.PHONY: python30-source python30-unpack python30 python30-stage python30-ipk python30-clean python30-dirclean python30-check python30-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON30_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYTHON30_SITE)/$(PYTHON30_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PYTHON30_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python30-source: $(DL_DIR)/$(PYTHON30_SOURCE) $(PYTHON30_PATCHES)

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
$(PYTHON30_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON30_SOURCE) $(PYTHON30_PATCHES) # make/python30.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) bzip2-stage readline-stage openssl-stage libdb-stage sqlite-stage zlib-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(PYTHON30_DIR) $(PYTHON30_BUILD_DIR)
	$(PYTHON30_UNZIP) $(DL_DIR)/$(PYTHON30_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cd $(BUILD_DIR)/$(PYTHON30_DIR); \
	    cat $(PYTHON30_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON30_DIR) -p1; \
	    autoconf configure.in > configure
	mkdir $(PYTHON30_BUILD_DIR)
	(cd $(PYTHON30_BUILD_DIR); \
	( \
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > setup.cfg; \
	\
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON30_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON30_LDFLAGS)" \
		ac_cv_sizeof_off_t=8 \
		ac_cv_file__dev_ptmx=yes \
		ac_cv_file__dev_ptc=no \
		ac_cv_header_bluetooth_bluetooth_h=no \
		ac_cv_header_bluetooth_h=no \
		../$(PYTHON30_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--enable-shared \
		--enable-unicode=ucs4 \
	)
	touch $(PYTHON30_BUILD_DIR)/.configured

python30-unpack: $(PYTHON30_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON30_BUILD_DIR)/.built: $(PYTHON30_BUILD_DIR)/.configured
	rm -f $(PYTHON30_BUILD_DIR)/.built
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON30_BUILD_DIR)
	touch $(PYTHON30_BUILD_DIR)/.built

#
# This is the build convenience target.
#
python30: $(PYTHON30_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON30_BUILD_DIR)/.staged: $(PYTHON30_BUILD_DIR)/.built
	rm -f $(PYTHON30_BUILD_DIR)/.staged
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON30_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PYTHON30_BUILD_DIR)/.staged

python30-stage: $(PYTHON30_BUILD_DIR)/.staged

$(HOST_STAGING_PREFIX)/bin/python3.0: host/.configured make/python30.mk
	$(MAKE) $(PYTHON30_BUILD_DIR)/.built
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON30_BUILD_DIR)/buildpython30 DESTDIR=$(HOST_STAGING_DIR) install
	rm -f $(HOST_STAGING_PREFIX)/bin/python

python30-host-stage: $(HOST_STAGING_PREFIX)/bin/python3.0

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON30_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: python30" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON30_PRIORITY)" >>$@
	@echo "Section: $(PYTHON30_SECTION)" >>$@
	@echo "Version: $(PYTHON30_VERSION)-$(PYTHON30_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON30_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON30_SITE)/$(PYTHON30_SOURCE)" >>$@
	@echo "Description: $(PYTHON30_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON30_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON30_IPK_DIR)/opt/sbin or $(PYTHON30_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON30_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON30_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON30_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON30_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON30_IPK): $(PYTHON30_BUILD_DIR)/.built
	rm -rf $(PYTHON30_IPK_DIR) $(BUILD_DIR)/python30_*_$(TARGET_ARCH).ipk
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(PYTHON30_BUILD_DIR) DESTDIR=$(PYTHON30_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON30_IPK_DIR)/opt/bin/python$(PYTHON30_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON30_IPK_DIR)/opt/lib/python$(PYTHON30_VERSION_MAJOR)/lib-dynload/*.so
	chmod 755 $(PYTHON30_IPK_DIR)/opt/lib/libpython$(PYTHON30_VERSION_MAJOR).so.1.0
	$(STRIP_COMMAND) $(PYTHON30_IPK_DIR)/opt/lib/libpython$(PYTHON30_VERSION_MAJOR).so.1.0
	chmod 555 $(PYTHON30_IPK_DIR)/opt/lib/libpython$(PYTHON30_VERSION_MAJOR).so.1.0
	rm $(PYTHON30_IPK_DIR)/opt/bin/python $(PYTHON30_IPK_DIR)/opt/bin/python-config
#	cd $(PYTHON30_IPK_DIR)/opt/bin; ln -s python$(PYTHON30_VERSION_MAJOR) python
	for f in bin/pydoc bin/idle bin/smtpd.py man/man1/python.1; \
	    do mv $(PYTHON30_IPK_DIR)/opt/$$f $(PYTHON30_IPK_DIR)/opt/`echo $$f | sed -e 's/\(\.\|$$\)/3.0\1/'`; done
	install -d $(PYTHON30_IPK_DIR)/opt/local/bin
	install -d $(PYTHON30_IPK_DIR)/opt/local/lib/python$(PYTHON30_VERSION_MAJOR)/site-packages
	$(MAKE) $(PYTHON30_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON30_SOURCE_DIR)/postinst $(PYTHON30_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON30_SOURCE_DIR)/prerm $(PYTHON30_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON30_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python30-ipk: $(PYTHON30_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python30-clean:
	-$(MAKE) -C $(PYTHON30_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python30-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON30_DIR) $(PYTHON30_BUILD_DIR) $(PYTHON30_IPK_DIR) $(PYTHON30_IPK)

#
# Some sanity check for the package.
#
python30-check: $(PYTHON30_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PYTHON30_IPK)
