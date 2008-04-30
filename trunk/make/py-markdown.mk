##########################################################
#
# py-markdown
#
###########################################################

#
# PY-MARKDOWN_VERSION, PY-MARKDOWN_SITE and PY-MARKDOWN_SOURCE define
# the upstream location of the source code for the package.
# PY-MARKDOWN_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MARKDOWN_UNZIP is the command used to unzip the source.
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
PY-MARKDOWN_SITE=http://pypi.python.org/packages/source/M/Markdown
PY-MARKDOWN_VERSION=1.7
PY-MARKDOWN_SOURCE=markdown-$(PY-MARKDOWN_VERSION).tar.gz
PY-MARKDOWN_DIR=markdown-$(PY-MARKDOWN_VERSION)
PY-MARKDOWN_UNZIP=zcat
PY-MARKDOWN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MARKDOWN_DESCRIPTION=Python implementation of Markdown, a text-to-HTML conversion tool for web writers.
PY-MARKDOWN_SECTION=text
PY-MARKDOWN_PRIORITY=optional
PY24-MARKDOWN_DEPENDS=python24
PY25-MARKDOWN_DEPENDS=python25
PY-MARKDOWN_CONFLICTS=

#
# PY-MARKDOWN_IPK_VERSION should be incremented when the ipk changes.
#
PY-MARKDOWN_IPK_VERSION=2

#
# PY-MARKDOWN_CONFFILES should be a list of user-editable files
#PY-MARKDOWN_CONFFILES=/opt/etc/py-markdown.conf /opt/etc/init.d/SXXpy-markdown

#
# PY-MARKDOWN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MARKDOWN_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MARKDOWN_CPPFLAGS=
PY-MARKDOWN_LDFLAGS=

#
# PY-MARKDOWN_BUILD_DIR is the directory in which the build is done.
# PY-MARKDOWN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MARKDOWN_IPK_DIR is the directory in which the ipk is built.
# PY-MARKDOWN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MARKDOWN_BUILD_DIR=$(BUILD_DIR)/py-markdown
PY-MARKDOWN_SOURCE_DIR=$(SOURCE_DIR)/py-markdown

PY24-MARKDOWN_IPK_DIR=$(BUILD_DIR)/py24-markdown-$(PY-MARKDOWN_VERSION)-ipk
PY24-MARKDOWN_IPK=$(BUILD_DIR)/py24-markdown_$(PY-MARKDOWN_VERSION)-$(PY-MARKDOWN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MARKDOWN_IPK_DIR=$(BUILD_DIR)/py25-markdown-$(PY-MARKDOWN_VERSION)-ipk
PY25-MARKDOWN_IPK=$(BUILD_DIR)/py25-markdown_$(PY-MARKDOWN_VERSION)-$(PY-MARKDOWN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-markdown-source py-markdown-unpack py-markdown py-markdown-stage py-markdown-ipk py-markdown-clean py-markdown-dirclean py-markdown-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MARKDOWN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MARKDOWN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-markdown-source: $(DL_DIR)/$(PY-MARKDOWN_SOURCE) $(PY-MARKDOWN_PATCHES)

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
$(PY-MARKDOWN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MARKDOWN_SOURCE) $(PY-MARKDOWN_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MARKDOWN_DIR)
	$(PY-MARKDOWN_UNZIP) $(DL_DIR)/$(PY-MARKDOWN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MARKDOWN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MARKDOWN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MARKDOWN_DIR) $(@D)/2.4
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.4") >> $(@D)/2.4/setup.cfg
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MARKDOWN_DIR)
	$(PY-MARKDOWN_UNZIP) $(DL_DIR)/$(PY-MARKDOWN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MARKDOWN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MARKDOWN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MARKDOWN_DIR) $(@D)/2.5
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.5") >> $(@D)/2.4/setup.cfg
	touch $@

py-markdown-unpack: $(PY-MARKDOWN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MARKDOWN_BUILD_DIR)/.built: $(PY-MARKDOWN_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build;
	cd $(@D)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build;
	touch $@

#
# This is the build convenience target.
#
py-markdown: $(PY-MARKDOWN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MARKDOWN_BUILD_DIR)/.staged: $(PY-MARKDOWN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-MARKDOWN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-markdown-stage: $(PY-MARKDOWN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-markdown
#
$(PY24-MARKDOWN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-markdown" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MARKDOWN_PRIORITY)" >>$@
	@echo "Section: $(PY-MARKDOWN_SECTION)" >>$@
	@echo "Version: $(PY-MARKDOWN_VERSION)-$(PY-MARKDOWN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MARKDOWN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MARKDOWN_SITE)/$(PY-MARKDOWN_SOURCE)" >>$@
	@echo "Description: $(PY-MARKDOWN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MARKDOWN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MARKDOWN_CONFLICTS)" >>$@

$(PY25-MARKDOWN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-markdown" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MARKDOWN_PRIORITY)" >>$@
	@echo "Section: $(PY-MARKDOWN_SECTION)" >>$@
	@echo "Version: $(PY-MARKDOWN_VERSION)-$(PY-MARKDOWN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MARKDOWN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MARKDOWN_SITE)/$(PY-MARKDOWN_SOURCE)" >>$@
	@echo "Description: $(PY-MARKDOWN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MARKDOWN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MARKDOWN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MARKDOWN_IPK_DIR)/opt/sbin or $(PY-MARKDOWN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MARKDOWN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MARKDOWN_IPK_DIR)/opt/etc/py-markdown/...
# Documentation files should be installed in $(PY-MARKDOWN_IPK_DIR)/opt/doc/py-markdown/...
# Daemon startup scripts should be installed in $(PY-MARKDOWN_IPK_DIR)/opt/etc/init.d/S??py-markdown
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MARKDOWN_IPK): $(PY-MARKDOWN_BUILD_DIR)/.built
	rm -rf $(PY24-MARKDOWN_IPK_DIR) $(BUILD_DIR)/py24-markdown_*_$(TARGET_ARCH).ipk
	cd $(PY-MARKDOWN_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MARKDOWN_IPK_DIR) --prefix=/opt;
#	for f in $(PY24-MARKDOWN_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-MARKDOWN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MARKDOWN_IPK_DIR)

$(PY25-MARKDOWN_IPK): $(PY-MARKDOWN_BUILD_DIR)/.built
	rm -rf $(PY25-MARKDOWN_IPK_DIR) $(BUILD_DIR)/py25-markdown_*_$(TARGET_ARCH).ipk
	cd $(PY-MARKDOWN_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MARKDOWN_IPK_DIR) --prefix=/opt;
#	cd $(PY25-MARKDOWN_IPK_DIR)/opt/share/markdown; \
	    tar --remove-files -cvzf underlay.tar.gz underlay; \
	    rm -rf underlay
	$(MAKE) $(PY25-MARKDOWN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MARKDOWN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-markdown-ipk: $(PY24-MARKDOWN_IPK) $(PY25-MARKDOWN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-markdown-clean:
	-$(MAKE) -C $(PY-MARKDOWN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-markdown-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MARKDOWN_DIR) $(PY-MARKDOWN_BUILD_DIR)
	rm -rf $(PY24-MARKDOWN_IPK_DIR) $(PY24-MARKDOWN_IPK)
	rm -rf $(PY25-MARKDOWN_IPK_DIR) $(PY25-MARKDOWN_IPK)

#
# Some sanity check for the package.
#
py-markdown-check: $(PY24-MARKDOWN_IPK) $(PY25-MARKDOWN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MARKDOWN_IPK) $(PY25-MARKDOWN_IPK)
