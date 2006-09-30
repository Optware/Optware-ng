###########################################################
#
# getmail
#
###########################################################

#
# GETMAIL_VERSION, GETMAIL_SITE and GETMAIL_SOURCE define
# the upstream location of the source code for the package.
# GETMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# GETMAIL_UNZIP is the command used to unzip the source.
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
GETMAIL_SITE=http://pyropus.ca/software/getmail/old-versions
GETMAIL_VERSION=4.6.4
GETMAIL_SOURCE=getmail-$(GETMAIL_VERSION).tar.gz
GETMAIL_DIR=getmail-$(GETMAIL_VERSION)
GETMAIL_UNZIP=zcat
GETMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GETMAIL_DESCRIPTION=getmail is a mail retriever designed to allow you to get your mail from one or more mail accounts on various mail servers to your local machine.
GETMAIL_SECTION=mail
GETMAIL_PRIORITY=optional
GETMAIL_DEPENDS=python
GETMAIL_SUGGESTS=
GETMAIL_CONFLICTS=

#
# GETMAIL_IPK_VERSION should be incremented when the ipk changes.
#
GETMAIL_IPK_VERSION=1

#
# GETMAIL_CONFFILES should be a list of user-editable files
#GETMAIL_CONFFILES=/opt/etc/getmail.conf /opt/etc/init.d/SXXgetmail

#
# GETMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GETMAIL_PATCHES=$(GETMAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GETMAIL_CPPFLAGS=
GETMAIL_LDFLAGS=

#
# GETMAIL_BUILD_DIR is the directory in which the build is done.
# GETMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GETMAIL_IPK_DIR is the directory in which the ipk is built.
# GETMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GETMAIL_BUILD_DIR=$(BUILD_DIR)/getmail
GETMAIL_SOURCE_DIR=$(SOURCE_DIR)/getmail
GETMAIL_IPK_DIR=$(BUILD_DIR)/getmail-$(GETMAIL_VERSION)-ipk
GETMAIL_IPK=$(BUILD_DIR)/getmail_$(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GETMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(GETMAIL_SITE)/$(GETMAIL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
getmail-source: $(DL_DIR)/$(GETMAIL_SOURCE) $(GETMAIL_PATCHES)

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
$(GETMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(GETMAIL_SOURCE) $(GETMAIL_PATCHES)
	rm -rf $(BUILD_DIR)/$(GETMAIL_DIR) $(GETMAIL_BUILD_DIR)
	$(GETMAIL_UNZIP) $(DL_DIR)/$(GETMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GETMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(GETMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(GETMAIL_DIR) $(GETMAIL_BUILD_DIR)
	(cd $(GETMAIL_BUILD_DIR); \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) >> setup.cfg; \
	)
	touch $(GETMAIL_BUILD_DIR)/.configured

getmail-unpack: $(GETMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GETMAIL_BUILD_DIR)/.built: $(GETMAIL_BUILD_DIR)/.configured
	rm -f $(GETMAIL_BUILD_DIR)/.built
	(cd $(GETMAIL_BUILD_DIR); \
	    python2.4 setup.py build; \
	)
	touch $(GETMAIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
getmail: $(GETMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GETMAIL_BUILD_DIR)/.staged: $(GETMAIL_BUILD_DIR)/.built
	rm -f $(GETMAIL_BUILD_DIR)/.staged
	#$(MAKE) -C $(GETMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GETMAIL_BUILD_DIR)/.staged

getmail-stage: $(GETMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/getmail
#
$(GETMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(GETMAIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: getmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GETMAIL_PRIORITY)" >>$@
	@echo "Section: $(GETMAIL_SECTION)" >>$@
	@echo "Version: $(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GETMAIL_MAINTAINER)" >>$@
	@echo "Source: $(GETMAIL_SITE)/$(GETMAIL_SOURCE)" >>$@
	@echo "Description: $(GETMAIL_DESCRIPTION)" >>$@
	@echo "Depends: $(GETMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(GETMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(GETMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GETMAIL_IPK_DIR)/opt/sbin or $(GETMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GETMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GETMAIL_IPK_DIR)/opt/etc/getmail/...
# Documentation files should be installed in $(GETMAIL_IPK_DIR)/opt/doc/getmail/...
# Daemon startup scripts should be installed in $(GETMAIL_IPK_DIR)/opt/etc/init.d/S??getmail
#
# You may need to patch your application to make it use these locations.
#
$(GETMAIL_IPK): $(GETMAIL_BUILD_DIR)/.built
	rm -rf $(GETMAIL_IPK_DIR) $(BUILD_DIR)/getmail_*_$(TARGET_ARCH).ipk
	(cd $(GETMAIL_BUILD_DIR); \
	    python2.4 setup.py install --prefix=$(GETMAIL_IPK_DIR)/opt; \
	)
#	install -d $(GETMAIL_IPK_DIR)/opt/etc/
#	install -m 644 $(GETMAIL_SOURCE_DIR)/getmail.conf $(GETMAIL_IPK_DIR)/opt/etc/getmail.conf
#	install -d $(GETMAIL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GETMAIL_SOURCE_DIR)/rc.getmail $(GETMAIL_IPK_DIR)/opt/etc/init.d/SXXgetmail
	$(MAKE) $(GETMAIL_IPK_DIR)/CONTROL/control
#	install -m 755 $(GETMAIL_SOURCE_DIR)/postinst $(GETMAIL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GETMAIL_SOURCE_DIR)/prerm $(GETMAIL_IPK_DIR)/CONTROL/prerm
#	echo $(GETMAIL_CONFFILES) | sed -e 's/ /\n/g' > $(GETMAIL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GETMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
getmail-ipk: $(GETMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
getmail-clean:
	-$(MAKE) -C $(GETMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
getmail-dirclean:
	rm -rf $(BUILD_DIR)/$(GETMAIL_DIR) $(GETMAIL_BUILD_DIR) $(GETMAIL_IPK_DIR) $(GETMAIL_IPK)
