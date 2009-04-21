###########################################################
#
# boost
#
###########################################################

# You must replace "boost" and "BOOST" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BOOST_VERSION, BOOST_SITE and BOOST_SOURCE define
# the upstream location of the source code for the package.
# BOOST_DIR is the directory which is created when the source
# archive is unpacked.
# BOOST_UNZIP is the command used to unzip the source.
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
BOOST_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/boost
BOOST_VERSION=1_38_0
BOOST_SOURCE=boost_$(BOOST_VERSION).tar.gz
BOOST_DIR=boost_$(BOOST_VERSION)
BOOST_UNZIP=zcat
BOOST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BOOST_DESCRIPTION=Boost is a set of peer-reviewed extensions to the standard C++ library
BOOST_SECTION=misc
BOOST_PRIORITY=optional
BOOST_DEPENDS=
BOOST_SUGGESTS=
BOOST_CONFLICTS=
BOOST_JAM=$(BUILD_DIR)/boost/bjam

#
# BOOST_IPK_VERSION should be incremented when the ipk changes.
#
BOOST_IPK_VERSION=1

#
# BOOST_CONFFILES should be a list of user-editable files
#BOOST_CONFFILES=/opt/etc/boost.conf /opt/etc/init.d/SXXboost

#
# BOOST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BOOST_PATCHES=$(BOOST_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BOOST_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.5
BOOST_LDFLAGS=
BOOST_JAM_ARGS= \
	-d+2 \
	toolset=gcc \
	link=shared \
	--layout=system \
	--without-mpi
ifeq (uclibc, $(LIBC_STYLE))
	BOOST_JAM_ARGS+= \
		--without-math 
endif

#
# BOOST_BUILD_DIR is the directory in which the build is done.
# BOOST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BOOST_IPK_DIR is the directory in which the ipk is built.
# BOOST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BOOST_BUILD_DIR=$(BUILD_DIR)/boost
BOOST_SOURCE_DIR=$(SOURCE_DIR)/boost

BOOST_DEV_IPK_DIR=$(BUILD_DIR)/boost-dev-$(BOOST_VERSION)-ipk
BOOST_DEV_IPK=$(BUILD_DIR)/boost-dev_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_DATE_TIME_IPK_DIR=$(BUILD_DIR)/boost-date-time-$(BOOST_VERSION)-ipk
BOOST_DATE_TIME_IPK=$(BUILD_DIR)/boost-date-time_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_FILESYSTEM_IPK_DIR=$(BUILD_DIR)/boost-filesystem-$(BOOST_VERSION)-ipk
BOOST_FILESYSTEM_IPK=$(BUILD_DIR)/boost-filesystem_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_FUNCTION_TYPES_IPK_DIR=$(BUILD_DIR)/boost-function-types-$(BOOST_VERSION)-ipk
BOOST_FUNCTION_TYPES_IPK=$(BUILD_DIR)/boost-function-types_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_GRAPH_IPK_DIR=$(BUILD_DIR)/boost-graph-$(BOOST_VERSION)-ipk
BOOST_GRAPH_IPK=$(BUILD_DIR)/boost-graph_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_IOSTREAMS_IPK_DIR=$(BUILD_DIR)/boost-iostreams-$(BOOST_VERSION)-ipk
BOOST_IOSTREAMS_IPK=$(BUILD_DIR)/boost-iostreams_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_MATH_IPK_DIR=$(BUILD_DIR)/boost-math-$(BOOST_VERSION)-ipk
BOOST_MATH_IPK=$(BUILD_DIR)/boost-math_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PROGRAM_OPTIONS_IPK_DIR=$(BUILD_DIR)/boost-program-options-$(BOOST_VERSION)-ipk
BOOST_PROGRAM_OPTIONS_IPK=$(BUILD_DIR)/boost-program-options_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PYTHON_IPK_DIR=$(BUILD_DIR)/boost-python-$(BOOST_VERSION)-ipk
BOOST_PYTHON_IPK=$(BUILD_DIR)/boost-python_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_REGEX_IPK_DIR=$(BUILD_DIR)/boost-regex-$(BOOST_VERSION)-ipk
BOOST_REGEX_IPK=$(BUILD_DIR)/boost-regex_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_SERIALIZATION_IPK_DIR=$(BUILD_DIR)/boost-serialization-$(BOOST_VERSION)-ipk
BOOST_SERIALIZATION_IPK=$(BUILD_DIR)/boost-serialization_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_SIGNALS_IPK_DIR=$(BUILD_DIR)/boost-signals-$(BOOST_VERSION)-ipk
BOOST_SIGNALS_OPTIONS_IPK=$(BUILD_DIR)/boost-signals_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_SYSTEM_IPK_DIR=$(BUILD_DIR)/boost-system-$(BOOST_VERSION)-ipk
BOOST_SYSTEM_OPTIONS_IPK=$(BUILD_DIR)/boost-system_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_TEST_IPK_DIR=$(BUILD_DIR)/boost-test-$(BOOST_VERSION)-ipk
BOOST_TEST_IPK=$(BUILD_DIR)/boost-test_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_THREAD_IPK_DIR=$(BUILD_DIR)/boost-thread-$(BOOST_VERSION)-ipk
BOOST_THREAD_IPK=$(BUILD_DIR)/boost-thread_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_WAVE_IPK_DIR=$(BUILD_DIR)/boost-wave-$(BOOST_VERSION)-ipk
BOOST_WAVE_IPK=$(BUILD_DIR)/boost-wave_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_IPK_DIRS= \
	$(BOOST_DEV_IPK_DIR) \
	$(BOOST_DATE_TIME_IPK_DIR) \
	$(BOOST_FILESYSTEM_IPK_DIR) \
	$(BOOST_GRAPH_IPK_DIR) \
	$(BOOST_IOSTREAMS_IPK_DIR) \
	$(BOOST_PROGRAM_OPTIONS_IPK_DIR) \
	$(BOOST_PYTHON_IPK_DIR) \
	$(BOOST_REGEX_IPK_DIR) \
	$(BOOST_SERIALIZATION_IPK_DIR) \
	$(BOOST_SIGNALS_IPK_DIR) \
	$(BOOST_SYSTEM_IPK_DIR) \
	$(BOOST_THREAD_DIR) \
	$(BOOST_TEST_IPK_DIR) \
	$(BOOST_WAVE_IPK_DIR)

BOOST_LIB_IPKS= \
	$(BOOST_DATE_TIME_IPK) \
	$(BOOST_FILESYSTEM_IPK) \
	$(BOOST_GRAPH_IPK) \
	$(BOOST_IOSTREAMS_IPK) \
	$(BOOST_PROGRAM_OPTIONS_IPK) \
	$(BOOST_PYTHON_IPK) \
	$(BOOST_REGEX_IPK) \
	$(BOOST_SERIALIZATION_IPK) \
	$(BOOST_SIGNALS_IPK) \
	$(BOOST_SYSTEM_IPK) \
	$(BOOST_THREAD) \
	$(BOOST_TEST_IPK) \
	$(BOOST_WAVE_IPK)

ifeq (glibc, $(LIBC_STYLE))
	BOOST_IPK_DIRS+= \
		$(BOOST_MATH_IPK_DIR) 
	BOOST_LIB_IPKS+= \
		$(BOOST_MATH_IPK) 
endif

.PHONY: boost-source boost-unpack boost boost-stage boost-ipk boost-clean boost-dirclean boost-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BOOST_SOURCE):
	$(WGET) -P $(@D) $(BOOST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
boost-source: $(DL_DIR)/$(BOOST_SOURCE) $(BOOST_PATCHES)

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
$(BOOST_BUILD_DIR)/.configured: $(DL_DIR)/$(BOOST_SOURCE) $(BOOST_PATCHES) make/boost.mk
	$(MAKE) bzip2-stage python-stage
	rm -rf $(BUILD_DIR)/$(BOOST_DIR) $(@D)
	$(BOOST_UNZIP) $(DL_DIR)/$(BOOST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BOOST_PATCHES)" ; \
		then cat $(BOOST_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BOOST_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BOOST_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BOOST_DIR) $(@D) ; \
	fi
	(cd $(@D)/tools/jam/src; \
		./build.sh; \
		cp bin.*/bjam $(@D) \
	)
	sed -i -e 's|: ar :|: $(TARGET_AR) :|' $(@D)/tools/build/v2/tools/gcc.jam
	echo 'using gcc : $(CROSS_CONFIGURATION_GCC_VERSION) : $(TARGET_CXX) : <cxxflags>"$(STAGING_CPPFLAGS) $(BOOST_CPPFLAGS)" <linkflags>"$(STAGING_LDFLAGS) $(BOOST_LDFLAGS)" ;' > $(@D)/tools/build/v2/user-config.jam
	echo 'using python : : $(STAGING_DIR)/bin/python ;' >> $(@D)/tools/build/v2/user-config.jam
ifeq ($(LIBC_STYLE),uclibc)
	###uclibc portability issue
	sed -i -e "s/get_nprocs()/1/" $(@D)/libs/thread/src/pthread/thread.cpp
endif
ifeq ($(OPTWARE_TARGET), $(filter gumstix1151, $(OPTWARE_TARGET)))
	###some bug when building on gumstix1151
	echo '#undef BOOST_HAS_PTHREAD_DELAY_NP' >> $(@D)/boost/config.hpp ; \
	echo '#undef BOOST_HAS_NANOSLEEP' >> $(@D)/boost/config.hpp ; \
	sed -i -e 's|#  error "Threading support unavaliable: it has been explicitly disabled with BOOST_DISABLE_THREADS"|//#error "Threading support unavaliable: it has been explicitly disabled with BOOST_DISABLE_THREADS"|' $(@D)/boost/config/requires_threads.hpp
endif
	touch $@

boost-unpack: $(BOOST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BOOST_BUILD_DIR)/.built: $(BOOST_BUILD_DIR)/.configured
	rm -f $@
	###We need this 'exit 0' trick cause building serialization can give '#error "wide char i/o not supported on this platform"', which means no libboost_wserialization*, and yet build libboost_serialization* fine.
	(cd $(BOOST_BUILD_DIR); $(BOOST_JAM) $(BOOST_JAM_ARGS); exit 0)
	touch $@

#
# This is the build convenience target.
#
boost: $(BOOST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BOOST_BUILD_DIR)/.staged: $(BOOST_BUILD_DIR)/.built
	rm -f $@
	(cd $(BOOST_BUILD_DIR); $(BOOST_JAM) install $(BOOST_JAM_ARGS) --prefix=$(STAGING_DIR)/opt; exit 0)
	touch $@

boost-stage: $(BOOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/boost
#

$(BOOST_DEV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: Boost headers" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_DATE_TIME_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-date-time" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_FILESYSTEM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-filesystem" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_GRAPH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-graph" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_IOSTREAMS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-iostreams" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: bzip2" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_MATH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-math" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PROGRAM_OPTIONS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-program-options" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: python" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_REGEX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-regex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SERIALIZATION_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-serialization" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SIGNALS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-signals" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SYSTEM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-system" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_TEST_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-test" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_THREAD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-thread" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_WAVE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: boost-wave" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends:" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BOOST_IPK_DIR)/opt/sbin or $(BOOST_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BOOST_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BOOST_IPK_DIR)/opt/etc/boost/...
# Documentation files should be installed in $(BOOST_IPK_DIR)/opt/doc/boost/...
# Daemon startup scripts should be installed in $(BOOST_IPK_DIR)/opt/etc/init.d/S??boost
#
# You may need to patch your application to make it use these locations.
#
$(BOOST_DEV_IPK): $(BOOST_BUILD_DIR)/.built
	rm -rf $(BOOST_IPK_DIRS) $(BUILD_DIR)/boost*_$(TARGET_ARCH).ipk
	(cd $(BOOST_BUILD_DIR); $(BOOST_JAM) install $(BOOST_JAM_ARGS) --prefix=$(BOOST_DEV_IPK_DIR)/opt; exit 0)
	### now make boost-date_time
	$(MAKE) $(BOOST_DATE_TIME_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_DATE_TIME_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*date_time* $(BOOST_DATE_TIME_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_DATE_TIME_IPK_DIR)
	### now make boost-filesystem
	$(MAKE) $(BOOST_FILESYSTEM_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_FILESYSTEM_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*filesystem* $(BOOST_FILESYSTEM_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_FILESYSTEM_IPK_DIR)
	### now make boost-graph
	$(MAKE) $(BOOST_GRAPH_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_GRAPH_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*graph* $(BOOST_GRAPH_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_GRAPH_IPK_DIR)
	### now make boost-iostreams
	$(MAKE) $(BOOST_IOSTREAMS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_IOSTREAMS_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*iostreams* $(BOOST_IOSTREAMS_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_IOSTREAMS_IPK_DIR)
	### now make boost-program_options
	$(MAKE) $(BOOST_PROGRAM_OPTIONS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PROGRAM_OPTIONS_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*program_options* $(BOOST_PROGRAM_OPTIONS_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PROGRAM_OPTIONS_IPK_DIR)
	### now make boost-python
	$(MAKE) $(BOOST_PYTHON_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PYTHON_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*python* $(BOOST_PYTHON_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PYTHON_IPK_DIR)
	### now make boost-regex
	$(MAKE) $(BOOST_REGEX_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_REGEX_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*regex* $(BOOST_REGEX_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_REGEX_IPK_DIR)
	### now make boost-serialization
	$(MAKE) $(BOOST_SERIALIZATION_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_SERIALIZATION_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*serialization* $(BOOST_SERIALIZATION_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_SERIALIZATION_IPK_DIR)
	### now make boost-signals
	$(MAKE) $(BOOST_SIGNALS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_SIGNALS_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*signals* $(BOOST_SIGNALS_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_SIGNALS_IPK_DIR)
	### now make boost-system
	$(MAKE) $(BOOST_SYSTEM_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_SYSTEM_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*system* $(BOOST_SYSTEM_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_SYSTEM_IPK_DIR)
	### now make boost-test
	$(MAKE) $(BOOST_TEST_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_TEST_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*unit_test_framework* $(BOOST_TEST_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*prg_exec_monitor* $(BOOST_TEST_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_TEST_IPK_DIR)
	### now make boost-thread
	$(MAKE) $(BOOST_THREAD_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_THREAD_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*thread* $(BOOST_THREAD_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_THREAD_IPK_DIR)
	### now make boost-wave
	$(MAKE) $(BOOST_WAVE_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_WAVE_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/*wave* $(BOOST_WAVE_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_WAVE_IPK_DIR)
ifeq (glibc, $(LIBC_STYLE))
	### now make boost-math
	$(MAKE) $(BOOST_MATH_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_MATH_IPK_DIR)/opt/lib
	mv $(BOOST_DEV_IPK_DIR)/opt/lib/* $(BOOST_MATH_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_MATH_IPK_DIR)
endif
	### finally boost-dev
	$(MAKE) $(BOOST_DEV_IPK_DIR)/CONTROL/control
	rm -rf $(BOOST_DEV_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
boost-ipk: $(BOOST_DEV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
boost-clean:
	rm -f $(BOOST_BUILD_DIR)/.built
	rm -rf $(BOOST_BUILD_DIR)/bin.v2

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
boost-dirclean:
	rm -rf $(BUILD_DIR)/$(BOOST_DIR) $(BOOST_BUILD_DIR) $(BOOST_IPK_DIRS) $(BUILD_DIR)/boost*_$(TARGET_ARCH).ipk
#
#
# Some sanity check for the package.
#
boost-check: $(BOOST_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BOOST_LIB_IPKS)
