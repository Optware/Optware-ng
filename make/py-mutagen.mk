###########################################################
#
# py-mutagen
#
###########################################################

#
# PY_MUTAGEN_VERSION, PY_MUTAGEN_SITE and PY_MUTAGEN_SOURCE define
# the upstream location of the source code for the package.
# PY_MUTAGEN_DIR is the directory which is created when the source
# archive is unpacked.
# PY_MUTAGEN_UNZIP is the command used to unzip the source.
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
PY_MUTAGEN_VERSION=1.39
PY_MUTAGEN_SITE=https://pypi.python.org/packages/61/cb/df5b1ed5276d758684b245ecde990b05ea7470d4fa9530deb86a24cf723b
PY_MUTAGEN_SOURCE=mutagen-$(PY_MUTAGEN_VERSION).tar.gz
PY_MUTAGEN_DIR=mutagen-$(PY_MUTAGEN_VERSION)
PY_MUTAGEN_UNZIP=zcat
PY_MUTAGEN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY_MUTAGEN_DESCRIPTION=Mutagen is a Python module to handle audio metadata. It supports ASF, FLAC, MP4, Monkey’s Audio, MP3, Musepack, Ogg Opus, Ogg FLAC, Ogg Speex, Ogg Theora, Ogg Vorbis, True Audio, WavPack, OptimFROG, and AIFF audio files.
PY_MUTAGEN_SECTION=misc
PY_MUTAGEN_PRIORITY=optional
PY27_MUTAGEN_DEPENDS=python27
PY3_MUTAGEN_DEPENDS=python3
PY_MUTAGEN_CONFLICTS=

#
# PY_MUTAGEN_IPK_VERSION should be incremented when the ipk changes.
#
PY_MUTAGEN_IPK_VERSION=2

#
# PY_MUTAGEN_CONFFILES should be a list of user-editable files
#PY_MUTAGEN_CONFFILES=$(TARGET_PREFIX)/etc/py-mutagen.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-mutagen

#
# PY_MUTAGEN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY_MUTAGEN_PATCHES=$(PY_MUTAGEN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY_MUTAGEN_CPPFLAGS=
PY_MUTAGEN_LDFLAGS=

#
# PY_MUTAGEN_BUILD_DIR is the directory in which the build is done.
# PY_MUTAGEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY_MUTAGEN_IPK_DIR is the directory in which the ipk is built.
# PY_MUTAGEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY_MUTAGEN_BUILD_DIR=$(BUILD_DIR)/py-mutagen
PY_MUTAGEN_SOURCE_DIR=$(SOURCE_DIR)/py-mutagen

PY27_MUTAGEN_IPK_DIR=$(BUILD_DIR)/py27-mutagen-$(PY_MUTAGEN_VERSION)-ipk
PY27_MUTAGEN_IPK=$(BUILD_DIR)/py27-mutagen_$(PY_MUTAGEN_VERSION)-$(PY_MUTAGEN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3_MUTAGEN_IPK_DIR=$(BUILD_DIR)/py3-mutagen-$(PY_MUTAGEN_VERSION)-ipk
PY3_MUTAGEN_IPK=$(BUILD_DIR)/py3-mutagen_$(PY_MUTAGEN_VERSION)-$(PY_MUTAGEN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mutagen-source py-mutagen-unpack py-mutagen py-mutagen-stage py-mutagen-ipk py-mutagen-clean py-mutagen-dirclean py-mutagen-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY_MUTAGEN_SOURCE):
	$(WGET) -P $(@D) $(PY_MUTAGEN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mutagen-source: $(DL_DIR)/$(PY_MUTAGEN_SOURCE) $(PY_MUTAGEN_PATCHES)

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
$(PY_MUTAGEN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY_MUTAGEN_SOURCE) $(PY_MUTAGEN_PATCHES) make/py-mutagen.mk
	$(MAKE) python27-host-stage python3-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY_MUTAGEN_DIR) $(@D)
	mkdir -p $(@D)
	$(PY_MUTAGEN_UNZIP) $(DL_DIR)/$(PY_MUTAGEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY_MUTAGEN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY_MUTAGEN_DIR) -p1
	mv $(BUILD_DIR)/$(PY_MUTAGEN_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY_MUTAGEN_UNZIP) $(DL_DIR)/$(PY_MUTAGEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY_MUTAGEN_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY_MUTAGEN_DIR) -p1
	mv $(BUILD_DIR)/$(PY_MUTAGEN_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-mutagen-unpack: $(PY_MUTAGEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY_MUTAGEN_BUILD_DIR)/.built: $(PY_MUTAGEN_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-mutagen: $(PY_MUTAGEN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY_MUTAGEN_BUILD_DIR)/.staged: $(PY_MUTAGEN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY_MUTAGEN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-mutagen-stage: $(PY_MUTAGEN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mutagen
#
$(PY27_MUTAGEN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-mutagen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY_MUTAGEN_PRIORITY)" >>$@
	@echo "Section: $(PY_MUTAGEN_SECTION)" >>$@
	@echo "Version: $(PY_MUTAGEN_VERSION)-$(PY_MUTAGEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY_MUTAGEN_MAINTAINER)" >>$@
	@echo "Source: $(PY_MUTAGEN_SITE)/$(PY_MUTAGEN_SOURCE)" >>$@
	@echo "Description: $(PY_MUTAGEN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27_MUTAGEN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY_MUTAGEN_CONFLICTS)" >>$@

$(PY3_MUTAGEN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-mutagen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY_MUTAGEN_PRIORITY)" >>$@
	@echo "Section: $(PY_MUTAGEN_SECTION)" >>$@
	@echo "Version: $(PY_MUTAGEN_VERSION)-$(PY_MUTAGEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY_MUTAGEN_MAINTAINER)" >>$@
	@echo "Source: $(PY_MUTAGEN_SITE)/$(PY_MUTAGEN_SOURCE)" >>$@
	@echo "Description: $(PY_MUTAGEN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3_MUTAGEN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY_MUTAGEN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/etc/py-mutagen/...
# Documentation files should be installed in $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/doc/py-mutagen/...
# Daemon startup scripts should be installed in $(PY_MUTAGEN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-mutagen
#
# You may need to patch your application to make it use these locations.
#
$(PY27_MUTAGEN_IPK): $(PY_MUTAGEN_BUILD_DIR)/.built
	rm -rf $(PY27_MUTAGEN_IPK_DIR) $(BUILD_DIR)/py27-mutagen_*_$(TARGET_ARCH).ipk
	(cd $(PY_MUTAGEN_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27_MUTAGEN_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27_MUTAGEN_IPK_DIR)/CONTROL/control
	echo $(PY_MUTAGEN_CONFFILES) | sed -e 's/ /\n/g' > $(PY27_MUTAGEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27_MUTAGEN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY27_MUTAGEN_IPK_DIR)

$(PY3_MUTAGEN_IPK): $(PY_MUTAGEN_BUILD_DIR)/.built
	rm -rf $(PY3_MUTAGEN_IPK_DIR) $(BUILD_DIR)/py3-mutagen_*_$(TARGET_ARCH).ipk
	(cd $(PY_MUTAGEN_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3_MUTAGEN_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3_MUTAGEN_IPK_DIR)/CONTROL/control
	echo $(PY_MUTAGEN_CONFFILES) | sed -e 's/ /\n/g' > $(PY3_MUTAGEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3_MUTAGEN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY3_MUTAGEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mutagen-ipk: $(PY27_MUTAGEN_IPK) $(PY3_MUTAGEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mutagen-clean:
	-$(MAKE) -C $(PY_MUTAGEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mutagen-dirclean:
	rm -rf $(BUILD_DIR)/$(PY_MUTAGEN_DIR) $(PY_MUTAGEN_BUILD_DIR) \
	$(PY27_MUTAGEN_IPK_DIR) $(PY27_MUTAGEN_IPK) \
	$(PY3_MUTAGEN_IPK_DIR) $(PY3_MUTAGEN_IPK) \

#
# Some sanity check for the package.
#
py-mutagen-check: $(PY27_MUTAGEN_IPK) $(PY3_MUTAGEN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
