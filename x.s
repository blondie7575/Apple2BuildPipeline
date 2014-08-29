;
;  x.s
;  AssemblyTest
;
;  Part of a sample build pipeline for Apple ][ software development
;
;  Created by Quinn Dunki on 8/15/14.
;  One Girl, One Laptop Productions
;  http://www.quinndunki.com
;  http://www.quinndunki.com/blondihacks
;


.org $6000

; Reserved locations

INVERSE = $32


; Constants

CHAR_NORMAL = $ff
CHAR_INVERSE = $3f
CHAR_FLASH = $7f


; ROM entry points

COUT = $fded



; Main

main:
	lda #CHAR_FLASH
	sta INVERSE

loop:
	lda	#'X' + $80
	jsr	COUT
	jmp loop		; OMG so many Xs

	

