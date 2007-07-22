#############################################################
#
# ipkg-utils for use on the host system
#
#############################################################

# You must replace "ipkg_utils" and "IPKG_UTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IPKG-UTILS_VERSION, IPKG-UTILS_SITE and IPKG-UTILS_SOURCE define
# the upstream location of the source code for the package.
# IPKG-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# IPKG-UTILS_UNZIP is the command used to unzip the source.
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
IPKG-UTILS_VERSION:=1.7
IPKG-UTILS_SITE:=http://nslu.sf.net/downloads
#IPKG-UTILS_SITE:=http://handhelds.org/packages/ipkg-utils/
IPKG-UTILS_SOURCE:=ipkg-utils-$(IPKG-UTILS_VERSION).tar.gz
IPKG-UTILS_DIR:=$(TOOL_BUILD_DIR)/ipkg-utils-$(IPKG-UTILS_VERSION)


#
# IPKG-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG-UTILS_PATCHES=$(IPKG-UTILS_SOURCE_DIR)/ipkg-utils-1.7-ipkg_buildpackage.patch \
		$(IPKG-UTILS_SOURCE_DIR)/ipkg-utils-1.7-ipkg_build_clean.patch \
		$(IPKG-UTILS_SOURCE_DIR)/ipkg-utils-1.7-ipkg_tar_invocation.patch
ifeq ($(HOST_MACHINE),armv5b)
IPKG-UTILS_PATCHES += $(IPKG-UTILS_SOURCE_DIR)/ipkg-utils-1.7-ipkg_native_shell.patch
endif


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG-UTILS_CPPFLAGS=
IPKG-UTILS_LDFLAGS=

#
# IPKG-UTILS_BUILD_DIR is the directory in which the build is done.
# IPKG-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPKG-UTILS_IPK_DIR is the directory in which the ipk is built.
# IPKG-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG-UTILS_BUILD_DIR=$(BUILD_DIR)/ipkg-utils
IPKG-UTILS_SOURCE_DIR=$(SOURCE_DIR)/ipkg-utils
IPKG-UTILS_IPK_DIR=$(BUILD_DIR)/ipkg-utils-$(IPKG-UTILS_VERSION)-ipk
IPKG-UTILS_IPK=$(BUILD_DIR)/ipkg-utils_$(IPKG-UTILS_VERSION)-$(IPKG-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipkg-utils-source ipkg-utils-unpack ipkg-utils ipkg-utils-stage ipkg-utils-ipk ipkg-utils-clean ipkg-utils-dirclean ipkg-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPKG-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPKG-UTILS_SITE)/$(IPKG-UTILS_SOURCE)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipkg-utils-source: $(DL_DIR)/$(IPKG-UTILS_SOURCE) $(IPKG-UTILS_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
$(IPKG-UTILS_DIR)/.unpacked: $(DL_DIR)/$(IPKG-UTILS_SOURCE)
	mkdir -p $(TOOL_BUILD_DIR)
	mkdir -p $(DL_DIR)
	zcat $(DL_DIR)/$(IPKG-UTILS_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	cd $(SOURCE_DIR); cat $(IPKG-UTILS_PATCHES) | patch -p1 -d $(IPKG-UTILS_DIR)
	touch $(IPKG-UTILS_DIR)/.unpacked

ipkg-utils-unpack: $(IPKG-UTILS_BUILD_DIR)/.unpacked

#
# This builds the actual binary.
#
$(STAGING_DIR)/bin/ipkg-build: $(IPKG-UTILS_DIR)/.unpacked
	mkdir -p $(STAGING_DIR)/bin
	install -m0755 $(IPKG-UTILS_DIR)/ipkg-build* $(STAGING_DIR)/bin
	install -m0755 $(IPKG-UTILS_DIR)/ipkg-make-index $(STAGING_DIR)/bin
	install -m0755 $(IPKG-UTILS_DIR)/ipkg.py $(STAGING_DIR)/bin

#
# This is the build convenience target.
#
ipkg-utils: $(STAGING_DIR)/bin/ipkg-build

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-utils-clean:
	rm -f $(STAGING_DIR)/bin/ipkg*

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-utils-dirclean:
	rm -rf $(IPKG-UTILS_DIR)


IPKG_BUILDPACKAGE := PATH=$(TARGET_PATH) ipkg-buildpackage -c -o root -g root
IPKG_BUILD := PATH=$(TARGET_PATH) TAR_OPTIONS=--format=ustar ipkg-build -c -o root -g root
IPKG_MAKE_INDEX := PATH=$(TARGET_PATH) TAR_OPTIONS=--wildcards ipkg-make-index

