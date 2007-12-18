###########################################################
#
# ipkg-web
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#

IPKG_WEB_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
IPKG_WEB_DESCRIPTION=A web frontend for ipkg
IPKG_WEB_SECTION=web
IPKG_WEB_PRIORITY=optional
IPKG_WEB_DEPENDS=
IPKG_WEB_SUGGESTS=
IPKG_WEB_CONFLICTS=

#
# IPKG_WEB_IPK_VERSION should be incremented when the ipk changes.
#
IPKG_WEB_IPK_VERSION=7
#
# There is no external version!
#
IPKG_WEB_VERSION=$(IPKG_WEB_IPK_VERSION)

#
# IPKG_WEB_BUILD_DIR is the directory in which the build is done.
# IPKG_WEB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPKG_WEB_IPK_DIR is the directory in which the ipk is built.
# IPKG_WEB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG_WEB_BUILD_DIR=$(BUILD_DIR)/ipkg-web
IPKG_WEB_SOURCE_DIR=$(SOURCE_DIR)/ipkg-web
IPKG_WEB_IPK_DIR=$(BUILD_DIR)/ipkg-web-$(IPKG_WEB_VERSION)-ipk
IPKG_WEB_IPK=$(BUILD_DIR)/ipkg-web_$(IPKG_WEB_VERSION)-$(IPKG_WEB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# It's just one shell script in the source dir. We don't need to build anything.
#
ipkg-web:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipkg-web
#
$(IPKG_WEB_IPK_DIR)/CONTROL/control:
	@install -d $(IPKG_WEB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ipkg-web" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG_WEB_PRIORITY)" >>$@
	@echo "Section: $(IPKG_WEB_SECTION)" >>$@
	@echo "Version: $(IPKG_WEB_VERSION)-$(IPKG_WEB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG_WEB_MAINTAINER)" >>$@
	@echo "Source: $(IPKG_WEB_SITE)/$(IPKG_WEB_SOURCE)" >>$@
	@echo "Description: $(IPKG_WEB_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG_WEB_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG_WEB_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG_WEB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG_WEB_IPK_DIR)/opt/sbin or $(IPKG_WEB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG_WEB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPKG_WEB_IPK_DIR)/opt/etc/ipkg-web/...
# Documentation files should be installed in $(IPKG_WEB_IPK_DIR)/opt/doc/ipkg-web/...
# Daemon startup scripts should be installed in $(IPKG_WEB_IPK_DIR)/opt/etc/init.d/S??ipkg-web
#
# You may need to patch your application to make it use these locations.
#
$(IPKG_WEB_IPK): $(IPKG_WEB_SOURCE_DIR)/package.cgi
	rm -rf $(IPKG_WEB_IPK_DIR) $(BUILD_DIR)/ipkg-web_*_$(TARGET_ARCH).ipk
	install -d $(IPKG_WEB_IPK_DIR)/home/httpd/html/Management
	install -m 755 $(IPKG_WEB_SOURCE_DIR)/package.cgi $(IPKG_WEB_IPK_DIR)/home/httpd/html/Management/package.cgi
	install -m 755 $(IPKG_WEB_SOURCE_DIR)/sluginfo.cgi $(IPKG_WEB_IPK_DIR)/home/httpd/html/Management/sluginfo.cgi
	$(MAKE) $(IPKG_WEB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG_WEB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-web-ipk: $(IPKG_WEB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-web-clean:

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-web-dirclean:
	rm -rf $(IPKG_WEB_IPK_DIR) $(IPKG_WEB_IPK)
