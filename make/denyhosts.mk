###########################################################
#
# denyhosts
#
###########################################################
#
DENYHOSTS_SITE=http://dl.sourceforge.net/sourceforge/denyhosts
DENYHOSTS_VERSION=1.1.2
DENYHOSTS_SOURCE=DenyHosts-$(DENYHOSTS_VERSION).tar.gz
DENYHOSTS_DIR=DenyHosts-$(DENYHOSTS_VERSION)
DENYHOSTS_UNZIP=zcat
DENYHOSTS_MAINTAINER=Don Lubinski <nlsu2@shine-hs.com>
DENYHOSTS_DESCRIPTION=DenyHosts is a script intended to be run by Linux system administrators to help thwart ssh server attacks. If you've ever looked at your ssh log (/var/log/secure on Redhat, /var/log/auth.log on Mandrake, etc...) you may be alarmed to see how many hackers attempted to gain access to your server. Hopefully, none of them were successful (but then again, how would you know?). Wouldn't it be better to automatically prevent that attacker from continuing to gain entry into your system?  DenyHosts attempts to address the above... and more. 
DENYHOSTS_SECTION= Security
DENYHOSTS_PRIORITY=optional
DENYHOSTS_DEPENDS=python
DENYHOSTS_SUGGESTS=
DENYHOSTS_CONFLICTS=

#
# DENYHOSTS_IPK_VERSION should be incremented when the ipk changes.
#
DENYHOSTS_IPK_VERSION=1

#
# DENYHOSTS_CONFFILES should be a list of user-editable files
DENYHOSTS_CONFFILES=/opt/etc/denyhosts.cfg /opt/etc/init.d/S01denyhosts


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DENYHOSTS_CPPFLAGS=
DENYHOSTS_LDFLAGS=
DENYHOSTS_CFLAGS=$(TARGET_CFLAGS) 

#
# DENYHOSTS_BUILD_DIR is the directory in which the build is done.
# DENYHOSTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DENYHOSTS_IPK_DIR is the directory in which the ipk is built.
# DENYHOSTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DENYHOSTS_BUILD_DIR=$(BUILD_DIR)/denyhosts
DENYHOSTS_SOURCE_DIR=$(SOURCE_DIR)/denyhosts
DENYHOSTS_IPK_DIR=$(BUILD_DIR)/denyhosts-$(DENYHOSTS_VERSION)-ipk
DENYHOSTS_IPK=$(BUILD_DIR)/denyhosts_$(DENYHOSTS_VERSION)-$(DENYHOSTS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DENYHOSTS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DENYHOSTS_SITE)/$(DENYHOSTS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
denyhosts-source: $(DL_DIR)/$(DENYHOSTS_SOURCE) 

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
#
$(DENYHOSTS_BUILD_DIR)/.configured: $(DL_DIR)/$(DENYHOSTS_SOURCE) 
	rm -rf $(BUILD_DIR)/$(DENYHOSTS_DIR) $(DENYHOSTS_BUILD_DIR)
	$(DENYHOSTS_UNZIP) $(DL_DIR)/$(DENYHOSTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(DENYHOSTS_DIR)" != "$(DENYHOSTS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DENYHOSTS_DIR) $(DENYHOSTS_BUILD_DIR) ; \
	fi
	touch $(DENYHOSTS_BUILD_DIR)/.configured

denyhosts-unpack: $(DENYHOSTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DENYHOSTS_BUILD_DIR)/.built: $(DENYHOSTS_BUILD_DIR)/.configured
	touch $(DENYHOSTS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
denyhosts: $(DENYHOSTS_BUILD_DIR)/.built


# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/denyhosts
#
$(DENYHOSTS_IPK_DIR)/CONTROL/control:
	@install -d $(DENYHOSTS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: denyhosts" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DENYHOSTS_PRIORITY)" >>$@
	@echo "Section: $(DENYHOSTS_SECTION)" >>$@
	@echo "Version: $(DENYHOSTS_VERSION)-$(DENYHOSTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DENYHOSTS_MAINTAINER)" >>$@
	@echo "Source: $(DENYHOSTS_SITE)/$(DENYHOSTS_SOURCE)" >>$@
	@echo "Description: $(DENYHOSTS_DESCRIPTION)" >>$@
	@echo "Depends: $(DENYHOSTS_DEPENDS)" >>$@
	@echo "Suggests: $(DENYHOSTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(DENYHOSTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DENYHOSTS_IPK_DIR)/opt/sbin or $(DENYHOSTS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DENYHOSTS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DENYHOSTS_IPK_DIR)/opt/etc/denyhosts/...
# Documentation files should be installed in $(DENYHOSTS_IPK_DIR)/opt/doc/denyhosts/...
# Daemon startup scripts should be installed in $(DENYHOSTS_IPK_DIR)/opt/etc/init.d/S??denyhosts
#
# You may need to patch your application to make it use these locations.
#
$(DENYHOSTS_IPK): $(DENYHOSTS_BUILD_DIR)/.built
	rm -rf $(DENYHOSTS_IPK_DIR) $(BUILD_DIR)/denyhosts_*_$(TARGET_ARCH).ipk
	install -d $(DENYHOSTS_IPK_DIR)/var/lock/subsys
	install -d $(DENYHOSTS_IPK_DIR)/opt/etc/
	install -m 644 $(DENYHOSTS_BUILD_DIR)/denyhosts.cfg-dist $(DENYHOSTS_IPK_DIR)/opt/etc/denyhosts.cfg
	install -d $(DENYHOSTS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(DENYHOSTS_SOURCE_DIR)/rc.denyhosts $(DENYHOSTS_IPK_DIR)/opt/etc/init.d/S01denyhosts
	install -dv $(DENYHOSTS_IPK_DIR)/opt/var/lib/denyhosts
	cp -r $(DENYHOSTS_BUILD_DIR)/* $(DENYHOSTS_IPK_DIR)/opt/var/lib/denyhosts
	$(MAKE) $(DENYHOSTS_IPK_DIR)/CONTROL/control
	echo $(DENYHOSTS_CONFFILES) | sed -e 's/ /\n/g' > $(DENYHOSTS_IPK_DIR)/CONTROL/conffiles
	install -m 755 $(DENYHOSTS_SOURCE_DIR)/postinst $(DENYHOSTS_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DENYHOSTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
denyhosts-ipk: $(DENYHOSTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
denyhosts-clean:
	rm -f $(DENYHOSTS_BUILD_DIR)/.built
	-$(MAKE) -C $(DENYHOSTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
denyhosts-dirclean:
	rm -rf $(BUILD_DIR)/$(DENYHOSTS_DIR) $(DENYHOSTS_BUILD_DIR) $(DENYHOSTS_IPK_DIR) $(DENYHOSTS_IPK)
