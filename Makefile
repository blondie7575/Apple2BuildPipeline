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
	@PATH=$(PATH):/usr/local/bin; $(CL65) -t apple2enh -l$(PGM).lst --start-addr $(ADDR) $(PGM).s
	java -jar $(AC) -d $(PGM).dsk $(PGM)
	java -jar $(AC) -p $(PGM).dsk $(PGM) BIN 0x$(ADDR) < $(PGM)
	rm -f $(PGM)
	rm -f $(PGM).o
	osascript V2Make.scpt $(PROJECT_DIR) $(PGM)
