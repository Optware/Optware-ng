###########################################################
#
# pyogg
#
###########################################################

# You must replace "pyogg" and "PYOGG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PYOGG_VERSION, PYOGG_SITE and PYOGG_SOURCE define
# the upstream location of the source code for the package.
# PYOGG_DIR is the directory which is created when the source
# archive is unpacked.
# PYOGG_UNZIP is the command used to unzip the source.
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
PYOGG_SITE=http://www.andrewchatham.com/pyogg/download
PYOGG_VERSION=1.3
PYOGG_SOURCE=pyogg-$(PYOGG_VERSION).tar.gz
PYOGG_DIR=pyogg-$(PYOGG_VERSION)
PYOGG_UNZIP=zcat
PYOGG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYOGG_DESCRIPTION=Python Wrapper for Ogg.
PYOGG_SECTION=misc
PYOGG_PRIORITY=optional
PYOGG_DEPENDS=libogg,python
PYOGG_SUGGESTS=
PYOGG_CONFLICTS=

#
# PYOGG_IPK_VERSION should be incremented when the ipk changes.
#
PYOGG_IPK_VERSION=1

#
# PYOGG_CONFFILES should be a list of user-editable files
#PYOGG_CONFFILES=/opt/etc/pyogg.conf /opt/etc/init.d/SXXpyogg

#
# PYOGG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PYOGG_PATCHES=$(PYOGG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYOGG_CPPFLAGS=
PYOGG_LDFLAGS=

#
# PYOGG_BUILD_DIR is the directory in which the build is done.
# PYOGG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYOGG_IPK_DIR is the directory in which the ipk is built.
# PYOGG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYOGG_BUILD_DIR=$(BUILD_DIR)/pyogg
PYOGG_SOURCE_DIR=$(SOURCE_DIR)/pyogg
PYOGG_IPK_DIR=$(BUILD_DIR)/pyogg-$(PYOGG_VERSION)-ipk
PYOGG_IPK=$(BUILD_DIR)/pyogg_$(PYOGG_VERSION)-$(PYOGG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYOGG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYOGG_SITE)/$(PYOGG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pyogg-source: $(DL_DIR)/$(PYOGG_SOURCE) $(PYOGG_PATCHES)

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
$(PYOGG_BUILD_DIR)/.configured: $(DL_DIR)/$(PYOGG_SOURCE) $(PYOGG_PATCHES) make/pyogg.mk
	$(MAKE) python-stage libogg-stage
	rm -rf $(BUILD_DIR)/$(PYOGG_DIR) $(PYOGG_BUILD_DIR)
	$(PYOGG_UNZIP) $(DL_DIR)/$(PYOGG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PYOGG_PATCHES)" ; \
		then cat $(PYOGG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PYOGG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PYOGG_DIR)" != "$(PYOGG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PYOGG_DIR) $(PYOGG_BUILD_DIR) ; \
	fi
	(cd $(PYOGG_BUILD_DIR); \
	    ( \
	        echo "ogg_libs=ogg"; \
		echo "ogg_lib_dir=$(STAGING_LIB_DIR)"; \
		echo "ogg_include_dir=$(STAGING_INCLUDE_DIR)"; \
	    ) > Setup; \
	)
	touch $(PYOGG_BUILD_DIR)/.configured

pyogg-unpack: $(PYOGG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYOGG_BUILD_DIR)/.built: $(PYOGG_BUILD_DIR)/.configured
	rm -f $(PYOGG_BUILD_DIR)/.built
	(cd $(PYOGG_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PYOGG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
pyogg: $(PYOGG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYOGG_BUILD_DIR)/.staged: $(PYOGG_BUILD_DIR)/.built
	rm -f $(PYOGG_BUILD_DIR)/.staged
#	$(MAKE) -C $(PYOGG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PYOGG_BUILD_DIR)/.staged

pyogg-stage: $(PYOGG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pyogg
#
$(PYOGG_IPK_DIR)/CONTROL/control:
	@install -d $(PYOGG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pyogg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYOGG_PRIORITY)" >>$@
	@echo "Section: $(PYOGG_SECTION)" >>$@
	@echo "Version: $(PYOGG_VERSION)-$(PYOGG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYOGG_MAINTAINER)" >>$@
	@echo "Source: $(PYOGG_SITE)/$(PYOGG_SOURCE)" >>$@
	@echo "Description: $(PYOGG_DESCRIPTION)" >>$@
	@echo "Depends: $(PYOGG_DEPENDS)" >>$@
	@echo "Suggests: $(PYOGG_SUGGESTS)" >>$@
	@echo "Conflicts: $(PYOGG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYOGG_IPK_DIR)/opt/sbin or $(PYOGG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYOGG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYOGG_IPK_DIR)/opt/etc/pyogg/...
# Documentation files should be installed in $(PYOGG_IPK_DIR)/opt/doc/pyogg/...
# Daemon startup scripts should be installed in $(PYOGG_IPK_DIR)/opt/etc/init.d/S??pyogg
#
# You may need to patch your application to make it use these locations.
#
$(PYOGG_IPK): $(PYOGG_BUILD_DIR)/.built
	rm -rf $(PYOGG_IPK_DIR) $(BUILD_DIR)/pyogg_*_$(TARGET_ARCH).ipk
	(cd $(PYOGG_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py install --root=$(PYOGG_IPK_DIR) --prefix=/opt; \
	)
	for so in `find $(PYOGG_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PYOGG_IPK_DIR)/CONTROL/control
	echo $(PYOGG_CONFFILES) | sed -e 's/ /\n/g' > $(PYOGG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYOGG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pyogg-ipk: $(PYOGG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pyogg-clean:
	rm -f $(PYOGG_BUILD_DIR)/.built
	-$(MAKE) -C $(PYOGG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pyogg-dirclean:
	rm -rf $(BUILD_DIR)/$(PYOGG_DIR) $(PYOGG_BUILD_DIR) $(PYOGG_IPK_DIR) $(PYOGG_IPK)
