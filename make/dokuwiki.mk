###########################################################
#
# dokuwiki
#
###########################################################

# You must replace "dokuwiki" and "DOKUWIKI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# DOKUWIKI_VERSION, DOKUWIKI_SITE and DOKUWIKI_SOURCE define
# the upstream location of the source code for the package.
# DOKUWIKI_DIR is the directory which is created when the source
# archive is unpacked.
# DOKUWIKI_UNZIP is the command used to unzip the source.
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
DOKUWIKI_SITE=http://www.splitbrain.org/_media/projects/dokuwiki
DOKUWIKI_VERSION=2009-02-14
DOKUWIKI_SOURCE=dokuwiki-$(DOKUWIKI_VERSION).tgz
DOKUWIKI_DIR=dokuwiki-$(DOKUWIKI_VERSION)
DOKUWIKI_UNZIP=zcat
DOKUWIKI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DOKUWIKI_DESCRIPTION=DokuWiki is a standards compliant, simple to use Wiki
DOKUWIKI_SECTION=web
DOKUWIKI_PRIORITY=optional
DOKUWIKI_DEPENDS=
DOKUWIKI_SUGGESTS=
DOKUWIKI_CONFLICTS=

#
# DOKUWIKI_IPK_VERSION should be incremented when the ipk changes.
#
DOKUWIKI_IPK_VERSION=1

#
# DOKUWIKI_CONFFILES should be a list of user-editable files
#DOKUWIKI_CONFFILES=/opt/etc/dokuwiki.conf /opt/etc/init.d/SXXdokuwiki

#
# DOKUWIKI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DOKUWIKI_PATCHES=$(DOKUWIKI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DOKUWIKI_CPPFLAGS=
DOKUWIKI_LDFLAGS=

#
# DOKUWIKI_BUILD_DIR is the directory in which the build is done.
# DOKUWIKI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DOKUWIKI_IPK_DIR is the directory in which the ipk is built.
# DOKUWIKI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DOKUWIKI_BUILD_DIR=$(BUILD_DIR)/dokuwiki
DOKUWIKI_SOURCE_DIR=$(SOURCE_DIR)/dokuwiki
DOKUWIKI_IPK_DIR=$(BUILD_DIR)/dokuwiki-$(DOKUWIKI_VERSION)-ipk
DOKUWIKI_IPK=$(BUILD_DIR)/dokuwiki_$(DOKUWIKI_VERSION)-$(DOKUWIKI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DOKUWIKI_SOURCE):
	$(WGET) -P $(@D) $(DOKUWIKI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dokuwiki-source: $(DL_DIR)/$(DOKUWIKI_SOURCE) $(DOKUWIKI_PATCHES)

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
$(DOKUWIKI_BUILD_DIR)/.configured: $(DL_DIR)/$(DOKUWIKI_SOURCE) $(DOKUWIKI_PATCHES)
	rm -rf $(BUILD_DIR)/$(DOKUWIKI_DIR) $(DOKUWIKI_BUILD_DIR)
	$(DOKUWIKI_UNZIP) $(DL_DIR)/$(DOKUWIKI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DOKUWIKI_DIR) $(@D)
	touch $@

dokuwiki-unpack: $(DOKUWIKI_BUILD_DIR)/.configured

#
# This is the build convenience target.
#
dokuwiki: $(DOKUWIKI_BUILD_DIR)/.configured

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dokuwiki
#
$(DOKUWIKI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dokuwiki" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOKUWIKI_PRIORITY)" >>$@
	@echo "Section: $(DOKUWIKI_SECTION)" >>$@
	@echo "Version: $(DOKUWIKI_VERSION)-$(DOKUWIKI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOKUWIKI_MAINTAINER)" >>$@
	@echo "Source: $(DOKUWIKI_SITE)/$(DOKUWIKI_SOURCE)" >>$@
	@echo "Description: $(DOKUWIKI_DESCRIPTION)" >>$@
	@echo "Depends: $(DOKUWIKI_DEPENDS)" >>$@
	@echo "Suggests: $(DOKUWIKI_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOKUWIKI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DOKUWIKI_IPK_DIR)/opt/sbin or $(DOKUWIKI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DOKUWIKI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DOKUWIKI_IPK_DIR)/opt/etc/dokuwiki/...
# Documentation files should be installed in $(DOKUWIKI_IPK_DIR)/opt/doc/dokuwiki/...
# Daemon startup scripts should be installed in $(DOKUWIKI_IPK_DIR)/opt/etc/init.d/S??dokuwiki
#
# You may need to patch your application to make it use these locations.
#
$(DOKUWIKI_IPK): $(DOKUWIKI_BUILD_DIR)/.configured
	rm -rf $(DOKUWIKI_IPK_DIR) $(BUILD_DIR)/dokuwiki_*_$(TARGET_ARCH).ipk
	install -d $(DOKUWIKI_IPK_DIR)/opt/share/www/dokuwiki/data/changes.log
	cp -a $(DOKUWIKI_BUILD_DIR)/* $(DOKUWIKI_IPK_DIR)/opt/share/www/dokuwiki	
	$(MAKE) $(DOKUWIKI_IPK_DIR)/CONTROL/control
	install -m 755 $(DOKUWIKI_SOURCE_DIR)/postinst $(DOKUWIKI_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(DOKUWIKI_SOURCE_DIR)/prerm $(DOKUWIKI_IPK_DIR)/CONTROL/prerm
	#echo $(DOKUWIKI_CONFFILES) | sed -e 's/ /\n/g' > $(DOKUWIKI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOKUWIKI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dokuwiki-ipk: $(DOKUWIKI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dokuwiki-clean:
	-$(MAKE) -C $(DOKUWIKI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dokuwiki-dirclean:
	rm -rf $(BUILD_DIR)/$(DOKUWIKI_DIR) $(DOKUWIKI_BUILD_DIR) $(DOKUWIKI_IPK_DIR) $(DOKUWIKI_IPK)
