;
;  ___FILENAME___
;  ___PROJECTNAME___
;
;  Created by ___FULLUSERNAME___ on ___DATE___.
;___COPYRIGHT___
;


COUT = $fded
KEYBOARD = $c000
STROBE = $c010

main:
    ldx #$00
loop:
    lda msg, X
    beq wait
    ora #$80
    jsr COUT
    inx
    jmp loop
    
wait:
    lda KEYBOARD
    bpl wait
    lda STROBE
    rts

msg:    .asciiz "HELLO, WORLD"
