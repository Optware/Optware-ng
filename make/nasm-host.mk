###########################################################
#
# nasm-host
#
###########################################################
#
# NASM_HOST_VERSION, NASM_HOST_SITE and NASM_HOST_SOURCE define
# the upstream location of the source code for the package.
# NASM_HOST_DIR is the directory which is created when the source
# archive is unpacked.
# NASM_HOST_UNZIP is the command used to unzip the source.
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
NASM_HOST_URL=http://www.nasm.us/pub/nasm/releasebuilds/$(NASM_HOST_VERSION)/$(NASM_HOST_SOURCE)
NASM_HOST_VERSION=2.13.02
NASM_HOST_SOURCE=nasm-$(NASM_HOST_VERSION).tar.xz
NASM_HOST_DIR=nasm-$(NASM_HOST_VERSION)
NASM_HOST_UNZIP=xzcat
NASM_HOST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>

#
# NASM_HOST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NASM_HOST_PATCHES=$(NASM_HOST_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NASM_HOST_CPPFLAGS=
NASM_HOST_LDFLAGS=

#
# NASM_HOST_BUILD_DIR is the directory in which the build is done.
# NASM_HOST_SOURCE_DIR is the directory which holds all the
# patches.
#
# You should not change any of these variables.
#
NASM_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/nasm
NASM_HOST_SOURCE_DIR=$(SOURCE_DIR)/nasm-host

#
# Where host nasm binaries are installed to.
#
NASM_HOST_BIN_DIR=$(NASM_HOST_BUILD_DIR)/install_dir/bin

.PHONY: nasm-host-source nasm-host-unpack nasm-host nasm-host-clean nasm-host-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(NASM_HOST_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(NASM_HOST_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(NASM_HOST_SOURCE).sha512
#
$(DL_DIR)/$(NASM_HOST_SOURCE):
	$(WGET) -O $@ $(NASM_HOST_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nasm-host-source: $(DL_DIR)/$(NASM_HOST_SOURCE) $(NASM_HOST_PATCHES)

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
$(NASM_HOST_BUILD_DIR)/.configured: $(DL_DIR)/$(NASM_HOST_SOURCE) $(NASM_HOST_PATCHES) make/nasm-host.mk
	rm -rf $(HOST_BUILD_DIR)/$(NASM_HOST_DIR) $(@D)
	$(NASM_HOST_UNZIP) $(DL_DIR)/$(NASM_HOST_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(NASM_HOST_PATCHES)" ; \
		then cat $(NASM_HOST_PATCHES) | \
		$(PATCH) -d $(HOST_BUILD_DIR)/$(NASM_HOST_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(NASM_HOST_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(NASM_HOST_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=$(@D)/install_dir \
	)
	touch $@

nasm-host-unpack: $(NASM_HOST_BUILD_DIR)/.configured

#
# This builds and installs the actual binary.
#
$(NASM_HOST_BUILD_DIR)/.built: $(NASM_HOST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) install
	touch $@

#
# This is the build convenience target.
#
nasm-host: $(NASM_HOST_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all of the built files.
#
nasm-host-clean:
	rm -f $(NASM_HOST_BUILD_DIR)/.built
	-$(MAKE) -C $(NASM_HOST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nasm-host-dirclean:
	rm -rf $(HOST_BUILD_DIR)/$(NASM_HOST_DIR) $(NASM_HOST_BUILD_DIR)
