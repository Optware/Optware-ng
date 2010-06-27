###########################################################
#
# wizd
#
###########################################################

# You must replace "wizd" and "WIZD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WIZD_VERSION, WIZD_SITE and WIZD_SOURCE define
# the upstream location of the source code for the package.
# WIZD_DIR is the directory which is created when the source
# archive is unpacked.
# WIZD_UNZIP is the command used to unzip the source.
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
#WIZD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/wizd
WIZD_VERSION=0_12h_pvb_24
WIZD_SOURCE=wizd_$(WIZD_VERSION).tar.gz
WIZD_REPOSITORY=:pserver:anonymous@wizd.cvs.sf.net:/cvsroot/wizd
# WIZD_TAG=-r v$(WIZD_VERSION)
WIZD_TAG=-D 20061110
WIZD_MODULE=wizd
WIZD_DIR=wizd_$(WIZD_VERSION)
WIZD_UNZIP=zcat
WIZD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WIZD_DESCRIPTION=Mediaserver program for IO-DATA and other players
WIZD_SECTION=net
WIZD_PRIORITY=optional
WIZD_DEPENDS=libdvdread, libjpeg
WIZD_SUGGESTS=
WIZD_CONFLICTS=

#
# WIZD_IPK_VERSION should be incremented when the ipk changes.
#
WIZD_IPK_VERSION=2

#
# WIZD_CONFFILES should be a list of user-editable files
WIZD_CONFFILES=/opt/etc/wizd.conf

#
# WIZD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WIZD_PATCHES= \
	$(WIZD_SOURCE_DIR)/wizd.h.patch \
	$(WIZD_SOURCE_DIR)/Makefile.patch \
	$(WIZD_SOURCE_DIR)/wizd_http.c.patch \
	$(WIZD_SOURCE_DIR)/wizd_menu.c.patch \
	$(WIZD_SOURCE_DIR)/wizd_mp3.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WIZD_CPPFLAGS=-I$(STAGING_INCLUDE_DIR) -I$(STAGING_INCLUDE_DIR)/ncurses
WIZD_LDFLAGS=-lm

#
# WIZD_BUILD_DIR is the directory in which the build is done.
# WIZD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WIZD_IPK_DIR is the directory in which the ipk is built.
# WIZD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WIZD_BUILD_DIR=$(BUILD_DIR)/wizd
WIZD_SOURCE_DIR=$(SOURCE_DIR)/wizd
WIZD_IPK_DIR=$(BUILD_DIR)/wizd-$(WIZD_VERSION)-ipk
WIZD_IPK=$(BUILD_DIR)/wizd_$(WIZD_VERSION)-$(WIZD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wizd-source wizd-unpack wizd wizd-stage wizd-ipk wizd-clean wizd-dirclean wizd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WIZD_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(WIZD_REPOSITORY) co $(WIZD_TAG) $(WIZD_MODULE)
	cd $(DL_DIR) ; $(CVS) -d $(WIZD_REPOSITORY) co skin
	mv $(DL_DIR)/$(WIZD_MODULE) $(DL_DIR)/$(WIZD_DIR)
	mv $(DL_DIR)/skin $(DL_DIR)/$(WIZD_DIR)
	cd $(DL_DIR) ; tar zcvf $(WIZD_SOURCE) $(WIZD_DIR)
	rm -rf $(DL_DIR)/$(WIZD_DIR)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wizd-source: $(DL_DIR)/$(WIZD_SOURCE) $(WIZD_PATCHES)

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
$(WIZD_BUILD_DIR)/.configured: $(DL_DIR)/$(WIZD_SOURCE) $(WIZD_PATCHES)
	$(MAKE) libdvdread-stage libjpeg-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(WIZD_DIR) $(WIZD_BUILD_DIR)
	$(WIZD_UNZIP) $(DL_DIR)/$(WIZD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	sed -i -e 's/\r//' $(BUILD_DIR)/$(WIZD_DIR)/wizd.conf
	mv $(BUILD_DIR)/$(WIZD_DIR)/makefile $(BUILD_DIR)/$(WIZD_DIR)/Makefile
	cat $(WIZD_PATCHES) | patch -d $(BUILD_DIR)/$(WIZD_DIR) -p1
	mv $(BUILD_DIR)/$(WIZD_DIR) $(WIZD_BUILD_DIR)
	touch $(WIZD_BUILD_DIR)/.configured

wizd-unpack: $(WIZD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WIZD_BUILD_DIR)/.built: $(WIZD_BUILD_DIR)/.configured
	rm -f $(WIZD_BUILD_DIR)/.built
	sed -i "s#-I/usr/local/include#$(WIZD_CPPFLAGS)#g" $(WIZD_BUILD_DIR)/Makefile
	sed -i "s#/usr/local#${STAGING_DIR}/opt#g" $(WIZD_BUILD_DIR)/Makefile 
	sed -i "s/-static //" $(WIZD_BUILD_DIR)/Makefile
	CPPFLAGS="$(STAGING_CPPFLAGS) $(WIZD_CPPFLAGS)" \
       LDFLAGS="$(STAGING_LDFLAGS) $(WIZD_LDFLAGS)" \
	$(MAKE) -C $(WIZD_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
	touch $(WIZD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
wizd: $(WIZD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WIZD_BUILD_DIR)/.staged: $(WIZD_BUILD_DIR)/.built
#	rm -f $(WIZD_BUILD_DIR)/.staged
#	$(MAKE) -C $(WIZD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WIZD_BUILD_DIR)/.staged

wizd-stage: $(WIZD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wizd
#
$(WIZD_IPK_DIR)/CONTROL/control:
	@install -d $(WIZD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: wizd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WIZD_PRIORITY)" >>$@
	@echo "Section: $(WIZD_SECTION)" >>$@
	@echo "Version: $(WIZD_VERSION)-$(WIZD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WIZD_MAINTAINER)" >>$@
	@echo "Source: $(WIZD_SITE)/$(WIZD_SOURCE)" >>$@
	@echo "Description: $(WIZD_DESCRIPTION)" >>$@
	@echo "Depends: $(WIZD_DEPENDS)" >>$@
	@echo "Suggests: $(WIZD_SUGGESTS)" >>$@
	@echo "Conflicts: $(WIZD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WIZD_IPK_DIR)/opt/sbin or $(WIZD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WIZD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WIZD_IPK_DIR)/opt/etc/wizd/...
# Documentation files should be installed in $(WIZD_IPK_DIR)/opt/doc/wizd/...
# Daemon startup scripts should be installed in $(WIZD_IPK_DIR)/opt/etc/init.d/S??wizd
#
# You may need to patch your application to make it use these locations.
#
$(WIZD_IPK): $(WIZD_BUILD_DIR)/.built
	rm -rf $(WIZD_IPK_DIR) $(BUILD_DIR)/wizd_*_$(TARGET_ARCH).ipk
	install -d $(WIZD_IPK_DIR)/opt/sbin/
	install -m 755 $(WIZD_BUILD_DIR)/wizd $(WIZD_IPK_DIR)/opt/sbin/wizd
	install -d $(WIZD_IPK_DIR)/opt/etc/
	install -m 644 $(WIZD_SOURCE_DIR)/wizd.conf $(WIZD_IPK_DIR)/opt/etc/wizd.conf
	install -d $(WIZD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(WIZD_SOURCE_DIR)/rc.wizd $(WIZD_IPK_DIR)/opt/etc/init.d/S84wizd
	install -d $(WIZD_IPK_DIR)/opt/share/wizd
	#cp -rip $(WIZD_BUILD_DIR)/docroot $(WIZD_IPK_DIR)/opt/share/wizd
	install -d $(WIZD_IPK_DIR)/opt/share/wizd/docroot
	cp -rip $(WIZD_BUILD_DIR)/skin $(WIZD_IPK_DIR)/opt/share/wizd
	$(MAKE) $(WIZD_IPK_DIR)/CONTROL/control
	install -m 755 $(WIZD_SOURCE_DIR)/postinst $(WIZD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(WIZD_SOURCE_DIR)/prerm $(WIZD_IPK_DIR)/CONTROL/prerm
	echo $(WIZD_CONFFILES) | sed -e 's/ /\n/g' > $(WIZD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WIZD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wizd-ipk: $(WIZD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wizd-clean:
	rm -f $(WIZD_BUILD_DIR)/.built
	-$(MAKE) -C $(WIZD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wizd-dirclean:
	rm -rf $(BUILD_DIR)/$(WIZD_DIR) $(WIZD_BUILD_DIR) $(WIZD_IPK_DIR) $(WIZD_IPK)
#
#
# Some sanity check for the package.
#
wizd-check: $(WIZD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
