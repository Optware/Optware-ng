###########################################################
#
# erl-escript
#
###########################################################
#
# ERL-ESCRIPT_VERSION, ERL-ESCRIPT_SITE and ERL-ESCRIPT_SOURCE define
# the upstream location of the source code for the package.
# ERL-ESCRIPT_DIR is the directory which is created when the source
# archive is unpacked.
# ERL-ESCRIPT_UNZIP is the command used to unzip the source.
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
ERL-ESCRIPT_SITE=http://yhafri.club.fr/crux/escript
ERL-ESCRIPT_VERSION=4.0
ERL-ESCRIPT_SOURCE=escript-$(ERL-ESCRIPT_VERSION).tgz
ERL-ESCRIPT_DIR=escript-$(ERL-ESCRIPT_VERSION)
ERL-ESCRIPT_UNZIP=zcat
ERL-ESCRIPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ERL-ESCRIPT_DESCRIPTION=A simple one pass "load and go" Erlang scripting interface.
ERL-ESCRIPT_SECTION=misc
ERL-ESCRIPT_PRIORITY=optional
ERL-ESCRIPT_DEPENDS=erlang, coreutils
ERL-ESCRIPT_SUGGESTS=
ERL-ESCRIPT_CONFLICTS=

#
# ERL-ESCRIPT_IPK_VERSION should be incremented when the ipk changes.
#
ERL-ESCRIPT_IPK_VERSION=1

#
# ERL-ESCRIPT_CONFFILES should be a list of user-editable files
# ERL-ESCRIPT_CONFFILES=/opt/etc/escript.conf /opt/etc/escript-cert.pem /opt/etc/escript-key.pem

#
# ERL-ESCRIPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# ERL-ESCRIPT_PATCHES=$(ERL-ESCRIPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ERL-ESCRIPT_CPPFLAGS=-I$(ERLANG_BUILD_DIR)/erts/emulator/beam/
ERL-ESCRIPT_LDFLAGS=

#
# ERL-ESCRIPT_BUILD_DIR is the directory in which the build is done.
# ERL-ESCRIPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ERL-ESCRIPT_IPK_DIR is the directory in which the ipk is built.
# ERL-ESCRIPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ERL-ESCRIPT_BUILD_DIR=$(BUILD_DIR)/erl-escript
ERL-ESCRIPT_SOURCE_DIR=$(SOURCE_DIR)/erl-escript
ERL-ESCRIPT_IPK_DIR=$(BUILD_DIR)/erl-escript-$(ERL-ESCRIPT_VERSION)-ipk
ERL-ESCRIPT_IPK=$(BUILD_DIR)/erl-escript_$(ERL-ESCRIPT_VERSION)-$(ERL-ESCRIPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: erl-escript-source erl-escript-unpack erl-escript erl-escript-stage erl-escript-ipk erl-escript-clean erl-escript-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ERL-ESCRIPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(ERL-ESCRIPT_SITE)/$(ERL-ESCRIPT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
erl-escript-source: $(DL_DIR)/$(ERL-ESCRIPT_SOURCE) $(ERL-ESCRIPT_PATCHES)

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
$(ERL-ESCRIPT_BUILD_DIR)/.configured: $(DL_DIR)/$(ERL-ESCRIPT_SOURCE) $(ERL-ESCRIPT_PATCHES) make/erl-escript.mk
	$(MAKE) $(ERLANG_HOST_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/$(ERL-ESCRIPT_DIR) $(ERL-ESCRIPT_BUILD_DIR)
	$(ERL-ESCRIPT_UNZIP) $(DL_DIR)/$(ERL-ESCRIPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ERL-ESCRIPT_PATCHES)" ; \
		then cat $(ERL-ESCRIPT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ERL-ESCRIPT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ERL-ESCRIPT_DIR)" != "$(ERL-ESCRIPT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ERL-ESCRIPT_DIR) $(ERL-ESCRIPT_BUILD_DIR) ; \
	fi
	sed -i \
	    -e 's|{BEAM_FILES}|(BEAM_FILES)|' \
	    -e 's|(MODS:=\(\..*\))|(addsuffix \1,$$(MODS))|' \
	    $(ERL-ESCRIPT_BUILD_DIR)/Makefile
	sed -i -e 's|$$CWD|/opt/lib/erlang/lib/$(ERL-ESCRIPT_DIR)|' $(ERL-ESCRIPT_BUILD_DIR)/mk_escript.sh
	touch $(ERL-ESCRIPT_BUILD_DIR)/.configured

erl-escript-unpack: $(ERL-ESCRIPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ERL-ESCRIPT_BUILD_DIR)/.built: $(ERL-ESCRIPT_BUILD_DIR)/.configured
	rm -f $(ERL-ESCRIPT_BUILD_DIR)/.built
	$(MAKE) -C $(ERL-ESCRIPT_BUILD_DIR) all \
		ERLC=$(ERLANG_HOST_BUILD_DIR)/bin/erlc
	touch $(ERL-ESCRIPT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
erl-escript: $(ERL-ESCRIPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ERL-ESCRIPT_BUILD_DIR)/.staged: $(ERL-ESCRIPT_BUILD_DIR)/.built
	rm -f $(ERL-ESCRIPT_BUILD_DIR)/.staged
#	$(MAKE) -C $(ERL-ESCRIPT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ERL-ESCRIPT_BUILD_DIR)/.staged

erl-escript-stage: $(ERL-ESCRIPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/erl-escript
#
$(ERL-ESCRIPT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: erl-escript" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ERL-ESCRIPT_PRIORITY)" >>$@
	@echo "Section: $(ERL-ESCRIPT_SECTION)" >>$@
	@echo "Version: $(ERL-ESCRIPT_VERSION)-$(ERL-ESCRIPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ERL-ESCRIPT_MAINTAINER)" >>$@
	@echo "Source: $(ERL-ESCRIPT_SITE)/$(ERL-ESCRIPT_SOURCE)" >>$@
	@echo "Description: $(ERL-ESCRIPT_DESCRIPTION)" >>$@
	@echo "Depends: $(ERL-ESCRIPT_DEPENDS)" >>$@
	@echo "Suggests: $(ERL-ESCRIPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(ERL-ESCRIPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ERL-ESCRIPT_IPK_DIR)/opt/sbin or $(ERL-ESCRIPT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ERL-ESCRIPT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ERL-ESCRIPT_IPK_DIR)/opt/etc/erl-escript/...
# Documentation files should be installed in $(ERL-ESCRIPT_IPK_DIR)/opt/doc/erl-escript/...
# Daemon startup scripts should be installed in $(ERL-ESCRIPT_IPK_DIR)/opt/etc/init.d/S??erl-escript
#
# You may need to patch your application to make it use these locations.
#
$(ERL-ESCRIPT_IPK): $(ERL-ESCRIPT_BUILD_DIR)/.built
	rm -rf $(ERL-ESCRIPT_IPK_DIR) $(BUILD_DIR)/erl-escript_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(ERL-ESCRIPT_BUILD_DIR) DESTDIR=$(ERL-ESCRIPT_IPK_DIR) install
	install -d $(ERL-ESCRIPT_IPK_DIR)/opt/lib/erlang/lib/$(ERL-ESCRIPT_DIR)
	(cd $(ERL-ESCRIPT_BUILD_DIR); \
	install -m 755 escript mk_escript.sh factorial fibi fibc \
		$(ERL-ESCRIPT_IPK_DIR)/opt/lib/erlang/lib/$(ERL-ESCRIPT_DIR); \
	install -m 644 escript.{erl,beam} \
		Makefile history escript.html \
		$(ERL-ESCRIPT_IPK_DIR)/opt/lib/erlang/lib/$(ERL-ESCRIPT_DIR); )
	install -d $(ERL-ESCRIPT_IPK_DIR)/opt/bin
	(cd $(ERL-ESCRIPT_IPK_DIR)/opt/bin; \
		ln -s /opt/lib/erlang/lib/$(ERL-ESCRIPT_DIR)/escript .; )
	$(MAKE) $(ERL-ESCRIPT_IPK_DIR)/CONTROL/control
#	install -m 755 $(ERL-ESCRIPT_SOURCE_DIR)/postinst $(ERL-ESCRIPT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ERL-ESCRIPT_SOURCE_DIR)/prerm $(ERL-ESCRIPT_IPK_DIR)/CONTROL/prerm
#	echo $(ERL-ESCRIPT_CONFFILES) | sed -e 's/ /\n/g' > $(ERL-ESCRIPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ERL-ESCRIPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
erl-escript-ipk: $(ERL-ESCRIPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
erl-escript-clean:
	rm -f $(ERL-ESCRIPT_BUILD_DIR)/.built
	-$(MAKE) -C $(ERL-ESCRIPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
erl-escript-dirclean:
	rm -rf $(BUILD_DIR)/$(ERL-ESCRIPT_DIR) $(ERL-ESCRIPT_BUILD_DIR) $(ERL-ESCRIPT_IPK_DIR) $(ERL-ESCRIPT_IPK)
