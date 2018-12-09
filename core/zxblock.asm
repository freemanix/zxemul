
; ZX Spectrum emulator 

; Block moves and compares
; (c) Freeman, August 2000, Prague

; -----------------------------------------------------------------------------

BlockMoveD	MACRO

		push	ax
		mov	di, RegDE
		mov	al, MemIHL
		mov	es:[di], al
		dec	di
		mov	RegDE, di
		pop	di
		dec	RegHL
		and	RegF, NOT flgHPN
		dec	RegBC
		jz	MoveFinish
		or	RegF, flgP
		
		ENDM

; -----------------------------------------------------------------------------

BlockMoveI	MACRO

		push	ax
		mov	di, RegDE
		mov	al, MemIHL
		mov	es:[di], al
		inc	di
		mov	RegDE, di
		pop	di
		inc	RegHL
		and	RegF, NOT flgHPN
		dec	RegBC
		jz	MoveFinish
		or	RegF, flgP
		
		ENDM

; -----------------------------------------------------------------------------

BlockCmpD	MACRO
		
		cmp	RegA, MemIHL
		lahf	
		or	RegF, NOT flgC
		or	ah, NOT flgSZH
		and	RegF, ah
		dec	RegHL
		dec	RegBC
		jz	CmpFinish
		test	RegF, flgZ
		jnz	MoveFinishX
		
		ENDM

; -----------------------------------------------------------------------------

BlockCmpI	MACRO

		cmp	RegA, MemIHL
		lahf	
		or	RegF, NOT flgC
		or	ah, NOT flgSZH
		and	RegF, ah
		inc	RegHL
		dec	RegBC
		jz	CmpFinish
		test	RegF, flgZ
		jnz	MoveFinishX

		ENDM

; -----------------------------------------------------------------------------

ldd:		BlockMoveD
		FetchHere

; -----------------------------------------------------------------------------

ldi:		BlockMoveI
		FetchHere

; -----------------------------------------------------------------------------

MoveFinish:	FetchHere

; -----------------------------------------------------------------------------

lddr:		BlockMoveD
		BlockRepeat
		FetchHere

; -----------------------------------------------------------------------------

ldir:		BlockMoveI
		BlockRepeat
		FetchHere

; -----------------------------------------------------------------------------

cpd:		BlockCmpD
		FetchHere

; -----------------------------------------------------------------------------

cpi:		BlockCmpI
		FetchHere

; -----------------------------------------------------------------------------

CmpFinish:	and	RegF, NOT flgP
		FetchHere

; -----------------------------------------------------------------------------

MoveFinishX:	FetchHere

; -----------------------------------------------------------------------------

cpdr:		BlockCmpD
		BlockRepeat
		FetchHere

; -----------------------------------------------------------------------------

cpir:		BlockCmpI
		BlockRepeat
		FetchHere

; -----------------------------------------------------------------------------
