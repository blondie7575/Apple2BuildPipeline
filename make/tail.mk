#
#  tail.mk
#  Apple2BuildPipelineSample
#
#  Part of a sample build pipeline for Apple ][ software development
#
#  Created by Quinn Dunki on 8/15/14.
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#

export PATH := $(PATH):$(CC65_BIN)

C_OBJS=$(C_SRCS:.c=.o)
ASM_OBJS=$(ASM_SRCS:.s=.o)
ASM_LSTS=$(ASM_SRCS:.s=.lst)
OBJS=$(C_OBJS) $(ASM_OBJS)

MAPFILE=$(PGM).map
DISKIMAGE=$(PGM).dsk
DEPSFILE=$(PGM).deps

LINK_ARGS=

ifneq ($(START_ADDR),)
# If the MACHINE is set to an option which does not support a variable start
# address, then error.
    ifneq ($(filter $(MACHINE), apple2-system apple2enh-system),)
        $(error You cannot change start address with this machine type)
    endif
    LINK_ARGS += --start-addr $(START_ADDR)
endif


.PHONY: all execute clean
	
all: execute

clean:
	rm -f $(PGM)
	rm -f $(OBJS)
	rm -f $(MAPFILE)
	rm -f $(ASM_LSTS)
	rm -f $(DISKIMAGE)
	rm -f $(DEPSFILE)

$(PGM): $(OBJS)
	$(CL65) -t $(MACHINE) --mapfile $(MAPFILE) $(LINK_ARGS) -o $(PGM) $(OBJS)

$(DISKIMAGE): $(PGM)
	cp make/prodos_template.dsk $(DISKIMAGE)
	java -jar $(AC) -d $(DISKIMAGE) $(PGM)
	java -jar $(AC) -p $(DISKIMAGE) $(PGM) BIN 0x$(START_ADDR) < $(PGM)

execute: $(DISKIMAGE)
	osascript make/V2Make.scpt $(PROJECT_DIR) $(PGM)

%.o:	%.c
	$(CL65) -t $(MACHINE) --create-dep -c -o $@ $<

%.o:	%.s
	$(CL65) -t $(MACHINE) --cpu $(CPU) -l -c -o $@ $<

