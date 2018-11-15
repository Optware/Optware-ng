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
BOOST_VERSION ?= 1_68_0
BOOST_VERSION_DOTTED=$(shell echo $(BOOST_VERSION)|sed s/_/\./g)
BOOST_SOURCE=boost_$(BOOST_VERSION).tar.gz
BOOST_DIR=boost_$(BOOST_VERSION)
BOOST_UNZIP=zcat
BOOST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BOOST_DESCRIPTION=Boost is a set of peer-reviewed extensions to the standard C++ library
BOOST_SECTION=misc
BOOST_PRIORITY=optional
BOOST_DEPENDS=libstdc++
BOOST_LOCALE_DEPENDS=$(BOOST_DEPENDS), icu
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BOOST_LOCALE_DEPENDS+=, libiconv
endif
BOOST_SUGGESTS=
BOOST_CONFLICTS=

BOOST_EXTERNAL_JAM ?= no

BOOST_JAM=EXPAT_INCLUDE=$(STAGING_INCLUDE_DIR) \
	EXPAT_LIBPATH=$(STAGING_LIB_DIR)\
	$(BUILD_DIR)/boost/bjam
BOOST_JAM_PYTHON26=PYVER=-py26 \
	$(BUILD_DIR)/boost/bjam
BOOST_JAM_PYTHON27=PYVER=-py27 \
	$(BUILD_DIR)/boost/bjam
BOOST_JAM_PYTHON3=PYVER=-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g') \
	$(BUILD_DIR)/boost/bjam
BOOST_JAM_VERSION=3.1.17
BOOST_JAM_SOURCE=boost-jam-$(BOOST_JAM_VERSION).tgz
BOOST_JAM_DIR=boost-jam-$(BOOST_JAM_VERSION)
BOOST_JAM_UNZIP=zcat

ifeq ($(BOOST_EXTERNAL_JAM), yes)
BOOST_SOURCES=	$(DL_DIR)/$(BOOST_SOURCE) \
		$(DL_DIR)/$(BOOST_JAM_SOURCE)
else
BOOST_SOURCES=	$(DL_DIR)/$(BOOST_SOURCE)
endif

BOOST_GCC_CONF ?= tools/build/src/tools/gcc

BOOST_JAM_ROOT ?= tools/build

# boost libs that are expected to build always
BOOST_LIBS = dev date-time filesystem graph iostreams \
		program-options random regex signals system thread

# boost python libs that are expected to build always
BOOST_PYTHON_LIBS = python26 python27 python3

# serialization, test and wave may fail to build for some targets:
# override in platforms/packages-$(OPTWARE_TARGET).mk,
# e.g., see platforms/packages-buildroot-armeabi.mk,
# to skip them or add more additional libs;
# available additional libs (starting from certain boost
# versions and/or for certain arch(s)) are:
# 	atomic \
	chrono \
	container \
	context \
	coroutine \
	coroutine2 \
	graph-parallel \
	locale \
	log \
	timer \
	exception \
	serialization \
	test \
	wave
# graph-parallel and coroutine2 aren't separate libs, but are extensions
# to the graph and coroutine libraries, respectively
BOOST_ADDITIONAL_LIBS ?= serialization test wave


#
# BOOST_IPK_VERSION should be incremented when the ipk changes.
#
BOOST_IPK_VERSION ?= 1

#
# BOOST_CONFFILES should be a list of user-editable files
#BOOST_CONFFILES=$(TARGET_PREFIX)/etc/boost.conf $(TARGET_PREFIX)/etc/init.d/SXXboost

#
# BOOST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BOOST_PATCHES=\
$(BOOST_SOURCE_DIR)/skip-unit-test-binaries-execution.patch \
#$(BOOST_SOURCE_DIR)/atomic_count_gcc.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BOOST_CPPFLAGS=
BOOST_PYTHON26_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.6
BOOST_PYTHON27_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.7
BOOST_PYTHON3_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m
BOOST_LDFLAGS=
BOOST_JAM_ARGS= \
	-d+2 \
	toolset=gcc \
	link=shared \
	--layout=system \
	$(patsubst %, --with-%, $(shell echo $(BOOST_ADDITIONAL_LIBS) $(filter-out dev, $(BOOST_LIBS) | tr \- _))) \
	-sICU_PATH=$(STAGING_PREFIX) \
	--user-config=$(BOOST_BUILD_DIR)/user-config.jam
BOOST_JAM_PYTHON26_ARGS= \
	-d+2 \
	toolset=gcc \
	link=shared \
	--layout=system \
	--with-python \
	-sBOOST_VERSION=$(BOOST_VERSION_DOTTED)-py2.6 \
	--user-config=$(BOOST_BUILD_DIR)/user-config-py2.6.jam
BOOST_JAM_PYTHON27_ARGS= \
	-d+2 \
	toolset=gcc \
	link=shared \
	--layout=system \
	--with-python \
	-sBOOST_VERSION=$(BOOST_VERSION_DOTTED)-py2.7 \
	--user-config=$(BOOST_BUILD_DIR)/user-config-py2.7.jam
BOOST_JAM_PYTHON3_ARGS= \
	-d+2 \
	toolset=gcc \
	link=shared \
	--layout=system \
	--with-python \
	-sBOOST_VERSION=$(BOOST_VERSION_DOTTED)-py$(PYTHON3_VERSION_MAJOR) \
	--user-config=$(BOOST_BUILD_DIR)/user-config-py$(PYTHON3_VERSION_MAJOR).jam

ifeq ($(LIBC_STYLE),uclibc)
	BOOST_JAM_ARGS += boost.locale.posix=off define=BOOST_LOG_NO_THREADS
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

BOOST_GRAPH_IPK_DIR=$(BUILD_DIR)/boost-graph-$(BOOST_VERSION)-ipk
BOOST_GRAPH_IPK=$(BUILD_DIR)/boost-graph_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_IOSTREAMS_IPK_DIR=$(BUILD_DIR)/boost-iostreams-$(BOOST_VERSION)-ipk
BOOST_IOSTREAMS_IPK=$(BUILD_DIR)/boost-iostreams_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PROGRAM_OPTIONS_IPK_DIR=$(BUILD_DIR)/boost-program-options-$(BOOST_VERSION)-ipk
BOOST_PROGRAM_OPTIONS_IPK=$(BUILD_DIR)/boost-program-options_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PYTHON26_IPK_DIR=$(BUILD_DIR)/boost-python26-$(BOOST_VERSION)-ipk
BOOST_PYTHON26_IPK=$(BUILD_DIR)/boost-python26_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PYTHON27_IPK_DIR=$(BUILD_DIR)/boost-python27-$(BOOST_VERSION)-ipk
BOOST_PYTHON27_IPK=$(BUILD_DIR)/boost-python27_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_PYTHON3_IPK_DIR=$(BUILD_DIR)/boost-python3-$(BOOST_VERSION)-ipk
BOOST_PYTHON3_IPK=$(BUILD_DIR)/boost-python3_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_RANDOM_IPK_DIR=$(BUILD_DIR)/boost-random-$(BOOST_VERSION)-ipk
BOOST_RANDOM_IPK=$(BUILD_DIR)/boost-random_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

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

### additional libs that can be built starting from certain boost version

BOOST_ATOMIC_IPK_DIR=$(BUILD_DIR)/boost-atomic-$(BOOST_VERSION)-ipk
BOOST_ATOMIC_IPK=$(BUILD_DIR)/boost-atomic_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_CHRONO_IPK_DIR=$(BUILD_DIR)/boost-chrono-$(BOOST_VERSION)-ipk
BOOST_CHRONO_IPK=$(BUILD_DIR)/boost-chrono_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_CONTAINER_IPK_DIR=$(BUILD_DIR)/boost-container-$(BOOST_VERSION)-ipk
BOOST_CONTAINER_IPK=$(BUILD_DIR)/boost-container_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_CONTEXT_IPK_DIR=$(BUILD_DIR)/boost-context-$(BOOST_VERSION)-ipk
BOOST_CONTEXT_IPK=$(BUILD_DIR)/boost-context_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_COROUTINE_IPK_DIR=$(BUILD_DIR)/boost-coroutine-$(BOOST_VERSION)-ipk
BOOST_COROUTINE_IPK=$(BUILD_DIR)/boost-coroutine_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_LOCALE_IPK_DIR=$(BUILD_DIR)/boost-locale-$(BOOST_VERSION)-ipk
BOOST_LOCALE_IPK=$(BUILD_DIR)/boost-locale_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_LOG_IPK_DIR=$(BUILD_DIR)/boost-log-$(BOOST_VERSION)-ipk
BOOST_LOG_IPK=$(BUILD_DIR)/boost-log_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_TIMER_IPK_DIR=$(BUILD_DIR)/boost-timer-$(BOOST_VERSION)-ipk
BOOST_TIMER_IPK=$(BUILD_DIR)/boost-timer_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_EXCEPTION_IPK_DIR=$(BUILD_DIR)/boost-exception-$(BOOST_VERSION)-ipk
BOOST_EXCEPTION_IPK=$(BUILD_DIR)/boost-exception-dev_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk

BOOST_IPK_DIRS= \
	$(BOOST_DEV_IPK_DIR) \
	$(BOOST_DATE_TIME_IPK_DIR) \
	$(BOOST_FILESYSTEM_IPK_DIR) \
	$(BOOST_GRAPH_IPK_DIR) \
	$(BOOST_IOSTREAMS_IPK_DIR) \
	$(BOOST_PROGRAM_OPTIONS_IPK_DIR) \
	$(BOOST_RANDOM_IPK_DIR) \
	$(BOOST_REGEX_IPK_DIR) \
	$(BOOST_SERIALIZATION_IPK_DIR) \
	$(BOOST_SIGNALS_IPK_DIR) \
	$(BOOST_SYSTEM_IPK_DIR) \
	$(BOOST_THREAD_IPK_DIR) \
	$(BOOST_TEST_IPK_DIR) \
	$(BOOST_WAVE_IPK_DIR) \
	$(BOOST_ATOMIC_IPK_DIR) \
	$(BOOST_CHRONO_IPK_DIR) \
	$(BOOST_CONTAINER_IPK_DIR) \
	$(BOOST_CONTEXT_IPK_DIR) \
	$(BOOST_COROUTINE_IPK_DIR) \
	$(BOOST_LOCALE_IPK_DIR) \
	$(BOOST_LOG_IPK_DIR) \
	$(BOOST_TIMER_IPK_DIR) \
	$(BOOST_EXCEPTION_IPK_DIR)

BOOST_LIB_IPKS= \
	$(BOOST_DATE_TIME_IPK) \
	$(BOOST_FILESYSTEM_IPK) \
	$(BOOST_GRAPH_IPK) \
	$(BOOST_IOSTREAMS_IPK) \
	$(BOOST_PROGRAM_OPTIONS_IPK) \
	$(BOOST_RANDOM_IPK) \
	$(BOOST_REGEX_IPK) \
	$(BOOST_SIGNALS_IPK) \
	$(BOOST_SYSTEM_IPK) \
	$(BOOST_THREAD_IPK)

ifneq ($(BOOST_ADDITIONAL_LIBS),)
BOOST_LIB_IPKS += $(patsubst %, $(BUILD_DIR)/boost-%_$(BOOST_VERSION)-$(BOOST_IPK_VERSION)_$(TARGET_ARCH).ipk, $(filter-out exception graph-parallel coroutine2, $(BOOST_ADDITIONAL_LIBS)))
ifeq (exception, $(filter exception, $(BOOST_ADDITIONAL_LIBS)))
BOOST_LIB_IPKS += $(BOOST_EXCEPTION_IPK)
endif
endif

BOOST_LIB_PYTHON_IPKS = \
	$(BOOST_PYTHON26_IPK) \
	$(BOOST_PYTHON27_IPK) \
	$(BOOST_PYTHON3_IPK)

# boost lib ipks mask used for cleaning previous ipk versions before
# packaging all boost ipks except python ones
BOOST_LIB_IPKS_MASK = $(patsubst %, $(BUILD_DIR)/boost-%_*_$(TARGET_ARCH).ipk, $(BOOST_LIBS) $(filter-out exception, $(BOOST_ADDITIONAL_LIBS)))
ifeq (exception, $(filter exception, $(BOOST_ADDITIONAL_LIBS)))
BOOST_LIB_IPKS_MASK += $(BUILD_DIR)/boost-exception-dev_*_$(TARGET_ARCH).ipk
endif

.PHONY: boost-source boost-unpack boost boost-stage boost-ipk boost-clean boost-dirclean boost-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BOOST_SOURCE):
	$(WGET) -P $(@D) $(BOOST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(BOOST_JAM_SOURCE):
	$(WGET) -P $(@D) $(BOOST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
boost-source: $(DL_DIR)/$(BOOST_SOURCE) $(DL_DIR)/$(BOOST_JAM_SOURCE) $(BOOST_PATCHES)

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
$(BOOST_BUILD_DIR)/.configured: $(BOOST_SOURCES) $(BOOST_PATCHES) make/boost.mk
	$(MAKE) bzip2-stage expat-stage icu-stage libstdc++-stage python26-stage python27-stage python3-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(BOOST_DIR) $(BOOST_IPK_DIRS) $(BOOST_PYTHON26_IPK_DIR) $(BOOST_PYTHON27_IPK_DIR) $(BOOST_PYTHON3_IPK_DIR) $(@D)
	rm -rf $(STAGING_INCLUDE_DIR)/boost $(STAGING_LIB_DIR)/libboost*
	$(BOOST_UNZIP) $(DL_DIR)/$(BOOST_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BOOST_PATCHES)" ; \
		then cat $(BOOST_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(BOOST_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(BOOST_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BOOST_DIR) $(@D) ; \
	fi
ifeq ($(BOOST_EXTERNAL_JAM),yes)
	$(BOOST_JAM_UNZIP) $(DL_DIR)/$(BOOST_JAM_SOURCE) | tar -C $(@D) -xvf -
	(cd $(@D)/$(BOOST_JAM_DIR); \
		./build.sh; \
		cp bin.*/bjam $(@D) \
	)
else
	(cd $(@D)/$(BOOST_JAM_ROOT); \
		./bootstrap.sh; \
		cp bjam $(@D) \
	)
endif
	sed -i -e 's|: ar :|: $(TARGET_AR) :|' -e 's/-Wl,\$$(RPATH_OPTION:E=-R)\$$(SPACE)-Wl,\$$(RPATH)//' $(@D)/$(BOOST_GCC_CONF).jam
	sed -i -e 's/-Wl,\$$(RPATH_OPTION:E=-R)\$$(SPACE)-Wl,"\$$(RPATH)" //' $(@D)/$(BOOST_GCC_CONF).py
	### add PYVER env variable to libboost_python soname, e.g.: libboost_python.so.1.45.0 --> libboost_python${PYVER}.so.1.45.0
	sed -i -e 's;\$$(SONAME_OPTION)\$$(SPACE)-Wl,\$$(<\[-1\]:D=);\$$(SONAME_OPTION)\$$(SPACE)-Wl,`echo \$$(<\[-1\]:D=)|sed s/python[0-9]*/python\$${PYVER}/`;' $(@D)/$(BOOST_GCC_CONF).jam
	### set compilation and linking flags
	echo "using gcc : `$(TARGET_CC) -dumpversion` : $(TARGET_CXX) :" '<cxxflags>"$(STAGING_CPPFLAGS) $(BOOST_CPPFLAGS)" <linkflags>"$(STAGING_LDFLAGS) $(BOOST_LDFLAGS)" ;' > $(@D)/user-config.jam
	echo "using gcc : `$(TARGET_CC) -dumpversion` : $(TARGET_CXX) :" '<cxxflags>"$(STAGING_CPPFLAGS) $(BOOST_PYTHON26_CPPFLAGS)" <linkflags>"$(STAGING_LDFLAGS) $(BOOST_PYTHON26_LDFLAGS)" ;' > $(@D)/user-config-py2.6.jam
	echo "using gcc : `$(TARGET_CC) -dumpversion` : $(TARGET_CXX) :" '<cxxflags>"$(STAGING_CPPFLAGS) $(BOOST_PYTHON27_CPPFLAGS)" <linkflags>"$(STAGING_LDFLAGS) $(BOOST_PYTHON27_LDFLAGS)" ;' > $(@D)/user-config-py2.7.jam
	echo "using gcc : `$(TARGET_CC) -dumpversion` : $(TARGET_CXX) :" '<cxxflags>"$(STAGING_CPPFLAGS) $(BOOST_PYTHON3_CPPFLAGS)" <linkflags>"$(STAGING_LDFLAGS) $(BOOST_PYTHON3_LDFLAGS)" ;' > $(@D)/user-config-py$(PYTHON3_VERSION_MAJOR).jam
ifeq ($(LIBC_STYLE),uclibc)
	###uclibc portability issue
	sed -i -e "s/get_nprocs()/sysconf(_SC_NPROCESSORS_ONLN)/" $(@D)/libs/thread/src/pthread/thread.cpp
	###another uclibc issue
	sed -i -e 's/sizeof(tracking_type) == sizeof(bool)/1/' \
		-e 's/sizeof(class_id_type) == sizeof(int_least16_t)/1/' \
		-e 's/sizeof(class_id_reference_type) == sizeof(int_least16_t)/1/' $(@D)/boost/archive/basic_binary_iarchive.hpp $(@D)/boost/archive/basic_binary_oarchive.hpp
endif
ifeq ($(OPTWARE_TARGET), $(filter gumstix1151, $(OPTWARE_TARGET)))
	###some gumstix1151 threads bug
	echo '#undef BOOST_HAS_PTHREAD_DELAY_NP' >> $(@D)/boost/config.hpp ; \
	echo '#undef BOOST_HAS_NANOSLEEP' >> $(@D)/boost/config.hpp ; \
	echo '#define BOOST_THREAD_POSIX' >> $(@D)/boost/config.hpp ; \
	sed -i -e '/#  error "Threading support unavaliable: it has been explicitly disabled with BOOST_DISABLE_THREADS"/s|^|// |' $(@D)/boost/config/requires_threads.hpp
endif
	###'No WCHAR_MIN and WCHAR_MAX present' issue
	sed -i -e 's/namespace boost {/#ifndef WCHAR_MAX\n#define WCHAR_MAX 2147483647\n#endif\n#ifndef WCHAR_MIN\n#define WCHAR_MIN (-2147483647-1)\n#endif\nnamespace boost {/' $(@D)/boost/integer_traits.hpp
	touch $@

boost-unpack: $(BOOST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BOOST_BUILD_DIR)/.mainbuilt: $(BOOST_BUILD_DIR)/.configured
	rm -f $@
	### building serialization can give '#error "wide char i/o not supported on this platform"', which means no libboost_wserialization*, and yet build libboost_serialization* fine.
	-cd $(@D); $(BOOST_JAM) $(BOOST_JAM_ARGS)
	touch $@

$(BOOST_BUILD_DIR)/.py26built: $(BOOST_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(@D)/bin.v2/libs/python
	(cd $(@D); $(BOOST_JAM_PYTHON26) $(BOOST_JAM_PYTHON26_ARGS))
	mv $(@D)/stage/lib/libboost_python27.so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py26.so.$(BOOST_VERSION_DOTTED)
	rm -f $(@D)/stage/lib/libboost_python-py26.so
	ln -s libboost_python-py26.so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py26.so
	rm -f $(@D)/stage/lib/libboost_python.so
	touch $@

$(BOOST_BUILD_DIR)/.py27built: $(BOOST_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(@D)/bin.v2/libs/python
	(cd $(@D); $(BOOST_JAM_PYTHON27) $(BOOST_JAM_PYTHON27_ARGS))
	mv $(@D)/stage/lib/libboost_python27.so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py27.so.$(BOOST_VERSION_DOTTED)
	rm -f $(@D)/stage/lib/libboost_python-py27.so
	ln -s libboost_python-py27.so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py27.so
	rm -f $(@D)/stage/lib/libboost_python.so
	touch $@

$(BOOST_BUILD_DIR)/.py3built: $(BOOST_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(@D)/bin.v2/libs/python
	(cd $(@D); $(BOOST_JAM_PYTHON3) $(BOOST_JAM_PYTHON3_ARGS))
	mv -f $(@D)/stage/lib/libboost_python27.so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so.$(BOOST_VERSION_DOTTED)
	rm -f $(@D)/stage/lib/libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so
	ln -s libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so.$(BOOST_VERSION_DOTTED) $(@D)/stage/lib/libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so
	rm -f $(@D)/stage/lib/libboost_python.so
	touch $@

#
# This is the build convenience target.
#
boost: $(BOOST_BUILD_DIR)/.mainbuilt $(BOOST_BUILD_DIR)/.py26built $(BOOST_BUILD_DIR)/.py27built $(BOOST_BUILD_DIR)/.py3built

#
# If you are building a library, then you need to stage it too.
#
$(BOOST_BUILD_DIR)/.staged: $(BOOST_BUILD_DIR)/.mainbuilt $(BOOST_BUILD_DIR)/.py26built $(BOOST_BUILD_DIR)/.py27built $(BOOST_BUILD_DIR)/.py3built
	rm -f $@ $(STAGING_LIB_DIR)/libboost_*
	-cd $(@D); $(BOOST_JAM) install $(BOOST_JAM_ARGS) --prefix=$(STAGING_PREFIX)
	cp -af $(@D)/stage/lib/libboost_python-py*.so* $(STAGING_LIB_DIR)
	touch $@

boost-stage: $(BOOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/boost
#

$(BOOST_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-date-time" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_FILESYSTEM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-filesystem" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_GRAPH_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-graph" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS), expat" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_IOSTREAMS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-iostreams" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS), bzip2" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PROGRAM_OPTIONS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-program-options" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PYTHON26_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-python26" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS), python26" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PYTHON27_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-python27" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS), python27" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_PYTHON3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-python3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS), python3" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_RANDOM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-random" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_REGEX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-regex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SERIALIZATION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-serialization" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SIGNALS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-signals" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_SYSTEM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-system" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_TEST_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-test" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_THREAD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-thread" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_WAVE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-wave" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

### additional libs that can be built starting from certain boost version

$(BOOST_ATOMIC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-atomic" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_CHRONO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-chrono" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_CONTAINER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-container" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_CONTEXT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-context" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_COROUTINE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-coroutine" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_LOCALE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-locale" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_LOCALE_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_LOG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-log" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_TIMER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-timer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION)" >>$@
	@echo "Depends: $(BOOST_DEPENDS)" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

$(BOOST_EXCEPTION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: boost-exception-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOOST_PRIORITY)" >>$@
	@echo "Section: $(BOOST_SECTION)" >>$@
	@echo "Version: $(BOOST_VERSION)-$(BOOST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOOST_MAINTAINER)" >>$@
	@echo "Source: $(BOOST_SITE)/$(BOOST_SOURCE)" >>$@
	@echo "Description: $(BOOST_DESCRIPTION). This is a static library for native development only" >>$@
	@echo "Depends:  $(BOOST_DEPENDS), boost-dev" >>$@
	@echo "Suggests: $(BOOST_SUGGESTS)" >>$@
	@echo "Conflicts: $(BOOST_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BOOST_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BOOST_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BOOST_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BOOST_IPK_DIR)$(TARGET_PREFIX)/etc/boost/...
# Documentation files should be installed in $(BOOST_IPK_DIR)$(TARGET_PREFIX)/doc/boost/...
# Daemon startup scripts should be installed in $(BOOST_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??boost
#
# You may need to patch your application to make it use these locations.
#
$(BOOST_PYTHON26_IPK): $(BOOST_BUILD_DIR)/.py26built
	### now make boost-python-py26
	rm -rf $(BOOST_PYTHON26_IPK_DIR) $(BUILD_DIR)/boost-python26_*_$(TARGET_ARCH).ipk
	$(MAKE) $(BOOST_PYTHON26_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PYTHON26_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -f $(BOOST_BUILD_DIR)/stage/lib/libboost_python-py26.so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON26_IPK_DIR)$(TARGET_PREFIX)/lib
	ln -s libboost_python-py26.so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON26_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py26.so
	$(STRIP_COMMAND) $(BOOST_PYTHON26_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py26.so.$(BOOST_VERSION_DOTTED)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PYTHON26_IPK_DIR)

$(BOOST_PYTHON27_IPK): $(BOOST_BUILD_DIR)/.py27built
	rm -rf $(BOOST_PYTHON27_IPK_DIR) $(BUILD_DIR)/boost-python27_*_$(TARGET_ARCH).ipk
	### now make boost-python-py27
	$(MAKE) $(BOOST_PYTHON27_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PYTHON27_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -f $(BOOST_BUILD_DIR)/stage/lib/libboost_python-py27.so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON27_IPK_DIR)$(TARGET_PREFIX)/lib
	ln -s libboost_python-py27.so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON27_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py27.so
	$(STRIP_COMMAND) $(BOOST_PYTHON27_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py27.so.$(BOOST_VERSION_DOTTED)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PYTHON27_IPK_DIR)

$(BOOST_PYTHON3_IPK): $(BOOST_BUILD_DIR)/.py3built
	rm -rf $(BOOST_PYTHON3_IPK_DIR) $(BUILD_DIR)/boost-python3_*_$(TARGET_ARCH).ipk
	### now make boost-python-py3
	$(MAKE) $(BOOST_PYTHON3_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PYTHON3_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -f $(BOOST_BUILD_DIR)/stage/lib/libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON3_IPK_DIR)$(TARGET_PREFIX)/lib
	ln -s libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so.$(BOOST_VERSION_DOTTED) $(BOOST_PYTHON3_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py$(shell \
																echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so
	$(STRIP_COMMAND) $(BOOST_PYTHON3_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g').so.$(BOOST_VERSION_DOTTED)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PYTHON3_IPK_DIR)

$(BOOST_DEV_IPK) $(BOOST_LIB_IPKS): $(BOOST_BUILD_DIR)/.mainbuilt
	rm -rf $(BOOST_IPK_DIRS) $(BOOST_LIB_IPKS_MASK)
	-(cd $(BOOST_BUILD_DIR); $(BOOST_JAM) install $(BOOST_JAM_ARGS) --prefix=$(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*.so*
	### now make boost-date_time
	$(MAKE) $(BOOST_DATE_TIME_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_DATE_TIME_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*date_time* $(BOOST_DATE_TIME_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_DATE_TIME_IPK_DIR)
	### now make boost-filesystem
	$(MAKE) $(BOOST_FILESYSTEM_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_FILESYSTEM_IPK_DIR)$(TARGET_PREFIX)/lib
	-mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*filesystem* $(BOOST_FILESYSTEM_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_FILESYSTEM_IPK_DIR)
	### now make boost-graph
	$(MAKE) $(BOOST_GRAPH_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_GRAPH_IPK_DIR)$(TARGET_PREFIX)/lib
	-mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*graph* $(BOOST_GRAPH_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_GRAPH_IPK_DIR)
	### now make boost-iostreams
	$(MAKE) $(BOOST_IOSTREAMS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_IOSTREAMS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*iostreams* $(BOOST_IOSTREAMS_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_IOSTREAMS_IPK_DIR)
	### now make boost-program_options
	$(MAKE) $(BOOST_PROGRAM_OPTIONS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_PROGRAM_OPTIONS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*program_options* $(BOOST_PROGRAM_OPTIONS_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_PROGRAM_OPTIONS_IPK_DIR)
	### now make boost-random
	$(MAKE) $(BOOST_RANDOM_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_RANDOM_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*random* $(BOOST_RANDOM_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_RANDOM_IPK_DIR)
	### now make boost-regex
	$(MAKE) $(BOOST_REGEX_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_REGEX_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*regex* $(BOOST_REGEX_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_REGEX_IPK_DIR)
	### now make boost-signals
	$(MAKE) $(BOOST_SIGNALS_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_SIGNALS_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*signals* $(BOOST_SIGNALS_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_SIGNALS_IPK_DIR)
	### now make boost-system
	$(MAKE) $(BOOST_SYSTEM_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_SYSTEM_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*system* $(BOOST_SYSTEM_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_SYSTEM_IPK_DIR)
ifeq (test, $(filter test, $(BOOST_ADDITIONAL_LIBS)))
	### now make boost-test
	$(MAKE) $(BOOST_TEST_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_TEST_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*unit_test_framework* $(BOOST_TEST_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*prg_exec_monitor* $(BOOST_TEST_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_TEST_IPK_DIR)
endif
	### now make boost-thread
	$(MAKE) $(BOOST_THREAD_IPK_DIR)/CONTROL/control
	mkdir -p $(BOOST_THREAD_IPK_DIR)$(TARGET_PREFIX)/lib
	mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/*thread* $(BOOST_THREAD_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_THREAD_IPK_DIR)
ifneq ($(BOOST_ADDITIONAL_LIBS),)
	### make additional libs
	for lib in $(filter-out coroutine2 graph-parallel test, $(BOOST_ADDITIONAL_LIBS)); do \
		$(MAKE) $(BUILD_DIR)/boost-$${lib}-$(BOOST_VERSION)-ipk/CONTROL/control; \
		mkdir -p $(BUILD_DIR)/boost-$${lib}-$(BOOST_VERSION)-ipk$(TARGET_PREFIX)/lib; \
		mv $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/libboost_`echo $${lib} | tr \- _`* $(BUILD_DIR)/boost-$${lib}-$(BOOST_VERSION)-ipk$(TARGET_PREFIX)/lib; \
		(cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILD_DIR)/boost-$${lib}-$(BOOST_VERSION)-ipk); \
	done
endif
	### finally boost-dev
	$(MAKE) $(BOOST_DEV_IPK_DIR)/CONTROL/control
	rm -rf $(BOOST_DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOOST_DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
boost-ipk: $(BOOST_DEV_IPK) $(BOOST_LIB_IPKS) $(BOOST_LIB_PYTHON_IPKS)

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
	rm -rf $(BUILD_DIR)/$(BOOST_DIR) $(BOOST_BUILD_DIR) $(BOOST_IPK_DIRS) \
		$(BOOST_PYTHON26_IPK_DIR) $(BOOST_PYTHON27_IPK_DIR) $(BOOST_PYTHON3_IPK_DIR) \
		$(BOOST_LIB_IPKS) $(BOOST_LIB_PYTHON_IPKS)
#
#
# Some sanity check for the package.
#
boost-check: $(BOOST_DEV_IPK) $(BOOST_LIB_IPKS) $(BOOST_LIB_PYTHON_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BOOST_LIB_IPKS) $(BOOST_LIB_PYTHON_IPKS)
