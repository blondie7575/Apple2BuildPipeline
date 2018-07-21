;
;  ___FILENAME___
;  ___PROJECTNAME___
;
;  Created by ___FULLUSERNAME___ on ___DATE___.
;  ___COPYRIGHT___
;

.include "apple2.inc"

COUT = $fded
CR = $8d

.proc main
    lda #CR
    jsr COUT

    ldx #$00
loop:
    lda msg, X
    beq wait
    ora #$80
    jsr COUT
    inx
    jmp loop
    
wait:
    lda KBD
    bpl wait
    lda KBDSTRB

    lda #CR
    jsr COUT

    jmp DOSWARM
.endproc

msg:    .asciiz "HELLO, WORLD"

