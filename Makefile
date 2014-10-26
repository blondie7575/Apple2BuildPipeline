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

include make/head.mk

# Customize this file to control what gets built, what machines to
# target, where in memory to put it, etc.

# The name of your system or binary file to build goes here:
PGM=___PACKAGENAME___

# Set the config you are building for.  See these pages for details:
#   http://cc65.github.io/cc65/doc/apple2.html#s4
#   http://cc65.github.io/cc65/doc/apple2enh.html#s4
#
# Uncomment the one you want below (the first one is the default):
#    MACHINE = apple2
#    MACHINE = apple2-dos33
#    MACHINE = apple2-system
#    MACHINE = apple2-loader
#    MACHINE = apple2-reboot
#    MACHINE = apple2enh
#    MACHINE = apple2enh-dos33
#    MACHINE = apple2enh-system
#    MACHINE = apple2enh-loader
#    MACHINE = apple2enh-reboot

# Uncomment and set this to your starting address in Apple ][ memory
# if necessary:
#    START_ADDR = 6000

# Set the default CPU to assemble for.  You can change this in the
# body of a .s file using control commands like ".PC02".  Uncomment
# the one you want below (the first one is the default):
#    CPU = 6502
#    CPU = 65SC02
#    CPU = 65C02
#    CPU = 65816
# Note: You can assemble for 65816 in 16-bit mode but the C compiler
# will only produce 8-bit code.

# Any *.c files in your main project directory will automatically be
# built.  But, if you have subdirectories with C files in them, you 
# should add them to the list of C_SRCS to build.  Do that by
# uncommenting the following line and changing "someSubDir" to match
# the subdirectory you have created.  Add multiple lines like this
# for each subdirectory:
#    C_SRCS += $(wildcard someSubDir/*.c)

# Any *.s files in your main project directory will automatically be
# built.  But, if you have subdirectories with assembly files in them,
# you should add them to the list of ASM_SRCS to build.  Do that by
# uncommenting the following line and changing "someSubDir" to match
# the subdirectory you have created.  Add multiple lines like this
# for each subdirectory:
#    ASM_SRCS += $(wildcard someSubDir/*.s)

# If you have a non-standard cc65 install, you may need to change
# some of these.  Uncomment the following line and change it to the
# correct path to CC65_HOME if the default is not correct:
#    export CC65_HOME := /usr/local/lib/cc65
# 
# If the path to the cc65 binaries is not correct, uncomment this
# line and change it:
#    CC65_BIN = /usr/local/bin

# If you want to add arguments to the compile commandline, add them
# to this variable:
#    CFLAGS += -Os

# If you want to add arguments to the assembly commandline, add them
# to this variable:
#    ASMFLAGS += -g

# If you want to add arguments to the link commandline, add them to
# this variable:
#    LDFLAGS += -v

# If you have java installed in a non-standard location, you can set
# the path to it by uncommenting the following line:
#    export JAVA=/usr/bin/java


# Do not change anything else below here...
include make/tail.mk
