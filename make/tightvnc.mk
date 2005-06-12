###########################################################
#
# tightvnc
#
###########################################################

#
# TIGHTVNC_VERSION, TIGHTVNC_SITE and TIGHTVNC_SOURCE define
# the upstream location of the source code for the package.
# TIGHTVNC_DIR is the directory which is created when the source
# archive is unpacked.
# TIGHTVNC_UNZIP is the command used to unzip the source.
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
TIGHTVNC_SITE=http://dl.sourceforge.net/sourceforge/vnc-tight
TIGHTVNC_VERSION=1.2.9
TIGHTVNC_SOURCE=tightvnc-$(TIGHTVNC_VERSION)_unixsrc.tar.bz2
TIGHTVNC_DIR=vnc_unixsrc
TIGHTVNC_UNZIP=bzcat
TIGHTVNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TIGHTVNC_DESCRIPTION=A free remote control software package derived from the popular VNC software.
TIGHTVNC_SECTION=x11
TIGHTVNC_PRIORITY=optional
TIGHTVNC_DEPENDS=perl
TIGHTVNC_SUGGESTS=
TIGHTVNC_CONFLICTS=

#
# TIGHTVNC_IPK_VERSION should be incremented when the ipk changes.
#
TIGHTVNC_IPK_VERSION=1

#
# TIGHTVNC_CONFFILES should be a list of user-editable files
#TIGHTVNC_CONFFILES=/opt/etc/tightvnc.conf /opt/etc/init.d/SXXtightvnc

#
# TIGHTVNC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TIGHTVNC_PATCHES=$(TIGHTVNC_SOURCE_DIR)/linux.cf.patch $(TIGHTVNC_SOURCE_DIR)/WC.c.patch $(TIGHTVNC_SOURCE_DIR)/vncviewer-Imakefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TIGHTVNC_CPPFLAGS=
TIGHTVNC_LDFLAGS=


#
# TIGHTVNC_BUILD_DIR is the directory in which the build is done.
# TIGHTVNC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TIGHTVNC_IPK_DIR is the directory in which the ipk is built.
# TIGHTVNC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TIGHTVNC_BUILD_DIR=$(BUILD_DIR)/tightvnc
TIGHTVNC_SOURCE_DIR=$(SOURCE_DIR)/tightvnc
TIGHTVNC_IPK_DIR=$(BUILD_DIR)/tightvnc-$(TIGHTVNC_VERSION)-ipk
TIGHTVNC_IPK=$(BUILD_DIR)/tightvnc_$(TIGHTVNC_VERSION)-$(TIGHTVNC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TIGHTVNC_SOURCE):
	$(WGET) -P $(DL_DIR) $(TIGHTVNC_SITE)/$(TIGHTVNC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tightvnc-source: $(DL_DIR)/$(TIGHTVNC_SOURCE) $(TIGHTVNC_PATCHES)

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
$(TIGHTVNC_BUILD_DIR)/.configured: $(DL_DIR)/$(TIGHTVNC_SOURCE) $(TIGHTVNC_PATCHES)
	$(MAKE) x11-stage xdmcp-stage libjpeg-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(TIGHTVNC_DIR) $(TIGHTVNC_BUILD_DIR)
	$(TIGHTVNC_UNZIP) $(DL_DIR)/$(TIGHTVNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(TIGHTVNC_PATCHES) | patch -d $(BUILD_DIR)/$(TIGHTVNC_DIR) -p1
		#echo "#define __arm__ 1"; \
		#echo "#define CrossCompiling 1"; 
	mv $(BUILD_DIR)/$(TIGHTVNC_DIR) $(TIGHTVNC_BUILD_DIR)
	make -C $(TIGHTVNC_BUILD_DIR)/Xvnc/config/imake -f Makefile.ini
	#cp $(STAGING_INCLUDE_DIR)/{jconfig,jmorecfg,jpeglib,zconf,zlib}.h $(TIGHTVNC_BUILD_DIR)/Xvnc/
	( \
		echo "#define OSName Linux"; \
		echo "#define OSMajorVersion 2"; \
		echo "#define OSMinorVersion 4"; \
		echo "#define OSTeenyVersion 22"; \
		echo "#define CcCmd $(TARGET_CC)"; \
		echo "#define CppCmd $(TARGET_CPP)"; \
		echo "#define ArCmdBase $(TARGET_AR)"; \
	) > $(TIGHTVNC_BUILD_DIR)/Xvnc/config/cf/platform.def
	( \
		cd $(TIGHTVNC_BUILD_DIR)/Xvnc/; \
		config/imake/imake -Iconfig/cf -DTOPDIR=. -DCURDIR=.; \
		make Makefiles; \
		make -C $(TIGHTVNC_BUILD_DIR)/Xvnc/config/makedepend CC=$(HOSTCC); \
		make includes; \
		make depend; \
	)
	( \
		cd $(TIGHTVNC_BUILD_DIR)/; \
		Xvnc/config/imake/imake -IXvnc/config/cf -DTOPDIR=Xvnc -DCURDIR=.; \
	)
	touch $(TIGHTVNC_BUILD_DIR)/.configured

tightvnc-unpack: $(TIGHTVNC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TIGHTVNC_BUILD_DIR)/.built: $(TIGHTVNC_BUILD_DIR)/.configured
	rm -f $(TIGHTVNC_BUILD_DIR)/.built
	$(MAKE) -C $(TIGHTVNC_BUILD_DIR) \
	    EXTRA_INCLUDES="$(STAGING_CPPFLAGS) $(TIGHTVNC_CPPFLAGS)" \
	    EXTRA_LDOPTIONS="$(STAGING_LDFLAGS) $(TIGHTVNC_LDFLAGS)" \
	    World
	$(MAKE) -C $(TIGHTVNC_BUILD_DIR)/Xvnc \
	    EXTRA_INCLUDES="$(STAGING_CPPFLAGS) $(TIGHTVNC_CPPFLAGS)" \
	    EXTRA_LDOPTIONS="$(STAGING_LDFLAGS) $(TIGHTVNC_LDFLAGS)" \
	    all
	touch $(TIGHTVNC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tightvnc: $(TIGHTVNC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TIGHTVNC_BUILD_DIR)/.staged: $(TIGHTVNC_BUILD_DIR)/.built
	rm -f $(TIGHTVNC_BUILD_DIR)/.staged
	$(MAKE) -C $(TIGHTVNC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TIGHTVNC_BUILD_DIR)/.staged

tightvnc-stage: $(TIGHTVNC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tightvnc
#
$(TIGHTVNC_IPK_DIR)/CONTROL/control:
	@install -d $(TIGHTVNC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: tightvnc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TIGHTVNC_PRIORITY)" >>$@
	@echo "Section: $(TIGHTVNC_SECTION)" >>$@
	@echo "Version: $(TIGHTVNC_VERSION)-$(TIGHTVNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TIGHTVNC_MAINTAINER)" >>$@
	@echo "Source: $(TIGHTVNC_SITE)/$(TIGHTVNC_SOURCE)" >>$@
	@echo "Description: $(TIGHTVNC_DESCRIPTION)" >>$@
	@echo "Depends: $(TIGHTVNC_DEPENDS)" >>$@
	@echo "Suggests: $(TIGHTVNC_SUGGESTS)" >>$@
	@echo "Conflicts: $(TIGHTVNC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TIGHTVNC_IPK_DIR)/opt/sbin or $(TIGHTVNC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TIGHTVNC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TIGHTVNC_IPK_DIR)/opt/etc/tightvnc/...
# Documentation files should be installed in $(TIGHTVNC_IPK_DIR)/opt/doc/tightvnc/...
# Daemon startup scripts should be installed in $(TIGHTVNC_IPK_DIR)/opt/etc/init.d/S??tightvnc
#
# You may need to patch your application to make it use these locations.
#
$(TIGHTVNC_IPK): $(TIGHTVNC_BUILD_DIR)/.built
	rm -rf $(TIGHTVNC_IPK_DIR) $(BUILD_DIR)/tightvnc_*_$(TARGET_ARCH).ipk
	( \
	    cd $(TIGHTVNC_BUILD_DIR); \
	    install -d $(TIGHTVNC_IPK_DIR)/opt/bin $(TIGHTVNC_IPK_DIR)/opt/man/man1; \
	    ./vncinstall $(TIGHTVNC_IPK_DIR)/opt/bin $(TIGHTVNC_IPK_DIR)/opt/man; \
	)
	#install -d $(TIGHTVNC_IPK_DIR)/opt/etc/
	#install -m 644 $(TIGHTVNC_SOURCE_DIR)/tightvnc.conf $(TIGHTVNC_IPK_DIR)/opt/etc/tightvnc.conf
	#install -d $(TIGHTVNC_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(TIGHTVNC_SOURCE_DIR)/rc.tightvnc $(TIGHTVNC_IPK_DIR)/opt/etc/init.d/SXXtightvnc
	$(MAKE) $(TIGHTVNC_IPK_DIR)/CONTROL/control
	#install -m 755 $(TIGHTVNC_SOURCE_DIR)/postinst $(TIGHTVNC_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(TIGHTVNC_SOURCE_DIR)/prerm $(TIGHTVNC_IPK_DIR)/CONTROL/prerm
	#echo $(TIGHTVNC_CONFFILES) | sed -e 's/ /\n/g' > $(TIGHTVNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TIGHTVNC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tightvnc-ipk: $(TIGHTVNC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tightvnc-clean:
	-$(MAKE) -C $(TIGHTVNC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tightvnc-dirclean:
	rm -rf $(BUILD_DIR)/$(TIGHTVNC_DIR) $(TIGHTVNC_BUILD_DIR) $(TIGHTVNC_IPK_DIR) $(TIGHTVNC_IPK)
