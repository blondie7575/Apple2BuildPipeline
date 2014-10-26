#
#  head.mk
#  Apple2BuildPipelineSample
#
#  Part of a sample build pipeline for Apple II software development
#
#  Created by Quinn Dunki on 8/15/14.
#  One Girl, One Laptop Productions
#  http://www.quinndunki.com
#  http://www.quinndunki.com/blondihacks
#

export CC65_HOME := /usr/local/lib/cc65

CC65_BIN = /usr/local/bin

CL65=$(CC65_BIN)/cl65
CA65=$(CC65_BIN)/ca65
CC65=$(CC65_BIN)/cc65

AC=make/AppleCommander.jar

C_SRCS=$(wildcard *.c)
ASM_SRCS=$(wildcard *.s)

MACHINE=apple2
CPU=6502
CFLAGS=
ASMFLAGS=
LDFLAGS=
