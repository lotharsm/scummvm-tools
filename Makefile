#######################################################################
# Default compilation parameters. Normally don't edit these           #
#######################################################################

srcdir      ?= .

DEFINES     := -DHAVE_CONFIG_H
LDFLAGS     :=
INCLUDES    := -I. -I$(srcdir)
LIBS        :=
OBJS        :=
DEPDIR      := .deps

MODULES     :=
MODULE_DIRS :=

STANDALONE  :=
# This one will go away once all tools are converted
NO_MAIN     := -DEXPORT_MAIN


# Load the make rules generated by configure
-include config.mk

ifeq "$(HAVE_GCC)" "1"
	CXXFLAGS:= -Wall $(CXXFLAGS)
	# Turn off some annoying and not-so-useful warnings
	CXXFLAGS+= -Wno-long-long -Wno-multichar -Wno-unknown-pragmas -Wno-reorder
	# Enable even more warnings...
	CXXFLAGS+= -Wpointer-arith -Wcast-qual
	CXXFLAGS+= -Wshadow -Wnon-virtual-dtor -Wwrite-strings

	# Currently we disable this gcc flag, since it will also warn in cases,
	# where using GCC_PRINTF (means: __attribute__((format(printf, x, y))))
	# is not possible, thus it would fail compiliation with -Werror without
	# being helpful.
	#CXXFLAGS+= -Wmissing-format-attribute

ifneq "$(HAVE_CLANG)" "1"
	# enable checking of pointers returned by "new", but only when we do not
	# build with clang
	CXXFLAGS+= -fcheck-new
endif
endif

ifeq "$(HAVE_CLANG)" "1"
	CXXFLAGS+= -Wno-conversion -Wno-shorten-64-to-32 -Wno-sign-compare -Wno-four-char-constants
endif

#######################################################################
# Default commands - put the necessary replacements in config.mk      #
#######################################################################

CAT     ?= cat
CP      ?= cp
ECHO    ?= printf
INSTALL ?= install
MKDIR   ?= mkdir -p
RM      ?= rm -f
RM_REC  ?= $(RM) -r
ZIP     ?= zip -q

#######################################################################

include $(srcdir)/Makefile.common

# check if configure has been run or has been changed since last run
config.h config.mk: $(srcdir)/configure
ifeq "$(findstring config.mk,$(MAKEFILE_LIST))" "config.mk"
	@echo "Running $(srcdir)/configure with the last specified parameters"
	@sleep 2
	LDFLAGS="$(SAVED_LDFLAGS)" CXX="$(SAVED_CXX)" \
			CXXFLAGS="$(SAVED_CXXFLAGS)" CPPFLAGS="$(SAVED_CPPFLAGS)" \
			ASFLAGS="$(SAVED_ASFLAGS)" WINDRESFLAGS="$(SAVED_WINDRESFLAGS)" \
			$(srcdir)/configure $(SAVED_CONFIGFLAGS)
else
	$(error You need to run $(srcdir)/configure before you can run make. Check $(srcdir)/configure --help for a list of parameters)
endif


#
# Windows specific
#

scummvmtoolswinres.o: $(srcdir)/gui/media/scummvmtools.ico $(srcdir)/dists/scummvmtools.rc
	$(QUIET_WINDRES)$(WINDRES) -DHAVE_CONFIG_H $(WINDRESFLAGS) $(DEFINES) -I. -I$(srcdir) $(srcdir)/dists/scummvmtools.rc scummvmtoolswinres.o

# Special target to create a win32 tools snapshot binary
WIN32PATH ?= build
win32dist:   all
	mkdir -p $(WIN32PATH)/graphics
	mkdir -p $(WIN32PATH)/tools/media
	cp $(srcdir)/gui/media/detaillogo.jpg $(WIN32PATH)/tools/media/
	cp $(srcdir)/gui/media/logo.jpg $(WIN32PATH)/tools/media/
	cp $(srcdir)/gui/media/tile.gif $(WIN32PATH)/tools/media/
	$(STRIP) construct_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(WIN32PATH)/tools/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT) -o $(WIN32PATH)/tools/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT) -o $(WIN32PATH)/tools/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT) -o $(WIN32PATH)/tools/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(WIN32PATH)/tools/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT) -o $(WIN32PATH)/tools/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(WIN32PATH)/tools/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(WIN32PATH)/tools/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(WIN32PATH)/tools/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(WIN32PATH)/tools/gob_loadcalc$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(WIN32PATH)/tools/scummvm-tools-cli$(EXEEXT)
	cp $(srcdir)/*.bat $(WIN32PATH)/tools
	cp $(srcdir)/COPYING $(WIN32PATH)/tools/COPYING.txt
	cp $(srcdir)/README $(WIN32PATH)/tools/README.txt
	cp $(srcdir)/NEWS $(WIN32PATH)/tools/NEWS.txt
	cp $(srcdir)/dists/win32/graphics/left.bmp $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/graphics/scummvm-install.ico $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/ScummVM?Tools.iss $(WIN32PATH)
	unix2dos $(WIN32PATH)/tools/*.txt

# Special target to create a win32 NSIS installer
WIN32BUILD=build
win32setup: all
	mkdir -p $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/COPYING          $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/NEWS             $(srcdir)/$(WIN32BUILD)
	cp $(srcdir)/README           $(srcdir)/$(WIN32BUILD)
	unix2dos $(srcdir)/$(WIN32BUILD)/*.*
	$(STRIP) construct_mohawk$(EXEEXT)   -o $(srcdir)/$(WIN32BUILD)/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT)          -o $(srcdir)/$(WIN32BUILD)/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT)              -o $(srcdir)/$(WIN32BUILD)/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT)             -o $(srcdir)/$(WIN32BUILD)/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT)           -o $(srcdir)/$(WIN32BUILD)/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT)            -o $(srcdir)/$(WIN32BUILD)/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT)           -o $(srcdir)/$(WIN32BUILD)/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT)     -o $(srcdir)/$(WIN32BUILD)/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT)       -o $(srcdir)/$(WIN32BUILD)/gob_loadcalc$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT)      -o $(srcdir)/$(WIN32BUILD)/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT)  -o $(srcdir)/$(WIN32BUILD)/scummvm-tools-cli$(EXEEXT)
	makensis -V2 -Dtop_srcdir="../.." -Dtext_dir="../../$(WIN32BUILD)" -Dbuild_dir="../../$(WIN32BUILD)" $(srcdir)/dists/win32/scummvm-tools.nsi


#
# OS X specific
#

ifdef USE_VORBIS
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libvorbisfile.a $(STATICLIBPATH)/lib/libvorbis.a $(STATICLIBPATH)/lib/libvorbisenc.a $(STATICLIBPATH)/lib/libogg.a
endif

ifdef USE_FLAC
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libFLAC.a
endif

ifdef USE_MAD
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libmad.a
endif

ifdef USE_PNG
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libpng.a
endif

ifdef USE_ZLIB
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libz.a
endif


# Special target to create a static linked binaries for Mac OS X.
scummvm-tools-static: $(scummvm-tools_OBJS)
	$(CXX) $(LDFLAGS) -o scummvm-tools-static $(scummvm-tools_OBJS) \
		-framework AudioUnit -framework AudioToolbox -framework Carbon -framework CoreMIDI \
		$(WXSTATICLIBS) $(OSX_STATIC_LIBS)

scummvm-tools-cli-static: $(scummvm-tools-cli_OBJS)
	$(CXX) $(LDFLAGS) -o scummvm-tools-cli-static $(scummvm-tools-cli_OBJS) \
		-framework AudioUnit -framework AudioToolbox -framework Carbon -framework CoreMIDI \
		$(OSX_STATIC_LIBS)

bundle_name = ScummVM\ Tools.app
bundle: scummvm-tools-static
	mkdir -p $(bundle_name)
	mkdir -p $(bundle_name)/Contents
	mkdir -p $(bundle_name)/Contents/MacOS
	mkdir -p $(bundle_name)/Contents/Resources
	echo "APPL????" > $(bundle_name)/Contents/PkgInfo
	cp $(srcdir)/dists/macosx/Info.plist $(bundle_name)/Contents/
	cp $(srcdir)/gui/media/*.* $(bundle_name)/Contents/Resources
	cp scummvm-tools-static $(bundle_name)/Contents/MacOS/scummvm-tools

# Special target to create a snapshot disk image for Mac OS X
osxsnap: bundle scummvm-tools-cli-static
	mkdir ScummVM-Tools-snapshot
	cp $(srcdir)/COPYING ./ScummVM-Tools-snapshot/License\ \(GPL\)
	cp $(srcdir)/NEWS ./ScummVM-Tools-snapshot/News
	cp $(srcdir)/README ./ScummVM-Tools-snapshot/ScummVM\ ReadMe
	$(XCODETOOLSPATH)/SetFile -t ttro -c ttxt ./ScummVM-Tools-snapshot/*
	$(XCODETOOLSPATH)/CpMac -r $(bundle_name) ./ScummVM-Tools-snapshot/
	cp scummvm-tools-cli-static ./ScummVM-Tools-snapshot/scummvm-tools-cli
	cp $(srcdir)/dists/macosx/DS_Store ./ScummVM-Tools-snapshot/.DS_Store
	$(XCODETOOLSPATH)/SetFile -a V ./ScummVM-Tools-snapshot/.DS_Store
	hdiutil create -ov -format UDZO -imagekey zlib-level=9 -fs HFS+ \
					-srcfolder ScummVM-Tools-snapshot \
					-volname "ScummVM Tools" \
					ScummVM-Tools-snapshot.dmg
	rm -rf ScummVM-snapshot


#
# AmigaOS specific
#

# Special target to create an AmigaOS snapshot installation
amigaos4dist: all
	mkdir -p $(AMIGAOS4PATH)
	mkdir -p $(AMIGAOS4PATH)/graphics
	mkdir -p $(AMIGAOS4PATH)/tools
	mkdir -p $(AMIGAOS4PATH)/tools/media
	cp $(srcdir)/gui/media/detaillogo.jpg $(AMIGAOS4PATH)/tools/media/
	cp $(srcdir)/gui/media/logo.jpg $(AMIGAOS4PATH)/tools/media/
	cp $(srcdir)/gui/media/tile.gif $(AMIGAOS4PATH)/tools/media/
	$(STRIP) construct_mohawk$(EXEEXT) -o $(AMIGAOS4PATH)/tools/construct_mohawk$(EXEEXT)
ifeq "$(USE_FREETYPE)" "1"
ifeq "$(USE_ICONV)" "1"
	$(STRIP) create_sjisfnt$(EXEEXT) -o $(AMIGAOS4PATH)/tools/create_sjisfnt$(EXEEXT)
endif
endif
	$(STRIP) decine$(EXEEXT) -o $(AMIGAOS4PATH)/tools/decine$(EXEEXT)
ifeq "$(USE_BOOST)" "1"
	$(STRIP) decompile$(EXEEXT) -o $(AMIGAOS4PATH)/tools/decompile$(EXEEXT)
endif
	$(STRIP) degob$(EXEEXT) -o $(AMIGAOS4PATH)/tools/degob$(EXEEXT)
	$(STRIP) dekyra$(EXEEXT) -o $(AMIGAOS4PATH)/tools/dekyra$(EXEEXT)
	$(STRIP) deprince$(EXEEXT) -o $(AMIGAOS4PATH)/tools/deprince$(EXEEXT)
	$(STRIP) descumm$(EXEEXT) -o $(AMIGAOS4PATH)/tools/descumm$(EXEEXT)
	$(STRIP) desword2$(EXEEXT) -o $(AMIGAOS4PATH)/tools/desword2$(EXEEXT)
	$(STRIP) extract_mohawk$(EXEEXT) -o $(AMIGAOS4PATH)/tools/extract_mohawk$(EXEEXT)
	$(STRIP) gob_loadcalc$(EXEEXT) -o $(AMIGAOS4PATH)/tools/gob_loadcalc$(EXEEXT)
ifeq "$(USE_WXWIDGETS)" "1"
	$(STRIP) scummvm-tools$(EXEEXT) -o $(AMIGAOS4PATH)/tools/scummvm-tools$(EXEEXT)
endif
	$(STRIP) scummvm-tools-cli$(EXEEXT) -o $(AMIGAOS4PATH)/tools/scummvm-tools-cli$(EXEEXT)
	#cp ${srcdir}/icons/scummvm-tools.info $(AMIGAOS4PATH)/scummvm-tools.info
	cp $(srcdir)/COPYING $(AMIGAOS4PATH)/tools/COPYING.txt
	cp $(srcdir)/README $(AMIGAOS4PATH)/tools/README.txt
	cp $(srcdir)/NEWS $(AMIGAOS4PATH)/tools/NEWS.txt

#
# RISC OS specific
#

ifdef QUIET
QUIET_ELF2AIF = @echo '   ' ELF2AIF '' $@;
endif

, := ,

# Special target to create an RISC OS snapshot installation
riscosdist: all riscosboot $(addprefix !ScummTool/bin/,$(addsuffix $(,)ff8,$(PROGRAMS)))
	cp ${srcdir}/dists/riscos/!Run,feb !ScummTool/!Run,feb
	cp ${srcdir}/dists/riscos/!Sprites,ff9 !ScummTool/!Sprites,ff9
	cp ${srcdir}/dists/riscos/!Sprites11,ff9 !ScummTool/!Sprites11,ff9
	cp $(srcdir)/README !ScummTool/!Help,fff
	cp $(srcdir)/COPYING !ScummTool/COPYING,fff
	cp $(srcdir)/NEWS !ScummTool/NEWS,fff
ifeq "$(USE_WXWIDGETS)" "1"
	mkdir -p !ScummTool/bin/media
	cp $(srcdir)/gui/media/detaillogo.jpg !ScummTool/bin/media/detaillogo.jpg,c85
	cp $(srcdir)/gui/media/logo.jpg !ScummTool/bin/media/logo.jpg,c85
	cp $(srcdir)/gui/media/tile.gif !ScummTool/bin/media/tile.gif,695
endif

riscosboot:
	mkdir -p !ScummTool/bin
	cp ${srcdir}/dists/riscos/!Boot,feb !ScummTool/!Boot,feb
	rm -rf !ScummTool/bin/*,ff8

!ScummTool/bin/%,ff8: %$(EXEEXT)
	$(QUIET_ELF2AIF)elf2aif $(<) !ScummTool/bin/$*,ff8
	$(QUIET)echo "Set Alias\$$$* <ScummTool\$$Dir>.bin.$* %%*0" >> !ScummTool/!Boot,feb
