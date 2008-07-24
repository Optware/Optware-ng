###########################################################
#
# crosstool-ng
#
###########################################################
#
# CROSSTOO-NG_VERSION, CROSSTOO-NG_SITE and CROSSTOO-NG_SOURCE define
# the upstream location of the source code for the package.
# CROSSTOO-NG_DIR is the directory which is created when the source
# archive is unpacked.
# CROSSTOO-NG_UNZIP is the command used to unzip the source.
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
CROSSTOO-NG_SITE=http://ymorin.is-a-geek.org/download/crosstool-ng
CROSSTOO-NG_VERSION?=1.2.0
CROSSTOO-NG_SOURCE=crosstool-ng-$(CROSSTOO-NG_VERSION).tar.bz2
CROSSTOO-NG_DIR=crosstool-ng-$(CROSSTOO-NG_VERSION)
CROSSTOO-NG_UNZIP=bzcat
CROSSTOO-NG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CROSSTOO-NG_DESCRIPTION=crosstool-NG is a versatile toolchain generator, aiming at being highly configurable.

#
# CROSSTOO-NG_CONFFILES should be a list of user-editable files
#CROSSTOO-NG_CONFFILES=/opt/etc/crosstool-ng.conf /opt/etc/init.d/SXXcrosstool-ng

#
# CROSSTOO-NG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CROSSTOO-NG_PATCHES=$(CROSSTOO-NG_SOURCE_DIR)/configure.patch

CROSSTOO-NG_CPPFLAGS=
CROSSTOO-NG_LDFLAGS=

CROSSTOO-NG_SOURCE_DIR=$(SOURCE_DIR)/crosstool-ng
CROSSTOO-NG_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/crosstool-ng

.PHONY: crosstool-ng-source crosstool-ng-unpack crosstool-ng crosstool-ng-stage crosstool-ng-ipk crosstool-ng-clean crosstool-ng-dirclean crosstool-ng-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CROSSTOO-NG_SOURCE):
	$(WGET) -P $(@D) $(CROSSTOO-NG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
crosstool-ng-source: $(DL_DIR)/$(CROSSTOO-NG_SOURCE) $(CROSSTOO-NG_PATCHES)

$(CROSSTOO-NG_HOST_BUILD_DIR)/.staged: host/.configured \
$(DL_DIR)/$(CROSSTOO-NG_SOURCE) $(CROSSTOO-NG_PATCHES) make/crosstool-ng.mk
	rm -rf $(HOST_BUILD_DIR)/$(CROSSTOO-NG_DIR) $(@D)
	$(CROSSTOO-NG_UNZIP) $(DL_DIR)/$(CROSSTOO-NG_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(CROSSTOO-NG_PATCHES)" ; \
		then cat $(CROSSTOO-NG_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(CROSSTOO-NG_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(CROSSTOO-NG_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(CROSSTOO-NG_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX) \
	)
	$(MAKE) -C $(@D)
	$(MAKE) -C $(@D) install
	touch $@

crosstool-ng-host-stage: $(CROSSTOO-NG_HOST_BUILD_DIR)/.staged
