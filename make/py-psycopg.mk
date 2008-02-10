###########################################################
#
# py-psycopg
#
###########################################################

#
# PY-PSYCOPG_VERSION, PY-PSYCOPG_SITE and PY-PSYCOPG_SOURCE define
# the upstream location of the source code for the package.
# PY-PSYCOPG_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PSYCOPG_UNZIP is the command used to unzip the source.
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
PY-PSYCOPG_SITE=http://initd.org/pub/software/psycopg
PY-PSYCOPG_VERSION=1.1.21
PY-PSYCOPG_SOURCE=psycopg-$(PY-PSYCOPG_VERSION).tar.gz
PY-PSYCOPG_DIR=psycopg-$(PY-PSYCOPG_VERSION)
PY-PSYCOPG_UNZIP=zcat
PY-PSYCOPG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PSYCOPG_DESCRIPTION=psycopg is a PostgreSQL database adapter for the Python programming language.
PY-PSYCOPG_SECTION=misc
PY-PSYCOPG_PRIORITY=optional
PY24-PSYCOPG_DEPENDS=python24, py-mx-base
PY25-PSYCOPG_DEPENDS=python25, py25-mx-base
PY-PSYCOPG_CONFLICTS=

#
# PY-PSYCOPG_IPK_VERSION should be incremented when the ipk changes.
#
PY-PSYCOPG_IPK_VERSION=5

#
# PY-PSYCOPG_CONFFILES should be a list of user-editable files
#PY-PSYCOPG_CONFFILES=/opt/etc/py-psycopg.conf /opt/etc/init.d/SXXpy-psycopg

#
# PY-PSYCOPG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PSYCOPG_PATCHES=$(PY-PSYCOPG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PSYCOPG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/postgresql
PY-PSYCOPG_LDFLAGS=

#
# PY-PSYCOPG_BUILD_DIR is the directory in which the build is done.
# PY-PSYCOPG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PSYCOPG_IPK_DIR is the directory in which the ipk is built.
# PY-PSYCOPG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PSYCOPG_BUILD_DIR=$(BUILD_DIR)/py-psycopg
PY-PSYCOPG_SOURCE_DIR=$(SOURCE_DIR)/py-psycopg

PY24-PSYCOPG_IPK_DIR=$(BUILD_DIR)/py-psycopg-$(PY-PSYCOPG_VERSION)-ipk
PY24-PSYCOPG_IPK=$(BUILD_DIR)/py-psycopg_$(PY-PSYCOPG_VERSION)-$(PY-PSYCOPG_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PSYCOPG_IPK_DIR=$(BUILD_DIR)/py25-psycopg-$(PY-PSYCOPG_VERSION)-ipk
PY25-PSYCOPG_IPK=$(BUILD_DIR)/py25-psycopg_$(PY-PSYCOPG_VERSION)-$(PY-PSYCOPG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-psycopg-source py-psycopg-unpack py-psycopg py-psycopg-stage py-psycopg-ipk py-psycopg-clean py-psycopg-dirclean py-psycopg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PSYCOPG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PSYCOPG_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(PY-PSYCOPG_SITE)/PSYCOPG-1-1/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-psycopg-source: $(DL_DIR)/$(PY-PSYCOPG_SOURCE) $(PY-PSYCOPG_PATCHES)

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
$(PY-PSYCOPG_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PSYCOPG_SOURCE) $(PY-PSYCOPG_PATCHES)
	$(MAKE) postgresql-stage python-stage py-mx-base-stage
	rm -rf $(PY-PSYCOPG_BUILD_DIR)
	mkdir -p $(PY-PSYCOPG_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG_DIR)
	$(PY-PSYCOPG_UNZIP) $(DL_DIR)/$(PY-PSYCOPG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-PSYCOPG_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PSYCOPG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PSYCOPG_DIR) $(@D)/2.4
	sed -i -e '/py_makefile=/s|=.*|=$(STAGING_LIB_DIR)/python2.4/config/Makefile|' $(@D)/2.4/configure
	(cd $(@D)/2.4; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PY-PSYCOPG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-PSYCOPG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-python=$(HOST_STAGING_PREFIX)/bin/python2.4 \
		--with-python-prefix=/opt \
		--with-postgres-includes=$(STAGING_INCLUDE_DIR)/postgresql \
		--with-postgres-libraries=$(STAGING_LIB_DIR) \
		--with-mxdatetime-includes=$(STAGING_LIB_DIR)/python2.4/site-packages/mx/DateTime/mxDateTime/ \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG_DIR)
	$(PY-PSYCOPG_UNZIP) $(DL_DIR)/$(PY-PSYCOPG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-PSYCOPG_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PSYCOPG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PSYCOPG_DIR) $(@D)/2.5
	sed -i -e '/py_makefile=/s|=.*|=$(STAGING_LIB_DIR)/python2.5/config/Makefile|' $(@D)/2.5/configure
	(cd $(@D)/2.5; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PY-PSYCOPG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PY-PSYCOPG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-python=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		--with-python-prefix=/opt \
		--with-postgres-includes=$(STAGING_INCLUDE_DIR)/postgresql \
		--with-postgres-libraries=$(STAGING_LIB_DIR) \
		--with-mxdatetime-includes=$(STAGING_LIB_DIR)/python2.5/site-packages/mx/DateTime/mxDateTime/ \
	)
	touch $@

py-psycopg-unpack: $(PY-PSYCOPG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PSYCOPG_BUILD_DIR)/.built: $(PY-PSYCOPG_BUILD_DIR)/.configured
	rm -f $@
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(@D)/2.4 \
		INCLUDEDIR=$(STAGING_INCLUDE_DIR) \
		LDSHARED="$(TARGET_CC) -s -shared -lc `echo $(STAGING_LDFLAGS) $(PY-PSYCOPG_LDFLAGS)`"
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
		$(MAKE) -C $(@D)/2.5 \
		INCLUDEDIR=$(STAGING_INCLUDE_DIR) \
		LDSHARED="$(TARGET_CC) -s -shared -lc `echo $(STAGING_LDFLAGS) $(PY-PSYCOPG_LDFLAGS)`"
	touch $@

#
# This is the build convenience target.
#
py-psycopg: $(PY-PSYCOPG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PSYCOPG_BUILD_DIR)/.staged: $(PY-PSYCOPG_BUILD_DIR)/.built
	rm -f $@
	#$(MAKE) -C $(PY-PSYCOPG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-psycopg-stage: $(PY-PSYCOPG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-psycopg
#
$(PY24-PSYCOPG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-psycopg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PSYCOPG_PRIORITY)" >>$@
	@echo "Section: $(PY-PSYCOPG_SECTION)" >>$@
	@echo "Version: $(PY-PSYCOPG_VERSION)-$(PY-PSYCOPG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PSYCOPG_MAINTAINER)" >>$@
	@echo "Source: $(PY-PSYCOPG_SITE)/$(PY-PSYCOPG_SOURCE)" >>$@
	@echo "Description: $(PY-PSYCOPG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PSYCOPG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PSYCOPG_CONFLICTS)" >>$@

$(PY25-PSYCOPG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-psycopg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PSYCOPG_PRIORITY)" >>$@
	@echo "Section: $(PY-PSYCOPG_SECTION)" >>$@
	@echo "Version: $(PY-PSYCOPG_VERSION)-$(PY-PSYCOPG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PSYCOPG_MAINTAINER)" >>$@
	@echo "Source: $(PY-PSYCOPG_SITE)/$(PY-PSYCOPG_SOURCE)" >>$@
	@echo "Description: $(PY-PSYCOPG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PSYCOPG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PSYCOPG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PSYCOPG_IPK_DIR)/opt/sbin or $(PY-PSYCOPG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PSYCOPG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PSYCOPG_IPK_DIR)/opt/etc/py-psycopg/...
# Documentation files should be installed in $(PY-PSYCOPG_IPK_DIR)/opt/doc/py-psycopg/...
# Daemon startup scripts should be installed in $(PY-PSYCOPG_IPK_DIR)/opt/etc/init.d/S??py-psycopg
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PSYCOPG_IPK): $(PY-PSYCOPG_BUILD_DIR)/.built
	rm -rf $(PY24-PSYCOPG_IPK_DIR) $(BUILD_DIR)/py-psycopg_*_$(TARGET_ARCH).ipk
	install -d $(PY24-PSYCOPG_IPK_DIR)/opt/lib/python2.4/site-packages
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
	$(MAKE) -C $(PY-PSYCOPG_BUILD_DIR)/2.4 \
		prefix=$(PY24-PSYCOPG_IPK_DIR)/opt \
		exec_prefix=$(PY24-PSYCOPG_IPK_DIR)/opt \
		INSTALL=install install
	for f in `find $(PY24-PSYCOPG_IPK_DIR)/opt/lib -name '*.so'`; do \
		chmod u+w $$f; $(STRIP_COMMAND) $$f; chmod u-w $$f; \
	done
	install -d $(PY24-PSYCOPG_IPK_DIR)/opt/share/doc/
	cp -rp $(PY-PSYCOPG_BUILD_DIR)/2.4/doc $(PY24-PSYCOPG_IPK_DIR)/opt/share/doc/py-psycopg
	$(MAKE) $(PY24-PSYCOPG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PSYCOPG_IPK_DIR)

$(PY25-PSYCOPG_IPK): $(PY-PSYCOPG_BUILD_DIR)/.built
	rm -rf $(PY25-PSYCOPG_IPK_DIR) $(BUILD_DIR)/py25-psycopg_*_$(TARGET_ARCH).ipk
	install -d $(PY25-PSYCOPG_IPK_DIR)/opt/lib/python2.5/site-packages
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
	$(MAKE) -C $(PY-PSYCOPG_BUILD_DIR)/2.5 \
		prefix=$(PY25-PSYCOPG_IPK_DIR)/opt \
		exec_prefix=$(PY25-PSYCOPG_IPK_DIR)/opt \
		INSTALL=install install
	for f in `find $(PY25-PSYCOPG_IPK_DIR)/opt/lib -name '*.so'`; do \
		chmod u+w $$f; $(STRIP_COMMAND) $$f; chmod u-w $$f; \
	done
	install -d $(PY25-PSYCOPG_IPK_DIR)/opt/share/doc/
	cp -rp $(PY-PSYCOPG_BUILD_DIR)/2.5/doc $(PY24-PSYCOPG_IPK_DIR)/opt/share/doc/py-psycopg
	$(MAKE) $(PY25-PSYCOPG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PSYCOPG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-psycopg-ipk: $(PY24-PSYCOPG_IPK) $(PY25-PSYCOPG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-psycopg-clean:
	-$(MAKE) -C $(PY-PSYCOPG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-psycopg-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG_DIR) $(PY-PSYCOPG_BUILD_DIR)
	rm -rf $(PY24-PSYCOPG_IPK_DIR) $(PY24-PSYCOPG_IPK)
	rm -rf $(PY25-PSYCOPG_IPK_DIR) $(PY25-PSYCOPG_IPK)

#
# Some sanity check for the package.
#
py-psycopg-check: $(PY24-PSYCOPG_IPK) $(PY25-PSYCOPG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PSYCOPG_IPK) $(PY25-PSYCOPG_IPK)
