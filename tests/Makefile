include ../extra.mk

SUBDIRS = ${TESTPLUGIN}

CLEAN = EBOOT.PBP		\
	boot.dol		\
	${PROG_NOINST}.arm9	\
	${PROG_NOINST}.nds

PROG_NOINST = tests${PROG_SUFFIX}
SRCS = ForwardingTests.m		\
       OFArrayTests.m			\
       ${OFBLOCKTESTS_M}		\
       OFDataTests.m			\
       OFDateTests.m			\
       OFDictionaryTests.m		\
       OFHTTPCookieTests.m		\
       OFHTTPCookieManagerTests.m	\
       OFInvocationTests.m		\
       OFJSONTests.m			\
       OFListTests.m			\
       OFMethodSignatureTests.m		\
       OFNumberTests.m			\
       OFObjectTests.m			\
       OFSetTests.m			\
       OFStreamTests.m			\
       OFStringTests.m			\
       OFURLTests.m			\
       OFXMLElementBuilderTests.m	\
       OFXMLNodeTests.m			\
       OFXMLParserTests.m		\
       PBKDF2Tests.m			\
       RuntimeTests.m			\
       ScryptTests.m			\
       TestsAppDelegate.m		\
       ${USE_SRCS_FILES}		\
       ${USE_SRCS_PLUGINS}		\
       ${USE_SRCS_SOCKETS}		\
       ${USE_SRCS_THREADS}		\
       ${OFHTTPCLIENTTESTS_M}
SRCS_FILES = OFHMACTests.m		\
	     OFINIFileTests.m		\
	     OFMD5HashTests.m		\
	     OFRIPEMD160HashTests.m	\
	     OFSerializationTests.m	\
	     OFSHA1HashTests.m		\
	     OFSHA224HashTests.m	\
	     OFSHA256HashTests.m	\
	     OFSHA384HashTests.m	\
	     OFSHA512HashTests.m
SRCS_PLUGINS = OFPluginTests.m
SRCS_SOCKETS = OFKernelEventObserverTests.m	\
	       OFTCPSocketTests.m		\
	       OFUDPSocketTests.m
SRCS_THREADS = OFThreadTests.m

IOS_USER ?= mobile
IOS_TMP ?= /tmp/objfw-test

include ../buildsys.mk

post-all: ${RUN_TESTS}

.PHONY: run run-on-ios run-on-android
run:
	rm -f libobjfw.so.${OBJFW_LIB_MAJOR}
	rm -f libobjfw.so.${OBJFW_LIB_MAJOR_MINOR}
	rm -f libobjfw.dll libobjfw.${OBJFW_LIB_MAJOR}.dylib
	rm -f libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR}
	rm -f libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR}
	rm -f libobjfw-rt.dll libobjfw-rt.${OBJFW_RT_LIB_MAJOR}.dylib
	if test -f ../src/libobjfw.so; then \
		${LN_S} ../src/libobjfw.so libobjfw.so.${OBJFW_LIB_MAJOR}; \
		${LN_S} ../src/libobjfw.so \
		    libobjfw.so.${OBJFW_LIB_MAJOR_MINOR}; \
	elif test -f ../src/libobjfw.so.${OBJFW_LIB_MAJOR_MINOR}; then \
		${LN_S} ../src/libobjfw.so.${OBJFW_LIB_MAJOR_MINOR} \
		    libobjfw.so.${OBJFW_LIB_MAJOR_MINOR}; \
	fi
	if test -f ../src/libobjfw.dll; then \
		${LN_S} ../src/libobjfw.dll libobjfw.dll; \
	fi
	if test -f ../src/libobjfw.dylib; then \
		${LN_S} ../src/libobjfw.dylib \
		    libobjfw.${OBJFW_LIB_MAJOR}.dylib; \
	fi
	if test -f ../src/runtime/libobjfw-rt.so; then \
		${LN_S} ../src/runtime/libobjfw-rt.so \
		    libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR}; \
		${LN_S} ../src/runtime/libobjfw-rt.so \
		    libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR}; \
	elif test -f ../src/runtime/libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR}; then \
		${LN_S} ../src/runtime/libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR} libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR}; \
	fi
	if test -f ../src/runtime/libobjfw-rt.dll; then \
		${LN_S} ../src/runtime/libobjfw-rt.dll libobjfw-rt.dll; \
	fi
	if test -f ../src/runtime/libobjfw-rt.dylib; then \
		${LN_S} ../src/runtime/libobjfw-rt.dylib \
		    libobjfw-rt.${OBJFW_RT_LIB_MAJOR}.dylib; \
	fi
	LD_LIBRARY_PATH=.$${LD_LIBRARY_PATH+:}$$LD_LIBRARY_PATH \
	DYLD_LIBRARY_PATH=.$${DYLD_LIBRARY_PATH+:}$$DYLD_LIBRARY_PATH \
	LIBRARY_PATH=.$${LIBRARY_PATH+:}$$LIBRARY_PATH \
	ASAN_OPTIONS=allocator_may_return_null=1 \
	${WRAPPER} ./${PROG_NOINST}; EXIT=$$?; \
	rm -f libobjfw.so.${OBJFW_LIB_MAJOR}; \
	rm -f libobjfw.so.${OBJFW_LIB_MAJOR_MINOR} libobjfw.dll; \
	rm -f libobjfw.${OBJFW_LIB_MAJOR}.dylib; \
	rm -f libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR}; \
	rm -f libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR_MINOR} libobjfw-rt.dll; \
	rm -f libobjfw-rt.${OBJFW_RT_LIB_MAJOR}.dylib; \
	exit $$EXIT

run-on-ios: all
	if [ -z "${IOS_HOST}" ]; then \
		echo "Please set IOS_HOST to the hostname of your iOS host!"; \
		exit 1; \
	fi
	echo "Uploading files to iOS device ${IOS_HOST} at ${IOS_TMP}..."
	ssh ${IOS_USER}@${IOS_HOST} \
	    'rm -fr ${IOS_TMP} && mkdir -p ${IOS_TMP}/plugin'
	destname=libobjfw.${OBJFW_LIB_MAJOR}.dylib; \
	scp -q ../src/libobjfw.dylib \
	    ${IOS_USER}@${IOS_HOST}:${IOS_TMP}/$$destname
	scp -q tests testfile.bin testfile.txt testfile.ini serialization.xml \
	    ${IOS_USER}@${IOS_HOST}:${IOS_TMP}/
	scp -q plugin/TestPlugin.bundle \
	    ${IOS_USER}@${IOS_HOST}:${IOS_TMP}/plugin/
	echo "Running tests binary on iOS device ${IOS_HOST}..."
	ssh ${IOS_USER}@${IOS_HOST} \
	    'cd ${IOS_TMP} && DYLD_LIBRARY_PATH=. ${WRAPPER} ./tests'

run-on-android: all
	echo "Uploading files to Android device..."
	if test -f ../src/libobjfw.so; then \
		adb push ../src/libobjfw.so \
		    /data/local/tmp/objfw/libobjfw.so.${OBJFW_LIB_MAJOR}; \
	fi
	if test -f ../src/runtime/libobjfw-rt.so; then \
		adb push ../src/runtime/libobjfw-rt.so \
		    /data/local/tmp/objfw/libobjfw-rt.so.${OBJFW_RT_LIB_MAJOR}; \
	fi
	adb push tests /data/local/tmp/objfw/tests
	adb push testfile.bin /data/local/tmp/objfw/testfile.bin
	adb push testfile.txt /data/local/tmp/objfw/testfile.txt
	adb push testfile.ini /data/local/tmp/objfw/testfile.ini
	adb push serialization.xml /data/local/tmp/objfw/serialization.xml
	if test -f plugin/TestPlugin.so; then \
		adb push plugin/TestPlugin.so \
		    /data/local/tmp/objfw/plugin/TestPlugin.so; \
	fi
	echo "Running tests binary on Android device..."
	adb shell 'cd /data/local/tmp/objfw && LD_LIBRARY_PATH=. exec ${WRAPPER} ./tests'

EBOOT.PBP: ${PROG_NOINST}
	psp-fixup-imports ${PROG_NOINST}
	mksfo "ObjFW Tests" PARAM.SFO
	psp-strip ${PROG_NOINST}
	pack-pbp $@ PARAM.SFO NULL NULL NULL NULL NULL ${PROG_NOINST} NULL

boot.dol: ${PROG_NOINST}
	elf2dol ${PROG_NOINST} $@

${PROG_NOINST}: ${LIBOBJFW_DEP}

${PROG_NOINST}.arm9: ${PROG_NOINST}
	arm-none-eabi-objcopy -O binary $< $@

${PROG_NOINST}.nds: ${PROG_NOINST}.arm9
	rm -fr nds-data
	mkdir -p nds-data
	cp testfile.bin testfile.txt testfile.ini serialization.xml nds-data
	ndstool -c $@ -9 $< -d nds-data
	rm -fr nds-data

${PROG_NOINST}.3dsx: ${PROG_NOINST}
	3dsxtool $< $@

CPPFLAGS += -I../src -I../src/exceptions -I../src/runtime -I.. -DSTDOUT
OBJCFLAGS += ${TESTS_OBJCFLAGS}
LIBS := -L../src -lobjfw -L../src/runtime ${RUNTIME_LIBS} ${TESTS_LIBS} ${LIBS}
LDFLAGS += ${MAP_LDFLAGS}
LD = ${OBJC}
