###########################################################
#
# ocaml
#
###########################################################
#
# $Header$
#
# OCAML_VERSION, OCAML_SITE and OCAML_SOURCE define
# the upstream location of the source code for the package.
# OCAML_DIR is the directory which is created when the source
# archive is unpacked.
# OCAML_UNZIP is the command used to unzip the source.
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
OCAML_SITE=http://caml.inria.fr/pub/distrib/ocaml-3.10
OCAML_VERSION=3.10.0
OCAML_SOURCE=ocaml-$(OCAML_VERSION).tar.gz
OCAML_DIR=ocaml-$(OCAML_VERSION)
OCAML_UNZIP=zcat
OCAML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OCAML_DESCRIPTION=Objective Caml system is the main implementation of the Caml language.
OCAML_SECTION=misc
OCAML_PRIORITY=optional
OCAML_DEPENDS=
OCAML_SUGGESTS=
OCAML_CONFLICTS=

#
# OCAML_IPK_VERSION should be incremented when the ipk changes.
#
OCAML_IPK_VERSION=1

#
# OCAML_CONFFILES should be a list of user-editable files
#OCAML_CONFFILES=/opt/etc/ocaml.conf /opt/etc/init.d/SXXocaml

#
# OCAML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq ($(TARGET_ARCH), armeb)
OCAML_PATCHES=\
$(OCAML_SOURCE_DIR)/asmcomp-arm-emit.mlp.patch \
$(OCAML_SOURCE_DIR)/asmcomp-arm-selection.ml.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OCAML_CPPFLAGS=
OCAML_LDFLAGS=

#
# OCAML_BUILD_DIR is the directory in which the build is done.
# OCAML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OCAML_IPK_DIR is the directory in which the ipk is built.
# OCAML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OCAML_BUILD_DIR=$(BUILD_DIR)/ocaml
OCAML_SOURCE_DIR=$(SOURCE_DIR)/ocaml
OCAML_IPK_DIR=$(BUILD_DIR)/ocaml-$(OCAML_VERSION)-ipk
OCAML_IPK=$(BUILD_DIR)/ocaml_$(OCAML_VERSION)-$(OCAML_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OCAML_SOURCE):
	$(WGET) -P $(DL_DIR) $(OCAML_SITE)/$(OCAML_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ocaml-source: $(DL_DIR)/$(OCAML_SOURCE) $(OCAML_PATCHES)

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
#		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
		--disable-static \

$(OCAML_BUILD_DIR)/.configured: $(DL_DIR)/$(OCAML_SOURCE) $(OCAML_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(OCAML_DIR) $(OCAML_BUILD_DIR)
	$(OCAML_UNZIP) $(DL_DIR)/$(OCAML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OCAML_PATCHES)"; then \
		cat $(OCAML_PATCHES) | patch -d $(BUILD_DIR)/$(OCAML_DIR) -p1; \
        fi
	mv $(BUILD_DIR)/$(OCAML_DIR) $(OCAML_BUILD_DIR)
	(cd $(OCAML_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OCAML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OCAML_LDFLAGS)" \
		./configure \
		--prefix /opt \
		--no-tk \
	)
	touch $(OCAML_BUILD_DIR)/.configured

ocaml-unpack: $(OCAML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OCAML_BUILD_DIR)/.built: $(OCAML_BUILD_DIR)/.configured
	rm -f $(OCAML_BUILD_DIR)/.built
	$(MAKE) -C $(OCAML_BUILD_DIR) world opt
	touch $(OCAML_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ocaml: $(OCAML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OCAML_BUILD_DIR)/.staged: $(OCAML_BUILD_DIR)/.built
	rm -f $(OCAML_BUILD_DIR)/.staged
	$(MAKE) -C $(OCAML_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(OCAML_BUILD_DIR)/.staged

ocaml-stage: $(OCAML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ocaml
#
$(OCAML_IPK_DIR)/CONTROL/control:
	@install -d $(OCAML_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ocaml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OCAML_PRIORITY)" >>$@
	@echo "Section: $(OCAML_SECTION)" >>$@
	@echo "Version: $(OCAML_VERSION)-$(OCAML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OCAML_MAINTAINER)" >>$@
	@echo "Source: $(OCAML_SITE)/$(OCAML_SOURCE)" >>$@
	@echo "Description: $(OCAML_DESCRIPTION)" >>$@
	@echo "Depends: $(OCAML_DEPENDS)" >>$@
	@echo "Suggests: $(OCAML_SUGGESTS)" >>$@
	@echo "Conflicts: $(OCAML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OCAML_IPK_DIR)/opt/sbin or $(OCAML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OCAML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OCAML_IPK_DIR)/opt/etc/ocaml/...
# Documentation files should be installed in $(OCAML_IPK_DIR)/opt/doc/ocaml/...
# Daemon startup scripts should be installed in $(OCAML_IPK_DIR)/opt/etc/init.d/S??ocaml
#
# You may need to patch your application to make it use these locations.
#
$(OCAML_IPK): $(OCAML_BUILD_DIR)/.built
	rm -rf $(OCAML_IPK_DIR) $(BUILD_DIR)/ocaml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OCAML_BUILD_DIR) PREFIX=$(OCAML_IPK_DIR)/opt install
	for exe in ocamlrun ocamlyacc; do $(STRIP_COMMAND) $(OCAML_IPK_DIR)/opt/bin/$$exe; done
	for so in $(OCAML_IPK_DIR)/opt/lib/ocaml/stublibs/*.so; do $(STRIP_COMMAND) $$so; done
#	install -d $(OCAML_IPK_DIR)/opt/etc/
#	install -m 644 $(OCAML_SOURCE_DIR)/ocaml.conf $(OCAML_IPK_DIR)/opt/etc/ocaml.conf
#	install -d $(OCAML_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OCAML_SOURCE_DIR)/rc.ocaml $(OCAML_IPK_DIR)/opt/etc/init.d/SXXocaml
	$(MAKE) $(OCAML_IPK_DIR)/CONTROL/control
#	install -m 755 $(OCAML_SOURCE_DIR)/postinst $(OCAML_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OCAML_SOURCE_DIR)/prerm $(OCAML_IPK_DIR)/CONTROL/prerm
#	echo $(OCAML_CONFFILES) | sed -e 's/ /\n/g' > $(OCAML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OCAML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ocaml-ipk: $(OCAML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ocaml-clean:
	-$(MAKE) -C $(OCAML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ocaml-dirclean:
	rm -rf $(BUILD_DIR)/$(OCAML_DIR) $(OCAML_BUILD_DIR) $(OCAML_IPK_DIR) $(OCAML_IPK)
