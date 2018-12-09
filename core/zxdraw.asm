
; ZX Spectrum emulator 

; Psion screen drawing
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

DrawInkBytes	MACRO

		lodsw	
		xlat		cs:BitSwapTable
		xchg		al, ah
		xlat		cs:BitSwapTable
		xchg		al, ah
		stosw
		
		ENDM

; -----------------------------------------------------------------------------

ScrWidth	EQU		480
ScrHeight	EQU		160

ScrRow		EQU		ScrWidth/8
ScrSegment	EQU		040h
ScrBytes	EQU		ScrRow*ScrHeight

ScrGray		EQU		ScrBytes
ScrRowNext	EQU		ScrRow-32
ScrRowSkip	EQU		(ScrRow-32)/2

; -----------------------------------------------------------------------------

DrawModeIN	EQU		0		
DrawModeBW	EQU		1		
DrawModeGR	EQU		2		

; -----------------------------------------------------------------------------

BW00		EQU		0
BW01		EQU		1
BW10		EQU		2
BW11		EQU		3

; -----------------------------------------------------------------------------

GR00		EQU		0
GR01		EQU		1
GR02		EQU		2
GR10		EQU		3
GR11		EQU		4
GR12		EQU		5
GR20		EQU		6
GR21		EQU		7
GR22		EQU		8

; -----------------------------------------------------------------------------

		ALIGN

ScrPtr		DW		?
FlashMask	DW		?
DataSeg		DW		?
ZXSeg		DW		?
LastBorder	DW		?

; -----------------------------------------------------------------------------

BitSwapTable	DB		000h, 080h, 040h, 0C0h, 020h, 0A0h, 060h, 0E0h
		DB		010h, 090h, 050h, 0D0h, 030h, 0B0h, 070h, 0F0h
		DB		008h, 088h, 048h, 0C8h, 028h, 0A8h, 068h, 0E8h
		DB		018h, 098h, 058h, 0D8h, 038h, 0B8h, 078h, 0F8h
		DB		004h, 084h, 044h, 0C4h, 024h, 0A4h, 064h, 0E4h
		DB		014h, 094h, 054h, 0D4h, 034h, 0B4h, 074h, 0F4h
		DB		00Ch, 08Ch, 04Ch, 0CCh, 02Ch, 0ACh, 06Ch, 0ECh
		DB		01Ch, 09Ch, 05Ch, 0DCh, 03Ch, 0BCh, 07Ch, 0FCh
		DB		002h, 082h, 042h, 0C2h, 022h, 0A2h, 062h, 0E2h
		DB		012h, 092h, 052h, 0D2h, 032h, 0B2h, 072h, 0F2h
		DB		00Ah, 08Ah, 04Ah, 0CAh, 02Ah, 0AAh, 06Ah, 0EAh
		DB		01Ah, 09Ah, 05Ah, 0DAh, 03Ah, 0BAh, 07Ah, 0FAh
		DB		006h, 086h, 046h, 0C6h, 026h, 0A6h, 066h, 0E6h
		DB		016h, 096h, 056h, 0D6h, 036h, 0B6h, 076h, 0F6h
		DB		00Eh, 08Eh, 04Eh, 0CEh, 02Eh, 0AEh, 06Eh, 0EEh
		DB		01Eh, 09Eh, 05Eh, 0DEh, 03Eh, 0BEh, 07Eh, 0FEh
		DB		001h, 081h, 041h, 0C1h, 021h, 0A1h, 061h, 0E1h
		DB		011h, 091h, 051h, 0D1h, 031h, 0B1h, 071h, 0F1h
		DB		009h, 089h, 049h, 0C9h, 029h, 0A9h, 069h, 0E9h
		DB		019h, 099h, 059h, 0D9h, 039h, 0B9h, 079h, 0F9h
		DB		005h, 085h, 045h, 0C5h, 025h, 0A5h, 065h, 0E5h
		DB		015h, 095h, 055h, 0D5h, 035h, 0B5h, 075h, 0F5h
		DB		00Dh, 08Dh, 04Dh, 0CDh, 02Dh, 0ADh, 06Dh, 0EDh
		DB		01Dh, 09Dh, 05Dh, 0DDh, 03Dh, 0BDh, 07Dh, 0FDh
		DB		003h, 083h, 043h, 0C3h, 023h, 0A3h, 063h, 0E3h
		DB		013h, 093h, 053h, 0D3h, 033h, 0B3h, 073h, 0F3h
		DB		00Bh, 08Bh, 04Bh, 0CBh, 02Bh, 0ABh, 06Bh, 0EBh
		DB		01Bh, 09Bh, 05Bh, 0DBh, 03Bh, 0BBh, 07Bh, 0FBh
		DB		007h, 087h, 047h, 0C7h, 027h, 0A7h, 067h, 0E7h
		DB		017h, 097h, 057h, 0D7h, 037h, 0B7h, 077h, 0F7h
		DB		00Fh, 08Fh, 04Fh, 0CFh, 02Fh, 0AFh, 06Fh, 0EFh
		DB		01Fh, 09Fh, 05Fh, 0DFh, 03Fh, 0BFh, 07Fh, 0FFh

; -----------------------------------------------------------------------------

AttrTableBW	DB		BW00, BW01, BW01, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW00, BW01, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW00, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW00, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW11, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW11, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW10, BW11, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW10, BW10, BW11

		DB		BW00, BW01, BW01, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW00, BW01, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW00, BW01, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW00, BW01, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW11, BW01, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW11, BW01, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW10, BW11, BW01
		DB		BW10, BW10, BW10, BW10, BW10, BW10, BW10, BW11

		DB		BW00, BW10, BW10, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW00, BW10, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW00, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW00, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW11, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW11, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW01, BW11, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW01, BW01, BW11

		DB		BW00, BW10, BW10, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW00, BW10, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW00, BW10, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW00, BW10, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW11, BW10, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW11, BW10, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW01, BW11, BW10
		DB		BW01, BW01, BW01, BW01, BW01, BW01, BW01, BW11

; -----------------------------------------------------------------------------

AttrTableGR	DB		GR00, GR00, GR01, GR01, GR01, GR02, GR02, GR02
		DB		GR00, GR00, GR01, GR01, GR01, GR02, GR02, GR02
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22

		DB		GR00, GR00, GR01, GR01, GR01, GR02, GR02, GR02
		DB		GR00, GR00, GR01, GR01, GR01, GR02, GR02, GR02
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR10, GR10, GR11, GR11, GR11, GR12, GR12, GR12
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22
		DB		GR20, GR20, GR21, GR21, GR21, GR22, GR22, GR22

		DB		GR00, GR00, GR10, GR10, GR10, GR20, GR20, GR20
		DB		GR00, GR00, GR10, GR10, GR10, GR20, GR20, GR20
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22

		DB		GR00, GR00, GR10, GR10, GR10, GR20, GR20, GR20
		DB		GR00, GR00, GR10, GR10, GR10, GR20, GR20, GR20
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR01, GR01, GR11, GR11, GR11, GR21, GR21, GR21
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22
		DB		GR02, GR02, GR12, GR12, GR12, GR22, GR22, GR22

; -----------------------------------------------------------------------------

AttrRoutineBW	DW		BW_00_00
		DW		BW_00_01
		DW		BW_00_10
		DW		BW_00_11
		
		DW		BW_01_00
		DW		BW_01_01
		DW		BW_01_10
		DW		BW_01_11
		
		DW		BW_10_00
		DW		BW_10_01
		DW		BW_10_10
		DW		BW_10_11
		
		DW		BW_11_00
		DW		BW_11_01
		DW		BW_11_10
		DW		BW_11_11

; -----------------------------------------------------------------------------

AttrRoutineGR	DW		GR_00
		DW		GR_01
		DW		GR_02

		DW		GR_10
		DW		GR_11
		DW		GR_12

		DW		GR_20
		DW		GR_21
		DW		GR_22

; -----------------------------------------------------------------------------

BorderTable	DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1

		DW		BorderBW_0
		DW		BorderBW_0
		DW		BorderBW_0
		DW		BorderBW_0
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1
		DW		BorderBW_1

		DW		BorderBW_0
		DW		BorderBW_0
		DW		BorderGR_1
		DW		BorderGR_1
		DW		BorderGR_1
		DW		BorderGR_2
		DW		BorderGR_2
		DW		BorderGR_2

; -----------------------------------------------------------------------------

BW_00_00:	inc		si
		inc		si
		mov		ax, cx
		stosw
		ret
		
BW_00_01:	lodsw
		mov		ah, ch
		not		al
		xlat		cs:BitSwapTable
		stosw
		ret
		
BW_00_10:	lodsw
		mov		ah, ch
		xlat		cs:BitSwapTable
		stosw
		ret

BW_00_11:	inc		si
		inc		si
		mov		ah, ch
		xor		al, al
		stosw
		ret
		
BW_01_00:	lodsw
		mov		al, ah
		xlat		cs:BitSwapTable
		mov		ah, al
		not		ah
		mov		al, cl
		stosw
		ret

BW_01_01:	lodsw
		xlat		cs:BitSwapTable
		xchg		al, ah
		xlat		cs:BitSwapTable
		xchg		al, ah
		not		ax
		stosw
		ret

BW_01_10:	lodsw
		xlat		cs:BitSwapTable
		xchg		al, ah
		xlat		cs:BitSwapTable
		xchg		al, ah
		not		ah
		stosw
		ret

BW_01_11:	lodsw
		mov		al, ah
		xlat		cs:BitSwapTable
		mov		ah, al
		not		ah
		xor		al, al
		stosw
		ret

BW_10_00:	lodsw
		mov		al, ah
		xlat		cs:BitSwapTable
		mov		ah, al
		mov		al, cl
		stosw
		ret

BW_10_01:	lodsw
		xlat		cs:BitSwapTable
		xchg		al, ah
		xlat		cs:BitSwapTable
		xchg		al, ah
		not		al
		stosw
		ret

BW_10_10:	lodsw
		xlat		cs:BitSwapTable
		xchg		al, ah
		xlat		cs:BitSwapTable
		xchg		al, ah
		stosw
		ret

BW_10_11:	lodsw
		mov		al, ah
		xlat		cs:BitSwapTable
		mov		ah, al
		xor		al, al
		stosw
		ret

BW_11_00:	inc		si
		inc		si
		mov		al, cl
		xor		ah, ah
		stosw
		ret

BW_11_01:	lodsw
		xlat		cs:BitSwapTable
		not		al
		xor		ah, ah
		stosw
		ret

BW_11_10:	lodsw
		xlat		cs:BitSwapTable
		xor		ah, ah
		stosw
		ret

BW_11_11:	inc		si
		inc		si
		xor		ax, ax
		stosw
		ret
		
; -----------------------------------------------------------------------------

GR_00:		inc		si
		mov		al, ch
		stosb
		ret

GR_01:		lodsb	
		xlat		cs:BitSwapTable
		mov		es:[di+ScrGray], al
		not		al
		stosb
		ret
		
GR_02:		lodsb
		xlat		cs:BitSwapTable
		mov		es:[di+ScrGray], cl
		not		al
		stosb
		ret

GR_10:		lodsb
		xlat		cs:BitSwapTable
		mov		es:[di+ScrGray], ch
		stosb
		ret

GR_11:		inc		si
		mov		es:[di+ScrGray], ch
		mov		al, cl
		stosb
		ret

GR_12:		lodsb
		xlat		cs:BitSwapTable
		not		al
		mov		es:[di+ScrGray], al
		mov		al, cl
		stosb
		ret

GR_20:		lodsb
		xlat		cs:BitSwapTable
		mov		es:[di+ScrGray], cl
		stosb
		ret

GR_21:		lodsb
		xlat		cs:BitSwapTable
		mov		es:[di+ScrGray], al
		mov		al, cl
		stosb
		ret

GR_22:		inc		si
		mov		es:[di+ScrGray], cl
		mov		al, cl
		stosb
		ret
		
; -----------------------------------------------------------------------------

BorderBW:	stosw
		add		di, 32
		stosw
		add		di, ScrRowNext-4
		loop		BorderBW
		ret
		
BorderGR:	mov		es:[di+ScrGray], bx
		stosw
		add		di, 32
		mov		es:[di+ScrGray], bx
		stosw
		add		di, ScrRowNext-4
		loop		BorderGR
		ret

BorderBW_0:	mov		ax, 0FFFFh
		jmp		BorderBW

BorderBW_1:	xor		ax, ax
		jmp		BorderBW
		
BorderGR_1:	xor		ax, ax
		mov		bx, 0FFFFh
		jmp		BorderGR
		
BorderGR_2:	xor		ax, ax
		mov		bx, ax
		jmp		BorderGR

; -----------------------------------------------------------------------------

ZX_DrawScreen	PROC		

		; si = RqPtr, bp = IntPtr
		
		cli
		push		si
		
		; dx = pointer to ZX screen rows starts

		mov		dx, [si].RqA1Ptr
		
		; get mask
		
		mov		cx, [si].RqA2Ptr
		
		; calculate initial attribute address

		mov		bx, dx		
		mov		al, [bx]
		mov		ah, 058h
		dec		ax
		dec		ax
		mov		si, ax

		; store data segment
				
		mov		cs:DataSeg, ds
		
		; get ZX memory segment into ds
		
		GenDataSegment
		mov		bx, cs:ZXMemorySeg
		mov		ds, es:[bx]
		
		; store ZX segment
		
		mov		cs:ZXSeg, ds
				
		; get Psion screen segment into es
		
		mov		ax, ScrSegment
		mov		es, ax
		
		; get initial address in Psion screen
		
		mov		di, ScrRowSkip

		; ink mode ?
		
		mov		bx, offset DrawIN
		cmp		cl, DrawModeIN
		jz		DoDraw
		
		; black & white mode ?
		
		mov		bx, offset DrawBW
		cmp		cl, DrawModeBW
		jz		DoDraw

		; gray mode
		
		mov		bx, offset DrawGR
		
		; call drawing routine
		
DoDraw:		call		bx

		; restore segment registers
		
		mov		ds, [bp].IntDS
		mov		es, [bp].IntES
		pop		si
		sti
		
		ret
		
ZX_DrawScreen	ENDP

; -----------------------------------------------------------------------------
		
DrawIN		PROC		NEAR

		; prepared: cx, dx, si, di, ds, es

		cld
		mov		bx, offset BitSwapTable
		mov		cx, ScrHeight
		
		; fetch next ZX screen row start address

NextRowIN:	mov		ds, cs:DataSeg
		mov		si, dx
		lodsw
		mov		dx, si
		mov		ds, cs:ZXSeg
		
		mov		si, ax

		; copy 32 bytes (with bit swap) from ds:si to es:di
		
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		DrawInkBytes			
		
		; move to next screen row

		add		di, ScrRowNext
		
		; iterate
		
		dec		cx
		jz		EndDrawIN
		jmp		NextRowIN
		
EndDrawIN:	ret		

DrawIN		ENDP
		
; -----------------------------------------------------------------------------

DrawBW		PROC		NEAR

		; prepared: cx, dx, si, di, ds, es
		
		push		si
		
		; store flash mask

		mov		cl, ch
		mov		cs:FlashMask, cx
		
		; invalidate ScrPtr
		
		mov		byte ptr cs:ScrPtr, cl

		; get start of row in ZX screen into ax

NextRowBW:	mov		ds, cs:DataSeg
		mov		si, dx
		lodsw		
		mov		dx, si
		mov		ds, cs:ZXSeg

		; check if next attributes must be compiled
		
		cmp		al, byte ptr cs:ScrPtr
		mov		cs:ScrPtr, ax
		jnz		CompileBW
		
		; rewind program
		
		sub		sp, 32+2
		
		; prepare to run
		
RunBW:		mov		si, ax
		mov		bx, offset BitSwapTable
		mov		cx, 0FFFFh
		
		; ret will start compiled program
		
		cld
		ret
		
CompileBW:	; get stored ZX attribute addr into si
		
		pop		si
		add		si, 32
		push		si
		
		; store pointer again
		
		std
		mov		cx, 16
		
		; store program termination point
		
		push		offset ProgEndBW
		
NextAttrBW:	lodsw
		
		; apply flash
		
		and		ax, cs:FlashMask
		
		; ax = ATTR2:ATTR1
		
		mov		bx, offset AttrTableBW
		xlat		cs:AttrTableBW
		xchg		al, ah
		xlat		cs:AttrTableBW
		
		; ah = code[ATTR1], al = code[ATTR2]
		
		add		al, al
		add		al, al
		add		al, ah
		mov		bl, al
		xor		bh, bh
		add		bx, bx
		
		; bx = 2*(al + 4*ah)
		
		push		word ptr cs:[bx+AttrRoutineBW]

		; next ?
		
		loop		NextAttrBW
		
		; run compiled program

		mov		ax, cs:ScrPtr		
		jmp		RunBW
		
		; check if at the end of screen
		
ProgEndBW:	add		di, ScrRowNext
		cmp		di, ScrRowSkip+ScrBytes
		jnz		NextRowBW
		
		pop		ax
		ret	
		
DrawBW		ENDP		

; -----------------------------------------------------------------------------

DrawGR		PROC		NEAR

		; prepared: cx, dx, si, di, ds, es
		
		push		si
		
		; store flash mask

		mov		cl, ch
		mov		cs:FlashMask, cx
		
		; invalidate ScrPtr
		
		mov		byte ptr cs:ScrPtr, cl
		
		; get start of row in ZX screen into ax

NextRowGR:	mov		ds, cs:DataSeg
		mov		si, dx
		lodsw		
		mov		dx, si
		mov		ds, cs:ZXSeg

		; check if next attributes must be compiled
		
		cmp		al, byte ptr cs:ScrPtr
		mov		cs:ScrPtr, ax
		jnz		CompileGR
		
		; rewind program
		
		sub		sp, 32*2+2
		
		; prepare to run
		
RunGR:		mov		si, ax
		mov		bx, offset BitSwapTable
		mov		cx, 0FF00h
		
		; ret will start compiled program
		
		cld
		ret
		
CompileGR:	; get stored ZX attribute addr into si
		
		pop		si
		add		si, 32
		push		si
		
		; store pointer again
		
		std
		mov		cx, 16
		
		; store program termination point
		
		push		offset ProgEndGR
		
NextAttrGR:	lodsw
		
		; apply flash
		
		and		ax, cs:FlashMask
		
		; ax = ATTR2:ATTR1
		
		mov		bx, offset AttrTableGR
		xchg		al, ah
		xlat		cs:AttrTableGR
		
		mov		bl, al
		xor		bh, bh
		add		bx, bx

		; bx = 2*code[ATTR2]

		push		word ptr cs:[bx+AttrRoutineGR]

		mov		bx, offset AttrTableGR
		mov		al, ah
		xlat		cs:AttrTableGR

		mov		bl, al
		xor		bh, bh
		add		bx, bx

		; bx = 2*code[ATTR1]

		push		word ptr cs:[bx+AttrRoutineGR]

		; process next attributes on a row

		loop		NextAttrGR
		
		; run compiled program

		mov		ax, cs:ScrPtr		
		jmp		RunGR

		; check if at the end of screen
		
ProgEndGR:	add		di, ScrRowNext
		cmp		di, ScrRowSkip+ScrBytes
		jnz		NextRowGR
		
		pop		ax
		ret
		
DrawGR		ENDP		

; -----------------------------------------------------------------------------

ZX_DrawBorder	PROC

		; si = RqPtr, bp = IntPtr
		
		cli
		push		si
		
		; ax = 16*color mode
		
		mov		ax, [si].RqA1Ptr
		xor		ah, ah
		shl		ax, 4
		
		; bx = 2*border color
		
		mov		bl, cs:[AllPorts+0FEh]
		and		bl, 007h
		xor		bh, bh
		add		bx, bx
		
		; bx = drawing routine

		add		bx, ax		
		mov		bx, cs:[bx+BorderTable]
		
		; compare with last used drawing routine
		
		cmp		bx, cs:LastBorder
		mov		cs:LastBorder, bx
		jz		Finished
			
		; get Psion screen segment into es
		
		mov		ax, ScrSegment
		mov		es, ax
		
		; draw border
		
		mov		cx, 160
		mov		di, ScrRowSkip-2
		call		bx
		
		; restore segment registers
		
Finished:	mov		es, [bp].IntES
		pop		si
		sti
		
		ret

ZX_DrawBorder	ENDP

; -----------------------------------------------------------------------------

ZX_EraseGray	PROC

		cli
		push		si
		
		; get Psion screen segment into es
		
		mov		ax, ScrSegment
		mov		es, ax
		
		; prepare to erase gray plane
		
		xor		ax, ax
		mov		bx, 160
		mov		di, ScrGray + ScrRowSkip - 2
		
EraseNext:	mov		cx, 16+2
		rep		stosw
		add		di, ScrRowNext - 4
		dec		bx
		jnz		EraseNext

		; restore segments

		mov		es, [bp].IntES
		pop		si
		sti
		ret

ZX_EraseGray	ENDP

; -----------------------------------------------------------------------------

ZX_ForceRedraw	PROC

		; invalidate last border color to force redraw

		xor		ax, ax
		mov		cs:LastBorder, ax
		ret

ZX_ForceRedraw	ENDP

; -----------------------------------------------------------------------------
