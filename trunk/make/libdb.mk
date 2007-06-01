###########################################################
#
# libdb
#
###########################################################

# Copyright (C) 2004 by Tom King <ka6sox@gmail.com>
# Copyright (C) 2004 by Rod Whitby
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# You must replace "<foo>" and "<FOO>" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# <FOO>_VERSION, <FOO>_SITE and <FOO>_SOURCE define
# the upstream location of the source code for the package.
# <FOO>_DIR is the directory which is created when the source
# archive is unpacked.
# <FOO>_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBDB_SITE=http://download.oracle.com/berkeley-db
LIBDB_VERSION=4.2.52
LIBDB_LIB_VERSION=4.2
LIBDB_SOURCE=db-$(LIBDB_VERSION).tar.gz
LIBDB_DIR=db-$(LIBDB_VERSION)
LIBDB_UNZIP=zcat
LIBDB_MAINTAINER=ka6sox <ka6sox@gmail.com>
LIBDB_DESCRIPTION=Berkeley DB Libraries
LIBDB_SECTION=lib
LIBDB_PRIORITY=optional
LIBDB_DEPENDS=
LIBDB_CONFLICTS=

#
# <FOO>_IPK_VERSION should be incremented when the ipk changes.
#
LIBDB_IPK_VERSION=3

#
# <FOO>_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
##LIBDB_PATCHES=$(LIBDB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDB_CPPFLAGS=
LIBDB_LDFLAGS=

#
# <FOO>_BUILD_DIR is the directory in which the build is done.
# <FOO>_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# <FOO>_IPK_DIR is the directory in which the ipk is built.
# <FOO>_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDB_BUILD_DIR=$(BUILD_DIR)/libdb
LIBDB_SOURCE_DIR=$(SOURCE_DIR)/libdb
LIBDB_IPK_DIR=$(BUILD_DIR)/libdb-$(LIBDB_VERSION)-ipk
LIBDB_IPK=$(BUILD_DIR)/libdb_$(LIBDB_VERSION)-$(LIBDB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDB_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBDB_SITE)/$(LIBDB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBDB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdb-source: $(DL_DIR)/$(LIBDB_SOURCE) $(LIBDB_PATCHES)

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
$(LIBDB_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDB_SOURCE) $(LIBDB_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBDB_DIR) $(LIBDB_BUILD_DIR)
	$(LIBDB_UNZIP) $(DL_DIR)/$(LIBDB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(LIBDB_PATCHES) | patch -d $(BUILD_DIR)/$(LIBDB_DIR) -p1
	mv $(BUILD_DIR)/$(LIBDB_DIR) $(LIBDB_BUILD_DIR)
	(cd $(LIBDB_BUILD_DIR)/build_unix; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDB_LDFLAGS)" \
		../dist/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(LIBDB_BUILD_DIR)/.configured

libdb-unpack: $(LIBDB_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBDB_BUILD_DIR)/build_unix/.libs/libdb-$(LIBDB_LIB_VERSION).a: $(LIBDB_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBDB_BUILD_DIR)/build_unix

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
# Note: this should be path where libdb really appears, might need to fix
libdb: $(LIBDB_BUILD_DIR)/build_unix/.libs/libdb-$(LIBDB_LIB_VERSION).a

#
# If you are building a library, then you need to stage it too.
#
$(LIBDB_BUILD_DIR)/.staged: $(LIBDB_BUILD_DIR)/build_unix/.libs/libdb-$(LIBDB_LIB_VERSION).a
	rm -f $@
	$(MAKE) -C $(LIBDB_BUILD_DIR)/build_unix DESTDIR=$(STAGING_DIR) install_setup install_include install_lib
	rm -f $(STAGING_LIB_DIR)/libdb-$(LIBDB_LIB_VERSION).la
	touch $@

libdb-stage: $(LIBDB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdb
#
$(LIBDB_IPK_DIR)/CONTROL/control:
	@install -d $(LIBDB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libdb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDB_PRIORITY)" >>$@
	@echo "Section: $(LIBDB_SECTION)" >>$@
	@echo "Version: $(LIBDB_VERSION)-$(LIBDB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDB_MAINTAINER)" >>$@
	@echo "Source: $(LIBDB_SITE)/$(LIBDB_SOURCE)" >>$@
	@echo "Description: $(LIBDB_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDB_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBDB_CONFLICTS)" >>$@

# This builds the IPK file.
#
# Binaries should be installed into $(<FOO>_IPK_DIR)/opt/sbin or $(LIBDB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(<FOO>_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(<FOO>_IPK_DIR)/opt/etc/<foo>/...
# Documentation files should be installed in $(<FOO>_IPK_DIR)/opt/doc/<foo>/...
# Daemon startup scripts should be installed in $(<FOO>_IPK_DIR)/opt/etc/init.d/S??<foo>
#
# You may need to patch your application to make it use these locations.
#
$(LIBDB_IPK): $(LIBDB_BUILD_DIR)/build_unix/.libs/libdb-$(LIBDB_LIB_VERSION).a
	rm -rf $(LIBDB_IPK_DIR) $(LIBDB_IPK)
	$(MAKE) -C $(LIBDB_BUILD_DIR)/build_unix DESTDIR=$(LIBDB_IPK_DIR) install_setup install_include install_lib
	-$(STRIP_COMMAND) $(LIBDB_IPK_DIR)/opt/lib/*.so
	rm -f $(LIBDB_IPK_DIR)/opt/lib/*.{la,a}
	$(MAKE) $(LIBDB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDB_IPK_DIR)
#
#
# This is called from the top level makefile to create the IPK file.
#
libdb-ipk: $(LIBDB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdb-clean:
	-$(MAKE) -C $(LIBDB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdb-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDB_DIR) $(LIBDB_BUILD_DIR) $(LIBDB_IPK_DIR) $(LIBDB_IPK)
