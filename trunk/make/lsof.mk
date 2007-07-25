#############################################################
#
# lsof
#
#############################################################
#
# LSOF_VERSION, LSOF_SITE and LSOF_SOURCE define
# the upstream location of the source code for the package.
# LSOF_DIR is the directory which is created when the source
# archive is unpacked.
# LSOF_UNZIP is the command used to unzip the source.
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

LSOF_DIR:=$(BUILD_DIR)/lsof
LSOF_SOURCE_DIR:=$(SOURCE_DIR)/lsof
LSOF_VERSION:=4.77.dfsg.1
LSOF:=lsof-$(LSOF_VERSION).orig
LSOF_FILE:=lsof_$(LSOF_VERSION).orig
LSOF_DSC=lsof_$(LSOF_VERSION)-3.dsc
LSOF_SITE=http://http.us.debian.org/debian/pool/main/l/lsof
LSOF_SOURCE:=$(LSOF_FILE).tar.gz
LSOF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LSOF_DESCRIPTION=LiSt Open Files - a diagnostic tool.
LSOF_SECTION=admin
LSOF_PRIORITY=optional
LSOF_DEPENDS=
LSOF_SUGGESTS=
LSOF_CONFLICTS=


#
# LSOF_IPK_VERSION should be incremented when the ipk changes.
#
LSOF_IPK_VERSION=2

#
# LSOF_BUILD_DIR is the directory in which the build is done.
# LSOF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LSOF_IPK_DIR is the directory in which the ipk is built.
# LSOF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LSOF_IPK:=$(BUILD_DIR)/lsof_$(LSOF_VERSION)-$(LSOF_IPK_VERSION)_$(TARGET_ARCH).ipk
LSOF_IPK_DIR:=$(BUILD_DIR)/lsof-$(LSOF_VERSION)-ipk
ifeq ($(OPTWARE_TARGET),wl500g)
LSOF_PATCH:=$(LSOF_SOURCE_DIR)/Makefile-lib.patch $(LSOF_SOURCE_DIR)/machine_h.patch $(LSOF_SOURCE_DIR)/print_c.patch
else
LSOF_PATCH:=$(LSOF_SOURCE_DIR)/Makefile-lib.patch
endif
LSOF_UNZIP:=gunzip

.PHONY: lsof-source lsof-unpack lsof lsof-stage lsof-ipk lsof-clean lsof-dirclean lsof-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LSOF_SOURCE):
	$(WGET) -P $(DL_DIR) $(LSOF_SITE)/$(LSOF_SOURCE)

$(DL_DIR)/$(LSOF_DSC):
	$(WGET) -P $(DL_DIR) $(LSOF_SITE)/$(LSOF_DSC)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lsof-source: $(DL_DIR)/$(LSOF_SOURCE) $(DL_DIR)/$(LSOF_DSC) $(LSOF_PATCH)

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
$(LSOF_DIR)/.configured: $(DL_DIR)/$(LSOF_SOURCE) $(DL_DIR)/$(LSOF_DSC) $(LSOF_PATCHES)
	@rm -rf $(BUILD_DIR)/$(LSOF) $(LSOF_DIR)
	cd $(DL_DIR) && \
		if [ `grep $(LSOF_SOURCE) $(LSOF_DSC) | cut -f 2 -d " "` != \
			`md5sum $(DL_DIR)/$(LSOF_SOURCE) | cut -f $(if $MD5FIELD == ppc_darwin,4,1)  -d " "` ] ; then \
			echo "md5sum is not a match, aborting." ; \
			exit 2; \
		else \
			echo "md5sum verified." ; \
		fi
	cd $(BUILD_DIR) && tar zxf $(DL_DIR)/$(LSOF_SOURCE)	
	cd $(BUILD_DIR)/$(LSOF) && echo "n\ny\ny\ny\nn\nn\ny\n" | env \
		LSOF_CC=$(TARGET_CC) \
		LSOF_INCLUDE=$(TARGET_INCDIR) \
		LINUX_CLIB="-DGLIBCV=2" \
		./Configure linux
	cat $(LSOF_PATCH) | patch -d $(BUILD_DIR)/$(LSOF) -p1
	mv $(BUILD_DIR)/$(LSOF) $(LSOF_DIR)
	touch $(LSOF_DIR)/.configured

lsof-unpack: $(LSOF_DIR)/.configured

#
# This builds the actual binary.
#
$(LSOF_DIR)/lsof: $(LSOF_DIR)/.configured
	make -C $(LSOF_DIR) $(TARGET_CONFIGURE_OPTS) CDEF="$(TARGET_CFLAGS)"

#
# This is the build convenience target.
#
lsof: $(LSOF_DIR)/lsof

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lsof
#
$(LSOF_IPK_DIR)/CONTROL/control:
	@install -d $(LSOF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lsof" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LSOF_PRIORITY)" >>$@
	@echo "Section: $(LSOF_SECTION)" >>$@
	@echo "Version: $(LSOF_VERSION)-$(LSOF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LSOF_MAINTAINER)" >>$@
	@echo "Source: $(LSOF_SITE)/$(LSOF_SOURCE)" >>$@
	@echo "Description: $(LSOF_DESCRIPTION)" >>$@
	@echo "Depends: $(LSOF_DEPENDS)" >>$@
	@echo "Suggests: $(LSOF_SUGGESTS)" >>$@
	@echo "Conflicts: $(LSOF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LSOF_IPK_DIR)/opt/sbin or $(LSOF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LSOF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LSOF_IPK_DIR)/opt/etc/lsof/...
# Documentation files should be installed in $(LSOF_IPK_DIR)/opt/doc/lsof/...
# Daemon startup scripts should be installed in $(LSOF_IPK_DIR)/opt/etc/init.d/S??lsof
#
# You may need to patch your application to make it use these locations.

$(LSOF_IPK): $(LSOF_DIR)/lsof
	rm -rf $(LSOF_IPK_DIR) $(BUILD_DIR)/lsof_*_$(TARGET_ARCH).ipk
	install -d $(LSOF_IPK_DIR)/CONTROL
	install -d $(LSOF_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(LSOF_DIR)/lsof -o $(LSOF_IPK_DIR)/opt/sbin/lsof
	$(MAKE) $(LSOF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LSOF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lsof-ipk: $(LSOF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lsof-clean:
	-make -C $(LSOF_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lsof-dirclean:
	rm -rf $(LSOF_DIR) $(LSOF_IPK_DIR) $(LSOF_IPK)

#
# Some sanity check for the package.
#
lsof-check: $(LSOF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LSOF_IPK)
