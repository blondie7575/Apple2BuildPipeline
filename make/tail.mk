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

export PATH := $(PATH):$(CC65_BIN)

CWD=$(shell pwd)

ifneq ($(DRIVERS),)
    SRCDIRS+=$(DRVDIR)
endif

C_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.c, $(SRCDIRS))))
C_OBJS=$(C_SRCS:.c=.o)
C_DEPS=$(C_SRCS:.c=.u)

ASM_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS))))
ASM_OBJS=$(ASM_SRCS:.s=.o)
ASM_LSTS=$(ASM_SRCS:.s=.lst)

OBJS=$(C_OBJS) $(ASM_OBJS)

MAPFILE=$(PGM).map
DISKIMAGE=$(PGM).dsk

LINK_ARGS=

EXECCMD=

ALLTARGET=$(DISKIMAGE)

ifneq ($(START_ADDR),)
# If the MACHINE is set to an option which does not support a variable start
# address, then error.
    ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
        $(error You cannot change start address with this machine type)
    endif
else
    # If not set, then use the default for the config as per cc65 documentation
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

# By default, use the a2 drivers.  If the machine is one of the enhanced
# targets though, use the a2e drivers.
DRV_BASE_MACHINE=a2
ifneq ($(filter $(MACHINE), apple2enh apple2enh-dos33 apple2enh-system apple2enh-loader apple2enh-reboot),)
    DRV_BASE_MACHINE=a2e
endif

MACHCONFIG= -t apple2

ifneq ($(filter $(MACHINE), apple2enh apple2apple2enh-dos33 apple2enh-system apple2enh-loader apple2enh-reboot),)
    MACHCONFIG= -t apple2enh
endif

ifeq ($(filter $(MACHINE), apple2 apple2enh),)
    MACHCONFIG += -C $(MACHINE).cfg
endif

.PHONY: build execute clean xcodefix loresgr hiresgr auxmem joystick mouse serial
	
build: $(ALLTARGET)

clean: genclean
	rm -f "$(PGM)"
	rm -f $(OBJS)
	rm -f $(C_DEPS)
	rm -f $(MAPFILE)
	rm -f $(ASM_LSTS)
	rm -f "$(DISKIMAGE)"
	rm -Rf "$(DRVDIR)"

cleanMacCruft:
	rm -rf pkg

$(PGM): $(OBJS)
	make/errorFilter.sh $(CL65) $(MACHCONFIG) --mapfile $(MAPFILE) $(LDFLAGS) -o "$(PGM)" $(OBJS)

$(DISKIMAGE): $(PGM)
	make/createDiskImage $(AC) $(MACHINE) "$(DISKIMAGE)" "$(PGM)" "$(START_ADDR)" $(COPYDIRS)

execute: $(DISKIMAGE)
	osascript make/V2Make.scpt "$(CWD)" "$(PGM)" "$(CWD)/make/DevApple.vii" "$(EXECCMD)"

%.o:	%.c
	make/errorFilter.sh $(CL65) $(MACHCONFIG) $(CFLAGS) --create-dep -c -o $@ $<
	sed -i .bak 's/\.s:/.o:/' $(@:.o=.u)
	rm -f $(@:.o=.u).bak

%.o:	%.s
	make/errorFilter.sh $(CL65) $(MACHCONFIG) --cpu $(CPU) $(ASMFLAGS) -l -c -o $@ $<

$(OBJS): Makefile


# Some gen phase stuff...
gen: xcodefix $(DRIVERS)

xcodefix:
	defaults write "$(CC65_PLUGIN_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)s -array `defaults read "$(XCODE_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)`


# Lores driver codegen
loresgr: $(DRVDIR)/a2_lores_drv.s $(DRVDIR)/a2_lores_drv.h

$(DRVDIR)/a2_lores_drv.s: $(CC65_HOME)/tgi/$(DRV_BASE_MACHINE).lo.tgi
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_lores_drv -o $@ $(CC65_HOME)/tgi/$(DRV_BASE_MACHINE).lo.tgi

$(DRVDIR)/a2_lores_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <tgi.h>' > $@
	echo 'extern char a2_lores_drv;' >> $@


# Hires driver codegen
hiresgr: $(DRVDIR)/a2_hires_drv.s $(DRVDIR)/a2_hires_drv.h

$(DRVDIR)/a2_hires_drv.s: $(CC65_HOME)/tgi/$(DRV_BASE_MACHINE).hi.tgi
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_hires_drv -o $@ $(CC65_HOME)/tgi/$(DRV_BASE_MACHINE).hi.tgi

$(DRVDIR)/a2_hires_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <tgi.h>' > $@
	echo 'extern char a2_hires_drv;' >> $@


# Auxmem driver codegen
auxmem: $(DRVDIR)/a2_auxmem_drv.s $(DRVDIR)/a2_auxmem_drv.h

$(DRVDIR)/a2_auxmem_drv.s: $(CC65_HOME)/emd/$(DRV_BASE_MACHINE).auxmem.emd
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_auxmem_drv -o $@ $(CC65_HOME)/emd/$(DRV_BASE_MACHINE).auxmem.emd

$(DRVDIR)/a2_auxmem_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <em.h>' > $@
	echo 'extern char a2_auxmem_drv;' >> $@


# Joystick driver codegen
joystick: $(DRVDIR)/a2_joystick_drv.s $(DRVDIR)/a2_joystick_drv.h

$(DRVDIR)/a2_joystick_drv.s: $(CC65_HOME)/joy/$(DRV_BASE_MACHINE).stdjoy.joy
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_joystick_drv -o $@ $(CC65_HOME)/joy/$(DRV_BASE_MACHINE).stdjoy.joy

$(DRVDIR)/a2_joystick_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <joystick.h>' > $@
	echo 'extern char a2_joystick_drv;' >> $@


# Mouse driver codegen
mouse: $(DRVDIR)/a2_mouse_drv.s $(DRVDIR)/a2_mouse_drv.h

$(DRVDIR)/a2_mouse_drv.s: $(CC65_HOME)/mou/$(DRV_BASE_MACHINE).stdmou.mou
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_mouse_drv -o $@ $(CC65_HOME)/mou/$(DRV_BASE_MACHINE).stdmou.mou

$(DRVDIR)/a2_mouse_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <mouse.h>' > $@
	echo 'extern char a2_mouse_drv;' >> $@


# Serial driver codegen
serial: $(DRVDIR)/a2_serial_drv.s $(DRVDIR)/a2_serial_drv.h

$(DRVDIR)/a2_serial_drv.s: $(CC65_HOME)/ser/$(DRV_BASE_MACHINE).ssc.ser
	mkdir -p $(DRVDIR)
	$(CO65) --code-label _a2_serial_drv -o $@ $(CC65_HOME)/ser/$(DRV_BASE_MACHINE).ssc.ser

$(DRVDIR)/a2_serial_drv.h:
	mkdir -p $(DRVDIR)
	echo '#include <serial.h>' > $@
	echo 'extern char a2_serial_drv;' >> $@


-include $(C_DEPS)
