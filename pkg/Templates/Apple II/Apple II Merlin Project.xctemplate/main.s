*
*  ___FILENAME___
*  ___PROJECTNAME___
*
*  Created by ___FULLUSERNAME___ on ___DATE___.
*  ___COPYRIGHT___
*

]XCODESTART     ; Keep this at the start and put your code after this

COUT        equ $fded
KEYBOARD    equ $c000
STROBE      equ $c010
DOSWARM     equ $3d0
CR          equ #$8d

START       lda CR
            jsr COUT
            
            ldx #$00
LOOP        lda MSG,X
            beq WAIT
            jsr COUT
            inx
            jmp LOOP
            
WAIT        lda KEYBOARD
            bpl WAIT
            lda STROBE
            
            lda CR
            jsr COUT
            
            jmp DOSWARM

MSG         asc "HELLO, WORLD",00

]XCODEEND       ; Keep this at the end and put your code above this

