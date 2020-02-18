#
#  tail.mk
#  Apple2BuildPipelineSample
#
#  Part of a sample build pipeline for Apple II software development
#
#  Created by Quinn Dunki on 8/15/14.
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#

BUILD_TYPE := $(shell if echo $(MACHINE) | grep -q -- -basic; then echo basic; elif echo $(MACHINE) | grep -q -- -merlin; then echo merlin; else echo cc65; fi)

CWD=$(shell pwd)

DISKIMAGE=$(TARGETDIR)/$(PGM).dsk

EXECCMD=

vpath $(GENDIR)

BASIC_SRCS=$(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.bas, $(SRCDIRS)))))
BASIC_OBJS=$(patsubst %.bas, $(TARGETDIR)/%.tok, $(BASIC_SRCS))

ifeq ($(BUILD_TYPE),cc65)
    export PATH := $(PATH):$(CC65_BIN)

    # By default, use the a2 drivers.  If the machine is one of the enhanced
    # targets though, use the a2e drivers.
    DRV_BASE_MACHINE=a2
    BASE_MACHINE = apple2
    ifneq ($(filter $(MACHINE), apple2enh apple2enh-dos33 apple2enh-system apple2enh-loader apple2enh-reboot),)
        DRV_BASE_MACHINE=a2e
        BASE_MACHINE = apple2enh
    endif

    export CC65_SUPPORTS_APPLE_SINGLE=1
    CC65_CREATE_DEP_ARG=--create-dep $(@:.o=.u)
    CC65_LIST_ARG=-l $(@:.o=.lst)
    CC65_DRV_DIR=$(CC65_HOME)/target/$(BASE_MACHINE)/drv

    MACHCONFIG= -t $(BASE_MACHINE)
    ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
        MACHCONFIG += -C $(BASE_MACHINE)-system.cfg
    else
        ifeq ($(PROJECT_TYPE),ca65)
            MACHCONFIG += -C $(BASE_MACHINE)-asm.cfg
            LDFLAGS += -u __EXEHDR__
        else
            MACHCONFIG += -C $(BASE_MACHINE).cfg
        endif
    endif

    CFLAGS+=-I $(GENDIR)
    ifneq ($(DRIVERS),)
        SRCDIRS+=$(DRVDIR)
    endif

    C_SRCS=$(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.c, $(SRCDIRS)))))
    C_OBJS=$(patsubst %.c, $(OBJDIR)/%.o, $(C_SRCS))
    C_DEPS=$(patsubst %.c, $(OBJDIR)/%.u, $(C_SRCS))

    ASM_SRCS=$(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS)))))
    ASM_OBJS=$(patsubst %.s, $(OBJDIR)/%.o, $(ASM_SRCS))
    ASM_LSTS=$(patsubst %.s, $(OBJDIR)/%.lst, $(ASM_SRCS))

    MAPFILE=$(TARGETDIR)/$(PGM).map

    ifneq ($(START_ADDR),)
        # If the MACHINE is set to an option which does not support a variable
        # start address, then error.
        ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
            $(error You cannot change start address with this machine type)
        endif
    else
        # If not set, then use the default for the config as per cc65
	# documentation
        ifneq ($(filter $(MACHINE), apple2 apple2-dos33 apple2enh apple2enh-dos33),)
            START_ADDR=803
        endif
        ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
            START_ADDR=2000
        endif
        ifneq ($(filter $(MACHINE), apple2-loader apple2-reboot apple2enh-loader apple2enh-reboot),)
            START_ADDR=800
        endif
    endif

    LDFLAGS += --start-addr 0x$(START_ADDR)

    ifneq ($(filter $(MACHINE), apple2 apple2enh apple2-dos33 apple2enh-dos33),)
        EXECCMD=$(shell echo brun $(PGM) | tr '[a-z]' '[A-Z]')
    endif
else
    C_OBJS=
    C_DEPS=

    ASM_OBJS=
    ASM_LSTS=
endif

ifeq ($(BUILD_TYPE),merlin)
    ASM_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS))))
    MAPFILE=$(TARGETDIR)/_Output.txt
    EXECCMD=$(shell echo brun $(PGM) | tr '[a-z]' '[A-Z]')
endif

ifeq ($(BUILD_TYPE),basic)
    MAPFILE=
    EXECCMD=$(shell echo run $(PGM) | tr '[a-z]' '[A-Z]')
endif

OBJS=$(C_OBJS) $(ASM_OBJS)

ALLTARGET=$(DISKIMAGE)


.PHONY: build execute clean cleandrivers xcodefix

build: $(ALLTARGET)

$(DISKIMAGE): $(TARGETDIR)/$(PGM) $(BASIC_OBJS)
	make/createDiskImage $(AC) $(MACHINE) "$(DISKIMAGE)" "$(TARGETDIR)/$(PGM)" "$(START_ADDR)" $(BASIC_OBJS) $(COPYDIRS)

execute: $(DISKIMAGE)
	osascript make/V2Make.scpt "$(TARGETDIR)" "$(PGM)" "$(CWD)/make/DevApple.vii" "$(EXECCMD)"

$(TARGETDIR)/%.tok:	%.bas
	$(MKDIR) `dirname $@`
	make/bt $< $(BASICFLAGS) -o $@

ifneq ($(DRIVERS),)
cleandrivers:
	rm -Rf "$(DRVDIR)"

else
cleandrivers:

endif

clean: genclean cleandrivers
	rm -f "$(TARGETDIR)/$(PGM)" $(OBJS) $(BASIC_OBJS) $(C_DEPS) $(MAPFILE) $(ASM_LSTS) "$(DISKIMAGE)"

cleanMacCruft:
	rm -rf pkg

# Some gen phase stuff...
gen: xcodefix $(DRIVERS)

xcodefix:
	defaults write "$(CC65_PLUGIN_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)s -array `defaults read "$(XCODE_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)` || true


ifeq ($(BUILD_TYPE),basic)
# Build rules for BASIC projects

$(TARGETDIR)/$(PGM): $(BASIC_OBJS)
	cp $(TARGETDIR)/$(PGM).tok $(TARGETDIR)/$(PGM)

$(BASIC_OBJS): Makefile


endif


ifeq ($(BUILD_TYPE),merlin)
# Build rules for Merlin projects

$(TARGETDIR)/$(PGM): $(ASM_SRCS) Makefile
	$(MKDIR) $(TARGETDIR)
	rm -f $(TARGETDIR)/$(PGM)
	$(MERLIN_ASM) linkscript.s $(PGM) $(TARGETDIR)/$(PGM)

endif


ifeq ($(BUILD_TYPE),cc65)
# Build rules for cc65 projects

$(TARGETDIR)/$(PGM): $(OBJS)
	$(MKDIR) `dirname $@`
	make/errorFilter.sh $(CL65) $(MACHCONFIG) --mapfile $(MAPFILE) $(LDFLAGS) -o "$(TARGETDIR)/$(PGM)" $(OBJS)

$(OBJS): Makefile

$(OBJDIR)/%.o:    %.c
	$(MKDIR) `dirname $@`
	make/errorFilter.sh $(CL65) $(MACHCONFIG) $(CFLAGS) $(CC65_CREATE_DEP_ARG) -c -o $@ $<
	sed -i .bak 's/\.s:/.o:/' $(@:.o=.u)
	rm -f $(@:.o=.u).bak

$(OBJDIR)/%.o:	$(GENDIR)/%.c
	$(MKDIR) `dirname $@`
	make/errorFilter.sh $(CL65) $(MACHCONFIG) $(CFLAGS) $(CC65_CREATE_DEP_ARG) -c -o $@ $<
	sed -i .bak 's/\.s:/.o:/' $(@:.o=.u)
	rm -f $(@:.o=.u).bak

$(OBJDIR)/%.o:	%.s
	$(MKDIR) `dirname $@`
	make/errorFilter.sh $(CL65) $(MACHCONFIG) --cpu $(CPU) $(ASMFLAGS) $(CC65_LIST_ARG) -c -o $@ $<

$(OBJDIR)/%.o:    $(GENDIR)/%.s
	$(MKDIR) `dirname $@`
	make/errorFilter.sh $(CL65) $(MACHCONFIG) --cpu $(CPU) $(ASMFLAGS) $(CC65_LIST_ARG) -c -o $@ $<


.PHONY: loresgr hiresgr auxmem joystick mouse serial
# Lores driver codegen
loresgr: $(DRVDIR)/a2_lores_drv.s $(DRVDIR)/a2_lores_drv.h

$(DRVDIR)/a2_lores_drv.s: $(CC65_DRV_DIR)/tgi/$(DRV_BASE_MACHINE).lo.tgi
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_lores_drv -o $@ $(CC65_DRV_DIR)/tgi/$(DRV_BASE_MACHINE).lo.tgi

$(DRVDIR)/a2_lores_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <tgi.h>' > $@
	echo 'extern char a2_lores_drv;' >> $@


# Hires driver codegen
hiresgr: $(DRVDIR)/a2_hires_drv.s $(DRVDIR)/a2_hires_drv.h

$(DRVDIR)/a2_hires_drv.s: $(CC65_DRV_DIR)/tgi/$(DRV_BASE_MACHINE).hi.tgi
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_hires_drv -o $@ $(CC65_DRV_DIR)/tgi/$(DRV_BASE_MACHINE).hi.tgi

$(DRVDIR)/a2_hires_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <tgi.h>' > $@
	echo 'extern char a2_hires_drv;' >> $@


# Auxmem driver codegen
auxmem: $(DRVDIR)/a2_auxmem_drv.s $(DRVDIR)/a2_auxmem_drv.h

$(DRVDIR)/a2_auxmem_drv.s: $(CC65_DRV_DIR)/emd/$(DRV_BASE_MACHINE).auxmem.emd
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_auxmem_drv -o $@ $(CC65_DRV_DIR)/emd/$(DRV_BASE_MACHINE).auxmem.emd

$(DRVDIR)/a2_auxmem_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <em.h>' > $@
	echo 'extern char a2_auxmem_drv;' >> $@


# Joystick driver codegen
joystick: $(DRVDIR)/a2_joystick_drv.s $(DRVDIR)/a2_joystick_drv.h

$(DRVDIR)/a2_joystick_drv.s: $(CC65_DRV_DIR)/joy/$(DRV_BASE_MACHINE).stdjoy.joy
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_joystick_drv -o $@ $(CC65_DRV_DIR)/joy/$(DRV_BASE_MACHINE).stdjoy.joy

$(DRVDIR)/a2_joystick_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <joystick.h>' > $@
	echo 'extern char a2_joystick_drv;' >> $@


# Mouse driver codegen
mouse: $(DRVDIR)/a2_mouse_drv.s $(DRVDIR)/a2_mouse_drv.h

$(DRVDIR)/a2_mouse_drv.s: $(CC65_DRV_DIR)/mou/$(DRV_BASE_MACHINE).stdmou.mou
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_mouse_drv -o $@ $(CC65_DRV_DIR)/mou/$(DRV_BASE_MACHINE).stdmou.mou

$(DRVDIR)/a2_mouse_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <mouse.h>' > $@
	echo 'extern char a2_mouse_drv;' >> $@


# Serial driver codegen
serial: $(DRVDIR)/a2_serial_drv.s $(DRVDIR)/a2_serial_drv.h

$(DRVDIR)/a2_serial_drv.s: $(CC65_DRV_DIR)/ser/$(DRV_BASE_MACHINE).ssc.ser
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_serial_drv -o $@ $(CC65_DRV_DIR)/ser/$(DRV_BASE_MACHINE).ssc.ser

$(DRVDIR)/a2_serial_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <serial.h>' > $@
	echo 'extern char a2_serial_drv;' >> $@

endif


-include $(C_DEPS)
