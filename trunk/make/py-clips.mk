###########################################################
#
# py-clips
#
###########################################################

#
# PY-CLIPS_VERSION, PY-CLIPS_SITE and PY-CLIPS_SOURCE define
# the upstream location of the source code for the package.
# PY-CLIPS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CLIPS_UNZIP is the command used to unzip the source.
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
PY-CLIPS_SITE=http://dl.sourceforge.net/sourceforge/pyclips
PY-CLIPS_VERSION=1.0_R3
PY-CLIPS_SOURCE=pyclips-$(PY-CLIPS_VERSION).tar.gz
PY-CLIPS_CLIPS_SITE=http://www.ghg.net/clips/download/source
PY-CLIPS_CLIPS_SOURCE=CLIPSSrc.zip
PY-CLIPS_DIR=pyclips
PY-CLIPS_UNZIP=zcat
PY-CLIPS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-CLIPS_DESCRIPTION=PyCLIPS is an extension module that embeds full CLIPS functionality in Python applications.
PY-CLIPS_SECTION=misc
PY-CLIPS_PRIORITY=optional
PY-CLIPS_DEPENDS=python
PY-CLIPS_SUGGESTS=
PY-CLIPS_CONFLICTS=

#
# PY-CLIPS_IPK_VERSION should be incremented when the ipk changes.
#
PY-CLIPS_IPK_VERSION=1

#
# PY-CLIPS_CONFFILES should be a list of user-editable files
#PY-CLIPS_CONFFILES=/opt/etc/py-clips.conf /opt/etc/init.d/SXXpy-clips

#
# PY-CLIPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CLIPS_PATCHES=$(PY-CLIPS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CLIPS_CPPFLAGS=
PY-CLIPS_LDFLAGS=

#
# PY-CLIPS_BUILD_DIR is the directory in which the build is done.
# PY-CLIPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CLIPS_IPK_DIR is the directory in which the ipk is built.
# PY-CLIPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CLIPS_BUILD_DIR=$(BUILD_DIR)/py-clips
PY-CLIPS_SOURCE_DIR=$(SOURCE_DIR)/py-clips
PY-CLIPS_IPK_DIR=$(BUILD_DIR)/py-clips-$(PY-CLIPS_VERSION)-ipk
PY-CLIPS_IPK=$(BUILD_DIR)/py-clips_$(PY-CLIPS_VERSION)-$(PY-CLIPS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CLIPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CLIPS_SITE)/$(PY-CLIPS_SOURCE)

$(DL_DIR)/$(PY-CLIPS_CLIPS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CLIPS_CLIPS_SITE)/$(PY-CLIPS_CLIPS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-clips-source: $(DL_DIR)/$(PY-CLIPS_SOURCE) $(DL_DIR)/$(PY-CLIPS_CLIPS_SOURCE) $(PY-CLIPS_PATCHES)

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
$(PY-CLIPS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CLIPS_SOURCE) $(DL_DIR)/$(PY-CLIPS_CLIPS_SOURCE) $(PY-CLIPS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-CLIPS_DIR) $(PY-CLIPS_BUILD_DIR)
	$(PY-CLIPS_UNZIP) $(DL_DIR)/$(PY-CLIPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-CLIPS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CLIPS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CLIPS_DIR) $(PY-CLIPS_BUILD_DIR)
	(cd $(PY-CLIPS_BUILD_DIR); \
	    ( \
		echo ; \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_DIR)/opt/include:$(STAGING_DIR)/opt/include/python2.4"; \
		echo "library-dirs=$(STAGING_DIR)/opt/lib"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) >> setup.cfg; \
	    cp $(DL_DIR)/$(PY-CLIPS_CLIPS_SOURCE) . \
	)
	touch $(PY-CLIPS_BUILD_DIR)/.configured

py-clips-unpack: $(PY-CLIPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CLIPS_BUILD_DIR)/.built: $(PY-CLIPS_BUILD_DIR)/.configured
	rm -f $(PY-CLIPS_BUILD_DIR)/.built
	(cd $(PY-CLIPS_BUILD_DIR); \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            python2.4 setup.py build; \
        )
	touch $(PY-CLIPS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-clips: $(PY-CLIPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CLIPS_BUILD_DIR)/.staged: $(PY-CLIPS_BUILD_DIR)/.built
	rm -f $(PY-CLIPS_BUILD_DIR)/.staged
	$(MAKE) -C $(PY-CLIPS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CLIPS_BUILD_DIR)/.staged

py-clips-stage: $(PY-CLIPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-clips
#
$(PY-CLIPS_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CLIPS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-clips" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CLIPS_PRIORITY)" >>$@
	@echo "Section: $(PY-CLIPS_SECTION)" >>$@
	@echo "Version: $(PY-CLIPS_VERSION)-$(PY-CLIPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CLIPS_MAINTAINER)" >>$@
	@echo "Source: $(PY-CLIPS_SITE)/$(PY-CLIPS_SOURCE)" >>$@
	@echo "Description: $(PY-CLIPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CLIPS_DEPENDS)" >>$@
	@echo "Suggests: $(PY-CLIPS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-CLIPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CLIPS_IPK_DIR)/opt/sbin or $(PY-CLIPS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CLIPS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CLIPS_IPK_DIR)/opt/etc/py-clips/...
# Documentation files should be installed in $(PY-CLIPS_IPK_DIR)/opt/doc/py-clips/...
# Daemon startup scripts should be installed in $(PY-CLIPS_IPK_DIR)/opt/etc/init.d/S??py-clips
#
# You may need to patch your application to make it use these locations.
#
$(PY-CLIPS_IPK): $(PY-CLIPS_BUILD_DIR)/.built
	rm -rf $(PY-CLIPS_IPK_DIR) $(BUILD_DIR)/py-clips_*_$(TARGET_ARCH).ipk
	(cd $(PY-CLIPS_BUILD_DIR); \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            python2.4 setup.py install --prefix=$(PY-CLIPS_IPK_DIR)/opt; \
        )
	$(STRIP_COMMAND) $(PY-CLIPS_IPK_DIR)/opt/lib/python2.4/site-packages/clips/_clips.so
	$(MAKE) $(PY-CLIPS_IPK_DIR)/CONTROL/control
	#install -m 755 $(PY-CLIPS_SOURCE_DIR)/postinst $(PY-CLIPS_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(PY-CLIPS_SOURCE_DIR)/prerm $(PY-CLIPS_IPK_DIR)/CONTROL/prerm
	#echo $(PY-CLIPS_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CLIPS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CLIPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-clips-ipk: $(PY-CLIPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-clips-clean:
	-$(MAKE) -C $(PY-CLIPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-clips-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CLIPS_DIR) $(PY-CLIPS_BUILD_DIR) $(PY-CLIPS_IPK_DIR) $(PY-CLIPS_IPK)
