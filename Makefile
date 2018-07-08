#
#  Makefile
#  Apple2BuildPipelineSample
#
#  Part of a sample build pipeline for Apple ][ software development
#
#  Created by Quinn Dunki on 8/15/14.
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#

CL65=cl65

# You may need to change this to where your AppleCommander is installed:
AC=AppleCommander.jar

# Change this to your desired starting address in Apple ][ memory:
ADDR=6000

# Put the name of your sourcefile here:
PGM=x

all: $(PGM)

install: $(PGM)

clean:
	rm -f $(PGM)
	rm -f $(PGM).o
	rm -f $(PGM).lst

$(PGM):
    # First eject the mounted disk in S6D1, which (in some versions of Virtual II) also rewrites
    # the .dsk image
    osascript V2Eject.scpt $(PROJECT_DIR) $(PGM)
    # Rebuild binary
    @PATH=$(PATH):/usr/local/bin; $(CL65) -t apple2enh --config apple2enh-asm.cfg -l$(PGM).lst --start-addr $(ADDR) $(PGM).s
    # Update the disk image
    java -jar $(AC) -d $(PGM).dsk $(PGM)
    java -jar $(AC) -p $(PGM).dsk $(PGM) BIN 0x$(ADDR) < $(PGM)
    # Clean up for next time
    rm -f $(PGM)
    rm -f $(PGM).o
    # Insert disk into S6D1, reset the machine and invoke -$(PGM) from prompt
    osascript V2Make.scpt $(PROJECT_DIR) $(PGM)

